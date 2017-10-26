Collect = Class(BehaviourNode, function(self, inst, target)
   BehaviourNode._ctor(self, "Collect")
   self.inst = inst
   self.target = target
end)

function Collect:__tostring()
   return string.format("Collect (%s)", self.target)
end