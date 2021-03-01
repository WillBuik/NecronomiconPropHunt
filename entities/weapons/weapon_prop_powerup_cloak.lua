AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Cloak"
SWEP.PrintName = "Cloak"

SWEP.AbilityDuration = 7
SWEP.AbilityDescription = "Disappear almost completely for $AbilityDuration seconds."

function SWEP:Ability()
    if CLIENT then return end
    local ply = self:GetOwner()
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end)
    -- ply:GetProp():SetRenderMode(RENDERMODE_NONE)
    ply:GetProp():SetRenderMode( RENDERMODE_TRANSALPHA )
    ply:GetProp():Fire( "alpha", 4, 0 )
    ply:GetProp():DrawShadow(false)
end

function SWEP:AbilityCleanup()
    if CLIENT then return end
    if !IsValid(self:GetOwner()) then return end
    local ply = self:GetOwner()
    if (IsValid(ply:GetProp())) then
        ply:GetProp():SetRenderMode(RENDERMODE_NORMAL)
        ply:GetProp():Fire( "alpha", 255, 0 )
        ply:GetProp():DrawShadow(true)
    end
end
