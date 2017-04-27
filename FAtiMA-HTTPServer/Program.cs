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
        private class Perception
        {
            private string subject { get; set; }
            private string actionName { get; set; }
            private string target { get; set; }
            private string type { get; set; }

            public Perception(string s, string a, string t, string type)
            {
                this.subject = s;
                this.actionName = a;
                this.target = t;
                this.type = type;
            }

            private Name ToName()
            {
                switch (type)
                {
                    case "actionend":
                        return ToActionEnd();
                    case "actionstart":
                        return ToActionStart();
                    case "propertychange":
                        return ToPropertyChange();
                    default:
                        throw new Exception("Type of action not recognised");
                }
            }

            private Name ToActionEnd()
            {
                return EventHelper.ActionEnd(subject, actionName, target);
            }

            private Name ToActionStart()
            {
                return EventHelper.ActionStart(subject, actionName, target);
            }

            private Name ToPropertyChange()
            {
                return EventHelper.PropertyChange(subject, actionName, target);
            }

            public static Name FromJSON(string s)
            {
                return JsonConvert.DeserializeObject<Perception>(s).ToName();
            }
        }

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
            else if (request.RawUrl == "/percept")
            {
                if (request.HasEntityBody)
                {
                    using (System.IO.Stream body = request.InputStream) // here we have data
                    {
                        using (System.IO.StreamReader reader = new System.IO.StreamReader(body, request.ContentEncoding))
                        {
                            Console.Write("Updating Perceptions...");
                            string e = reader.ReadToEnd();
                            Console.WriteLine("Percept " + e);

                            List<Name> events = new List<Name>();
                            events.Add(Perception.FromJSON(e));
                            Walter.Perceive(events);
                            return "perceptions updated";
                        }
                    }
                }
            }
            return null;
        }
    }
}
