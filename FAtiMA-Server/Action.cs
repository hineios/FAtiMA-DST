using IntegratedAuthoringTool;
using System;
using System.Linq;
using System.Globalization;

namespace FAtiMA_Server
{
    public class Action
    {
        public string Type { get; set; }
        public string Target { get; set; }
        public string Name { get; set; }
        public string WFN { get; set; }

        public Action(string type, string target, string name)
        {
            Type = type;
            Target = target;
            Name = name;
            WFN = Type + "(" + Name + ")"; 
        }

        public static Action ToAction(ActionLibrary.IAction a, IntegratedAuthoringToolAsset IAT)
        {
            Char[] delimiters = { '(', ',', ' ', ')' };
            String[] splitted = a.Name.ToString().Split(delimiters);

            switch (splitted[0])
            {
                case "Action":
                    return new DSTAction(splitted[0], a.Target.ToString(), splitted[1], splitted[3], splitted[5], splitted[7], splitted[9], a.Name.ToString());
                case "Speak":
                    var dialog = IAT.GetDialogueActions(
                        a.Parameters[0],
                        a.Parameters[1],
                        a.Parameters[2],
                        a.Parameters[3]).FirstOrDefault();
                    return new SpeakAction(splitted[0], a.Target.ToString(), splitted[1], splitted[3], splitted[5], splitted[7], a.Name.ToString(), dialog.Utterance);
                default:
                    throw new Exception("This type of action (" + splitted[0] + ") is not recognized");
            }

        }

        public override string ToString()
        {
            return Type + " = " + Target;
        }
    }

    public class DSTAction : Action
    {
        // The action itself. It MUST match the table present in the README.md
        public string Action { get; set; }

        // An inventory object. Can be null
        public string InvObject { get; set; }

        // Used only when the Action needs a world position
        public string PosX { get; set; }
        //public string PosY { get; set; } The Y is always 0
        public string PosZ { get; set; }

        // The name of the recipe to be built
        public string Recipe { get; set; }

        public DSTAction(string type, string target, string action, string invobject, string posx, string posz, string recipe, string name) : base(type, target, name)
        {
            Target = target;
            Action = action;
            InvObject = invobject;
            PosX = posx;
            PosZ = posz;
            Recipe = recipe;
            Type = type;
            WFN = Type + "(" + Action + ", " + InvObject + ", " + PosX + ", " + PosZ + ", " + Recipe + ")";
        }
        
        public override string ToString()
        {
            return WFN + " = " + Target;
        }
    }

    public class SpeakAction : Action
    {
        public string CurrentState { get; set; }
        public string NextState { get; set; }
        public string Meaning { get; set; }
        public string Style { get; set; }
        public string Utterance { get; set; }

        public SpeakAction(string type, string target, string currentstate, string nextstate, string meaning, string style, string name, string utterance) : base(type, target, name)
        {
            CurrentState = currentstate;
            NextState = nextstate;
            Meaning = meaning;
            Style = style;
            Utterance = utterance;
            WFN = Type + "(" + CurrentState + ", " + NextState + ", " + Meaning + ", " + Style + ", '" + Utterance + "')";
        }

        public override string ToString()
        {
            return WFN + " = " + Target;
        }
    }
}
