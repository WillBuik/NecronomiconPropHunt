AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Decoy"
SWEP.PrintName = "Decoy"

SWEP.AbilitySound = "vo/canals/matt_goodluck.wav"
SWEP.AbilityDecoyCount = 12
SWEP.AbilityDuration = 9
SWEP.AbilityDescription = "Spawns $AbilityDecoyCount decoys and sends them in random directions\nThe decoys disappear afer $AbilityDuration seconds."

SWEP.AbilityCallWhenPrimed = true --

-- This SWEP curently doesn't work for a mirade of reasons: The decoys get stuck in the ground and sometimes eachother, don't have the right model, and refuse to move even if nocliped
function SWEP:Ability()
    if CLIENT then return end
    self:SetIsAbilityPrimed(true) --

    local ply = self:GetOwner()

    -- Angle locks off for maximum chaos but decoys are pitch locked so match that
    ply:SetPropAngleLocked(false)
    ply:SetPropAngleSnapped(false)
    ply:SetPropPitchEnabled(false)
    ply:SetPropPitchEnabled(false)
    ply:SetPropRollAngle(0)
    ResetPropToProp(ply)

    for i = 1,self.AbilityDecoyCount do
        local decoy = ents.Create("decoy_ent")
        if !IsValid(decoy) then break end
        decoy:InitAsPlayer(ply, (i - 1) * 0.05)
        SafeRemoveEntityDelayed(decoy, self.AbilityDuration)
    end
end
