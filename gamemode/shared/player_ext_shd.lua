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

function plymeta:ObjSetRagdolled(state)
    self:SetNWBool("objAbilityIsRagdolled", state)
end

function plymeta:ObjIsRagdolled()
    return self:GetNWBool("objAbilityIsRagdolled", false)
end

-- indicates whether the player has set the Play Dead ability to trigger
function plymeta:ObjSetShouldPlaydead(state)
    self:SetNWBool("objPlaydeadEnabled", state)
end

function plymeta:ObjShouldPlaydead()
    return self:GetNWBool("objPlaydeadEnabled", false)
end

-- indicates whether the player is currently playing dead
function plymeta:ObjSetPlaydead(state)
    self:SetNWBool("objAbilityIsPlaydead", state)
end

function plymeta:ObjIsPlaydead()
    return self:GetNWBool("objAbilityIsPlaydead", false)
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

--[[=====================]]
--[[ Taunt-related state ]]
--[[=====================]]

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
