AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("server/autotaunt.lua")

function GM:PlayerInitialSpawn(ply)
    ply:SetTeam(TEAM_SPECTATOR)
    player_manager.SetPlayerClass(ply, "player_spectator")

    if (ply:IsBot()) then
        -- Auto add bots to the smaller team for testing.
        SetTeam(ply, TEAM_ANY)
    end

    ply:SetCustomCollisionCheck(true)
    ply.nextTaunt = 0
    ply.lastTaunt = CurTime()
    ply.autoTauntInterval = OBJHUNT_AUTOTAUNT_INTERVAL + OBJHUNT_HIDE_TIME
    net.Start("Class Selection")
        -- Just used as a hook
    net.Send(ply)
end

-- Add command to hunter blindness for testing.
-- This is a huge hack but it is only needed for testing.
concommand.Add("testmode", function (ply)
    if IsValid(ply) then return end -- Bail if this is sent from a player.
    BroadcastLua("OBJHUNT_HIDE_TIME = 1")
    OBJHUNT_HIDE_TIME = 1
    print("Test mode enabled.")
end)

-- [[ Class Selection ]] --
function GM:ShowTeam(ply) -- This hook is called everytime F1 is pressed.
    net.Start("Class Selection")
        -- Just used as a hook
    net.Send(ply)
end

function GM:ShowHelp(ply)
    net.Start("Help")
        -- Just used as a hook
    net.Send(ply)
end

net.Receive("Class Selection", function(len, ply)
    local chosen = net.ReadUInt(32)
    SetTeam(ply, chosen)
end)

function SetTeam(ply, chosen)
    local playerTable = {}
    local oldTeam = ply:Team()

    if chosen == ply:Team() then
        ply:ChatPrint("You are already on that team.")
        return end
    if chosen == TEAM_SPECTATOR then
        player_manager.SetPlayerClass(ply, "player_spectator")
    end

    playerTable[ TEAM_PROPS ] = team.NumPlayers(TEAM_PROPS)
    playerTable[ TEAM_HUNTERS ] = team.NumPlayers(TEAM_HUNTERS)
    playerTable[ TEAM_SPECTATOR ] = team.NumPlayers(TEAM_SPECTATOR)
    playerTable[ ply:Team() ] = playerTable[ ply:Team() ] - 1

    if chosen == TEAM_ANY then
        if playerTable[ TEAM_PROPS ] > playerTable[ TEAM_HUNTERS ] then
            chosen = TEAM_HUNTERS
        else
            chosen = TEAM_PROPS
        end
    end

    if math.abs(playerTable[ TEAM_PROPS ] - playerTable[ TEAM_HUNTERS ]) >= MAX_TEAM_NUMBER_DIFFERENCE then
        if playerTable[ chosen ] == math.max(playerTable[ TEAM_PROPS ], playerTable[ TEAM_HUNTERS ]) then
            ply:ChatPrint("Sorry, that team is currently full.")
            return end
    end

    ply:SetTeam(chosen)
    if (chosen == TEAM_PROPS) then
        player_manager.SetPlayerClass(ply, "player_prop")
    elseif (chosen == TEAM_HUNTERS) then
        player_manager.SetPlayerClass(ply, "player_hunter")
    end

    PrintMessage(HUD_PRINTTALK, ply:Nick() .. " moved from " .. TeamString(oldTeam) .. " to " .. TeamString(ply:Team()))
    RemovePlayerProp(ply)
    ply:KillSilent()
    --ply:Spawn()
end

