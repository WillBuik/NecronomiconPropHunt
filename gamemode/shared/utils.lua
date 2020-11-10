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

-- now realised there is a flag to ignore ws, don't use this it's not done....
function isStuck(ply)
    local pos = ply:GetPos()
    local ws = game.GetWorld()
    local td = {}
    td.start = pos
    td.endpos = pos
    td.filter = { ply, ply.chosenProp, ws }
    td.mins, td.maxs = ply:GetHitBoxBounds(0,0)

    local trace = util.TraceHull(td)

    ent = trace.Entity
    -- should never be stuck in world
    --if ent and (ent:IsWorld() or ent:IsValid()) then

    if (ent and ent:IsValid()) then
        return true
    end

    return false
end

function WouldBeStuck(ply, prop)
    local pos = ply:GetPos()
    local td = {}
    td.start = pos
    td.endpos = pos
    td.filter = { ply, ply:GetProp() }
    local hbMin, hbMax = prop:GetHitBoxBounds(0, 0)
    if (!hbMin or !hbMax) then return true end
    hbMin = Vector(math.Round(hbMin.x),math.Round(hbMin.y),math.Round(hbMin.z))
    hbMax = Vector(math.Round(hbMax.x),math.Round(hbMax.y),math.Round(hbMax.z))
    -- Adjust height
    hbMax = Vector(hbMax.x,hbMax.y,hbMax.z + hbMax.z)
    hbMin = Vector(hbMin.x,hbMin.y,0)

    td.mins = hbMin
    td.maxs = hbMax
    local trace = util.TraceHull(td)

    ent = trace.Entity
    if ent and (ent:IsWorld() or ent:IsValid()) then
        return true
    end

    return false
end

function GetClosestTaunter(ply)
    local props = GetLivingPlayers(TEAM_PROPS)
    local closestPlyTaunting = nil
    for _, prop in pairs(props) do
        if (prop.nextTaunt > CurTime()) then
            if (closestPlyTaunting == nil or
                ply:GetPos():DistToSqr(prop:GetPos()) < ply:GetPos():DistToSqr(closestPlyTaunting:GetPos())) then
                closestPlyTaunting = prop
            end
        end
    end
    return closestPlyTaunting
end

function PropHitbox(ply)
    local tHitboxMin, tHitboxMax = prop:GetHitBoxBounds(0, 0)
    if (ply.lockedAngle) then
        tHitboxMin, tHitboxMax = prop:GetRotatedAABB(tHitboxMin, tHitboxMax)
     end

    -- we round to reduce getting stuck
    tHitboxMin = Vector(math.Round(tHitboxMin.x), math.Round(tHitboxMin.y), math.Round(tHitboxMin.z))
    tHitboxMax = Vector(math.Round(tHitboxMax.x), math.Round(tHitboxMax.y), math.Round(tHitboxMax.z))
    return tHitboxMin, tHitboxMax
end

function FindSpotForProp(ply, prop)
    local hbMin, hbMax = prop:GetHitBoxBounds(0, 0)
    return FindSpotFor(ply, hbMin, hbMax)
end

function FindSpotFor(ply, hbMin, hbMax)
    local goalPos = ply:GetPos()
    local td = {}
    td.endpos = goalPos
    td.filter = { ply }
    if (IsValid(ply:GetProp())) then
        table.insert(td.filter, ply:GetProp())
    end
    if ( !hbMin or !hbMax ) then return true end
    -- Adjust height
--     hbMax = Vector(hbMax.x,hbMax.y,hbMax.z + hbMax.z)
--     hbMin = Vector(hbMin.x,hbMin.y,0)

    td.mins = hbMin
    td.maxs = hbMax

    local approachVec = (hbMax - hbMin) * 2

    -- Approaching from the z direction will almost always work so try it first
    local defaultApproach = goalPos + Vector(0, 0, approachVec.z)
    do
        td.start = defaultApproach
        local trace = util.TraceHull( td )
        if (trace.HitPos != trace.StartPos) then
            return trace.HitPos
        end
    end

    local altWaysToApproach = {
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
        local trace = util.TraceHull( td )
        if (trace.HitPos != trace.StartPos and
            (closestToGoal == nil or goalPos:DistToSqr(trace.HitPos) < goalPos:DistToSqr(closestToGoal))
        ) then
            closestToGoal = trace.HitPos
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
