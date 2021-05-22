--[[=============]]--
--[[FRIENDLY FIRE]]--
--[[=============]]--
--
-- Server-side state and helper functions for the friendly-fire powerup (see
-- /entities/weapons/weapon_prop_powerup_friendlyfire.lua).
--
-- BASIC DESIGN (2021/5/22)
--
-- State:
--   friendly_fire_players (local)
--     A Lua table.  Keys are players who are currently causing friendly fire
--     to be in effect.  This is more complex than a simple boolean to handle
--     overlapping instances of the effect from different players, e.g.:
--
--                   |-----------|             player P1's friendly fire effect
--                       |-----------|         player P2's friendly fire effect
--       time ---------------------------->
--
-- Procedures:
--   EnableHunterFriendlyFire(ply)    -- called at the start of the ability
--   DisableHunterFriendlyFire(ply)   -- called at the end of the ability
--   IsHunterFriendlyFireEnabled()    -- checked by server damage hook

local friendly_fire_players = {}

local function FriendlyFireDebug(prefix)
    if IsHunterFriendlyFireEnabled() then
        print(prefix .. " -- friendly fire is now ON")
        for ply, _ in pairs(friendly_fire_players) do
            print(" - " .. ply:GetName())
        end
    else
        print(prefix .. " -- friendly fire is now OFF")
    end
end

hook.Add("OBJHUNT_RoundStart", "Reset friendly fire state", function()
    friendly_fire_players = {}
    FriendlyFireDebug("At round start")
end)

function EnableHunterFriendlyFire(ply)
    friendly_fire_players[ply] = true
    FriendlyFireDebug("Enable friendly fire from " .. ply:GetName())
end

function DisableHunterFriendlyFire(ply)
    friendly_fire_players[ply] = nil
    FriendlyFireDebug("Disable friendly fire from " .. ply:GetName())
end

function IsHunterFriendlyFireEnabled()
    for ply, _ in pairs(friendly_fire_players) do
        return true
    end
    return false
end
