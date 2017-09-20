using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using RolePlayCharacter;
using AssetManagerPackage;
using Newtonsoft.Json;

namespace HTTPServerTest
{
    class TestJSON
    {
        public TestJSON(string name, string id, int time)
        {
            Name = name;
            this.ID = id;
            this.Time = time;
        }

        public string Name { get; set; }
        public string ID { get; set; }
        public int Time { get; set; }

        public override string ToString()
        {
            return "Name: " + Name + ", ID: " + ID + ", Time: " + Time;
        }
    }
    class Program
    {
        private static RolePlayCharacterAsset Walter;

        static void Main(string[] args)
        {
            AssetManager.Instance.Bridge = new BasicIOBridge();
            Console.Write("Loading Character from file... ");
            Walter = RolePlayCharacterAsset.LoadFromFile("../../walter.rpc");
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
            Console.Write("Deliberating... ");
            
            if (!request.HasEntityBody)
            {
                Console.Write(" No new perceptions... ");
                return null;
            }
            using (System.IO.Stream body = request.InputStream) // here we have data
            {
                using (System.IO.StreamReader reader = new System.IO.StreamReader(body, request.ContentEncoding))
                {
                    Console.Write(" Updating perceptions... ");
                    TestJSON j = JsonConvert.DeserializeObject<TestJSON>(reader.ReadToEnd());
                    Console.WriteLine(j.ToString());
                    j.Time++;
                    return JsonConvert.SerializeObject(j);
                }
            }
        }
    }
}
