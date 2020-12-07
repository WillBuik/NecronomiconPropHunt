-- Custom weapon base, used to derive from CS one, still very similar

AddCSLuaFile()

---- TTT SPECIAL EQUIPMENT FIELDS

-- This must be set to one of the WEAPON_ types in TTT weapons for weapon
-- carrying limits to work properly. See /gamemode/shared.lua for all possible
-- weapon categories.
SWEP.Kind = WEAPON_NONE

-- If this weapon should be given to players upon spawning, set a table of the
-- roles this should happen for here
--  SWEP.InLoadoutFor = { ROLE_TRAITOR, ROLE_DETECTIVE, ROLE_INNOCENT }

-- DO NOT set SWEP.WeaponID. Only the standard TTT weapons can have it. Custom
-- SWEPs do not need it for anything.
--  SWEP.WeaponID = nil

---- YE OLDE SWEP STUFF

if CLIENT then
   SWEP.DrawCrosshair   = false
   SWEP.ViewModelFOV    = 82
   SWEP.ViewModelFlip   = true
   SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_base"

SWEP.Category           = "TTT"
SWEP.Spawnable          = false

SWEP.IsGrenade = false

SWEP.Weight             = 5
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false

SWEP.Primary.Sound          = Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Recoil         = 1.5
SWEP.Primary.Damage         = 1
SWEP.Primary.NumShots       = 1
SWEP.Primary.Cone           = 0.02
SWEP.Primary.Delay          = 0.15

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"
SWEP.Primary.ClipMax        = -1

SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipMax      = -1

SWEP.HeadshotMultiplier = 2.7

SWEP.StoredAmmo = 0
SWEP.IsDropped = false

SWEP.DeploySpeed = 1.4

SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD

SWEP.fingerprints = {}

local sparkle = CLIENT and CreateConVar("ttt_crazy_sparks", "0", FCVAR_ARCHIVE)

-- crosshair
if CLIENT then
   local sights_opacity = CreateConVar("ttt_ironsights_crosshair_opacity", "0.8", FCVAR_ARCHIVE)
   local crosshair_brightness = CreateConVar("ttt_crosshair_brightness", "1.0", FCVAR_ARCHIVE)
   local crosshair_size = CreateConVar("ttt_crosshair_size", "1.0", FCVAR_ARCHIVE)
   local disable_crosshair = CreateConVar("ttt_disable_crosshair", "0", FCVAR_ARCHIVE)

   function SWEP:DrawHUD()
      if self.HUDHelp then
         self:DrawHelp()
      end

      local client = LocalPlayer()
      if disable_crosshair:GetBool() or (not IsValid(client)) then return end

      local sights = (not self.NoSights) and self:GetIronsights()

      local x = math.floor(ScrW() / 2.0)
      local y = math.floor(ScrH() / 2.0)
      local scale = math.max(0.2,  10 * self:GetPrimaryCone())

      local LastShootTime = self:LastShootTime()
      scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))

      local alpha = sights and sights_opacity:GetFloat() or 1
      local bright = crosshair_brightness:GetFloat() or 1

      -- somehow it seems this can be called before my player metatable
      -- additions have loaded
      if client.IsTraitor and client:IsTraitor() then
         surface.SetDrawColor(255 * bright,
                              50 * bright,
                              50 * bright,
                              255 * alpha)
      else
         surface.SetDrawColor(0,
                              255 * bright,
                              0,
                              255 * alpha)
      end

      local gap = math.floor(20 * scale * (sights and 0.8 or 1))
      local length = math.floor(gap + (25 * crosshair_size:GetFloat()) * scale)
      surface.DrawLine( x - length, y, x - gap, y )
      surface.DrawLine( x + length, y, x + gap, y )
      surface.DrawLine( x, y - length, x, y - gap )
      surface.DrawLine( x, y + length, x, y + gap )
   end

   local GetPTranslation = LANG.GetParamTranslation

   -- Many non-gun weapons benefit from some help
   local help_spec = {text = "", font = "TabLarge", xalign = TEXT_ALIGN_CENTER}
   function SWEP:DrawHelp()
      local data = self.HUDHelp

      local translate = data.translatable
      local primary   = data.primary
      local secondary = data.secondary

      if translate then
         primary   = primary   and GetPTranslation(primary,   data.translate_params)
         secondary = secondary and GetPTranslation(secondary, data.translate_params)
      end

      help_spec.pos  = {ScrW() / 2.0, ScrH() - 40}
      help_spec.text = secondary or primary
      draw.TextShadow(help_spec, 2)

      -- if no secondary exists, primary is drawn at the bottom and no top line
      -- is drawn
      if secondary then
         help_spec.pos[2] = ScrH() - 60
         help_spec.text = primary
         draw.TextShadow(help_spec, 2)
      end
   end

   -- mousebuttons are enough for most weapons
   local default_key_params = {
      primaryfire   = Key("+attack",  "LEFT MOUSE"),
      secondaryfire = Key("+attack2", "RIGHT MOUSE"),
      usekey        = Key("+use",     "USE")
   };

   function SWEP:AddHUDHelp(primary_text, secondary_text, translate, extra_params)
      extra_params = extra_params or {}

      self.HUDHelp = {
         primary = primary_text,
         secondary = secondary_text,
         translatable = translate,
         translate_params = table.Merge(extra_params, default_key_params)
      };
   end
end