-- [[ Taunts ]] --
function SendTaunt(ply, taunt, pitch)
    if (CurTime() < ply.nextTaunt) then return end
    if (!ply:Alive()) then return end
    if (ply:Team() == TEAM_PROPS and !table.HasValue(PROP_TAUNTS, taunt)) then return end
    if (ply:Team() == TEAM_HUNTERS and !table.HasValue(HUNTER_TAUNTS, taunt)) then return end

    local soundDur = SoundDuration(taunt) * (100 / pitch)
    ply.nextTaunt = CurTime() + soundDur
    ply.lastTaunt = CurTime()
    ply.autoTauntInterval = OBJHUNT_AUTOTAUNT_INTERVAL + soundDur -- Offset the interval by the sound dur

    local filter = RecipientFilter();
    filter:AddPlayer(ply);

    net.Start("Taunt Selection")
        net.WriteString(taunt)
        net.WriteUInt(pitch, 8)
        net.WriteUInt(ply:EntIndex(), 8)
        net.WriteFloat(ply.lastTaunt)
        net.WriteFloat(ply.autoTauntInterval)
    net.Broadcast()
end

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

function GM:ShowSpare1(ply)
    local TAUNTS
    if (ply:Team() == TEAM_PROPS) then
        TAUNTS = PROP_TAUNTS
    else
        TAUNTS = HUNTER_TAUNTS
    end

    local pRange = TAUNT_MAX_PITCH - TAUNT_MIN_PITCH
    local taunt = table.Random(TAUNTS)
    local pitch = math.random() * pRange + TAUNT_MIN_PITCH
    SendTaunt(ply, taunt, pitch)
end

net.Receive("Taunt Selection", function(len, ply)
    local taunt = net.ReadString()
    local pitch = net.ReadUInt(8)
    SendTaunt(ply, taunt, pitch)
end)


function GM:PlayerSetModel(ply)
    class = player_manager.GetPlayerClass(ply)
    if (class == "player_hunter") then
        ply:SetModel(TEAM_HUNTERS_DEFAULT_MODEL)
    elseif (class == "player_prop") then
        ply:SetModel(TEAM_PROPS_DEFAULT_MODEL)
    else
        return
    end
end

-- disable the regular damage system
function GM:PlayerShouldTakeDamage(victim, attacker)
    return false
end

local function BroadcastPlayerDeath(ply)
    net.Start("Player Death")
        -- the player who died, so sad, too bad.
        net.WriteUInt(ply:EntIndex(), 8)
    net.Broadcast()
    -- remove ragdoll
    local ragdoll = ply:GetRagdollEntity()
    SafeRemoveEntityDelayed(ragdoll, 5)
end


-- how damage to props is handled
local function HurtProp(ply, dmg, attacker)
    if (attacker:Alive()) then
        local gain = math.min(ply:Health(), dmg)
        gain = gain / 2
        local newHP = math.Clamp(attacker:Health() + gain, 0, 100)
        attacker:SetHealth(newHP)
    end

    ply:SetHealth(ply:Health() - dmg)
    if (ply:Health() < 1 and ply:Alive()) then
        ply:KillSilent()
        ply:CreateRagdoll()
        RemovePlayerProp(ply)
        BroadcastPlayerDeath(ply)
        net.Start("Death Notice")
            net.WriteString(attacker:Nick())
            net.WriteUInt(attacker:Team(), 16)
            net.WriteString("found")
            net.WriteString(ply:Nick())
            net.WriteUInt(ply:Team(), 16)
        net.Broadcast()
        attacker:AddFrags(1)
        ply:AddDeaths(1)
    end
end

-- new damage system
local function DamageHandler(target, dmgInfo)

    local attacker = dmgInfo:GetAttacker()
    -- dynamic damage
    local dmg = dmgInfo:GetDamage()

    if (attacker:IsPlayer()) then
        if (attacker:Team() == TEAM_HUNTERS) then
            -- since player_prop_ent isn't in USABLE_PROP_ENTS this is sufficient logic to prevent
            -- player owned props from getting hurt
            if (!target:IsPlayer() and table.HasValue(USABLE_PROP_ENTITIES, target:GetClass()) and attacker:Alive()) then
                -- disable stepping on bottles to hurt
                local dmgType = dmgInfo:GetDamageType()
                if (dmgType == DMG_CRUSH) then return end
                -- static damage
                if (HUNTER_DAMAGE_PENALTY > 0) then
                    dmg = HUNTER_DAMAGE_PENALTY
                end

                attacker:SetHealth(attacker:Health() - dmg)
                if (attacker:Health() < 1) then
                    attacker:Kill()
                    -- default suicide notice
                end
            elseif (target:GetOwner():IsPlayer() and target:GetOwner():Team() == TEAM_PROPS and !target:GetOwner():ObjIsPlayDead()) then
                local ply = target:GetOwner()
                HurtProp(ply, dmg, attacker)
            elseif (target:IsPlayer() and target:Team() == TEAM_PROPS and !target:ObjIsPlayDead()) then
                local ply = target
                HurtProp(ply, dmg, attacker)
            end
        end
    end
