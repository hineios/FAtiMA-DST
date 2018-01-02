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

local function Event(name, value, brain)
	print(name, value)
	for k, v in pairs(value) do
		print(k, v)
	end
end
local function OnActionEndEvent(name, value, brain)
	local d = {}
	d.Type= "Action-End"
	d.Name = name
	d.Value = value
	d.Subject = "Walter"
	print("Event(" .. d.Type .. ", " .. d.Subject .. ", " .. d.Name .. ", " .. d.Value .. ")")
	TheSim:QueryServer(
        brain.FAtiMAServer .. "/events",
        brain.OnEventCallback,
        "POST",
        json.encode(d))
end

local function OnPropertyChangedEvent(name, value, brain)
	local d = {}
	d.Type= "Property-Change"
	d.Name = name
	d.Value = value
	d.Subject = "Walter"
	TheSim:QueryServer(
        brain.FAtiMAServer .. "/events",
        brain.OnEventCallback,
        "POST",
        json.encode(d))
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

	self.OnEventCallback = function(result, isSuccessful , http_code)
		-- Intentionally left blank
	end

    self.DecideCallback = function(result, isSuccessful , http_code)
        if isSuccessful then
			local action = result and (result ~= "") and json.decode(result)
			if action and action.Name then
				self.inst:InterruptBufferedAction()
				self.inst.components.locomotor:Clear()
				self.CurrentAction = action
				print("Action(" .. action.Name .. ", " .. action.InvObject .. ", (" .. action.PosX .. ", 0, " .. action.PosZ .. "), " .. action.Recipe .. ") = " .. action.Target)
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

	-- Listen to phases of the day changes
	-- This is actualy a perception, but it is perferable to check for changes instead of constantly checking its value.
	self.inst:ListenForEvent("phasechanged", function(inst, data) OnPropertyChangedEvent("Day(Phase)", data, self) end)
    self.inst:ListenForEvent("enterdark", function(inst, data) OnPropertyChangedEvent("Light(Walter)", "dark", self) end)
	self.inst:ListenForEvent("enterlight", function(inst, data) OnPropertyChangedEvent("Light(Walter)", "light", self) end)

	-- Events configurable in the Mod Config
	if GetModConfigData("Killed", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("killed", function(inst, data) OnActionEndEvent("Killed", data.victim.GUID, self) end) end
	if GetModConfigData("Attacked", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("attacked", function(inst, data) OnActionEndEvent("Attacked", data.attacker.GUID, self) end) end
	if GetModConfigData("Death", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("death", function(inst, data) OnActionEndEvent("Death", data.afflicter.GUID, self) end) end
	if GetModConfigData("MissOther", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("onmissother", function(inst, data) OnActionEndEvent("MissOther", data.target.GUID, self) end) end
	if GetModConfigData("HitOther", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("onhitother", function(inst, data) OnActionEndEvent("HitOther", data.target.GUID, self) end) end
	
	

--	if GetModConfigData("HealthDelta", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("healthdelta", function(inst, data) Event("HealthDelta", data, self) end) end
--	if GetModConfigData("PlayerDied", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("playerdied", function(inst, data) Event("PlayerDied", data.victim.GUID, self) end) end
--	if GetModConfigData("AdvanceSeason", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("ms_advanceseason", function(inst, data) Event("AdvanceSeason", data.victim.GUID, self) end) end
--	if GetModConfigData("Ignite", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("onignite", function(inst, data) Event("Ignite", data.victim.GUID, self) end) end
--	if GetModConfigData("BuildStructure", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("buildstructure", function(inst, data) Event("BuildStructure", data.victim.GUID, self) end) end
--	if GetModConfigData("BuildItem", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("builditem", function(inst, data) Event("BuildItem", data.victim.GUID, self) end) end
--	if GetModConfigData("WeatherTick", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("weathertick", function(inst, data) Event("WeatherTick", data.victim.GUID, self) end) end
--	if GetModConfigData("SeasonTick", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("seasontick", function(inst, data) Event("SeasonTick", data.victim.GUID, self) end) end
--	if GetModConfigData("PrecipitationChanged", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("precipitationchanged", function(inst, data) Event("PrecipitationChanged", data.victim.GUID, self) end) end
--	if GetModConfigData("PlayerActivated", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("playeractivated", function(inst, data) Event("PlayerActivated", data.victim.GUID, self) end) end
--	if GetModConfigData("PlayerDeactivated", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("playerdeactivated", function(inst, data) Event("PlayerDeactivated", data.victim.GUID, self) end) end
--	if GetModConfigData("PlayerJoined", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("ms_playerjoined", function(inst, data) Event("PlayerJoined", data.victim.GUID, self) end) end
--	if GetModConfigData("PlayerLeft", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("ms_playerleft", function(inst, data) Event("PlayerLeft", data.victim.GUID, self) end) end
	-- "killed", "onhitother", "attacked", "weathertick", "seasontick", "precipitationchanged", "death", "playeractivated", "playerdeactivated", "enterdark", "enterlight", "nightvision", "healthdelta", "ms_playerjoined", "ms_playerleft", "playerdied", "ms_advanceseason", "onignite", "buildstructure", "builditem"

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
							(self.CurrentAction.PosX ~= "-" and Vector3(tonumber(self.CurrentAction.PosX), tonumber(self.CurrentAction.PosY), tonumber(self.CurrentAction.PosZ)) or nil), -- Pos
							(self.CurrentAction.Recipe ~= "-") and self.CurrentAction.Recipe or nil --Recipe
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
    if GetModConfigData("Killed", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:RemoveEventCallback("killed", function(inst, data) OnActionEndEvent("Killed", data.victim.GUID, self) end) end
	self.inst:RemoveEventCallback("phasechanged", OnPropertyChangedEvent)
end

return WalterBrain