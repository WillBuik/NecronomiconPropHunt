--[[==============]]--
--[[GENERAL CONFIG]]--
--[[==============]]--

-- the team numbers (this value generally should not have to be changed)
TEAM_PROPS      = 1
TEAM_HUNTERS    = 2

TEAM_ANY        = 1003

-- the default player models
TEAM_PROPS_DEFAULT_MODEL = "models/player/kleiner.mdl"
TEAM_HUNTERS_DEFAULT_MODEL = "models/player/combine_super_soldier.mdl"

-- the maximum difference between the number of players for each team
MAX_TEAM_NUMBER_DIFFERENCE = 2

-- Number of rounds per map
OBJHUNT_ROUNDS = 4

-- Length of each round in seconds
OBJHUNT_ROUND_TIME = 315

-- Initial waiting time before first round starts
OBJHUNT_PRE_ROUND_TIME = 90

-- Waiting time before new round starts after first round
OBJHUNT_POST_ROUND_TIME = 5

-- How much time props have before hunters are released
OBJHUNT_HIDE_TIME = 45

-- This enables autotaunt
AUTOTAUNT_ENABLED = true

-- Auto taunting base interval in seconds (we also factor in the length of the taunt)
OBJHUNT_AUTOTAUNT_BASE_INTERVAL = 20

-- We multiply this by the last taunt duration and add auto taunting base interval to get the next auto taunt time
OBJHUNT_AUTOTAUNT_DURATION_MODIFIER = 1.5

-- The damage hunters will take for shooting the wrong prop
-- Set this negative if you want dynamic damage (hit 50 damage take 50 damage)
HUNTER_DAMAGE_PENALTY = 5

-- Can players talk between teams or only amongst?
DISABLE_GLOBAL_CHAT = false

-- Round constants
ROUND_WAIT  = 0
ROUND_START = 1
ROUND_IN    = 2
ROUND_END   = 3

-- The minimum Z height that the props view will be set to
VIEW_MIN_Z = 5

-- the default hitbox for the initial prop
PROP_DEFAULT_HB_MIN = Vector(-10,-10,0)
PROP_DEFAULT_HB_MAX = Vector(10,10,35)

-- the default scale for the initial prop
PROP_DEFAULT_SCALE = 2.0

-- the scale for the props chosen by the player
PROP_CHOSEN_SCALE = 1

-- the time in seconds the prop has to wait before they can change prop
PROP_CHOOSE_COOLDOWN = 2

-- the maximum distance at which a prop can be selected
PROP_SELECT_DISTANCE = 150

-- this value should be left alone
PROP_DEFAULT_DENSITY = 0.0025879917184265

-- the maximum distance from the player the camera will render when in third person
THIRDPERSON_DISTANCE = 100

-- this enables TEAM_HUNTERS to pick up props
OBJHUNT_TEAM_HUNTERS_CAN_MOVE_PROPS = false

-- this enables TEAM_PROPS to pick up props
OBJHUNT_TEAM_PROPS_CAN_MOVE_PROPS = true

-- Increase the default prop jump height to make it so props can get on tables
PROP_DEFAULT_JUMP_POWER = 260

-- The incriment of the prop roll for each tick on the mouse wheel
PROP_ROLL_INCRIMENT = 15

-- Amount of time a prop's ragdoll is shown after death
-- Affects both real death and fake "play dead" death
PROP_RAGDOLL_DURATION = 8

-- Duration (in seconds) that friendly fire is enabled when a prop uses the
-- friendly fire powerup.
FRIENDLY_FIRE_ABILITY_DURATION = 30

-- Amount of time a player is given to contemplate their own demise before
-- going into spectator mode
-- If this is set to 0, the dead player's ragdoll may spawn in the wrong place,
-- on top of the player they are spectating
TIME_BEFORE_SPECTATE = 3

-- Number maps shown to vote on
MAPS_SHOWN_TO_VOTE = 10

-- entities that are capable of being chosen by props
USABLE_PROP_ENTITIES = {
    "prop_physics",
    "prop_physics_multiplayer",
    "prop_physics_override"
}

BANNED_PROPS = {
    "models/props/cs_office/tv_plasma.mdl",
    "models/props_c17/chair02a.mdl",
    "models/props/cs_office/fire_extinguisher.mdl",
    "models/props/cs_office/snowman_arm.mdl",
    "models/props/cs_assault/money.mdl",
    "models/props/cs_assault/dollar.mdl",
    "models/props_c17/door01_left.mdl",
    "models/props_c17/signpole001.mdl"
}

DOORS = {
    "func_door",
    "func_door_rotating",
    "prop_door_rotating"
}

PROPHUNT_MAP_PREFIXES = {"cs_", "ph_", "gm_ww"}

--[[=====================]]--
--[[COLORS AND HUD CONFIG]]--
--[[=====================]]--

-- halos around props
GOOD_HOVER_COLOR = Color(0,255,0,255)
BAD_HOVER_COLOR = Color(255,0,0,255)

-- general look and feel of gui
PANEL_FILL = Color(200,200,200,20)
PANEL_BORDER = Color(200,200,200,255)

-- team colors displayed on the scoreboard
PLAYER_LINE_COLOR = Color(85, 85, 85)
TEAM_PROPS_COLOR = Color(255, 0, 0, 100)
TEAM_HUNTERS_COLOR = Color(0, 0, 255, 100)
TEAM_PROPS_CHAT_COLOR = Color(255, 0, 0, 255)
TEAM_HUNTERS_CHAT_COLOR = Color(0, 0, 255, 255)
TEAM_ANY_COLOR = Color(180, 0, 180, 100)

-- context menu elements
ON_COLOR = Color(0, 255, 0, 100)
OFF_COLOR = Color(255, 0, 0, 100)

