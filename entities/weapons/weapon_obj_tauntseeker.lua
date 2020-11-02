AddCSLuaFile()

SWEP.Name = "Taunt Seeker"
SWEP.PrintName = "TAUNT SEEKER"
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.Slot = 4
SWEP.SlotPos = 5

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = true

SWEP.HoldType = "ar2"
SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"

SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 1.5

SWEP.AbilityAccuracy = 50

SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Think()
end

function SWEP:FireBall()
    if CLIENT then return end

    local props = team.GetPlayers(TEAM_PROPS)
    local closestPropTaunting = GetClosestTaunter(self.Owner)

    local posToShoot = Vector(0,0,0)
    if closestPropTaunting != nil then
        posToShoot = closestPropTaunting:GetPos()
    end

    -- A little uncertaintity
    posToShoot:Add(Vector(
        math.random(-self.AbilityAccuracy, self.AbilityAccuracy),
        math.random(-self.AbilityAccuracy, self.AbilityAccuracy),
        0
  ))

    local forward = self.Owner:EyeAngles():Forward()

    local ent = ents.Create("prop_combine_ball")
    if (IsValid(ent)) then
        ent:SetPos(self.Owner:GetShootPos() + forward * 32)
        ent:SetAngles(self.Owner:EyeAngles())
        posToShoot:Sub(self.Owner:GetShootPos())
        ent:Spawn()
        ent:SetOwner(self.Owner)
        ent:SetSaveValue("m_flRadius", 12)
        ent:SetSaveValue("m_nState", 3)
        ent:SetSaveValue("m_nMaxBounces", 1)
        ent:SetSaveValue("m_nBounceCount", 1)
        local phys = ent:GetPhysicsObject()
        phys:SetVelocity(posToShoot:GetNormalized() * 10)
        timer.Simple(1, function()
            ent:Remove()
        end)
    end

end

function SWEP:PrimaryAttack()
    if !self:CanPrimaryAttack() then return end
    timer.Simple(1.5, function()
        if !self.Owner:Alive() or self:GetOwner():GetActiveWeapon():GetClass() != "weapon_obj_tauntseeker" then return end
        self:Reload()
        self:SendWeaponAnim(ACT_VM_DRAW)
    end)
    self:FireBall()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)
    self.Owner:DoAttackEvent()
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
end

function SWEP:SecondaryAttack()
end
