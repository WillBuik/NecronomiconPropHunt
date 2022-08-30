local padding = 10
local width = 300
local height = 400
local btnWidth = width
local btnHeight = 50
local searchHeight = 25

local TAUNT_MENU_DELAY = 0.07
local TAUNT_MENU_SHORT_PRESS = 0.25
local TAUNT_SELECTION_TIMER_ID = "SHOW_TAUNT_SELECTION_MENU"

local tauntPanel = nil
local searchTextEntry = nil

-- Returns true if the taunt menu is visible and in search mode.
local function tauntMenuIsSearching()
    if tauntPanel != nil then
        return tauntPanel:IsKeyboardInputEnabled()
    end
    return false
end

-- Enable taunt search and focus the search bar.
local function tauntMenuEnableSearch()
    if tauntPanel == nil or searchTextEntry == nil then return end
    tauntPanel:SetKeyboardInputEnabled(true)
    searchTextEntry:RequestFocus()
end

-- Cancels the taunt menu display timer and returns true if it was running.
local function cancelTauntMenuAfter()
    if timer.Exists(TAUNT_SELECTION_TIMER_ID) then
        -- This was a short press, play a random taunt and cancel the menu timer
        timer.Remove(TAUNT_SELECTION_TIMER_ID)
        return true
    end
    return false
end

-- Close the taunt menu.
local function hideTauntMenu()
    cancelTauntMenuAfter()
    if tauntPanel == nil then return end
    tauntPanel:Remove()
    tauntPanel = nil
    searchTextEntry = nil
end

local function playTaunt(taunt, pitch)
    -- Only annoy the server if it looks like we can taunt right now.  (The
    -- server does its own checks, so we don't *need* this guard, but it can't
    -- hurt!)
    if taunt == nil or taunt:len() == 0 or !LocalPlayer():CanTauntAt(CurTime()) then return false end

    net.Start("Taunt Selection")
        net.WriteString(taunt)
        net.WriteUInt(pitch, 8)
    net.SendToServer()

    return true
end

local function getSearchString(str)
    return str:lower():gsub("[- ',._\\(\\)!:;]", "")
end

