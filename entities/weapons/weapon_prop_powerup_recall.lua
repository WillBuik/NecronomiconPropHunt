AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Recall"
SWEP.PrintName = "Recall"

SWEP.AbilityDescription = "Teleport back to a previously saved location and prop."

SWEP.AbilityCallWhenPrimed = true
SWEP.AbilityUsableBeforeHuntersReleaed = true

local ORB_SPEED = 800

function SWEP:spawn_recall_effect(start_pos, end_pos)
    local target_end = ents.Create("info_target")
    target_end:SetName("target" .. self:EntIndex() .. "2")
    target_end:SetPos(end_pos)

    local orb = ents.Create("prop_combine_ball")
    orb:SetName("target" .. self:EntIndex() .. "")
    orb:SetPos(start_pos)
    orb:Spawn()
    orb:SetOwner(self:GetOwner())
    orb:SetSaveValue("m_flRadius", 6)
    orb:SetSaveValue("m_nState", 3)
    orb:SetSaveValue("m_nMaxBounces", 1)
    orb:SetSaveValue("m_nBounceCount", 1)
    orb:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    local phys = orb:GetPhysicsObject()
    local orb_vel = end_pos - start_pos
    phys:SetVelocity(orb_vel:GetNormalized() * ORB_SPEED)
    local orb_timeout = orb_vel:Length() / ORB_SPEED;

    local beam = ents.Create("env_beam")
    beam:SetPos(self:GetPos())
    beam:SetKeyValue("spawnflags", "1")
    beam:SetKeyValue("rendercolor", "255 210 0")
    beam:SetKeyValue("texture", "sprites/laserbeam.spr")
    beam:SetKeyValue("BoltWidth", "3")
    beam:SetKeyValue("Damage", "0")
    beam:SetKeyValue("NoiseAmplitude", "0.2")
    beam:SetKeyValue("LightningStart", "" .. orb:GetName() .. "")
    beam:SetKeyValue("LightningEnd", "" .. target_end:GetName() .. "")
    beam:Spawn()
    beam:Activate()
    beam:Fire("Alpha","50",0)

    timer.Simple(orb_timeout, function()
        orb:Remove()
        beam:Remove()
        target_end:Remove()
    end)
end

function SWEP:Ability()
    if CLIENT then return end

    local ply = self:GetOwner();
    if !IsValid(ply) then return end

    if self:GetIsAbilityPrimed() then
        self:SetIsAbilityPrimed(false) -- Base sets AbilityUsed = true

        PropHitbox(ply)

        local beam_start_pos = PropCenterMass(ply)
        local beam_end_pos = self.prev_center_mass

        ply:SetVelocity(ply:GetVelocity():GetNegated()) -- Zero player velocity before recall

        ply.prevPropModel = self.prevPropModel
        ply.prevPropSkin = self.prevPropSkin
        ply.prevPropMass = self.prevPropMass
        ply.prevPropVMesh = self.prevPropVMesh
        ply.prevPropScale = self.prevPropScale
        ply.prevPos = self.prevPos
        ply.prevAngle = self.prevAngle
        ply.prevLockedAngle = self.prevLockedAngle
        ply.prevRollAngle = self.prevRollAngle
        SetPlayerProp(ply, ply:GetProp(), ply:GetProp():GetModelScale(), true)

        self:spawn_recall_effect(beam_start_pos, beam_end_pos)

    else
        self:SetIsAbilityPrimed(true)

        self.prev_center_mass = PropCenterMass(ply)

        local prop = ply:GetProp()
        self.prevPropModel = prop:GetModel()
        self.prevPropSkin = prop:GetSkin()
        self.prevPropMass = ply:GetPhysicsObject():GetMass()
        self.prevPropVMesh = ply:GetPhysicsObject():GetMeshConvexes()
        self.prevPropScale = prop:GetModelScale()
        self.prevPos = ply:GetPos()
        self.prevAngle = ply:GetAngles()
        self.prevLockedAngle = ply:GetPropLockedAngle()
        self.prevRollAngle = ply:GetPropRollAngle()

        self:GetOwner():PrintMessage(HUD_PRINTCENTER, "Location and prop saved, right-click again to recall.")
    end
end