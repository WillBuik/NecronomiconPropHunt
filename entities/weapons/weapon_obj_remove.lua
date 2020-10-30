AddCSLuaFile()

SWEP.Base = "weapon_obj_base"
SWEP.Name = "Remove"
SWEP.PrintName = "Remove"

SWEP.AbilityDescription = "Removes the Prop you're looking at for better hiding."

function SWEP:Ability()
    if SERVER then return end
    local ply = self:GetOwner()
    print("got to 1")
    local prop = getViewEnt( ply )
	net.Start( "Remove Prop" )
		net.WriteEntity( prop )
	net.SendToServer()
end

function getViewEnt(ply)
	-- this needs to be here otherwise some people get errors for some unknown reason
	if( ply.viewOrigin == nil || ply.wantThirdPerson == nil ) then return end

    print("got to 2")
	local trace = {}
	trace.mask = MASK_SHOT_HULL
	trace.start = ply.viewOrigin
	if( ply.wantThirdPerson ) then
		trace.endpos = trace.start + ply:GetAngles():Forward() * (THIRDPERSON_DISTANCE+PROP_SELECT_DISTANCE)
	else
		trace.endpos = trace.start + ply:GetAngles():Forward() * (PROP_SELECT_DISTANCE)
	end
	trace.filter = { ply:GetProp(), ply }
	tr = util.TraceLine(trace)
    print("got to 3")
	return tr.Entity
end
