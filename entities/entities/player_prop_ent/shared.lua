ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Draw()
    if !IsValid(self) then return end

    local owner = self:GetOwner()
    if !IsValid(owner) then return end

    self:SnapToPlayer()

    if (CLIENT) then
        -- third person stuff
        if (LocalPlayer().wantThirdPerson or owner != LocalPlayer()) then
            self:DrawModel()
        end
    end
end

function ENT:Think()
    if !IsValid(self) then return end
    self:SnapToPlayer()
end

-- Adjust the prop's position and angle to match the player.  This should be
-- called frequently on both server and client.
--
-- In general, the prop's position and angle cannot be trusted, since it will
-- lag behind the player's by just a smidge.  Procedures that need up-to-date
-- information should call this before reading the prop's properties.
--
-- Precondition: IsValid(self)
function ENT:SnapToPlayer()

    local owner = self:GetOwner()
    if !IsValid(owner) then return end

    self:SetPos(owner:GetPos())

    local propAngle
    if (owner:IsPropAngleLocked()) then
        propAngle = owner:GetPropLockedAngle()
    else
        -- snap to 45 degree increments on yaw, and dissallow pitch unless enablePitch is turned on
        propAngle = owner:EyeAngles()

        -- angle snapping stuff
        if (owner:IsPropAngleSnapped()) then
            propAngle:SnapTo("y",45)
        end

        -- Disable pitch movement
        if (!owner:IsPropPitchEnabled()) then
            propAngle:SnapTo("p",180)
        end
    end

    self:SetAngles(Angle(propAngle.p, propAngle.y, owner:GetPropRollAngle()))

end
