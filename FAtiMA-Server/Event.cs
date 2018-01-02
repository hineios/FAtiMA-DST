using Newtonsoft.Json;
using RolePlayCharacter;
using System;
using System.Diagnostics;
using WellFormedNames;

namespace FAtiMA_Server
{
    public class Event
    {
        private string Type { get; set; }
        // What was it?/Belief
        private string Name { get; set; }
        // Who was the target/value
        private string Value { get; set; }
        // Who did it?/For who did it change
        private string Subject { get; set; }

        [JsonConstructor]
        public Event(string type, string name, string value, string subject)
        {
            Subject = subject;
            Name = name;
            Value = value;
            Type = type;
        }

        public void Perceive(RolePlayCharacterAsset rpc)
        {
            switch (Type)
            {
                case "Action-End":
                    PerceiveActionEnd(rpc);
                    return;
                case "Action-Start":
                    PerceiveActionStart(rpc);
                    return;
                case "Property-Change":
                    PerceivePropertyChanged(rpc);
                    return;

                default:
                    throw new Exception("Event of unknown type. Events must be 'Action-Start', 'Action-End', or 'Property-Change'.");
            }
        }

        private void PerceiveActionStart(RolePlayCharacterAsset rpc)
        {
            var e = EventHelper.ActionStart(Subject, Name, Value);
            Debug.WriteLine(e.ToString());
            rpc.Perceive(e);
        }

        private void PerceiveActionEnd(RolePlayCharacterAsset rpc)
        {
            var e = EventHelper.ActionEnd(Subject, Name, Value);
            Debug.WriteLine(e.ToString());
            rpc.Perceive(e);
        }

        private void PerceivePropertyChanged(RolePlayCharacterAsset rpc)
        {
            /*
             * Update the KB with the new belief if it is different from the current belief
             * */
            string bv = rpc.GetBeliefValue(Name);
            if (bv == null || !bv.Equals(Value.ToString()))
            {
                Debug.WriteLine(Name + ": " + bv + " -> " + Value.ToString());
                rpc.Perceive(EventHelper.PropertyChange(Name, Value, Subject));
            }
        }

        public override string ToString()
        {
            return Type + "(" + Name + ", " + Value + ", " + Subject + ")";
        }
    }
}
