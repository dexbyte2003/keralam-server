Config = {}

-- ======================================================
-- 🎮 GENERAL SETTINGS
-- ======================================================

Config.OpenKey = 'F7'                 -- Key to open NPC Spawner UI
Config.Command = 'npcspawner'         -- Optional chat command
Config.AllowCommand = true

Config.Debug = false
Config.Locale = 'en'

-- ======================================================
-- 🔐 PERMISSIONS (NATIVE ACE)
-- ======================================================
-- Uses FiveM built-in admin system
-- Checks: IsPlayerAceAllowed(source, "group.admin")

Config.AdminOnly = false               -- true = only admins can access
Config.UseGroupAdmin = false           -- enforce group.admin check

-- ======================================================
-- 🧍 NPC LIMITS & SAFETY
-- ======================================================

Config.MaxNPCsGlobal = 100             -- Hard global cap
Config.MaxNPCsPerSpawn = 20            -- Max per spawn action
Config.MaxDistanceCleanup = 350.0      -- Auto delete far NPCs

Config.PreventSpawnInVehicle = true
Config.PreventSpawnWhileDead = true

-- ======================================================
-- 🗺️ SPAWN SETTINGS
-- ======================================================

Config.DefaultSpawn = {
    useGroundSnap = true,
    randomRadius = 0.0,                -- 0 = disabled
    heading = 'player'                 -- 'player' | 'random' | number
}

Config.Formations = {
    'single',
    'line',
    'circle',
    'grid',
    'follow'
}

-- ======================================================
-- 🧠 AI & BEHAVIOR DEFAULTS
-- ======================================================

Config.DefaultBehavior = {
    type = 'passive',                  -- passive | civilian | guard | aggressive | companion
    wanderRadius = 15.0,
    canFlee = false,
    alertness = 0.5,                   -- 0.0 - 1.0
    reactionTime = 0.4                 -- seconds
}

-- ======================================================
-- 🔫 COMBAT DEFAULTS
-- ======================================================

Config.DefaultCombat = {
    enabled = false,
    accuracy = 35,                     -- 0 - 100
    aggression = 50,                   -- 0 - 100
    fireRate = 1.0,                    -- multiplier
    combatRange = 40.0,
    headshotChance = 10,
    useCover = true
}

Config.AllowWeapons = true
Config.AllowWeaponAttachments = true

-- ======================================================
-- 🛡️ NPC STATE FLAGS
-- ======================================================

Config.AllowGodMode = true
Config.AllowNoRagdoll = true
Config.AllowNoCollision = true
Config.AllowInvisible = true

Config.DefaultStates = {
    invincible = false,
    ragdoll = true,
    collision = true,
    frozen = false,
    invisible = false
}

-- ======================================================
-- 🎭 APPEARANCE OPTIONS
-- ======================================================

Config.AllowRandomOutfits = true
Config.AllowPlayerOutfitCopy = true

-- ======================================================
-- 💾 SAVE & PERSISTENCE
-- ======================================================

Config.AllowPresets = true
Config.SaveToServer = true             -- sync presets server-side
Config.RespawnOnDeath = false
Config.RespawnDelay = 5                -- seconds

-- ======================================================
-- 🖱️ UI SETTINGS
-- ======================================================

Config.UI = {
    theme = 'dark',
    blurBackground = true,
    enableAnimations = true,
    closeOnEscape = true,
    lockControlsWhenOpen = true
}

-- ======================================================
-- ⚙️ PERFORMANCE
-- ======================================================

Config.Performance = {
    enablePooling = true,
    tickRateNear = 500,                -- ms
    tickRateFar = 2000,                -- ms
    farDistance = 100.0
}

-- ======================================================
-- 🚫 BLACKLISTS
-- ======================================================

Config.BlacklistedPeds = {
    `mp_f_deadhooker`,
    `s_m_y_swat_01`
}

Config.BlacklistedWeapons = {
    `WEAPON_RAILGUN`,
    `WEAPON_MINIGUN`
}
