if AUTOTAUNT_ENABLED then

    surface.CreateFont("AutoTauntFont",
    {
        font = "coolvetica",
        size = 30,
        weight = 1000,
        antialias = true,
        outline = false
    })

    local opacity = .5 * 255
    local brightBlue = Color(14, 54, 100, 100)
    local brightYellow = Color(150, 54, 100, 100)
    local brightRed = Color(255, 54, 100, 100)
    local lightGray = Color(80, 80, 80, opacity)
    local brightWhite = Color(255, 255, 255, 255)

    function draw.Circle(x, y, radius, seg)
        local cir = {}

        table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
        for i = 0, seg do
            local a = math.rad((i / seg) * -360)
            table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
        end

        local a = math.rad(0) -- This is need for non absolute segment counts
        table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })

        surface.DrawPoly(cir)
    end

    function loadExtraHuds()

        --Loads the auto-taunt HUD
        autotauntHud()

    end

    function validateProp(ply)
        return ply:IsValid() and ply:Alive() and ply:Team() == TEAM_PROPS
    end

    function autotauntHud()

        local ply = LocalPlayer()

        -- Check if the player is valid, alive, and is a prop
        if (!validateProp(ply)) then return end

        -- Don't draw this HUD until the round starts and hunters are released
        if (round.state != ROUND_IN) then return end
        if (!round.startTime) then return end
        local timeToHunterRelease = round.startTime + round.timePad + OBJHUNT_HIDE_TIME - CurTime()
        if (timeToHunterRelease > 0) then return end

        -- Constants for HUD drawing
        local radius = 50
        local padding = 60
        local paddingL = 100
        local startCountingAtSeconds = 30 -- all times longer than this are drawn the same
        local warnAtSecondsRemaining = 12 -- 40% there!
        local criticalAtSecondsRemaining = 6 -- 80% there!

        -- Read/compute relevant auto-taunt state.  The visualization only
        -- depends on the amount of time remaining, which is the most important
        -- number for the player.
        local timeUntilNextAutoTaunt = ply:GetNextAutoTauntTime() - CurTime()
        local proportionRemaining = math.min(timeUntilNextAutoTaunt, startCountingAtSeconds) / startCountingAtSeconds

        local x = ScrW() - paddingL
        local y = ScrH() - padding

        -- Set the text Position and Text
        local timer = math.Round(timeUntilNextAutoTaunt, 0)
        local timertext = tostring(timer)
        if timer <= 0 then
            timertext = "!"
        end
        draw.SimpleText(timertext, "ObjHUDFont", x, y, brightWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- This is the outer circle
        surface.SetDrawColor(lightGray)
        draw.NoTexture()
        draw.Circle(x, y, radius, radius)

        -- This is the growing inner circle
        local timerRadius = (1 - proportionRemaining) * radius
        local color = nil
        if (timeUntilNextAutoTaunt < criticalAtSecondsRemaining) then
            color = brightRed
        elseif (timeUntilNextAutoTaunt < warnAtSecondsRemaining) then
            color = brightYellow
        else
            color = brightBlue
        end
        surface.SetDrawColor(color)
        draw.NoTexture()
        draw.Circle(x, y, timerRadius , radius)
        draw.SimpleText("Auto-Taunt", "AutoTauntFont", x, y - radius, brightWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    end


    hook.Add("HUDPaint", "Load Additional HUDS", loadExtraHuds)
    hook.Add("AutoTauntHUDRerender", "Re-render Auto Taunt HUD", autotauntHud)

end
