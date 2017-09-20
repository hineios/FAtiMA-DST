Move = Class(BehaviourNode, function(self, inst, location)
   BehaviourNode._ctor(self, "Move")
   self.inst = inst
   self.location = location
end)

function Move:__tostring()
   return string.format("Move (%s)", self.location)
end