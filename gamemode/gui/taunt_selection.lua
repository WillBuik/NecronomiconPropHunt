local padding = 10
local width = 250
local height = 200
local btnWidth = width
local btnHeight = 50
local tauntPanel
local pitchSlider

local function playTaunt(taunt, pitch)
    -- Only annoy the server if it looks like we can taunt right now.  (The
    -- server does its own checks, so we don't *need* this guard, but it can't
    -- hurt!)
    if !LocalPlayer():CanTauntAt(CurTime()) then return end

    net.Start("Taunt Selection")
        net.WriteString(taunt)
        net.WriteUInt(pitch, 8)
    net.SendToServer()

    pitchSlider:SetValue(pitch)
end


local function tauntSelection(player)
    local TAUNTS
    if (player:Team() == TEAM_PROPS) then
        TAUNTS = PROP_TAUNTS
    else
        TAUNTS = HUNTER_TAUNTS
    end


    tauntPanel = vgui.Create("DPanel")
        tauntPanel:SetSize(width + padding * 4, height + padding * 5 + btnHeight * 2)
        tauntPanel:Center()
        tauntPanel:SetVisible(true)
        tauntPanel:SetPaintBackground(false)
        tauntPanel:MakePopup()

    local prettyPanel = vgui.Create("DPanel", tauntPanel)
        prettyPanel:SetPos(padding, padding)
        prettyPanel:SetSize(width + padding * 2, height + padding * 3 + btnHeight * 2)

    local exitBtn = vgui.Create("DImageButton", tauntPanel)
        exitBtn:SetImage("icon16/cancel.png")
        exitBtn:SizeToContents()
        local ebw = exitBtn:GetSize() / 2
        exitBtn:SetPos(width + padding * 3 - ebw, padding - ebw)
        exitBtn.DoClick = function()
            tauntPanel:Remove()
        end

    -- Remember what pitch the player last selected in this UI.
    local pitch = 100
    if (player.lastSelectedPitch != nil) then
        pitch = player.lastSelectedPitch
    end

    pitchSlider = vgui.Create("DNumSlider", prettyPanel)
        pitchSlider:SetText("Pitch")
        pitchSlider:SetMin(TAUNT_MIN_PITCH)
        pitchSlider:SetMax(TAUNT_MAX_PITCH)
        pitchSlider:SetDecimals(0)
        pitchSlider:SetValue(pitch)
        pitchSlider:SetWide(width)
        pitchSlider:SetPos(padding * 2, height + btnHeight + padding * 3)

    local tauntList = vgui.Create("DListView", prettyPanel)
        tauntList:SetMultiSelect(false)
        tauntList:SetSize(width, height)
        tauntList:SetPos(padding, padding)
        tauntList:AddColumn("Select A Taunt")
        for k, v in orderedPairs(TAUNTS) do
            tauntList:AddLine(k, v)
        end
        tauntList.OnClickLine = function(parent, line, isSelected)
            local selectedPitch = pitchSlider:GetValue()
            player.lastSelectedPitch = selectedPitch
            playTaunt(line:GetValue(2), selectedPitch)
        end

    local randomBtn = vgui.Create("DButton", prettyPanel)
        randomBtn:SetText("")
        randomBtn:SetSize(btnWidth, btnHeight)
        randomBtn:SetPos(padding, height + padding * 2)
        randomBtn.DoClick = function()
            playTaunt(RandomTaunt(player), RandomPitch())
        end

    -- Painting
    prettyPanel.Paint = function(self, w, h)
        surface.SetDrawColor(PANEL_FILL)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(PANEL_BORDER)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    randomBtn.Paint = function(self, w, h)
        local btnColor = Color(0, 0, 255, 100)

        if (randomBtn:IsHovered()) then
            btnColor.a = btnColor.a + 50
        end

        surface.SetFont("Toggle Buttons")
        surface.SetTextColor(Color(255, 255, 255, 255))
        local text = "Play A Random Taunt"
        local tw, th = surface.GetTextSize(text)
        surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
        surface.DrawText(text)
        surface.SetDrawColor(btnColor)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(PANEL_BORDER)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

end

hook.Add("OnSpawnMenuOpen", "Display the taunt menu", function()
    ply = LocalPlayer()
    ply.tauntMenuOpened = CurTime()
    if !IsValid(ply) or !ply:CanTauntNowOrLater() then return end
    if (tauntPanel and tauntPanel:IsVisible()) then
        tauntPanel:SetVisible(false)
    end
    tauntSelection(ply)
    tauntPanel:SetVisible(true)
    tauntPanel:MakePopup()
    tauntPanel:SetKeyboardInputEnabled(false)
end)

hook.Add("OnSpawnMenuClose", "Close the context menu", function()
    ply = LocalPlayer()
    if (ply.tauntMenuOpened and
        ply.tauntMenuOpened + 0.4  > CurTime() and
        ply:CanTauntAt(CurTime())
    ) then
        local taunt = RandomTaunt(ply)
        local pitch = RandomPitch()
        net.Start("Taunt Selection")
            net.WriteString(taunt)
            net.WriteUInt(pitch, 8)
        net.SendToServer()
    end
    if (!tauntPanel) then return end
    tauntPanel:SetKeyboardInputEnabled(true)
    tauntPanel:SetVisible(false)
end)
