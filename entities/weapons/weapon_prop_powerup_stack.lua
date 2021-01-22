AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Stack"
SWEP.PrintName = "Stack"

SWEP.AbilityDescription = "Stack the Prop you're hold on top of you for better hiding."

function SWEP:Ability()
    if CLIENT then return end
    local ply = self:GetOwner()
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
        ply:GetPos().z + playerPropHBMax.z - propHBMin.z + 1
    ))
end