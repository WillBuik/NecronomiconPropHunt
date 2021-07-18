AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Play Dead"
SWEP.PrintName = "Play Dead"

SWEP.AbilityDuration = PROP_RAGDOLL_DURATION
SWEP.AbilityDescription = "Transforms you into a ragdoll for $AbilityDuration seconds the next time you take damage."

function SWEP:Ability()
    if CLIENT then return end

    local ply = self:GetOwner()

    ply:ObjSetPlaydeadDuration(self.AbilityDuration)
    ply:PrintMessage(HUD_PRINTTALK, "The next time you take damage, you will play dead.")
end

function SWEP:AbilityCleanup()
    if CLIENT then return end
    self:GetOwner():GiveNewPowerupAfterWait()
    self:GetOwner():ObjSetPlaydeadDuration(-1)
    self:GetOwner():ObjSetPlaydead(false)
end
