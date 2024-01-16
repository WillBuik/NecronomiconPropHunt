AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Go Limp"
SWEP.PrintName = "Go Limp"

SWEP.AbilityDescription = "Makes you prop behave acording to standard physics rules until disabled"

function SWEP:Ability()
    if CLIENT then return end

    local ply = self:GetOwner()
    ply:GetProp():SetRenderMode(RENDERMODE_NONE)
    ply:GetProp():DrawShadow(false)
    ply:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

    local phys_prop = ents.Create(ply:GetProp())
    phys_prop:SetAngles(ply:GetAngles())
    phys_prop:SetModel(ply:GetModel())
    phys_prop:SetPos(ply:GetPos())
    phys_prop:SetSkin(ply:GetSkin())
    phys_prop:SetColor(ply:GetColor())
    phys_prop:SetOwner(ply)
    phys_prop:Spawn()
    phys_prop:Activate()

    ply:Spectate(OBS_MODE_CHASE)
    ply:SpectateEntity(phys_prop)
    ply:SetParent(phys_prop)
end

function SWEP:AbilityCleanup()
    if CLIENT || !IsValid(self:GetOwner()) then return end

    local ply = self:GetOwner()

    if (IsValid(ply:GetProp())) then
        ply:GetProp():SetRenderMode(RENDERMODE_NORMAL)
        ply:GetProp():DrawShadow(true)
    end
    if (IsValid(ply:GetObserverTarget()) then
        phys_prop = ply:GetObserverTarget()
        ply:SetPos(phys_prop:GetPos())
        ply:SetAngles(phys_prop:GetAngles())
        phys_prop:Remove()
    end
    ply:UnSpectate()
    ply:SetCollisionGroup(COLLISION_GROUP_NONE)
    ply:SetParent()

    ResetPropToProp(ply)
end
