AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Gun"
SWEP.PrintName = "Gun"

SWEP.AbilityDuration = 10
SWEP.AbilityDescription = "Get a gun for $AbilityDuration seconds."

local WEAPON_TO_GIVE = "weapon_hunter_gun_smg"
local AMMO_TYPE = "SMG1"
local AMMO_AMOUNT = 500

function SWEP:Ability()
    if CLIENT then return end
    local ply = self:GetOwner()
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanupOnce() end)
    ply:Give(WEAPON_TO_GIVE)
    ply:SetAmmo(AMMO_AMOUNT, AMMO_TYPE)
    ply:SelectWeapon(WEAPON_TO_GIVE)

    -- Set up rendering so that the gun is visible, but not the player's model.
    -- (Reminder: the player's model is always human, even if the player is a
    -- prop.  It is usually hidden with RENDERMODE_NONE.)
    ply:Fire("alpha", 0, 0)
    ply:DrawShadow(false)
    ply:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function SWEP:AbilityCleanup()
    if CLIENT then return end
    local ply = self:GetOwner()
    if IsValid(ply) then
        ply:RemoveAllAmmo()
        ply:StripWeapon(WEAPON_TO_GIVE)
        ply:SetRenderMode(RENDERMODE_NONE)
        ply:Fire("alpha", 255, 0)
        ply:DrawShadow(true)
    end
end
