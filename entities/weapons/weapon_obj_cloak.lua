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
        ply:GetProp():SetRenderMode( RENDERMODE_NONE )
        ply:GetProp():DrawShadow(false)
    end
end

function SWEP:AbilityCleanup()
    if not IsValid( self:GetOwner() ) then return end
    local ply = self:GetOwner()
    if SERVER then
        if (IsValid(ply:GetProp())) then
            ply:GetProp():SetRenderMode( RENDERMODE_NORMAL )
            ply:GetProp():DrawShadow(true)
        end
    end
end
