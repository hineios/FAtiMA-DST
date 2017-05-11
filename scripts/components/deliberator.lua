-- List Helpers
List = {}

function List:Create ()
	local l = {}
	l.first = 0
	l.last = -1


	function l:PushLeft(value)
		local first = l.first - 1
		l.first = first
		l[first] = value
	end

	function l:PushRight(value)
		local last = l.last + 1
		l.last = last
		l[last] = value
	end

	function l:PopLeft()
		local first = l.first
		if first > l.last then error("list is empty") end
		local value = l[first]
		l[first] = nil        -- to allow garbage collection
		l.first = first + 1
		return value
	end

	function l:PopRight()
		local last = l.last
		if l.first > last then error("list is empty") end
		local value = l[last]
		l[last] = nil         -- to allow garbage collection
		l.last = last - 1
		return value
	end

	function l:IsEmpty()
		return l.first > l.last
	end

	return l
end


local Deliberator = Class(function(self, inst)
	self.currentaction = nil
	self.actionlist = nil
end)

function Deliberator:HasNextAction()
	return self.actionlist and not self.actionlist:IsEmpty()
end

function Deliberator:SetActions(actions)
	local l = List:Create()

	for i, v in ipairs(actions) do
		print("deliberator", v.actionName, v.target)
		l.PushRight(v)
	end
	
	self.actionlist = l
	self.currentaction = nil
end

function Deliberator:GetNextAction()
	if self.actionlist and not self.actionlist:IsEmpty() then
		self.currentaction = self.actionlist:PopLeft()
		return self.currentaction
	end
	return nil
end

function Deliberator:FinishAction()
	self.currentaction = nil
end

function Deliberator:CurrentAction()
	return self.currentaction
end

return Deliberator