-- Create and show the taunt selection menu.
local function createTauntMenu()
    local player = LocalPlayer()
    local TAUNTS
    if (player:Team() == TEAM_PROPS) then
        TAUNTS = PROP_TAUNTS
    else
        TAUNTS = HUNTER_TAUNTS
    end

    tauntPanel = vgui.Create("EditablePanel")
        tauntPanel:SetSize(width + padding * 4, height + padding * 6 + searchHeight + btnHeight * 2)
        tauntPanel:Center()
        tauntPanel:MakePopup()

    local prettyPanel = vgui.Create("DPanel", tauntPanel)
        prettyPanel:SetPos(padding, padding)
        prettyPanel:SetSize(width + padding * 2, height + padding * 4 + searchHeight + btnHeight * 2)

    local exitBtn = vgui.Create("DImageButton", tauntPanel)
        exitBtn:SetImage("icon16/cancel.png")
        exitBtn:SizeToContents()
        local ebw = exitBtn:GetSize() / 2
        exitBtn:SetPos(width + padding * 3 - ebw, padding - ebw)
        exitBtn.DoClick = function()
            hideTauntMenu()
        end

    searchTextEntry = vgui.Create("DTextEntry", prettyPanel)
        searchTextEntry:SetPlaceholderText("Search... (Click or Ctrl+Q)")
        searchTextEntry:SetEditable(true)
        searchTextEntry:SetSize(width, searchHeight)
        searchTextEntry:SetPos(padding, padding)
        searchTextEntry.OnGetFocus = function(self)
            tauntMenuEnableSearch()
        end

    -- Remember what pitch the player last selected in this UI.
    local pitch = 100
    if (player.lastSelectedPitch != nil) then
        pitch = player.lastSelectedPitch
    end

    local pitchSlider = vgui.Create("DNumSlider", prettyPanel)
        pitchSlider:SetText("Pitch")
        pitchSlider:SetMin(TAUNT_MIN_PITCH)
        pitchSlider:SetMax(TAUNT_MAX_PITCH)
        pitchSlider:SetDecimals(0)
        pitchSlider:SetValue(pitch)
        pitchSlider:SetWide(width)
        pitchSlider:SetPos(padding * 2, height + searchHeight + btnHeight + padding * 4)

    local tauntList = vgui.Create("DListView", prettyPanel)
        tauntList:SetMultiSelect(false)
        tauntList:SetSize(width, height)
        tauntList:SetPos(padding, padding * 2 + searchHeight)
        tauntList:AddColumn("Select A Taunt")
        tauntList.OnClickLine = function(parent, line, isSelected)
            local selectedPitch = pitchSlider:GetValue()
            player.lastSelectedPitch = selectedPitch
            if playTaunt(line:GetValue(2), selectedPitch) then
                hideTauntMenu()
            end
        end
    
    local function filterTauntList()
        local tauntSearch = getSearchString(searchTextEntry:GetText())
        local noMatchingTaunts = true
        tauntList:Clear()
        for tauntDisplayName, taunt in orderedPairs(TAUNTS) do
            local tauntSearchName = getSearchString(tauntDisplayName)
            if tauntSearch:len() == 0 or tauntSearchName:find(tauntSearch, 0, true) != nil then
                tauntList:AddLine(tauntDisplayName, taunt)
                noMatchingTaunts = false
            end
        end
        if noMatchingTaunts == true then
            tauntList:AddLine("No Matching Taunts", nil)
        end
    end
    
    local function playRandomTauntInList()
        if playTaunt(table.Random(tauntList:GetLines()):GetValue(2), RandomPitch()) then
            hideTauntMenu()
        end
    end

    filterTauntList()
    searchTextEntry.OnChange = function()
        filterTauntList()
    end
    searchTextEntry.OnEnter = playRandomTauntInList

    local randomBtn = vgui.Create("DButton", prettyPanel)
        randomBtn:SetText("")
        randomBtn:SetSize(btnWidth, btnHeight)
        randomBtn:SetPos(padding, height + searchHeight + padding * 3)
        randomBtn.DoClick = playRandomTauntInList

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

-- Open the taunt menu.
local function showTauntMenu()
    cancelTauntMenuAfter()
    if tauntPanel == nil then
        createTauntMenu()
        tauntPanel:SetKeyboardInputEnabled(false)
    end
end

-- Open the taunt menu after a short delay.
local function showTauntMenuAfter(delay)
    -- Start/restart timer to show the selection menu or taunt on a quick press
    cancelTauntMenuAfter()
    timer.Create(TAUNT_SELECTION_TIMER_ID, delay, 1, showTauntMenu)
end

-- Hooks for taunt selection 'Q' button press.
hook.Add("OnSpawnMenuOpen", "Display the taunt menu", function()
    if input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL) then
        showTauntMenu()
        tauntMenuEnableSearch()
        LocalPlayer().tauntMenuOpenTime = nil
    else
        showTauntMenuAfter(TAUNT_MENU_DELAY)
        LocalPlayer().tauntMenuOpenTime = CurTime()
    end
end)

-- Hooks for taunt selection 'Q' button release.
hook.Add("OnSpawnMenuClose", "Close the context menu", function()
    -- Cancel the open timer, does nothing if the dialog is already open.
    cancelTauntMenuAfter()

    -- Check if this was a short press, if so play a random taunt.
    local ply = LocalPlayer()
    if (ply.tauntMenuOpenTime and
        ply.tauntMenuOpenTime + TAUNT_MENU_SHORT_PRESS  > CurTime()) then
        playTaunt(RandomTaunt(ply), RandomPitch())
    end

    -- Hide the taunt menu if the user hasn't focused the search bar.
    if !tauntMenuIsSearching() then
        hideTauntMenu()
    end
end)
