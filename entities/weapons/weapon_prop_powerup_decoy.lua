AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Decoy"
SWEP.PrintName = "Decoy"

SWEP.AbilitySound = "vo/canals/matt_goodluck.wav"
SWEP.AbilityDecoyCount = 1
SWEP.AbilityDuration = 14
SWEP.AbilityDescription = "Spawns $AbilityDecoyCount decoys and sends them in random directions\nThe decoys disappear afer $AbilityDuration seconds."

-- This SWEP curently doesn't work for a mirade of reasons: The decoys get stuck in the ground and sometimes eachother, don't have the right model, and refuse to move even if nocliped
function SWEP:Ability()
    if CLIENT then return end

    local spawnPos = self:GetOwner():GetPos()

    self:GetOwner():SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    for _ = 1,self.AbilityDecoyCount do
        local decoy = ents.Create("decoy_ent")
        if !IsValid(decoy) then break end
        decoy:SetCollisionGroup(COLLISION_GROUP_NPC_SCRIPTED)
        decoy:SetPos(spawnPos + Vector(10 * math.random(), 10 * math.random(), 4))
        decoy:DropToFloor()
        decoy:Spawn()
        decoy:Activate()
        SafeRemoveEntityDelayed(decoy, self.AbilityDuration)
    end

    self:GetOwner():SetAngles(Angle(math.random(), math.random(), 0))
end
