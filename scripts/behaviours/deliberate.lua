Deliberate = Class(BehaviourNode, function(self, inst, server)
   BehaviourNode._ctor(self, "Deliberate")
   self.inst = inst
   self.FAtiMAServer = server or "http://localhost:8080/"
   self.HandleCallback = function(result, isSuccessful , http_code)
                           if isSuccessful and http_code == 200 then
                              self.status = READY
                              local resp = json.decode(result)
                              print(result)
                              for k,v in pairs(resp) do
                                 print(k,v)
                              end
                           end
                        end
end)

function Deliberate:QueryFAtiMA(data)
   TheSim:QueryServer(
      self.FAtiMAServer,
      self.HandleCallback,
      "POST",
      data)
end

function Deliberate:Visit()
   print("I visited deliberate")
   local data = json.encode({
      Name = "Joined",
      ID = "KU_TOPPOT",
      Time = 1234567890,
   })  
   if self.status == READY then
      self:QueryFAtiMA(data)
      self.status = SUCCESS
   end   
end