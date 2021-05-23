--[[ Rounds are handled here, obviously ]]--

-----------------------------------
-- This module invokes the following server-side hooks:
--   OBJHUNT_RoundStart
--   OBJHUNT_HuntersReleased
--   OBJHUNT_RoundEnd
--   OBJHUNT_RoundLimit
--
-- In general, the sequence of events during a round state change is:
--   1. Update relevant game state (e.g. respawn players, set round.startTime)
--   2. Fire hook (e.g. OBJHUNT_RoundStart)
--   3. Broadcast round update to clients
-----------------------------------

-- this var is used outside of this file
round = {}
round.state           = ROUND_WAIT
round.current         = 0
round.startTime       = 0          -- only meaningful when state >= ROUND_IN
round.huntersReleased = false      -- only meaningful when state == ROUND_IN
round.endTime         = 0          -- only meaningful when state == ROUND_END
round.winner          = "Newbrict" -- only meaningful when state == ROUND_END

local function SendRoundUpdate(sendMethod)
    net.Start("Round Update")
        net.WriteUInt(round.state, 8)
        net.WriteUInt(round.current, 8)
        net.WriteUInt(round.startTime, 32)
        net.WriteUInt(round.endTime, 32)
        net.WriteBit(round.huntersReleased)
        net.WriteUInt(CurTime(), 32)
    sendMethod()
end

local function SwapTeams()
    local hunters = team.GetPlayers(TEAM_HUNTERS)
    local props = team.GetPlayers(TEAM_PROPS)

    for _, v in pairs(hunters) do
        if (IsValid(v)) then
            RemovePlayerProp(v)
            v:SetTeam(TEAM_PROPS)
            player_manager.SetPlayerClass(v, "player_prop")
        end
    end

    for _, v in pairs(props) do
        if (IsValid(v)) then
            RemovePlayerProp(v)
            v:SetTeam(TEAM_HUNTERS)
            player_manager.SetPlayerClass(v, "player_hunter")
        end
    end
end

