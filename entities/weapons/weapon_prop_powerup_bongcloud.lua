AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Bongcloud"
SWEP.PrintName = "Bongcloud"

SWEP.AbilityDuration = 8
SWEP.AbilityEmits = 4
SWEP.AbilityRadius = 50
SWEP.AbilityDescription = "Create clouds of smoke at your location for $AbilityDuration seconds."

function SWEP:Ability()
    if CLIENT then return end
    self:CreateAllSmoke()
    local originalCenter = self:GetOwner():GetPos()
    self:AbilityTimerIfValidOwner(self.AbilityDuration / (self.AbilityEmits - 1), self.AbilityEmits - 1, true, function() self:CreateAllSmoke(originalCenter) end)
end

function SWEP:CreateAllSmoke(originalCenter)
        local othersFilter = RecipientFilter()
        othersFilter:AddAllPlayers()
        othersFilter:RemovePlayer(self:GetOwner())
        self:CreateSomeSmoke(originalCenter, 255, othersFilter)

        local ownerFilter = RecipientFilter()
        ownerFilter:AddPlayer(self:GetOwner())
        self:CreateSomeSmoke(originalCenter, 100, ownerFilter)
end

function SWEP:CreateSomeSmoke(originalCenter, alpha, recipientFilter)
        local currentCenter = self:GetOwner():GetPos()
        local effect = EffectData()
        effect:SetEntity(self:GetOwner())
        effect:SetOrigin(currentCenter)
        effect:SetRadius(self.AbilityRadius)
        effect:SetScale(self.AbilityDuration * 3)
        effect:SetMagnitude(alpha)
        util.Effect("ph_bongcloud", effect, true, recipientFilter)
        if !originalCenter then return end
        local differanceVec =
            Vector(currentCenter.x - originalCenter.x , currentCenter.y - originalCenter.y, 0)
        if differanceVec:IsZero() then return end

        effect:SetOrigin(AddAngleToXY(differanceVec, 2 * math.pi / 3) + originalCenter)
        util.Effect("ph_bongcloud", effect, true, recipientFilter)

        effect:SetOrigin(AddAngleToXY(differanceVec, -2 * math.pi / 3) + originalCenter)
        util.Effect("ph_bongcloud", effect, true, recipientFilter)
end

