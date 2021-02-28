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
        trace.endpos = trace.start + hunter:GetEyeAngles() * PROP_SELECT_DISTANCE * 3 
        trace.filter = { ply }
        tr = util.TraceLine(trace)
        if tr.Entity == ply then return hunter end
    end
    return nil
end

function PropHitbox(ply)
    local tHitboxMin, tHitboxMax = GetHitBoxInModelCoordinates(ply:GetProp())
    if (ply:IsPropAngleLocked()) then
        tHitboxMin, tHitboxMax = ply:GetProp():GetRotatedAABB(tHitboxMin, tHitboxMax)
    end
    return tHitboxMin, tHitboxMax
end

-- Compute the smallest axis-aligned bounding box that contains all of the
-- given points.  This is the inverse of AABBToVertices().
--
-- Returns mins,maxs of the bounding box, or nil,nil if #points == 0.
function FitAABB(points)
    local first = true
    local mins = nil
    local maxs = nil
    for _, pt in pairs(points) do
        if first then
            mins = Vector(pt)
            maxs = Vector(pt)
            first = false
        else
            mins.x = math.min(mins.x, pt.x)
            mins.y = math.min(mins.y, pt.y)
            mins.z = math.min(mins.z, pt.z)
            maxs.x = math.max(maxs.x, pt.x)
            maxs.y = math.max(maxs.y, pt.y)
            maxs.z = math.max(maxs.z, pt.z)
        end
    end
    return mins, maxs
end

-- Convert an axis-aligned bounding box to its list of corners.  This is the
-- inverse of FitAABB().
--
-- Returns the corners of the bounding box as a list of vectors.
function AABBToVertices(mins, maxs)
    return {
        Vector(mins.x, mins.y, mins.z),
        Vector(mins.x, mins.y, maxs.z),
        Vector(mins.x, maxs.y, mins.z),
        Vector(mins.x, maxs.y, maxs.z),
        Vector(maxs.x, mins.y, mins.z),
        Vector(maxs.x, mins.y, maxs.z),
        Vector(maxs.x, maxs.y, mins.z),
        Vector(maxs.x, maxs.y, maxs.z),
    }
end

-- Get the hitbox of an entity, adjusted so that it is relative to the entity
-- model, not the entity's bones.  Note that ent:GetHitBoxBounds(...) returns
-- the hit box relative to a bone, and while the bone USUALLY has the same
-- position and orientation as the model, it does not ALWAYS have the same
-- position and orientation as the model.
--
-- Precondition: ent != nil and IsValid(ent)
--
-- Returns: the corners of the entity's hitbox in model coordinates, as a table
-- of 8 vectors.  (In model coordinates the bounding box might not be
-- axis-aligned, so we can't just return mins,maxs like ent:GetHitBoxBounds.)
--
-- This function returns nil if the entity has no hitbox.
function GetHitBoxCornersInModelCoordinates(ent)
    -- NOTE: entities can have multiple hitboxes, but hitbox (0, 0) is usually
    -- the only one that matters.  This call returns the hitbox in bone
    -- coordinates.
    local hbMin, hbMax = ent:GetHitBoxBounds(0, 0)

    if (hbMin and hbMax) then
        local verts = AABBToVertices(hbMin, hbMax)
        local boneNo = ent:GetHitBoxBone(0, 0)

        -- Get the bone's world transformation matrix.  That is, for a vector
        -- V in bone coordinates, boneTransform*V gives V in world coordinates.
        --
        -- NOTE 2021/1/31: according to the gmod docs for Entity:GetBonePosition(),
        -- this call bypasses the "bone cache" and should be more reliable than
        -- Entity:GetBonePosition().
        local boneTransform = ent:GetBoneMatrix(boneNo)

        -- Compute the inverse of the entity's transformation matrix.  That is,
        -- for a vector V in world coordinates, invertEntityTransform*V gives V
        -- in entity coordinates.  Note that there is a defensive copy because
        -- Invert() modifies the matrix in-place.  Note also that if the matrix
        -- is not invertible, we don't try to proceed.
        local invertEntityTransform = Matrix(ent:GetWorldTransformMatrix())
        if invertEntityTransform:Invert() then

            -- Compute an overall transformation that converts bone coordinates
            -- to entity coordinates.  Note that the transformations are listed
            -- here in the reverse order they are applied:
            --
            --   transform * V = invertEntityTransform * boneTransform * V
            --                 = invertEntityTransform * (boneTransform * V)
            --                 = worldToEntityCoords(boneToWorldCoords(v))
            --
            local transform = invertEntityTransform * boneTransform

            local result = {}
            for i, v in pairs(verts) do
                result[i] = transform * v
            end

            return result
        end
    end
    return nil
end

-- Get an entity's hitbox as mins,maxs relative to the entity's model, not the
-- entity's bones.  You should prefer this function over direct calls to
-- Entity:GetHitBoxBounds() in virtually all cases.
--
-- This function fits an AABB around the corners returned by
-- GetHitBoxCornersInModelCoordinates; see that function for more details.
function GetHitBoxInModelCoordinates(ent)
    return FitAABB(GetHitBoxCornersInModelCoordinates(ent) or {})
end

function FindSpotForProp(ply, prop)
    local hbMin, hbMax = GetHitBoxInModelCoordinates(prop)
    return FindSpotFor(ply, hbMin, hbMax)
end

-- Find a clear location for the given player, assuming that their new hitbox
-- and hull will be defined by hbMin,hbMax (vectors relative to the player's
-- position and angle).
function FindSpotFor(ply, hbMin, hbMax)
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
    td.filter = { ply }
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
    if !ply:AccountID() then return Vector(0,0,0) end
    local cubeID = ply:AccountID() ^ 3
    local idHash = math.floor(cubeID / 10^(math.floor(math.log10(cubeID) - 10)))
    return Vector(
        ((idHash * 3) % 256) / 256,
        ((idHash * 5) % 256) / 256,
        ((idHash * 7) % 256) / 256
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

function AddAngleToXY(vector, rangle)
    local radius = math.sqrt(vector.x, vector.y)
    local theta = math.atan2(vector.y, vector.x) + rangle 
    return Vector(radius * cos(theta), radius * sin(theta), vector.z)
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

function EmptySet()
    local newSet = {}
    newSet["size"] = 0
    newSet["elements"] = {}
    return newSet
end

function SetAdd(set, elem)
    set["size"] = set["size"] + 1
    set["elements"][elem] = true
end

function SetContains(set, elem)
    if !set then return false end
    return set["elements"][elem] == true
end

function SetSize(set)
    if !set then return 0 end
    return set["size"]
end
