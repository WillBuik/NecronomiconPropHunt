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
function GM:ShowTeam(ply) -- This hook is called everytime F2 is pressed.
    net.Start("Class Selection")
        -- Just used as a hook
    net.Send(ply)
end

function GM:ShowHelp(ply)
    net.Start("Help")
        -- Just used as a hook
    net.Send(ply)
end


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
    -- Checks: the player has to be allowed to make a taunt right now, and the
    -- server has to know about the taunt they want to play.
    local now = CurTime()
    if !IsValid(ply) or !ply:CanTauntAt(now) then return end
    if (ply:Team() == TEAM_PROPS and !table.HasValue(PROP_TAUNTS, taunt)) then return end
    if (ply:Team() == TEAM_HUNTERS and !table.HasValue(HUNTER_TAUNTS, taunt)) then return end

    -- NOTE: `NewSoundDuration` uses the "GAME" search path, which includes our
    -- game mode's content/ folder.  The taunt itself is relative to
    -- content/sound/, so we have to extend the path with the sound/ prefix.
    -- Normally, sound-specific APIs don't need to adjust the path in this way;
    -- for instance, clients won't have to do this when playing the sound.
    local duration = NewSoundDuration("sound/" .. taunt)

    -- Bail out if the duration could not be determined or is nonsensical.
    -- NewSoundDuration's fallback to the built in SoundDuration can return
    -- junk values if it can't parse a sound file. This is game-breaking so
    -- bail if that happens. For more details see:
    -- https://github.com/Facepunch/garrysmod-issues/issues/936
    if (!duration or duration <= 0 or duration >= 50) then
        if (!duration) then duration = "nil" end
        print("[ERROR] Taunt '" .. taunt .. "' has bad duration '" .. duration .. "'")
        return
    end

    print("Taunt: " .. taunt .. " from " .. ply:Nick() .. " at pitch " .. tostring(pitch) .. "; pre-pitch-adjusted duration is " .. duration .. "s" )

    local adjustedDuration = duration * (100 / pitch)

    ply:SetLastTauntTime(now)
    ply:SetLastTauntDuration(adjustedDuration)

    -- NOTE: +1 on the modifier to ensure that the previous taunt doesn't count
    -- against the player's time, even if the modifier is 0.
    ply:SetNextAutoTauntDelay(
        (OBJHUNT_AUTOTAUNT_DURATION_MODIFIER + 1) * adjustedDuration +
        OBJHUNT_AUTOTAUNT_BASE_INTERVAL
    )

    net.Start("Taunt Selection BROADCAST")
        net.WriteString(taunt)
        net.WriteUInt(pitch, 8)
        net.WriteUInt(ply:EntIndex(), 8)
    net.Broadcast()

    if (!ply.tauntHistory) then
        ply.tauntHistory = EmptySet()
    end
    SetAdd(ply.tauntHistory, taunt)
end

function GM:PlayerSetModel(ply)
    local class = player_manager.GetPlayerClass(ply)
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

function BroadcastPlayerDeath(ply)
    net.Start("Player Death")
        -- the player who died, so sad, too bad.
        net.WriteUInt(ply:EntIndex(), 8)
    net.Broadcast()
    -- remove ragdoll
    local ragdoll = ply:GetRagdollEntity()
    -- ideally this ragdoll stays around the same amount of time as a prop can play dead for
    SafeRemoveEntityDelayed(ragdoll, PROP_RAGDOLL_DURATION)
end

function AnnouncePlayerDeath(ply, attacker)
    net.Start("Death Notice")
        net.WriteString(attacker:Nick())
        net.WriteUInt(attacker:Team(), 16)
        net.WriteString("found")
        net.WriteString(ply:Nick())
        net.WriteUInt(ply:Team(), 16)
    net.Broadcast()
end

-- NOTE: damage from hunters should go through HurtProp, which first rewards
-- the attacker based on damage dealt and then calls this procedure.  This
-- procedure merely:
--   - deals the damage
--   - performs prop-specific on-death effects if new health <= 0
function HurtPropAndCheckForDeath(ply, dmg, attacker)
    ply:SetHealth(ply:Health() - dmg)
    if (ply:Health() < 1 and ply:Alive()) then
        ply:PropDeath(attacker)
    end
end

