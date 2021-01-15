AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Disguise"
SWEP.PrintName = "Disguise"

SWEP.AbilityDuration = 20
SWEP.AbilityDescription = "Transforms you into a random hunter for $AbilityDuration seconds."

function SWEP:Ability()
    local ply = self:GetOwner()
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end)
    local hunters = team.GetPlayers(TEAM_HUNTERS)
    ply:ObjSetDisguised(true)
    if #hunters > 0 then
        ply:ObjSetDisguiseName(hunters[math.random(1, #hunters)]:Nick())
    else
        ply:ObjSetDisguiseName(ply:Nick())
    end
    if SERVER then
        ply:SetModel(TEAM_HUNTERS_DEFAULT_MODEL)
        ply:SetRenderMode(RENDERMODE_NORMAL)
        ply:GetProp():SetRenderMode(RENDERMODE_NONE)
        ply:Give("weapon_prop_util_smgdummy")
        ply:SelectWeapon("weapon_prop_util_smgdummy")

        ply:ResetHull()
        net.Start("Reset Prop")
            -- empty, just used for the hook
        net.Send(ply)
    end
end

function SWEP:AbilityCleanup()
    if not IsValid(self:GetOwner()) then return end
    local ply = self:GetOwner()
    ply:ObjSetDisguised(false)
    if SERVER then
        ply:StripWeapon("weapon_prop_util_smgdummy")
        player_manager.RunClass(ply, "SetModel")
        if (IsValid(ply:GetProp())) then
            ply:GetProp():SetRenderMode(RENDERMODE_NORMAL)
            ResetPropToProp(ply)
        end
        ply:SetRenderMode(RENDERMODE_NONE)
    end
end
