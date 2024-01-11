AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Recall"
SWEP.PrintName = "Recall"

SWEP.AbilityDescription = "Teleport back to a previously saved location and prop."

SWEP.AbilityCallWhenPrimed = true
SWEP.AbilityUsableBeforeHuntersReleaed = true

local ORB_SPEED = 800

function SWEP:Ability()
    if CLIENT then return end

    local ply = self:GetOwner();
    if !IsValid(ply) then return end

    if self:GetIsAbilityPrimed() then
        self:SetIsAbilityPrimed(false) -- Base sets AbilityUsed = true

        local orb_start_pos = ply:GetPos()
        local orb_end_pos = self.prevPos

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

        local orb = ents.Create("prop_combine_ball")
        if (IsValid(orb)) then
            --orb:SetModel( "models/Weapons/w_bugbait.mdl" )
            --orb:SetMaterial("Models/effects/splodearc_sheet")
            --orb:SetRenderMode(RENDERMODE_TRANSCOLOR)
            --orb:SetColor(Color(0, 0, 255, 255))
            orb:SetPos(orb_start_pos)
            orb:Spawn()
            orb:SetOwner(self:GetOwner())
            orb:SetSaveValue("m_flRadius", 6)
            orb:SetSaveValue("m_nState", 3)
            orb:SetSaveValue("m_nMaxBounces", 1)
            orb:SetSaveValue("m_nBounceCount", 1)
            orb:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
            local phys = orb:GetPhysicsObject()
            local orb_vel = orb_end_pos - orb_start_pos
            phys:SetVelocity(orb_vel:GetNormalized() * ORB_SPEED)
            local orb_timeout = orb_vel:Length() / ORB_SPEED * 1.05;
            timer.Simple(orb_timeout, function()
                orb:Remove()
            end)
        end

    else
        self:SetIsAbilityPrimed(true)

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