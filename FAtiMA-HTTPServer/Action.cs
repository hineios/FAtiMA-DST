using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FAtiMA_HTTPServer
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
            String[] splited = a.Name.ToString().Split(delimiters);
            return new Action(splited[0], splited[1]);
        }
        public override string ToString()
        {
            return Name + "(" + Target + ")";
        }
    }
}
