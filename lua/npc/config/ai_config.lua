--[[
    AI Behaviors Configuration
    
    All configurable values for advanced NPC AI behaviors
    Includes cover-seeking, target prioritization, combat states, and group communication
]]--

VJGM = VJGM or {}
VJGM.Config = VJGM.Config or {}

-- AI Behaviors main configuration
VJGM.Config.AIBehaviors = {
    -- Enable AI behavior system
    Enabled = true,
    
    -- AI update interval (seconds) - how often to process AI decisions
    UpdateInterval = 0.5,
    
    -- Enable debug mode for AI behaviors
    DebugMode = false,
    
    -- Enable visual debug helpers (cover indicators, threat lines, etc.)
    VisualDebug = false,
}

-- Cover-Seeking Behavior configuration
VJGM.Config.CoverSeeking = {
    -- Enable cover-seeking behavior
    Enabled = true,
    
    -- Maximum distance to search for cover (units)
    MaxCoverDistance = 1000,
    
    -- Minimum distance from enemy to seek cover (units)
    MinEnemyDistance = 300,
    
    -- Height bonus for elevated cover positions
    ElevationBonus = 50,
    
    -- How often to check for better cover (seconds)
    CheckInterval = 3.0,
    
    -- Minimum time to stay in cover before moving (seconds)
    MinCoverTime = 5.0,
    
    -- Health threshold to trigger cover seeking (0.0 - 1.0)
    HealthThreshold = 0.7,
    
    -- Cover quality multiplier for nearby allies (encourages grouping)
    AllyProximityBonus = 1.2,
    
    -- Trace distance to check if position provides cover
    CoverCheckDistance = 100,
    
    -- Number of cover positions to evaluate
    CoverSampleCount = 8,
    
    -- Prefer corners and edges for tactical advantage
    CornerPreference = 1.3,
}

-- Target Prioritization configuration
VJGM.Config.TargetPrioritization = {
    -- Enable target prioritization
    Enabled = true,
    
    -- Re-evaluate targets interval (seconds)
    UpdateInterval = 2.0,
    
    -- Priority calculation weights (should sum to 1.0 for balanced scoring)
    -- Distance: Closer targets are prioritized
    -- Threat: Higher threat entities are prioritized (players, medics, etc.)
    -- Health: Lower health targets are prioritized for finishing
    -- LineOfSight: Targets with clear LOS are prioritized
    DistanceWeight = 0.4,
    ThreatWeight = 0.3,
    HealthWeight = 0.2,
    LineOfSightWeight = 0.1,
    
    -- Maximum target distance (units)
    MaxTargetDistance = 10000,
    
    -- Threat multipliers for different entity types
    ThreatMultipliers = {
        player = 2.0,          -- Players are high priority
        npc_turret = 1.8,      -- Turrets are dangerous
        vehicle = 1.5,         -- Vehicles are significant threats
        npc_sniper = 1.7,      -- Snipers get priority
        npc_heavy = 1.4,       -- Heavy units are threats
        npc_medic = 1.6,       -- Medics should be prioritized
        default = 1.0,         -- Default threat level
    },
    
    -- Bonus for enemies attacking allies
    AttackingAllyBonus = 1.3,
    
    -- Penalty for targets behind cover
    CoverPenalty = 0.7,
}

