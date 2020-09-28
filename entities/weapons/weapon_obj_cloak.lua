AddCSLuaFile()

SWEP.Base = "weapon_obj_base"
SWEP.Name = "Cloak"
SWEP.PrintName = "Cloak"

SWEP.AbilityDuration = 7
SWEP.AbilityDescription = "Disappear almost completely for $AbilityDuration seconds."

function SWEP:Ability()
    local ply = self:GetOwner()
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end )
    if SERVER then
        ply:GetProp():SetRenderMode( RENDERMODE_TRANSALPHA )
        ply:Fire( "alpha", 4, 0 )
    end
end

function SWEP:AbilityCleanup()
    if not IsValid( self:GetOwner() ) then return end
    local ply = self:GetOwner()
    ply:GetProp():SetRenderMode( RENDERMODE_NORMAL )
    if SERVER then
        ply:GetProp():SetRenderMode( RENDERMODE_NORMAL )
        ply:Fire( "alpha", 255, 0 )
    end
end
