if AUTOTAUNT_ENABLED then

    local function runAutoTaunter()
        local props = GetLivingPlayers(TEAM_PROPS)
        local now = CurTime()

        for _,ply in pairs(props) do
            doHoldBreath(ply, now)

            local nextAutoTaunt = ply:GetNextAutoTauntTime()
            if nextAutoTaunt ~= nil and now > nextAutoTaunt then
                local taunt = RandomTaunt(ply)
                local pitch = RandomPitch()
                --Send the Taunt to the player
                SendTaunt(ply, taunt, pitch)
            end
        end
    end

    function CreateAutoTauntTimer()
        timer.Create("AutoTauntTimer", 0.1, 0, runAutoTaunter)
    end

    hook.Add("OBJHUNT_HuntersReleased", "Restart the AutoTaunt Timer", function ()
        local players = team.GetPlayers(TEAM_PROPS)
        for _,ply in pairs(players) do

            ply:SetNextAutoTauntDelay(
                -- By adding this we can set NextAutoTauntTime from the CurTime instead of the LastTauntTime
                (CurTime() - ply:GetLastTauntTime()) +
                OBJHUNT_AUTOTAUNT_BASE_INTERVAL * (1 + math.random())
            )

        end

        if timer.Exists("AutoTauntTimer") then
            timer.Start("AutoTauntTimer")
        else
            CreateAutoTauntTimer()
        end

    end)

end
