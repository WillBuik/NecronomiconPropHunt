-- Validate the lengths of all prop and hunter taunts.
concommand.Add("checktaunts", function(ply, cmd, args, str)
    if (SERVER) then
        print("SERVER Side Taunts:")
    else
        print("CLIENT Side Taunts:")
    end

    for _, taunt in pairs(PROP_TAUNTS) do
        local duration = NewSoundDuration("sound/" .. taunt)
        local durationStr
        if (!duration) then
            durationStr = "nil"
        else
            durationStr = string.format("%.2fs", duration)
        end
        print("Taunt '" .. taunt .. "'\tduration " .. durationStr)
    end

    for _, taunt in pairs(HUNTER_TAUNTS) do
        local duration = NewSoundDuration("sound/" .. taunt)
        local durationStr
        if (!duration) then
            durationStr = "nil"
        else
            durationStr = string.format("%.2fs", duration)
        end
        print("Taunt '" .. taunt .. "'\tduration " .. durationStr)
    end
end)
