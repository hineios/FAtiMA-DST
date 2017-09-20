Craft = Class(BehaviourNode, function(self, inst, recipe)
   BehaviourNode._ctor(self, "Craft")
   self.inst = inst
   self.recipe = recipe

end)

function Craft:__tostring()
   return string.format("Craft (%s)", self.recipe)
end