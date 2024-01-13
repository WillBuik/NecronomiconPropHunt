AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Decoy"
SWEP.PrintName = "Decoy"

SWEP.AbilitySound = "vo/canals/matt_goodluck.wav"
SWEP.AbilityDecoyCount = 6
SWEP.AbilityDuration = 10
SWEP.AbilityDescription = "Spawns $AbilityDecoyCount decoys and sends them in random directions\nThe decoys disappear afer $AbilityDuration seconds."

--SWEP.AbilityCallWhenPrimed = true --

-- This SWEP curently doesn't work for a mirade of reasons: The decoys get stuck in the ground and sometimes eachother, don't have the right model, and refuse to move even if nocliped
function SWEP:Ability()
    if CLIENT then return end
    --self:SetIsAbilityPrimed(true) --

    local spawnPos = self:GetOwner():GetPos()
    local prop = self:GetOwner():GetProp()

    for _ = 1,self.AbilityDecoyCount do
        local decoy = ents.Create("decoy_ent")
        if !IsValid(decoy) then break end
        decoy:SetupProp(prop:GetModel(), prop:GetModelScale())
        decoy:SetPos(spawnPos + Vector(10 * math.random(), 10 * math.random(), 0))
        decoy:DropToFloor()
        decoy:Spawn()
        decoy:Activate()
        SafeRemoveEntityDelayed(decoy, self.AbilityDuration)
    end
end
