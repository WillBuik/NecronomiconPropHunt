ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Draw()

    local owner = self:GetOwner()

    if !self:IsValid() or !IsValid(owner) then return end

    self:SetPos(owner:GetPos())

    local propAngle = owner:EyeAngles()
    -- snap to 45 degree increments on yaw, and dissallow pitch unless enablePitch is turned on

    -- angle snapping stuff
    if (owner:IsPropAngleSnapped()) then
        propAngle:SnapTo("y",45)
    end

    -- Disable pitch movement
    if (!owner:IsPropPitchEnabled()) then
        propAngle:SnapTo("p",180)
    end

    -- Disable pitch movement
    propAngle:Add(Angle(0, 0, owner:GetPropRollAngle()))

    -- angle locking stuff
    if (!owner:IsPropAngleLocked()) then
        self:SetAngles(propAngle)
    else
        self:SetAngles(owner:GetPropLockedAngle())
    end

    if (CLIENT) then
        -- third person stuff
        if (LocalPlayer().wantThirdPerson or owner != LocalPlayer()) then
            self:DrawModel()
        end
    end
end

function ENT:Think()
    self:Draw()
end
