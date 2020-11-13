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
            net.WriteBit(!LocalPlayer():IsPropPitchEnabled())
        net.SendToServer()
    end
end)

hook.Add("KeyPress", "PressShiftRollHunter", function(ply, key)
    if (key == IN_SPEED and
         ply:Team() == TEAM_HUNTERS and
         ply:Alive()
    ) then
        ply:Freeze(true)
        net.Start("Hunter Roll")
            net.WriteBit(true)
        net.SendToServer()
    end
end)

hook.Add("KeyRelease", "ReleaseShiftRollHunter", function(ply, key)
    if (key == IN_SPEED and
         ply:Team() == TEAM_HUNTERS and
         ply:Alive()
    ) then
        ply:Freeze(false)
        net.Start("Hunter Roll")
            net.WriteBit(false)
        net.SendToServer()
    end
end)
