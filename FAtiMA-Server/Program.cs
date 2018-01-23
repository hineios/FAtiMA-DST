using AssetManagerPackage;
using IntegratedAuthoringTool;
using Newtonsoft.Json;
using RolePlayCharacter;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;

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

            //Loading the asset
            Console.Write("Loading Scenario...");
            IntegratedAuthoringToolAsset IAT = IntegratedAuthoringToolAsset.LoadFromFile("Example Character/FAtiMA-DST.iat");
            Console.WriteLine(" Done");

            // TODO Support multiple RPCs
            Console.Write("Loading character...");
            RolePlayCharacterAsset Walter = RolePlayCharacterAsset.LoadFromFile(IAT.GetAllCharacterSources().FirstOrDefault().Source);
            Walter.LoadAssociatedAssets();
            // bind ValidDialogue dynamic property to RPC
            IAT.BindToRegistry(Walter.DynamicPropertiesRegistry);

            Console.WriteLine(" Complete!");
            
            WebServer ws = new WebServer(
                (HttpListenerRequest request) =>
                    {
                        lock (l)
                        {
                            switch (request.RawUrl)
                            {
                                case "/perceptions":
                                    if (request.HasEntityBody)
                                    {
                                        using (System.IO.Stream body = request.InputStream) // here we have data
                                        {
                                            using (System.IO.StreamReader reader = new System.IO.StreamReader(body, request.ContentEncoding))
                                            {
                                                string e = reader.ReadToEnd();
                                                var p = JsonConvert.DeserializeObject<Perceptions>(e);
                                                try
                                                {
                                                    p.UpdatePerceptions(Walter);
                                                }
                                                catch (Exception excpt)
                                                {
                                                    //Debug.WriteLine(p.ToString());
                                                    throw new Exception(p.ToString());
                                                }
                                                return JsonConvert.True;
                                            }
                                        }
                                    }
                                    return JsonConvert.False;
                                case "/decide":
                                    var decision = Walter.Decide();
                                    if (decision.Count() < 1)
                                        return JsonConvert.Null;
                                    var action = Action.ToAction(decision.First(), IAT);
                                    string t = decision.Count().ToString() + ": ";
                                    foreach (var a in decision)
                                    {
                                        t += a.Name + " = " + a.Target + "; ";
                                    }
                                    Debug.WriteLine(t);
                                    Console.WriteLine(JsonConvert.SerializeObject(action));
                                    return JsonConvert.SerializeObject(action);
                                case "/events":
                                    if (request.HasEntityBody)
                                    {
                                        using (System.IO.Stream body = request.InputStream) // here we have data
                                        {
                                            using (System.IO.StreamReader reader = new System.IO.StreamReader(body, request.ContentEncoding))
                                            {
                                                string s = reader.ReadToEnd();
                                                var e = JsonConvert.DeserializeObject<Event>(s);
                                                try
                                                {
                                                    e.Perceive(Walter);
                                                }
                                                catch (Exception excpt)
                                                {
                                                    //Debug.WriteLine(e.ToString());
                                                    throw new Exception(e.ToString());
                                                }
                                                return JsonConvert.True;
                                            }
                                        }
                                    }
                                    return JsonConvert.False;
                                default:
                                    return JsonConvert.Null;
                            }
                        }
                    }
            , "http://localhost:8080/");
            ws.Run();
            Console.WriteLine("Press a key to quit.");
            Console.ReadKey();
            ws.Stop();

            Walter.SaveToFile("./walter-final.rpc");
        }
    }
}
