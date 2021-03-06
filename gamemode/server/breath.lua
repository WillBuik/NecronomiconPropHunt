--[[==============]]--
--[[HOLDING BREATH]]--
--[[==============]]--
--
-- Prop players can hold a button to hold their breath.  This pauses the
-- autotaunt timer, but costs health while the button is held.
--
-- BASIC DESIGN (2020/12/7)
--
-- Autotuanting is based on two variables: LastTauntTime (a timestamp) and
-- NextAutoTauntDelay (a duration).  While a player holds their breath,
-- this code increases NextAutoTauntDelay to push out the scheduled autotaunt.
--
-- Breath state:
--   BreathHoldOffsetTime (per-player server-side variable)
--     - nil indicates the player is not holding their breath
--     - non-nil is the CurTime() when LastTauntTime was in-sync with breath
--   LastSuffocationTime (per-player server-side variable)
--     - if BreathHoldOffsetTime != nil, this indicates the last CurTime() when
--       the player lost health due to holding their breath
--     - otherwise, this has no particular meaning
--
-- Other important state:
--   LastTauntTime (per-player networked variable, managed server-side)
--   NextAutoTauntDelay (per-player networked variable, managed server-side)
--
-- Periodically, on the server: call doHoldBreath() for each player.  This
-- should happen at least every BREATH_PERIODIC_HEALTH_PENALTY_RATE seconds.
-- If the player is holding their breath, doHoldBreath() will:
--   - adjust NextAutoTauntDelay to delay the next autotaunt
--   - set BreathHoldOffsetTime = now
--   - deal damage based on LastSuffocationTime
--   - update LastSuffocationTime appropriately

if AUTOTAUNT_ENABLED then

    hook.Add("PlayerSpawn", "reset_breath_state", function(ply)
        ply.BreathHoldOffsetTime = nil
    end)

    hook.Add("PlayerButtonDown", "start_holding_breath", function(ply, button)
        if
            SERVER and
            button == BREATH_BUTTON and
            ply:Alive() and
            ply:Team() == TEAM_PROPS and
            ply:Health() > BREATH_INIT_HEALTH_PENALTY + BREATH_PERIODIC_HEALTH_PENALTY
        then
            local now = CurTime()
            ply.BreathHoldOffsetTime = now
            ply.LastSuffocationTime = now
            HurtPropAndCheckForDeath(ply, BREATH_INIT_HEALTH_PENALTY, ply)
        end
    end)

    hook.Add("PlayerButtonUp", "stop_holding_breath", function(ply, button)
        -- NOTE: always safe to reset, so no need to guard with ply:Alive()
        if SERVER and button == BREATH_BUTTON and ply:Team() == TEAM_PROPS then
            ply.BreathHoldOffsetTime = nil
        end
    end)

    function doHoldBreath(ply, now)

        if ply.BreathHoldOffsetTime ~= nil then
            local delta = now - ply.BreathHoldOffsetTime
            ply:SetNextAutoTauntDelay(ply:GetNextAutoTauntDelay() + delta)
            ply.BreathHoldOffsetTime = now

            local suffocationCount = math.floor((now - ply.LastSuffocationTime) / BREATH_PERIODIC_HEALTH_PENALTY_RATE)
            if suffocationCount > 0 then
                local hurt = suffocationCount * BREATH_PERIODIC_HEALTH_PENALTY
                ply.LastSuffocationTime = ply.LastSuffocationTime + (suffocationCount * BREATH_PERIODIC_HEALTH_PENALTY_RATE)
                HurtPropAndCheckForDeath(ply, hurt, ply)
            end
        end

    end

end
