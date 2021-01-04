AddCSLuaFile()

SWEP.Base = "weapon_common_base"

SWEP.Name = "Taunt Grenade"
SWEP.PrintName = "TAUNT GRENADE"
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.Slot = 3
SWEP.SlotPos = 4

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = true

SWEP.HoldType = "grenade"
SWEP.UseHands = true
SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"

SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 1.5
SWEP.Primary.AutoReload = true

SWEP.AbilityRange = 300

SWEP.Secondary.Ammo = "none"

SWEP.WeaponIconKey = "j" -- Bugbait

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Think()
end

function SWEP:Throw()
    if SERVER then
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

            local pRange = TAUNT_MAX_PITCH - TAUNT_MIN_PITCH
            for _, propPlayer in pairs(team.GetPlayers(TEAM_PROPS)) do
                if (propPlayer:Alive() and propPlayer:GetPos():DistToSqr(entobj:GetPos()) < self.AbilityRange^2) then
                    local taunt = table.Random(PROP_TAUNTS)
                    local pitch = math.random() * pRange + TAUNT_MIN_PITCH
                    SendTaunt(propPlayer, taunt, pitch)
                end
            end
            ent:Remove()
        end)
    end
end

function SWEP:PrimaryAttack()
    if !self:CanPrimaryAttack() then return end
    timer.Simple(1.5, function()
        if !self:GetOwner():Alive() or self:GetOwner():GetActiveWeapon():GetClass() != "weapon_obj_tauntgranade" then return end
        self:Reload()
        self:SendWeaponAnim(ACT_VM_DRAW)
    end)
    self:Throw()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)
    self:GetOwner():DoAttackEvent()
    self:SendWeaponAnim(ACT_VM_THROW)
end

function SWEP:SecondaryAttack()
end
