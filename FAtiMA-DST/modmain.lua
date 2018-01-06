-- Debug Helpers
GLOBAL.CHEATS_ENABLED = true
GLOBAL.require 'debugkeys' 
GLOBAL.require 'debughelpers'

local ArtificalWalterEnabled = false

local function SetSelfAI()
	print("Enabling Artificial Walter")

	local brain = GLOBAL.require "brains/fatimabrain"
	GLOBAL.ThePlayer:SetBrain(brain)
	GLOBAL.ThePlayer:RestartBrain()
	
	ArtificalWalterEnabled = true

end

local function SetSelfNormal()
	print("Disabling Artifical Walter")
	
	local brain = GLOBAL.require "brains/wilsonbrain"
	GLOBAL.ThePlayer:SetBrain(brain)
	GLOBAL.ThePlayer:RestartBrain()

	ArtificalWalterEnabled = false
end

local function MakeClickableBrain(self, owner)

	local BrainBadge = self
	
    BrainBadge:SetClickable(true)

    -- Make the brain pulse for a cool effect
	local x = 0
	local darker = true
	local function BrainPulse(self)
		if not darker then
			x = x+.1
			if x >=1 then
				darker = true
				x = 1
			end
		else 
			x = x-.1
			if x <=.5 then
				darker = false
				x = .5
			end
		end

		BrainBadge.anim:GetAnimState():SetMultColour(x,x,x,1)
		self.BrainPulse = self:DoTaskInTime(.15, BrainPulse)
	end
	
	BrainBadge.OnMouseButton = function(self,button,down,x,y)	
		if down == true then
			if ArtificalWalterEnabled then
				self.owner.BrainPulse:Cancel()
				BrainBadge.anim:GetAnimState():SetMultColour(1,1,1,1)
				SetSelfNormal()
			else
				BrainPulse(self.owner)
				SetSelfAI()
			end
		end
	end
end

AddClassPostConstruct("widgets/sanitybadge", MakeClickableBrain)