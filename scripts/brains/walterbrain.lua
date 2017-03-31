require "behaviours/deliberate"

local WalterBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function WalterBrain:OnStart()
	--self.inst:AddComponent("deliberator")
    local root = PriorityNode({Deliberate(self.inst)}, 5)
    -- {
    -- 	SequenceNode{
    -- 		Wander(self.inst, nil, 10),
    -- 		Deliberate(self.inst),
    -- 	}
    -- }, 1)
    

    self.bt = BT(self.inst, root)

end

return WalterBrain