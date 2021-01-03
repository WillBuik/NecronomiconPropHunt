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
SWEP.Primary.DefaultClip   = 45
SWEP.Primary.Ammo			= "smg1"
SWEP.Secondary.Ammo			= "SMG1_Grenade"
SWEP.Primary.Sound			= Sound("Weapon_SMG1.Single")
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_smg1.mdl"
SWEP.WorldModel            = "models/weapons/v_smg1.mdl"

local reloadfix = 0
local canglf = 1
local clik = 1
local up = 0
local firclik = 1
local wai = 0


//Now for yet another God Damn workaround
function SWEP:Think()
   if ( self:GetClass() == "hl2smg" && Entity( 1 ):KeyDown( IN_USE ) && not (Entity( 1 ):KeyDown( IN_SPEED ))) then
      if (up == 0 && canglf == 1) then
            self:EmitSound("Weapon_smg_gl1")
				up = 1
			end
			self:SetNextPrimaryFire(CurTime() + 0.1)
			if (( Entity( 1 ):GetAmmoCount( 9 ) ) > 0) then
				if (Entity( 1 ):KeyDown( IN_ATTACK )) then
					if (canglf == 1 && SERVER) then
						local ang = self:GetOwner():EyeAngles()
						local ent = ents.Create( "grenade_ar2" )
						self:TakeSecondaryAmmo(1)
						if ( IsValid( ent ) ) then
                     ent:SetPos( self:GetOwner():GetShootPos() + ang:Forward() + ang:Right() * 4 - ang:Up())
                     ent:SetVelocity(self:GetOwner():GetAimVector() * 1000)
						ent:SetAngles( ang )
						ent:SetOwner( self.GetOwner() )
						ent:Spawn()
						ent:Activate()
					end
					reloadfix = 1
				end
				self:EmitSound("Weapon_SMG1.Double")
				self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
				canglf = 0
				timer.Simple(1, function() canglf = 1 end)
			end
		else
			if (Entity( 1 ):KeyDown( IN_ATTACK )) then
				if (clik == 1) then
					self:EmitSound("Weapon_smg_d")
					clik = 0
				end
			else 
				clik = 1
			end
		end
		self.VMPos = Vector( -1.3768, -3.1543, -1.9429 )
		self.VMAng = Vector( 4.998, 0.0623, -12.091 )
		if (self:Clip1() == 0) then
			if (firclik == 1 && Entity( 1 ):KeyDown( IN_ATTACK )) then
				firclik = 0
				self:EmitSound("Weapon_SMG1.Empty")
			end
			self:SetNextPrimaryFire(CurTime() + 0.3)
		end
		if (( self:Clip1()) > 0) then
			firclik = 1
		end
		self.VMPos = Vector(0,0,0)
		self.VMAng = Vector(0,0,0)
		self.data.ironsights_default = 1
		clik = 1
		if (up == 1) then
			self:EmitSound("Weapon_smg_gld")
		end
		up = 0
	end
	self:Think2()
	self:CalculateRatios(CLIENT)
end


