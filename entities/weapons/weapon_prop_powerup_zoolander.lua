AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Zoolander"
SWEP.PrintName = "Zoolander"

SWEP.AbilityRange = 400
SWEP.AbilityShowTargetHalos = true
SWEP.AbilityDuration = 11
SWEP.AbilityDescription = "Make all hunters within a range of $AbilityRange unable to turn left for $AbilityDuration seconds"

function SWEP:Ability()
    if CLIENT then return end
    local targets = self:GetHuntersInRange(self.AbilityRange, true)
    -- dont use ability if no target was found
    if #targets == 0 then
        return OBJ_ABILTY_CAST_ERROR_NO_TARGET
    end

    for _, ply in pairs(targets) do
        ply:SetZoolander(true)
        timer.Simple(self.AbilityDuration, function() ply:SetZoolander(false) end)
    end
end

if CLIENT then
    hook.Add( "InputMouseApply", "ZoolanderHook", function(cmd)
        if !LocalPlayer():IsZoolander() then return end

        cmd:SetMouseX(math.max(cmd:GetMouseX(), 0))
        return true
    end )
end