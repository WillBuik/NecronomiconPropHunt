function GetLivingPlayers(onTeam)
    local allPly = team.GetPlayers(onTeam)
    local livingPly = {}
    for _, v in pairs(allPly) do
        if (IsValid(v) and v:Alive()) then
            livingPly[#livingPly + 1] = v
        end
    end
    return livingPly
end

function GetClosestTaunter(ply)
    local props = GetLivingPlayers(TEAM_PROPS)
    local closestPlyTaunting = nil
    local now = CurTime()
    for _, prop in pairs(props) do
        if (prop:IsTauntingRightNow(now)) then
            if (closestPlyTaunting == nil or
                ply:GetPos():DistToSqr(prop:GetPos()) < ply:GetPos():DistToSqr(closestPlyTaunting:GetPos())) then
                closestPlyTaunting = prop
            end
        end
    end
    return closestPlyTaunting
end

function GetClosestHunter(ply)
    local hunters = GetLivingPlayers(TEAM_HUNTERS)
    local closestHunter = nil
    for _, hunter in pairs(hunters) do
        if (closestHunter == nil or
            ply:GetPos():DistToSqr(hunter:GetPos()) < ply:GetPos():DistToSqr(closestHunter:GetPos())) then
                closestHunter = hunter
        end
    end
    return closestHunter
end

function GetHunterLookingAtYou(ply)
    local hunters = GetLivingPlayers(TEAM_HUNTERS)
    for _, hunter in pairs(hunters) do
        local trace = {}
        trace.mask = MASK_SHOT_HULL
        trace.start = hunter:GetShootPos()
        trace.endpos = trace.start + (hunter:EyeAngles():Forward() * PROP_SELECT_DISTANCE * 3)
        trace.filter = { ply }
        local tr = util.TraceLine(trace)
        if tr.Entity == ply then return hunter end
    end
    return nil
end

function PropHitbox(ply)
    local prop = ply:GetProp()
    prop:SnapToPlayer()
    local tHitboxMin, tHitboxMax = GetHitBoxInModelCoordinates(prop)
    if (ply:IsPropAngleLocked()) then
        tHitboxMin, tHitboxMax = prop:GetRotatedAABB(tHitboxMin, tHitboxMax)
    end
    return tHitboxMin, tHitboxMax
end

-- Get an entity's hitbox as mins,maxs relative to the entity's model, not the
-- entity's bones.  You should prefer this function over direct calls to
-- Entity:GetHitBoxBounds() in virtually all cases.
function GetHitBoxInModelCoordinates(ent)
    return ent:GetModelBounds()
end

function FindSpotForProp(ply, prop)
    local hbMin, hbMax = GetHitBoxInModelCoordinates(prop)
    return FindSpotFor(ply, hbMin, hbMax)
end

-- Find a clear location for the given player, assuming that their new hitbox
-- and hull will be defined by hbMin,hbMax (vectors relative to the player's
-- position and angle).
function FindSpotFor(ply, hbMin, hbMax, searchMultplier)
    if (!hbMin or !hbMax) then return nil end

    local plyPos = ply:GetPos()

    -- Compute a vertical adjustment to align the bottom of the given hitbox
    -- with the bottom of the player's current hull.
    local plyMin, plyMax = ply:GetHull()
    local playerFloor = math.min(plyMin.z, plyMax.z)
    local propFloor = math.min(hbMin.z, hbMax.z)
    local zDelta = playerFloor - propFloor

    -- Initialize some fields of the TraceHull input.  We will be doing several
    -- traces, but these fields won't change.
    local goalPos = plyPos + Vector(0, 0, zDelta)
    local td = {}
    td.filter = { ply, ply.objRagdoll }
    if (IsValid(ply:GetProp())) then
        table.insert(td.filter, ply:GetProp())
    end

    -- NOTE: something extremely subtle is happening here.  The hbMin and hbMax
    -- vectors are relative to the player's current position and angle, but we
    -- aren't tracing a rotated hull.  Instead, we are ignoring the player's
    -- rotation and tracing a hull that is axis-aligned in world coordinates.
    -- This is deliberate!  Garry's Mod (or perhaps the underlying Source
    -- Engine) has a deep-seated limitation that player collision hulls are
    -- always axis-aligned in world coordinates.  Therefore, this
    -- ridiculous-looking trace actually CORRECTLY corresponds to the player's
    -- future collision hull given hbMin,hbMax, even though it is not rotated.
    --
    -- And besides, we couldn't do a trace with a rotated hull even if we
    -- wanted.  See: https://github.com/Facepunch/garrysmod-requests/issues/748
    td.mins = hbMin
    td.maxs = hbMax

    -- Just checking if it's locked to begin with will almost always work so try it first
    do
        td.start = goalPos
        td.endpos = goalPos
        local trace = util.TraceHull( td )
        if (!trace.Hit) then
            return trace.HitPos
        end
    end

    if (!searchMultplier) then
        searchMultplier = 2
    end
    local approachVec = (hbMax - hbMin) * searchMultplier
    local altWaysToApproach = {
        goalPos + Vector(0, 0, approachVec.z),
        goalPos + Vector(0, approachVec.y, 0),
        goalPos + Vector(0, -approachVec.y, 0),
        goalPos + Vector(approachVec.x, 0, 0),
        goalPos + Vector(-approachVec.x, 0, 0),
        goalPos + Vector(0, approachVec.y, approachVec.z),
        goalPos + Vector(0, -approachVec.y, approachVec.z),
        goalPos + Vector(approachVec.x, 0, approachVec.z),
        goalPos + Vector(-approachVec.x, 0, approachVec.z),
        goalPos + Vector(approachVec.x, approachVec.y, approachVec.z),
        goalPos + Vector(-approachVec.x, approachVec.y, approachVec.z),
        goalPos + Vector(approachVec.x, -approachVec.y, approachVec.z),
        goalPos + Vector(-approachVec.x, -approachVec.y, approachVec.z)
    }
    local closestToGoal = nil
    for _, approachPos in pairs(altWaysToApproach) do
        td.start = approachPos
        td.endpos = goalPos

        local trace = util.TraceHull( td )
        if (trace.HitPos != trace.StartPos and
            (closestToGoal == nil or goalPos:DistToSqr(trace.HitPos) < goalPos:DistToSqr(closestToGoal))
        ) then

            -- Double check that the discovered position is clear.  If our
            -- trace STARTED inside a solid object (like a wall, a ceiling, or
            -- another prop), then the HitPos will not necessarily equal
            -- StartPos, even if the trace hull is still colliding with that
            -- solid object at the end.  (NOTE 2021/1/31: from what I can tell
            -- by testing, the HitPos reports the location where the hull
            -- started intersecting a NEW object, not the first position where
            -- it intersected ANY object.  Objects that the hull intersects at
            -- the start of the trace affect trace.Hit but not trace.HitPos.)
            --
            -- It is better to do this check here, AFTER doing the trace,
            -- because we actually don't want to exclude traces that start
            -- inside the ceiling but end up in a clear position on the floor.
            local candidatePos = trace.HitPos
            td.start = candidatePos
            td.endpos = candidatePos
            trace = util.TraceHull(td, trace)
            if (!trace.Hit) then
                closestToGoal = trace.HitPos
            end

        end
    end

    if closestToGoal != nil then
        return closestToGoal
    end

    -- default to the original position to avoid spawning at map origin
    print("Could not find a safe position to spawn prop!")
    return plyPos
