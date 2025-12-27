--[[
    Dynamic NPC Spawner - Main Configuration
    
    All configurable values for the NPC spawner system
    Modify these values to customize the spawner behavior
]]--

VJGM = VJGM or {}
VJGM.Config = VJGM.Config or {}
VJGM.Config.Spawner = {
    -- Default spawn interval between waves (in seconds)
    DefaultWaveInterval = 30,
    
    -- Default NPC class if none specified
    DefaultNPCClass = "npc_vj_test_human",
    
    -- Default spawn height offset (units above spawn point)
    SpawnHeightOffset = 10,
    
    -- Cleanup NPCs when wave completes
    DefaultCleanupOnComplete = false,
    
    -- Default NPC health if not specified
    DefaultNPCHealth = 100,
    
    -- Enable debug messages
    DebugMode = true,
    
    -- Prefix for console messages
    ConsolePrefix = "[VJGM]",
    
    -- Timer name prefix
    TimerPrefix = "VJGM_Wave_",
    
    -- Cleanup callback prefix
    CleanupPrefix = "VJGM_Cleanup_",
    
    -- Maximum active waves allowed simultaneously
    MaxActiveWaves = 10,
    
    -- Auto-initialize on server start
    AutoInitialize = true,
    
    -- VJ Base detection warning
    ShowVJBaseWarning = true,
}

-- Spawn point configuration
VJGM.Config.SpawnPoints = {
    -- Default spawn point group name
    DefaultGroupName = "default",
    
    -- Default spawn angle
    DefaultAngle = Angle(0, 0, 0),
    
    -- Default radius for radial spawn point creation
    DefaultRadius = 500,
    
    -- Default number of points in radial pattern
    DefaultRadialCount = 8,
    
    -- Default entity class to import spawn points from
    DefaultEntityClass = "info_player_start",
    
    -- Enable debug messages
    DebugMode = true,
}

-- NPC Customizer configuration
VJGM.Config.Customizer = {
    -- Apply health customization by default
    EnableHealthCustomization = true,
    
    -- Apply weapon customization by default
    EnableWeaponCustomization = true,
    
    -- Apply model customization by default
    EnableModelCustomization = true,
    
    -- Apply VJ Base customization by default
    EnableVJBaseCustomization = true,
    
    -- Enable debug messages
    DebugMode = false,
}

-- VJ Base integration settings
VJGM.Config.VJBase = {
    -- Default faction for NPCs
    DefaultFaction = "VJ_FACTION_ANTLION",
    
    -- Default call for help setting
    DefaultCallForHelp = true,
    
    -- Default wander setting
    DefaultCanWander = true,
    
    -- Default sight distance
    DefaultSightDistance = 10000,
    
    -- Default hearing coefficient
    DefaultHearingCoef = 1.0,
    
    -- Default melee distance (0 = use NPC default)
    DefaultMeleeDistance = 0,
    
    -- Enable VJ Base integration
    Enabled = true,
}

return VJGM.Config
