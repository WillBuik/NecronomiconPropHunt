
--[[ All network strings should be precached HERE ]]--
hook.Add("Initialize", "Precache all network strings", function()
    util.AddNetworkString("Death Notice")
    util.AddNetworkString("Class Selection")
    util.AddNetworkString("Taunt Selection")
    util.AddNetworkString("Taunt Selection BROADCAST")
    util.AddNetworkString("Help")
    util.AddNetworkString("Round Update")
    util.AddNetworkString("Player Death")
    util.AddNetworkString("Prop Update")
    util.AddNetworkString("Reset Prop")
    util.AddNetworkString("Selected Prop")
    util.AddNetworkString("Prop Angle Lock")
    util.AddNetworkString("Prop Angle Snap")
    util.AddNetworkString("Prop Pitch Enable")
    util.AddNetworkString("Hunter Hint Updown")
    util.AddNetworkString("AutoTaunt Update")
    util.AddNetworkString("Prop Roll")
    util.AddNetworkString("Popup Open")
    util.AddNetworkString("BSOD Open")
    util.AddNetworkString("Reset To Spawn")
    util.AddNetworkString("Unstick Prop")
    util.AddNetworkString("Ghost Door")
end)

net.Receive("Class Selection", function(len, ply)
    local chosen = net.ReadUInt(32)
    SetTeam(ply, chosen)
end)

net.Receive("Taunt Selection", function(len, ply)
    local taunt = net.ReadString()
    local pitch = net.ReadUInt(8)
    if (!QMenuAntiAbuse(ply)) then
        SendTaunt(ply, taunt, pitch)
    end
end)

--[[ When a player presses +use on a prop ]]--
net.Receive("Selected Prop", function(len, ply)
    local ent = net.ReadEntity()

    if (ply.pickupProp or !playerCanBeEnt(ply, ent)) then return end
    local oldHP = ply:GetProp().health
    SetPlayerProp(ply, ent, PROP_CHOSEN_SCALE)
    ply:GetProp().health = oldHP
end)

--[[ When a player wants to lock world angles on their prop ]]--
net.Receive("Prop Angle Lock", function(len, ply)
    local shouldAngleLock = net.ReadBit() == 1
    local propAngle = net.ReadAngle()
    ply:SetPropAngleLocked(shouldAngleLock)
    ply:SetPropLockedAngle(propAngle)

    if (IsValid(ply:GetProp())) then
        -- We should investigate why this angle doesn't naturally stay in sync
        propAngle = Angle(propAngle.p, propAngle.y, ply:GetPropRollAngle())
        ply:GetProp():SetAngles(propAngle)
        ResetPropToProp(ply)
    end
end)

--[[ When a player wants enable pitch on their prop ]]--
net.Receive("Prop Pitch Enable", function(len, ply)
    local shouldPitchEnable = net.ReadBit() == 1
    ply:SetPropPitchEnabled(shouldPitchEnable)
end)

net.Receive("Hunter Hint Updown", function(len, ply)
    local closestPropTaunting = GetClosestTaunter(ply)
    if (closestPropTaunting != nil) then
        local heightDiff = closestPropTaunting:GetPos().z - ply:GetPos().z
        if (heightDiff > ply:GetViewOffset().z) then
            ply:SetEyeAngles( ply:EyeAngles() + Angle( -15, 0, 0 ) )
        elseif (heightDiff < 0) then
            ply:SetEyeAngles( ply:EyeAngles() + Angle( 15, 0, 0 ) )
        end
    end
end)

--[[ When a player wants toggle world angle snapping on their prop ]]--
net.Receive("Prop Angle Snap", function(len, ply)
    local shouldAngleSnap = net.ReadBit() == 1
    ply:SetPropAngleSnapped(shouldAngleSnap)
end)

--[[ Adjust the prop roll angle ]]--
net.Receive("Prop Roll", function(len, ply)
    local rollAngleToAdd = net.ReadInt(16)
    local newRollAngle = (ply:GetPropRollAngle() + rollAngleToAdd + 180) % 360 - 180
    ply:SetPropRollAngle(newRollAngle)
end)

net.Receive("Unstick Prop", function(len, ply)
    UnstickPlayer(ply, 10)
end)

net.Receive("Reset To Spawn", function(len, ply)
    ply:SetPos(table.Random(team.GetSpawnPoints(ply:Team())):GetPos())
    UnstickPlayer(ply, 10)
end)

--[[ When a ghost prop presses +use on a prop ]]--
net.Receive("Ghost Door", function(len, ply)
    if (CurTime() < ply:GetTimeOfNextDoorOpen()) then return end
    local door = net.ReadEntity()
    if (!IsValid(door) or !table.HasValue(DOORS, door:GetClass())) then return end

    ply:SetTimeOfNextDoorOpen(CurTime() + PROP_GHOST_DOOR_WAIT)
    door:Fire("Toggle")
end)