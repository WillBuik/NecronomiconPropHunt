AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Blast Off"
SWEP.PrintName = "Blast Off"

SWEP.AbilityRange = 400
SWEP.AbilityShowTargetHalos = true
SWEP.AbilityDuration = 4
SWEP.AbilityDescription = "Launches all hunters within a range of $AbilityRange into the air after a short delay.\nThe seekers are stuck in the air for at least $AbilityDuration seconds.\n\nDoes not work well indoors."

function SWEP:Ability()
    if CLIENT then return end
    local targets = self:GetHuntersInRange(self.AbilityRange, true)
    -- dont use ability if no target was found
    if #targets == 0 then
        return OBJ_ABILTY_CAST_ERROR_NO_TARGET
    end

    for _, ply in pairs(targets) do
        timer.Simple(0.5, function() ply:SetVelocity(Vector(0, 0, 2000)) end)
        local effect = EffectData()
        effect:SetEntity(ply)
        effect:SetMagnitude(3)
        util.Effect("ph_blastoff", effect, true, true)

        local tName = "phLaunch" .. ply:SteamID()
        timer.Create(tName, 0.1, 15, function()
            if util.QuickTrace(ply:EyePos(), Vector(0, 0, 30), ply).HitWorld then
                timer.Remove(tName)
                ply:SetGravity(-1)
                timer.Simple(self.AbilityDuration, function() ply:SetGravity(1) end)
            end
        end)
    end
end
