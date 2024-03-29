local mainPanel
local padding = 10
local deltaTime = 0.2
local width = 200
local height = 300
local posXOpen
local posXClose
local posY
surface.CreateFont("Toggle Buttons",
{
    font = "Helvetica",
    size = 16,
    weight = 30,
    antialias = false,
    outline = true,
})

local btnHeight = 30

local function DrawContextMenu()

    local totalBtns = 0

    mainPanel = vgui.Create("DPanel")
    mainPanel:SetPos(ScrW() - width, ScrH() + height)

    if (LocalPlayer():Team() == TEAM_PROPS or
        LocalPlayer():Team() == TEAM_HUNTERS) then
        totalBtns = totalBtns + 1
        local thirdPersonBtn = vgui.Create("DButton", mainPanel)
        thirdPersonBtn:SetText("")
        thirdPersonBtn:SetPos(padding, totalBtns * padding  + (totalBtns - 1) * btnHeight)
        thirdPersonBtn:SetSize(width - 2 * padding, btnHeight)
        thirdPersonBtn.DoClick = function()
            LocalPlayer().wantThirdPerson = !LocalPlayer().wantThirdPerson
        end

        -- painting
        thirdPersonBtn.Paint = function(self, w, h)
            local btnColor
            if (LocalPlayer().wantThirdPerson) then
                btnColor = table.Copy(ON_COLOR)
            else
                btnColor = table.Copy(OFF_COLOR)
            end

            if (thirdPersonBtn:IsHovered()) then
                btnColor.a = btnColor.a + 20
            end

            surface.SetFont("Toggle Buttons")
            surface.SetTextColor(Color(255, 255, 255, 255))
            local text = "Third Person"
            local tw, th = surface.GetTextSize(text)
            surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
            surface.DrawText(text)
            surface.SetDrawColor(btnColor)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(PANEL_BORDER)
            surface.DrawOutlinedRect(0, 0, w, h)

        end
    end

    if (LocalPlayer():Team() == TEAM_PROPS) then
        totalBtns = totalBtns + 1
        local worldAngleBtn = vgui.Create("DButton", mainPanel)
        worldAngleBtn:SetText("")
        worldAngleBtn:SetPos(padding, totalBtns * padding + (totalBtns - 1) * btnHeight)
        worldAngleBtn:SetSize(width - 2 * padding, btnHeight)
        worldAngleBtn.DoClick = function()
            net.Start("Prop Angle Lock")
                net.WriteBit(!LocalPlayer():IsPropAngleLocked())
                net.WriteAngle(LocalPlayer():GetProp():GetAngles())
            net.SendToServer()
        end

        -- painting
        worldAngleBtn.Paint = function(self, w, h)
            local btnColor
            if (LocalPlayer():IsPropAngleLocked()) then
                btnColor = table.Copy(ON_COLOR)
            else
                btnColor = table.Copy(OFF_COLOR)
            end

            if (worldAngleBtn:IsHovered()) then
                btnColor.a = btnColor.a + 20
            end

            surface.SetFont("Toggle Buttons")
            surface.SetTextColor(Color(255, 255, 255, 255))
            local text = "Angle Lock"
            local tw, th = surface.GetTextSize(text)
            surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
            surface.DrawText(text)
            surface.SetDrawColor(btnColor)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(PANEL_BORDER)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
    end

    if (LocalPlayer():Team() == TEAM_PROPS) then
        totalBtns = totalBtns + 1
        local snapAngleBtn = vgui.Create("DButton", mainPanel)
        snapAngleBtn:SetText("")
        snapAngleBtn:SetPos(padding, totalBtns * padding  + (totalBtns - 1) * btnHeight)
        snapAngleBtn:SetSize(width - 2 * padding, btnHeight)
        snapAngleBtn.DoClick = function()
            if (!IsValid(LocalPlayer():GetProp())) then return end
            net.Start("Prop Angle Snap")
                net.WriteBit(!LocalPlayer():IsPropAngleSnapped())
            net.SendToServer()
        end

        -- painting
        snapAngleBtn.Paint = function(self, w, h)
            local btnColor
            if (LocalPlayer():IsPropAngleSnapped()) then
                btnColor = table.Copy(ON_COLOR)
            else
                btnColor = table.Copy(OFF_COLOR)
            end

            if (snapAngleBtn:IsHovered()) then
                btnColor.a = btnColor.a + 20
            end

            surface.SetFont("Toggle Buttons")
            surface.SetTextColor(Color(255, 255, 255, 255))
            local text = "Angle Snapping"
            local tw, th = surface.GetTextSize(text)
            surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
            surface.DrawText(text)
            surface.SetDrawColor(btnColor)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(PANEL_BORDER)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
    end

    if (LocalPlayer():Team() == TEAM_PROPS) then
        totalBtns = totalBtns + 1
        local pitchEnableBtn = vgui.Create("DButton", mainPanel)
        pitchEnableBtn:SetText("")
        pitchEnableBtn:SetPos(padding, totalBtns * padding  + (totalBtns - 1) * btnHeight)
        pitchEnableBtn:SetSize(width - 2 * padding, btnHeight)
        pitchEnableBtn.DoClick = function()
            if (!IsValid(LocalPlayer():GetProp())) then return end
            net.Start("Prop Pitch Enable")
                net.WriteBit(!LocalPlayer():IsPropPitchEnabled())
            net.SendToServer()
        end

        -- painting
        pitchEnableBtn.Paint = function(self, w, h)
            local btnColor
            if (LocalPlayer():IsPropPitchEnabled()) then
                btnColor = table.Copy(ON_COLOR)
            else
                btnColor = table.Copy(OFF_COLOR)
            end

            if (pitchEnableBtn:IsHovered()) then
                btnColor.a = btnColor.a + 20
            end

            surface.SetFont("Toggle Buttons")
            surface.SetTextColor(Color(255, 255, 255, 255))
            local text = "Enable Tilt"
            local tw, th = surface.GetTextSize(text)
            surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
            surface.DrawText(text)
            surface.SetDrawColor(btnColor)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(PANEL_BORDER)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
    end

    if (LocalPlayer():Team() == TEAM_PROPS) then
        totalBtns = totalBtns + 1
        local unstickPropBtn = vgui.Create("DButton", mainPanel)
        unstickPropBtn:SetText("")
        unstickPropBtn:SetPos(padding, totalBtns * padding  + (totalBtns - 1) * btnHeight)
        unstickPropBtn:SetSize(width - 2 * padding, btnHeight)
        unstickPropBtn.DoClick = function()
            net.Start("Unstick Prop")
            net.SendToServer()
        end

        -- painting
        unstickPropBtn.Paint = function(self, w, h)
            local btnColor = table.Copy(Color(0, 0, 255, 100))

            if (unstickPropBtn:IsHovered()) then
                btnColor.a = btnColor.a + 20
            end

            surface.SetFont("Toggle Buttons")
            surface.SetTextColor(Color(255, 255, 255, 255))
            local text = "Unstick Prop"
            local tw, th = surface.GetTextSize(text)
            surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
            surface.DrawText(text)
            surface.SetDrawColor(btnColor)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(PANEL_BORDER)
            surface.DrawOutlinedRect(0, 0, w, h)

        end
    end

    if (LocalPlayer():Team() == TEAM_PROPS or
        LocalPlayer():Team() == TEAM_HUNTERS) then
        totalBtns = totalBtns + 1
        local resetToSpawnBtn = vgui.Create("DButton", mainPanel)
        resetToSpawnBtn:SetText("")
        resetToSpawnBtn:SetPos(padding, totalBtns * padding  + (totalBtns - 1) * btnHeight)
        resetToSpawnBtn:SetSize(width - 2 * padding, btnHeight)
        resetToSpawnBtn.DoClick = function()
            net.Start("Reset To Spawn")
            net.SendToServer()
        end

        -- painting
        resetToSpawnBtn.Paint = function(self, w, h)
            local btnColor = table.Copy(Color(0, 0, 255, 100))

            if (resetToSpawnBtn:IsHovered()) then
                btnColor.a = btnColor.a + 20
            end

            surface.SetFont("Toggle Buttons")
            surface.SetTextColor(Color(255, 255, 255, 255))
            local text = "Reset To Spawn"
            local tw, th = surface.GetTextSize(text)
            surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
            surface.DrawText(text)
            surface.SetDrawColor(btnColor)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(PANEL_BORDER)
            surface.DrawOutlinedRect(0, 0, w, h)

        end
    end

    mainPanel.Paint = function(self,w,h)
    surface.SetDrawColor(PANEL_FILL)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(PANEL_BORDER)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    -- after drawing all the buttons, size the panel
    local nHeight = padding * (totalBtns + 1) + btnHeight * totalBtns
    mainPanel:SetSize(width, nHeight)
    posXOpen = ScrW() - width - padding
    posXClose = ScrW() + width
    posY = ScrH() / 2 - nHeight / 2
