Build = Class(BehaviourNode, function(self, inst, recipe, location)
   BehaviourNode._ctor(self, "Build")
   self.inst = inst
   self.recipe = recipe
   self.location = location
   end
end)

function Build:__tostring()
   return string.format("Build %s in %s", self.recipe, self.location)
end