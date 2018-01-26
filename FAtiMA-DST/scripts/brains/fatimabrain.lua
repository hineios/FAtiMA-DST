local SEE_DIST = 20
local SEE_RANGE_HELPER = true
local PERCEPTION_UPDATE_INTERVAL = .3
local DECIDE_INTERVAL = 1
local NUM_SEGS = 16

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
			d.Pickable = v:HasTag("_inventoryitem") -- PICKUP
			d.Collectable = v:HasTag("pickable") -- PICK
			d.ChopWorkable = v:HasTag("CHOP_workable")
			d.DigWorkable = v:HasTag("DIG_workable")
			d.HammerWorkable = v:HasTag("HAMMER_workable")
			d.MineWorkable = v:HasTag("MINE_workable") 
			d.Equippable = v:HasTag("_equippable")
			d.Fuel = v:HasTag("BURNABLE_fuel")
			d.Fueled = v:HasTag("BURNABLE_fueled")
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
		-- Stuff in the inventory is neither pickable nor workable
		d.Pickable = false
		d.Collectable = false
		d.ChopWorkable = false
		d.DigWorkable = false
		d.HammerWorkable = false
		d.MineWorkable = false
		d.Equippable = v:HasTag("_equippable")
		d.Fuel = v:HasTag("BURNABLE_fuel")
		d.Fueled = v:HasTag("BURNABLE_fueled")
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
		-- Stuff in the inventory is neither pickable nor workable
		d.Pickable = false
		d.Collectable = false
		d.ChopWorkable = false
		d.DigWorkable = false
		d.HammerWorkable = false
		d.MineWorkable = false
		d.Equippable = v:HasTag("_equippable")
		d.Fuel = v:HasTag("BURNABLE_fuel")
		d.Fueled = v:HasTag("BURNABLE_fueled")
        d.Slot = k
		d.X, d.Y, d.Z = v.Transform:GetWorldPosition()

        EquipSlots[i] = d
        i = i + 1
    end

    return EquipSlots, ItemSlots
end

-- here for testing purposes...
local function Event(name, value, brain)
	print(name, value)
	if (type(value) == "table") then
		for k, v in pairs(value) do
			print(k, v)
		end
	end
end

local function KeepWorking(action, target)
	local t = Ents[tonumber(target)]
	if action == "CHOP" and t ~= nil and t:HasTag("CHOP_workable") then return true
	elseif action == "HAMMER" and t ~= nil and t:HasTag("HAMMER_workable") then return true
	elseif action == "DIG" and t ~= nil and t:HasTag("DIG_workable") then return true
	elseif action == "MINE" and t ~= nil and t:HasTag("MINE_workable") then return true
	else return false end
end

local function IsWorkAction(action)
	return action == "CHOP" or action == "MINE" or action == "HAMMER" or action == "DIG"
end

