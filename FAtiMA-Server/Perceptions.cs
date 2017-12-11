using Newtonsoft.Json;
using RolePlayCharacter;
using System.Collections.Generic;
using WellFormedNames;

namespace FAtiMA_Server
{
    public class Perceptions
    {
        List<Item> Vision { get; set; }
        List<Item> ItemSlots { get; set; }
        List<EquippedItems> EquipSlots { get; set; }
        public int Hunger { get; set; }
        public int Sanity { get; set; }
        public int Health { get; set; }
        public int Moisture { get; set; }
        public int Temperature { get; set; }
        public bool IsFreezing { get; set; }
        public bool IsOverheating { get; set; }
        public bool IsBusy { get; set; }

        //TODO: Add something to track which part of the day the agent is in.

        [JsonConstructor]
        public Perceptions(List<EquippedItems> EquipSlots, List<Item> Vision, List<Item> ItemSlots,
            float Hunger, float Sanity, float Health, float Moisture, float Temperature, bool IsFreezing, bool IsOverheating, bool IsBusy)
        {
            this.Vision = Vision;
            this.ItemSlots = ItemSlots;
            this.EquipSlots = EquipSlots;
            this.Hunger = (int) Hunger;
            this.Health = (int) Health;
            this.Sanity = (int) Sanity;
            this.Moisture = (int) Moisture;
            this.Temperature = (int) Temperature;
            this.IsFreezing = IsFreezing;
            this.IsOverheating = IsOverheating;
            this.IsBusy = IsBusy;
        }
        
        public void UpdatePerceptions(RolePlayCharacterAsset rpc)
        {
            /*
             * Find every InSight, Inventory, and IsEquipped belief and set them to false
             * Eventually try and delete the beliefs (depending on performance).
             * */

            var subset = new List<SubstitutionSet>();
            subset.Add(new SubstitutionSet());

            var beliefs = rpc.m_kb.AskPossibleProperties((Name)"InSight([x])", (Name)"SELF", subset);
            //Console.WriteLine("Query returned " + beliefs.Count() + " InSight beliefs.");
            foreach (var b in beliefs)
            {
                foreach (var s in b.Item2)
                {
                    rpc.UpdateBelief("InSight(" + s[(Name)"[x]"] + ")", "FALSE");
                    //rpc.RemoveBelief("InSight(" + s[(Name)"[x]"] + ")", "SELF");
                }
            }

            beliefs = rpc.m_kb.AskPossibleProperties((Name)"InInventory([x])", (Name)"SELF", subset);
            //Console.WriteLine("Query returned " + beliefs.Count() + " InInventory beliefs.");
            foreach (var b in beliefs)
            {
                foreach (var s in b.Item2)
                {
                    rpc.UpdateBelief("InInventory(" + s[(Name)"[x]"] + ")", "FALSE");
                    //rpc.RemoveBelief("InInventory(" + s[(Name)"[x]"] + ")", "SELF");
                }
            }

            beliefs = rpc.m_kb.AskPossibleProperties((Name)"IsEquipped([x], [y])", (Name)"SELF", subset);
            //Console.WriteLine("Query returned " + beliefs.Count() + " IsEquipped beliefs.");
            foreach (var b in beliefs)
            {
                foreach (var s in b.Item2)
                {
                    rpc.UpdateBelief("IsEquipped(" + s[(Name)"[x]"] + ")", "FALSE");
                }
            }

            /*
             * Update the KB with the new beliefs
             * */
            

            rpc.Perceive(EventHelper.PropertyChange("Hunger(" + rpc.CharacterName.ToString() + ")", this.Hunger.ToString(), rpc.CharacterName.ToString()));
            rpc.Perceive(EventHelper.PropertyChange("Health(" + rpc.CharacterName.ToString() + ")", this.Health.ToString(), rpc.CharacterName.ToString()));
            rpc.Perceive(EventHelper.PropertyChange("Sanity(" + rpc.CharacterName.ToString() + ")", this.Sanity.ToString(), rpc.CharacterName.ToString()));
            rpc.Perceive(EventHelper.PropertyChange("IsFreezing(" + rpc.CharacterName.ToString() + ")", this.IsFreezing.ToString(), rpc.CharacterName.ToString()));
            rpc.Perceive(EventHelper.PropertyChange("IsOverheating(" + rpc.CharacterName.ToString() + ")", this.IsOverheating.ToString(), rpc.CharacterName.ToString()));
            rpc.Perceive(EventHelper.PropertyChange("Moisture(" + rpc.CharacterName.ToString() + ")", this.Moisture.ToString(), rpc.CharacterName.ToString()));
            rpc.Perceive(EventHelper.PropertyChange("Temperature(" + rpc.CharacterName.ToString() + ")", this.Temperature.ToString(), rpc.CharacterName.ToString()));
            rpc.Perceive(EventHelper.PropertyChange("IsBusy(" + rpc.CharacterName.ToString() + ")", this.IsBusy.ToString(), rpc.CharacterName.ToString()));

            foreach (Item i in Vision)
            {
                rpc.Perceive(EventHelper.PropertyChange("InSight(" + i.GUID + ")", "TRUE", rpc.CharacterName.ToString()));
                i.UpdatePerception(rpc);
            }

            foreach(Item i in ItemSlots)
            {
                rpc.Perceive(EventHelper.PropertyChange("InInventory(" + i.GUID + ")", "TRUE", rpc.CharacterName.ToString()));
                i.UpdatePerception(rpc);
            }

            foreach(EquippedItems i in EquipSlots)
            {
                rpc.Perceive(EventHelper.PropertyChange("IsEquipped(" + i.GUID + "," + i.Slot + ")", "TRUE", rpc.CharacterName.ToString()));
                i.UpdatePerception(rpc);
            }

            rpc.Update();
        }
        
        /**
         * Just a quick way to show the Perceptions that we just got from the 'body'
         **/
        public override string ToString()
        {
            string s = "Perceptions:\n";
            s += "\tHunger: " + this.Hunger;
            s += "\tSanity: " + this.Sanity;
            s += "\tHealth: " + this.Health;
            s += "\n\tMoisture: " + this.Moisture;
            s += "\tTemperature: " + this.Temperature;
            s += "\tIsFreezing: " + this.IsFreezing;
            s += "\tIsOverheating: " + this.IsOverheating;
            s += "\tIsBusy: " + this.IsBusy;
            s += "\n\tVision:\n";
            foreach (Item v in Vision)
            {
                s += "\t\t" + v.ToString() + "\n";
            }
            s += "\tItemSlots:\n";
            foreach (Item i in ItemSlots)
            {
                s += "\t\t" + i.ToString() + "\n";
            }
            s += "\tEquipSlots:\n";
            foreach (Item e in EquipSlots)
            {
                s += "\t\t" + e.ToString() + "\n";
            }
            return s;
        }
    }
}

