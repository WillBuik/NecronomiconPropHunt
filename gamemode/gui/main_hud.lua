-- the font I will use for info
surface.CreateFont("ObjHUDFont",
{
    font = "Helvetica",
    size = 40,
    weight = 2000,
    antialias = true,
    outline = false
})

surface.CreateFont("barHUD",
{
    font = "Helvetica",
    size = 16,
    weight = 1000,
    antialias = false,
    outline = true
})

--[[=======================]]--
--[[ This has all the bars ]]--
--[[=======================]]--
local function ObjHUD()
    local ply = LocalPlayer()
    if (!ply:IsValid()) then return end

    local width = 200
    --local height = 150
    local padding = 10
    local iconX = padding
    local barX = padding * 2 + 16
    local startY = ScrH()

    -- random color just to let the icon draw
    surface.SetDrawColor(PANEL_BORDER)

    -- INFO GUI
    do
        startY = startY - padding - 16

        -- icon
        local infoMat = Material("icon16/information.png", "unlitgeneric")
        surface.SetMaterial(infoMat)
        surface.DrawTexturedRect(iconX, startY, 16 , 16)

        --text
        surface.SetFont("barHUD")
        surface.SetTextColor(255, 255, 255, 255)
        local textToDraw = "Press F1 For Information"
        local textX = barX
        local textY = startY
        surface.SetTextPos(textX, textY)
        surface.DrawText(textToDraw)
    end

    -- HP GUI
    if (ply:Alive() and (ply:Team() == TEAM_PROPS or ply:Team() == TEAM_HUNTERS)) then
        startY = startY - padding - 16

        -- icon
        local heartMat = Material("icon16/heart.png", "unlitgeneric")
        surface.SetMaterial(heartMat)
        surface.DrawTexturedRect(iconX, startY, 16 , 16)

        -- bar
        hpFrac = math.Clamp(ply:Health(), 0, 100) / 100

        local widthOffset = width - (padding * 3) - 16
        surface.SetDrawColor(PANEL_FILL)
        surface.DrawRect(barX, startY, widthOffset, 16)
        surface.SetDrawColor(HP_COLOR)
        surface.DrawRect(barX, startY, widthOffset * hpFrac, 16)
        surface.SetDrawColor(PANEL_BORDER)
        surface.DrawOutlinedRect(barX, startY, widthOffset, 16)

        --text
        surface.SetFont("barHUD")
        surface.SetTextColor(255, 255, 255, 255)
        local textToDraw = LocalPlayer():Health()
        local textX = barX + 3
        local textY = startY
        surface.SetTextPos(textX, textY)
        surface.DrawText(textToDraw)
    end

    -- PROP COOLDOWN GUI
    if (ply:Alive() and ply:Team() == TEAM_PROPS) then
        -- this needs to be here otherwise some people get errors for some unknown reason
        if (ply.viewOrigin == nil or ply.wantThirdPerson == nil) then return end

        startY = startY - padding - 16

        -- icon
        local propMat = Material("icon16/package.png", "unlitgeneric")
        surface.SetMaterial(propMat)
        surface.DrawTexturedRect(iconX, startY, 16 , 16)

        -- bar
        local propFrac = math.Clamp(CurTime() - ply:GetPropLastChange() , 0, PROP_CHOOSE_COOLDOWN) / PROP_CHOOSE_COOLDOWN
        local propColor = LerpColor(propFrac, DEPLETED_COLOR, FULL_COLOR)

        local widthOffset = width - (padding * 3) - 16
        surface.SetDrawColor(PANEL_FILL)
        surface.DrawRect(barX, startY, widthOffset, 16)
        surface.SetDrawColor(propColor)
        surface.DrawRect(barX, startY, widthOffset * propFrac, 16)
        surface.SetDrawColor(PANEL_BORDER)
        surface.DrawOutlinedRect(barX, startY, widthOffset, 16)

        --text
        local textToDraw = PROP_CHOOSE_COOLDOWN - propFrac * PROP_CHOOSE_COOLDOWN
        textToDraw = math.ceil(textToDraw)
        if (textToDraw != 0) then
            surface.SetFont("barHUD")
            surface.SetTextColor(255, 255, 255, 255)
            local textX = barX + 3
            local textY = startY
            surface.SetTextPos(textX, textY)
            surface.DrawText(textToDraw)
        end
    end

    -- TAUNT COOLDOWN GUI
    if (ply:Alive() and (ply:Team() == TEAM_PROPS or ply:Team() == TEAM_HUNTERS)) then
        local lastTauntTime = ply:GetLastTauntTime()
        local lastTauntDuration = ply:GetLastTauntDuration()

        startY = startY - padding - 16

        -- icon
        local tauntMat = Material("icon16/music.png", "unlitgeneric")
        surface.SetMaterial(tauntMat)
        surface.DrawTexturedRect(iconX, startY, 16 , 16)

        -- bar
        local tauntFrac = math.Clamp(CurTime() - lastTauntTime , 0, lastTauntDuration) / lastTauntDuration
        local tauntColor = TAUNT_BAR_COLOR

        local widthOffset = width - (padding * 3) - 16
        surface.SetDrawColor(PANEL_FILL)
        surface.DrawRect(barX, startY, widthOffset, 16)
        surface.SetDrawColor(tauntColor)
        surface.DrawRect(barX, startY, widthOffset * tauntFrac, 16)
        surface.SetDrawColor(PANEL_BORDER)
        surface.DrawOutlinedRect(barX, startY, widthOffset, 16)

        --text
        local textToDraw = lastTauntDuration - tauntFrac * lastTauntDuration
        textToDraw = math.ceil(textToDraw)
        if (textToDraw != 0) then
            surface.SetFont("barHUD")
            surface.SetTextColor(255, 255, 255, 255)
            local textX = barX + 3
            local textY = startY
            surface.SetTextPos(textX, textY)
            surface.DrawText(textToDraw)
        end
    end

    -- POWERUP GUI
    for _, weapon in pairs(ply:GetWeapons()) do
        if (ply:Alive() and
            ply:Team() == TEAM_PROPS and
            weapon != nil and
            weapon.GetIsAbilityUsed and
            (!weapon:GetIsAbilityUsed() or weapon.AbilityStartTime + weapon.AbilityDuration > CurTime())
        ) then

            startY = startY - padding - 16

            -- icon
            local tauntMat = Material("icon16/star.png", "unlitgeneric")
            surface.SetMaterial(tauntMat)
            surface.DrawTexturedRect(iconX, startY, 16 , 16)

            local textToDraw = ""
            if (!weapon:GetIsAbilityUsed()) then
                textToDraw = weapon:GetPrintName()
            else
                -- bar
                local powerupFrac = math.Clamp(CurTime() - weapon.AbilityStartTime, 0, weapon.AbilityDuration) / weapon.AbilityDuration

                local widthOffset = width - (padding * 3) - 16
                surface.SetDrawColor(PANEL_FILL)
                surface.DrawRect(barX, startY, widthOffset, 16)
                surface.SetDrawColor(POWERUP_COLOR)
                surface.DrawRect(barX, startY, widthOffset * powerupFrac, 16)
                surface.SetDrawColor(PANEL_BORDER)
                surface.DrawOutlinedRect(barX, startY, widthOffset, 16)

                --text
                textToDraw = weapon.AbilityDuration - powerupFrac * weapon.AbilityDuration
                textToDraw = math.ceil(textToDraw)
            end

            --text
            surface.SetFont("barHUD")
            surface.SetTextColor(255, 255, 255, 255)
            local textX = barX
            local textY = startY
            surface.SetTextPos(textX, textY)
            surface.DrawText(textToDraw)
        end
    end
