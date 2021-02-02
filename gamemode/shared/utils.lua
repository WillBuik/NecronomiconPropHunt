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
    for _, prop in pairs(props) do
        if (prop:GetNextTauntAvailableTime() > CurTime()) then
            if (closestPlyTaunting == nil or
                ply:GetPos():DistToSqr(prop:GetPos()) < ply:GetPos():DistToSqr(closestPlyTaunting:GetPos())) then
                closestPlyTaunting = prop
            end
        end
    end
    return closestPlyTaunting
end

function PropHitbox(ply)
    local tHitboxMin, tHitboxMax = ply:GetProp():GetHitBoxBounds(0, 0)
    if (ply:IsPropAngleLocked()) then
        tHitboxMin, tHitboxMax = ply:GetProp():GetRotatedAABB(tHitboxMin, tHitboxMax)
     end

    return tHitboxMin, tHitboxMax
end

function FindSpotForProp(ply, prop)
    local hbMin, hbMax = prop:GetHitBoxBounds(0, 0)
    return FindSpotFor(ply, hbMin, hbMax)
end

function FindSpotFor(ply, hbMin, hbMax)
    local goalPos = ply:GetPos()
    local td = {}
    td.filter = { ply }
    if (IsValid(ply:GetProp())) then
        table.insert(td.filter, ply:GetProp())
    end
    if ( !hbMin or !hbMax ) then return nil end
    -- Adjust height
--     hbMax = Vector(hbMax.x,hbMax.y,hbMax.z + hbMax.z)
--     hbMin = Vector(hbMin.x,hbMin.y,0)

    td.mins = hbMin
    td.maxs = hbMax


    -- Just checking if it's locked to begin with will almost always work so try it first
    do
        td.start = goalPos
        local trace = util.TraceHull( td )
        if (!trace.Hit) then
            return trace.HitPos
        end
    end

    local approachVec = (hbMax - hbMin) * 2
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

    return closestToGoal
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
    local cubeID = ply:AccountID() ^ 3
    return Vector(
        ((cubeID * 3) % 256) / 255,
        ((cubeID * 5) % 256) / 255,
        ((cubeID * 7) % 256) / 255
    )
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
    local secs = CurTime() - round.startTime + round.timePad
    if (round.state == ROUND_WAIT) then
        return OBJHUNT_PRE_ROUND_TIME - secs
    elseif (round.state == ROUND_IN or round.state == ROUND_START) then
        return OBJHUNT_ROUND_TIME - secs
    elseif (round.state == ROUND_END) then
        secs = CurTime() - round.endTime + round.timePad
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
    tr = util.TraceLine(trace)
    return tr.Entity
end

function FloorMagnitude(x)
    if x > 0 then
        return math.floor(x)
    else
        return math.ceil(x)
    end
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

    key = nil
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
