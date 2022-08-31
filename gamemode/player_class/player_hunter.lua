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

-- Give a hunter a weapon and setup ammo.
local function hunter_give_weapon(ply, weapon, testmode)
    ply:Give(weapon.swep)
    if weapon.ammo != nil then
        for i = 1, #weapon.ammo - 1, 2 do
            if testmode then
                ply:SetAmmo(HUNTER_WEAPONS_TESTMODE_AMMO, weapon.ammo[i])
            else
                ply:SetAmmo(weapon.ammo[i+1], weapon.ammo[i])
            end
        end
    end
end

-- Setup the hunter loadout based on HUNTER_WEAPONS.
function hunter_setup_loadout(ply, testmode)
    ply:RemoveAllAmmo()
    ply:StripWeapons()

    for _, class_weapons in ipairs(HUNTER_WEAPONS) do
        if testmode then
            -- Give hunter all class weapons in testmode
            for _, class_weapon in ipairs(class_weapons) do
                hunter_give_weapon(ply, class_weapon, true)
            end
        else
            hunter_give_weapon(ply, table.Random(class_weapons), false)
        end
    end
end

function PLAYER:Loadout()
    hunter_setup_loadout(self.Player, GetGlobalInt("PHD_TESTMODE") == 1)
end

player_manager.RegisterClass("player_hunter", PLAYER, "player_default")
