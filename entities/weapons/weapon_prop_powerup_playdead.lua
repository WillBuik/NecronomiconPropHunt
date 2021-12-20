AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Play Dead"
SWEP.PrintName = "Play Dead"

SWEP.AbilityDuration = PROP_RAGDOLL_DURATION
SWEP.AbilityDescription = "Transforms you into a ragdoll for $AbilityDuration seconds the next time you take damage."

function SWEP:Ability()
    if CLIENT then return end
    self:SetIsAbilityPrimed(true)

    local ply = self:GetOwner()

    ply:ObjSetPlaydeadCallback(self)
    ply:PrintMessage(HUD_PRINTTALK, "The next time you take damage, you will play dead.")
end

function SWEP:AbilityTrigger()
    if CLIENT then return end

    self:SetIsAbilityPrimed(false)
    self:SetIsAbilityUsed(true)

    local ply = self:GetOwner()

    ply:PropDeath(attacker, true)

    ply:GetProp():SetRenderMode(RENDERMODE_NONE)
    ply:GetProp():DrawShadow(false)
    ply:Freeze(true)
    ply:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    RecordFakePropDeath(ply)

    -- pause auto-taunting while fake-dead to avoid a dead giveaway (pun intended)
    ply:SetNextAutoTauntDelay(ply:GetNextAutoTauntDelay() + self.AbilityDuration)

    ply:ObjSetPlaydeadCallback(nil)
    ply:ObjSetPlaydead(true)


    -- un-fake the death after a few seconds
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end)
end

function SWEP:AbilityCleanup()
    if CLIENT then return end

    self:SetIsAbilityPrimed(false)
    self:SetIsAbilityUsed(true)

    local ply = self:GetOwner()

    ply:ObjSetPlaydeadCallback(nil)
    ply:ObjSetPlaydead(false)

    if (IsValid(ply:GetProp())) then
        ply:GetProp():SetRenderMode(RENDERMODE_NORMAL)
        ply:GetProp():DrawShadow(true)
    end
    ply:Freeze(false)
    ply:SetCollisionGroup(COLLISION_GROUP_NONE)
    ply:ObjSetPlaydead(false)
    UndoFakePropDeath()

    ResetPropToProp(ply)
    ply:RemoveRagdoll()
end