-- HUD elements
HP_COLOR = Color(255, 0, 0, 150)
POWERUP_COLOR = Color(255, 215, 0, 150)
DEPLETED_COLOR = Color(255, 0, 0, 150)
FULL_COLOR = Color(0, 255, 0, 150)
ROUND_TIME_COLOR = Color(85, 85, 85, 200)
TAUNT_BAR_COLOR = Color(0, 255, 255, 150)
TEXT_COLOR = Color(255, 255, 255, 255)

--[[================]]--
--[[ABILITIES CONFIG]]--
--[[================]]--

ABILITIES = {
    "weapon_prop_powerup_friendlyfire",
    "weapon_prop_powerup_cloak",
    "weapon_prop_powerup_disguise",
    "weapon_prop_powerup_remove",
    "weapon_prop_powerup_playdead",
    "weapon_prop_powerup_stack",
    "weapon_prop_powerup_popup",
    "weapon_prop_powerup_superhot",
    "weapon_prop_powerup_blastoff",
    "weapon_prop_powerup_bongcloud",
    "weapon_prop_powerup_zoolander",
    "weapon_prop_powerup_gun",
    "weapon_prop_powerup_recall",
}

-- These abilities are skipped if a Navmesh isn't loaded for the map.
ABILITIES_REQUIRE_NAVMESH = {
    "weapon_prop_powerup_decoy",
}

--[[=====================]]--
--[[HUNTER WEAPONS CONFIG]]--
--[[=====================]]--

-- Hunter weapons, hunters will get one random weapon from each entry in this table.
HUNTER_WEAPONS = {
    -- Crowbar
    {
        {
            swep = "weapon_crowbar"
        }
    },
    -- Hand guns
    {
        {
            swep = "weapon_hunter_gun_pistol",
            ammo = { "Pistol", 256 }
        },
        {
            swep = "weapon_hunter_gun_revolver",
            ammo = { "357", 36 }
        },
    },
    -- Long guns
    {
        {
            swep = "weapon_hunter_gun_smg",
            ammo = { "SMG1", 256, "SMG1_Grenade", 1 }
        },
        {
            swep = "weapon_hunter_gun_shotgun",
            ammo = { "Buckshot", 64 }
        }
    },
    -- Special guns
    {
        {
            swep = "weapon_hunter_special_tauntgranade",
            ammo = { "AR2AltFire", 1 }
        },
        {
            swep = "weapon_hunter_special_tauntseeker",
            ammo = { "AR2AltFire", 1 }
        },
        {
            swep = "weapon_hunter_special_thumper",
            ammo = { "AR2AltFire", 1 }
        },
        {
            swep = "weapon_hunter_special_clairvoyance",
            ammo = { "AR2AltFire", 1 }
        }
    },
    -- Self destruct
    {
        {
            swep = "weapon_hunter_special_selfdestruct"
        }
    }
}

-- Amount of ammo to give hunters in test mode.
HUNTER_WEAPONS_TESTMODE_AMMO = 500

--[[=============]]--
--[[BREATH CONFIG]]--
--[[=============]]--

-- Button to hold
BREATH_BUTTON = KEY_LSHIFT

-- Damage suffered immediately upon pressing BREATH_BUTTON
BREATH_INIT_HEALTH_PENALTY = 2

-- Damage suffered periodically while holding your breath, and how often (in
-- seconds) to deal it.  The first periodic penalty happens
-- BREATH_PERIODIC_HEALTH_PENALTY_RATE after pressing BREATH_BUTTON.
BREATH_PERIODIC_HEALTH_PENALTY = 1
BREATH_PERIODIC_HEALTH_PENALTY_RATE = 0.5

--[[============]]--
--[[TAUNT CONFIG]]--
--[[============]]--

-- change within 0 < range < 256
TAUNT_MAX_PITCH = 110
TAUNT_MIN_PITCH = 90

-- Q-menu Anti Abuse Settings
QMENU_ANTI_ABUSE = false        -- Kill players who abuse the Q-menu
QMENU_CONSEQUENCE_ODDS = 200    -- Using the Q-menu will kill the player 1 in N times

-- Prop ghosts have to wait this many seconds between the end of their last
-- taunt and the start of their next one.
PROP_GHOST_TAUNT_WAIT = 30

-- Prop ghosts have to wait this many seconds between the end of their last
-- door open/close to do it again
PROP_GHOST_DOOR_WAIT = 5

-- Create taunt tables only if a pack hasn't already created them.
if (PROP_TAUNTS == nil) then
    PROP_TAUNTS = { }
end
if (HUNTER_TAUNTS == nil) then
    HUNTER_TAUNTS = { }
end

-- USAGE:
-- PROP_TAUNTS["Display Name"] = "taunts/file_name.wav"
PROP_TAUNTS["LEEROY... JENKINS!"]           = "taunts/leeroy_jenkins.wav"

-- USAGE:
-- HUNTER_TAUNTS["Display Name"] = "taunts/file_name.wav"
HUNTER_TAUNTS["GlaDoS - President"]         = "taunts/glados-president.wav"

-- For paying respects
RESPECTS_VERBS = {
    "paid respects to",
    "mourned",
    "left a tribute for",
    "poured one out for",
    "observed a moment of silence for",
    "lit a candle for",
    "contemplated the fragility of the life of",
    "bowed their head for",
    "dropped an F in the chat for"
}

-- Enable PVS workaround for wallhacks
-- Warning, this causes a performance hit, see "Wallhacks PVS fix" hook
-- in init.lua for more details.
WALLHACK_PVS_FIX = true

-- Name of the map info SQL table in the server database
-- This must be a safe name for a SQL table!
MAP_DB_TABLE_NAME = "nph_map_info"
