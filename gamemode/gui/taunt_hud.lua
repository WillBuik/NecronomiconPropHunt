surface.CreateFont("TauntHUDFont",
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
local brightGreen = Color(54, 255, 100, 100)
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

function tauntHUD()

    local ply = LocalPlayer()

    -- Check if the player is taunt-eligible.
    if !IsValid(ply) or !ply:CanTauntNowOrLater() then return end

    -- Eh, only props really want this HUD.
    if ply:Team() != TEAM_PROPS then return end

    -- Don't draw this HUD until the round starts and hunters are released
    if (round.state != ROUND_IN) then return end
    if (!round.huntersReleased) then return end

    -- Constants for HUD drawing
    local radius = 50
    local padding = 60
    local paddingL = 100
    local startCountingAtSeconds = 30 -- all times longer than this are drawn the same
    local warnAtSecondsRemaining = 12 -- 40% there!
    local criticalAtSecondsRemaining = 6 -- 80% there!

    -- Read/compute relevant state.  The visualization depends on the amount of
    -- time remaining and whether we are counting down to an auto-taunt or
    -- to taunt eligibility.
    local now = CurTime()
    local nextEventTimestamp
    local label
    local eventColor
    local deadlineOfNextAutoTaunt = ply:GetNextAutoTauntTime()
    if deadlineOfNextAutoTaunt != nil then
        label = "Auto-Taunt"
        nextEventTimestamp = deadlineOfNextAutoTaunt
        eventColor = brightRed
    else
        label = "Next Taunt"
        nextEventTimestamp = ply:GetNextTauntAvailableTime()
        eventColor = brightGreen
    end
    local timeUntilNextEvent = math.max(nextEventTimestamp - now, 0)
    local proportionRemaining = math.min(timeUntilNextEvent, startCountingAtSeconds) / startCountingAtSeconds

    local x = ScrW() - paddingL
    local y = ScrH() - padding

    -- Set the text Position and Text
    local timer = math.Round(timeUntilNextEvent, 0)
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
    if (timeUntilNextEvent < criticalAtSecondsRemaining) then
        color = eventColor
    elseif (timeUntilNextEvent < warnAtSecondsRemaining) then
        color = brightYellow
    else
        color = brightBlue
    end
    surface.SetDrawColor(color)
    draw.NoTexture()
    draw.Circle(x, y, timerRadius , radius)
    draw.SimpleText(label, "TauntHUDFont", x, y - radius, brightWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

end

hook.Add("HUDPaint", "Load Additional HUDS", tauntHUD)
