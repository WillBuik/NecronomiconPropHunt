AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Play Dead"
SWEP.PrintName = "Play Dead"

SWEP.AbilityDuration = 0
SWEP.AbilityDescription = "Transforms you into a ragdoll for 8 seconds the next time you take damage."

function SWEP:Ability()
    if CLIENT then return end

    local ply = self:GetOwner()

    ply:ObjSetShouldPlaydead(true)
    ply:PrintMessage(HUD_PRINTTALK, "The next time you take damage, you will play dead.")
end

function SWEP:AbilityCleanup()
    self:GetOwner():ObjSetShouldPlaydead(false)
    self:GetOwner():ObjSetPlaydead(false)
end

if CLIENT then
    hook.Add("OnEntityCreated", "objRagdollPlayerColor", function(ent)
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
