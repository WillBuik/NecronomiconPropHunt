if AUTOTAUNT_ENABLED then

    local function runAutoTaunter()
        local players = team.GetPlayers(TEAM_PROPS)
        local pRange = TAUNT_MAX_PITCH - TAUNT_MIN_PITCH
        local pitch = math.random() * pRange + TAUNT_MIN_PITCH

        --Render the Auto-taunt HUD

        for _,ply in pairs(players) do
            local taunt = table.Random(PROP_TAUNTS)

            if ply:Alive() and ply:Team() == TEAM_PROPS and CurTime() > ply:GetNextAutoTauntTime() then
                --Send the Taunt to the player
                SendTaunt(ply, taunt, pitch)
            end
        end
    end

    function CreateAutoTauntTimer()
        timer.Create("AutoTauntTimer", 0.1, 0, runAutoTaunter)
    end

--     hook.Add("Initialize", "Set Map Time",  function ()
--         mapStartTime = os.time()
--         CreateAutoTauntTimer()
--     end)

    hook.Add("OBJHUNT_RoundStart", "Restart the Timer", function ()
        local players = team.GetPlayers(TEAM_PROPS)
        for _,ply in pairs(players) do

            ply:SetLastTauntTime(CurTime() + OBJHUNT_HIDE_TIME +  OBJHUNT_AUTOTAUNT_BASE_INTERVAL * (1 + math.random()))
            ply:SetLastTauntDuration(1)

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
