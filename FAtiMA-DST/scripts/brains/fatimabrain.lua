local SEE_DIST = 20
local SEE_RANGE_HELPER = true
local PERCEPTION_UPDATE_INTERVAL = .5
local DSTACTION_INTERVAL = 1.5
local SPEAKACTION_INTERVAL = 10
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

local function Entity(inst, v)
	local d = {}
	d.GUID = v.GUID
	d.Prefab = v.prefab
	d.Collectable = v:HasTag("pickable") -- PICK
	d.Pickable = v.components.inventoryitem and v.components.inventoryitem.canbepickedup -- PICKUP
	d.Edible = inst.components.eater:CanEat(v)
	d.Equippable = v:HasTag("_equippable")
	d.Choppable = v:HasTag("CHOP_workable")
	d.Diggable = v:HasTag("DIG_workable")
	d.Hammerable = v:HasTag("HAMMER_workable")
	d.Mineable = v:HasTag("MINE_workable")
	d.Fuel = v:HasTag("BURNABLE_fuel")
	d.Fueled = v:HasTag("BURNABLE_fueled")
	d.X, d.Y, d.Z = v.Transform:GetWorldPosition()
	d.Quantity = v.components.stackable ~= nil and v.components.stackable:StackSize() or 1

	return d
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
	return (action == "CHOP" and t ~= nil and t:HasTag("CHOP_workable")) or (action == "HAMMER" and t ~= nil and t:HasTag("HAMMER_workable")) or (action == "DIG" and t ~= nil and t:HasTag("DIG_workable")) or (action == "MINE" and t ~= nil and t:HasTag("MINE_workable"))
end

local function IsWorkAction(action)
	return action == "CHOP" or action == "MINE" or action == "HAMMER" or action == "DIG"
end

local FAtiMABrain = Class(Brain, function(self, inst, server)
    Brain._ctor(self, inst)
    self.inst = inst

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

	self.OnDSTActionDecide = function() self:Decide("Behaviour") end
	self.OnSpeakActionDecide = function() self:Decide("Dialog") end
    self.DecideCallback = function(result, isSuccessful , http_code)
        if isSuccessful then
			local action = result and (result ~= "") and json.decode(result)
			if action and action.Type then
				if action.Type == "Action" then
					if self.CurrentAction == nil or (self.CurrentAction.WFN ~= action.WFN or self.CurrentAction.Target ~= action.Target) then 
						print(action.WFN .. " = " .. action.Target)
						self.inst:InterruptBufferedAction()
						self.inst.components.locomotor:Clear()
						self.CurrentAction = action
					end
					--Otherwise the action is the same as the one being executed, so tehere is no need to override it
				elseif action.Type == "Speak" then
					-- Speak Action are made the moment they are received. They only occur every SPEAKACTION_INTERVAL seconds
					-- Speak([cs],[ns],[m],[sty]) = [t]
					print(action.Type .. " = " .. action.Utterance)
					self.inst.components.talker:Say(action.Utterance)
					-- Tell FAtiMA that the action has ended
					self:OnActionEndEvent(action.Name, action.Target)
				end
			end
		end
    end

	------------------------------
    -- Event Listener Functions --
    ------------------------------
	-- I need to keep references to these functions to remove the listeners later
	self.OnKilled = function(inst, data) self:OnActionEndEvent("Killed", data.victim.GUID) end
	self.OnAttacked = function(inst, data) self:OnActionEndEvent("Attacked", data.attacker and data.attacker.GUID or "darkness") end
	self.OnDeath = function(inst, data) self:OnActionEndEvent("Death", data.afflicter and data.attacker.GUID or "darkness") end
	self.OnMissOther = function(inst, data) self:OnActionEndEvent("MissOther", data.target.GUID) end
	self.OnHitOther = function(inst, data) self:OnActionEndEvent("HitOther", data.target.GUID) end

	------------------------------
    ------ Watch World State -----
    ------------------------------
	self.OnClockTick = function (inst, data)
		if self.time ~= nil then
			local prevseg = math.floor(self.time * NUM_SEGS)
			local nextseg = math.floor(data.time * NUM_SEGS)
			if prevseg ~= nextseg then
				self:OnPropertyChangedEvent("World(CurrentSegment)", nextseg)
			end
		else
			-- The first time we need to tell FAtiMA what is the current segment
			self:OnPropertyChangedEvent("World(CurrentSegment)", math.floor(data.time * NUM_SEGS))
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
	self.OnCycles = function(inst, cycles) if cycles ~= nil then self:OnPropertyChangedEvent("World(Cycle)", cycles + 1) end end
	self.OnPhase = function(inst, phase) self:OnPropertyChangedEvent("World(Phase)", phase) end
	self.OnMoonPhase = function(inst, moonphase) self:OnPropertyChangedEvent("World(MoonPhase)", moonphase) end
	self.OnSeason = function(inst, season) self:OnPropertyChangedEvent("World(Season)", season) end
	self.OnSeasonProgress = function(inst, seasonprogress) self:OnPropertyChangedEvent("World(SeasonProgress)", seasonprogress) end
	self.OnElapsedDaysInSeason = function(inst, elapseddaysinseason) self:OnPropertyChangedEvent("World(ElapsedDaysInSeason)", elapseddaysinseason) end
	self.OnRemainingDaysInSeason = function(inst, remainingdaysinseason) self:OnPropertyChangedEvent("World(RemainingDaysInSeason)", remainingdaysinseason) end
	self.OnSpringLength = function(inst, springlength) self:OnPropertyChangedEvent("World(SpringLength)", springlength) end
	self.OnSummerLength = function(inst, summerlength) self:OnPropertyChangedEvent("World(SummerLength)", summerlength) end
	self.OnAutumnLength = function(inst, autumnlength) self:OnPropertyChangedEvent("World(AutumnLenght)", autumnlength) end
	self.OnWinterLength = function(inst, winterlength) self:OnPropertyChangedEvent("World(WinterLenght)", winterlength) end
	self.OnIsSnowing = function(inst, issnowing) self:OnPropertyChangedEvent("World(IsSnowing)", issnowing) end
	self.OnIsRaining = function(inst, israining) self:OnPropertyChangedEvent("World(IsRaining)", israining) end
end)

