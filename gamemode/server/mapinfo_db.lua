-- Utilities for storing and retreiving information about maps.

local function map_info_table_exists()
    return sql.TableExists(MAP_DB_TABLE_NAME)
end

local function init_map_info_table()
    sql.Query("CREATE TABLE " .. MAP_DB_TABLE_NAME .. "(map_name TEXT PRIMARY KEY, prop_count INT, broken INT, comment TEXT, play_count INT)")
end

-- Store map info in the server database
-- Nil values retain their previous value and default to false, 0, or "".
function save_map_info(map_name, prop_count, broken, comment, play_count)
    if !map_info_table_exists() then
        init_map_info_table()
    end

    local in_db, prev_prop_count, prev_broken, prev_comment, prev_play_count = load_map_info(map_name)
    if !in_db then
        prev_prop_count = 0
        prev_broken = false
        prev_comment = ""
        prev_play_count = 0
    end

    if type(prop_count) == "nil" then
        prop_count = prev_prop_count
    end
    if type(broken) == "nil" then
        broken = prev_broken
    end
    if type(comment) == "nil" then
        comment = prev_comment
    end
    if type(play_count) == "nil" then
        play_count = prev_play_count
    end

    -- Sanitize input
    local quoted_map_name = sql.SQLStr(map_name)
    prop_count = tonumber(prop_count)
    comment = sql.SQLStr(comment)
    if broken then
        broken = 1
    else
        broken = 0
    end
    play_count = tonumber(play_count)

    q = "REPLACE INTO " .. MAP_DB_TABLE_NAME .. " (map_name, prop_count, broken, comment, play_count) VALUES (" .. quoted_map_name .. ", " .. prop_count .. ", " .. broken .. ", " .. comment .. ", " .. play_count .. ")"
    sql.Query(q)
end

-- Returns in_db:bool, prop_count:number, broken:bool, comment:string, play_count:number.
-- If in_db is false, all other values are nil
function load_map_info(map_name)
    if !map_info_table_exists() then
        return false
    end

    local quoted_map_name = sql.SQLStr(map_name)

    q = "SELECT prop_count, broken, comment, play_count FROM " .. MAP_DB_TABLE_NAME .. " WHERE map_name = " .. quoted_map_name 
    local result = sql.QueryRow(q) -- Warning, this API returns everything as a string :(

    if result then
        return true, tonumber(result.prop_count), tonumber(result.broken) == 1, result.comment, tonumber(result.play_count)
    else
        return false
    end
end

-- Increments the play count for the current map.
-- Does nothing if the current map isn't in the database.
function increment_current_map_play_count()
    local cur_map = game.GetMap()
    local in_db, _, _, _, play_count = load_map_info(cur_map)
    if in_db then
        save_map_info(cur_map, nil, nil, nil, play_count + 1)
    end
end
