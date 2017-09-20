using Newtonsoft.Json;
using RolePlayCharacter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WellFormedNames;

namespace FAtiMA_HTTPServer
{
    public class Item
    {
        int GUID { get; set; }
        string Prefab { get; set; }
        string Name { get; set; }
        int Count { get; set; }

        public Item(int GUID, string prefab, string name, int count)
        {
            this.GUID = GUID;
            this.Prefab = prefab;
            this.Name = name;
            this.Count = count;
        }

        public static Item FromJSON(string s)
        {
            return JsonConvert.DeserializeObject<Item>(s);
        }

        public override string ToString()
        {
            return "ITEM: GUID: " + GUID.ToString() + ", Prefab: " + Prefab + ", Name: " + Name + ", Count: " + Count;
        }
    }
    public class EquippedItems
    {
        Item Hands { get; set; }
        Item Head { get; set; }
        Item Body { get; set; }

        public EquippedItems(Item hands, Item head, Item body)
        {
            Hands = hands;
            Head = head;
            Body = body;
        }
    }

    public class Perceptions
    {
        List<Item> Vision { get; set; }
        List<Item> ItemSlots { get; set; }
        EquippedItems EquipSlots { get; set; }

        [JsonConstructor]
        public Perceptions(EquippedItems EquipSlots, List<Item> Vision, List<Item> ItemSlots)
        {
            this.Vision = Vision;
            this.ItemSlots = ItemSlots;
            this.EquipSlots = EquipSlots;
        }
        //Perceptions(List<Item> Vision, List<Item> EquipSlots, List<Item> ItemSlots)
        //{

        //}
        //Perceptions(List<Item> ItemSlots, List<Item> EquipSlots, List<Item> Vision)
        //Perceptions(List<Item> ItemSlots, List<Item> Vision, List<Item> EquipSlots)
        //Perceptions(List<Item> EquipSlots, List<Item> ItemSlots, List<Item> Vision)
        //Perceptions(List<Item> EquipSlots, List<Item> Vision, List<Item> ItemSlots)
        public static Perceptions FromJSON(string s)
        {
            return JsonConvert.DeserializeObject<Perceptions>(s);
        }

        public override string ToString()
        {
            string s = "Perceptions:\n\tVision:\n";
            foreach (Item v in Vision)
            {
                s += "\t\t" + v.ToString();
            }
            s += "\n\tItemSlots:\n";
            foreach (Item i in ItemSlots)
            {
                s += "\t\t" + i.ToString();
            }
            s += "\n\tEquipSlots:\n";
            s += "\t\t" + EquipSlots.ToString();
            return s;
        }
    }
}
//class Perception
//{
//    private List<> subject { get; set; }
//    private string actionName { get; set; }
//    private string target { get; set; }
//    private string type { get; set; }

//    public Perception(string s, string a, string t, string type)
//    {
//        this.subject = s;
//        this.actionName = a;
//        this.target = t;
//        this.type = type;
//    }

//    private Name ToName()
//    {
//        switch (type)
//        {
//            case "actionend":
//                return ToActionEnd();
//            case "actionstart":
//                return ToActionStart();
//            case "propertychange":
//                return ToPropertyChange();
//            default:
//                throw new Exception("Type of action not recognised");
//        }
//    }

//    private Name ToActionEnd()
//    {
//        return EventHelper.ActionEnd(subject, actionName, target);
//    }

//    private Name ToActionStart()
//    {
//        return EventHelper.ActionStart(subject, actionName, target);
//    }

//    private Name ToPropertyChange()
//    {
//        return EventHelper.PropertyChange(subject, actionName, target);
//    }

//    public static Name FromJSON(string s)
//    {
//        return JsonConvert.DeserializeObject<Perception>(s).ToName();
//    }
//}

