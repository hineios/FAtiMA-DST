using System;

namespace FAtiMA_Server
{
    public class Action
    {
        public string Name { get; set; }
        public string Target { get; set; }
        public Action(string name, string target)
        {
            Name = name;
            Target = target;
        }

        public static Action ToAction(ActionLibrary.IAction a)
        {
            Char[] delimiters = { '(', ')' };
            String[] splitted = a.Name.ToString().Split(delimiters);
            return new Action(splitted[0], splitted[1]);
        }
        public override string ToString()
        {
            return Name + "(" + Target + ")";
        }
    }
}