end

hook.Add("EntityTakeDamage", "forward dmg to new system", function(target, dmg)
    DamageHandler(target, dmg)
end)

--[[ All network strings should be precached HERE ]]--
hook.Add("Initialize", "Precache all network strings", function()
    util.AddNetworkString("Clear Round State")
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
    util.AddNetworkString("Prop Angle Lock BROADCAST")
    util.AddNetworkString("Prop Angle Snap")
    util.AddNetworkString("Prop Angle Snap BROADCAST")
    util.AddNetworkString("Prop Pitch Enable")
    util.AddNetworkString("Prop Pitch Enable BROADCAST")
    util.AddNetworkString("Hunter Roll")
    util.AddNetworkString("Hunter Roll BROADCAST")
    util.AddNetworkString("AutoTaunt Update")
    util.AddNetworkString("Update Taunt Times")
    util.AddNetworkString("Remove Prop")
end)

--[[ Map Time ]]--

--[[ Door Exploit fix ]]--
function GM:PlayerUse(ply, ent)
    -- default value
    if (!ply.lastDoorTrigger) then
        ply.lastDoorTrigger = CurTime()
        ply.nextDoorTrigger = CurTime() + (0.5 + math.random())
        return true
    end

    if (table.HasValue(DOORS, ent:GetClass()) and CurTime() < ply.nextDoorTrigger) then
        return false
    else
        ply.lastDoorTrigger = CurTime()
        ply.nextDoorTrigger = CurTime() + (0.5 + math.random())
        return true
    end


end

--[[ sets the players prop, run PlayerCanBeEnt before using this ]]--
function SetPlayerProp(ply, ent, scale, hbMin, hbMax)

    -- scaling
    ply:GetProp():SetModelScale(scale, 0)

    ply:GetProp():SetModel(ent:GetModel())
    ply:GetProp():SetSkin(ent:GetSkin())
    ply:GetProp():SetAngles(ply:GetAngles())
    ply:GetProp():SetSolid(SOLID_VPHYSICS)

    local tHitboxMin, tHitboxMax = PropHitbox(ply)
    if (hbMin != nil && hbMax != nil) then
       tHitboxMin, tHitboxMax = hbMin, hbMax
    end

    --Adjust Position for no stuck
    local foundSpot = FindSpotFor(ply, tHitboxMin, tHitboxMax)
    ply:SetPos(foundSpot) -- + Vector(0,0, -tHitboxMin.z))

    ply:SetHull(tHitboxMin, tHitboxMax)
    ply:SetHullDuck(tHitboxMin, tHitboxMax)
    local tHeight = tHitboxMax.z-tHitboxMin.z

    -- match the view offset for calcviewing to the height
    ply:SetViewOffset(Vector(0,0,tHeight))

    -- scale steps to prop size
    ply:SetStepSize(math.Round(4 + tHeight / 4))

    -- give bigger props a bonus for being big
    ply:SetJumpPower(PROP_DEFAULT_JUMP_POWER + math.sqrt(tHeight))

    ply.lastPropChange = os.time()

    local volume = (tHitboxMax.x - tHitboxMin.x) * (tHitboxMax.y - tHitboxMin.y) * (tHitboxMax.z - tHitboxMin.z)

    -- the damage percent is what percent of hp the prop currently has
    ply.dmgPct = math.min(ply.dmgPct, ply:Health() / ply.oldMaxHP)

    local maxHP = math.Clamp(volume / 10, 1, 100)

    ply.oldMaxHP = maxHP

    -- just enough to see the HP bar at lowest possible hp
    local newHP = math.Clamp(maxHP * ply.dmgPct, 2, 100)
    ply:SetHealth(newHP)

    -- Update the player's mass to be something more reasonable to the prop
    local phys = ent:GetPhysicsObject()
    if IsValid(ent) and phys:IsValid() then
        ply:GetPhysicsObject():SetMass(phys:GetMass())
        -- vphysics
        local vPhysMesh = ent:GetPhysicsObject():GetMeshConvexes()
        ply:GetProp():PhysicsInitMultiConvex(vPhysMesh)
    else
        -- Entity doesn't have a physics object so calculate mass
        local density = PROP_DEFAULT_DENSITY
        local mass = volume * density
        mass = math.Clamp(mass, 0, 100)
        ply:GetPhysicsObject():SetMass(mass)
    end

    net.Start("Prop Update")
        net.WriteVector(tHitboxMax)
        net.WriteVector(tHitboxMin)
    net.Send(ply)

