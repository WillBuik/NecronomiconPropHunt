if AUTOTAUNT_ENABLED then

    local function runAutoTaunter()
        local props = GetLivingPlayers(TEAM_PROPS)
        local now = CurTime()

        for _,ply in pairs(props) do
            doHoldBreath(ply, now)

            if now > ply:GetNextAutoTauntTime() then
                local taunt = table.Random(PROP_TAUNTS)
                local pRange = TAUNT_MAX_PITCH - TAUNT_MIN_PITCH
                local pitch = math.random() * pRange + TAUNT_MIN_PITCH
                --Send the Taunt to the player
                SendTaunt(ply, taunt, pitch)
            end
        end
    end

    function CreateAutoTauntTimer()
        timer.Create("AutoTauntTimer", 0.1, 0, runAutoTaunter)
    end

    hook.Add("OBJHUNT_HuntersReleased", "Restart the Timer", function ()
        local players = team.GetPlayers(TEAM_PROPS)
        for _,ply in pairs(players) do

            ply:SetNextAutoTauntDelay(
                -- By adding this we can set NextAutoTauntTime from the CurTime instead of the LastTauntTime
                (CurTime() - ply:GetLastTauntTime()) + 
                OBJHUNT_AUTOTAUNT_BASE_INTERVAL * (1 + math.random())
            )

            net.Start("AutoTaunt Update")
            net.Send(ply)
        end

        if timer.Exists("AutoTauntTimer") then
            timer.Start("AutoTauntTimer")
        else
            CreateAutoTauntTimer()
        end

    end)

end
