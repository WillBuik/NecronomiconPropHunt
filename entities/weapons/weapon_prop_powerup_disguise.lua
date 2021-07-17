AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Disguise"
SWEP.PrintName = "Disguise"

SWEP.AbilityUseManuallyManaged = true
SWEP.AbilityDescription = "Transforms you into a random hunter until you turn it off."

function SWEP:Ability()
    local ply = self:GetOwner()
    if !ply:ObjIsDisguised() then
        local hunters = team.GetPlayers(TEAM_HUNTERS)
        if SERVER then
            ply:ObjSetDisguised(true)
            ply:SetModel(TEAM_HUNTERS_DEFAULT_MODEL)
            ply:SetRenderMode(RENDERMODE_NORMAL)
            ply:GetProp():SetRenderMode(RENDERMODE_NONE)
            ply:Give("weapon_prop_util_smgdummy")
            ply:SelectWeapon("weapon_prop_util_smgdummy")

            local tHitboxMin, tHitboxMax = GetHitBoxInModelCoordinates(ply)
            UpdatePlayerPropHitbox(ply, tHitboxMin, tHitboxMax)
        end
    else
        print("test")
        if SERVER then
            ply:ObjSetDisguised(false)
            print("another super odd place")
            self:SetIsAbilityUsed(true)
            ply:StripWeapon("weapon_prop_util_smgdummy")
            player_manager.RunClass(ply, "SetModel")
            if (IsValid(ply:GetProp())) then
                ply:GetProp():SetRenderMode(RENDERMODE_NORMAL)
                ResetPropToProp(ply)
            end
            ply:SetRenderMode(RENDERMODE_NONE)
        end
    end
end

function SWEP:AbilityCleanup()
    if !IsValid(self:GetOwner()) then return end
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
