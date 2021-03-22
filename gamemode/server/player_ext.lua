local plymeta = FindMetaTable("Player")
if !plymeta then return end


function plymeta:SetupPropHealth()
    if (!self.maxHP or !self.healthAtLastChange or !self.dmgPct or !self.propSize) then
        self.maxHP = 100
        self.healthAtLastChange = 100
        self.dmgPct = 1
        self.propSize = 100
        return
    end

    -- the damage percent is what percent of hp the prop currently has
    -- Let's only change it if the prop has taken damge to prevent drift
    local dmgPct = self.dmgPct
    if (self.healthAtLastChange != self:Health()) then
        dmgPct = self:Health() / self.maxHP
        self.dmgPct = dmgPct
    end


    self.maxHP = math.Clamp(self.propSize * 5.5 - 25, 1, 200)

    -- just enough to see the HP bar at lowest possible hp
    local newHP = math.Clamp(self.maxHP * dmgPct, 2, 200)
    self:SetHealth(newHP)
    self.healthAtLastChange = self:Health() 
end

function plymeta:SetupPropSpeed(abilityModifier)
    local baseSpeed = 222
    local sizeModifier = ((math.Clamp(self.propSize, 1, 200) / 100) * 0.15) + 0.85

    if (!self.abilitySpeedModifier) then
        self.abilitySpeedModifier = 1
    end
    if (abilityModifier) then
        self.abilitySpeedModifier = abilityModifier * self.abilitySpeedModifier 
    end

    self:SetWalkSpeed(baseSpeed * sizeModifier * self.abilitySpeedModifier)
    self:SetRunSpeed(baseSpeed * sizeModifier * self.abilitySpeedModifier)
end


function plymeta:ObjStartRagdoll(velocityBoost, velocityMultiplier)
    velocityBoost = velocityBoost or Vector(0, 0, 0)
    velocityMultiplier = velocityMultiplier or 1
    -- Do nothing if already ragdolled
    if self.objRagdoll then
        return
    end

    if self:InVehicle() then
        self:ExitVehicle()
    end

    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetAngles(self:GetAngles())
    ragdoll:SetModel(self:GetModel())
    ragdoll:SetPos(self:GetPos())
    ragdoll:SetSkin(self:GetSkin())
    for _, value in pairs(self:GetBodyGroups()) do
        ragdoll:SetBodygroup(value.id, self:GetBodygroup(value.id))
    end
    ragdoll:SetColor(self:GetColor())
    ragdoll:SetOwner(self)
    ragdoll:Spawn()
    ragdoll:Activate()
    self:SetParent(ragdoll) -- So their player ent will match up (position-wise) with where their ragdoll is.
    -- Set velocity for each piece of the ragdoll

    local velocity = (self:GetVelocity() + velocityBoost) * velocityMultiplier
    local j = 1
    while true do -- Break inside
        local phys_obj = ragdoll:GetPhysicsObjectNum(j)
        if phys_obj then
            phys_obj:SetVelocity(velocity * math.Clamp(phys_obj:GetMass() / 10, 0, 2))
            j = j + 1
        else
            break
        end
    end

    --self:Spectate(OBS_MODE_CHASE)
    --self:SpectateEntity(ragdoll)
    self:Freeze(true)
    self:ObjSetRagdolled(true)
    for _, wep in pairs(self:GetWeapons()) do
        wep:SetNoDraw(true)
    end

    self.objRagdoll = ragdoll
end

function plymeta:ObjEndRagdoll()
    self:SetParent()
    --self:UnSpectate()
    self:Freeze(false)
    self:ObjSetRagdolled(false)
    for _, wep in pairs(self:GetWeapons()) do
        wep:SetNoDraw(false)
    end

    local ragdoll = self.objRagdoll
    self.objRagdoll = nil -- Gotta do this before spawn or our hook catches it

    if !IsValid(ragdoll) or !ragdoll:IsValid() then -- Something must have removed it, just spawn
        return
    else
--         if self:Alive() then
--             self:Spawn()
--         end

        local pos = ragdoll:GetPos()

        self:SetModel(ragdoll:GetModel())
        self:SetPos(pos)
        self:SetVelocity(ragdoll:GetVelocity())
        local yaw = ragdoll:GetAngles().yaw
        self:SetAngles(Angle(0, yaw, 0))
        ragdoll:Remove()
        ResetPropToProp(self)
    end
end

function plymeta:FakeDeath(attacker)
    net.Start("Death Notice")
        net.WriteString(attacker:Nick())
        net.WriteUInt(attacker:Team(), 16)
        net.WriteString("found")
        net.WriteString(self:Nick())
        net.WriteUInt(self:Team(), 16)
    net.Broadcast()

    self:GetProp():SetRenderMode(RENDERMODE_NONE)
    self:GetProp():DrawShadow(false)
    self:ObjStartRagdoll()

    self:ObjSetShouldPlaydead(false)
    self:ObjSetPlaydead(true)

    -- pause auto-taunting while fake-dead to avoid a dead giveaway (pun intended)
    self:SetNextAutoTauntDelay(self:GetNextAutoTauntDelay() + PROP_RAGDOLL_DURATION)

    -- un-fake the death after a few seconds
    timer.Create("EndFakeDeath", PROP_RAGDOLL_DURATION, 1, function()
        self:EndFakeDeath()
    end)
end

function plymeta:EndFakeDeath()
    if (IsValid(self:GetProp())) then
        self:GetProp():SetRenderMode(RENDERMODE_NORMAL)
        self:GetProp():DrawShadow(true)
    end
    self:ObjEndRagdoll()
    self:ObjSetPlaydead(false)
end
