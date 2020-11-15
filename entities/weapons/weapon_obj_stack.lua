AddCSLuaFile()

SWEP.Base = "weapon_obj_base"
SWEP.Name = "Stack"
SWEP.PrintName = "Stack"

SWEP.AbilityDescription = "Stack the Prop you're hold on top of you for better hiding."

function SWEP:Ability()
    local ply = self:GetOwner()
    if SERVER then
        local propHeld = ply:GetEntityInUse()
        if !IsValid(propHeld) then
            print("Invalid prop")
            return "Nothing held"
        end
        local _, playerPropHBMax = PropHitbox(ply)
        local heldPropHBMin, _ = propHeld:GetHitBoxBounds(0, 0)
        propHeld:SetAngles(Angle(0, math.random(-180, 180), 0))
        propHeld:SetPos(Vector(
            ply:GetPos().x,
            ply:GetPos().y,
            ply:GetPos().z + playerPropHBMax.z - heldPropHBMin.z
        ))
    end
end