Eat = Class(BehaviourNode, function(self, inst, item)
   BehaviourNode._ctor(self, "Eat")
   self.inst = inst
   self.item = item
end)

function Eat:__tostring()
   return string.format("Eat %s", self.item)
end