function FAtiMABrain:Perceptions()
    local data = {}

	-- Vision
	local x, y, z = self.inst.Transform:GetWorldPosition()
    local TAGS = nil
    local EXCLUDE_TAGS = {"INLIMBO", "NOCLICK", "CLASSIFIED", "FX"}
    local ONE_OF_TAGS = nil
    local ents = TheSim:FindEntities(x, y, z, SEE_DIST, TAGS, EXCLUDE_TAGS, ONE_OF_TAGS)
    
    -- Go over all the objects that the agent can see and take what information we need
    local vision = {}
	local j = 1
    for i, v in pairs(ents) do
		if v.GUID ~= self.inst.GUID then
			vision[j] = Entity(self.inst, v)
			j = j+1
		end
    end
    data.Vision = vision

	-- Inventory
	local equipslots = {}
    local itemslots = {}
 
    -- Go over all items in the inventory and take what information we need
    for k, v in pairs(self.inst.components.inventory.itemslots) do
        itemslots[k] = Entity(self.inst, v)
    end

    -- Go over equipped items and put them in an array
    -- I chose to use an array not to limit which equip slots the agent has.
    -- This way I do not need to change any code, should any new slot appear.
    local i = 1
    for k, v in pairs(self.inst.components.inventory.equipslots) do
        equipslots[i] = Entity(self.inst, v)
        i = i + 1
    end
    data.EquipSlots, data.ItemSlots = equipslots, itemslots

    data.Health = self.inst.components.health.currenthealth
    data.Hunger = self.inst.components.hunger.current
    data.Sanity = self.inst.components.sanity.current
    data.Temperature = self.inst:GetTemperature()
    data.IsFreezing = self.inst:IsFreezing()
    data.IsOverHeating = self.inst:IsOverheating()
    data.Moisture = self.inst:GetMoisture()
	data.IsBusy = (self.CurrentAction or false) and true
	data.PosX, data.PosY, data.PosZ = self.inst.Transform:GetWorldPosition()

    TheSim:QueryServer(
        self.FAtiMAServer .. "/" .. tostring(self.inst.GUID) .. "/perceptions",
        self.PerceptionsCallback,
        "POST",
        json.encode(data))
end

function FAtiMABrain:Decide(layer)
    TheSim:QueryServer(
        self.FAtiMAServer .. "/" .. tostring(self.inst.GUID) .. "/decide/" .. layer,
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
        self.FAtiMAServer .. "/" .. tostring(self.inst.GUID) .. "/events",
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
        self.FAtiMAServer .. "/" .. tostring(self.inst.GUID) .. "/events",
        self.OnEventCallback,
        "POST",
        json.encode(d))
end

