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

-- Role-Based NPCs configuration
VJGM.Config.RoleBasedNPCs = {
    -- Enable role-based NPC system
    Enabled = true,
    
    -- Medic role settings
    Medic = {
        HealAmount = 25,
        HealRange = 300,
        HealCooldown = 10,
        HealThreshold = 0.8,  -- Heal allies below 80% health
        DefaultHealth = 100,
    },
    
    -- Engineer role settings
    Engineer = {
        RepairAmount = 50,
        RepairRange = 300,
        RepairCooldown = 15,
        DefaultHealth = 100,
    },
    
    -- Squad Leader role settings
    SquadLeader = {
        BuffRange = 500,
        DamageBuff = 1.2,
        AccuracyBuff = 1.15,
        BuffDuration = 5,
        DefaultHealth = 150,
    },
    
    -- Sniper role settings
    Sniper = {
        SightDistance = 15000,
        SightAngle = 60,
        DefaultHealth = 80,
    },
    
    -- Scout role settings
    Scout = {
        WalkSpeedMultiplier = 1.3,
        RunSpeedMultiplier = 1.3,
        DefaultHealth = 80,
    },
    
    -- Heavy role settings
    Heavy = {
        HealthMultiplier = 1.5,
        DefaultHealth = 200,
    },
    
    -- Assault role settings (default/standard)
    Assault = {
        DefaultHealth = 100,
    },
}

-- Vehicle Support configuration
VJGM.Config.VehicleSupport = {
    -- Enable vehicle support system
    Enabled = true,
    
    -- Default vehicle health
    DefaultVehicleHealth = 1000,
    
    -- Default spawn height offset for vehicles
    VehicleSpawnHeightOffset = 20,
    
    -- Default vehicle spawn interval
    DefaultVehicleInterval = 60,
    
    -- Auto-assign crew to vehicles
    AutoAssignCrew = true,
    
    -- Crew spawn radius around vehicle (units)
    CrewSpawnRadius = 50,
    
    -- Delay before assigning crew to seats (seconds)
    CrewAssignmentDelay = 0.1,
    
    -- Vehicle patrol settings
    PatrolSpeed = 200,
    PatrolStopDistance = 100,
    
    -- Cleanup vehicles on wave complete
    CleanupVehiclesOnComplete = false,
}

-- GUI Controller configuration
VJGM.Config.GUIController = {
    -- Enable GUI controller
    Enabled = true,
    
    -- Update interval for wave monitor (seconds)
    MonitorUpdateInterval = 1,
    
    -- Admin only access
    AdminOnly = true,
    
    -- Show NPC health bars in monitor
    ShowNPCHealthBars = true,
    
    -- Maximum NPCs to show in monitor
    MaxNPCsInMonitor = 50,
}

-- Wave Scaling configuration
VJGM.Config.WaveScaling = {
    -- Enable dynamic wave scaling
    Enabled = true,
    
    -- Scale difficulty based on player count
    ScaleByPlayerCount = true,
    
    -- Difficulty multiplier per player
    DifficultyPerPlayer = 0.15,
    
    -- Maximum difficulty multiplier
    MaxDifficultyMultiplier = 3.0,
    
    -- Minimum players for scaling
    MinPlayersForScaling = 1,
    
    -- Enable AI learning (track player performance)
    EnableAILearning = false,
    
    -- Randomization percentage (0.0 - 1.0)
    RandomizationFactor = 0.15,
}

return VJGM.Config
