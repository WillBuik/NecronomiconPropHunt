local plymeta = FindMetaTable("Player")
if (!plymeta) then return end

function plymeta:ObjSetDisguised(state)
    self:SetNWBool("objAbilityIsDisguised", state)
end

function plymeta:ObjIsDisguised()
    return self:GetNWBool("objAbilityIsDisguised", false)
end

function plymeta:ObjSetDisguiseName(name)
    self:SetNWString("objAbilityDisguiseName", string.sub(name, 1, math.min(#name, 64)))
end

function plymeta:ObjGetDisguiseName()
    return self:GetNWString("objAbilityDisguiseName", "")
end

-- indicates whether the player has set the Play Dead ability to trigger and how long it should go
function plymeta:ObjSetPlaydeadDuration(dur)
    self:SetNWBool("objPlaydeadDuration", dur)
end

function plymeta:ObjGetPlaydeadDuration()
    return self:GetNWBool("objPlaydeadDuration", -1)
end

-- indicates whether the player is currently playing dead
function plymeta:ObjSetPlaydead(state)
    self:SetNWBool("objAbilityIsPlaydead", state)
end

function plymeta:ObjIsPlaydead()
    return self:GetNWBool("objAbilityIsPlaydead", false)
end

function plymeta:IsZoolander()
    return self:GetNWBool("objZoolander", false)
end

function plymeta:SetZoolander(zoolander)
    return self:SetNWBool("objZoolander", zoolander)
end

function plymeta:IsPropPitchEnabled()
    return self:GetNWBool("PropPitchEnabled", false)
end

function plymeta:SetPropPitchEnabled(isEnabled)
    self:SetNWBool("PropPitchEnabled", isEnabled)
end

function plymeta:GetPropLockedAngle()
    return self:GetNWAngle("PropLockedAngle", Angle(0,0,0))
end

function plymeta:SetPropLockedAngle(angle)
    self:SetNWAngle("PropLockedAngle", angle)
end

function plymeta:IsPropAngleLocked()
    return self:GetNWBool("PropAngleLocked", false)
end

function plymeta:SetPropAngleLocked(isLocked)
    return self:SetNWBool("PropAngleLocked", isLocked)
end

function plymeta:IsPropAngleSnapped()
    return self:GetNWBool("PropAngleSnapped", false)
end

function plymeta:SetPropAngleSnapped(isSnapped)
    return self:SetNWBool("PropAngleSnapped", isSnapped)
end

function plymeta:GetPropRollAngle()
    return self:GetNWInt("PropRollAngle", 0)
end

function plymeta:SetPropRollAngle(angle)
    self:SetNWInt("PropRollAngle", angle)
end

function plymeta:GetPropLastChange()
    return self:GetNWFloat("PropLastChange", 0)
end

function plymeta:SetPropLastChange(time)
    self:SetNWInt("PropLastChange", time)
end

function plymeta:GetPropPoints()
    return self:GetNWFloat("PropPoints", 0)
end

function plymeta:SetPropPoints(points)
    self:SetNWInt("PropPoints", points)
end

function plymeta:AddPropPoints(points)
    local currentPoints = self:GetPropPoints()
    self:SetPropPoints(currentPoints + points)
end

function plymeta:SetTimeOfDeath(time)
    self:SetNWFloat("TimeOfDeath", time)
end

function plymeta:GetTimeOfDeath()
    return self:GetNWFloat("TimeOfDeath", 0)
end

--[[=====================]]
--[[ Taunt-related state ]]
--[[=====================]]

-- CanTauntNowOrLater: Is this player ever allowed to taunt?  This method will
-- return true for players who can't taunt right now, but could in the future.

function plymeta:CanTauntNowOrLater()
    team = self:Team()
    if team == TEAM_PROPS then
        return true -- all props can taunt, even as ghosts
    elseif team == TEAM_HUNTERS then
        return self:Alive() -- hunters can taunt when they are alive
    else
        return false -- spectators can't ever taunt
    end
end

-- CanTauntAt: Is this player allowed to taunt, and can they do it at the given
-- timestamp?  (Quick design note: taking the timestamp as an argument rather
-- than reading CurTime() inside this method is (1) more generic and (2)
-- enables callers to avoid race conditions where the system clock changes
-- between calling this method and using the result.)  Since we don't remember
-- old taunts, this method is only meaningful for times >= GetLastTauntTime().

function plymeta:CanTauntAt(time)
    return self:CanTauntNowOrLater() and time >= self:GetNextTauntAvailableTime()
end

-- LastTauntTime: the timestamp of the last time this player issued a taunt.
-- (NOTE 2020/1/10: the meaning of this variable is extremely unclear before
-- the player's first taunt of the round.)

function plymeta:GetLastTauntTime()
    return self:GetNWFloat("LastTauntTime", 0)
end

function plymeta:SetLastTauntTime(time)
    self:SetNWFloat("LastTauntTime", time)
end

-- LastTauntDuration: how long the last taunt played.  If a taunt is currently
-- playing, this is the duration of the currently-playing taunt.  The duration
-- is already pitch-adjusted, and represents the true duration that the audio
-- took to play.
-- (NOTE 2020/1/10: the meaning of this variable is extremely unclear before
-- the player's first taunt of the round.)

function plymeta:GetLastTauntDuration()
    return self:GetNWFloat("LastTauntDuration", 1)
end

function plymeta:SetLastTauntDuration(dur)
    self:SetNWFloat("LastTauntDuration", dur)
end

-- NextTauntAvailableTime: the next timestamp when the player is eligible to
-- issue a taunt.  For example, the player may not issue a new taunt while
-- their previous taunt is still playing.
-- (NOTE 2020/1/10: should this variable prevent taunts before the hunters are
-- released?  Today, it does not.)
-- (NOTE 2020/1/10: While I believe we can assign a sensible value like 0 to
-- this variable before the player's first taunt, it isn't obvious what value
-- this has at the start of a round.)

function plymeta:GetNextTauntAvailableTime()
    return self:GetLastTauntTime() + self:GetLastTauntDuration()
end

-- IsTauntingRightNow: is the player currently playing a taunt?  (Quick design
-- note: this method takes the current timestamp as an argument.  See
-- CanTauntAt docs for justification.)  Since we don't remember old taunts and
-- we can't predict when the player will taunt in the future, this method is
-- only meaningful when the `now` argument is approximately CurTime().

function plymeta:IsTauntingRightNow(now)
    local lastTauntStart = self:GetLastTauntTime()
    local lastTauntEnd = start + self:GetLastTauntDuration()
    return lastTauntStart <= now and now <= lastTauntEnd
end

-- NextAutoTauntDelay: the duration from the last taunt to the next auto-taunt.

function plymeta:GetNextAutoTauntDelay()
    return self:GetNWFloat("NextAutoTauntDelay", 1)
end

function plymeta:SetNextAutoTauntDelay(delay)
    self:SetNWFloat("NextAutoTauntDelay", delay)
end

-- NextAutoTauntTime: the timestamp of the next auto-taunt.  This is always
-- equal to LastTauntTime + NextAutoTauntDelay.

function plymeta:GetNextAutoTauntTime()
    return self:GetLastTauntTime() + self:GetNextAutoTauntDelay()
end
