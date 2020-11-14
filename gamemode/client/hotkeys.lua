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

hook.Add("InputMouseApply", "propRoll", function(cmd, x, y, ang)
    local rollAngle = cmd:GetMouseWheel() * 5
    if ( LocalPlayer():Team() == TEAM_PROPS and
         LocalPlayer():Alive() and
         IsValid(ply:GetProp())
    ) then
        net.Start("Prop Roll")
            net.WriteInt(rollAngle, 16)
        net.SendToServer()
    end
    cmd:SetMouseWheel(0)
    return true
end)