end

function LerpColor(frac,from,to)
    return Color(
        Lerp(frac,from.r,to.r),
        Lerp(frac,from.g,to.g),
        Lerp(frac,from.b,to.b),
        Lerp(frac,from.a,to.a)
    )
end

function PlayerToAccentColor(ply)
    if !ply:AccountID() then return Vector(0,0,0) end
    -- We have to make the ID small enough to avoid floating point error
    local idInt = math.floor(ply:AccountID() / math.max(1, 10^(math.floor(math.log10(ply:AccountID()) - 10))))
    -- We'll use the Division Method for hashing from here:
    -- https://www.cs.hmc.edu/~geoff/classes/hmc.cs070.200101/homework10/hashfuncs.html
    -- We just need 3 random-ish, reasonably sized (bigger than 256 by an order of
    -- magintude but small enough so no floating point error) primes than aren't close
    -- to powers of 2.
    return Vector(
        (idInt % 5021) % 256,
        (idInt % 1321) % 256,
        (idInt % 6857) % 256
    ) / 256
end

function RandomTaunt(ply)
    if (ply:Team() == TEAM_PROPS) then
        return table.Random(PROP_TAUNTS)
    else
        return table.Random(HUNTER_TAUNTS)
    end
end

function RandomPitch()
    local pRange = TAUNT_MAX_PITCH - TAUNT_MIN_PITCH
    return math.random() * pRange + TAUNT_MIN_PITCH
