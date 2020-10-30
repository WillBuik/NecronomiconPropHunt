AddCSLuaFile()

SWEP.Base = "weapon_obj_base"
SWEP.Name = "Play Dead"
SWEP.PrintName = "Play Dead"

SWEP.AbilityDuration = 8
SWEP.AbilityDescription = "Transforms you into a ragdoll for $AbilityDuration seconds."

function SWEP:Ability()
    if CLIENT then return end

    local ply = self:GetOwner()
    self:AbilityTimerIfValidSWEP(self.AbilityDuration, 1, true, function()
        self:AbilityCleanup()
    end)


    local hunters = team.GetPlayers(TEAM_HUNTERS)
    local closestHunter = nil
    local closestDistSq = math.huge
    for _, hunter in pairs(hunters) do
        local currentDistSq = ply:GetPos():DistToSqr(hunter:GetPos())
        if IsValid(hunter) and hunter:Alive() and (currentDistSq < closestDistSq) then
            closestHunter = hunter
            closestDistSq = currentDistSq
        end
    end

    if IsValid(closestHunter) then
		net.Start( "Death Notice" )
			net.WriteString( closestHunter:Nick() )
			net.WriteUInt( closestHunter:Team(), 16 )
			net.WriteString( "found" )
			net.WriteString( ply:Nick() )
			net.WriteUInt( ply:Team(), 16 )
		net.Broadcast()
    end

    ply:GetProp():SetRenderMode( RENDERMODE_NONE )

    ply:ObjSetPlaydead(true)
    ply:ObjStartRagdoll()
end

function SWEP:AbilityCleanup()
    if CLIENT then return end
    if not IsValid( self:GetOwner() ) then return end
    if (IsValid(ply:GetProp())) then
        self:GetOwner():GetProp():SetRenderMode( RENDERMODE_NORMAL )
    end
    self:GetOwner():ObjSetPlaydead(false)
    self:GetOwner():ObjEndRagdoll()
end

if CLIENT then
    hook.Add( "OnEntityCreated", "objRagdollPlayerColor", function( ent )
        if IsValid(ent) and ent:GetClass() == "prop_playdead" and IsValid(ent:GetOwner()) and ent:GetOwner():IsPlayer() then
            ent.GetPlayerColor = function(self)
                if IsValid(ent:GetOwner()) and ent:GetOwner():IsPlayer()  and ent:GetOwner().GetPlayerColor then
                    return self:GetOwner():GetPlayerColor()
                end
                return Vector(1, 1, 1)
            end
        end
    end)
end