-- Shooting functions largely copied from weapon_cs_base
function SWEP:PrimaryAttack(worldsnd)

   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not self:CanPrimaryAttack() then return end

   if not worldsnd then
      self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
   elseif SERVER then
      sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
   end

   self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone() )

   self:TakePrimaryAmmo( 1 )

   local owner = self:GetOwner()
   if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end

   owner:ViewPunch( Angle( util.SharedRandom(self:GetClass(),-0.2,-0.1,0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(),-0.1,0.1,1) * self.Primary.Recoil, 0 ) )
end

function SWEP:DryFire(setnext)
   if CLIENT and LocalPlayer() == self:GetOwner() then
      self:EmitSound( "Weapon_Pistol.Empty" )
   end

   setnext(self, CurTime() + 0.2)

   self:Reload()
end

function SWEP:CanPrimaryAttack()
   if not IsValid(self:GetOwner()) then return end

   if self:Clip1() <= 0 then
      self:DryFire(self.SetNextPrimaryFire)
      return false
   end
   return true
end

function SWEP:CanSecondaryAttack()
   if not IsValid(self:GetOwner()) then return end

   if self:Clip2() <= 0 then
      self:DryFire(self.SetNextSecondaryFire)
      return false
   end
   return true
end

local function Sparklies(attacker, tr, dmginfo)
   if tr.HitWorld and tr.MatType == MAT_METAL then
      local eff = EffectData()
      eff:SetOrigin(tr.HitPos)
      eff:SetNormal(tr.HitNormal)
      util.Effect("cball_bounce", eff)
   end
end

function SWEP:ShootBullet( dmg, recoil, numbul, cone )

   self:SendWeaponAnim(self.PrimaryAnim)

   self:GetOwner():MuzzleFlash()
   self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

   local sights = self:GetIronsights()

   numbul = numbul or 1
   cone   = cone   or 0.01

   local bullet = {}
   bullet.Num    = numbul
   bullet.Src    = self:GetOwner():GetShootPos()
   bullet.Dir    = self:GetOwner():GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = 4
   bullet.TracerName = self.Tracer or "Tracer"
   bullet.Force  = 10
   bullet.Damage = dmg
   if CLIENT and sparkle:GetBool() then
      bullet.Callback = Sparklies
   end

   self:GetOwner():FireBullets( bullet )

   -- Owner can die after firebullets
   if (not IsValid(self:GetOwner())) or (not self:GetOwner():Alive()) or self:GetOwner():IsNPC() then return end

   if ((game.SinglePlayer() and SERVER) or
       ((not game.SinglePlayer()) and CLIENT and IsFirstTimePredicted())) then

      local eyeang = self:GetOwner():EyeAngles()
      eyeang.pitch = eyeang.pitch - recoil
      self:GetOwner():SetEyeAngles( eyeang )
   end
end

function SWEP:GetPrimaryCone()
   return self.Primary.Cone or 0.2
end

function SWEP:DrawWeaponSelection() end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
   self:SetIronsights(false)
   return true
end

function SWEP:Reload()
   if ( self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
   self:DefaultReload(self.ReloadAnim)
   self:SetIronsights( false )
end


function SWEP:OnRestore()
   self.NextSecondaryAttack = 0
   self:SetIronsights( false )
end

function SWEP:Ammo1()
   return IsValid(self:GetOwner()) and self:GetOwner():GetAmmoCount(self.Primary.Ammo) or false
end

local SF_WEAPON_START_CONSTRAINED = 1

function SWEP:Initialize()
   if CLIENT and self:Clip1() == -1 then
      self:SetClip1(self.Primary.DefaultClip)
   elseif SERVER then
      self.fingerprints = {}

   end

   self:SetDeploySpeed(self.DeploySpeed)

   -- compat for gmod update
   if self.SetHoldType then
      self:SetHoldType(self.HoldType or "pistol")
   end
end

function SWEP:CalcViewModel()
   if (not CLIENT) or (not IsFirstTimePredicted()) then return end
   self.fCurrentTime = CurTime()
   self.fCurrentSysTime = SysTime()
end

-- Note that if you override Think in your SWEP, you should call
-- BaseClass.Think(self) so as not to break ironsights
function SWEP:Think()
   self:CalcViewModel()
end

local host_timescale = GetConVar("host_timescale")

function SWEP:GetViewModelPosition( pos, ang )
   if (not self.IronSightsPos) or (self.bIron == nil) then return pos, ang end

   local bIron = self.bIron
   local time = self.fCurrentTime + (SysTime() - self.fCurrentSysTime) * game.GetTimeScale() * host_timescale:GetFloat()

   if bIron then
      self.SwayScale = 0.3
      self.BobScale = 0.1
   else
      self.SwayScale = 1.0
      self.BobScale = 1.0
   end

   local fIronTime = self.fIronTime
   if (not bIron) and fIronTime < time - IRONSIGHT_TIME then
      return pos, ang
   end

   local mul = 1.0

   if fIronTime > time - IRONSIGHT_TIME then
      mul = math.Clamp( (time - fIronTime) / IRONSIGHT_TIME, 0, 1 )

      if not bIron then mul = 1 - mul end
   end

   local offset = self.IronSightsPos + (ttt_lowered:GetBool() and LOWER_POS or vector_origin)

   if self.IronSightsAng then
      ang = ang * 1
      ang:RotateAroundAxis( ang:Right(),    self.IronSightsAng.x * mul )
      ang:RotateAroundAxis( ang:Up(),       self.IronSightsAng.y * mul )
      ang:RotateAroundAxis( ang:Forward(),  self.IronSightsAng.z * mul )
   end

   pos = pos + offset.x * ang:Right() * mul
   pos = pos + offset.y * ang:Forward() * mul
   pos = pos + offset.z * ang:Up() * mul

   return pos, ang
end