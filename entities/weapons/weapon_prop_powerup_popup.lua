AddCSLuaFile()

SWEP.Base = "weapon_prop_powerup_base"
SWEP.Name = "Popup"
SWEP.PrintName = "Popup"

SWEP.AbilityRange = 400
SWEP.AbilityShowTargetHalos = true
SWEP.AbilityPopupNumber = 3
SWEP.AbilityDescription = "Make $AbilityPopupNumber Popup Ads appear on the screens of Hunters within a range of $AbilityRange."

-- BSOD Parameters
SWEP.BSODChance    = 4  -- 1 in 4 odds of causing a BSOD

local BSODTime     = 3.0
local BIOSBootTime = 2.5
local MEBootTime   = 4.5

local BSODTimeStarted = 0
local BSODMaterial = nil
local MEBootMaterial = nil
local BIOSBootMaterial = nil


function SWEP:Ability()
    if CLIENT then return end
    local targets = self:GetHuntersInRange(self.AbilityRange, true)
    -- dont use ability if no target was found
    if #targets == 0 then
        return OBJ_ABILTY_CAST_ERROR_NO_TARGET
    end

    local BSOD = math.random(self.BSODChance) == self.BSODChance

    for _,v in pairs(targets) do
        if (BSOD == false) then
            v:EmitSound("weapons/error.wav")
            net.Start("Popup Open")
            net.WriteUInt(self.AbilityPopupNumber, 8)
            net.Send(v)
        else
            v:EmitSound("weapons/error_3_1.wav")
            net.Start("BSOD Open")
            net.Send(v)
        end
    end
end

function SWEP:AbilityCleanup()
    -- Make sure we are no longer showing the BSOD overlay
    BSODTimeStarted = 0
end

function BuildPopup(popupX, popupY, popupImage, closeSizeX, closeSizeY, closePosX, closePosY, closeText, closeColor)
    local popup = vgui.Create("DFrame")
    local pos1 = math.random(1, ScrW() - popupX)
    local pos2 = math.random(1, ScrH() - popupY)
    popup:SetPos(pos1, pos2)
    popup:SetSize(popupX, popupY)
    popup:ShowCloseButton(false)
    popup:MakePopup()

    local image = vgui.Create("DImage", popup)
    image:SetImage(popupImage)
    image:SetPos(0,0)
    image:SetSize(popupX, popupY)

    local closebutton = vgui.Create("DButton" , popup)
    closebutton:SetSize(closeSizeX, closeSizeY)
    closebutton:SetPos(closePosX, closePosY)
    closebutton:SetText(closeText)
    closebutton.Paint = function(s , w , h)
        draw.RoundedBox(5,0,0, w, h, closeColor)
    end
    closebutton.DoClick = function()
        popup:Close()
    end
end

