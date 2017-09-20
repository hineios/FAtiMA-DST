Cook = Class(BehaviourNode, function(self, inst, recipe)
   BehaviourNode._ctor(self, "Cook")
   self.inst = inst
   self.recipe = recipe
end)

function Cook:__tostring()
   return string.format("Cook (%s)", self.recipe)
end