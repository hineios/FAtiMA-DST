Decide = Class(BehaviourNode, function(self, inst, server)
   BehaviourNode._ctor(self, "Decide")
   self.inst = inst
   self.FAtiMAServer = (server and server .. "decide") or "http://localhost:8080/decide"

   self.callbackfn = function(result, isSuccessful , http_code)
      self:HandleCallback(result, isSuccessful, http_code)
   end
end)

function Decide:__tostring()
   return string.format("Decide (%s)", self.FAtiMAServer)
end

function Decide:HandleCallback(result, isSuccessful, http_code)
   if isSuccessful and http_code == 200 then
      if self.inst.components.deliberator then
         self.inst.components.deliberator:SetNextAction(result)
         self.status = SUCCESS
      else
         self.status = FAILED
      end
   else
      self.status = FAILED
   end
end

function Decide:QueryFAtiMA()
   TheSim:QueryServer(
      self.FAtiMAServer,
      self.callbackfn,
      "POST")
end

function Decide:Visit()
   if self.status == READY and self.inst.components.deliberator and not self.inst.components.deliberator:HasNextAction() then
      self:QueryFAtiMA()
      self.status = RUNNING
   end
end