-- 
-- List Helpers
--
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
		--print("IsEmpty?", l.first > l.last)
		return l.first > l.last
	end

	return l
end

--- The deliberator works has follows:
---   a list of actions is saved in actionslist
---   the current executing action is saved in currentaction
---   while theres is an action in currentaction the deliberator does not pass a new action
---   only when the action has finished and the value of currentaction is set to nil does the deliberator return a new action
---   the exception occurs when there is a list of new actions from FAtiMA which causes the currentaction to be discarded.

local Deliberator = Class(function(self, inst)
    self.inst = inst

	self.currentaction = nil
	self.actionslist = List:Create()
end)

function Deliberator:HasNextAction()
	return self.actionslist and not self.actionslist:IsEmpty()
end

function Deliberator:HasAction()
    return self.currentaction
end

function Deliberator:ClearActions()
	self.actionslist = List:Create()
	self.currentaction = nil
end

function Deliberator:SetActions(actions)
	local l = List:Create()
	for i, v in pairs(actions) do
		l:PushRight(v)
	end
	
	self.actionslist = l
	self.currentaction = nil
end

function Deliberator:GetNextAction()
    if self.actionslist and (not self.actionslist:IsEmpty()) and self.currentaction == nil then
		self.currentaction = self.actionslist:PopLeft()
        --print("GetNextAction", self.currentaction)
		return self.currentaction
	else
        --print("GetNextAction", self.currentaction)
        return self.currentaction
    end
end

function Deliberator:FinishAction()
	self.currentaction = nil
end

function Deliberator:GetCurrentAction()
	return self.currentaction
end

return Deliberator