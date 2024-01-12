local padding = 10
local width = 300
local height = 400
local btnWidth = width
local btnHeight = 50
local searchHeight = 25

local commandPanel = nil
local searchTextEntry = nil

local COMMANDS = {}

-- Enable command search and focus the search bar.
local function commandMenuEnableSearch()
    if commandPanel == nil or searchTextEntry == nil then return end
    commandPanel:SetKeyboardInputEnabled(true)
    searchTextEntry:RequestFocus()
end

-- Close the command menu.
local function hideCommandMenu()
    if commandPanel == nil then return end
    commandPanel:Remove()
    commandPanel = nil
    searchTextEntry = nil
end

local function getSearchString(str)
    return str:lower():gsub("[- ',._\\(\\)!:;]", "")
end

-- Create and show the command selection menu.
local function createCommandMenu()
    commandPanel = vgui.Create("EditablePanel")
        commandPanel:SetSize(width + padding * 4, height + padding * 6 + searchHeight + btnHeight)
        commandPanel:Center()
        commandPanel:MakePopup()

    local prettyPanel = vgui.Create("DPanel", commandPanel)
        prettyPanel:SetPos(padding, padding)
        prettyPanel:SetSize(width + padding * 2, height + padding * 4 + searchHeight + btnHeight)

    local exitBtn = vgui.Create("DImageButton", commandPanel)
        exitBtn:SetImage("icon16/cancel.png")
        exitBtn:SizeToContents()
        local ebw = exitBtn:GetSize() / 2
        exitBtn:SetPos(width + padding * 3 - ebw, padding - ebw)
        exitBtn.DoClick = function()
            hideCommandMenu()
        end

    searchTextEntry = vgui.Create("DTextEntry", prettyPanel)
        searchTextEntry:SetPlaceholderText("Search...")
        searchTextEntry:SetEditable(true)
        searchTextEntry:SetSize(width, searchHeight)
        searchTextEntry:SetPos(padding, padding)
        searchTextEntry.OnGetFocus = function(self)
            commandMenuEnableSearch()
        end

    local commandList = vgui.Create("DListView", prettyPanel)
        commandList:SetMultiSelect(false)
        commandList:SetSize(width, height)
        commandList:SetPos(padding, padding * 2 + searchHeight)
        commandList:AddColumn("Select A Command")
        commandList.OnClickLine = function(parent, line, isSelected)
            local command = line:GetValue(2)
            if command != nil and tostring(command) != "" then
                local player = LocalPlayer()
                if IsValid(player) then
                    player:ConCommand(command)
                end
                hideCommandMenu()
            end
        end
    
    local function filterCommandList()
        local commandSearch = getSearchString(searchTextEntry:GetText())
        local noMatchingCommand = true
        commandList:Clear()
        for _, command in ipairs(COMMANDS) do
            local commandSearchName = getSearchString(command.display)
            if commandSearch:len() == 0 or commandSearchName:find(commandSearch, 0, true) != nil then
                commandList:AddLine(command.display, command.command)
                noMatchingCommand = false
            end
        end
        if noMatchingCommand == true then
            commandList:AddLine("No Matching Commands", nil)
        end
    end

    local onEnterHandler = function()
        if #commandList:GetLines() == 1 then
            local command = commandList:GetLines()[1]:GetValue(2)
            if command != nil and tostring(command) != "" then
                local player = LocalPlayer()
                if IsValid(player) then
                    player:ConCommand(command)
                end
                hideCommandMenu()
            else
                searchTextEntry:RequestFocus()
            end
        else
            searchTextEntry:RequestFocus()
        end
    end

    filterCommandList()
    searchTextEntry.OnChange = function()
        filterCommandList()
    end
    searchTextEntry.OnEnter = onEnterHandler

    local randomCommandButtonHandler = function()
        hideCommandMenu()
    end

    local randomBtn = vgui.Create("DButton", prettyPanel)
        randomBtn:SetText("")
        randomBtn:SetSize(btnWidth, btnHeight)
        randomBtn:SetPos(padding, height + searchHeight + padding * 3)
        randomBtn.DoClick = randomCommandButtonHandler

    -- Painting
    prettyPanel.Paint = function(self, w, h)
        surface.SetDrawColor(PANEL_FILL)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(PANEL_BORDER)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    randomBtn.Paint = function(self, w, h)
        local btnColor = Color(0, 0, 255, 100)
        local text = "Run Random Command"

        if (randomBtn:IsHovered()) then
            text = "Kill Kevin"
            btnColor.a = btnColor.a + 50
        end

        surface.SetFont("Toggle Buttons")
        surface.SetTextColor(Color(255, 255, 255, 255))
        local tw, th = surface.GetTextSize(text)
        surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
        surface.DrawText(text)
        surface.SetDrawColor(btnColor)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(PANEL_BORDER)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
end

-- Open and focus the command menu (global)
function showCommandMenu()
    if commandPanel == nil then
        createCommandMenu()
        commandMenuEnableSearch()
    end
end

-- Add commands to the command list.
local function add_command(display, command)
    COMMANDS[#COMMANDS + 1] = {
        display = display,
        command = command
    }
end

-- Command list:
add_command("Pause Countdown",               "phd pause")
add_command("Resume Countdown",              "phd resume")
add_command("Reload Current Map",            "phd reload")
add_command("Call Map Vote",                 "phd mapvote")

add_command("  -- Debug *Use Caution* --",   "")
add_command("Enter Testmode",                "phd testmode")
add_command("Add Bot",                       "phd addbot")
add_command("List Taunt Durations",          "phd tauntinfo")