local FAtiMABrain = Class(Brain, function(self, inst, server)
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
	self.OnPerceptions = function() self:Perceptions() end
    self.PerceptionsCallback = function(result, isSuccessful , http_code)
        -- Intentionally left blank
    end

	self.OnEventCallback = function(result, isSuccessful , http_code)
		-- Intentionally left blank
	end

	self.OnDecide = function() self:Decide() end
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

	------------------------------
    -- Event Listener Functions --
    ------------------------------
	-- I need to keep references to these functions to remove the listeners later
	self.OnClockTick = function (inst, data)
		if self.time ~= nil then
			local prevseg = math.floor(self.time * NUM_SEGS)
			local nextseg = math.floor(data.time * NUM_SEGS)
			if prevseg ~= nextseg then
				self:OnPropertyChangedEvent("World(CurrentSegment)", nextseg)
			end
		end
		self.time = data.time
	end
	self.OnClockSegsChanged = function(inst, data) 
		self:OnPropertyChangedEvent("World(PhaseLenght, day)", data.day) 
		self:OnPropertyChangedEvent("World(PhaseLenght, dusk)", data.dusk) 
		self:OnPropertyChangedEvent("World(PhaseLenght, night)", data.night) 
	end
	self.OnEnterDark = function(inst, data) self:OnPropertyChangedEvent("Light(Walter)", "dark") end
	self.OnEnterLight = function(inst, data) self:OnPropertyChangedEvent("Light(Walter)", "light") end

	self.OnKilled = function(inst, data) self:OnActionEndEvent("Killed", data.victim.GUID) end
	self.OnAttacked = function(inst, data) self:OnActionEndEvent("Attacked", data.attacker.GUID) end
	self.OnDeath = function(inst, data) self:OnActionEndEvent("Death", data.afflicter.GUID) end
	self.OnMissOther = function(inst, data) self:OnActionEndEvent("MissOther", data.target.GUID) end
	self.OnHitOther = function(inst, data) self:OnActionEndEvent("HitOther", data.target.GUID) end

	------------------------------
    ------ Watch World State -----
    ------------------------------
	self.OnCycles = function(inst, cycles) 
		if cycles ~= nil then
			self:OnPropertyChangedEvent("World(Cycle)", cycles + 1)
		end
	end
	self.OnPhase = function(inst, phase) self:OnPropertyChangedEvent("World(Phase)", phase) end
	self.OnIsDay = function(inst, isday) self:OnPropertyChangedEvent("World(IsDay)", isday) end
	self.OnIsDusk = function(inst, isdusk) self:OnPropertyChangedEvent("World(IsDusk)", isdusk) end
	self.OnIsNight = function(inst, isnight) self:OnPropertyChangedEvent("World(IsNight)", isnight) end
	self.OnMoonPhase = function(inst, moonphase) self:OnPropertyChangedEvent("World(MoonPhase)", moonphase) end
	self.OnIsFullMoon = function(inst, isfullmoon) self:OnPropertyChangedEvent("World(IsFullMoon)", isfullmoon) end
	self.OnIsNewMoon = function(inst, isnewmoon) self:OnPropertyChangedEvent("World(IsNewMoon)", isnewmoon) end
	self.OnSeason = function(inst, season) self:OnPropertyChangedEvent("World(Season)", season) end
	self.OnSeasonProgress = function(inst, seasonprogress) self:OnPropertyChangedEvent("World(SeasonProgress)", seasonprogress) end
	self.OnSpringLength = function(inst, springlength) self:OnPropertyChangedEvent("World(SpringLength)", springlength) end
	self.OnSummerLength = function(inst, summerlength) self:OnPropertyChangedEvent("World(SummerLength)", summerlength) end
	self.OnAutumnLength = function(inst, autumnlength) self:OnPropertyChangedEvent("World(AutumnLenght)", autumnlength) end
	self.OnWinterLength = function(inst, winterlength) self:OnPropertyChangedEvent("World(WinterLenght)", winterlength) end
	self.OnIsSpring = function(inst, isspring) self:OnPropertyChangedEvent("World(IsSpring)", isspring) end
	self.OnIsSummer = function(inst, issummer) self:OnPropertyChangedEvent("World(IsSummer)", issummer) end
	self.OnIsAutumn = function(inst, isautumn) self:OnPropertyChangedEvent("World(IsAutumn)", isautumn) end
	self.OnIsWinter = function(inst, iswinter) self:OnPropertyChangedEvent("World(IsWinter)", iswinter) end
	self.OnElapsedDaysInSeason = function(inst, elapseddaysinseason) self:OnPropertyChangedEvent("World(ElapsedDaysInSeason)", elapseddaysinseason) end
	self.OnRemainingDaysInSeason = function(inst, remainingdaysinseason) self:OnPropertyChangedEvent("World(RemainingDaysInSeason)", remainingdaysinseason) end
	self.OnIsSnowing = function(inst, issnowing) self:OnPropertyChangedEvent("World(IsSnowing)", issnowing) end
	self.OnIsRaining = function(inst, israining) self:OnPropertyChangedEvent("World(IsRaining)", israining) end
end)

function FAtiMABrain:Perceptions()
    local data = {}
    data.Vision = Vision(self.inst)
    data.EquipSlots, data.ItemSlots = Inventory(self.inst) 

    data.Health = self.inst.components.health.currenthealth
    data.Hunger = self.inst.components.hunger.current
    data.Sanity = self.inst.components.sanity.current
    data.Temperature = self.inst:GetTemperature()
    data.IsFreezing = self.inst:IsFreezing()
    data.IsOverHeating = self.inst:IsOverheating()
    data.Moisture = self.inst:GetMoisture()
	data.IsBusy = (self.CurrentAction or false) and true
	local x, y, z = self.inst.Transform:GetWorldPosition()
	data.PosX = x
	data.PosY = y
	data.PosZ = z

    TheSim:QueryServer(
        self.FAtiMAServer .. "/perceptions",
        self.PerceptionsCallback,
        "POST",
        json.encode(data))
