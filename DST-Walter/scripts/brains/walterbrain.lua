require "behaviours/decide"

local SEE_DIST = 20
local SEE_RANGE_HELPER = true
local PERCEPTION_UPDATE_INTERVAL = 1
local RECONSIDER_ACTIONS_INTERVAL = 10

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
        d.x, d.y, d.z = v.Transform:GetWorldPosition()
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
        EquipSlots[i] = d
        i = i + 1
    end

    return EquipSlots, ItemSlots
end

local function Perceptions(inst, FAtiMAServer, beliefscallbackfn)
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
        FAtiMAServer .. "/beliefs",
        beliefscallbackfn,
        "POST",
        json.encode(data))
end

local function ReconsiderActions(inst, FAtiMAServer, reconsidercallbackfn)
    TheSim:QueryServer(
        FAtiMAServer .. "/decide",
        reconsidercallbackfn,
        "GET")
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
    self.beliefscallbackfn = function(result, isSuccessful , http_code)
        -- Intentionally left blank
    end

    self.decidecallbackfn = function(result, isSuccessful , http_code)
        print("Decision:")
        --print("agent is ", self.inst)
        if isSuccessful then
			local actions = json.decode(result)
			if self.inst.components.deliberator and actions then
				self.inst.components.deliberator:SetActions(actions)
			end
			for k, v in pairs(actions) do
				print("    ", v.Name, v.Target)
			end
		else
			print("No response from server!")
		end
    end
end)

-- local x, y, z = ThePlayer().Transform:GetWorldPosition()
-- local ents = TheSim:FindEntities(x, y, z, 20, nil, {"INLIMBO"}, nil)
-- for k, v in pairs(ents) do print(k); for i, g in pairs(v) do print("    ", i, g)
local function Test(inst)
--	print("Action:", ACTIONS[inst.components.deliberator:GetNextAction().Name])
--	for k, v in pairs(ACTIONS[inst.components.deliberator:GetNextAction().Name]) do
--		print(k, v)
--	end
--	print("T:" , Ents[inst.components.deliberator:GetNextAction().Target], "type:", type(inst.components.deliberator:GetNextAction().Target))
    print("Doing ",ACTIONS[inst.components.deliberator:GetNextAction().Name], inst.components.deliberator:GetNextAction().Target)
    return BufferedAction(inst, 
        Ents[tonumber(inst.components.deliberator:GetNextAction().Target)], 
        ACTIONS[inst.components.deliberator:GetNextAction().Name])
end

local function TestCond(inst)
	--print("test cond", inst.components.deliberator:GetNextAction() ~= nil)
	return inst.components.deliberator:GetNextAction() ~= nil
end
function WalterBrain:OnStart()
    -----------------------
    ----- Deliberator -----
    -----------------------
    self.inst:AddComponent("deliberator")
    self.inst.components.deliberator:ClearActions()

    -----------------------
    ----- Range Helper ----
    -----------------------
    AddSeeRangeHelper(self.inst)

    -----------------------
    ----- Perceptions -----
    -----------------------
    if self.beliefupdater ~= nil then
        self.beliefupdater:Cancel()
    end
    -- DoPeriodicTask(interval, fn, initialdelay, ...) the extra parameters are passed to fn
    self.beliefupdater = self.inst:DoPeriodicTask(PERCEPTION_UPDATE_INTERVAL, Perceptions, 0, self.FAtiMAServer, self.beliefscallbackfn)

    -----------------------
    -- ReconsiderActions --
    -----------------------
    self.reconsideractions = self.inst:DoPeriodicTask(RECONSIDER_ACTIONS_INTERVAL, ReconsiderActions, 0, self.FAtiMAServer, self.decidecallbackfn)

    -----------------------
    --- Event Listeners ---
    -----------------------
    -- TODO
    --self.inst:ListenForEvent("killed", self.onkilledfn)

    -----------------------
    -------- Brain --------
    -----------------------
    local root = 
        PriorityNode(
        {
            IfNode(function() return TestCond(self.inst) end, "IfDoAction", 
                DoAction(self.inst, 
                    function() return Test(self.inst) end, 
                    "doaction", 
                    true)),
				ActionNode(function() return self.inst.components.deliberator:FinishAction() end, "End Action")
            --Decide(self.inst)
        }, 1)
    self.bt = BT(self.inst, root)
end

function WalterBrain:OnStop()
    -----------------------
    ----- Deliberator -----
    -----------------------
    self.inst:RemoveComponent("deliberator")
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
    if self.beliefupdater ~= nil then
        self.beliefupdater:Cancel()
        self.beliefupdater = nil
    end
    -----------------------
    -- ReconsiderActions --
    -----------------------
    if self.reconsideractions ~= nil then
        self.reconsideractions:Cancel()
        self.reconsideractions = nil
    end
    -----------------------
    --- Event Listeners ---
    -----------------------
    -- TODO
    --self.inst:RemoveEventCallback("killed", self.onkilledfn)

end



function WalterBrain:OnEvent(actor, event, target, type)
    local data = {}
    data["subject"] = actor
    data["actionName"] = event
    data["target"] = target.name
    data["type"] = type

    TheSim:QueryServer(
        self.FAtiMAServer .. "/events",
        self.eventscallbackfn,
        "POST",
        json.encode(data))
end

return WalterBrain