end

--[[=========================]]--
--[[ This has the round info ]]--
--[[=========================]]--
local function RoundHUD()
    local ply = LocalPlayer()
    if (!ply:IsValid()) then return end

    local width = 200
    local height = 50
    local padding = 10
    local startY = ScrH() - padding - height
    local startX = ScrW() - padding - width

    startX = startX / 2

    -- box with border
    surface.SetDrawColor(ROUND_TIME_COLOR)
    surface.DrawRect(startX, startY, width, height)
    surface.SetDrawColor(PANEL_BORDER)
    surface.DrawOutlinedRect(startX, startY, width, height)

    local lineX = startX + width / 2
    local lineY = startY + height - 1
    local box1Width = lineX - startX
    local box2Width = startX + width - lineX
    if (round.state) then
        -- labels for round/ time left
        surface.SetFont("InfoFont")
        surface.SetTextColor(255, 255, 255, 255)
        local textToDraw = "Time"
        local textWidth, textHeight = surface.GetTextSize(textToDraw)
        local textX = startX + box1Width / 2 - textWidth / 2
        local textY = startY - textHeight
        surface.SetTextPos(textX, textY)
        surface.DrawText(textToDraw)
        textToDraw = "Round"
        textWidth, textHeight = surface.GetTextSize(textToDraw)
        textX = lineX + box2Width / 2 - textWidth / 2
        surface.SetTextPos(textX, textY)
        surface.DrawText(textToDraw)

        surface.DrawLine(lineX, lineY, lineX, startY)

        -- Time left text
        surface.SetFont("ObjHUDFont")
        surface.SetTextColor(255, 255, 255, 255)

        local secs = RoundToTime(round)
        secs = math.max(0, secs)
        secs = math.Round(secs, 0)
        textToDraw = string.FormattedTime(secs, "%02i:%02i")

        textWidth, textHeight = surface.GetTextSize(textToDraw)
        textX = startX + box1Width / 2 - textWidth / 2
        textY = startY + height / 2 - textHeight / 2
        surface.SetTextPos(textX, textY)
        surface.DrawText(textToDraw)

        -- Rounds text
        textToDraw = round.current .. "/" .. OBJHUNT_ROUNDS
        textWidth, textHeight = surface.GetTextSize(textToDraw)
        textX = lineX + box2Width / 2 - textWidth / 2
        textY = startY + height / 2 - textHeight / 2

        surface.SetTextPos(textX, textY)
        surface.DrawText(textToDraw)
    end
end

--[[=========================]]--
--[[ This has spectater info ]]--
--[[=========================]]--
local function SpectateHUD()
    local ply = LocalPlayer()

    if (!ply:IsValid()) then return end

    local sTarget = ply:GetObserverTarget()
    if (!sTarget) then return end
    if (!sTarget:IsPlayer()) then return end --Fix console errors--
    local sNick = sTarget:Nick()

    local padding = 10


    local fColor
    if (sTarget:Team() == TEAM_HUNTERS) then
        fColor = TEAM_HUNTERS_COLOR
    else
        fColor = TEAM_PROPS_COLOR
    end

    local dColor = LerpColor(.70, fColor, Color(255,255,255,255))
    surface.SetFont("ObjHUDFont")
    surface.SetTextColor(dColor)
    local textWidth,_ = surface.GetTextSize(sNick)
    local textX = ScrW() / 2 - textWidth / 2
    local textY = padding * 2
    surface.SetTextPos(textX, textY)
    surface.DrawText(sNick)
end

hook.Add("HUDPaint", "Main ObjHunt HUD", ObjHUD)
hook.Add("HUDPaint", "Round HUD", RoundHUD)
hook.Add("HUDPaint", "Spec HUD", SpectateHUD)
