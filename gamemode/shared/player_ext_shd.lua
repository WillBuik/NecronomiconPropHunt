local plymeta = FindMetaTable("Player")
if (not plymeta) then return end

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

function plymeta:ObjSetPlaydead(state)
    self:SetNWBool("objAbilityIsPlaydead", state)
end

function plymeta:ObjIsPlayDead()
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

function plymeta:GetLastTauntTime()
    return self:GetNWFloat("LastTauntTime", 0)
end

function plymeta:SetLastTauntTime(time)
    self:SetNWFloat("LastTauntTime", time)
end

function plymeta:GetLastTauntDuration()
    return self:GetNWFloat("LastTauntDuration", 1)
end

function plymeta:SetLastTauntDuration(dur)
    self:SetNWFloat("LastTauntDuration", dur)
end

function plymeta:GetLastTauntPitch()
    return self:GetNWInt("LastTauntPitch", 100)
end

function plymeta:SetLastTauntPitch(pitch)
    self:SetNWInt("LastTauntPitch", pitch)
end

function plymeta:GetNextTauntAvailableTime()
    return self:GetLastTauntTime() + self:GetLastTauntDuration()
end

function plymeta:GetNextAutoTauntTime()
    return self:GetLastTauntTime() + OBJHUNT_AUTOTAUNT_DURATION_MODIFIER * (1 + self:GetLastTauntDuration()) + OBJHUNT_AUTOTAUNT_BASE_INTERVAL
end
