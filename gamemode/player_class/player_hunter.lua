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
    
    self.Player:Give("weapon_crowbar")

    if (math.random() > 0.5) then
        self.Player:GiveAmmo(256, "Pistol", true)
        self.Player:Give("weapon_hunter_gun_pistol")
    else
        self.Player:GiveAmmo(36, "357")
        self.Player:Give("weapon_hunter_gun_revolver")
    end

    if (math.random() > 0.5) then
        self.Player:GiveAmmo(256, "SMG1")
        self.Player:GiveAmmo(1, "SMG1_Grenade")
        self.Player:Give("weapon_hunter_gun_smg")
    else
        self.Player:GiveAmmo(64, "Buckshot")
        self.Player:Give("weapon_hunter_gun_shotgun")
    end

    if (math.random() > 0.5) then
        self.Player:GiveAmmo(5, "XBowBolt")
        self.Player:Give("weapon_hunter_special_tauntgranade")
    else
        self.Player:GiveAmmo(5, "AR2AltFire")
        self.Player:Give("weapon_hunter_special_tauntseeker")
    end
    
    self.Player:Give("weapon_hunter_special_selfdestruct")


end

player_manager.RegisterClass("player_hunter", PLAYER, "player_default")