local function RespawnTeams()
    local hunters = team.GetPlayers(TEAM_HUNTERS)
    local props = team.GetPlayers(TEAM_PROPS)

    local taunt_seeker = math.random(#hunters)
    local taunt_grenade = math.random(#hunters)
    while (#hunters > 1 and taunt_seeker == taunt_grenade) do
        taunt_grenade = math.random(#hunters)
    end
    for i, v in pairs(hunters) do
        if (IsValid(v)) then
            v:KillSilent()
            v:Spawn()
            if (i == taunt_seeker) then
                v:Give("weapon_hunter_special_tauntseeker")
                v:StripWeapon("weapon_hunter_special_tauntgranade")
            elseif (i == taunt_grenade) then
                v:Give("weapon_hunter_special_tauntgranade")
                v:StripWeapon("weapon_hunter_special_tauntseeker")
            end
        end
    end

    for _, v in pairs(props) do
        if (IsValid(v)) then
            v:KillSilent()
            v:Spawn()
        end
    end
end

local function WaitRound()
    -- wait for everyone to connect and what not
    local mapTime = CurTime()
    local spectators = team.GetPlayers(TEAM_SPECTATOR)
    if (mapTime < OBJHUNT_PRE_ROUND_TIME and #spectators != 0) then return end

    -- make sure we have at least one player on each team
    local hunters = team.GetPlayers(TEAM_HUNTERS)
    local props = team.GetPlayers(TEAM_PROPS)

    if (#props == 0 or #hunters == 0) then return end

    -- reset points here for now
    for _, v in pairs(player.GetAll()) do
        v:SetPropPoints(0)
        v.propHistory = EmptySet()
        v.tauntHistory = EmptySet()
    end

    round.state = ROUND_START
end

local function StartRound()
    -- reset the map
    game.CleanUpMap(false, {"player_prop_ent"})
    -- respawn everyone, swap teams if it's not the 0th round
    if (round.current == 0) then
        RespawnTeams()
    else
        SwapTeams()
        RespawnTeams()
    end
    round.current = round.current + 1
    round.startTime = CurTime()
    round.state = ROUND_IN
    round.huntersReleased = false

    print("Round " .. round.current .. " is starting")

    for _, v in pairs(player.GetAll()) do
        -- remove god mode from everyone
        v:GodDisable()

        -- reset previous round data
        v:SetPropAngleLocked(false)
        v:SetPropLockedAngle(Angle(0,0,0))
        v:SetPropPitchEnabled(false)
        v:SetPropAngleSnapped(false)
        v:SetPropRollAngle(0)
        -- taunt data
        v:SetLastTauntTime(CurTime())
        v:SetLastTauntDuration(1)

        if (v:Team() == TEAM_HUNTERS) then
            -- freeze all the hunters
            v:Freeze(true)
            -- Give ammo to hunters scaled with number of props on map
            v:GiveAmmo(math.floor(GetGlobalInt("NumPropsOnMap", 200) / 35 + 0.5), "AR2AltFire", true)

            v:SetPlayerColor(PlayerToAccentColor(v))
        end
    end

    hook.Call("OBJHUNT_RoundStart")

    -- send data to clients
    SendRoundUpdate(function() return net.Broadcast() end)
end

local function InRound()
    local roundTime = CurTime() - round.startTime
    local hunters = GetLivingPlayers(TEAM_HUNTERS)
    local props = GetLivingPlayers(TEAM_PROPS)

    -- Has anyone won yet?
    local winner = nil
    if (roundTime >= OBJHUNT_ROUND_TIME or #hunters == 0) then
        winner = "Props"
    elseif (#props == 0) then
        winner = "Hunters"
    end

    if (winner) then
        round.state = ROUND_END
        round.endTime = CurTime()
        round.winner = winner
        print(winner .. " Win!")
        for _, v in pairs(player.GetAll()) do
            v:PrintMessage(HUD_PRINTCENTER, winner .. " Win!")
            -- give everyone god mode until round starts again
            v:GodEnable()
        end
        hook.Call("OBJHUNT_RoundEnd")
        SendRoundUpdate(function() return net.Broadcast() end)
        return
    end

    -- unfreeze the hunters after their time is up
    if (roundTime > OBJHUNT_HIDE_TIME and !round.huntersReleased) then
        print("Releasing hunters")
        for _, v in pairs(hunters) do
            v:Freeze(false)
        end
        round.huntersReleased = true
        hook.Call("OBJHUNT_HuntersReleased")
        SendRoundUpdate(function() return net.Broadcast() end)
    end

end

local function EndRound()
    -- if we've played enough times on this map
    if (round.current >= OBJHUNT_ROUNDS) then
        -- no longer need the round orchestrator
        hook.Remove("Tick", "Round orchestrator")
        MapVote.Start(30, false, MAPS_SHOWN_TO_VOTE, {"cs_", "ph_", "gm_ww"})

        print("Map voting should start now")
        hook.Call("OBJHUNT_RoundLimit")
        return
    end

    -- make sure we have at least one player on each team
    local hunters = team.GetPlayers(TEAM_HUNTERS)
    local props = team.GetPlayers(TEAM_PROPS)
    if (#props == 0 or #hunters == 0) then return end

    -- start the round after we've waiting long enough
    local waitTime = CurTime() - round.endTime
    if (waitTime >= OBJHUNT_POST_ROUND_TIME) then
        round.state = ROUND_START
    end

end

local roundHandler = {}
roundHandler[ROUND_WAIT]  = WaitRound
roundHandler[ROUND_START] = StartRound
roundHandler[ROUND_IN]    = InRound
roundHandler[ROUND_END]   = EndRound

-- start the round orchestrator when the game has initialized
hook.Add("Initialize", "Begin round functions", function()
    hook.Add("Tick", "Round orchestrator", function()
        roundHandler[round.state]()
    end)
end)

hook.Add("PlayerInitialSpawn", "Send Round data to client", function(ply)
    -- sent to only the player, one time per join thing
    SendRoundUpdate(function() return net.Send(ply) end)
end)
