DEFINE_BASECLASS("player_default")

local PLAYER = {}

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--

PLAYER.DisplayName       = "Hunter"
PLAYER.WalkSpeed         = 222
PLAYER.RunSpeed          = 222
PLAYER.CanUseFlashlight  = true
PLAYER.AvoidPlayers      = false
PLAYER.TeammateNoCollide = true
PLAYER.MaxHealth         = 100
PLAYER.DuckSpeed         = 0.1
PLAYER.UnDuckSpeed       = 0.1

function PLAYER:Loadout()

    self.Player:RemoveAllAmmo()
    self.Player:GiveAmmo(256, "Pistol", true)
    self.Player:GiveAmmo(256, "SMG1")
    self.Player:GiveAmmo(64, "Buckshot")
    self.Player:GiveAmmo(24, "357")
    self.Player:GiveAmmo(5, "XBowBolt")
    self.Player:GiveAmmo(3, "AR2AltFire")
    self.Player:GiveAmmo(1, "SMG1_Grenade")
    self.Player:Give("weapon_crowbar")
    self.Player:Give("weapon_hunter_gun_pistol")
    self.Player:Give("weapon_hunter_gun_smg")
    self.Player:Give("weapon_hunter_gun_shotgun")
    -- self.Player:Give("item_ar2_grenade")
    self.Player:Give("weapon_frag")
    self.Player:Give("weapon_hunter_gun_revolver")
    self.Player:Give("weapon_hunter_special_tauntgranade")
    self.Player:Give("weapon_hunter_special_tauntseeker")
    self.Player:Give("weapon_hunter_special_selfdestruct")


end

player_manager.RegisterClass("player_hunter", PLAYER, "player_default")