if CLIENT then
    net.Receive("Popup Open", function(len , ply)
        local numPopups = net.ReadUInt(8)
        for _ = 1,numPopups do
            local popupnumber = math.random (1,10)

            if popupnumber == 1 then
                BuildPopup(
                        440,
                        414,
                        "materials/vgui/prophunt/popups/norton.png",
                        150,
                        50,
                        280,
                        350,
                        "Remind me Later. Close popup",
                        Color(254,191,63)
                )
            elseif popupnumber == 2 then
                BuildPopup(
                        750,
                        750,
                        "materials/vgui/prophunt/popups/adareyouretarded.png",
                        150,
                        100,
                        300,
                        200,
                        "Yes, Now close this ad",
                        Color(254,191,63) -- No color originally
                )
            elseif popupnumber == 3 then
                BuildPopup(
                        790,
                        353,
                        "materials/vgui/prophunt/popups/iphonescampopup.png",
                        200,
                        70,
                        490,
                        250,
                        "Claim IPhone and close the ad",
                        Color(4,0,100) -- draw.RoundedBox(5,0,0,240,150,Color(4,0,100)) Instead of standard w and h
                )
            elseif popupnumber == 4 then
                BuildPopup(
                        550,
                        346,
                        "materials/vgui/prophunt/popups/infected.png",
                        170,
                        70,
                        190,
                        240,
                        "Get rid of the virus. Close popup",
                        Color(80,0,0)
                )
            elseif popupnumber == 5 then
                BuildPopup(
                        320,
                        220,
                        "materials/vgui/prophunt/popups/single.png",
                        285,
                        22,
                        15,
                        180,
                        "Meet local singles. Close popup",
                        Color(132,255,24)
                )
            elseif popupnumber == 6 then
                BuildPopup(
                        600,
                        453,
                        "materials/vgui/prophunt/popups/wannacry.png",
                        600-181,
                        445-350,
                        175,
                        350,
                        "Give the hackers money and get your files back, close popup",
                        Color(200,200,200)
                )
            elseif popupnumber == 7 then
                BuildPopup(
                        551,
                        344,
                        "materials/vgui/prophunt/popups/stupid.png",
                        536-295,
                        335-290,
                        295,
                        290,
                        "Who actually cares? Close popup",
                        Color(2,0,200)
                )
            elseif popupnumber == 8 then
                BuildPopup(
                        640,
                        360,
                        "materials/vgui/prophunt/popups/robuxscam.png",
                        232,
                        80,
                        8,
                        270,
                        "Enter credit card details. Close popup",
                        Color(2,0,200)
                )
            elseif popupnumber == 9 then
                BuildPopup(
                        472,
                        376,
                        "materials/vgui/prophunt/popups/freevbucks.png",
                        232,
                        350-272,
                        120,
                        294,
                        "Get free vbucks. Close Popup",
                        Color(0,180,0)
                )
            elseif popupnumber == 10 then
                BuildPopup(
                        670,
                        356,
                        "materials/vgui/prophunt/popups/discordscam.png",
                        497-94,
                        339-296,
                        94,
                        296,
                        "Join server and lose your discord account. Close popup",
                        Color(67,181,129)
                )
            end
        end
    end)

    net.Receive("BSOD Open", function(len , ply)
        BSODTimeStarted = CurTime()
    end)

    local function PaintBSODOverlay()
        if (BSODTimeStarted <= 0) then return end

        if (BSODTimeStarted + BSODTime >= CurTime()) then
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(BSODMaterial)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        elseif (BSODTimeStarted + BSODTime + BIOSBootTime >= CurTime()) then
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(BIOSBootMaterial)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        elseif (BSODTimeStarted + BSODTime + BIOSBootTime + MEBootTime >= CurTime()) then
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(MEBootMaterial)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        else
            LocalPlayer():EmitSound("weapons/me_startup.wav")
            BSODTimeStarted = 0
        end
    end
    
    hook.Add("DrawOverlay", "BSOD Overlay", PaintBSODOverlay)

    BSODMaterial = Material("windows_9x_bsod.png")
    MEBootMaterial = Material("windows_me_boot.png")
    BIOSBootMaterial = Material("bios_boot_screen.png")
end

if SERVER then
    resource.AddFile("sound/weapons/error.wav")
    resource.AddFile("materials/vgui/prophunt/popupgunicon.vmt")
    resource.AddFile("materials/vgui/prophunt/popups/adareyouretarded.png")
    resource.AddFile("materials/vgui/prophunt/popups/single.png")
    resource.AddFile("materials/vgui/prophunt/popups/infected.png")
    resource.AddFile("materials/vgui/prophunt/popups/iphonescampopup.png")
    resource.AddFile("materials/vgui/prophunt/popups/freevbucks.png")
    resource.AddFile("materials/vgui/prophunt/popups/norton.png")
    resource.AddFile("materials/vgui/prophunt/popups/robuxscam.png")
    resource.AddFile("materials/vgui/prophunt/popups/stupid.png")
    resource.AddFile("materials/vgui/prophunt/popups/wannacry.png")
    resource.AddFile("materials/vgui/prophunt/popups/discordscam.png")

    resource.AddFile("materials/windows_9x_bsod.png")
    resource.AddFile("materials/windows_me_boot.png")
    resource.AddFile("materials/bios_boot_screen.png")
    resource.AddFile("sound/weapons/error_3_1.wav")
    resource.AddFile("sound/weapons/me_startup.wav")

    -- Debug commands

    concommand.Add("testbsod", function(ply, cmd, args, str)
        if (!ply) then return end
        ply:EmitSound("weapons/error_3_1.wav")
        net.Start("BSOD Open")
        net.Send(ply)
    end)

    concommand.Add("testpopup", function(ply, cmd, args, str)
        if (!ply) then return end
        ply:EmitSound("weapons/error.wav")
        net.Start("Popup Open")
        net.WriteUInt(3, 8)
        net.Send(ply)
    end)
end
