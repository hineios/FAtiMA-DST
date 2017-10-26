Exchange = Class(BehaviourNode, function(self, inst, target, item)
   BehaviourNode._ctor(self, "Exchange")
   self.inst = inst
   self.target = target
   self.item = item
   end
end)

function Exchange:__tostring()
   return string.format("Exchange %s with %s", self.item, self.target)
end