end

--[[ When a player presses +use on a prop ]]--
net.Receive("Selected Prop", function(len, ply)
    local ent = net.ReadEntity()

    if (ply.pickupProp or !playerCanBeEnt(ply, ent)) then return end
    local oldHP = ply:GetProp().health
    SetPlayerProp(ply, ent, PROP_CHOSEN_SCALE)
    ply:GetProp().health = oldHP
end)

--[[ When a player on team_props spawns ]]--
hook.Add("PlayerSpawn", "Set ObjHunt model", function (ply)
    -- default prop should be able to step wherever
    ply:SetStepSize(20)
    ply:SetNotSolid(false)
    if (ply:Team() == TEAM_PROPS) then
        ply.oldMaxHP = 100
        ply.dmgPct = 1
        -- make the player invisible
        ply:SetRenderMode(RENDERMODE_NONE)
        ply:SetBloodColor(DONT_BLEED)

        timer.Simple(0.5, function()
            ply:SetProp(ents.Create("player_prop_ent"))
            ply:GetProp():Spawn()
            ply:GetProp():SetOwner(ply)
            -- custom initial hb
            SetPlayerProp(ply, ply:GetProp(), PROP_DEFAULT_SCALE, PROP_DEFAULT_HB_MIN, PROP_DEFAULT_HB_MAX)
        end)

        -- this fixes ent culling when head in ceiling
        -- should be based on default hit box!
        ply:SetViewOffset(Vector(0,0,35))

    elseif (ply:Team() == TEAM_HUNTERS) then
        ply:SetRenderMode(RENDERMODE_NORMAL)
        ply:SetColor(Color(255,255,255,255))

        -- default
        ply:SetViewOffset(Vector(0,0,64))
    end

end)

--[[ When a player wants to lock world angles on their prop ]]--
net.Receive("Prop Angle Lock", function(len, ply)
    local lockStatus = net.ReadBit()
    local propAngle = net.ReadAngle()
    -- this is literally retarded
    if (lockStatus == 1) then
        lockStatus = true
    else
        lockStatus = false
    end

    if (IsValid(ply:GetProp())) then
        -- We should investigate why this angle doesn't naturally stay in sync
        ply:GetProp():SetAngles(propAngle)
        local tHitboxMin, tHitboxMax = PropHitbox(ply)

        --Adjust Position for no stuck
        local foundSpot = FindSpotFor(ply, tHitboxMin, tHitboxMax)
        ply:SetPos(foundSpot) -- + Vector(0,0, -tHitboxMin.z))

        ply:SetHull(tHitboxMin, tHitboxMax)
        ply:SetHullDuck(tHitboxMin, tHitboxMax)
        local tHeight = tHitboxMax.z - tHitboxMin.z

        -- match the view offset for calcviewing to the height
        ply:SetViewOffset(Vector(0, 0, tHeight))

        -- scale steps to prop size
        ply:SetStepSize(math.Round(4 + tHeight / 4))

        -- give bigger props a bonus for being big
        ply:SetJumpPower(PROP_DEFAULT_JUMP_POWER + math.sqrt(tHeight))

        net.Start("Prop Update")
            net.WriteVector(tHitboxMax)
            net.WriteVector(tHitboxMin)
        net.Send(ply)
    end

    net.Start("Prop Angle Lock BROADCAST")
        net.WriteEntity(ply)
        net.WriteBit(lockStatus)
        net.WriteAngle(propAngle)
    net.Broadcast()
