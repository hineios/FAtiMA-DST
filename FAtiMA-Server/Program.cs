using AssetManagerPackage;
using IntegratedAuthoringTool;
using Newtonsoft.Json;
using RolePlayCharacter;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using WellFormedNames;

namespace FAtiMA_Server
{
    class Program
    {
        static void Main(string[] args)
        {
            // A lock to proccess requests non concurrently
            // FAtiMA-Toolkit is not thread safe
            Object l = new Object();

            AssetManager.Instance.Bridge = new BasicIOBridge();
            
            // FAtiMA stuff
            IntegratedAuthoringToolAsset IAT;
            Dictionary<string, RolePlayCharacterAsset> RPCs = new Dictionary<string, RolePlayCharacterAsset>();

            // Ensure that the save directory exists
            Directory.CreateDirectory("Saved Characters");

            // Loading the Scenario
            // Need to use fullpaths for everything due to FAtiMA's handling of paths
            Console.Write("Loading Scenario...");
            IAT = IntegratedAuthoringToolAsset.LoadFromFile(Path.GetFullPath("Example Character\\FAtiMA-DST.iat"));
            Console.WriteLine(" Done");

            WebServer ws = new WebServer(
                (HttpListenerRequest request) =>
                    {
                        lock (l)
                        {
                            Char[] delimiters = { '/' };
                            String[] splitted = request.RawUrl.Split(delimiters);

                            if (splitted.Length < 3) throw new Exception("Invalid number of arguments for the request.");

                            RolePlayCharacterAsset RPC;

                            // Check if the referenced RPC already exists (either loaded or saved) and create or load it
                            if (!RPCs.ContainsKey(splitted[1]))
                            {
                                try
                                {
                                    // Try and load it from a saved file
                                    string s = Path.GetFullPath("Saved Characters\\" + splitted[1] + ".rpc");
                                    Console.Write("Loading from saved file... ");
                                    
                                    RPC = RolePlayCharacterAsset.LoadFromFile(s);
                                    RPC.LoadAssociatedAssets();
                                    // Bind ValidDialogue dynamic property to RPC
                                    IAT.BindToRegistry(RPC.DynamicPropertiesRegistry);

                                    RPCs.Add(splitted[1], RPC);
                                    Console.WriteLine("Done");
                                }
                                catch
                                {
                                    // If it fails we need to load it from the default RPC in the scenario
                                    string s = IAT.GetAllCharacterSources().FirstOrDefault().Source;
                                    Console.Write("No save file found, loading from default character... ");

                                    RPC = RolePlayCharacterAsset.LoadFromFile(s);
                                    RPC.LoadAssociatedAssets();
                                    // Bind ValidDialogue dynamic property to RPC
                                    IAT.BindToRegistry(RPC.DynamicPropertiesRegistry);

                                    RPCs.Add(splitted[1], RPC);
                                    Console.WriteLine("Done");
                                }
                            }
                            else
                            {
                                // The RPC should exist (already checked)
                                // If we get an error it should stop processing the request with the error
                                // So there is no handling for the ArgumentNullException
                                RPCs.TryGetValue(splitted[1], out RPC);
                            }
                            

                            // Process the request
                            switch (splitted[2])
                            {
                                case "perceptions":
                                    if (request.HasEntityBody)
                                    {
                                        using (System.IO.Stream body = request.InputStream) // here we have data
                                        {
                                            using (System.IO.StreamReader reader = new System.IO.StreamReader(body, request.ContentEncoding))
                                            {
                                                string e = reader.ReadToEnd();
                                                var p = JsonConvert.DeserializeObject<Perceptions>(e);
                                                p.UpdatePerceptions(RPC);
                                                return JsonConvert.True;
                                            }
                                        }
                                    }
                                    return JsonConvert.Null;
                                case "decide":
                                    // If there is a layer for the decision, use it
                                    IEnumerable<ActionLibrary.IAction> decision;
                                    if (splitted.Count() > 3 && splitted[3] != "")
                                        decision = RPC.Decide((Name)splitted[3]);
                                    else
                                        decision = RPC.Decide();

                                    if (decision.Count() < 1)
                                        return JsonConvert.Null;

                                    Action action = Action.ToAction(decision.First(), IAT);

                                    return JsonConvert.SerializeObject(action);
                                case "events":
                                    if (request.HasEntityBody)
                                    {
                                        using (System.IO.Stream body = request.InputStream) // here we have data
                                        {
                                            using (System.IO.StreamReader reader = new System.IO.StreamReader(body, request.ContentEncoding))
                                            {
                                                string s = reader.ReadToEnd();
                                                var e = JsonConvert.DeserializeObject<Event>(s);
                                                e.Perceive(RPC);
                                                return JsonConvert.True;
                                            }
                                        }
                                    }
                                    return JsonConvert.Null;
                                default:
                                    return JsonConvert.Null;
                            }
                        }
                    }
            , "http://localhost:8080/");

            ws.Run();
            Console.WriteLine("Press a key to quit.");
            Console.ReadKey();
            Console.WriteLine("Stopping Server...");
            ws.Stop();

            Console.Write("Saving Characters to files... ");
            foreach (KeyValuePair<string, RolePlayCharacterAsset> pair in RPCs)
                pair.Value.SaveToFile(Path.GetFullPath("Saved Characters\\" + pair.Key + ".rpc"));
            Console.WriteLine("Saved {0} characters successfuly.", RPCs.Count);
            Console.ReadKey();
        }
    }
}
