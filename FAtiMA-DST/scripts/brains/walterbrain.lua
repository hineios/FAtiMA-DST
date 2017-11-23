local SEE_DIST = 20
local SEE_RANGE_HELPER = false
local PERCEPTION_UPDATE_INTERVAL = 1
local DECIDE_INTERVAL = 1

local assets =
{
    Asset("ANIM", "anim/firefighter_placement.zip"),
}

local function AddSeeRangeHelper(inst)
    if SEE_RANGE_HELPER and inst.seerangehelper == nil then
        inst.seerangehelper = CreateEntity()

        --[[Non-networked entity]]
        inst.seerangehelper.entity:SetCanSleep(false)
        inst.seerangehelper.persists = false

        inst.seerangehelper.entity:AddTransform()
        inst.seerangehelper.entity:AddAnimState()

        inst.seerangehelper:AddTag("CLASSIFIED")
        inst.seerangehelper:AddTag("NOCLICK")
        inst.seerangehelper:AddTag("placer")

        inst.seerangehelper.Transform:SetScale(SEE_DIST/10, SEE_DIST/10, SEE_DIST/10)

        inst.seerangehelper.AnimState:SetBank("firefighter_placement")
        inst.seerangehelper.AnimState:SetBuild("firefighter_placement")
        inst.seerangehelper.AnimState:PlayAnimation("idle")
        inst.seerangehelper.AnimState:SetLightOverride(1)
        inst.seerangehelper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.seerangehelper.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.seerangehelper.AnimState:SetSortOrder(1)
        inst.seerangehelper.AnimState:SetAddColour(0, .2, .5, 0)

        inst.seerangehelper.entity:SetParent(inst.entity)
    end
end

