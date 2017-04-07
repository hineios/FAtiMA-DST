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
      --print("Decided " .. result)
      -- if self.inst.components.deliberator then
      --    self.inst.components.deliberator:SetNextAction(result)
          self.status = SUCCESS
      --    --print(result)
      -- else
      --    --print("No deliberator component. Something went terribly wrong")
      --    self.status = FAILED
      -- end
   else
      --print("Couldn't Decide...")
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
   if self.status == READY then
      self:QueryFAtiMA()
      self.status = RUNNING
      --print("I visited Decide")
   end
end