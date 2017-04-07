require "behaviours/decide"

local WalterBrain = Class(Brain, function(self, inst, server)
    Brain._ctor(self, inst)
    self.inst = inst

    self.FAtiMAServer = (server and server .. "percept") or "http://localhost:8080/percept"

    self.callbackfn = function(result, isSuccessful , http_code)
        self:HandleCallback(result, isSuccessful, http_code)
    end

    self.onkilledfn = function (inst, data)
        --print(inst.name, "Killed", data.victim.name)
        self:OnEvent(inst.name, "Killed", data.victim, "actionend")
    end

    self.onattackfn = function (inst, data)
        --print(inst.name, "Attacked", data.target.name)
        self:OnEvent(inst.name, "Attacked", data.target, "actionend")
    end
end)

function WalterBrain:OnStart()
    self.inst:ListenForEvent("killed", self.onkilledfn)
    self.inst:ListenForEvent("onattackother", self.onattackfn)
    self.inst:ListenForEvent("onmissother", self.onattackfn)

	--self.inst:AddComponent("deliberator")
    local root = 
        PriorityNode(
        {
            ParallelNode(
            {
                PriorityNode({Decide(self.inst)}, 2),
                Wander(self.inst, nil, 10)
            }, "Wander and Decide Actions")
        }, 5)


    -- local root = 
    --     PriorityNode(
    --     {
    --         ParallelNode(
    --         {
    --             IfNode(function () if self.inst.components.deliberator and self.inst.components.deliberator:HasNextAction() then print("brain" .. self.inst.components.deliberator:HasNextAction()) return self.inst.components.deliberator:GetNextAction() == "Wander" end end, "WanderIfNextAction", Wander(self.inst, nil, 10)),
    --             PriorityNode({Deliberate(self.inst)}, 5)
                
    --         }, "TRy everything!")
    --     }, .5)
        


    self.bt = BT(self.inst, root)

end

function WalterBrain:OnStop()
    --self.inst:RemoveComponent("deliberator")
    self.inst:RemoveEventCallback("killed", self.onkilledfn)
    self.inst:RemoveEventCallback("onattackother", self.onattackfn)
    self.inst:RemoveEventCallback("onmissother", self.onattackfn)
end

function WalterBrain:HandleCallback(result, isSuccessful, http_code)
    -- if isSuccessful and http_code == 200 then
    --  print(result)
    -- else
    --  print("Couldn't Appraise Perceptions")
    -- end
end

function WalterBrain:QueryFAtiMA(data)
    print(data)
    TheSim:QueryServer(
        self.FAtiMAServer,
        self.callbackfn,
        "POST",
        data)
end

function WalterBrain:OnEvent(actor, event, target, type)
    local data = {}
    data["subject"] = actor
    data["actionName"] = event
    data["target"] = target.name
    data["type"] = type

    self:QueryFAtiMA(json.encode(data))
end

return WalterBrain