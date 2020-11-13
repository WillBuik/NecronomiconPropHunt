ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Draw()

    local owner = self:GetOwner()

    if !self:IsValid() or !IsValid(owner) then return end

    self:SetPos(owner:GetPos())

    local propAngle = owner:EyeAngles()
    -- snap to 45 degree increments on yaw, and dissallow pitch unless enablePitch is turned on

    -- angle snapping stuff
    if (owner.wantAngleSnap) then
        propAngle:SnapTo("y",45)
    end

    -- Disable pitch movement
    if (!owner:IsPropPitchEnabled()) then
        propAngle:SnapTo("p",180)
    end

    -- angle locking stuff
    if (!owner.wantAngleLock) then
        self:SetAngles(propAngle)
    else
        self:SetAngles(owner.lockedAngle)
    end



    if (CLIENT) then
        -- third person stuff
        if (LocalPlayer().wantThirdPerson or self:GetOwner() != LocalPlayer()) then
            self:DrawModel()
        end
    end
end

function ENT:Think()
    self:Draw()
    if (SERVER) then
        local owner = self:GetOwner()
        local tHitboxMin, tHitboxMax = PropHitbox(owner)

        --Adjust Position for no stuck
        local foundSpot = FindSpotFor(owner, tHitboxMin, tHitboxMax)
        ply:SetPos(foundSpot) -- + Vector(0,0, -tHitboxMin.z))
    end
end