end

function FAtiMABrain:Decide()
    TheSim:QueryServer(
        self.FAtiMAServer .. "/decide",
        self.DecideCallback,
        "GET")
end

function FAtiMABrain:OnActionEndEvent(name, value)
	local d = {}
	d.Type= "Action-End"
	d.Name = name
	d.Value = value
	d.Subject = "Walter"
	print("Event(" .. d.Type .. ", " .. d.Name .. ", " .. d.Value .. ", " .. d.Subject .. ")")
	TheSim:QueryServer(
        self.FAtiMAServer .. "/events",
        self.OnEventCallback,
        "POST",
        json.encode(d))
end

function FAtiMABrain:OnPropertyChangedEvent(name, value)
	local d = {}
	d.Type= "Property-Change"
	d.Name = name
	d.Value = value
	d.Subject = "Walter"
	print(d.Name .. " = ", d.Value)
	TheSim:QueryServer(
        self.FAtiMAServer .. "/events",
        self.OnEventCallback,
        "POST",
        json.encode(d))
end

function FAtiMABrain:OnStart()
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
    if self.PerceptionsTask ~= nil then
        self.PerceptionsTask:Cancel()
    end
    -- DoPeriodicTask(interval, fn, initialdelay, ...) the extra parameters are passed to fn
    self.PerceptionsTask = self.inst:DoPeriodicTask(PERCEPTION_UPDATE_INTERVAL, self.OnPerceptions, 0)

    -----------------------
    -------- Decide -------
    -----------------------
	if self.DecideTask ~= nil then
        self.DecideTask:Cancel()
    end
    self.DecideTask = self.inst:DoPeriodicTask(DECIDE_INTERVAL, self.OnDecide, 0)

    -----------------------
    --- Event Listeners ---
    -----------------------
	-- EntityScript:ListenForEvent(event, fn, source)
	-- These are actualy perceptions/beliefs, but it is perferable to check for changes instead of constantly checking their values.
	
    self.inst:ListenForEvent("enterdark", self.OnEnterDark)
	self.inst:ListenForEvent("enterlight", self.OnEnterLight)
	self.inst:ListenForEvent("clocksegschanged", self.OnClockSegsChanged, TheWorld)
	self.inst:ListenForEvent("clocktick", self.OnClockTick, TheWorld) -- this is called so often there is no need to initialize
	
	-- Events configurable in the Mod Config
	if GetModConfigData("Killed", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("killed", self.OnKilled) end
	if GetModConfigData("Attacked", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("attacked", self.OnAttacked) end
	if GetModConfigData("Death", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("death", self.OnDeath)	end
	if GetModConfigData("MissOther", KnownModIndex:GetModActualName("FAtiMA-DST")) then	self.inst:ListenForEvent("onmissother", self.OnMissOther) end
	if GetModConfigData("HitOther", KnownModIndex:GetModActualName("FAtiMA-DST")) then self.inst:ListenForEvent("onhitother", self.OnHitOther) end

    -----------------------
    ---- World Watchers ---
    -----------------------
	-- EntityScript:WatchWorldState(var, fn)
	-- Day Related beliefs
	self.inst:WatchWorldState("cycles", self.OnCycles)
	self.inst:WatchWorldState("phase", self.OnPhase)
	self.inst:WatchWorldState("isday", self.OnIsDay)
	self.inst:WatchWorldState("isdusk", self.OnIsDusk)
	self.inst:WatchWorldState("isnight", self.OnIsNight)

	-- Moon Related beliefs
	self.inst:WatchWorldState("moonphase", self.OnMoonPhase)
	self.inst:WatchWorldState("isfullmoon", self.OnIsFullMoon)
	self.inst:WatchWorldState("isnewmoon", self.OnIsNewMoon)

	-- Season related beliefs
	self.inst:WatchWorldState("season", self.OnSeason)
	self.inst:WatchWorldState("seasonprogress", self.OnSeasonProgress)
	self.inst:WatchWorldState("springlength", self.OnSpringLenght)
	self.inst:WatchWorldState("summerlength", self.OnSummerLength)	
	self.inst:WatchWorldState("autumnlength", self.OnAutumnLenght)
	self.inst:WatchWorldState("winterlength", self.OnWinterLenght)
	self.inst:WatchWorldState("isspring", self.OnIsSpring)
	self.inst:WatchWorldState("issummer", self.OnIsSummer)
	self.inst:WatchWorldState("isautumn", self.OnIsAutumn)
	self.inst:WatchWorldState("iswinter", self.OnIsWinter)
	self.inst:WatchWorldState("elapseddaysinseason", self.OnElapsedDaysInSeason)
	self.inst:WatchWorldState("remainingdaysinseason", self.OnRemainingDaysInSeason)

	-- Weather related beliefs
	self.inst:WatchWorldState("issnowing", self.OnIsSnowing)
	self.inst:WatchWorldState("israining", self.OnIsRaining)
--	self.inst:WatchWorldState("precipitationrate", OnPrecipitationRate)
--	self.inst:WatchWorldState("precipitation", OnPrecipitation)
--	self.inst:WatchWorldState("issnowcovered", OnIsSnowCovered)
--	self.inst:WatchWorldState("snowlevel", OnSnowLevel)
	
	-- Registered listeners to tell FAtiMA about changes, now let's tell FAtiMA the initial values
	self.OnClockSegsChanged(self.inst, TheWorld.net.components.clock:OnSave().segs)
	if self.inst.LightWatcher:IsInLight() then
		self.OnEnterLight(self.inst, nil)
	else
		self.OnEnterDark(self.inst, nil)
	end
	self.OnCycles(self.inst, TheWorld.state.cycles)
	self.OnPhase(self.inst, TheWorld.state.phase)
	self.OnIsDay(self.inst, TheWorld.state.isday)
	self.OnIsDusk(self.inst, TheWorld.state.isdusk)
	self.OnIsNight(self.inst, TheWorld.state.isnight)
	self.OnMoonPhase(self.inst, TheWorld.state.moonphase)
	self.OnIsFullMoon(self.inst, TheWorld.state.isfullmoon)
	self.OnIsNewMoon(self.inst, TheWorld.state.isnewmoon)
	self.OnSeason(self.inst, TheWorld.state.season)
	self.OnSeasonProgress(self.inst, TheWorld.state.seasonprogress)
	self.OnSpringLength(self.inst, TheWorld.state.springlength)
	self.OnSummerLength(self.inst, TheWorld.state.summerlength)
	self.OnAutumnLength(self.inst, TheWorld.state.autumnlength)
	self.OnWinterLength(self.inst, TheWorld.state.winterlength)
	self.OnIsSpring(self.inst, TheWorld.state.isspring)
	self.OnIsSummer(self.inst, TheWorld.state.issummer)
	self.OnIsAutumn(self.inst, TheWorld.state.isautumn)
	self.OnIsWinter(self.inst, TheWorld.state.iswinter)
	self.OnElapsedDaysInSeason(self.inst, TheWorld.state.elapseddaysinseason)
	self.OnRemainingDaysInSeason(self.inst, TheWorld.state.remainingdaysinseason)
	self.OnIsSnowing(self.inst, TheWorld.state.issnowing)
	self.OnIsRaining(self.inst, TheWorld.state.israining)

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
							self.inst,
							Ents[tonumber(self.CurrentAction.Target)],
							ACTIONS[self.CurrentAction.Name],
							Ents[tonumber(self.CurrentAction.InvObject)],
							(self.CurrentAction.PosX ~= "-" and Vector3(tonumber(self.CurrentAction.PosX), tonumber(self.CurrentAction.PosY), tonumber(self.CurrentAction.PosZ)) or nil),
							(self.CurrentAction.Recipe ~= "-") and self.CurrentAction.Recipe or nil)
						end, 
						"DoAction", 
						true),
					DoAction(self.inst,
						function() 
							-- If the target of the action ceases to exist, we need to inform FAtiMA
							-- applyable for both working actions and not working actions
							if self.CurrentAction.Target ~= "-" and Ents[tonumber(self.CurrentAction.Target)] == nil then
								-- Target no longer exists
								self:OnPropertyChangedEvent("Pickable(" .. self.CurrentAction.Target .. ")", false)
								self:OnPropertyChangedEvent("Collectable(" .. self.CurrentAction.Target .. ")", false)
								self:OnPropertyChangedEvent("ChopWorkable(" .. self.CurrentAction.Target .. ")", false)
								self:OnPropertyChangedEvent("DigWorkable(" .. self.CurrentAction.Target .. ")", false)
								self:OnPropertyChangedEvent("HammerWorkable(" .. self.CurrentAction.Target .. ")", false)
								self:OnPropertyChangedEvent("MineWorkable(" .. self.CurrentAction.Target .. ")", false)
							end

							-- Working actions we want to keep executing until the target is not workable anymore
							if IsWorkAction(self.CurrentAction.Name) then
								if not KeepWorking(self.CurrentAction.Name, self.CurrentAction.Target) then
									self.CurrentAction = nil
								end
							else
								-- All other actions we want to stop here
								self.CurrentAction = nil
							end
						end,
						"CleanAction",
						true)
				}
			)
        }, 1)
    self.bt = BT(self.inst, root)
