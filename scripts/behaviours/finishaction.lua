FinishAction = Class(BehaviourNode, function(self, inst)
   BehaviourNode._ctor(self, "FinishAction")
   self.inst = inst
end)

function FinishAction:__tostring()
   return string.format("FinishAction (%s)")
end

function FinishAction:Visit()
   if self.status == READY and self.inst.components.deliberator then
      print("Finishing current action")
      self.inst.components.deliberator:FinishAction()
      self.status = SUCCESS
   end
end