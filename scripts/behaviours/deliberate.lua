Deliberate = Class(BehaviourNode, function(self, inst, server)
   BehaviourNode._ctor(self, "Deliberate")
   self.inst = inst
   self.FAtiMAServer = server or "http://localhost:8080/"
   self.callbackfn = function(result, isSuccessful , http_code)
      self:HandleCallback(result, isSuccessful, http_code)
   end
end)

function Deliberate:__tostring()
   return string.format("Deliberate (%s)", self.FAtiMAServer)
end

function Deliberate:HandleCallback(result, isSuccessful, http_code)
   if isSuccessful and http_code == 200 then
      if self.inst.components.deliberator then
         self.inst.components.deliberator:SetNextAction(result)
         self.status = SUCCESS
         print(result)
      else
         print("No deliberator component. Something went terribly wrong")
         self.status = FAILED
      end
   else
      print("Couldn't Deliberate...")
      self.status = FAILED
   end
end

function Deliberate:QueryFAtiMA(data)
   TheSim:QueryServer(
      self.FAtiMAServer,
      self.callbackfn,
      "POST",
      data)
end

function Deliberate:Visit()
   if self.status == READY then
      self:QueryFAtiMA("GetActions")
      self.status = RUNNING
      print("I visited deliberate")
   end
end