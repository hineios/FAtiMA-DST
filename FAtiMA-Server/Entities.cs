using RolePlayCharacter;

namespace FAtiMA_Server
{
    public class Entity
    {
        public int GUID { get; set; }
        //public int X { get; set; }
        //public int Y { get; set; }
        //public int Z { get; set; }

        public Entity(int GUID)
        {
            this.GUID = GUID;
        }

        public override string ToString()
        {
            return "Entity: " + this.GUID;
        }
    }

    public class Item : Entity
    {
        public string Prefab { get; set; }
        public int Count { get; set; }

        public Item(int GUID, string prefab, int count) : base(GUID)
        {
            this.Prefab = prefab;
            this.Count = count;
        }

        public void UpdatePerception(RolePlayCharacterAsset rpc)
        {
            rpc.Perceive(EventHelper.PropertyChange("Entity(" + GUID + "," + Prefab + ")", this.Count.ToString(), rpc.CharacterName.ToString()));
        }

        public override string ToString()
        {
            return Count + " x " + Prefab;
        }
    }

    public class EquippedItems : Item
    {
        public string Slot { get; set; }

        public EquippedItems(int GUID, string prefab, int count, string slot) : base(GUID, prefab, count)
        {
            this.Slot = slot;
        }

        public override string ToString()
        {
            return Slot + ": " + Prefab;
        }
    }
}
