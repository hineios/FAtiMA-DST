using AssetManagerPackage;
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
        //A lock to proccess requests non concurrently
        private static Object l = new Object();

        //TODO Support multiple RPCs
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

            Walter.SaveToFile("./walter-final.rpc");
        }

        public static string SendResponse(HttpListenerRequest request)
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
                                        Debug.WriteLine(p.ToString());
                                        throw excpt;
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
                        var action = Action.ToAction(decision.First());
                        string t = decision.Count().ToString() + ": ";
                        foreach (var a in decision)
                        {
                            t += a.Name + " " + a.Target + "; ";
                        }
                        Debug.WriteLine(t);
                        return JsonConvert.SerializeObject(action);
                    case "/events":
                        Console.Write("An event occured... ");
                        if (request.HasEntityBody)
                        {
                            using (System.IO.Stream body = request.InputStream) // here we have data
                            {
                                using (System.IO.StreamReader reader = new System.IO.StreamReader(body, request.ContentEncoding))
                                {
                                    string s = reader.ReadToEnd();
                                    var e = JsonConvert.DeserializeObject<Event>(s);
                                    Console.WriteLine(e.ToString());
                                    try
                                    {
                                        e.Perceive(Walter);
                                    }
                                    catch (Exception excpt)
                                    {
                                        Debug.WriteLine(e.ToString());
                                        throw excpt;
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
    }
}
