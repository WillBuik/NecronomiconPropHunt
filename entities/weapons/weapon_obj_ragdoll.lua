AddCSLuaFile()

SWEP.Base = "weapon_obj_base"
SWEP.Name = "Ragdoll"
SWEP.PrintName = "Ragdoll"

SWEP.AbilityDuration = 8
SWEP.AbilityDescription = "Pretty much what the name suggests.\nTransforms you into a ragdoll for $AbilityDuration seconds."

function SWEP:Ability()
    if CLIENT then return end

    local ply = self:GetOwner()
    self:AbilityTimerIfValidSWEP(self.AbilityDuration, 1, true, function()
        self:AbilityCleanup()
    end)


    local hunters = team.GetPlayers(TEAM_HUNTERS)
    local aliveHunters = {}
    for _, hunter in pairs(hunters) do
        if IsValid(hunter) and hunter:Alive() then
            table.insert(aliveHunters, hunter)
        end
    end

    local aliveHunter = aliveHunters[math.random(#aliveHunters)]

    if IsValid(aliveHunter) and IsValid(aliveHunter:GetActiveWeapon()) then
		net.Start( "Death Notice" )
			net.WriteString( aliveHunter:Nick() )
			net.WriteUInt( aliveHunter:Team(), 16 )
			net.WriteString( "found" )
			net.WriteString( ply:Nick() )
			net.WriteUInt( ply:Team(), 16 )
		net.Broadcast()
    end

    ply:GetProp():SetRenderMode( RENDERMODE_NONE )

    ply:ObjStartRagdoll()
end

function SWEP:AbilityCleanup()
    if CLIENT then return end
    if not IsValid( self:GetOwner() ) then return end
    self:GetOwner():GetProp():SetRenderMode( RENDERMODE_NORMAL )
    self:GetOwner():ObjEndRagdoll()
end

if CLIENT then
    hook.Add( "OnEntityCreated", "objRagdollPlayerColor", function( ent )
        if IsValid(ent) and ent:GetClass() == "prop_ragdoll" and IsValid(ent:GetOwner()) and ent:GetOwner():IsPlayer() then
            ent.GetPlayerColor = function(self)
                if IsValid(ent:GetOwner()) and ent:GetOwner():IsPlayer()  and ent:GetOwner().GetPlayerColor then
                    return self:GetOwner():GetPlayerColor()
                end
                return Vector(1, 1, 1)
            end
        end
    end)
end
