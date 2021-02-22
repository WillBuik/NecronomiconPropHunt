    local function runPropPoints()
        local props = GetLivingPlayers(TEAM_PROPS)
        for _,ply in pairs(props) do
            -- Only points for standing still
            if ply:GetVelocity():LengthSqr() > 1 then return end
            local exp = 0
            -- double for taunting
            if ply:GetNextTauntAvailableTime() > CurTime() then exp = exp + 1 end
            -- a hunter is close
            if ply:GetPos():DistToSqr(GetClosestHunter(ply):GetPos()) < 400 ^2 then exp = exp + 1 end
            -- a hunter is looking right at you
            if GetHunterLookingAtYou(ply) then exp = exp + 1 end

            ply:AddPropPoints(2 ^ exp)
        end
    end

    function CreatePropPointsTimer()
        timer.Create("PropPointsTimer", 1, 0, runPropPoints)
    end

    hook.Add("OBJHUNT_HuntersReleased", "Restart the Prop Point Timer", function ()

        if timer.Exists("PropPointsTimer") then
            timer.Start("PropPointsTimer")
        else
            CreatePropPointsTimer()
        end

    end)
