AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

function ENT:InitAsProp(start_pos, model, scale, movement_delay)
    -- Nextbot models must start at z=0 because their hull cannot be adjusted
    -- like players. :( As such, many props don't work. Instead spawn
    -- "decoy_prop_ent" to follow the bot. The "decoy_prop_ent" offsets its 
    -- own position to render the bottom of the prop at the bot's z=0.
    if !self.Prop then
        self.Prop = ents.Create("decoy_prop_ent")
        self.Prop:SetOwner(self)
        self.Prop:SetParent(self)
        self.Prop:Spawn()
    end
    self.Prop:SetModel(model)
    self.Prop:SetModelScale(scale)

    self.Delay = movement_delay

    self:SetPos(start_pos + Vector(5 * math.random(), 5 * math.random(), 0))
    self:DropToFloor()
    self:Spawn()
    self:Activate()
end

function ENT:InitAsPlayer(ply, movement_delay)
    local start_pos = ply:GetPos()
    local prop = ply:GetProp()
    if !IsValid(prop) then
        prop = ply -- For debugging, clone the player model of hunters
    end
    self:InitAsProp(start_pos, prop:GetModel(), prop:GetModelScale(), movement_delay)
end

function ENT:Initialize()
    self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    self:SetModel("models/player/combine_super_soldier.mdl")
    self:SetNoDraw(true)

    --self.IsRunning = true
    self.FearRadius = 200
end

function ENT:PlayerNear()
    for k, v in pairs(ents.FindInSphere(self:GetPos(), self.FearRadius)) do
        if (v:IsPlayer() and v:IsLineOfSightClear(self:GetPos())) then
            return true
        end
    end

    return false
end

function ENT:RunBehaviour()
    self.loco:SetStepHeight(30)

    if self.Delay then
        coroutine.wait(self.Delay)
    end

    while (true) do
        if (true) then
            self.loco:SetDesiredSpeed(300)
            self:StartActivity(ACT_RUN)
            self:MoveToPos(Vector(0, 0, 5) + self:GetPos() + Vector(math.random(-1, 1), math.random(-1, 1), 0) * self.FearRadius)
        else
            --self.IsRunning = false
            self:StartActivity(ACT_IDLE)
        end
        coroutine.yield()
    end
end

