local plymeta = FindMetaTable( "Player" )
if ( not plymeta ) then return end

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
