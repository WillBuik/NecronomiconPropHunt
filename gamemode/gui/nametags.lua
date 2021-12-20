surface.CreateFont("Nametags",
{
    font = "Helvetica",
    size = 128,
    weight = 30,
    antialias = false,
    outline = true,
})

hook.Add("PostDrawOpaqueRenderables", "Draw Nametags", function()
    if (LocalPlayer():Team() != TEAM_HUNTERS and
        LocalPlayer():Team() != TEAM_PROPS) then return end

    local toTag = GetLivingPlayers(LocalPlayer():Team())

    if (LocalPlayer():Team() == TEAM_PROPS) then
        table.Add(toTag, GetLivingPlayers(TEAM_HUNTERS))
    end

    if (LocalPlayer():Team() == TEAM_HUNTERS) then
        local props = GetLivingPlayers(TEAM_PROPS)
        for _, v in pairs(props) do
            if (v:ObjIsDisguised()) then
                table.insert(toTag, v)
            end
        end
    end

    for _, v in pairs(toTag) do
        if (v == LocalPlayer()) then continue end

        local cOffset = Vector(0, 0, 10)
        local pos = v:GetPos() + v:GetViewOffset() + cOffset

        -- 'Sprite' like angles based on positional angles
        -- local pDiff = v:GetPos() - LocalPlayer():GetPos()
        -- angle between local player and target player
        --local pAng = (pDiff):Angle():Right():Angle()
        --local angle = Angle(0,0,90) + pAng

        -- 'Sprite' like angles based on view angle
        local angle = Angle(0,0,90) + LocalPlayer():GetAimVector():Angle():Right():Angle()

        local name = v:Nick()

        if (v:ObjIsDisguised() and LocalPlayer():Team() == TEAM_HUNTERS) then
            pos = v:GetPos() + LocalPlayer():GetViewOffset() + cOffset
            local hunters = team.GetPlayers(TEAM_HUNTERS)
            local disguiseIndex = 1
            for i, hunter in pairs(hunters) do
                if (hunter == LocalPlayer()) then
                    if i == #hunters then
                        disguiseIndex = 1
                    else
                        disguiseIndex = (i + 1)
                    end
                    break
                end
            end
            name = hunters[disguiseIndex]:Nick()
        end

        cam.Start3D2D(pos, angle, .05)
            surface.SetFont("Nametags")
            surface.SetTextColor(Color(255,255,255,255))
            local tw, th = surface.GetTextSize(name)
            surface.SetTextPos(-tw / 2, -th)
            surface.DrawText(name)
        cam.End3D2D()
    end
end)
