include("shared.lua")

local function KillTaunt(ply)
    if (ply.tauntPatch and ply.tauntPatch:IsPlaying()) then
        ply.tauntPatch:Stop()
    end
end

--[ Prop Updates ]--
net.Receive("Prop Update", function(length)
    -- set up the hitbox
    local tHitboxMax = net.ReadVector()
    local tHitboxMin = net.ReadVector()
    LocalPlayer():SetHull(tHitboxMin, tHitboxMax)
    LocalPlayer():SetHullDuck(tHitboxMin, tHitboxMax)

    -- prop height for views, change time for cooldown
    local propHeight = tHitboxMax.z - tHitboxMin.z
    LocalPlayer().propHeight = propHeight

    -- initialize third person if first prop
    local firstProp = LocalPlayer():GetPropLastChange() == 0
    if (firstProp) then
        LocalPlayer().wantThirdPerson = true
    end

end)

net.Receive("Reset Prop", function(length)
    LocalPlayer():ResetHull()
    LocalPlayer().wantThirdPerson = false
end)

round = {}
net.Receive("Round Update", function()
    round.state           = net.ReadInt(8)
    round.current         = net.ReadInt(8)
    round.startTime       = net.ReadInt(32)
    round.endTime         = net.ReadInt(32)
    round.huntersReleased = net.ReadBit() != 0
    round.roundPaused     = net.ReadBit() != 0
end)

net.Receive("Death Notice", function()
    local attacker = net.ReadString()
    local attackerTeam = net.ReadUInt(16)
    local verb = net.ReadString()
    local victim = net.ReadString()
    local victimTeam = net.ReadUInt(16)

    killicon.AddFont("kill", "Sharp HUD", verb, Color(255,255,255,255))
    GAMEMODE:AddDeathNotice(attacker, attackerTeam, "kill", victim, victimTeam)
end)

net.Receive("Display Respects", function()
    local attacker = net.ReadString()
    local attackerTeam = net.ReadUInt(16)
    local verb = net.ReadString()
    local victim = net.ReadString()
    local victimTeam = net.ReadUInt(16)
    
    killicon.AddFont(verb, "Sharp HUD Small", verb, Color(255,255,255,255))
    GAMEMODE:AddDeathNotice(attacker, attackerTeam, verb, victim, victimTeam)
end)

net.Receive("Taunt Selection BROADCAST", function()
    local taunt = net.ReadString()
    local pitch = net.ReadUInt(8)
    local id = net.ReadUInt(8)
    local ply = player.GetByID(id)

    if !IsValid(ply) then return end

    local s = Sound(taunt)
    -- need to delete the gc function so my ents remain
    ply.tauntPatch = CreateSound(ply, s)
    if (ply.tauntPatch.__gc) then
        local smeta = getmetatable(ply.tauntPatch)
        smeta.__gc = function()
        end
    end

    if (ply == LocalPlayer()) then
        -- Let's make the taunt less horrible for the player playing it
        ply.tauntPatch:SetSoundLevel(40)
    else
        ply.tauntPatch:SetSoundLevel(100)
    end
    ply.tauntPatch:PlayEx(1, pitch)

    -- old not stoppable method
    --EmitSound(taunt , ply:GetPos(), id, CHAN_AUTO, 1, 100, 2, pitch)
end)

net.Receive("Player Death", function()
    local id = net.ReadUInt(8)
    local ply = player.GetByID(id)
    KillTaunt(ply)
end)

-- disable default hud elements here
function GM:HUDShouldDraw(name)
    if (name == "CHudHealth" or name == "CHudBattery") then
        return false
    end
    return true
end

