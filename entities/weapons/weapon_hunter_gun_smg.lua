AddCSLuaFile()

SWEP.HoldType              = "smg"

if CLIENT then
    SWEP.PrintName          = "SMG"
    SWEP.Slot               = 3

    SWEP.ViewModelFlip      = false
    SWEP.ViewModelFOV       = 54

    SWEP.IconLetter         = "n"
end

SWEP.Base                  = "weapon_hunter_gun_base"

SWEP.Primary.Recoil        = 0.3
SWEP.Primary.Damage        = 4
SWEP.Primary.Delay         = 0.07
SWEP.Primary.Cone          = 0.02
SWEP.Primary.ClipSize      = 45
SWEP.Primary.Automatic     = true

SWEP.Secondary.ClipSize     = 5
SWEP.Secondary.DefaultClip  = 0

SWEP.Primary.DefaultClip   = 45
SWEP.Primary.Ammo          = "smg1"
SWEP.Secondary.Ammo        = "SMG1_Grenade"
SWEP.Primary.Sound         = Sound("Weapon_SMG1.Single")
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_smg1.mdl"
SWEP.WorldModel            = "models/weapons/w_smg1.mdl"

function SWEP:SecondaryAttack()
    if !self:CanSecondaryAttack() or CLIENT then return end
    local ang = self:GetOwner():EyeAngles()
    local ent = ents.Create( "grenade_ar2" )
    self:TakeSecondaryAmmo(1)
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