AddCSLuaFile()

SWEP.Base = "weapon_obj_base"
SWEP.Name = "Remove"
SWEP.PrintName = "Remove"

SWEP.AbilityDescription = "Removes the Prop you're looking at for better hiding."

function SWEP:Ability()
    local ply = self:GetOwner()
    local prop = getViewEnt( ply )
    if SERVER then
        prop:Remove()
    end
end

