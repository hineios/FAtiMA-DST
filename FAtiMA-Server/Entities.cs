using RolePlayCharacter;

namespace FAtiMA_Server
{
    public class Entity
    {
        public int GUID { get; set; }
        public int X { get; set; }
        public int Y { get; set; }
        public int Z { get; set; }

        public Entity(int GUID, float x, float y, float z)
        {
            this.GUID = GUID;
            X = (int) x;
            Y = (int) y;
            Z = (int) z;
        }

        public override string ToString()
        {
            return "Entity: " + this.GUID + "(" + X + "," + Y + "," + Z + ")";
        }
    }

    public class Item : Entity
    {
        public string Prefab { get; set; }
        public int Quantity { get; set; }
        public bool ChopWorkable { get; set; }
        public bool HammerWorkable { get; set; }
        public bool DigWorkable { get; set; }
        public bool MineWorkable { get; set; }
        public bool Pickable { get; set; }
        public bool Collectable { get; set; }
        public bool Equippable { get; set; }

        public Item(int GUID, float x, float y, float z, string prefab, int quantity, bool chopworkable, bool hammerworkable, bool digworkable, bool mineworkable, bool pickable, bool collectable, bool equippable) : base(GUID, x, y, z)
        {
            Prefab = prefab;
            Quantity = quantity;
            ChopWorkable = chopworkable;
            HammerWorkable = hammerworkable;
            DigWorkable = digworkable;
            MineWorkable = mineworkable;
            Pickable = pickable;
            Collectable = collectable;
            Equippable = equippable;
        }

        public void UpdatePerception(RolePlayCharacterAsset rpc)
        {
            string b = rpc.GetBeliefValue("Entity(" + GUID + "," + Prefab + ")");
            if ( b == null || !(b.Equals(Quantity.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("Entity(" + GUID + "," + Prefab + ")", Quantity.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("ChopWorkable(" + GUID + ")");
            if ( b == null || !(b.Equals(ChopWorkable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("ChopWorkable(" + GUID + ")", ChopWorkable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("HammerWorkable(" + GUID + ")");
            if (b == null || !(b.Equals(HammerWorkable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("HammerWorkable(" + GUID + ")", HammerWorkable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("DigWorkable(" + GUID + ")");
            if (b == null || !(b.Equals(DigWorkable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("DigWorkable(" + GUID + ")", DigWorkable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("MineWorkable(" + GUID + ")");
            if (b == null || !(b.Equals(MineWorkable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("MineWorkable(" + GUID + ")", MineWorkable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("Pickable(" + GUID + ")");
            if ( b == null || !(b.Equals(Pickable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("Pickable(" + GUID + ")", Pickable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("Collectable(" + GUID + ")");
            if (b == null || !(b.Equals(Collectable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("Collectable(" + GUID + ")", Collectable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("Equippable(" + GUID + ")");
            if (b == null || !(b.Equals(Equippable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("Equippable(" + GUID + ")", Equippable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("PosX(" + GUID + ")");
            if ( b == null || !(b.Equals(X.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("PosX(" + GUID + ")", X.ToString(), rpc.CharacterName.ToString()));

            /*
             * The Y-axis is always equal to zero, no need to save it in the knowledge base
             * */
            //b = rpc.GetBeliefValue("PosY(" + GUID + ")");
            //if ( b == null || !(b.Equals(Y.ToString())))
            //    rpc.Perceive(EventHelper.PropertyChange("PosY(" + GUID + ")", Y.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("PosZ(" + GUID + ")");
            if ( b == null || !(b.Equals(Z.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("PosZ(" + GUID + ")", Z.ToString(), rpc.CharacterName.ToString()));
        }

        public override string ToString()
        {
            return Quantity + " x " + Prefab + "(" + X.ToString() + "," + Y.ToString() + "," + Z.ToString() + ")";
        }
    }

    public class EquippedItems : Item
    {
        public string Slot { get; set; }

        public EquippedItems(int GUID, float x, float y, float z, string prefab, int count, bool chopworkable, bool hammerworkable, bool digworkable, bool mineworkable, bool pickable, bool collectable, bool equippable, string slot) : base(GUID, x, y, z, prefab, count, chopworkable, hammerworkable, digworkable, mineworkable, pickable, collectable, equippable)
        {
            Slot = slot;
        }

        public override string ToString()
        {
            return Slot + ": " + Prefab;
        }
    }
}
