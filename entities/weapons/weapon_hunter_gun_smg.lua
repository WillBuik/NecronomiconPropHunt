AddCSLuaFile()

SWEP.HoldType              = "smg"

if CLIENT then
    SWEP.PrintName          = "SMG"
    SWEP.Slot               = 2

    SWEP.ViewModelFlip      = false
    SWEP.ViewModelFOV       = 54
end

SWEP.Base                  = "weapon_hunter_gun_base"

SWEP.Primary.Recoil        = 1.15
SWEP.Primary.Damage        = 4
SWEP.Primary.Delay         = 0.065
SWEP.Primary.Cone          = 0.03
SWEP.Primary.ClipSize      = 45
SWEP.Primary.Automatic     = true

SWEP.Primary.DefaultClip   = 45
SWEP.Primary.Ammo          = "smg1"
SWEP.Secondary.Ammo        = "SMG1_Grenade"
SWEP.Primary.Sound         = Sound("Weapon_SMG1.Single")
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_smg1.mdl"
SWEP.WorldModel            = "models/weapons/w_smg1.mdl"

SWEP.WeaponIconKey = "a" -- SMG
SWEP.ReloadSound  = "Weapon_SMG1.Reload"
SWEP.EmptySound  = "Weapon_SMG1.Empty"

function SWEP:SecondaryAttack()
    if self:GetOwner():GetAmmoCount("SMG1_Grenade") <= 0 or CLIENT then return end
    local ang = self:GetOwner():EyeAngles()
    local ent = ents.Create( "grenade_ar2" )
    self:GetOwner():RemoveAmmo( 1, "SMG1_Grenade" )
    if ( IsValid( ent ) ) then
        ent:SetPos( self:GetOwner():GetShootPos() + ang:Forward() + ang:Right() * 4 - ang:Up())
        ent:SetVelocity(self:GetOwner():GetAimVector() * 1000)
        ent:SetAngles( ang )
        ent:SetOwner( self:GetOwner() )
        ent:Spawn()
        ent:Activate()
    end
    self:EmitSound("Weapon_SMG1.Double")
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
end