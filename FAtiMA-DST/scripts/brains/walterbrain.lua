local SEE_DIST = 20
local SEE_RANGE_HELPER = true
local PERCEPTION_UPDATE_INTERVAL = .3
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

        inst.seerangehelper.Transform:SetScale(SEE_DIST/11, SEE_DIST/11, SEE_DIST/11)

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
    local EXCLUDE_TAGS = {"INLIMBO", "NOCLICK", "CLASSIFIED", "FX"}
    local ONE_OF_TAGS = nil
    local ents = TheSim:FindEntities(x, y, z, SEE_DIST, TAGS, EXCLUDE_TAGS, ONE_OF_TAGS)
    
    -- Go over all the objects that the agent can see and take what information we need
    local data = {}
	local j = 1
    for i, v in pairs(ents) do
		if v.GUID ~= inst.GUID then
			local d = {}
			d.GUID = v.GUID
			d.Prefab = v.prefab
			d.Quantity = v.components.stackable ~= nil and v.components.stackable:StackSize() or 1
			d.Pickable = v:HasTag("pickable")
			d.ChopWorkable = v:HasTag("CHOP_workable")
			d.DigWorkable = v:HasTag("DIG_workable")
			d.HammerWorkable = v:HasTag("HAMMER_workable")
			d.MineWorkable = v:HasTag("MINE_workable") 
			d.X, d.Y, d.Z = v.Transform:GetWorldPosition()

			data[j] = d
			j = j+1
		end
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
        d.Quantity = v.components.stackable ~= nil and v.components.stackable:StackSize() or 1
		d.X, d.Y, d.Z = v.Transform:GetWorldPosition()

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
        d.Quantity = v.components.stackable ~= nil and v.components.stackable:StackSize() or 1
        d.Slot = k
		d.X, d.Y, d.Z = v.Transform:GetWorldPosition()
        EquipSlots[i] = d
        i = i + 1
    end

    return EquipSlots, ItemSlots
end

local function Perceptions(inst, brain)
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
	data.IsBusy = (brain.CurrentAction or false) and true
	local x, y, z = inst.Transform:GetWorldPosition()
	data.PosX = x
	data.PosY = y
	data.PosZ = z

    -- Add a perception that says which time of the day it is (day, dusk, night)

    TheSim:QueryServer(
        brain.FAtiMAServer .. "/perceptions",
        brain.PerceptionsCallback,
        "POST",
        json.encode(data))
end

local function Decide(inst, brain)
    TheSim:QueryServer(
        brain.FAtiMAServer .. "/decide",
        brain.DecideCallback,
        "GET")
end

local function OnEvent(inst, FAtiMAServer, DecideCallback)
	
end

local WalterBrain = Class(Brain, function(self, inst, server)
    Brain._ctor(self, inst)
    self.inst = inst
	--self.inst.entity:SetCanSleep(false)

    ------------------------------
    ---- FAtiMA Communication ----
    ------------------------------
    self.FAtiMAServer = server or "http://localhost:8080"

    ------------------------------
    -- HTTP Callbacks Functions --
    ------------------------------
    self.PerceptionsCallback = function(result, isSuccessful , http_code)
        -- Intentionally left blank
    end

    self.DecideCallback = function(result, isSuccessful , http_code)
        if isSuccessful then
			local action = result and (result ~= "") and json.decode(result)
			if action and action.Name then
				self.inst:InterruptBufferedAction()
				self.inst.components.locomotor:Clear()
				self.CurrentAction = action
				print("Action(" .. action.Name .. ", " .. action.InvObject .. ", (" .. action.PosX .. "," .. action.PosZ .. "), " .. action.Recipe .. ", " .. action.Distance .. ") = " .. action.Target)
			end
		end
    end

	self.OnEvent = function(inst, data)
		print(inst.prefab)
		print("data")
		for k,v in pairs(data) do 
			print(k, v)
			for i, j in pairs(v) do
				print(i, j)
			end
		end
	end
end)

function WalterBrain:OnStart()
    -----------------------
    ----- Deliberator -----
    -----------------------
    self.CurrentAction = nil

    -----------------------
    ----- Range Helper ----
    -----------------------
    AddSeeRangeHelper(self.inst)

    -----------------------
    ----- Perceptions -----
    -----------------------
    if self.Perceptions ~= nil then
        self.Perceptions:Cancel()
    end
    -- DoPeriodicTask(interval, fn, initialdelay, ...) the extra parameters are passed to fn
    self.Perceptions = self.inst:DoPeriodicTask(PERCEPTION_UPDATE_INTERVAL, Perceptions, 0, self)

    -----------------------
    -------- Decide -------
    -----------------------
	if self.Decide ~= nil then
        self.Decide:Cancel()
    end
    self.Decide = self.inst:DoPeriodicTask(DECIDE_INTERVAL, Decide, 0, self)

    -----------------------
    --- Event Listeners ---
    -----------------------
    -- EntityScript:ListenForEvent(event, fn, source)
    -- self.inst:ListenForEvent("killed", self.OnEvent)

    -----------------------
    -------- Brain --------
    -----------------------
	-- BufferedAction(doer, target, action, invobject, pos, recipe, distance, forced, rotation)
    local root = 
        PriorityNode(
        {
            IfNode(function() return (self.CurrentAction ~= nil) end, "IfDoAction",
                SequenceNode{
					DoAction(self.inst, 
						function() return BufferedAction(
							self.inst, -- Doer
							Ents[tonumber(self.CurrentAction.Target)], -- Target
							ACTIONS[self.CurrentAction.Name], -- Action
							Ents[tonumber(self.CurrentAction.InvObject)], -- InvObject
							nil,  --Vector3({tonumber(self.CurrentAction.PosX), tonumber(self.CurrentAction.PosY), tonumber(self.CurrentAction.PosZ)}), -- Pos
							(self.CurrentAction.Recipe ~= "null") and self.CurrentAction.Recipe or nil --Recipe
							) end, 
						"DoAction", 
						true),
					DoAction(self.inst,
						function() self.CurrentAction = nil end,
						"CleanAction",
						true)
				}
			)
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
    if self.Perceptions ~= nil then
        self.Perceptions:Cancel()
        self.Perceptions = nil
    end
    -----------------------
    -------- Decide -------
    -----------------------
    if self.Decide ~= nil then
        self.Decide:Cancel()
        self.Decide = nil
    end
    -----------------------
    --- Event Listeners ---
    -----------------------
    self.inst:RemoveEventCallback("killed", self.OnEvent)

end

return WalterBrain