using RolePlayCharacter;

namespace FAtiMA_Server
{
    public class Entity
    {
        public int GUID { get; set; }
        public string Prefab { get; set; }
        public int Quantity { get; set; }
        //=====================================
        public bool IsCollectable { get; set; }
        public bool IsCooker { get; set; }
        public bool IsCookable { get; set; }
        public bool IsEdible { get; set; }
        public bool IsEquippable { get; set; }
        public bool IsFuel { get; set; }
        public bool IsFueled { get; set; }
        public bool IsGrower { get; set; }
        public bool IsHarvestable { get; set; }
        public bool IsPickable { get; set; }
        public bool IsStewer { get; set; }
        //===================================
        public bool IsChoppable { get; set; }
        public bool IsDiggable { get; set; }
        public bool IsHammerable { get; set; }
        public bool IsMineable { get; set; }
        //========================
        public int X { get; set; }
        public int Y { get; set; }
        public int Z { get; set; }

        public Entity(int GUID, string prefab, int quantity, bool collectable, bool cooker, bool cookable, bool edible, bool equippable, bool fuel, bool fueled, bool grower, bool harvestable, bool pickable, bool stewer, bool choppable, bool diggable, bool hammerable, bool mineable, float x, float y, float z)
        {
            this.GUID = GUID;
            Prefab = prefab;
            Quantity = quantity;
            //==========================
            IsCollectable = collectable;
            IsCooker = cooker;
            IsCookable = cookable;
            IsEdible = edible;
            IsEquippable = equippable;
            IsFuel = fuel;
            IsFueled = fueled;
            IsGrower = grower;
            IsHarvestable = harvestable;
            IsPickable = pickable;
            IsStewer = stewer;
            //======================
            IsChoppable = choppable;
            IsDiggable = diggable;
            IsHammerable = hammerable;
            IsMineable = mineable;
            
            X = (int)x;
            Y = (int)y;
            Z = (int)z;
        }

        public void UpdatePerception(RolePlayCharacterAsset rpc)
        {
            string b = rpc.GetBeliefValue("Entity(" + GUID + ")");
            if (b == null || !(b.Equals(Prefab.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("Entity(" + GUID + ")", Prefab.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("Quantity(" + GUID + ")");
            if (b == null || !(b.Equals(Quantity.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("Quantity(" + GUID + ")", Quantity.ToString(), rpc.CharacterName.ToString()));

            //====================================================
            b = rpc.GetBeliefValue("IsCollectable(" + GUID + ")");
            if (b == null || !(b.Equals(IsCollectable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsCollectable(" + GUID + ")", IsCollectable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsCooker(" + GUID + ")");
            if (b == null || !(b.Equals(IsCooker.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsCooker(" + GUID + ")", IsCooker.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsCookable(" + GUID + ")");
            if (b == null || !(b.Equals(IsCookable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsCookable(" + GUID + ")", IsCookable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsEdible(" + GUID + ")");
            if (b == null || !(b.Equals(IsEdible.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsEdible(" + GUID + ")", IsEdible.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsEquippable(" + GUID + ")");
            if (b == null || !(b.Equals(IsEquippable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsEquippable(" + GUID + ")", IsEquippable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsFuel(" + GUID + ")");
            if (b == null || !(b.Equals(IsFuel.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsFuel(" + GUID + ")", IsFuel.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsFueled(" + GUID + ")");
            if (b == null || !(b.Equals(IsFueled.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsFueled(" + GUID + ")", IsFueled.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsGrower(" + GUID + ")");
            if (b == null || !(b.Equals(IsGrower.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsGrower(" + GUID + ")", IsGrower.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsHarvestable(" + GUID + ")");
            if (b == null || !(b.Equals(IsHarvestable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsHarvestable(" + GUID + ")", IsHarvestable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsPickable(" + GUID + ")");
            if (b == null || !(b.Equals(IsPickable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsPickable(" + GUID + ")", IsPickable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsStewer(" + GUID + ")");
            if (b == null || !(b.Equals(IsStewer.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsStewer(" + GUID + ")", IsStewer.ToString(), rpc.CharacterName.ToString()));

            //==================================================
            b = rpc.GetBeliefValue("IsChoppable(" + GUID + ")");
            if (b == null || !(b.Equals(IsChoppable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsChoppable(" + GUID + ")", IsChoppable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsHammerable(" + GUID + ")");
            if (b == null || !(b.Equals(IsHammerable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsHammerable(" + GUID + ")", IsHammerable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsDiggable(" + GUID + ")");
            if (b == null || !(b.Equals(IsDiggable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsDiggable(" + GUID + ")", IsDiggable.ToString(), rpc.CharacterName.ToString()));

            b = rpc.GetBeliefValue("IsMineable(" + GUID + ")");
            if (b == null || !(b.Equals(IsMineable.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("IsMineable(" + GUID + ")", IsMineable.ToString(), rpc.CharacterName.ToString()));

            //===========================================
            b = rpc.GetBeliefValue("PosX(" + GUID + ")");
            if (b == null || !(b.Equals(X.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("PosX(" + GUID + ")", X.ToString(), rpc.CharacterName.ToString()));

            /*
             * The Y-axis is always equal to zero, no need to save it in the knowledge base
             * */

            b = rpc.GetBeliefValue("PosZ(" + GUID + ")");
            if (b == null || !(b.Equals(Z.ToString())))
                rpc.Perceive(EventHelper.PropertyChange("PosZ(" + GUID + ")", Z.ToString(), rpc.CharacterName.ToString()));
        }

        public override string ToString()
        {
            return Quantity + " x " + Prefab + "(" + X.ToString() + "," + Y.ToString() + "," + Z.ToString() + ")";
        }
    }
}
