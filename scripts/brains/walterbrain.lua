require "behaviours/deliberate"

local WalterBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function WalterBrain:OnStart()
	self.inst:AddComponent("deliberator")
    local root = PriorityNode({Deliberate(self.inst)}, 5)
    -- {
    -- 	SequenceNode{
    -- 		Wander(self.inst, nil, 10),
    -- 		Deliberate(self.inst),
    -- 	}
    -- }, 1)
    local times =
    {
        minwalktime = 2,
        randwalktime = 3,
        minwaittime = 1,
        randwaittime = 3,
    }

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
    self.inst:RemoveComponent("deliberator")
end

return WalterBrain