AddCSLuaFile()

SWEP.Base = "weapon_obj_base"
SWEP.Name = "Stack"
SWEP.PrintName = "Stack"

SWEP.AbilityDescription = "Stack the Prop you're hold on top of you for better hiding."

function SWEP:Ability()
    local ply = self:GetOwner()
    if SERVER then
        local prop = GetViewEntSv(ply)
        if !IsValid(prop) then
            return "Not looking at anything"
        end
        local _, playerPropHBMax = PropHitbox(ply)
        local propHBMin, _ = prop:GetHitBoxBounds(0, 0)
        prop:SetAngles(Angle(0, math.random(-180, 180), 0))
        prop:SetPos(Vector(
            ply:GetPos().x,
            ply:GetPos().y,
            ply:GetPos().z + playerPropHBMax.z - propHBMin.z
        ))
    end
end