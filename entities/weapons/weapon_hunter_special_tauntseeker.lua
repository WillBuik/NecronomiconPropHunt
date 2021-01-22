AddCSLuaFile()

SWEP.Base                   = "weapon_hunter_gun_base"

if CLIENT then
    SWEP.PrintName          = "TAUNT SEEKER"
    SWEP.Slot               = 3

    SWEP.ViewModelFlip      = false
    SWEP.ViewModelFOV       = 54
end

SWEP.HoldType              = "ar2"
SWEP.WeaponIconKey         = "l" -- Granade round launcher
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_irifle.mdl"
SWEP.WorldModel            = "models/weapons/w_irifle.mdl"

SWEP.Primary.Recoil        = 6
SWEP.Primary.Delay         = 1.5
SWEP.Primary.ClipSize      = 1
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.Ammo          = "AR2AltFire"
SWEP.Primary.Sound         = Sound( "Weapon_AR2.Special1" )
SWEP.Primary.AutoReload    = true
SWEP.Primary.Anim          = ACT_VM_SECONDARYATTACK
SWEP.Primary.Accuracy      = 70

function SWEP:FireBall(closestPropTaunting)
    if !SERVER then return end

    local posToShoot = closestPropTaunting:GetPos()

    -- A little uncertaintity
    posToShoot:Add(Vector(
        math.random(-self.Primary.Accuracy, self.Primary.Accuracy),
        math.random(-self.Primary.Accuracy, self.Primary.Accuracy),
        0
    ))

    local forward = self:GetOwner():EyeAngles():Forward()

    local ent = ents.Create("prop_combine_ball")
    if (IsValid(ent)) then
        ent:SetPos(self:GetOwner():GetShootPos() + forward * 32)
        ent:SetAngles(self:GetOwner():EyeAngles())
        posToShoot:Sub(self:GetOwner():GetShootPos())
        ent:Spawn()
        ent:SetOwner(self:GetOwner())
        ent:SetSaveValue("m_flRadius", 12)
        ent:SetSaveValue("m_nState", 3)
        ent:SetSaveValue("m_nMaxBounces", 1)
        ent:SetSaveValue("m_nBounceCount", 1)
        ent:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        local phys = ent:GetPhysicsObject()
        phys:SetVelocity(posToShoot:GetNormalized() * 50)
        timer.Simple(3, function()
            ent:Remove()
        end)
    end

end

function SWEP:PrimaryAttack()
    local closestPropTaunting = GetClosestTaunter(self:GetOwner())
    if !closestPropTaunting then return end
    self:PrimaryAttackWithFunction(function () self:FireBall(closestPropTaunting) end)
end
