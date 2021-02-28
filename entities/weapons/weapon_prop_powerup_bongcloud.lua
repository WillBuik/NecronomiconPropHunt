AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Bongcloud"
SWEP.PrintName = "Bongcloud"

SWEP.AbilityDuration = 8
SWEP.AbilityEmits = 4
SWEP.AbilityRadius = 40
SWEP.AbilityDescription = "Create clouds of smoke at your location for $AbilityDuration seconds."

function SWEP:Ability()
    if CLIENT then return end
    self:CreateSmoke()
    local originalCenter = self:GetOwner():GetPos()
    self:AbilityTimerIfValidOwner(self.AbilityDuration / (self.AbilityEmits - 1), self.AbilityEmits - 1, true, function() self:CreateSmoke(originalCenter) end)
end

function SWEP:CreateSmoke(originalCenter)
        local currentCenter = self:GetOwner():GetPos()
        local effect = EffectData()
        effect:SetEntity(self:GetOwner())
        effect:SetOrigin(currentCenter)
        effect:SetRadius(self.AbilityRadius)
        effect:SetScale(self.AbilityDuration * 2)
        util.Effect("ph_bongcloud", effect, true, true)
        if !originalCenter then return end
        local differanceVec =
            Vector(currentCenter.x - originalCenter.x , currentCenter.y - originalCenter.y, 0)
        if differanceVec:IsZero() then return end

        effect:SetOrigin(AddAngleToXY(differanceVec, 2 * math.pi / 3) + originalCenter)
        util.Effect("ph_bongcloud", effect, true, true)

        effect:SetOrigin(AddAngleToXY(differanceVec, -2 * math.pi / 3) + originalCenter)
        util.Effect("ph_bongcloud", effect, true, true)
end

