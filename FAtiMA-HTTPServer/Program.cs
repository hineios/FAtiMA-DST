using AssetManagerPackage;
using Newtonsoft.Json;
using RolePlayCharacter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using WellFormedNames;

namespace FAtiMA_Server
{
    class Program
    {
        private static Object l = new Object();
        private static RolePlayCharacterAsset Walter;
        static void Main(string[] args)
        {
            AssetManager.Instance.Bridge = new BasicIOBridge();
            Console.Write("Loading Character from file... ");
            Walter = RolePlayCharacterAsset.LoadFromFile("./walter.rpc");
            Walter.LoadAssociatedAssets();
            Console.WriteLine("Complete!");

            WebServer ws = new WebServer(SendResponse, "http://localhost:8080/");
            ws.Run();
            Console.WriteLine("Press a key to quit.");
            Console.ReadKey();
            ws.Stop();

            Walter.SaveToFile("./water-final.rpc");
        }

        public static string SendResponse(HttpListenerRequest request)
        {
            lock (l)
            {
                switch (request.RawUrl)
                {
                    case "/events":
                        Console.Write("An event occured... ");

                        //TODO: process event

                        Console.WriteLine("Event processed!");
                        goto case "/decide";
                    case "/decide":
                        Console.WriteLine("Deciding... ");

                        var decision = Walter.Decide();
                        List<Action> actions = new List<Action>();
                        foreach (var d in decision)
                        {
                            actions.Add(Action.ToAction(d));
                        }

                        Console.WriteLine("Done!");

                        return JsonConvert.SerializeObject(actions);

                    case "/beliefs":
                            if (request.HasEntityBody)
                            {
                                using (System.IO.Stream body = request.InputStream) // here we have data
                                {
                                    using (System.IO.StreamReader reader = new System.IO.StreamReader(body, request.ContentEncoding))
                                    {
                                        Console.Write("Updating Beliefs... ");

                                        string e = reader.ReadToEnd();
                                        var p = JsonConvert.DeserializeObject<Perceptions>(e);
                                        p.UpdateBeliefs(Walter);

                                        Console.WriteLine(" Done!");
                                        return JsonConvert.True;
                                    }
                                }
                            }
                            Console.WriteLine("Couldn't update beliefs");
                            return JsonConvert.False;

                    default:
                        return JsonConvert.Null;
                }
            }
        }
    }
}
