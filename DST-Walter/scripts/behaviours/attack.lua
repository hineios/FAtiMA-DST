Attack = Class(BehaviourNode, function(self, inst, target)
   BehaviourNode._ctor(self, "Attack")
   self.inst = inst
   self.target = target
end)

function Attack:__tostring()
   return string.format("Attack %s", self.target)
end