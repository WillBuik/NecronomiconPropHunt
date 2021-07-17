AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"

SWEP.Name = "Dummy SMG"
SWEP.PrintName = "Dummy SMG"

SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.ViewModel = "models/weapons/c_smg1.mdl"

SWEP.HoldType = "smg"

function SWEP:Ability()
    local ply = self:GetOwner()
    if SERVER then
        ply:StripWeapon("weapon_prop_util_smgdummy")
        player_manager.RunClass(ply, "SetModel")
        if (IsValid(ply:GetProp())) then
            ply:GetProp():SetRenderMode(RENDERMODE_NORMAL)
            ResetPropToProp(ply)
        end
        ply:SetRenderMode(RENDERMODE_NONE)
    end
end