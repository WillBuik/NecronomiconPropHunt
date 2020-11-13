DEFINE_BASECLASS("player_default")

local PLAYER = {}

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--

PLAYER.DisplayName       = "Prop"
PLAYER.WalkSpeed         = 222
PLAYER.RunSpeed          = 222
PLAYER.CanUseFlashlight  = false
PLAYER.UseVMHands        = false
PLAYER.AvoidPlayers      = false
PLAYER.TeammateNoCollide = false
PLAYER.MaxHealth         = 100
PLAYER.DuckSpeed         = 0.1
PLAYER.UnDuckSpeed       = 0.1
PLAYER.lastTaunt         = 0.0


function PLAYER:Loadout()
    self.Player:RemoveAllAmmo()
    self.Player:Give(ABILITIES[ math.random(#ABILITIES) ])
end

function PLAYER:SetupDataTables()
    self.Player:NetworkVar("Entity", 0, "Prop");
end

function PLAYER:GetPropLockedAngle()
    return self.Player:GetNWAngle("PropLockedAngle", Angle(0,0,0))
end

function PLAYER:SetPropLockedAngle(angle)
    self.Player:SetNWAngle("PropLockedAngle", angle)
end

function PLAYER:IsPropAngleLocked()
    return self.Player:GetNWBool("PropAngleLocked", false)
end

function PLAYER:SetPropLockedAngle(isLocked)
    return self.Player:SetNWBool("PropLockedAngle", isLocked)
end

player_manager.RegisterClass("player_prop", PLAYER, "player_default")
