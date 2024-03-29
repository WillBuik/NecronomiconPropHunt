util.AddNetworkString("RAM_MapVoteStart")
util.AddNetworkString("RAM_MapVoteUpdate")
util.AddNetworkString("RAM_MapVoteCancel")

MapVote.Continued = false

net.Receive("RAM_MapVoteUpdate", function(len, ply)
    if (MapVote.Allow) then
        if (IsValid(ply)) then
            local update_type = net.ReadUInt(3)

            if (update_type == MapVote.UPDATE_VOTE) then
                local map_id = net.ReadUInt(32)

                if (MapVote.CurrentMaps[map_id]) then
                    MapVote.Votes[ply:SteamID()] = map_id

                    net.Start("RAM_MapVoteUpdate")
                        net.WriteUInt(MapVote.UPDATE_VOTE, 3)
                        net.WriteEntity(ply)
                        net.WriteUInt(map_id, 32)
                    net.Broadcast()

                    MapVote.CheckWinner(false)
                end
            end
        end
    end
end)


function MapVote.Start(length, current, limit, prefix)
    if MapVote.Allow then
        MapVote.Cancel()
    end

    current = current or MapVote.Config.AllowCurrentMap or false
    length = length or MapVote.Config.TimeLimit or 28
    limit = limit or MapVote.Config.MapLimit or 24

    local maps = MapVote.MapList(prefix)

    local vote_maps = {}

    local amt = 0

    for _, map in RandomPairs(maps) do
        if (!current and game.GetMap():lower() == map) then continue end

        local in_db, _, broken = load_map_info(map)
        if in_db and broken then continue end

        vote_maps[#vote_maps + 1] = map
        amt = amt + 1

        if (limit and amt >= limit) then break end
    end

    net.Start("RAM_MapVoteStart")
        net.WriteUInt(#vote_maps, 32)

        for i = 1, #vote_maps do
            local in_db, prop_count, _, comment = load_map_info(vote_maps[i])
            if !in_db then
                prop_count = -1
            end
            net.WriteString(vote_maps[i])
            net.WriteInt(prop_count, 16)
            net.WriteString(comment)
        end

        net.WriteUInt(length, 32)
    net.Broadcast()

    MapVote.Allow = true
    MapVote.CurrentMaps = vote_maps
    MapVote.Votes = {}
    MapVote.SuddenDeath = false

    timer.Create("RAM_MapVote", length, 1, function()
        MapVote.CheckWinner(true)
    end)
end

function MapVote.CheckWinner(timeout)
    if MapVote.SuddenDeath and !timeout then return end

    local map_results = {}

    for k, v in pairs(MapVote.Votes) do
        if (!map_results[v]) then
            map_results[v] = 0
        end

        for k2, v2 in pairs(player.GetAll()) do
            if (v2:SteamID() == k) then
                if (MapVote.HasExtraVotePower(v2)) then
                    map_results[v] = map_results[v] + 2
                else
                    map_results[v] = map_results[v] + 1
                end
            end
        end

    end

    local winner = table.GetWinningKey(map_results) or 1

    if !timeout then
        local winner_votes = map_results[winner]

        if winner_votes and winner_votes >= (# player.GetHumans()) * MapVote.Config.SuddenDeathThreshold then
            timer.Remove("RAM_MapVote")
            timer.Create("RAM_MapVote", MapVote.Config.SuddenDeathTimeLimit, 1, function()
                MapVote.CheckWinner(true)
            end)

            net.Start("RAM_MapVoteUpdate")
                net.WriteUInt(MapVote.UPDATE_SUDDEN_DEATH, 3)
                net.WriteUInt(winner, 32)
            net.Broadcast()
        end

        return
    end

    MapVote.Allow = false

    net.Start("RAM_MapVoteUpdate")
        net.WriteUInt(MapVote.UPDATE_WIN, 3)

        net.WriteUInt(winner, 32)
    net.Broadcast()

    local map = MapVote.CurrentMaps[winner]


    timer.Simple(4, function()
        hook.Run("MapVoteChange", map)
        RunConsoleCommand("changelevel", map)
    end)
end

function MapVote.Cancel()
    if MapVote.Allow then
        MapVote.Allow = false

        net.Start("RAM_MapVoteCancel")
        net.Broadcast()

        timer.Remove("RAM_MapVote")
    end
end

function MapVote.MapList(prefix)
    local is_expression = false

    if !prefix then
        local info = file.Read(GAMEMODE.Folder .. "/" .. GAMEMODE.FolderName .. ".txt", "GAME")

        if (info) then
            info = util.KeyValuesToTable(info)
            prefix = info.maps
        else
            error("MapVote Prefix can not be loaded from gamemode")
        end

        is_expression = true
    else
        if prefix and type(prefix) != "table" then
            prefix = {prefix}
        end
    end

    local maps = file.Find("maps/*.bsp", "GAME")
    local filter_maps = {}
    
    for _, map in pairs(maps) do
        if is_expression then
            if (string.find(map, prefix)) then -- This might work (from gamemode.txt)
                filter_maps[#filter_maps + 1] = map:sub(1, -5)
            end
        else
            for _, v in pairs(prefix) do
                if string.find(map:lower(), "^" .. v) then
                    filter_maps[#filter_maps + 1] = map:sub(1, -5)
                    break
                end
            end
        end
    end

    table.sort(filter_maps) -- gmod already does this today, but who knows about tomorrow...
    return filter_maps
end