function FAtiMABrain:OnDeleteEntity(GUID)
	local d = {}
	d.Type = "Delete-Entity"
	d.Name = ""
	d.Value = GUID
	d.Subject = "Walter"
	print("Delete-Entity(" .. GUID .. ")")
	TheSim:QueryServer(
        self.FAtiMAServer .. "/" .. tostring(self.inst.GUID) .. "/events",
        self.OnEventCallback,
        "POST",
        json.encode(d))
end

function FAtiMABrain:OnStart()
	self.inst.entity:SetCanSleep(false)
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
	if self.DSTActionTask ~= nil then
        self.DSTActionTask:Cancel()
    end
    self.DSTActionTask = self.inst:DoPeriodicTask(DSTACTION_INTERVAL, self.OnDSTActionDecide, 0)
	
	if self.SpeakActionTask ~= nil then
		self.SpeakActionTask:Cancel()
	end
	self.SpeakActionTask = self.inst:DoPeriodicTask(SPEAKACTION_INTERVAL, self.OnSpeakActionDecide, 0)
	
    -----------------------
    --- Event Listeners ---
    -----------------------
	-- EntityScript:ListenForEvent(event, fn, source)
	self.inst:ListenForEvent("killed", self.OnKilled)
	self.inst:ListenForEvent("attacked", self.OnAttacked)
	self.inst:ListenForEvent("death", self.OnDeath)
	self.inst:ListenForEvent("onmissother", self.OnMissOther)
	self.inst:ListenForEvent("onhitother", self.OnHitOther)

    -----------------------
    ---- World Watchers ---
    -----------------------
	-- EntityScript:WatchWorldState(var, fn)
	self.inst:ListenForEvent("enterdark", self.OnEnterDark)
	self.inst:ListenForEvent("enterlight", self.OnEnterLight)
	self.inst:ListenForEvent("clocksegschanged", self.OnClockSegsChanged, TheWorld)
	self.inst:ListenForEvent("clocktick", self.OnClockTick, TheWorld) -- this is called so often there is no need to initialize
	self.inst:WatchWorldState("cycles", self.OnCycles)
	self.inst:WatchWorldState("phase", self.OnPhase)
	self.inst:WatchWorldState("moonphase", self.OnMoonPhase)
	self.inst:WatchWorldState("season", self.OnSeason)
	self.inst:WatchWorldState("seasonprogress", self.OnSeasonProgress)
	self.inst:WatchWorldState("elapseddaysinseason", self.OnElapsedDaysInSeason)
	self.inst:WatchWorldState("remainingdaysinseason", self.OnRemainingDaysInSeason)
	self.inst:WatchWorldState("springlength", self.OnSpringLenght)
	self.inst:WatchWorldState("summerlength", self.OnSummerLength)	
	self.inst:WatchWorldState("autumnlength", self.OnAutumnLenght)
	self.inst:WatchWorldState("winterlength", self.OnWinterLenght)
	self.inst:WatchWorldState("issnowing", self.OnIsSnowing)
	self.inst:WatchWorldState("israining", self.OnIsRaining)

	-- Registered listeners to tell FAtiMA about changes, now let's tell FAtiMA the initial values
	self.OnClockSegsChanged(self.inst, TheWorld.net.components.clock:OnSave().segs)
		if self.inst.LightWatcher:IsInLight() then
			self.OnEnterLight(self.inst, nil)
		else
			self.OnEnterDark(self.inst, nil)
	end
	self.OnCycles(self.inst, TheWorld.state.cycles)
	self.OnPhase(self.inst, TheWorld.state.phase)
	self.OnMoonPhase(self.inst, TheWorld.state.moonphase)
	self.OnSeason(self.inst, TheWorld.state.season)
	self.OnSeasonProgress(self.inst, TheWorld.state.seasonprogress)
	self.OnElapsedDaysInSeason(self.inst, TheWorld.state.elapseddaysinseason)
	self.OnRemainingDaysInSeason(self.inst, TheWorld.state.remainingdaysinseason)
	self.OnSpringLength(self.inst, TheWorld.state.springlength)
	self.OnSummerLength(self.inst, TheWorld.state.summerlength)
	self.OnAutumnLength(self.inst, TheWorld.state.autumnlength)
	self.OnWinterLength(self.inst, TheWorld.state.winterlength)
	self.OnIsSnowing(self.inst, TheWorld.state.issnowing)
	self.OnIsRaining(self.inst, TheWorld.state.israining)

    -----------------------
    -------- Brain --------
    -----------------------
	-- BufferedAction(doer, target, action, invobject, pos, recipe, distance, forced, rotation)
    local root = 
        PriorityNode(
        {
            IfNode(function() return (self.CurrentAction ~= nil and self.CurrentAction.Type == "Action") end, "IfAction",
                DoAction(self.inst, 
					-- BufferedAction(Doer, Target, Action, InvObject, Pos, Recipe)
					function() 
						local b = BufferedAction(
							self.inst,
							Ents[tonumber(self.CurrentAction.Target)],
							ACTIONS[self.CurrentAction.Action],
							Ents[tonumber(self.CurrentAction.InvObject)],
							(self.CurrentAction.PosX ~= "-" and Vector3(tonumber(self.CurrentAction.PosX), tonumber(self.CurrentAction.PosY), tonumber(self.CurrentAction.PosZ)) or nil),
							(self.CurrentAction.Recipe ~= "-") and self.CurrentAction.Recipe or nil)

						b:AddFailAction(function() 
							if IsWorkAction(self.CurrentAction.Action) then
								if KeepWorking(self.CurrentAction.Action, self.CurrentAction.Target) then
									return
								end
							end
							self:OnActionEndEvent(self.CurrentAction.WFN, self.CurrentAction.Target)
							self.CurrentAction = nil 
						end)

						b:AddSuccessAction(function() 
							-- If the target of the action ceases to exist, we need to inform FAtiMA
							-- applyable for both working actions and not working actions
							if self.CurrentAction.Target ~= "-" and Ents[tonumber(self.CurrentAction.Target)] == nil then
								-- Target no longer exists
								self:OnDeleteEntity(self.CurrentAction.Target)
							end

							-- Working actions we want to keep executing until the target is not workable anymore
							if IsWorkAction(self.CurrentAction.Action) then
								if not KeepWorking(self.CurrentAction.Action, self.CurrentAction.Target) then
									self:OnActionEndEvent(self.CurrentAction.WFN, self.CurrentAction.Target)
									self.CurrentAction = nil
								end
							else
								self:OnActionEndEvent(self.CurrentAction.WFN, self.CurrentAction.Target)
								self.CurrentAction = nil
							end
						end)
						return b
					end, 
					"DoAction", 
					true)
				-- Close DoAction
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
	if self.DSTActionTask ~= nil then
        self.DSTActionTask:Cancel()
		self.DSTActionTask= nil
    end
	
	if self.SpeakActionTask ~= nil then
		self.SpeakActionTask:Cancel()
		self.SpeakActionTask = nil
	end

    -----------------------
    --- Event Listeners ---
    -----------------------
	self.inst:RemoveEventCallback("killed", self.OnKilled)
	self.inst:RemoveEventCallback("attacked", self.OnAttacked)
	self.inst:RemoveEventCallback("death", self.OnDeath)
	self.inst:RemoveEventCallback("onmissother", self.OnMissOther)
	self.inst:RemoveEventCallback("onhitother", self.OnHitOther)

	-----------------------
    ---- World Watchers ---
    -----------------------
	self.inst:RemoveEventCallback("enterdark", self.OnEnterDark)
	self.inst:RemoveEventCallback("enterlight", self.OnEnterLight)
	self.inst:RemoveEventCallback("clocksegschanged", self.OnClockSegsChanged, TheWorld)
	self.inst:RemoveEventCallback("clocktick", self.OnClockTick, TheWorld)
	self.inst:StopWatchingWorldState("cycles", self.OnCycles)
	self.inst:StopWatchingWorldState("phase", self.OnPhase)
	self.inst:StopWatchingWorldState("moonphase", self.OnMoonPhase)
	self.inst:StopWatchingWorldState("season", self.OnSeason)
	self.inst:StopWatchingWorldState("seasonprogress", self.OnSeasonProgress)
	self.inst:StopWatchingWorldState("elapseddaysinseason", self.OnElapsedDaysInSeason)
	self.inst:StopWatchingWorldState("remainingdaysinseason", self.OnRemainingDaysInSeason)
	self.inst:StopWatchingWorldState("springlength", self.OnSpringLenght)
	self.inst:StopWatchingWorldState("summerlength", self.OnSummerLength)	
	self.inst:StopWatchingWorldState("autumnlength", self.OnAutumnLenght)
	self.inst:StopWatchingWorldState("winterlength", self.OnWinterLenght)
	self.inst:StopWatchingWorldState("issnowing", self.OnIsSnowing)
	self.inst:StopWatchingWorldState("israining", self.OnIsRaining)

	self.inst.entity:SetCanSleep(true)
end

return FAtiMABrain