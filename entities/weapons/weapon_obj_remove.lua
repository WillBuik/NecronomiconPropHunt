AddCSLuaFile()

SWEP.Base = "weapon_obj_base"
SWEP.Name = "Remove"
SWEP.PrintName = "Remove"

SWEP.AbilityDescription = "Removes the Prop you're looking at for better hiding."

function SWEP:Ability()
    if SERVER then return end
    local ply = self:GetOwner()
    local prop = getViewEnt(ply)
    net.Start("Remove Prop")
        net.WriteEntity(prop)
    net.SendToServer()
end

function getViewEnt(ply)
    -- this needs to be here otherwise some people get errors for some unknown reason
    if (ply.viewOrigin == nil or ply.wantThirdPerson == nil) then return end

    local trace = {}
    trace.mask = MASK_SHOT_HULL
    trace.start = ply.viewOrigin
    if (ply.wantThirdPerson) then
        trace.endpos = trace.start + ply:GetAngles():Forward() * (THIRDPERSON_DISTANCE + PROP_SELECT_DISTANCE)
    else
        trace.endpos = trace.start + ply:GetAngles():Forward() * PROP_SELECT_DISTANCE
    end
    trace.filter = { ply:GetProp(), ply }
    tr = util.TraceLine(trace)
    return tr.Entity
end
