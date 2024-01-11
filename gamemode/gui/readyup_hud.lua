-- HUD shown while waiting for the first round to start --

surface.CreateFont("ReadyHUDTitleFont",
{
    font = "Helvetica",
    size = 40,
    weight = 2000,
    antialias = true,
    outline = false
})

surface.CreateFont("ReadyHUDSubTitleFont",
{
    font = "Helvetica",
    size = 30,
    weight = 2000,
    antialias = true,
    outline = false
})

surface.CreateFont("ReadyHUDTextFont",
{
    font = "Helvetica",
    size = 22,
    weight = 800,
    antialias = true,
    outline = false
})

local WHITE = Color(255, 255, 255, 255)
local BACKGROUND = Color(0, 0, 0, 160)
local TEAM_PROPS_COLOR = Color(0, 60, 255, 255)
local TEAM_HUNTERS_COLOR = Color(230, 0, 30, 255)
local TEAM_SPECTATOR_COLOR = Color(200, 200, 200, 255)

local HELP_PROP = {
    {"Q", "Taunt (Hold to Select)"},
    {"E", "Become Prop / Interact (Open Door)"},
    {"R-Click", "Use Powerup"},
    {"R", "Lock Rotation"},
    {"F", "Pay Respects"},
    {"L-Shift", "Delay Forced Taunt (Costs Health)"}
}

local HELP_HUNTER = {
    {"E", "Interact (Open Door)"},
    {"F", "Flashlight / Pay Respects"},
    {"L-Shift", "Look Up or Down at Nearest Taunt"}
}

local HELP_ALL = {
    {"F1", "Show Detailed Help"},
    {"C", "Hold to Show Player Options"},
    {"TAB", "Show Score Board"},
    {"Space", "(Spectate) No Clip / Follow Player"}
}

local function draw_text(x, y, text)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
end

local function set_text_color(color)
    surface.SetTextColor(color.r, color.g, color.b, color.a)
end

local function set_draw_color(color)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
end

local function ReadyUpHUD()
    local ply = LocalPlayer()
    if (!ply:IsValid()) then return end

    if round.current != ROUND_WAIT then return end

    set_draw_color(BACKGROUND)
    surface.DrawRect(0, 0, 532, ScrH())

    local text_y = 60

    surface.SetFont("ReadyHUDTitleFont")
    set_text_color(WHITE)
    draw_text(60, text_y, "Necronomicon Prop Hunt")
    text_y = text_y + 60

    surface.SetFont("ReadyHUDTextFont")
    if ply:Team() == TEAM_SPECTATOR then
        draw_text(62, text_y, "[F2]  Join a Team to Ready Up!")
    else
        draw_text(62, text_y, "[F2]  Change Teams")
    end
    text_y = text_y + 44

    surface.SetFont("ReadyHUDSubTitleFont")
    set_text_color(WHITE)
    draw_text(60, text_y, "Players")
    text_y = text_y + 40
    
    surface.SetFont("ReadyHUDTextFont")
    for _, player in ipairs(player.GetAll()) do
        if player:Nick() != "unconnected" then
            local team = player:Team()
            if team == TEAM_PROPS then
                set_text_color(TEAM_PROPS_COLOR)
            elseif team == TEAM_HUNTERS then
                set_text_color(TEAM_HUNTERS_COLOR)
            elseif team == TEAM_SPECTATOR then
                set_text_color(TEAM_SPECTATOR_COLOR)
            end
            draw_text(62, text_y, player:Nick())
            set_text_color(WHITE)
            text_y = text_y + 32
        end
    end

    local i = 0
    local help = {}
    if ply:Team() == TEAM_PROPS then
        for _, v in pairs(HELP_PROP) do
            help[i] = v
            i = i + 1
        end
    end
    if ply:Team() == TEAM_HUNTERS then
        for _, v in pairs(HELP_HUNTER) do
            help[i] = v
            i = i + 1
        end
    end
    for _, v in pairs(HELP_ALL) do
        help[i] = v
        i = i + 1
    end

    local help_lines = # help
    text_y = ScrH() - 140 - 32 * help_lines
    
    set_text_color(WHITE)
    surface.SetFont("ReadyHUDSubTitleFont")
    if ply:Team() == TEAM_PROPS then
        draw_text(60, text_y, "Help (Props)")
    elseif ply:Team() == TEAM_HUNTERS then
        draw_text(60, text_y, "Help (Hunters)")
    else
        draw_text(60, text_y, "Help")
    end
    text_y = text_y + 40
    
    surface.SetFont("ReadyHUDTextFont")
    for _, v in pairs(help) do
        draw_text(62, text_y, v[1])
        draw_text(142, text_y, v[2])
        text_y = text_y + 32
    end
end

hook.Add("HUDPaint", "ReadyUp HUD", ReadyUpHUD)
