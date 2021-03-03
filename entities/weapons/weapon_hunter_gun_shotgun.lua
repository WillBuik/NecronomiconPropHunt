AddCSLuaFile()

DEFINE_BASECLASS "weapon_hunter_gun_base"

SWEP.HoldType              = "shotgun"

if CLIENT then
   SWEP.PrintName          = "SHOTGUN"
   SWEP.Slot               = 2

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54
end

SWEP.Base                  = "weapon_hunter_gun_base"

SWEP.Primary.Ammo          = "Buckshot"
SWEP.Primary.Damage        = 8
SWEP.Primary.Cone          = 0.085
SWEP.Primary.Delay         = 0.8
SWEP.Primary.ClipSize      = 8
SWEP.Primary.ClipMax       = 24
SWEP.Primary.DefaultClip   = 8
SWEP.Primary.Automatic     = true
SWEP.Primary.NumShots      = 7
SWEP.Primary.Sound         = Sound( "Weapon_Shotgun.Single" )
SWEP.Primary.Recoil        = 7


SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel            = "models/weapons/w_shotgun.mdl"

SWEP.WeaponIconKey = "b" -- Shotgun
SWEP.EmptySound  = "Weapon_Shotgun.Empty"

function SWEP:SetupDataTables()
   self:NetworkVar("Bool", 0, "Reloading")
   self:NetworkVar("Float", 0, "ReloadTimer")
end

function SWEP:PrimaryAttack()

   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if !self:CanPrimaryAttack() then return end

   if SERVER then
      sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
   end

   self:SendWeaponAnim(self.Primary.Anim)
   self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone() )

   self:TakePrimaryAmmo( 1 )

   local owner = self:GetOwner()
   if !IsValid(owner) or owner:IsNPC() or (!owner.ViewPunch) then return end

   owner:ViewPunch( Angle( util.SharedRandom(self:GetClass(),-0.2,-0.1,0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(),-0.1,0.1,1) * self.Primary.Recoil, 0 ) )
   
   if self:Clip1() == 0 then self:Reload() end
end

function SWEP:DryFire(setnext)
   if CLIENT and LocalPlayer() == self:GetOwner() then
      self:EmitSound(self.EmptySound)
   end

   setnext(self, CurTime() + 0.2)

   self:Reload()
end

function SWEP:CanPrimaryAttack()
   if !IsValid(self:GetOwner()) then return end

   if self:Clip1() <= 0 then
      self:DryFire(self.SetNextPrimaryFire)
      return false
   end
   return true
end

function SWEP:Reload()
   if self:GetReloading() then return end

   if self:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount( self.Primary.Ammo ) > 0 then

      if self:StartReload() then
         return
      end
   end

end

function SWEP:StartReload()
   if self:GetReloading() then
      return false
   end

   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   local ply = self:GetOwner()

   if !ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then
      return false
   end

   if self:Clip1() >= self.Primary.ClipSize then
      return false
   end

   self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
   self:EmitSound("Weapon_Shotgun.Reload")

   self:SetReloadTimer(CurTime() + self:SequenceDuration())

   self:SetReloading(true)

   return true
end

function SWEP:PerformReload()
   local ply = self:GetOwner()

   -- prevent normal shooting in between reloads
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if !ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end

   if self:Clip1() >= self.Primary.ClipSize then return end

   self:GetOwner():RemoveAmmo( 1, self.Primary.Ammo, false )
   self:SetClip1( self:Clip1() + 1 )

   self:SendWeaponAnim(ACT_VM_RELOAD)
   self:EmitSound("Weapon_Shotgun.Reload")

   self:SetReloadTimer(CurTime() + self:SequenceDuration())
end

function SWEP:FinishReload()
   self:SetReloading(false)
   self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
   self:EmitSound("Weapon_Shotgun.Special1")

   self:SetReloadTimer(CurTime() + self:SequenceDuration())
end

function SWEP:Think()
   BaseClass.Think(self)
   if self:GetReloading() then
      if self:GetOwner():KeyDown(IN_ATTACK) or self:GetOwner():KeyDown(IN_ATTACK2) then
         self:FinishReload()
         return
      end

      if self:GetReloadTimer() <= CurTime() then

         if self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then
            self:FinishReload()
         elseif self:Clip1() < self.Primary.ClipSize then
            self:PerformReload()
         else
            self:FinishReload()
         end
         return
      end
   end
end

function SWEP:Deploy()
   self:SetReloading(false)
   self:SetReloadTimer(0)
   return BaseClass.Deploy(self)
end

function SWEP:SecondaryAttack()

   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if !self:CanPrimaryAttack() then return end

   if SERVER then
      sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
   end

   local ammo = self:Clip1() 

   self:ShootBullet( self.Primary.Damage / 1.5, self.Primary.Recoil, self.Primary.NumShots * ammo, self:GetPrimaryCone() * ammo )

   self:TakePrimaryAmmo( ammo )

   local owner = self:GetOwner()
   if !IsValid(owner) or owner:IsNPC() or (!owner.ViewPunch) then return end

   owner:ViewPunch( Angle( util.SharedRandom(self:GetClass(),-0.2,-0.1,0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(),-0.1,0.1,1) * self.Primary.Recoil, 0 ) )

   print(self:Clip1())
   print(self.Reload)
   if self:Clip1() == 0 then self:Reload() end
end