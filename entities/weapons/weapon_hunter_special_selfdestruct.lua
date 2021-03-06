AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Self-Destruct"
SWEP.PrintName = "SELF-DESRUCT"
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.AbilitySound = {"vo/npc/male01/runforyourlife01.wav"} --, "vo/canals/female01/gunboat_farewell.wav", "vo/canals/male01/stn6_incoming.wav"}
SWEP.AbilityModelScaleTimes = 8
SWEP.AbilityDuration = 4
SWEP.AbilityDescription = "Creates an explosion after $AbilityDuration seconds that kills nearby props and the user."

SWEP.WeaponIconKey = "o" -- C4

function SWEP:Ability()
    if CLIENT then return end

    for t = 1, self.AbilityModelScaleTimes do
        self:AbilityTimerIfValidOwnerAndAlive(self.AbilityDuration * (t / self.AbilityModelScaleTimes), 1, true, function()
            self:GetOwner():SetColor(ColorRand())
            self:GetOwner():SetPlayerColor(Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1)))
            self:GetOwner():SetModelScale(
                self:GetOwner():GetModelScale() + self:GetOwner():GetModelScale() / 10, 
                self.AbilityDuration / self.AbilityModelScaleTimes
            )
        end)
    end

    self:AbilityTimerIfValidOwnerAndAlive(self.AbilityDuration, 1, true, function()
        local explode = ents.Create("env_explosion")
        explode:SetPos(self:GetOwner():GetPos())
        explode:SetOwner(self:GetOwner())
        explode:Spawn()
        explode:SetKeyValue("iMagnitude", "200")
        explode:Fire( "Explode", 0, 0 )
        explode:EmitSound( "BaseExplosionEffect.Sound", 100, 100 )
    end)

    self:AbilityTimerIfValidOwnerAndAlive(self.AbilityDuration + 0.1, 1, true, function()
        self:GetOwner():Kill()
    end)
end

function SWEP:AbilityCleanup()
    if IsValid(self:GetOwner()) then
        self:GetOwner():SetModelScale(1, 0.1)
        self:GetOwner():SetColor(Color( 255, 255, 255, 255))
        self:GetOwner():SetPlayerColor(PlayerToAccentColor(self:GetOwner()))
    end
end
