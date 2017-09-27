using AssetManagerPackage;
using Newtonsoft.Json;
using RolePlayCharacter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using WellFormedNames;

namespace FAtiMA_HTTPServer
{
    class Program
    {
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
            switch (request.RawUrl)
            {
                case "/decide":
                    Console.Write("Deciding... ");
                    var a = Walter.Decide().FirstOrDefault().Name.ToString();
                    Console.WriteLine(a);
                    return a;
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

                                //Console.WriteLine(p.ToString());
                                //Console.WriteLine("Percept " + e);
                                //events.Add(Perception.FromJSON(e));
                                //Walter.Perceive(events);
                                return "BeliefsUpdated: true";
                            }
                        }
                    }
                    Console.WriteLine("Couldn't update beliefs");
                    return "BeliefsUpdated: false";
                default:
                    return "";
            }
        }
    }
}
