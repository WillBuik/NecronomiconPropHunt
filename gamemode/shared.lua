GM.Name    = "Prop Hunt"
GM.Author  = "Newbrict, TheBerryBeast, Zombie"
GM.Email   = "newbrict@gmail.com"
GM.Website = "www.objhunt.com"

GM.BaseDir = "prop_hunt/gamemode/"

--[[ Add all the files on server/client ]]--
local resources = {}
resources["server"] = { "server" }
resources["shared"] = { "shared","player_class", "autotaunt" }
resources["client"] = { "client", "gui" }

local function resourceLoader(dirs, includeFunc)
    for _, addDir in pairs(dirs) do
        print("-- " .. addDir)
        local csFiles, _ = file.Find(GM.BaseDir .. addDir .. "/*", "LUA")
        for _, csFile in ipairs(csFiles) do
               includeFunc(addDir .. "/" .. csFile)
            print(" + " .. csFile)
        end
    end
end

if SERVER then
    print("Adding Server Side Lua Files...")
    resourceLoader(resources["shared"], function(x) include(x) AddCSLuaFile(x) end)
    resourceLoader(resources["server"], include)
    resourceLoader(resources["client"], AddCSLuaFile)
    -- add the taunts in
--     for _,t in pairs(PROP_TAUNTS) do
--         --if !file.Exists("sound/"..t, "MOD") then
--             print ("Adding prop taunt " .. t)
--         --    resource.AddFile("sound/"..t)
--         --else
--         --    print ("Prop taunt "..t.." not found.")
--         --end
--     end
--     for _,t in pairs(HUNTER_TAUNTS) do
--         if file.Exists("sound/" .. t, "MOD") then
--         --    resource.AddSingleFile("sound/"..t)
--         end
--     end
else
    print("Adding Client Side Lua Files...")
    resourceLoader(resources["shared"], include)
    resourceLoader(resources["client"], include)
end

if file.Exists(GM.BaseDir .. "maps/" .. game.GetMap() .. ".lua", "LUA") then
    print("Adding Config Of Current Map...")
    print("-- maps")
    print(" + " .. game.GetMap() .. ".lua")
    include("maps/" .. game.GetMap() .. ".lua")
    if SERVER then AddCSLuaFile("maps/" .. game.GetMap() .. ".lua") end
end

function playerCanBeEnt(ply, ent)
    -- this caused an issue once
    if (!ent or !IsValid(ent)) then return false end

    -- make sure we're living props
    if (!ply:Alive() or ply:Team() != TEAM_PROPS) then return false end

    -- make sure ent is a valid prop type
    if (    !table.HasValue(USABLE_PROP_ENTITIES, ent:GetClass())) then return false end

    -- make sure it's a valid phys object
    if (    !IsValid(ent:GetPhysicsObject())) then return false end

    -- make sure we can get the model and class
    if (    !ent:GetClass() or !ent:GetModel()) then return false end

    -- Not if disguised
    if (ply:ObjIsDisguised()) then return false end

    -- cooldown on switching props
    if (ply:GetProp():GetModel() != "models/player.mdl") then
        if (CurTime() < ply:GetPropLastChange() + PROP_CHOOSE_COOLDOWN) then
            return false
        end
    end

    if (FindSpotForProp(ply, ent) == nil) then return false end

    return true
end

--[[ set up the teams ]]--
function GM:CreateTeams()
    team.SetUp(TEAM_PROPS , "Props" , TEAM_PROPS_CHAT_COLOR, true)
    team.SetUp(TEAM_HUNTERS , "Hunters" , TEAM_HUNTERS_CHAT_COLOR, true)
    team.SetUp(TEAM_SPECTATOR , "Spectators" , Color(127, 127, 127), true)
    team.SetClass(TEAM_PROPS, {"player_prop"})
    team.SetClass(TEAM_HUNTERS, {"player_hunter"})
    team.SetClass(TEAM_SPECTATOR, {"player_spectator"})
    team.SetSpawnPoint(TEAM_PROPS, {"info_player_start", "info_player_terrorist", "info_player_rebel", "info_player_deathmatch", "info_player_allies"})
    team.SetSpawnPoint(TEAM_HUNTERS, {"info_player_start", "info_player_counterterrorist", "info_player_combine", "info_player_deathmatch", "info_player_axis"})
    team.SetSpawnPoint(TEAM_SPECTATOR, {"info_player_start", "info_player_counterterrorist", "info_player_combine", "info_player_deathmatch", "info_player_axis"})
end

--[[ some share hooks, disable footsteps and taget id's ]]--
function GM:HUDDrawTargetID()
    return true
end

function GM:PlayerTick(ply, mv)
    ply:SetDSP(0)
end

function GM:PlayerFootstep(ply, pos, foot, sound, volume, rf)
    if (ply:Team() != TEAM_HUNTERS) then return true end
end

-- initial collisions for props
function initNoCollide(ent1, ent2)
    if (!IsValid(ent1) or !IsValid(ent2)) then return end
    if (!ent1:IsPlayer() or !ent2:IsPlayer()) then return end
    if (ent1:Team() != ent2:Team() and !(ent1:IsFrozen() or ent2:IsFrozen())) then return end
    if (ent1:Team() == TEAM_PROPS and ent1.GetProp and IsValid(ent1:GetProp()) and ent1:GetProp():GetModel() == "models/player.mdl") then
        return false
    elseif (ent2:Team() == TEAM_PROPS and ent2.GetProp and IsValid(ent2:GetProp()) and ent2:GetProp():GetModel() == "models/player.mdl") then
        return false
    elseif (ent1:GetClass() == "npc_kleiner" or ent2:GetClass() == "npc_kleiner") then
        return false
    end
end
hook.Add("ShouldCollide", "Initial Nocollide For Props", initNoCollide)


-- Seed the random number generator.
local function seedRNG()
    -- Implementation notes:
    --  * Combining os.time() with the player's ID helps ensure that different
    --    players get different seeds, even if they run this code at similar times.
    --  * LocalPlayer() does not work until GM:InitPostEntity() is called.
    --  * The Player:AccountID() docs say "In singleplayer, this will return no
    --    value".  Does that mean it returns nil, or 0?  Or does it crash?  I have
    --    no idea.  In case it returns nil, "or 0" ensures that we get a number.
    --  * Generating a bunch of random numbers up-front helps "warm up" certain
    --    pseudorandom number generation algorithms.  Without it, the first few
    --    random numbers generated will not look very random.  (See:
    --    http://lua-users.org/lists/lua-l/2007-03/msg00564.html)
    print("Initializing RNG...")
    local seed = os.time()
    if (LocalPlayer) then
        local player = LocalPlayer()
        if (player) then
            seed = bit.bxor(seed, player:AccountID() or 0)
        end
    end
    print("-- seed=" .. seed)
    math.randomseed(seed)
    for i = 1, 50 do math.random() end
    print("-- done")
end

-- Per docs:
--  > Called after all the entities are initialized. Starting from this hook
--  > LocalPlayer will return valid object.
function GM:InitPostEntity()
   seedRNG()
end