end)

--[[ When a player wants toggle world angle snapping on their prop ]]--
net.Receive("Prop Angle Snap", function(len, ply)
    local snapStatus = net.ReadBit()
    -- this is literally retarded
    if (snapStatus == 1) then
        snapStatus = true
    else
        snapStatus = false
    end

    net.Start("Prop Angle Snap BROADCAST")
        net.WriteEntity(ply)
        net.WriteBit(snapStatus)
    net.Broadcast()
end)

--[[ When a player wants enable pitch on their prop ]]--
net.Receive("Prop Pitch Enable", function(len, ply)
    -- Especially shouldn't use slurs against the mentally ill when you don't know how types work
    local enableStatus = net.ReadBit() == 1

    ply:SetPropPitchEnabled(enableStatus)
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

    net.Start("Hunter Roll BROADCAST")
        net.WriteEntity(ply)
        net.WriteAngle(newAngle)
    net.Broadcast()
end)

hook.Add("PlayerDisconnected", "Remove ent prop on dc", function(ply)
    RemovePlayerProp(ply)
end)

hook.Add("PlayerDeath", "Remove ent prop on death", function(ply)
    BroadcastPlayerDeath(ply)

    ply.nextTaunt = 0
    RemovePlayerProp(ply)
    if (ply:IsFrozen()) then
        ply:Freeze(false)
    end
end)

--[[ When a player Removes a prop with the ability ]]--
net.Receive("Remove Prop", function(len, ply)
    local propToRemove = net.ReadEntity()
    if (IsValid(propToRemove)) then
        propToRemove:Remove()
    end
end)

--[[ remove the ent prop ]]--
function RemovePlayerProp(ply)
    if (ply.GetProp and IsValid(ply:GetProp())) then
        ply:GetProp():Remove()
        ply:SetProp(nil)
    end
    ply:ResetHull()
    net.Start("Reset Prop")
        -- empty, just used for the hook
    net.Send(ply)
end

function GM:PlayerSelectSpawn(ply)
    local spawns = team.GetSpawnPoints(ply:Team())
    if (!spawns) then return false end

    local ret, _ = table.Random(spawns)
    return ret
end

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)

    if (DISABLE_GLOBAL_CHAT) then
        if (speaker:IsAdmin()) then
            return true
        end

        if (listener:Team() != speaker:Team()) then
            return false
        end
    end

    if (teamOnly) then
        if (listener:Team() != speaker:Team()) then
            return false
        end
    end

    return true
end

function GM:PlayerCanPickupWeapon(ply, wep)
    return ply:Team() == TEAM_HUNTERS or (ply:Team() == TEAM_PROPS and wep:IsScripted())
end

function GM:AllowPlayerPickup(ply, ent)
    return (OBJHUNT_TEAM_HUNTERS_CAN_MOVE_PROPS and ply:Team() == TEAM_HUNTERS and ply.pickupProp) or
           (OBJHUNT_TEAM_PROPS_CAN_MOVE_PROPS   and ply:Team() == TEAM_PROPS   and ply.pickupProp)
end

function GM:PlayerButtonDown(ply, button)
    if (button == KEY_LCONTROL) then
        ply.pickupProp = true
    end
end

function GM:PlayerButtonUp(ply, button)
    if (button == KEY_LCONTROL) then
        ply.pickupProp = false
    end
end