-- how damage to props is handled
local function HurtProp(ply, dmg, attacker)
    if (attacker:Alive()) then
        local gain = math.min(ply:Health(), dmg)
        gain = gain / 2
        local newHP = math.Clamp(attacker:Health() + gain, 0, 100)
        attacker:SetHealth(newHP)
    end

    HurtPropAndCheckForDeath(ply, dmg, attacker)
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
            elseif (target:GetOwner():IsPlayer() and target:GetOwner():Team() == TEAM_PROPS and !target:GetOwner():ObjIsPlaydead()) then
                local ply = target:GetOwner()
                if (ply:ObjGetPlaydeadDuration() > 0) then
                    ply:FakeDeath(attacker)
                else
                    HurtProp(ply, dmg, attacker)
                end
            elseif (target:IsPlayer() and target:Team() == TEAM_PROPS and !target:ObjIsPlaydead()) then
                local ply = target
                if (ply:ObjGetPlaydeadDuration() > 0) then
                    ply:FakeDeath(attacker)
                else
                    HurtProp(ply, dmg, attacker)
                end
            elseif (target:IsPlayer() and target:Team() == TEAM_HUNTERS and IsHunterFriendlyFireEnabled()) then
                target:SetHealth(target:Health() - dmg)
                if (target:Health() < 1) then
                    target:KillSilent()
                    AnnouncePlayerDeath(target, attacker)
                end
            end
        end
    end
end

hook.Add("EntityTakeDamage", "forward dmg to new system", function(target, dmg)
    DamageHandler(target, dmg)
end)

--[[ Door Exploit fix ]]--
function GM:PlayerUse(ply, ent)
    if (table.HasValue(DOORS, ent:GetClass()) and CurTime() < ply:GetTimeOfNextDoorOpen()) then
        return false
    else
        ply:SetTimeOfNextDoorOpen(CurTime() +  0.5 + math.random())
        return true
    end
end

--[[ sets the players prop, run PlayerCanBeEnt before using this ]]--
function SetPlayerProp(ply, ent, scale, hbMin, hbMax)
    -- The player's prop entity will be adjusted in-place to look like `ent`.
    local prop = ply:GetProp()

    -- scaling
    prop:SetModelScale(scale, 0)

    prop:SetModel(ent:GetModel())
    prop:SetSkin(ent:GetSkin())
    prop:SetSolid(SOLID_VPHYSICS)

    -- We will reset the roll and pitch of a Prop when changing to make for easier escapes
    ply:SetPropRollAngle(0)
    local lockedAngle = ply:GetPropLockedAngle()
    local newAngle = Angle(0, lockedAngle.y, 0)
    ply:SetPropLockedAngle(newAngle)

    local tHitboxMin, tHitboxMax = hbMin, hbMax
    if (hbMin == nil or hbMax == nil) then
        tHitboxMin, tHitboxMax = PropHitbox(ply)
    end

    --Adjust Position for no stuck
    local foundSpot = FindSpotFor(ply, tHitboxMin, tHitboxMax)
    ply:SetPos(foundSpot)

    UpdatePlayerPropHitbox(ply, tHitboxMin, tHitboxMax)

    local tHeight = tHitboxMax.z-tHitboxMin.z

    -- scale steps to prop size
    ply:SetStepSize(math.Round(4 + tHeight / 4))

    -- give bigger props a bonus for being big
    ply:SetJumpPower(PROP_DEFAULT_JUMP_POWER + math.sqrt(tHeight))

    if (prop == ent) then
        -- In the case of the first Prop let's leave the Last Change Time at 0 so no cooldown
        ply:SetPropLastChange(0)
    else
        ply:SetPropLastChange(CurTime())
    end

    local volume = (tHitboxMax.x - tHitboxMin.x) * (tHitboxMax.y - tHitboxMin.y) * (tHitboxMax.z - tHitboxMin.z)
    ply.propSize = volume ^ (1 / 3)

    ply:SetupPropHealth()
    ply:SetupPropSpeed()

    -- Update the player's mass to be something more reasonable to the prop
    local phys = ent:GetPhysicsObject()
    if IsValid(ent) and phys:IsValid() then
        ply:GetPhysicsObject():SetMass(phys:GetMass())
        -- vphysics
        local vPhysMesh = ent:GetPhysicsObject():GetMeshConvexes()
        prop:PhysicsInitMultiConvex(vPhysMesh)
    else
        -- Entity doesn't have a physics object so calculate mass
        local density = PROP_DEFAULT_DENSITY
        local mass = volume * density
        mass = math.Clamp(mass, 0, 100)
        ply:GetPhysicsObject():SetMass(mass)
    end

    if (!ply.propHistory) then
        ply.propHistory = EmptySet()
    end
    SetAdd(ply.propHistory, ent:GetModel())
end

