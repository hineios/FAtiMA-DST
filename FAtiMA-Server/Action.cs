using System;

namespace FAtiMA_Server
{
    public class Action
    {
        public string Target { get; set; }
        public string Name { get; set; }
        public string InvObject { get; set; }
        public string PosX { get; set; }
        //public int PosY { get; set; } The Y is always 0
        public string PosZ { get; set; }
        public string Recipe { get; set; }
        public string Distance { get; set; }

        public Action(string target, string name, string invobject, string posx, string posz, string recipe, string distance)
        {
            Target = target;
            Name = name;
            InvObject = invobject;
            PosX = posx;
            PosZ = posz;
            Recipe = recipe;
            Distance = distance;
        }

        public static Action ToAction(ActionLibrary.IAction a)
        {
            Char[] delimiters = { '(', ',', ' ', ')' };
            String[] splitted = a.Name.ToString().Split(delimiters);
            
            return new Action(splitted[1], splitted[3], splitted[5], splitted[7], splitted[9], splitted[11], splitted[13]);
        }
        public override string ToString()
        {
            return "Action(" + Target + ", " + Name + ", " + InvObject + ", " + PosX + ", " + PosZ + ", " + Recipe + ", " + Distance + ")";
        }
    }
}