-- Dynamic Combat States configuration
VJGM.Config.CombatStates = {
    -- Enable dynamic combat states
    Enabled = true,
    
    -- How often to evaluate combat state (seconds)
    EvaluationInterval = 1.5,
    
    -- State transition cooldown (seconds) - prevent rapid state changes
    TransitionCooldown = 3.0,
    
    -- AGGRESSIVE state thresholds
    Aggressive = {
        -- Health threshold to enter aggressive state (above this value)
        HealthThreshold = 0.7,
        
        -- Minimum ally count nearby to maintain aggressive
        MinAllyCount = 2,
        
        -- Damage multiplier in aggressive state
        DamageMultiplier = 1.15,
        
        -- Movement speed multiplier
        SpeedMultiplier = 1.1,
        
        -- Weapon spread reduction (better accuracy)
        AccuracyMultiplier = 0.9,
        
        -- Preferred engagement distance (units)
        EngagementDistance = 500,
    },
    
    -- DEFENSIVE state thresholds
    Defensive = {
        -- Health threshold to enter defensive state
        HealthThreshold = 0.4,
        
        -- Enemy count threshold (more enemies = defensive)
        EnemyCountThreshold = 3,
        
        -- Damage multiplier in defensive state
        DamageMultiplier = 1.0,
        
        -- Movement speed multiplier
        SpeedMultiplier = 0.85,
        
        -- Weapon spread (reduced accuracy due to caution)
        AccuracyMultiplier = 1.1,
        
        -- Preferred engagement distance (units)
        EngagementDistance = 800,
        
        -- Prefer cover in defensive state
        SeekCover = true,
    },
    
    -- RETREAT state thresholds
    Retreat = {
        -- Health threshold to trigger retreat (below this value)
        HealthThreshold = 0.25,
        
        -- Enemy count threshold to trigger retreat
        EnemyCountThreshold = 5,
        
        -- No allies nearby forces retreat
        NoAlliesRetreat = true,
        
        -- Movement speed multiplier when retreating
        SpeedMultiplier = 1.2,
        
        -- Retreat distance from enemies (units)
        RetreatDistance = 1200,
        
        -- Suppress fire while retreating (reduced accuracy)
        AccuracyMultiplier = 1.5,
        
        -- Force cover seeking during retreat
        ForceCoverSeeking = true,
    },
    
    -- SUPPRESSED state (under heavy fire)
    Suppressed = {
        -- Damage taken threshold in time window
        DamageThreshold = 50,
        
        -- Time window for damage calculation (seconds)
        TimeWindow = 3.0,
        
        -- Movement speed reduction
        SpeedMultiplier = 0.6,
        
        -- Accuracy penalty
        AccuracyMultiplier = 1.4,
        
        -- Force to stay in cover
        StayInCover = true,
        
        -- Suppression duration (seconds)
        Duration = 5.0,
    },
}

-- Group Communication configuration
VJGM.Config.GroupCommunication = {
    -- Enable group communication system
    Enabled = true,
    
    -- Communication update interval (seconds)
    UpdateInterval = 1.0,
    
    -- Maximum communication range (units)
    MaxRange = 2000,
    
    -- Call for help range (units)
    CallForHelpRange = 1500,
    
    -- Alert allies when spotting enemy
    AlertOnEnemySighted = true,
    
    -- Share target information with squad
    ShareTargetInfo = true,
    
    -- Coordinate flanking maneuvers
    CoordinateFlanking = true,
    
    -- Flanking distance (units)
    FlankingDistance = 600,
    
    -- Request covering fire
    RequestCoveringFire = true,
    
    -- Covering fire duration (seconds)
    CoveringFireDuration = 5.0,
    
    -- Report low ammo to squad
    ReportLowAmmo = true,
    
    -- Low ammo threshold (percentage)
    LowAmmoThreshold = 0.3,
    
    -- Report injuries to squad
    ReportInjuries = true,
    
    -- Injury report threshold (percentage)
    InjuryThreshold = 0.5,
    
    -- Suppress enemy notification
    SuppressEnemyNotification = true,
    
    -- Squad leader gets priority communication
    SquadLeaderPriority = true,
    
    -- Communication types and their priorities
    MessagePriorities = {
        enemy_spotted = 10,
        under_fire = 9,
        man_down = 8,
        low_ammo = 6,
        requesting_backup = 7,
        flanking = 5,
        covering_fire = 5,
        holding_position = 3,
        advancing = 4,
        retreating = 8,
    },
}