local function Vision(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local TAGS = nil
    local EXCLUDE_TAGS = {"INLIMBO", "NOCLICK"}
    local ONE_OF_TAGS = nil
    local ents = TheSim:FindEntities(x, y, z, SEE_DIST, TAGS, EXCLUDE_TAGS, ONE_OF_TAGS)
    
    --Go over all the objects that the agent can see and take what information we need
    local data = {}
    for i, v in pairs(ents) do
        local d = {}
        d.GUID = v.GUID
        d.Prefab = v.prefab
        d.Count = v.components.stackable ~= nil and v.components.stackable:StackSize() or 1
		-- Add information about the state of the entity (is it workable?)
        --d.X, d.Y, d.Z = v.Transform:GetWorldPosition()
        data[i] = d
    end
    return data
end

local function Inventory(inst)
    local EquipSlots = {}
    local ItemSlots = {}
 
    -- Go over all items in the inventory and take what information we need
    for k, v in pairs(inst.components.inventory.itemslots) do
        local d = {}
        d.GUID = v.GUID
        d.Prefab = v.prefab
        d.Count = v.components.stackable ~= nil and v.components.stackable:StackSize() or 1
		--d.X, d.Y, d.Z = v.Transform:GetWorldPosition()
        ItemSlots[k] = d
    end

    -- Go over equipped items and put them in an array
    -- I chose to use an array not to limit which equip slots the agent has.
    -- This way I do not need to change any code, should any new slot appear.
    local i = 1
    for k, v in pairs(inst.components.inventory.equipslots) do
        local d = {}
        d.GUID = v.GUID
        d.Prefab = v.prefab
        d.Count = v.components.stackable ~= nil and v.components.stackable:StackSize() or 1
        d.Slot = k
		--d.X, d.Y, d.Z = v.Transform:GetWorldPosition()
        EquipSlots[i] = d
        i = i + 1
    end

    return EquipSlots, ItemSlots
end

local function Perceptions(inst, FAtiMAServer, perceptionscallbackfn)
    local data = {}
    data.Vision = Vision(inst)
    data.EquipSlots, data.ItemSlots = Inventory(inst) 

    data.Health = inst.components.health.currenthealth
    data.Hunger = inst.components.hunger.current
    data.Sanity = inst.components.sanity.current
    data.Temperature = inst:GetTemperature()
    data.IsFreezing = inst:IsFreezing()
    data.IsOverHeating = inst:IsOverheating()
    data.Moisture = inst:GetMoisture()

    -- Add a perception that says which time of the day it is (day, dusk, night)

    TheSim:QueryServer(
        FAtiMAServer .. "/perceptions",
        perceptionscallbackfn,
        "POST",
        json.encode(data))
end

local function Decide(inst, FAtiMAServer, decidecallbackfn)
    TheSim:QueryServer(
        FAtiMAServer .. "/decide",
        decidecallbackfn,
        "GET")
end

local function OnEvent(inst, FAtiMAServer, decidecallbackfn)
	
end
local WalterBrain = Class(Brain, function(self, inst, server)
    Brain._ctor(self, inst)
    self.inst = inst

    ------------------------------
    ---- FAtiMA Communication ----
    ------------------------------
    self.FAtiMAServer = server or "http://localhost:8080"

    ------------------------------
    -- HTTP Callbacks Functions --
    ------------------------------
    self.perceptionscallbackfn = function(result, isSuccessful , http_code)
        -- Intentionally left blank
    end

    self.decidecallbackfn = function(result, isSuccessful , http_code)
        if isSuccessful then
			local action = result and (result ~= "") and json.decode(result)
			if action and action.Name then
				self.currentaction = action
			end
		end
    end
end)

function WalterBrain:OnStart()
    -----------------------
    ----- Deliberator -----
    -----------------------
    self.currentaction = nil

    -----------------------
    ----- Range Helper ----
    -----------------------
    AddSeeRangeHelper(self.inst)

    -----------------------
    ----- Perceptions -----
    -----------------------
    if self.perceptions ~= nil then
        self.perceptions:Cancel()
    end
    -- DoPeriodicTask(interval, fn, initialdelay, ...) the extra parameters are passed to fn
    self.perceptions = self.inst:DoPeriodicTask(PERCEPTION_UPDATE_INTERVAL, Perceptions, 0, self.FAtiMAServer, self.perceptionscallbackfn)

    -----------------------
    -- ReconsiderActions --
    -----------------------
	if self.decide ~= nil then
        self.decide:Cancel()
    end
    self.decide = self.inst:DoPeriodicTask(DECIDE_INTERVAL, Decide, 0, self.FAtiMAServer, self.decidecallbackfn)

    -----------------------
    --- Event Listeners ---
    -----------------------
    -- EntityScript:ListenForEvent(event, fn, source)
    -- self.inst:ListenForEvent("killed", self.onkilledfn)

    -----------------------
    -------- Brain --------
    -----------------------
    local root = 
        PriorityNode(
        {
            IfNode(function() return (self.currentaction ~= nil) end, "IfDoAction",
                DoAction(self.inst, 
                    function() return BufferedAction(self.inst, 
						Ents[tonumber(self.currentaction.Target)], 
						ACTIONS[self.currentaction.Name]) end, 
                    "doaction", 
                    true))
        }, 1)
    self.bt = BT(self.inst, root)
end

function WalterBrain:OnStop()
    -----------------------
    ----- Range Helper ----
    -----------------------
    if SEE_RANGE_HELPER then
        self.inst.seerangehelper:Remove()
        self.inst.seerangehelper = nil
    end
    -----------------------
    ----- Perceptions -----
    -----------------------
    if self.perceptions ~= nil then
        self.perceptions:Cancel()
        self.perceptions = nil
    end
    -----------------------
    -- ReconsiderActions --
    -----------------------
    if self.decide ~= nil then
        self.decide:Cancel()
        self.decide = nil
    end
    -----------------------
    --- Event Listeners ---
    -----------------------
--    self.inst:RemoveEventCallback("killed", self.onkilledfn)

end

return WalterBrain