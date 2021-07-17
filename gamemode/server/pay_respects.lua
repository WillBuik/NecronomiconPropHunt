--[[============]]--
--[[PAY RESPECTS]]--
--[[============]]--
--
-- Server-side state and helpers for pressing F to pay respects

local last_dead_player = nil
local fake_dead_players = {}

function GetLatestVictim()
    if (#fake_dead_players > 0) then
        return fake_dead_players[#fake_dead_players]
    end
    return last_dead_player
end

-- Prop deaths go through the PlayerSilentDeath hook, but that fires
-- more often than is practical; use this directly when a prop dies
function RecordPropDeath(ply)
    if IsValid(ply) then
        last_dead_player = ply
    end
end

function RecordFakePropDeath(ply)
    if IsValid(ply) then
        table.insert(fake_dead_players, ply)
    end
end

function UndoFakePropDeath()
    table.remove(fake_dead_players, 1)
end

hook.Add("PlayerDeath", "Store Most Recent Player Death", function(ply)
    if IsValid(ply) then
        last_dead_player = ply
    end
end)

hook.Add("OBJHUNT_RoundStart", "Reset state for the paying of respects", function()
    last_dead_player = nil
    fake_dead_players = {}
end)
