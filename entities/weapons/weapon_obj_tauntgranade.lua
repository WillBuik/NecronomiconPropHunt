AddCSLuaFile()

SWEP.Name = "Taunt Grenade"
SWEP.PrintName = "Taunt Grenade"
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.Slot = 5
SWEP.SlotPos = 4

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = true

SWEP.HoldType = "grenade"
SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/v_bugbait.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"

SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "XBowBolt"
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 1.5

SWEP.AbilityRange = 300

SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Think()
end

function SWEP:Throw()
    if SERVER then
        local ent = ents.Create("prop_physics")
        ent:SetModel("models/weapons/w_bugbait.mdl")
        ent:SetOwner(self.Owner)
        ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 16))
        ent:Spawn()
        ent:SetMaterial("super_bouncy")
        ent:PhysicsInit(SOLID_VPHYSICS)
        ent:SetMoveType(MOVETYPE_VPHYSICS)
        ent:SetSolid(SOLID_BBOX)
        ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        util.SpriteTrail(ent, 0, Color(0,255,0), false, 16, 16, 0.5, 1/(15+1)*0.5, "trails/laser.vmt")

        local entobj = ent:GetPhysicsObject()
        entobj:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * self.Owner:GetEyeTrace().HitPos:Length() / 8)

        timer.Simple(1, function()
        ent:Ignite(1, 0)
        end )

        timer.Simple(2, function()
            local explosion = ents.Create("env_explosion")
            explosion:SetPos(entobj:GetPos())
            explosion:SetOwner(self.Owner)
            explosion:Spawn()
            explosion:SetKeyValue("iMagnitude", 0)
            explosion:SetKeyValue("DamageForce", 0)
            explosion:Fire("Explode", 0, 0)
            explosion:EmitSound("BaseGrenade.Explode", 75, 100)
            explosion:EmitSound("weapons/bugbait/bugbait_squeeze1.wav", 100, 100)

            for _,ply in pairs(team.GetPlayers(TEAM_PROPS)) do
                if (ply:Alive() and ply:GetPos():DistToSqr(entobj:GetPos()) < self.AbilityRange^2) then
                    local taunt = table.Random( PROP_TAUNTS )
                    local pRange = TAUNT_MAX_PITCH - TAUNT_MIN_PITCH
                    local pitch = math.random()*pRange + TAUNT_MIN_PITCH
                    SendTaunt(ply, taunt, pitch )
                end
            end
            ent:Remove()
        end )
    end
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	timer.Simple(1.5, function()
		if !self.Owner:Alive() or self:GetOwner():GetActiveWeapon():GetClass() ~= "weapon_obj_tauntgranade" then return end
		self:Reload()
		self:SendWeaponAnim(ACT_VM_DRAW)
	end )
	self:Throw()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self.Owner:DoAttackEvent()
	self:SendWeaponAnim(ACT_VM_THROW)
end

function SWEP:SecondaryAttack()
end
