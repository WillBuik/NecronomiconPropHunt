AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "REVOLVER"
   SWEP.Slot               = 1

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.IconLetter         = "u"
end

SWEP.Base                  = "weapon_hunter_gun_base"

SWEP.Primary.Recoil        = 0.9
SWEP.Primary.Damage        = 50
SWEP.Primary.Delay         = 0.85
SWEP.Primary.Cone          = 0.01
SWEP.Primary.ClipSize      = 6
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 6
SWEP.Primary.Ammo          = "357"
SWEP.Primary.Sound         = Sound( "Weapon_357.Single" )


SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_357.mdl"
SWEP.WorldModel            = "models/weapons/w_357.mdl"

SWEP.WeaponIconKey = "e" -- Revolver