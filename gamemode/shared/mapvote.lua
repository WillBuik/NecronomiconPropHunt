MapVote = {}
MapVote.Config = {}

-- CONFIG (sort of)
    MapVote.Config = {
        MapLimit = 24,
        TimeLimit = 28,
        AllowCurrentMap = false,
        SuddenDeathThreshold = 0.75,
        SuddenDeathTimeLimit = 5,
    }
-- CONFIG

function MapVote.HasExtraVotePower(ply)
    return false
end


MapVote.CurrentMaps = {}
MapVote.Votes = {}

MapVote.Allow = false

MapVote.UPDATE_VOTE = 1
MapVote.UPDATE_WIN = 3
MapVote.UPDATE_SUDDEN_DEATH = 4
