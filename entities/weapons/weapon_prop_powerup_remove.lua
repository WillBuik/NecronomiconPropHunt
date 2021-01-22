AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Remove"
SWEP.PrintName = "Remove"

SWEP.AbilityDescription = "Removes the Prop you're looking at for better hiding."

function SWEP:Ability()
    if CLIENT then return end
    local ply = self:GetOwner()
    local prop = GetViewEntSv(ply)
    if !IsValid(prop) then
        return "Not looking at anything"
    end
    prop:Remove()
end
