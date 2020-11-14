
--[[ All network strings should be precached HERE ]]--
hook.Add("Initialize", "Precache all network strings", function()
    util.AddNetworkString("Death Notice")
    util.AddNetworkString("Class Selection")
    util.AddNetworkString("Taunt Selection")
    util.AddNetworkString("Help")
    util.AddNetworkString("Round Update")
    util.AddNetworkString("Player Death")
    util.AddNetworkString("Prop Update")
    util.AddNetworkString("Reset Prop")
    util.AddNetworkString("Selected Prop")
    util.AddNetworkString("Prop Angle Lock")
    util.AddNetworkString("Prop Angle Snap")
    util.AddNetworkString("Prop Pitch Enable")
    util.AddNetworkString("Hunter Roll")
    util.AddNetworkString("AutoTaunt Update")
    util.AddNetworkString("Update Taunt Times")
    util.AddNetworkString("Remove Prop")
    util.AddNetworkString("Prop Roll")
end)

net.Receive("Class Selection", function(len, ply)
    local chosen = net.ReadUInt(32)
    SetTeam(ply, chosen)
end)

net.Receive("Taunt Selection", function(len, ply)
    local taunt = net.ReadString()
    local pitch = net.ReadUInt(8)
    SendTaunt(ply, taunt, pitch)
end)

--[[ When a player presses +use on a prop ]]--
net.Receive("Selected Prop", function(len, ply)
    local ent = net.ReadEntity()

    if (ply.pickupProp or !playerCanBeEnt(ply, ent)) then return end
    local oldHP = ply:GetProp().health
    SetPlayerProp(ply, ent, PROP_CHOSEN_SCALE)
    ply:GetProp().health = oldHP
end)

net.Receive("Update Taunt Times", function()
    local id = net.ReadUInt(8)
    local ply = player.GetByID(id)
    local nextTaunt = net.ReadFloat()
    local lastTaunt = net.ReadFloat()
    local autoTauntInterval = net.ReadFloat()

    ply.nextTaunt = nextTaunt
    ply.lastTaunt = lastTaunt
    ply.autoTauntInterval = autoTauntInterval
end)

--[[ When a player wants to lock world angles on their prop ]]--
net.Receive("Prop Angle Lock", function(len, ply)
    local shouldAngleLock = net.ReadBit() == 1
    local propAngle = net.ReadAngle()
    ply:SetPropAngleLocked(shouldAngleLock)
    ply:SetPropLockedAngle(propAngle)

    if (IsValid(ply:GetProp())) then
        -- We should investigate why this angle doesn't naturally stay in sync
        ply:GetProp():SetAngles(propAngle)
        local tHitboxMin, tHitboxMax = PropHitbox(ply)

        --Adjust Position for no stuck
        local foundSpot = FindSpotFor(ply, tHitboxMin, tHitboxMax)
        ply:SetPos(foundSpot)

        UpdatePlayerPropHitbox(ply, tHitboxMin, tHitboxMax)
    end
end)

--[[ When a player wants enable pitch on their prop ]]--
net.Receive("Prop Pitch Enable", function(len, ply)
    local shouldPitchEnable = net.ReadBit() == 1
    ply:SetPropPitchEnabled(shouldPitchEnable)
end)

net.Receive("Hunter Roll", function(len, ply)
    local shouldRoll = net.ReadBit() == 1

    local closestPlyTaunting = GetClosestTaunter(ply)
    local newPitch = 0
    if (closestPlyTaunting != nil) then
        local vectorBetween = closestPlyTaunting:GetPos() - ply:GetPos()
        local pitchFromAngle = vectorBetween:Angle().p
        newPitch = pitchFromAngle / (math.abs(pitchFromAngle))
    end
    local oldAngle = ply:EyeAngles()
    local newAngle = Angle(newPitch, oldAngle.y, 0)
    if (shouldRoll) then
       newAngle:Add(Angle(0,0, -90))
    end
    ply:SetEyeAngles(newAngle)
end)

--[[ When a player wants toggle world angle snapping on their prop ]]--
net.Receive("Prop Angle Snap", function(len, ply)
    local shouldAngleSnap = net.ReadBit() == 1
    ply:SetPropAngleSnapped(shouldAngleSnap)
end)

--[[ When a player Removes a prop with the ability ]]--
net.Receive("Remove Prop", function(len, ply)
    local propToRemove = net.ReadEntity()
    if (IsValid(propToRemove)) then
        propToRemove:Remove()
    end
end)

--[[ Adjust the prop roll angle ]]--
net.Receive("Prop Roll", function(len, ply)
    local rollAngleToAdd = net.ReadInt(16)
    local newRollAngle = (ply:GetPropRollAngle() + rollAngleToAdd + 180) % 360 - 180
    ply:SetPropRollAngle(newRollAngle)
    if (IsValid(ply:GetProp())) then
        -- We should investigate why this angle doesn't naturally stay in sync
        local propAngle = ply:EyeAngles() + Angle(0, 0, newRollAngle)
        ply:GetProp():SetAngles(propAngle)
        local tHitboxMin, tHitboxMax = PropHitbox(ply)

        --Adjust Position for no stuck
        local foundSpot = FindSpotFor(ply, tHitboxMin, tHitboxMax)
        ply:SetPos(foundSpot)

        UpdatePlayerPropHitbox(ply, tHitboxMin, tHitboxMax)
    end
end)