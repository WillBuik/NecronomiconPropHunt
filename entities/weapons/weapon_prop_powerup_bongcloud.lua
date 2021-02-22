AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Bongcloud"
SWEP.PrintName = "Bongcloud"

SWEP.AbilityDuration = 8
SWEP.AbilityEmits = 4
SWEP.AbilityRadius = 20
SWEP.AbilityDescription = "Create clouds of smoke at your location for $AbilityDuration seconds."

-- The only thing we need to do to make this SWEP work is have it create smoking ents, like we do for blastoff, so that it shows up on clients
function SWEP:Ability()
    if CLIENT then return end
    self:CreateSmoke()
    self:AbilityTimerIfValidOwner(self.AbilityDuration / (self.AbilityEmits - 1), self.AbilityEmits - 1, true, function() self:CreateSmoke() end)
end

function SWEP:CreateSmoke()
    for _,v in player.GetAll() do
        net.Start("Bong Smokecloud")
            net.WriteVector(self:GetOwner():GetPos())
            net.ReadUInt(self.AbilityRadius, 16)
        net.Send(v)
    end
end

if CLIENT then
    net.Receive("Bong Smokecloud", function(len , ply)
        local center = net.ReadVector()
        local radius = net.ReadUInt(16)
        local em = ParticleEmitter(center)

        local smokeparticles = {
            Model("particle/particle_smokegrenade"),
            Model("particle/particle_noisesphere")
         } 
        

        for i = 1, radius do
            local prpos = VectorRand() * radius
            prpos.z = prpos.z + 32
            local p = em:Add(table.Random(smokeparticles), center + prpos)
            if p then
                local gray = math.random(75, 200)
                p:SetColor(gray, gray, gray)
                p:SetStartAlpha(255)
                p:SetEndAlpha(200)
                p:SetVelocity(VectorRand() * math.Rand(900, 1300))
                p:SetLifeTime(0)
                
                p:SetDieTime(math.Rand(50, 70))

                p:SetStartSize(math.random(140, 150))
                p:SetEndSize(math.random(1, 40))
                p:SetRoll(math.random(-180, 180))
                p:SetRollDelta(math.Rand(-0.1, 0.1))
                p:SetAirResistance(600)

                p:SetCollide(true)
                p:SetBounce(0.4)

                p:SetLighting(false)
            end
        end

        em:Finish()
    end)
end

