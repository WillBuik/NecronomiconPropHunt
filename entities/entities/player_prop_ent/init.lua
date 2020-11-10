AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/player.mdl")
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end
