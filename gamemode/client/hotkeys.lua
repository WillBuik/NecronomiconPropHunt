hook.Add("PlayerButtonDown", "LockRotationKeyPress", function(ply, button)
    if (button == KEY_R and
         ply:Team() == TEAM_PROPS and
         ply:Alive() and
         IsValid(ply:GetProp())
    ) then
        net.Start("Prop Angle Lock")
            net.WriteBit(!ply:IsPropAngleLocked())
            net.WriteAngle(ply:GetProp():GetAngles())
        net.SendToServer()
    end
end)

hook.Add("PlayerButtonDown", "EnableTiltKeyPress", function(ply, button)
    if (button == KEY_T and
         ply:Team() == TEAM_PROPS and
         ply:Alive() and
         IsValid(ply:GetProp())
    ) then
        net.Start("Prop Pitch Enable")
            net.WriteBit(!ply:IsPropPitchEnabled())
        net.SendToServer()
    end
end)

hook.Add("PlayerButtonDown", "RevertKeyPress", function(ply, button)
    if (button == KEY_Z and
         ply:Team() == TEAM_PROPS and
         ply:Alive() and
         IsValid(ply:GetProp())
    ) then
        net.Start("Prop Revert")
        net.SendToServer()
    end
end)

hook.Add("KeyPress", "PressShiftHunterHintUpdown", function(ply, key)
    if (key == IN_SPEED and
         ply:Team() == TEAM_HUNTERS and
         ply:Alive()
    ) then
        net.Start("Hunter Hint Updown")
        net.SendToServer()
    end
end)


function GM:PlayerBindPress(ply, bind, pressed)
    if (ply:Team() == TEAM_PROPS and
        ply:Alive() and
        IsValid(ply:GetProp()) and
        pressed
    ) then
        if (bind == "invnext") then
            net.Start("Prop Roll")
                net.WriteInt(PROP_ROLL_INCRIMENT, 16)
                net.SendToServer()
            return true
        elseif (bind == "invprev") then
            net.Start("Prop Roll")
            net.WriteInt(-1 * PROP_ROLL_INCRIMENT, 16)
            net.SendToServer()
            return true
        end
    end
end
