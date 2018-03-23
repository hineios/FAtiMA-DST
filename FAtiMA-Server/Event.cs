using Newtonsoft.Json;
using RolePlayCharacter;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using WellFormedNames;

namespace FAtiMA_Server
{
    public class Event
    {
        private string Type { get; set; }
        // Who did it?/For who did it change
        private string Subject { get; set; }
        // What was it?/Belief
        private string Name { get; set; }
        // Who was the target/value
        private string Value { get; set; }

        [JsonConstructor]
        public Event(string type, string subject, string name, string value)
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
                case "Delete-Entity":
                    DeleteEntity(rpc);
                    return;
                default:
                    throw new Exception("Event of unknown type. Events must be 'Action-Start', 'Action-End', or 'Property-Change'.");
            }
        }

        private void DeleteEntity(RolePlayCharacterAsset rpc)
        {
            /*
            * This entity has been destroy by the agent, delete it from the KB
            * */
            rpc.RemoveBelief("Entity(" + Value + ")", "SELF");
            rpc.RemoveBelief("Quantity(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsCollectable(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsCooker(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsCookable(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsEdible(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsEquippable(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsFuel(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsFueled(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsGrower(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsHarvestable(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsPickable(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsStewer(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsChoppable(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsHammerable(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsDiggable(" + Value + ")", "SELF");
            rpc.RemoveBelief("IsMineable(" + Value + ")", "SELF");
            rpc.RemoveBelief("PosX(" + Value + ")", "SELF");
            rpc.RemoveBelief("PosZ(" + Value + ")", "SELF");
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
            return "Event(" + Type + ", " + Subject + ", " + Name + ", " + Value + ")";
        }
    }
}