-- Weapon Logic configuration
VJGM.Config.WeaponLogic = {
    -- Enable advanced weapon logic
    Enabled = true,
    
    -- Ammo management
    AmmoManagement = {
        -- Enable ammo tracking
        Enabled = true,
        
        -- Reload when ammo below this percentage
        ReloadThreshold = 0.3,
        
        -- Default reload time (seconds) - can be overridden per weapon
        DefaultReloadTime = 2.0,
        
        -- Ammo consumption rate per update (simulated)
        AmmoConsumptionRate = 0.01,
        
        -- Seek cover while reloading
        CoverDuringReload = true,
        
        -- Alert squad when low on ammo
        AlertOnLowAmmo = true,
        
        -- Conservative fire when low on ammo
        ConservativeFireThreshold = 0.2,
        
        -- Burst fire mode when conserving ammo
        BurstFireCount = 3,
        
        -- Delay between bursts (seconds)
        BurstDelay = 0.5,
    },
    
    -- Weapon selection logic
    WeaponSelection = {
        -- Enable intelligent weapon switching
        Enabled = true,
        
        -- Switch to long range weapon at distance (units)
        LongRangeThreshold = 1500,
        
        -- Switch to close range weapon at distance (units)
        CloseRangeThreshold = 300,
        
        -- Prefer explosive weapons against vehicles
        ExplosivesForVehicles = true,
        
        -- Prefer accurate weapons at long range
        AccuracyForLongRange = true,
    },
    
    -- Suppressive fire
    SuppressiveFire = {
        -- Enable suppressive fire
        Enabled = true,
        
        -- Duration of suppressive fire (seconds)
        Duration = 4.0,
        
        -- Cooldown between suppressive fire (seconds)
        Cooldown = 10.0,
        
        -- Trigger suppressive fire to help allies
        HelpAllies = true,
        
        -- Increased fire rate during suppression
        FireRateMultiplier = 1.3,
        
        -- Reduced accuracy (spray area)
        AccuracyPenalty = 1.5,
    },
    
    -- Fire discipline
    FireDiscipline = {
        -- Enable fire discipline
        Enabled = true,
        
        -- Don't shoot without clear line of sight
        RequireLineOfSight = true,
        
        -- Minimum accuracy to engage (percentage)
        MinAccuracyThreshold = 0.6,
        
        -- Hold fire when allies in line of fire
        AvoidFriendlyFire = true,
        
        -- Friendly fire check distance (units)
        FriendlyFireCheckDistance = 50,
        
        -- Controlled bursts for better accuracy
        UseControlledBursts = true,
        
        -- Burst size
        BurstSize = 5,
        
        -- Delay between bursts (seconds)
        BurstCooldown = 0.3,
    },
}

-- Tactical Awareness configuration
VJGM.Config.TacticalAwareness = {
    -- Enable tactical awareness
    Enabled = true,
    
    -- Scan interval for threats (seconds)
    ScanInterval = 1.0,
    
    -- Awareness radius (units)
    AwarenessRadius = 1500,
    
    -- Eye height offset for line of sight checks (units)
    EyeHeightOffset = 50,
    
    -- React to nearby explosions
    ReactToExplosions = true,
    
    -- Explosion reaction radius (units)
    ExplosionRadius = 500,
    
    -- React to gunfire sounds
    ReactToGunfire = true,
    
    -- Gunfire reaction radius (units)
    GunfireRadius = 800,
    
    -- Investigate suspicious sounds
    InvestigateSounds = true,
    
    -- Maintain formation with squad
    MaintainFormation = true,
    
    -- Formation spacing (units)
    FormationSpacing = 200,
    
    -- Watch flanks when in squad
    WatchFlanks = true,
    
    -- Avoid clustering (prevents grenade kills)
    AvoidClustering = true,
    
    -- Minimum spacing between NPCs (units)
    MinNPCSpacing = 150,
}

return VJGM.Config
