Talk = Class(BehaviourNode, function(self, inst, target, message)
   BehaviourNode._ctor(self, "Talk")
   self.inst = inst
   self.target = target
   self.message = message
end)

function Talk:__tostring()
   return string.format("Talk (%s)", self.target)
end