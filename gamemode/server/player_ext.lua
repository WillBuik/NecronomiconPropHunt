local plymeta = FindMetaTable("Player")
if (not plymeta) then return end

function plymeta:ObjStartRagdoll(velocityBoost, velocityMultiplier)
    velocityBoost = velocityBoost or Vector(0, 0, 0)
    velocityMultiplier = velocityMultiplier or 1
    -- Do nothing if already ragdolled
    if self.objRagdoll then
        return
    end

    if self:InVehicle() then
        self:ExitVehicle()
    end

    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetAngles(self:GetAngles())
    ragdoll:SetModel(self:GetModel())
    ragdoll:SetPos(self:GetPos())
    ragdoll:SetSkin(self:GetSkin())
    for _, value in pairs(self:GetBodyGroups()) do
        ragdoll:SetBodygroup(value.id, self:GetBodygroup(value.id))
    end
    ragdoll:SetColor(self:GetColor())
    ragdoll:SetOwner(self)
    ragdoll:Spawn()
    ragdoll:Activate()
    self:SetParent(ragdoll) -- So their player ent will match up (position-wise) with where their ragdoll is.
    -- Set velocity for each peice of the ragdoll

    local velocity = (self:GetVelocity() + velocityBoost) * velocityMultiplier
    local j = 1
    while true do -- Break inside
        local phys_obj = ragdoll:GetPhysicsObjectNum(j)
        if phys_obj then
            phys_obj:SetVelocity(velocity * math.Clamp(phys_obj:GetMass() / 10, 0, 2))
            j = j + 1
        else
            break
        end
    end

    --self:Spectate(OBS_MODE_CHASE)
    --self:SpectateEntity(ragdoll)
    self:Freeze(true)
    self:ObjSetRagdolled(true)
    for _, wep in pairs(self:GetWeapons()) do
        wep:SetNoDraw(true)
    end

    self.objRagdoll = ragdoll
end

function plymeta:ObjEndRagdoll()
    self:SetParent()
    --self:UnSpectate()
    self:Freeze(false)
    self:ObjSetRagdolled(false)
    for _, wep in pairs(self:GetWeapons()) do
        wep:SetNoDraw(false)
    end

    local ragdoll = self.objRagdoll
    self.objRagdoll = nil -- Gotta do this before spawn or our hook catches it

    if not IsValid(ragdoll) or not ragdoll:IsValid() then -- Something must have removed it, just spawn
        return
    else
--         if self:Alive() then
--             self:Spawn()
--         end

        local pos = ragdoll:GetPos()
        pos.z = pos.z + 8 -- So they don't end up in the ground

        self:SetModel(ragdoll:GetModel())
        self:SetPos(pos)
        self:SetVelocity(ragdoll:GetVelocity())
        local yaw = ragdoll:GetAngles().yaw
        self:SetAngles(Angle(0, yaw, 0))
        ragdoll:Remove()
    end
end

