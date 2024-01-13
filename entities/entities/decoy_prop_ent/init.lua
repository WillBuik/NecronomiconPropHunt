AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/player/items/humans/top_hat.mdl")
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end
