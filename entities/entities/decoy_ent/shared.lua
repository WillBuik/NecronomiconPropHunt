AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

function ENT:Initialize()
    self:SetModel( "models/seagull.mdl" )
    self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    self.IsRunning = true
    self.FearRadius = 1000
end

function ENT:PlayerNear()
    for k, v in pairs(ents.FindInSphere(self:GetPos(), self.FearRadius)) do
        if (v:IsPlayer() and v:IsLineOfSightClear(self:GetPos())) then
            return true
        end
    end

    return false
end

function ENT:RunBehavior()
    while (true) do
        if (self.IsRunning and self:PlayerNear()) then
            self.loco:SetDesiredSpeed(300)
            self:StartActivity(ACT_RUN)
            self:MoveToPos(self:GetPos() + Vector(math.random(-1, 1), math.random(-1, 1), 0) * self.FearRadius)
        else
            self.IsRunning = false
            self:StartActivity(ACT_IDLE)
        end
        coroutine.wait(1)
    end
end

