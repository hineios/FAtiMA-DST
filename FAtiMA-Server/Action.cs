using System;
using System.Globalization;

namespace FAtiMA_Server
{
    public class Action
    {
        // This represents the Target of the given action
        public string Target { get; set; }

        // The action itself. It MUST match the table present in the README.md
        public string Name { get; set; }

        // An inventory object. Can be null
        public string InvObject { get; set; }

        // Used only when the Action needs a world position
        public string PosX { get; set; }
        //public string PosY { get; set; } The Y is always 0
        public string PosZ { get; set; }

        // The name of the recipe to be built
        public string Recipe { get; set; }

        public Action(string target, string name, string invobject, string posx, string posz, string recipe)
        {
            Target = target;
            Name = name;
            InvObject = invobject;
            PosX = posx;
            PosZ = posz;
            Recipe = recipe;
        }

        public static Action ToAction(ActionLibrary.IAction a)
        {
            Char[] delimiters = { '(', ',', ' ', ')' };
            String[] splitted = a.Name.ToString().Split(delimiters);

            return new Action(a.Target.ToString(), splitted[1], splitted[3], splitted[5], splitted[7], splitted[9]);
        }
        public override string ToString()
        {
            return "Action(" + Name + ", " + InvObject + ", " + PosX + ", " + PosZ + ", " + Recipe +  ") = " + Target;
        }
    }
}
