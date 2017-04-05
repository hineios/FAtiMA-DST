local Deliberator = Class(function(self, inst)
	self.nextaction = nil
end)

function Deliberator:HasNextAction()
	return self.nextaction
end

function Deliberator:SetNextAction(action)
	self.nextaction = action
end

function Deliberator:GetNextAction(action)
	local a = self.nextaction
	self.nextaction = nil
	return a
end

return Deliberator