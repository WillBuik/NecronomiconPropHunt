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


function plymeta:PropDeath(attacker, fake)
    local ply = self
    ply:CreateRagdoll()
    BroadcastPlayerDeath(ply)
    AnnouncePlayerDeath(ply, attacker)
    -- an homage to a fun bug
    if (math.random() > 0.98) then
        AnnouncePlayerDeath(ply, attacker)
        AnnouncePlayerDeath(ply, attacker)
    end

    if (fake) then return end

    ply:SetRenderMode(RENDERMODE_NORMAL)
    RemovePlayerProp(ply)
    ply:KillSilent()
    attacker:AddFrags(1)
    ply:AddDeaths(1)
    ply:SetTimeOfDeath(CurTime())
end

function plymeta:FakeDeath(attacker)
    self:PropDeath(attacker, true)

    self:GetProp():SetRenderMode(RENDERMODE_NONE)
    self:GetProp():DrawShadow(false)
    self:Freeze(true)

    local playDeadDuration = self:ObjGetPlaydeadDuration()

    -- pause auto-taunting while fake-dead to avoid a dead giveaway (pun intended)
    self:SetNextAutoTauntDelay(self:GetNextAutoTauntDelay() + playDeadDuration)

    -- un-fake the death after a few seconds
    timer.Create("EndFakeDeath", playDeadDuration, 1, function()
        self:EndFakeDeath()
    end)

    self:ObjSetPlaydeadDuration(-1)
    self:ObjSetPlaydead(true)
end

function plymeta:EndFakeDeath()
    if (IsValid(self:GetProp())) then
        self:GetProp():SetRenderMode(RENDERMODE_NORMAL)
        self:GetProp():DrawShadow(true)
    end
    self:Freeze(false)
    self:ObjSetPlaydead(false)
end