end

function TeamString(teamID)
    if (teamID == TEAM_HUNTERS) then
        return "Hunters"
    elseif (teamID == TEAM_PROPS) then
        return "Props"
    elseif (teamID == TEAM_SPECTATOR) then
        return "Spectators"
    else
        return "UNKNOWN"
    end
end

function RoundToTime(round)
    local secs = CurTime() - round.startTime
    if (round.state == ROUND_WAIT) then
        return OBJHUNT_PRE_ROUND_TIME - secs
    elseif (round.state == ROUND_IN or round.state == ROUND_START) then
        return OBJHUNT_ROUND_TIME - secs
    elseif (round.state == ROUND_END) then
        secs = CurTime() - round.endTime
        return OBJHUNT_POST_ROUND_TIME - secs
    else
        return 0
    end
end

function GetViewEntSv(ply)
    local trace = {}
    trace.mask = MASK_SHOT_HULL
    trace.start = ply:GetShootPos()
    trace.endpos = trace.start + ply:GetAngles():Forward() * (THIRDPERSON_DISTANCE + PROP_SELECT_DISTANCE)
    trace.filter = { ply:GetProp(), ply }
    local tr = util.TraceLine(trace)
    return tr.Entity
end

function FloorMagnitude(x)
    if x > 0 then
        return math.floor(x)
    else
        return math.ceil(x)
    end
end

function AddAngleToXY(vector, rangle)
    local radius = math.sqrt(vector.x ^ 2, vector.y ^ 2)
    local theta = math.atan2(vector.y, vector.x) + rangle
    return Vector(radius * math.cos(theta), radius * math.sin(theta), vector.z)
end


--[[
Ordered table iterator, allow to iterate on the natural order of the keys of a
table.

Example:
]]

function __genOrderedIndex(t)
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert(orderedIndex, key)
    end
    table.sort(orderedIndex)
    return orderedIndex
end

function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state))
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex(t)
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1, #t.__orderedIndex do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i + 1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

function EmptySet()
    local newSet = {}
    newSet["size"] = 0
    newSet["elements"] = {}
    return newSet
end

function SetAdd(set, elem)
    if (!set["elements"][elem]) then
        set["size"] = set["size"] + 1
        set["elements"][elem] = 1
    else
        set["elements"][elem] = set["elements"][elem] + 1
    end
end

function SetContains(set, elem)
    if !set then return false end
    return set["elements"][elem] > 0
end

function SetSize(set)
    if !set then return 0 end
    return set["size"]
end


function SetCountGet(set, elem)
    if !set or !set["elements"][elem] then return 0 end
    return set["elements"][elem]
end

function SetCountGetMax(set)
    if !set or !set["elements"] then return 0 end

    local currentMax = 0
    for _, v in pairs(set["elements"]) do
        currentMax = math.max(currentMax, v)
    end
    return currentMax
end
