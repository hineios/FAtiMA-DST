require "behaviours/decide"

local SEE_DIST = 20

local assets =
{
    Asset("ANIM", "anim/firefighter_placement.zip"),
}

local function AddSeeRangeIndicator(inst)
    if inst.helper == nil then
        inst.helper = CreateEntity()

        --[[Non-networked entity]]
        inst.helper.entity:SetCanSleep(false)
        inst.helper.persists = false

        inst.helper.entity:AddTransform()
        inst.helper.entity:AddAnimState()

        inst.helper:AddTag("CLASSIFIED")
        inst.helper:AddTag("NOCLICK")
        inst.helper:AddTag("placer")

        inst.helper.Transform:SetScale(SEE_DIST/10, SEE_DIST/10, SEE_DIST/10)

        inst.helper.AnimState:SetBank("firefighter_placement")
        inst.helper.AnimState:SetBuild("firefighter_placement")
        inst.helper.AnimState:PlayAnimation("idle")
        inst.helper.AnimState:SetLightOverride(1)
        inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.helper.AnimState:SetSortOrder(1)
        inst.helper.AnimState:SetAddColour(0, .2, .5, 0)

        inst.helper.entity:SetParent(inst.entity)

        local x, y, z = inst.Transform:GetWorldPosition()
        local TAGS = nil
        local EXCLUDE_TAGS = {"INLIMBO"}
        local ONE_OF_TAGS = nil
        local ents = TheSim:FindEntities(x, y, z, SEE_DIST, TAGS, EXCLUDE_TAGS, ONE_OF_TAGS)
        for i, v in ipairs(ents) do
            
                print(v)
            
        end
    end
end

-- local function EatFoodAction(inst)
--     local target = FindEntity(inst, SEE_DIST, nil, { "edible_MEAT" })
    
--     if target ~= nil then
--         local act = BufferedAction(inst, target, ACTIONS.EAT)
--         act.validfn = function() return target.components.inventoryitem == nil or target.components.inventoryitem.owner == nil or target.components.inventoryitem.owner == inst end
--         return act
--     end
-- end

-- local function PickItemAction(inst)
--     local t = inst.components.deliberator:GetCurrentAction().target
--     print(t)

--     local target = FindEntity(inst, SEE_DIST, nil, { t })

--     if target ~= nil then
--         local act = BufferedAction(inst, target, ACTIONS.PICKUP)
--         act.validfn = function() return target.components.inventoryitem == nil or target.components.inventoryitem.owner == nil or target.components.inventoryitem.owner == inst end
--         return act
--     end
-- end

local function SeeFunction(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local TAGS = nil
    local EXCLUDE_TAGS = {"INLIMBO"}
    local ONE_OF_TAGS = nil
    local ents = TheSim:FindEntities(x, y, z, SEE_DIST, TAGS, EXCLUDE_TAGS, ONE_OF_TAGS)
    for i, v in ipairs(ents) do
        print(v)
        
    end
end

local WalterBrain = Class(Brain, function(self, inst, server)
    Brain._ctor(self, inst)
    self.inst = inst


    -- 
    -- Perceptions
    --
    self.FAtiMAServer = (server and server .. "percept") or "http://localhost:8080/percept"
    self.callbackfn = function(result, isSuccessful , http_code)
        self:HandleCallback(result, isSuccessful, http_code)
    end
end)

function WalterBrain:OnStart()
	self.inst:AddComponent("deliberator")
    
    --AddSeeRangeIndicator(self.inst)

    self.inst:DoPeriodicTask(1, SeeFunction, self.inst)



    -----------------
    ----- Brain -----
    -----------------
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
    self.inst:RemoveComponent("deliberator")

    --self.inst.helper:Remove()
    --self.inst.helper = nil
end

function WalterBrain:HandleCallback(result, isSuccessful, http_code)

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