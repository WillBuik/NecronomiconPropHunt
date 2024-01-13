-- Include needed files
include("shared.lua")

function ENT:Draw()
    if !IsValid(self) then return end

    self:SnapToEntity()
    self:DrawModel()
end
