AddCSLuaFile()

SWEP.Base                  = "weapon_hunter_gun_base"

if CLIENT then
    SWEP.PrintName          = "TAUNT GRENADE"
    SWEP.Slot               = 3

    SWEP.ViewModelFlip      = false
    SWEP.ViewModelFOV       = 54
end

SWEP.WeaponIconKey         = "j" -- Bugbait
SWEP.HoldType              = "grenade"
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel            = "models/weapons/w_bugbait.mdl"

SWEP.Primary.Delay         = 1.5
SWEP.Primary.ClipSize      = 1
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.Ammo          = "AR2AltFire"
SWEP.Primary.Sound         = Sound( "WeaponFrag.Throw" )
SWEP.Primary.AutoReload    = true
SWEP.Primary.Anim          = ACT_VM_THROW
SWEP.Primary.EffectRange   = 300

SWEP.ReloadSound           = ""
SWEP.EmptySound            = ""

function SWEP:Throw()
    if CLIENT then return end

    local ent = ents.Create("prop_physics")
    local ply = self:GetOwner()
    ent:SetModel("models/weapons/w_bugbait.mdl")
    ent:SetOwner(ply)
    ent:SetPos(ply:EyePos() + (ply:GetAimVector() * 16))
    ent:Spawn()
    ent:SetMaterial("super_bouncy")
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetSolid(SOLID_BBOX)
    ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    util.SpriteTrail(ent, 0, Color(0, 255, 0), false, 16, 16, 0.5, 1 / (15 + 1) * 0.5, "trails/laser.vmt")

    local src = ply:GetShootPos()
    local target = ply:GetEyeTraceNoCursor().HitPos
    local tang = (target - src):Angle() -- A target angle to actually throw the grenade to the crosshair instead of fowards
    -- Makes the grenade go upgwards
    if tang.p < 90 then
        tang.p = -10 + tang.p * ((90 + 10) / 90)
    else
        tang.p = 360 - tang.p
        tang.p = -10 + tang.p * -((90 + 10) / 90)
    end
    tang.p = math.Clamp(tang.p, -90, 90) -- Makes the grenade not go backwards :/
    local vel = math.min(800, (90 - tang.p) * 6)
    local thr = tang:Forward() * vel + ply:GetVelocity()

    local entobj = ent:GetPhysicsObject()
    entobj:SetVelocity(thr)
    entobj:AddAngleVelocity(Vector(600, math.random(-1200, 1200), 0))

    timer.Simple(1, function()
        ent:Ignite(1, 0)
    end)

    timer.Simple(2, function()
        local explosion = ents.Create("env_explosion")
        explosion:SetPos(entobj:GetPos())
        explosion:SetOwner(ply)
        explosion:Spawn()
        explosion:SetKeyValue("iMagnitude", 0)
        explosion:SetKeyValue("DamageForce", 0)
        explosion:Fire("Explode", 0, 0)
        explosion:EmitSound("weapons/bugbait/bugbait_squeeze1.wav", 100, 100)

        for _, propPlayer in pairs(GetLivingPlayers(TEAM_PROPS)) do
            if (propPlayer:GetPos():DistToSqr(entobj:GetPos()) < self.Primary.EffectRange^2) then
                local taunt = RandomTaunt(propPlayer)
                local pitch = RandomPitch()
                SendTaunt(propPlayer, taunt, pitch)
            end
        end
        ent:Remove()
    end)
end

function SWEP:PrimaryAttack()
    self:PrimaryAttackWithFunction(function () self:Throw() end)
end
