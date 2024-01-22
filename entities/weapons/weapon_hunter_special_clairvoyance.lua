AddCSLuaFile()

SWEP.Base                   = "weapon_hunter_gun_base"

if CLIENT then
    SWEP.PrintName          = "CLARIVOYANCE"
    SWEP.Slot               = 3

    SWEP.ViewModelFlip      = false
    SWEP.ViewModelFOV       = 54
end

SWEP.HoldType              = "magic"
SWEP.WeaponIconKey         = "*" -- Electrical symbol
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel            = "models/weapons/w_eq_defuser.mdl" -- Invisible, just shows magic stance

SWEP.Primary.Recoil        = 6
SWEP.Primary.Delay         = 1.5
SWEP.Primary.ClipSize      = 1
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.Ammo          = "AR2AltFire"
SWEP.Primary.Sound         = Sound("player/geiger3.wav")
SWEP.Primary.AutoReload    = true
--SWEP.Primary.Anim          = ACT_VM_SECONDARYATTACK
SWEP.Primary.Accuracy      = 110

SWEP.ReloadSound           = ""
SWEP.EmptySound            = ""

function SWEP:SpawnGhost(model, scale, rotation)
    if SERVER then return end

    -- Spawn ghost clientside
    local ghost = ents.CreateClientProp()
    local forward = self:GetOwner():EyeAngles():Forward()
    ghost:SetPos(self:GetOwner():GetShootPos() + forward * 50 - Vector(0, 0, 10))
    ghost:SetModel(model)
    ghost:SetModelScale(scale)
    ghost:SetAngles(rotation)
    ghost:SetRenderMode(RENDERMODE_TRANSALPHA)
    ghost:SetColor4Part(255, 255, 255, 120)
    ghost:DrawShadow(false)
    --ghost:SetParent(self:GetOwner())
	ghost:Spawn()

    timer.Simple(2, function()
        ghost:Remove()
    end)

    --print(model, scale, rotation)

end

function SWEP:PrimaryAttack()
    if !IsFirstTimePredicted() then return end -- Effect is client side

    local random_prop = table.Random(GetLivingPlayers(TEAM_PROPS))
    if !IsValid(random_prop) then return end
    local random_prop_prop = random_prop:GetProp()
    if !IsValid(random_prop_prop) then return end

    local model = random_prop_prop:GetModel()
    local scale = random_prop_prop:GetModelScale()
    local rotation = random_prop_prop:GetAngles()

    self:PrimaryAttackWithFunction(function () self:SpawnGhost(model, scale, rotation) end)
end