end

function FAtiMABrain:OnStop()
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
    if self.PerceptionsTask ~= nil then
        self.PerceptionsTask:Cancel()
        self.PerceptionsTask = nil
    end
    -----------------------
    -------- Decide -------
    -----------------------
    if self.DecideTask ~= nil then
        self.DecideTask:Cancel()
        self.DecideTask = nil
    end
    -----------------------
    --- Event Listeners ---
    -----------------------
	self.inst:RemoveEventCallback("enterdark", self.OnEnterDark)
	self.inst:RemoveEventCallback("enterlight", self.OnEnterLight)
	self.inst:RemoveEventCallback("clocksegschanged", self.OnClockSegsChanged, TheWorld)
	self.inst:RemoveEventCallback("clocktick", self.OnClockTick, TheWorld)

	self.inst:RemoveEventCallback("killed", self.OnKilled)
	self.inst:RemoveEventCallback("attacked", self.OnAttacked)
	self.inst:RemoveEventCallback("death", self.OnDeath)
	self.inst:RemoveEventCallback("onmissother", self.OnMissOther)
	self.inst:RemoveEventCallback("onhitother", self.OnHitOther)

	-----------------------
    ---- World Watchers ---
    -----------------------
	-- Day Related beliefs
	self.inst:StopWatchingWorldState("cycles", self.OnCycles)
	self.inst:StopWatchingWorldState("phase", self.OnPhase)
	self.inst:StopWatchingWorldState("isday", self.OnIsDay)
	self.inst:StopWatchingWorldState("isdusk", self.OnIsDusk)
	self.inst:StopWatchingWorldState("isnight", self.OnIsNight)

	-- Moon Related beliefs
	self.inst:StopWatchingWorldState("moonphase", self.OnMoonPhase)
	self.inst:StopWatchingWorldState("isfullmoon", self.OnIsFullMoon)
	self.inst:StopWatchingWorldState("isnewmoon", self.OnIsNewMoon)

	-- Season related beliefs
	self.inst:StopWatchingWorldState("season", self.OnSeason)
	self.inst:StopWatchingWorldState("seasonprogress", self.OnSeasonProgress)
	self.inst:StopWatchingWorldState("springlength", self.OnSpringLenght)
	self.inst:StopWatchingWorldState("summerlength", self.OnSummerLength)	
	self.inst:StopWatchingWorldState("autumnlength", self.OnAutumnLenght)
	self.inst:StopWatchingWorldState("winterlength", self.OnWinterLenght)
	self.inst:StopWatchingWorldState("isspring", self.OnIsSpring)
	self.inst:StopWatchingWorldState("issummer", self.OnIsSummer)
	self.inst:StopWatchingWorldState("isautumn", self.OnIsAutumn)
	self.inst:StopWatchingWorldState("iswinter", self.OnIsWinter)
	self.inst:StopWatchingWorldState("elapseddaysinseason", self.OnElapsedDaysInSeason)
	self.inst:StopWatchingWorldState("remainingdaysinseason", self.OnRemainingDaysInSeason)

	-- Weather related beliefs
	self.inst:StopWatchingWorldState("issnowing", self.OnIsSnowing)
	self.inst:StopWatchingWorldState("israining", self.OnIsRaining)
end

return FAtiMABrain