end

hook.Add("OnContextMenuOpen", "Display the context menu", function()
    -- Open admin menu if Alt+C is pressed.
    if (input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)) and IsValid(LocalPlayer()) and LocalPlayer():IsAdmin() then
        showCommandMenu()
        return
    end

    if (LocalPlayer():Team() != TEAM_PROPS and
        LocalPlayer():Team() != TEAM_HUNTERS or
        !LocalPlayer():Alive()) then return end
    if (mainPanel and mainPanel:IsVisible()) then
        mainPanel:SetVisible(false)
    end
    DrawContextMenu()

    timer.Remove("hide context menu")
    mainPanel:MoveTo(posXOpen, posY, deltaTime, 0, 1)
    mainPanel:SetVisible(true)
    mainPanel:MakePopup()
    mainPanel:SetKeyboardInputEnabled(false)
end)

hook.Add("OnContextMenuClose", "Close the context menu", function()
    if (LocalPlayer():Team() != TEAM_PROPS and
        LocalPlayer():Team() != TEAM_HUNTERS or
        !LocalPlayer():Alive()) then return end

    -- bail if the menu isn't open
    if mainPanel == nil then return end

    mainPanel:MoveTo(posXClose, posY, deltaTime, 0, 1)
    mainPanel:SetKeyboardInputEnabled(true)
    -- make sure it's not open before we kill it
    timer.Remove("hide context menu")
    timer.Create("hide context menu",deltaTime, 1, function ()
        mainPanel:SetVisible(false)
    end)
end)
