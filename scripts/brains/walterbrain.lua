local SEE_DIST = 20
local SEE_RANGE_HELPER = false

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

local function See()
    local x, y, z = inst.Transform:GetWorldPosition()
    local TAGS = nil
    local EXCLUDE_TAGS = {"INLIMBO"}
    local ONE_OF_TAGS = nil
    local ents = TheSim:FindEntities(x, y, z, SEE_DIST, TAGS, EXCLUDE_TAGS, ONE_OF_TAGS)
    
    local data = {}
    local j = 0;
    for i, v in ipairs(ents) do
        local d = {}
        d.GUID = v.GUID
        d.prefab = v.prefab
        d.name = v.name
        data[j] = d
        j = j+1;
    end

    return data
end

local function Inventory()
    local data = {}
    local j = 0;
    for i, v in ipairs(ents) do
        local d = {}
        d.GUID = v.GUID
        d.prefab = v.prefab
        d.name = v.name
        data[j] = d
        j = j+1;
    end

    return data
end

local function Perceptions(inst, FAtiMAServer, callbackfn)
    local data = {}
    data.see = See()
    data.inventory = Inventory()

    TheSim:QueryServer(
        FAtiMAServer .. "percept",
        callbackfn,
        "POST",
        json.encode(data))
    end

local WalterBrain = Class(Brain, function(self, inst, server)
    Brain._ctor(self, inst)
    self.inst = inst

    ------------------------------
    ---- FAtiMA Communication ----
    ------------------------------
    self.FAtiMAServer = (server and server .. "percept") or "http://localhost:8080/"
    self.callbackfn = function(result, isSuccessful , http_code)
        self:HandleCallback(result, isSuccessful, http_code)
    end
end)

function WalterBrain:HandleCallback(result, isSuccessful, http_code)

end

-- local x, y, z = ThePlayer().Transform:GetWorldPosition()
-- local ents = TheSim:FindEntities(x, y, z, 20, nil, {"INLIMBO"}, nil)
-- for k, v in pairs(ents) do print(k); for i, g in pairs(v) do print("    ", i, g)

function WalterBrain:OnStart()
    -----------------------
    ----- Range Helper ----
    -----------------------
    AddSeeRangeHelper(self.inst)

    -----------------------
    ----- Perceptions -----
    -----------------------
    if self.task ~= nil then
        self.task:Cancel()
    end
    -- DoPeriodicTask(interval, fn, initialdelay, ...)
    self.task = self.inst:DoPeriodicTask(1, Perceptions, 0, self.FAtiMAServer, self.callbackfn)

    -----------------------
    -------- Brain --------
    -----------------------
    -- local root = 
    --     PriorityNode(
    --     {
    --         -- WhileNode(function() return not self.inst.components.deliberator:HasNextAction() end, "Decide?", 
    --         --     Decide(self.inst)),
    --         -- DoAction(self.inst, EatFoodAction, "Eat Food"),

    --     }, 1)

    -- self.bt = BT(self.inst, root)
end

function WalterBrain:OnStop()
    -----------------------
    ----- Perceptions -----
    -----------------------
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end

    -----------------------
    ----- Range Helper ----
    -----------------------
    if SEE_RANGE_HELPER then
        self.inst.seerangehelper:Remove()
        self.inst.seerangehelper = nil
    end
end



function WalterBrain:OnEvent(actor, event, target, type)
    local data = {}
    data["subject"] = actor
    data["actionName"] = event
    data["target"] = target.name
    data["type"] = type

    TheSim:QueryServer(
        self.FAtiMAServer,
        self.callbackfn,
        "POST",
        json.encode(data))
end

return WalterBrain