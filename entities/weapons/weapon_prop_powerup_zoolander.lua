AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Zoolander"
SWEP.PrintName = "Zoolander"

SWEP.AbilityRange = 400
SWEP.AbilityShowTargetHalos = true
SWEP.AbilityDuration = 11
SWEP.AbilityDescription = "Make all hunters within a range of $AbilityRange unable to turn left for $AbilityDuration seconds"

function SWEP:Ability()
    if CLIENT then return end
    local targets = self:GetHuntersInRange(self.AbilityRange, true)
    -- dont use ability if no target was found
    if #targets == 0 then
        return OBJ_ABILTY_CAST_ERROR_NO_TARGET
    end

    for _, ply in pairs(targets) do
        ply:SetZoolander(true)
        timer.Simple(self.AbilityDuration, function() ply:SetZoolander(false) end)
    end
end

if CLIENT then

    -- Altering how "looking around" works was quite difficult to figure out.
    -- Hooks like GM:StartCommand don't seem able to affect mouse movement and
    -- player view angle.
    --
    -- Here's our best guess about how looking around works in GMod:
    --
    --  1. Player moves mouse
    --  2. InputMouseApply hook called
    --     - If hook returns false --> default implementation adjusts view
    --       angle by pitch += y*0.022, yaw -= x*0.022.  See
    --       https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/client/in_mouse.cpp#L484
    --     - If hook returns true --> engine does nothing (hook is entirely
    --       responsible for angle adjustment).  Thus, we have to re-implement
    --       the default behavior and tweak it to suit our needs.  We would
    --       much prefer a hook that runs AFTER the default implementation and
    --       lets us modify what the default implementation did---but we don't
    --       have such a hook.
    --  3. View angles updated client-side
    --     - This happens before CreateMove/StartCommand/etc.  Makes sense I
    --       guess (no need to pester the server with frequent mouse move
    --       events), but GMod docs don't say anything about it. :(
    --  4. CreateMove hook called
    --  5. StartCommand hook called (possibly many times)
    --  6. SetupMove hook called (possibly many times)
    --  7. Move hook called
    --  8. FinishMove hook called

    hook.Add("InputMouseApply", "ZoolanderHook", function( cmd, x, y, angle)
        if !LocalPlayer():IsZoolander() then return end

        angle.pitch = math.Clamp( angle.pitch + y * 0.022, -89, 89 )
        angle.yaw =  angle.yaw + math.max(x, 0) * 0.022
        angle:Normalize()
        cmd:SetViewAngles(angle)
        return true
    end )

    local function PaintZoolanderOverlay()
        if SERVER or !LocalPlayer():IsZoolander() then return end

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial(ZoolanderMaterial)
        surface.DrawTexturedRect(0, (ScrH() - 384) / 2, 384, 512)
    end

    hook.Add("HUDPaint", "Zoolander Overlay", PaintZoolanderOverlay)
    ZoolanderMaterial = Material("zoolander.png")
end

if SERVER then
    resource.AddFile("materials/zoolander.png")
end