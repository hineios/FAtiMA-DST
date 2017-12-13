using System;

namespace FAtiMA_Server
{
    public class Action
    {
        public string Target { get; set; }
        public string Name { get; set; }
        public string InvObject { get; set; }
        public string Pos { get; set; }
        public string Recipe { get; set; }
        public string Distance { get; set; }

        public Action(string target, string name, string invobject, string pos, string recipe, string distance)
        {
            Target = target;
            Name = name;
            InvObject = invobject;
            Pos = pos;
            Recipe = recipe;
            Distance = distance;
        }

        public static Action ToAction(ActionLibrary.IAction a)
        {
            Char[] delimiters = { '(', ',', ' ', ')' };
            String[] splitted = a.Name.ToString().Split(delimiters);
            
            return new Action(splitted[1], splitted[3], splitted[5], splitted[7], splitted[9], splitted[11]);
        }
        public override string ToString()
        {
            return "Action(" + Target + ", " + Name + ", " + InvObject + ", " + Pos + ", " + Recipe + ", " + Distance + ")";
        }
    }
}
