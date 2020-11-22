AddCSLuaFile()

SWEP.Base = "weapon_obj_base"
SWEP.Name = "Popup"
SWEP.PrintName = "Popup"

SWEP.AbilityRange = 400
SWEP.AbilityShowTargetHalos = true
SWEP.AbilityPopupNumber = 3
SWEP.AbilityDescription = "\"A solar flare is a sudden flash of increased brightness on the Sun, usually observed near its surface.\"\n\nIn this instance you are the sun!\nSeekers within a range of $AbilityRange units will be blinded for $AbilityDuration seconds."

function SWEP:Ability()
    local targets = self:GetHuntersInRange(self.AbilityRange, true)
    -- dont use ability if no target was found
    if #targets == 0 then
        return OBJ_ABILTY_CAST_ERROR_NO_TARGET
    end

    if not SERVER then return end

    local ply = self:GetOwner()

    for _,v in pairs(targets) do
        local distanceRatio = v:GetPos():Distance(ply:GetPos()) / self.AbilityRange
        timer.Simple(distanceRatio * self.AbilityCastTime, function()
            if IsValid(v) then
                v:EmitSound("weapons/error.wav")
                net.Start("clientpopupopen")
                net.Send(v)
            end
        end)
    end
end

if CLIENT then
    net.Receive("clientpopupopen", function(len , ply)
        for _ = 1,self.AbilityPopupNumber do
            local popupnumber = math.random (1,10)

            if popupnumber == 1 then
                local popup1 = vgui.Create("DFrame")
                local pos1 = math.random(1,ScrW()-440)
                local pos2 = math.random(1,ScrH()-414)
                popup1:SetPos(pos1,pos2)
                popup1:SetSize(440,414)
                popup1:ShowCloseButton(false)
                popup1:MakePopup()

                local norton = vgui.Create("DImage", popup1)
                norton:SetImage("materials/vgui/prophunt/popups/norton.png")
                norton:SetPos(0,0)
                norton:SetSize(440,414)
                local closebutton1 = vgui.Create("DButton" , popup1)
                closebutton1:SetSize(150,50)
                closebutton1:SetPos(280,350)
                closebutton1:SetText("Remind me Later, Close popup")
                closebutton1.Paint = function(s , w , h )
                draw.RoundedBox(5,0,0, w, h, Color(254,191,63))
                end
                closebutton1.DoClick = function()
                  popup1:Close()

                end
            elseif popupnumber == 2 then
                local popup2 = vgui.Create("DFrame")
                local pos3 = math.random(1,ScrW()-750)
                local pos4 = math.random(1,ScrH()-795)
                popup2:SetPos(pos3,pos4)
                popup2:SetSize(750,795)
                popup2:ShowCloseButton(false)
                popup2:MakePopup()

                local areyouretarded = vgui.Create("DImage", popup2)
                areyouretarded:SetImage("materials/vgui/prophunt/popups/adareyouretarded.png")
                areyouretarded:SetPos(0,0)
                areyouretarded:SetSize(750,795)
                local closebutton = vgui.Create("DButton" , popup2)
                closebutton:SetSize(150,100)
                closebutton:SetPos(300,200)
                closebutton:SetText("Yes, Now close this ad")
                closebutton.DoClick = function()
                    popup2:Close()
                end
            elseif popupnumber == 3 then
                local popup3 = vgui.Create("DFrame")
                local pos5 = math.random(1,ScrW()-790)
                local pos6 = math.random(1,ScrH()-353)
                popup3:SetPos(pos5,pos6)
                popup3:SetSize(790,353)
                popup3:ShowCloseButton(false)
                popup3:MakePopup()

                local iphonepopup = vgui.Create("DImage", popup3)
                iphonepopup:SetImage("materials/vgui/prophunt/popups/iphonescampopup.png")
                iphonepopup:SetPos(0,0)
                iphonepopup:SetSize(790,353)

                local closebutton3 = vgui.Create("DButton" , popup3)
                closebutton3:SetSize(200,70)
                closebutton3:SetPos(490,250)
                closebutton3:SetText("Claim IPhone and close the ad")
                closebutton3.Paint = function()
                    draw.RoundedBox(5,0,0,240,150,Color(4,0,100))
                end
                closebutton3.DoClick = function()
                    popup3:Close()
                end
            elseif popupnumber == 4 then
                local popup4 = vgui.Create("DFrame")
                local pos7 = math.random(1,ScrW()-550)
                local pos8 = math.random(1,ScrH()-346)
                popup4:SetPos(pos7,pos8)
                popup4:SetSize(550,346)
                popup4:ShowCloseButton(false)
                popup4:MakePopup()

                local infected = vgui.Create("DImage", popup4)
                infected:SetImage("materials/vgui/prophunt/popups/infected.png")
                infected:SetPos(0,0)
                infected:SetSize(550,346)

                local closebutton4 = vgui.Create("DButton" , popup4)
                closebutton4:SetSize(170,70)
                closebutton4:SetPos(190,240)
                closebutton4:SetText("Get rid of the virus, Close popup")
                closebutton4.Paint = function(s , w , h )
                    draw.RoundedBox(5,0,0, w, h, Color(80,0,0))
                end
                closebutton4.DoClick = function()
                    popup4:Close()
                end
            elseif popupnumber == 5 then
                local popup5 = vgui.Create("DFrame")
                local pos9 = math.random(1,ScrW()-320)
                local pos10 = math.random(1,ScrH()-220)
                popup5:SetPos(pos9,pos10)
                popup5:SetSize(320,220)
                popup5:ShowCloseButton(false)
                popup5:MakePopup()

                local single = vgui.Create("DImage", popup5)
                single:SetImage("materials/vgui/prophunt/popups/single.png")
                single:SetPos(0,0)
                single:SetSize(320,220)
                local closebutton5 = vgui.Create("DButton" , popup5)
                closebutton5:SetSize(285,22)
                closebutton5:SetPos(15,180)
                closebutton5:SetText("Meet local singles, Close popup")
                closebutton5.Paint = function(s , w , h )
                    draw.RoundedBox(5,0,0, w, h, Color(132,255,24))
                end
                closebutton5.DoClick = function()
                    popup5:Close()
                end
            elseif popupnumber == 6 then
                local popup6 = vgui.Create("DFrame")
                local pos11 = math.random(1,ScrW()-600)
                local pos12 = math.random(1,ScrH()-453)
                popup6:SetPos(pos11,pos12)
                popup6:SetSize(600,453)
                popup6:ShowCloseButton(false)
                popup6:MakePopup()

                local wannacry = vgui.Create("DImage", popup6)
                wannacry:SetImage("materials/vgui/prophunt/popups/wannacry.png")
                wannacry:SetPos(0,0)
                wannacry:SetSize(600,453)

                local closebutton6 = vgui.Create("DButton" , popup6)
                closebutton6:SetSize(600-181,445-350)
                closebutton6:SetPos(175,350)
                closebutton6:SetText("Give the hackers money and get your files back, close popup")
                closebutton6.Paint = function(s , w , h )
                    draw.RoundedBox(5,0,0, w, h, Color(200,200,200))
                end
                closebutton6.DoClick = function()
                    popup6:Close()
                end
            elseif popupnumber == 7 then
                local popup7 = vgui.Create("DFrame")
                local pos13 = math.random(1,ScrW()-551)
                local pos14 = math.random(1,ScrH()-344)
                popup7:SetPos(pos13,pos14)
                popup7:SetSize(551,344)
                popup7:ShowCloseButton(false)
                popup7:MakePopup()


                local stupid = vgui.Create("DImage", popup7)
                stupid:SetImage("materials/vgui/prophunt/popups/stupid.png")
                stupid:SetPos(0,0)
                stupid:SetSize(551,344)

                local closebutton7 = vgui.Create("DButton" , popup7)
                closebutton7:SetSize(536-295,335-290)
                closebutton7:SetPos(295,290)
                closebutton7:SetText("who actually cares? Close popup")
                closebutton7.Paint = function(s , w , h )
                draw.RoundedBox(5,0,0, w, h, Color(2,0,200))
                end
                closebutton7.DoClick = function()
                  popup7:Close()
                end
            elseif popupnumber == 8 then
                local popup8 = vgui.Create("DFrame")
                local pos15 = math.random(1,ScrW()-640)
                local pos16 = math.random(1,ScrH()-360)
                popup8:SetPos(pos15,pos16)
                popup8:SetSize(640,360)
                popup8:ShowCloseButton(false)
                popup8:MakePopup()


                local robuxscam = vgui.Create("DImage", popup8)
                robuxscam:SetImage("materials/vgui/prophunt/popups/robuxscam.png")
                robuxscam:SetPos(0,0)
                robuxscam:SetSize(640,360)

                local closebutton8 = vgui.Create("DButton" , popup8)
                closebutton8:SetSize(232,80)
                closebutton8:SetPos(8,270)
                closebutton8:SetText("enter credit card details. Close popup")
                closebutton8.Paint = function(s , w , h )
                draw.RoundedBox(5,0,0, w, h, Color(2,0,200))
                end
                closebutton8.DoClick = function()
                  popup8:Close()
                end
            elseif popupnumber == 9 then
                local popup9 = vgui.Create("DFrame")
                local pos17 = math.random(1,ScrW()-472)
                local pos18 = math.random(1,ScrH()-376)
                popup9:SetPos(pos17,pos18)
                popup9:SetSize(472,376)
                popup9:ShowCloseButton(false)
                popup9:MakePopup()

                local freevbucks = vgui.Create("DImage", popup9)
                freevbucks:SetImage("materials/vgui/prophunt/popups/freevbucks.png")
                freevbucks:SetPos(0,0)
                freevbucks:SetSize(472,376)

                local closebutton9 = vgui.Create("DButton" , popup9)
                closebutton9:SetSize(232,350-272)
                closebutton9:SetPos(120,294)
                closebutton9:SetText("Get free vbucks, Close Popup")
                closebutton9.Paint = function(s , w , h )
                    draw.RoundedBox(5,0,0, w, h, Color(0,180,0))
                end
                closebutton9.DoClick = function()
                    popup9:Close()
                end
            elseif popupnumber == 10 then
                local popup10 = vgui.Create("DFrame")
                local pos19 = math.random(1,ScrW()-670)
                local pos20 = math.random(1,ScrH()-356)
                popup10:SetPos(pos19,pos20)
                popup10:SetSize(670,356)
                popup10:ShowCloseButton(false)
                popup10:MakePopup()



                local discscam = vgui.Create("DImage", popup10)
                discscam:SetImage("materials/vgui/prophunt/popups/discordscam.png")
                discscam:SetPos(0,0)
                discscam:SetSize(670,356)
                local closebutton10 = vgui.Create("DButton" , popup10)
                closebutton10:SetSize(497-94,339-296)
                closebutton10:SetPos(94,296)
                closebutton10:SetText("Join server and lose your discord account, close popup")
                closebutton10.Paint = function(s , w , h )
                    draw.RoundedBox(5,0,0, w, h, Color(67,181,129))
                end
                closebutton10.DoClick = function()
                    popup10:Close()
                end
            end
        end
   end)
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

end