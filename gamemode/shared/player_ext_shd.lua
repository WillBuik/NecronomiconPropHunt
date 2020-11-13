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

function plymeta:SetPropLockedAngle(isLocked)
    return self:SetNWBool("PropLockedAngle", isLocked)
end
