hook.Add( "PlayerButtonDown", "LockRotationKeyPress", function( ply, button )
	if ( button == KEY_R &&
	     ply:Team() == TEAM_PROPS &&
	     ply:Alive() &&
	     IsValid( ply:GetProp() )
	) then
        net.Start( "Prop Angle Lock" )
            net.WriteBit( !ply.wantAngleLock )
            net.WriteAngle( ply:GetProp():GetAngles() )
        net.SendToServer()
	end
end )

hook.Add( "PlayerButtonDown", "EnableTiltKeyPress", function( ply, button )
	if ( button == KEY_T &&
	     ply:Team() == TEAM_PROPS &&
	     ply:Alive() &&
	     IsValid( ply:GetProp() )
	) then
        net.Start( "Prop Pitch Enable" )
            net.WriteBit( !LocalPlayer().wantPitchEnable )
        net.SendToServer()
	end
end )
