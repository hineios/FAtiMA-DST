-- Debug Helpers
GLOBAL.CHEATS_ENABLED = true
GLOBAL.require 'debugkeys' 
GLOBAL.require 'debughelpers'

local ArtificalWalterEnabled = false

local function SetSelfAI()
	local brain = GLOBAL.require "brains/fatimabrain"
	GLOBAL.ThePlayer:SetBrain(brain)
	GLOBAL.ThePlayer:RestartBrain()
	ArtificalWalterEnabled = true
end

local function SetSelfNormal()
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
		if down == true and GLOBAL.TheWorld.ismastersim then
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

local function FindPortal()
	local ents = GLOBAL.TheSim:FindEntities(0, 0, 0, 10000, {"antlion_sinkhole_blocker"}) 
    for i, v in ipairs(ents) do
        if v.entity:IsVisible() and v.prefab == "multiplayer_portal" then
            return v
        end
    end
end

AddSimPostInit(function ()
	if GLOBAL.TheWorld.ismastersim and GetModConfigData('fatima-character-num') > 0 then 

		-- Find the Portal
		local portal = FindPortal()

		-- Spawn the characters required in the mod config
		local i = 0
		while i < GetModConfigData("fatima-character-num") do
			local char = GLOBAL.SpawnPrefab("wilson")

			char:AddTag("FAtiMA-Brain")
		
			-- Move Spawned characters near the portal
			char.Transform:SetPosition(portal.Transform:GetWorldPosition())

			local brain = GLOBAL.require "brains/fatimabrain"
			char:SetBrain(brain)
			char:RestartBrain()
			i = i + 1
		end

	end
end)
