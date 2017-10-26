Decide = Class(BehaviourNode, function(self, inst, server)
   BehaviourNode._ctor(self, "Decide")
   self.inst = inst

   self.running = false
   self.FAtiMAServer = (server and server .. "decide") or "http://localhost:8080/decide"

   self.callbackfn = function(result, isSuccessful , http_code)
      if isSuccessful and http_code == 200 then
          if self.inst.components.deliberator then
             self.inst.components.deliberator:SetActions(json.decode(result))
             self.status = SUCCESS
          else
             self.status = FAILED
          end
      else
          self.status = FAILED
      end
   end
end)

function Decide:__tostring()
   return string.format("Decide (%s)", self.FAtiMAServer)
end

function Decide:QueryFAtiMA()
   TheSim:QueryServer(
      self.FAtiMAServer,
      self.callbackfn,
      "POST")
end

function Decide:Visit()
   if self.status == READY then
      self:QueryFAtiMA()
      self.status = RUNNING
   end
end