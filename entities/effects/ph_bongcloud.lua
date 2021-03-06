function EFFECT:Init(data)
    self:SetOwner(data:GetEntity())
    local radius = data:GetRadius()
    local fadeoutTime = data:GetScale()
    local center = data:GetOrigin()
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
            local alpha = 255
            if (LocalPlayer() == self:GetOwner()) then
                alpha = 32
            end
            p:SetStartAlpha(alpha)
            p:SetEndAlpha(math.max(0, alpha - 55))
            p:SetVelocity(VectorRand() * math.Rand(900, 1300))
            p:SetLifeTime(0)

            p:SetDieTime(math.Rand(math.floor(fadeoutTime / 3), fadeoutTime))

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
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end