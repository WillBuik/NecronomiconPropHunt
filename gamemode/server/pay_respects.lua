--[[============]]--
--[[PAY RESPECTS]]--
--[[============]]--
--
-- Server-side state and helpers for pressing F to pay respects

local last_dead_player = nil

function GetLatestVictim()
    return last_dead_player
end

hook.Add("PlayerDeath", "Store Most Recent Player Death", function(ply)
    print("player dead")

    if IsValid(ply) then
        print("setting player dead")
        print(ply)
        last_dead_player = ply
    end
end)

hook.Add("OBJHUNT_RoundStart", "Reset state for the paying of respects", function()
    last_dead_player = nil
end)
