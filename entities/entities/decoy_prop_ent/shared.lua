ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Think()
    if !IsValid(self) then return end
    self:SnapToEntity()
end

-- Adjust the decoy prop's position and angle to owning entity.  This should be
-- called frequently on both server and client.
--
-- In general, the prop's position and angle cannot be trusted, since it will
-- lag behind the player's by just a smidge.  Procedures that need up-to-date
-- information should call this before reading the prop's properties.
--
-- Precondition: IsValid(self)
function ENT:SnapToEntity()

    local owner = self:GetOwner()
    if !IsValid(owner) then return end

    local box_min, _ = GetHitBoxInModelCoordinates(self)
    self:SetPos(owner:GetPos() - Vector(0, 0, box_min.z))

    local propAngle
    -- dissallow pitch 
    propAngle = owner:EyeAngles()
    propAngle:SnapTo("p", 180)

    self:SetAngles(Angle(propAngle.p, propAngle.y, 0))
end
