AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Enable Friendly Fire"
SWEP.PrintName = SWEP.Name

SWEP.AbilityDuration = FRIENDLY_FIRE_ABILITY_DURATION
SWEP.AbilityDescription = "All hunters will suffer friendly fire for $AbilityDuration seconds."


function SWEP:Ability()
    if SERVER then
        local ply = self:GetOwner()
        ply:PrintMessage(HUD_PRINTTALK, "Hunters will suffer friendly fire for the next " .. self.AbilityDuration .. " seconds")
        EnableHunterFriendlyFire(ply)
        self:AbilityTimer(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end)
    end
end

function SWEP:AbilityCleanup()
    if SERVER then
        DisableHunterFriendlyFire(self:GetOwner())
    end
end
