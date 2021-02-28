AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Bongcloud"
SWEP.PrintName = "Bongcloud"

SWEP.AbilityDuration = 8
SWEP.AbilityEmits = 4
SWEP.AbilityRadius = 50
SWEP.AbilityDescription = "Create clouds of smoke at your location for $AbilityDuration seconds."

-- The only thing we need to do to make this SWEP work is have it create smoking ents, like we do for blastoff, so that it shows up on clients
function SWEP:Ability()
    if CLIENT then return end
    self:CreateSmoke()
    self:AbilityTimerIfValidOwner(self.AbilityDuration / (self.AbilityEmits - 1), self.AbilityEmits - 1, true, function() self:CreateSmoke() end)
end

function SWEP:CreateSmoke()
        local effect = EffectData()
        effect:SetEntity(self:GetOwner())
        effect:SetRadius(self.AbilityRadius)
        effect:SetScale(self.AbilityDuration * 3)
        util.Effect("ph_bongcloud", effect, true, true)
end