function UpdatePlayerPropHitbox(ply, hbMin, hbMax)
        ply:SetHull(hbMin, hbMax)
        ply:SetHullDuck(hbMin, hbMax)
        local height = hbMax.z - hbMin.z

        -- match the view offset for calcviewing to the height
        ply:SetViewOffset(Vector(0,0,height))

        net.Start("Prop Update")
            net.WriteVector(hbMax)
            net.WriteVector(hbMin)
        net.Send(ply)
end

function ResetPropToProp(ply)
        local tHitboxMin, tHitboxMax = PropHitbox(ply)

        --Adjust Position for no stuck
        local foundSpot = FindSpotFor(ply, tHitboxMin, tHitboxMax)
        ply:SetPos(foundSpot)

        UpdatePlayerPropHitbox(ply, tHitboxMin, tHitboxMax)
end

function UnstickPlayer(ply, searchMultplier)
        local tHitboxMin, tHitboxMax
        if (ply:Team() == TEAM_PROPS) then
            tHitboxMin, tHitboxMax = PropHitbox(ply)
        elseif (ply:Team() == TEAM_HUNTERS) then
            tHitboxMin, tHitboxMax = GetHitBoxInModelCoordinates(ply)
        else
            return
        end

        --Adjust Position for no stuck
        local foundSpot = FindSpotFor(ply, tHitboxMin, tHitboxMax, searchMultplier)
        ply:SetPos(foundSpot)

        UpdatePlayerPropHitbox(ply, tHitboxMin, tHitboxMax)
end

function GetNumValidPropsOnMap()
    local numProps = 0
    local allEnts = ents.GetAll()

    for _, someEnt in pairs( allEnts ) do
        if (
                IsValid(someEnt) and
                table.HasValue(USABLE_PROP_ENTITIES, someEnt:GetClass()) and
                IsValid(someEnt:GetPhysicsObject()) and
                someEnt:GetClass() and
                someEnt:GetModel()
            ) then
                numProps = numProps + 1
        end
    end
    print(numProps)
    return numProps
end

hook.Add("InitPostEntity", "Entities ready, count props", function ()
    SetGlobalInt("NumPropsOnMap", GetNumValidPropsOnMap())
end)

--[[ When a player on team_props spawns ]]--
hook.Add("PlayerSpawn", "Set ObjHunt model", function (ply)
    -- default prop should be able to step wherever
    ply:SetStepSize(20)
    ply:SetNotSolid(false)
    if (ply:Team() == TEAM_PROPS) then
        ply.propSize = 100
        ply:SetupPropHealth()
        ply:SetupPropSpeed()
        -- make the player invisible
        ply:SetRenderMode(RENDERMODE_NONE)
        ply:SetBloodColor(DONT_BLEED)

        timer.Simple(0.5, function()
            ply:SetProp(ents.Create("player_prop_ent"))
            ply:GetProp():Spawn()
            ply:GetProp():SetOwner(ply)
            -- custom initial hb (REMVOED): PROP_DEFAULT_HB_MIN, PROP_DEFAULT_HB_MAX
            SetPlayerProp(ply, ply:GetProp(), 2.0)
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

hook.Add("PlayerDisconnected", "Remove ent prop on dc", function(ply)
    RemovePlayerProp(ply)
end)

hook.Add("PlayerDeath", "Remove ent prop on death", function(ply)
    BroadcastPlayerDeath(ply)

    RemovePlayerProp(ply)
    if (ply:IsFrozen()) then
        ply:Freeze(false)
    end

    ply:SetTimeOfDeath(CurTime())
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

-- Q-menu (Taunt Selection) Anti Abuse --
function QMenuAntiAbuse(ply)
    if (!QMENU_ANTI_ABUSE or ply:Team() != TEAM_PROPS) then
        return false
    end

    local tauntRepeatsModifier = math.max(1, SetCountGetMax(ply.tauntHistory) - 2)
    if (math.random() * QMENU_CONSEQUENCE_ODDS / tauntRepeatsModifier < 1.0) then
        if (ply:Alive()) then
            ply:SetRenderMode(RENDERMODE_NORMAL)
            ply:CreateRagdoll()
            RemovePlayerProp(ply)
            ply:KillSilent()
            BroadcastPlayerDeath(ply)

            net.Start("Death Notice")
                net.WriteString("QAnon")
                net.WriteUInt(TEAM_HUNTERS, 16)
                net.WriteString("found")
                net.WriteString(ply:Nick())
                net.WriteUInt(ply:Team(), 16)
            net.Broadcast()
        end
        return true;
    end

    return false
end
