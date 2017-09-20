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
        }

        public static string SendResponse(HttpListenerRequest request)
        {
            if (request.RawUrl == "/decide")
            {
                Console.Write("Deciding... ");
                var a = Walter.Decide().FirstOrDefault().Name.ToString();
                Console.WriteLine(a);
                return a;
            }
            else if (request.RawUrl == "/perceptions")
            {
                if (request.HasEntityBody)
                {
                    using (System.IO.Stream body = request.InputStream) // here we have data
                    {
                        using (System.IO.StreamReader reader = new System.IO.StreamReader(body, request.ContentEncoding))
                        {
                            string e = reader.ReadToEnd();
                            
                            var p = JsonConvert.DeserializeObject<Perceptions>(e);
                            Console.WriteLine(p.ToString());

                            
                            //Console.Write("Updating Perceptions...");
                            //Console.WriteLine("Percept " + e);
                            //events.Add(Perception.FromJSON(e));
                            //Walter.Perceive(events);
                            return "perceptions updated";

                        
                        }
                    }
                }
            }
            return null;
        }
    }
}
