-- Lookup for server debug commands:
--   server_debug_command_tab["command"] = {
--       handler: server_func
--   }
local server_debug_command_tab = {}

-- Message name for command proxy.
local DEBUG_PROXY_NETMESSAGE = "phdproxycommand"

-- Helper to print a message back to the player or server console.
local function debug_print(ply, message)
    if IsValid(ply) and IsEntity(ply) and ply:IsPlayer() then
        ply:PrintMessage(HUD_PRINTCONSOLE, message)
    else
        print(message)
    end
end

-- Helper, returns true if a player is an admin or the server console.
local function is_admin(ply)
    if IsValid(ply) == false then
        return true
    else
        return IsValid(ply) and IsEntity(ply) and ply:IsPlayer() and ply:IsAdmin()
    end
end

-- Client side command handler, send proxy message.
local function debug_command_clientside_handler(ply, cmd, args, str)
    net.Start(DEBUG_PROXY_NETMESSAGE)
    net.WriteString(cmd)
    net.WriteTable(args)
    net.WriteString(str)
    net.SendToServer()
end

-- Server side command handler, dispatch command through handler table.
local function debug_command_serverside_handler(ply, cmd, args, str)
    local subcmd = args[1]
    if subcmd == nil then
        debug_print(ply, "You must specify a command.")
        return
    end
    subcmd = subcmd:lower()

    local command_entry = server_debug_command_tab[subcmd]
    if command_entry == nil then
        debug_print(ply, "No command '" .. subcmd .. "'.")
        return
    end

    table.remove(args, 1)
    str = str:sub(subcmd:len() + 1, -1):gsub("^%s*", "")
    command_entry["handler"](ply, subcmd, args, str)
end

-- Client side autocomplete.
local function debug_command_autocomplete(cmd, stringargs)
end

--- Server side proxy receiver.
local function debug_command_netrecv(len, ply)
    debug_command_serverside_handler(ply, net.ReadString(), net.ReadTable(), net.ReadString())
end

--- Register network strings, handlers, and console commands 
local function debug_command_init()
    if (SERVER) then
        util.AddNetworkString(DEBUG_PROXY_NETMESSAGE)
        concommand.Add("phd", debug_command_serverside_handler, debug_command_autocomplete, "Prophunt debug commands.")
        net.Receive(DEBUG_PROXY_NETMESSAGE, debug_command_netrecv)
    else
        concommand.Add("phd", debug_command_clientside_handler, debug_command_autocomplete, "Prophunt debug commands.")
    end
end

-- Add a server side prophunt debugging command. These can be run from
-- the player or server console as 'phd $command ...'. If run from the
-- player console, the command is proxied to the server using the
-- network library because that seems to be the only way to get auto-
-- complete working. Thanks gmod...
local function add_server_debug_command(command, server_func)
    command = command:lower()
    server_debug_command_tab[command] = {
        handler = server_func
    }
end

--
-- Set up debug commands:
--
debug_command_init()

-- Add command to test argument processing.
local function testargs_command(ply, cmd, args, str)
    local player_name = "{Server Console}"
    if IsValid(ply) then
        if IsEntity(ply) and ply:IsPlayer() then
            player_name = ply:Name()
        else
            player_name = "{Unknown}"
        end
    end
    debug_print(ply, "Player " .. player_name .. " sent command '" .. cmd .. "'")
    debug_print(ply, "  Server: " .. tostring(SERVER))
    debug_print(ply, "  Admin : " .. tostring(is_admin(ply)))
    debug_print(ply, "  Str   : '" .. str .. "'")
    for i, arg in ipairs(args) do
        debug_print(ply, "  Arg" .. tostring(i) .. "  : '" .. arg .. "'")
    end    
end
add_server_debug_command("testargs", testargs_command)

-- Pause round start countdown.
local function pause_round_command(ply, cmd, args, str)
    if is_admin(ply) then
        SetRoundPaused(true)
        debug_print(ply, "Round paused.")
    else
        debug_print(ply, "You must be an admin to run this command.")
    end
end
add_server_debug_command("pause", pause_round_command)

-- Resume round start countdown.
local function resume_round_command(ply, cmd, args, str)
    if is_admin(ply) then
        SetRoundPaused(false)
        debug_print(ply, "Round resumed.")
    else
        debug_print(ply, "You must be an admin to run this command.")
    end
end
add_server_debug_command("resume", resume_round_command)

-- Disable hunter blindness countdown for testing.
local function testmode_command(ply, cmd, args, str)
    if is_admin(ply) then
        -- This is a hack and only works for players currently logged in.
        BroadcastLua("OBJHUNT_HIDE_TIME = 1")
        OBJHUNT_HIDE_TIME = 1
        debug_print(ply, "Test mode enabled.")
    else
        debug_print(ply, "You must be an admin to run this command.")
    end
end
add_server_debug_command("testmode", testmode_command)

-- Add a bot.
local function addbot_command(ply, cmd, args, str)
    if is_admin(ply) then
        RunConsoleCommand("bot")
    else
        debug_print(ply, "You must be an admin to run this command.")
    end
end
add_server_debug_command("addbot", addbot_command)

-- Debug taunts, listing all durations. Nil durations are errors.
local function tauntinfo_command(ply, cmd, args, str)
    for _, taunt in pairs(PROP_TAUNTS) do
        local duration = NewSoundDuration("sound/" .. taunt)
        local durationStr
        if (!duration) then
            durationStr = "nil"
        else
            durationStr = string.format("%.2fs", duration)
        end
        debug_print(ply, "Taunt '" .. taunt .. "'\tduration " .. durationStr)
    end

    for _, taunt in pairs(HUNTER_TAUNTS) do
        local duration = NewSoundDuration("sound/" .. taunt)
        local durationStr
        if (!duration) then
            durationStr = "nil"
        else
            durationStr = string.format("%.2fs", duration)
        end
        debug_print(ply, "Taunt '" .. taunt .. "'\tduration " .. durationStr)
    end
end
add_server_debug_command("tauntinfo", tauntinfo_command)
