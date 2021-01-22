AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "SUPER HOT"
SWEP.PrintName = "SUPER HOT"

SWEP.AbilityDuration = 6
SWEP.AbilityTimeScale = 0.3
SWEP.AbilityDescription = "Not quite like the original.\n\nSlow Motion for everyone, but yourself.\nLasts $AbilityDuration seconds."

local playerSuperHotNWVarName = "propIsSuperHotEnabled"

function SWEP:Ability()
    if CLIENT then return end
    local ply = self:GetOwner()
    -- dont consume if already activated by someone else
    if GAMEMODE.PropAbilitySuperHotMode then
        return OBJ_ABILTY_CAST_ERROR_ALREADY_ACTIVE
    end

    GAMEMODE.PropAbilitySuperHotMode = true
    GAMEMODE.PropAbilitySuperHotModePly = ply
    GAMEMODE.PropAbilitySuperHotModeEndTime = RealTime() + self.AbilityDuration / self.AbilityTimeScale
    ply:SetWalkSpeed(ply:GetWalkSpeed() * 6)
    ply:SetRunSpeed(ply:GetRunSpeed() * 6)
    for _, p in pairs(player.GetAll()) do
        p:SetNWBool(playerSuperHotNWVarName, true)
    end
    game.SetTimeScale(self.AbilityTimeScale)
end

local function endSuperHotMode()
    if CLIENT then return end
    local ply = GAMEMODE.PropAbilitySuperHotModePly
    game.SetTimeScale(1)
    ply:SetWalkSpeed(ply:GetWalkSpeed() / 6)
    ply:SetRunSpeed(ply:GetRunSpeed() / 6)
    for _, p in pairs(player.GetAll()) do
        p:SetNWBool(playerSuperHotNWVarName, false)
    end

    GAMEMODE.PropAbilitySuperHotMode = false
    GAMEMODE.PropAbilitySuperHotModePly = nil
end

function SWEP:AbilityCleanup()
    if IsValid(self:GetOwner()) and self:GetOwner() == GAMEMODE.PropAbilitySuperHotModePly then
        endSuperHotMode()
    end
end

if SERVER then
    hook.Add("Think", "SuperHotThink", function()
        if GAMEMODE.PropAbilitySuperHotMode then
            local ply = GAMEMODE.PropAbilitySuperHotModePly
            if not IsValid(ply) or not ply:Alive() or GAMEMODE.PropAbilitySuperHotModeEndTime < RealTime() then
                endSuperHotMode()
            end
        end
    end)
end

if CLIENT then
    hook.Add("HUDPaint", "propSuperHotHudPaint", function()
        if IsValid(LocalPlayer()) and LocalPlayer():GetNWBool(playerSuperHotNWVarName) then
            local x = ScrW() / 2
            local y = ScrH() / 2 - 200
        
            local text = ""

            if math.floor(RealTime()) % 2 == 0 then
                surface.SetFont("ph_font_larger")
                text = "SUPER"
            else
                surface.SetFont("ph_font_huge")
                text = "HOT"
            end

            local w, h = surface.GetTextSize(text);

            surface.SetTextPos(x - w / 2, y - h / 2)
            surface.SetTextColor(G_PHColors.white:Unpack())
            surface.DrawText(text)
        end
    end)
end

hook.Add( "EntityEmitSound", "", function( t )

    local p = t.Pitch

    if game.GetTimeScale() ~= 1 then
        p = p * game.GetTimeScale()
    end

    if p ~= t.Pitch then
        t.Pitch = math.Clamp( p, 0, 255 )
        return true
    end

    if CLIENT and engine.GetDemoPlaybackTimeScale() ~= 1 then
        t.Pitch = math.Clamp( t.Pitch * engine.GetDemoPlaybackTimeScale(), 0, 255 )
        return true
    end

end )
