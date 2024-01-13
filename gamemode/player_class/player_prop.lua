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


function PLAYER:Loadout()
    self.Player:RemoveAllAmmo()

    local ability_count = # ABILITIES
    if navmesh.IsLoaded() then
        ability_count = ability_count + (# ABILITIES_REQUIRE_NAVMESH)
    end
    if ability_count > 0 then
        local ability_idx = math.random(ability_count)
        if ability_idx <= (# ABILITIES) then
            self.Player:Give(ABILITIES[ability_idx])
        else
            self.Player:Give(ABILITIES_REQUIRE_NAVMESH[ability_idx - (# ABILITIES)])
        end
    end
end

function PLAYER:SetupDataTables()
    self.Player:NetworkVar("Entity", 0, "Prop")
end

player_manager.RegisterClass("player_prop", PLAYER, "player_default")
