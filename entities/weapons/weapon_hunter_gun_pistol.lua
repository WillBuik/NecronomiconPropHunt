AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "PISTOL"
   SWEP.Slot               = 1

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54
end

SWEP.Base                  = "weapon_hunter_gun_base"

SWEP.Primary.Recoil        = 1.5
SWEP.Primary.Damage        = 5
SWEP.Primary.Delay         = 0.3
SWEP.Primary.Cone          = 0.02
SWEP.Primary.ClipSize      = 18
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 18
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.Sound         = Sound( "Weapon_Pistol.Single" )

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_Pistol.mdl"
SWEP.WorldModel            = "models/weapons/w_Pistol.mdl"

SWEP.WeaponIconKey = "d" -- Pistol
SWEP.Reload.Sound  = Sound( "Weapon_Pistol.Reload" )