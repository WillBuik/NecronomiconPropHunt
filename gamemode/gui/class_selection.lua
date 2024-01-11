surface.CreateFont("Sharp HUD",
{
    font = "Helvetica",
    size = 32,
    weight = 800,
    antialias = true,
    outline = false,
    shadow = true,
})

surface.CreateFont("Sharp HUD Small",
{
    font = "Helvetica",
    size = 24,
    weight = 800,
    antialias = true,
    outline = false,
    shadow = true,
})

local function SendTeam(chosen)
    net.Start("Class Selection")
        net.WriteUInt(chosen, 32)
    net.SendToServer()
end

local function classSelection()
    local padding = 10
    local btnHeight = 30
    local btnWidth  = 80
    local width   = 4 * btnWidth + 5 * padding
    local height  = btnHeight + 2 * padding
    local totalBtns = 0

    local classPanel = vgui.Create("DPanel")
    classPanel:SetSize(width + padding * 2, ScrH())
    classPanel:Center()
    classPanel:SetVisible(true)
    classPanel:SetPaintBackground(false)
    classPanel:MakePopup()

    local prettyPanel = vgui.Create("DPanel", classPanel)
    prettyPanel:SetSize(width, height)
    prettyPanel:Center()
    local px, py = prettyPanel:GetPos()

    local makeTeamBtn = function(team, teamText, teamColor)
        totalBtns = totalBtns + 1
        local btn = vgui.Create("DButton", prettyPanel)
        btn:SetText("")
        btn:SetSize(btnWidth, btnHeight)
        btn:SetPos(padding * totalBtns + btnWidth * (totalBtns - 1), padding)
        btn.DoClick = function()
            SendTeam(team)
            classPanel:Remove()
        end
        btn.Paint = function(self,w,h)
            local btnColor = table.Copy(teamColor)

            if (btn:IsHovered()) then
                btnColor.a = btnColor.a + 50
            end

            surface.SetFont("Toggle Buttons")
            surface.SetTextColor(Color(255,255,255,255))
            local text = teamText
            local tw, th = surface.GetTextSize(text)
            surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
            surface.DrawText(text)
            surface.SetDrawColor(btnColor)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(PANEL_BORDER)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
    end

    makeTeamBtn(TEAM_ANY, "Any", TEAM_ANY_COLOR)
    makeTeamBtn(TEAM_HUNTERS, "Hunter", TEAM_HUNTERS_COLOR)
    makeTeamBtn(TEAM_PROPS, "Prop", TEAM_PROPS_COLOR)
    makeTeamBtn(TEAM_SPECTATOR, "Spectator", PANEL_FILL)

    local exitBtn = vgui.Create("DImageButton", classPanel)
    exitBtn:SetImage("icon16/cancel.png")
    exitBtn:SizeToContents()
    local ebw = exitBtn:GetSize() / 2
    exitBtn:SetPos(width + px - ebw, py - ebw)
    exitBtn.DoClick = function()
        classPanel:Remove()
    end

    classPanel.Paint = function(self, w, h)
        --Derma_DrawBackgroundBlur(self, CurTime())

        surface.SetFont("Sharp HUD")
        surface.SetTextColor(255, 255, 255, 255)
        local textToDraw = "Select Your Team"
        local _, th = surface.GetTextSize(textToDraw)
        surface.SetTextPos(px, py - th)
        surface.DrawText(textToDraw)
    end

    prettyPanel.Paint = function(self,w,h)
        surface.SetDrawColor(PANEL_FILL)
        surface.DrawRect(0, 0, width, height)
        surface.SetDrawColor(PANEL_BORDER)
        surface.DrawOutlinedRect(0, 0, width, height)
    end
end

net.Receive("Class Selection", classSelection)
