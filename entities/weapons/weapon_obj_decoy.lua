AddCSLuaFile()

SWEP.Base = "weapon_obj_base"
SWEP.Name = "Decoy"
SWEP.PrintName = "Decoy"

SWEP.AbilitySound = "vo/canals/matt_goodluck.wav"
SWEP.AbilityDecoyCount = 1
SWEP.AbilityDuration = 14
SWEP.AbilityDescription = "Spawns $AbilityDecoyCount decoys and sends them in random directions\nThe decoys disappear afer $AbilityDuration seconds."

function SWEP:Ability()

    if CLIENT then return end

    local spawnPos = self:GetOwner():GetPos()

    for _ = 1,self.AbilityDecoyCount do
        local decoy = ents.Create("npc_kleiner")
        if not IsValid(decoy) then break end
        decoy:SetCollisionGroup(COLLISION_GROUP_WORLD)
        decoy:NavSetRandomGoal(500, Vector(math.random(), math.random(), spawnPos.z))
        decoy:SetModel(self:GetOwner():GetProp():GetModel())
        hbMins, hbMaxs = self:GetOwner():GetProp():GetHitBoxBounds(0, 0)
        decoy:SetCollisionBounds(hbMins, hbMaxs)
        decoy:SetPos(spawnPos)
        decoy:Spawn()
        decoy:Activate()
        SafeRemoveEntityDelayed(decoy, self.AbilityDuration)
    end

    self:GetOwner():SetAngles(Angle(math.random(), math.random(), 0))
    self:GetOwner():SetCollisionGroup(COLLISION_GROUP_DEBRIS)
end
