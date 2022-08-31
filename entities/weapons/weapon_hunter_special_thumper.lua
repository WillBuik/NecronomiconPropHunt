AddCSLuaFile()

SWEP.Base                  = "weapon_hunter_gun_base"

if CLIENT then
    SWEP.PrintName          = "THUMPER"
    SWEP.Slot               = 3

    SWEP.ViewModelFlip      = false
    SWEP.ViewModelFOV       = 54
end

local EFFECT_RANGE = 250;
local EFFECT_TIME = 0.65;

local MIN_IMPULSE = 80;
local MAX_IMPULSE = 200;
local MAX_ANGLE = 10;

local AOE_RENDER_SEGMENTS = 30;

SWEP.WeaponIconKey         = "k" -- grenade
SWEP.HoldType              = "grenade"
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_grenade.mdl"
SWEP.WorldModel            = "models/weapons/w_grenade.mdl"

SWEP.Primary.Delay         = 1.5
SWEP.Primary.ClipSize      = 1
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.Ammo          = "AR2AltFire"
SWEP.Primary.Sound         = Sound( "WeaponFrag.Throw" )
SWEP.Primary.AutoReload    = true
SWEP.Primary.Anim          = ACT_VM_THROW
SWEP.Primary.EffectRange   = EFFECT_RANGE

SWEP.ReloadSound           = ""
SWEP.EmptySound            = ""

local THUMPER_AOE_NETMESSAGE = "weapon_hunter_special_thumper_aoe"

local last_aoe = {}

local function thumper_aoe_netsend(pos)
    net.Start(THUMPER_AOE_NETMESSAGE)
    net.WriteVector(pos)
    net.Broadcast()
    last_aoe[pos] = CurTime()
end

local function thumper_aoe_netrecv()
    local pos = net.ReadVector()
    last_aoe[pos] = CurTime()
end

local function jolt_props(centerPos, min_radius, max_radius)
    local min_radius_sq = min_radius ^ 2
    local max_radius_sq = max_radius ^ 2

    for _, ent in pairs(ents.GetAll()) do
        if  IsValid(ent) and
            table.HasValue(USABLE_PROP_ENTITIES, ent:GetClass()) and
            IsValid(ent:GetPhysicsObject()) and
            ent:GetClass() and
            ent:GetModel()
            then
            
            local dist_sq = centerPos:DistToSqr(ent:GetPos())
            if dist_sq >= min_radius_sq and dist_sq < max_radius_sq then
                local impulse = Vector(0, 0, math.random(MIN_IMPULSE, MAX_IMPULSE))
                local impulse_angle = Angle()
                impulse_angle:Random(-MAX_ANGLE, MAX_ANGLE)
                impulse:Rotate(impulse_angle)
                ent:GetPhysicsObject():SetVelocity(impulse)
            end
        end
    end
end

function SWEP:Throw()
    if CLIENT then return end

    local ent = ents.Create("prop_physics")
    local ply = self:GetOwner()
    ent:SetModel("models/weapons/w_grenade.mdl")
    ent:SetOwner(ply)
    ent:SetPos(ply:EyePos() + (ply:GetAimVector() * 16))
    ent:Spawn()
    ent:SetMaterial("super_bouncy")
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetSolid(SOLID_BBOX)
    ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    util.SpriteTrail(ent, 0, Color(0, 0, 255), false, 16, 16, 0.5, 1 / (15 + 1) * 0.5, "trails/laser.vmt")

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

    timer.Simple(1.0, function()
        ent:EmitSound("buttons/blip1.wav", 100, 100)
    end)
    timer.Simple(1.4, function()
        ent:EmitSound("buttons/blip1.wav", 100, 100)
    end)
    timer.Simple(1.8, function()
        ent:EmitSound("buttons/blip1.wav", 100, 100)
    end)

    timer.Simple(2.2, function()
        --local explosion = ents.Create("env_explosion")
        --explosion:SetPos(entobj:GetPos())
        --explosion:SetOwner(ply)
        --explosion:Spawn()
        --explosion:SetKeyValue("iMagnitude", 0)
        --explosion:SetKeyValue("DamageForce", 0)
        --explosion:Fire("Explode", 0, 0)
        --explosion:EmitSound("weapons/bugbait/bugbait_squeeze1.wav", 100, 100)

        ent:EmitSound("physics/body/body_medium_impact_hard3.wav", 100, 100)
        ent:EmitSound("physics/body/body_medium_impact_hard5.wav", 100, 100)
        ent:EmitSound("physics/body/body_medium_impact_hard1.wav", 100, 100)

        thumper_aoe_netsend(entobj:GetPos())

        --jolt_props(entobj:GetPos(), 0, self.Primary.EffectRange)

        ent:Remove()
    end)
end

function SWEP:PrimaryAttack()
    self:PrimaryAttackWithFunction(function () self:Throw() end)
end

-- Physics handling
if SERVER then
    local function thumper_push()
        for pos, start_time in pairs(last_aoe) do
            local dt = (CurTime() - start_time) / EFFECT_TIME
            local dt_next = (CurTime() + 0.02 - start_time) / EFFECT_TIME
            if dt <= 1.0 then
                local radius_min = Lerp(dt, 0, EFFECT_RANGE)
                local radius_max = Lerp(dt_next, 0, EFFECT_RANGE)
                jolt_props(pos, radius_min - 10, radius_max + 10)
            end
        end
    end
    timer.Create("thumper_push_timer", 0.02, 0, thumper_push)
end

-- Area of effect rendering.
hook.Add("PostDrawTranslucentRenderables", "thumper_draw_sphere", function()
    render.SetColorMaterial()

    for pos, start_time in pairs(last_aoe) do
        local dt = (CurTime() - start_time) / EFFECT_TIME
        if dt <= 1.0 then
            local radius = Lerp(dt, 0, EFFECT_RANGE)
            render.DrawSphere(pos, radius, AOE_RENDER_SEGMENTS, AOE_RENDER_SEGMENTS, Color(0, 80, 200, 60))
        end
    end
end)

-- Set up area of effect network messages.
if (SERVER) then
    util.AddNetworkString(THUMPER_AOE_NETMESSAGE)
else
    net.Receive(THUMPER_AOE_NETMESSAGE, thumper_aoe_netrecv)
end
