using Newtonsoft.Json;
using RolePlayCharacter;
using System;
using WellFormedNames;

namespace FAtiMA_Server
{
    public class Event
    {
        private string Subject { get; set; }
        private string ActionName { get; set; }
        private string Target { get; set; }
        private string Type { get; set; }

        public Event(string subject, string action, string target, string type)
        {
            Subject = subject;
            ActionName = action;
            Target = target;
            Type = type;
        }

        public Name ToName()
        {
            switch (Type)
            {
                case "actionend":
                    return EventHelper.ActionEnd(Subject, ActionName, Target);
                case "actionstart":
                    return EventHelper.ActionStart(Subject, ActionName, Target);
                case "propertychange":
                    return EventHelper.PropertyChange(Subject, ActionName, Target);
                default:
                    throw new Exception("Event of unknown type. Events must be 'actionstart', 'actionend', or 'propertychange'.");
            }
        }

        public static Name FromJSON(string s)
        {
            return JsonConvert.DeserializeObject<Event>(s).ToName();
        }

        public override string ToString()
        {
            return Type + "(" + ActionName + ", " + Subject + ", " + Target + ")";
        }
    }
}
