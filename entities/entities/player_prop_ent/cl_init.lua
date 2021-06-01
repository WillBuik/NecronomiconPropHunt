-- Include needed files
include("shared.lua")

function ENT:Draw()
    if !IsValid(self) then return end

    self:SnapToPlayer()

    -- Only draw our own prop model when we are in 3rd person.  Always draw
    -- other players' prop models.
    if (LocalPlayer().wantThirdPerson or self:GetOwner() != LocalPlayer()) then
        self:DrawModel()
    end
end
