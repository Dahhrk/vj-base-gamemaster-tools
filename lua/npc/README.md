# NPC Module - Dynamic NPC Spawner

This folder contains the **Dynamic NPC Spawner** system for Clone Wars Roleplay and other Garry's Mod events. The system is fully compatible with **VJ Base** NPCs.

## Overview

The Dynamic NPC Spawner provides a wave-based NPC spawning system with advanced customization options, perfect for creating dynamic battles and staged events.

## Requirements

- **VJ Base** addon (https://steamcommunity.com/sharedfiles/filedetails/?id=131759821)
- Garry's Mod server
- Clone Wars NPC packs (optional, can use any VJ Base NPCs)

## Core Modules

### 1. `dynamic_spawner.lua`
Main spawner module that manages wave-based NPC spawning.

**Key Features:**
- Wave-based spawning system
- Configurable spawn intervals
- Event-driven wave triggers
- VJ Base NPC integration
- Advanced AI customization

**Main Functions:**
- `VJGM.NPCSpawner.StartWave(waveConfig, eventTrigger)` - Start a wave
- `VJGM.NPCSpawner.StopWave(waveID)` - Stop a wave
- `VJGM.NPCSpawner.GetWaveStatus(waveID)` - Get wave status
- `VJGM.NPCSpawner.GetActiveWaves()` - List active waves

### 2. `wave_config.lua`
Wave configuration system with validation and builders.

**Key Features:**
- Wave configuration structure
- Validation functions
- Configuration builder pattern
- Pre-made templates (Clone Wars, Basic)

**Main Functions:**
- `VJGM.WaveConfig.Validate(config)` - Validate configuration
- `VJGM.WaveConfig.CreateBuilder()` - Create configuration builder
- `VJGM.WaveConfig.CreateExample()` - Get example configuration
- `VJGM.WaveConfig.CreateCloneWarsExample()` - Get Clone Wars template

### 3. `spawn_points.lua`
Spawn point management system.

**Key Features:**
- Multiple spawn point groups
- Random/sequential selection
- Radius-based point creation
- Map entity import

**Main Functions:**
- `VJGM.SpawnPoints.Register(groupName, pos, angle)` - Register spawn point
- `VJGM.SpawnPoints.RegisterFromEntities(groupName, entityClass)` - Import from map
- `VJGM.SpawnPoints.RegisterInRadius(groupName, centerPos, radius, count)` - Create radial points
- `VJGM.SpawnPoints.GetPoints(groupName)` - Get spawn points

### 4. `npc_customizer.lua`
NPC customization system compatible with VJ Base.

**Key Features:**
- Health customization
- Weapon assignment
- Model/skin/bodygroup changes
- VJ Base specific settings (faction, AI behavior)
- Batch customization

**Main Functions:**
- `VJGM.NPCCustomizer.Apply(npc, customization)` - Apply customization
- `VJGM.NPCCustomizer.SetHealth(npc, health)` - Set health
- `VJGM.NPCCustomizer.SetWeapons(npc, weapons)` - Assign weapons

## Future Expansion Modules (Placeholders)

### 5. `vehicle_support.lua`
Vehicle spawning system with crew assignment. **✅ IMPLEMENTED**

**Features:**
- Vehicle spawn waves integrated with NPC waves
- Automatic crew assignment to seats (driver, gunner, passengers)
- Vehicle customization (health, color, skin)
- Basic patrol route system
- VJ Base compatible crew NPCs

**Main Functions:**
- `VJGM.VehicleSupport.SpawnVehicleWithCrew(vehicleClass, pos, angle, crew)` - Spawn vehicle with crew
- `VJGM.VehicleSupport.AddVehicleWave(waveConfig, vehicleWave)` - Add vehicle wave
- `VJGM.VehicleSupport.SetPatrolPath(vehicle, waypoints)` - Set patrol path
- `VJGM.VehicleSupport.GetSpawnedVehicles()` - List spawned vehicles
- `VJGM.VehicleSupport.CleanupAll()` - Remove all spawned vehicles

### 6. `role_based_npcs.lua`
Role-based NPC system with specialized behaviors. **✅ IMPLEMENTED**

**Features:**
- 7 NPC roles: Medic, Engineer, Squad Leader, Sniper, Scout, Heavy, Assault
- Medic NPCs automatically heal injured allies
- Squad Leader NPCs buff nearby allies with damage/accuracy boosts
- Role-specific attributes (health, speed, sight distance)
- Squad creation with balanced role distribution
- VJ Base compatible

**Main Functions:**
- `VJGM.RoleBasedNPCs.AssignRole(npc, role, roleConfig)` - Assign role to NPC
- `VJGM.RoleBasedNPCs.CreateSquad(squadConfig)` - Create balanced squad
- `VJGM.RoleBasedNPCs.GetNPCsByRole(role)` - Get NPCs by role
- `VJGM.RoleBasedNPCs.MedicBehavior(medic)` - Medic healing behavior
- `VJGM.RoleBasedNPCs.SquadLeaderBehavior(leader)` - Squad leader buff behavior

**Available Roles:**
- `VJGM.RoleBasedNPCs.Roles.MEDIC` - Heals injured allies
- `VJGM.RoleBasedNPCs.Roles.ENGINEER` - Repairs vehicles/structures (placeholder)
- `VJGM.RoleBasedNPCs.Roles.SQUAD_LEADER` - Buffs nearby allies
- `VJGM.RoleBasedNPCs.Roles.SNIPER` - Enhanced sight distance and accuracy
- `VJGM.RoleBasedNPCs.Roles.SCOUT` - Increased movement speed
- `VJGM.RoleBasedNPCs.Roles.HEAVY` - Increased health
- `VJGM.RoleBasedNPCs.Roles.ASSAULT` - Standard combat role

### 7. `gui_controller.lua`
Live GUI control panel for wave management. **✅ IMPLEMENTED**

**Features:**
- Full control panel with 4 tabs:
  - Active Waves: Monitor and control running waves
  - Wave Builder: Quick wave creation
  - Spawn Points: Visual spawn point management
  - Settings: Quick access to commands
- Real-time wave monitoring window
- Manual wave control (start, stop, pause, resume)
- Client-server networking
- Admin-only access

**Console Commands:**
- `vjgm_panel` - Open main control panel
- `vjgm_monitor` - Open wave monitor window

### 8. `testing_tools.lua`
Comprehensive testing and debugging tools. **✅ NEW**

**Features:**
- Wave management commands (pause, resume, stop, status)
- Role NPC testing and monitoring
- Vehicle management
- Spawn point management
- Quick test waves
- Help system

**Console Commands:**
- `vjgm_help` - Show all available commands
- `vjgm_wave_status [wave_id]` - Show wave status
- `vjgm_wave_pause <wave_id>` - Pause a wave
- `vjgm_wave_resume <wave_id>` - Resume a wave
- `vjgm_wave_stop <wave_id>` - Stop a wave
- `vjgm_wave_stop_all` - Stop all waves
- `vjgm_list_roles` - List role-based NPCs
- `vjgm_test_squad` - Test squad creation
- `vjgm_test_role_wave` - Spawn test wave with roles
- `vjgm_list_vehicles` - List spawned vehicles
- `vjgm_cleanup_vehicles` - Remove all vehicles
- `vjgm_test_vehicle_wave` - Spawn test vehicle wave
- `vjgm_list_spawns [group]` - List spawn points
- `vjgm_clear_spawns [group]` - Clear spawn points

## New Features

### Dynamic Wave Scaling
Automatically adjust wave difficulty based on player count and add randomization.

**Features:**
- Player count-based difficulty scaling
- NPC count and health scaling
- Wave composition randomization
- Fully configurable through `config/spawner_config.lua`

**Configuration:**
```lua
VJGM.Config.WaveScaling = {
    Enabled = true,
    ScaleByPlayerCount = true,
    DifficultyPerPlayer = 0.15,  -- 15% harder per player
    MaxDifficultyMultiplier = 3.0,
    RandomizationFactor = 0.15  -- ±15% randomization
}
```

### Wave Control
New pause/resume functionality for active waves.

**Functions:**
- `VJGM.NPCSpawner.PauseWave(waveID)` - Pause a wave
- `VJGM.NPCSpawner.ResumeWave(waveID)` - Resume a paused wave

## Future Expansion Modules (Placeholders)

## Usage Examples

See `examples.lua` for comprehensive usage examples including:
- Basic wave spawning
- Wave builder usage
- Clone Wars themed events
- Advanced customization
- Event-triggered waves
- Wave management

### Role-Based Squad Example
```lua
-- Create a role-based squad configuration
local squadConfig = {
    roles = {
        { role = VJGM.RoleBasedNPCs.Roles.SQUAD_LEADER, count = 1 },
        { role = VJGM.RoleBasedNPCs.Roles.ASSAULT, count = 4 },
        { role = VJGM.RoleBasedNPCs.Roles.MEDIC, count = 1 },
        { role = VJGM.RoleBasedNPCs.Roles.HEAVY, count = 1 }
    },
    baseClass = "npc_vj_clone_trooper",
    faction = "VJ_FACTION_PLAYER",
    squadName = "Alpha Squad"
}

-- Generate NPC configurations
local npcConfigs = VJGM.RoleBasedNPCs.CreateSquad(squadConfig)

-- Use in wave configuration
local waveConfig = {
    waves = {
        {
            npcs = npcConfigs,
            spawnPointGroup = "frontline",
            interval = 0
        }
    },
    defaultInterval = 30,
    cleanupOnComplete = false
}

VJGM.NPCSpawner.StartWave(waveConfig)
```

### Vehicle Wave Example
```lua
-- Setup spawn points
VJGM.SpawnPoints.RegisterInRadius("vehicle_spawns", Vector(0, 0, 100), 400, 4)

-- Create vehicle wave configuration
local vehicleWave = {
    vehicles = {
        {
            class = "prop_vehicle_jeep",
            count = 2,
            crew = {
                driver = {
                    class = "npc_vj_clone_trooper",
                    customization = {
                        health = 120,
                        vjbase = {
                            faction = "VJ_FACTION_PLAYER",
                            squad = "vehicle_crew"
                        }
                    }
                }
            },
            customization = {
                health = 1000,
                color = Color(100, 100, 100)
            }
        }
    },
    spawnPointGroup = "vehicle_spawns",
    interval = 60
}

-- Add to wave config
local waveConfig = VJGM.WaveConfig.CreateExample()
VJGM.VehicleSupport.AddVehicleWave(waveConfig, vehicleWave)
VJGM.NPCSpawner.StartWave(waveConfig)
```

### Manual Role Assignment Example
```lua
-- Spawn an NPC
local medic = ents.Create("npc_vj_clone_trooper")
medic:SetPos(Vector(0, 0, 100))
medic:Spawn()

-- Assign medic role
VJGM.RoleBasedNPCs.AssignRole(medic, VJGM.RoleBasedNPCs.Roles.MEDIC, {
    healAmount = 30,
    healRange = 400,
    healCooldown = 8
})
```

## Quick Start

### 1. Load Required Modules
All modules auto-initialize on server start. Ensure they're in the `lua/npc/` directory.

### 2. Register Spawn Points
```lua
-- From a center position
VJGM.SpawnPoints.RegisterInRadius("frontline", Vector(0, 0, 0), 500, 8)

-- From map entities
VJGM.SpawnPoints.RegisterFromEntities("default", "info_player_start")
```

### 3. Create Wave Configuration
```lua
local waveConfig = VJGM.WaveConfig.CreateBuilder()
    :SetDefaultInterval(25)
    :AddWave("frontline", 15)
    :AddNPCGroup("npc_vj_clone_trooper", 5, {
        health = 100,
        weapons = {"weapon_vj_dc15s"},
        vjbase = {
            faction = "VJ_FACTION_PLAYER",
            callForHelp = true,
            squad = "alpha_squad"
        }
    })
    :Build()
```

### 4. Start the Wave
```lua
local waveID = VJGM.NPCSpawner.StartWave(waveConfig)
```

## Wave Configuration Structure

```lua
{
    waves = {
        {
            npcs = {
                {
                    class = "npc_vj_clone_trooper",
                    count = 5,
                    customization = {
                        health = 100,
                        weapons = {"weapon_vj_dc15s"},
                        model = "models/clone_trooper.mdl",
                        vjbase = {
                            faction = "VJ_FACTION_PLAYER",
                            callForHelp = true,
                            canWander = false,
                            sightDistance = 10000,
                            squad = "wave_1"
                        }
                    }
                }
            },
            spawnPointGroup = "frontline",
            interval = 20
        }
    },
    defaultInterval = 30,
    cleanupOnComplete = false
}
```

## VJ Base Integration

The spawner is fully compatible with VJ Base NPCs. VJ Base-specific settings include:

- **faction** - VJ Base faction (e.g., "VJ_FACTION_PLAYER")
- **callForHelp** - Whether NPC calls for backup
- **canWander** - Allow/disable wandering
- **sightDistance** - Detection range
- **hearingCoef** - Hearing sensitivity
- **meleeDistance** - Melee attack range
- **squad** - Squad name for coordination

## Console Commands (for testing)

**Basic Testing:**
- `vjgm_help` - Show all available commands
- `vjgm_test_basic` - Test basic wave
- `vjgm_test_clonewars` - Test Clone Wars preset
- `vjgm_test_role_wave` - Test role-based squad wave
- `vjgm_test_vehicle_wave` - Test vehicle wave

**Wave Management:**
- `vjgm_wave_status [wave_id]` - Show wave status (all waves if no ID)
- `vjgm_wave_pause <wave_id>` - Pause a wave
- `vjgm_wave_resume <wave_id>` - Resume a paused wave
- `vjgm_wave_stop <wave_id>` - Stop a specific wave
- `vjgm_wave_stop_all` - Stop all active waves (also `vjgm_stop_all`)
- `vjgm_list_waves` - List all active waves

**Role-Based NPCs:**
- `vjgm_list_roles` - List all role-based NPCs
- `vjgm_test_squad` - Test squad creation

**Vehicles:**
- `vjgm_list_vehicles` - List all spawned vehicles
- `vjgm_cleanup_vehicles` - Remove all spawned vehicles

**Spawn Points:**
- `vjgm_list_spawns [group]` - List spawn points (all groups if no name)
- `vjgm_clear_spawns [group]` - Clear spawn points (all if no name)

**GUI Access:**
- `vjgm_panel` - Open main control panel (admin only)
- `vjgm_monitor` - Open wave monitor window (admin only)

## Notes

- All NPC classes should be VJ Base SNPCs for full feature support
- Replace placeholder class names (e.g., `npc_vj_test_human`) with actual Clone Wars NPC classes
- Spawn points must be registered before starting waves
- Wave IDs are unique and returned when starting waves
- Use event triggers for staged, story-driven spawns

## Support

For issues or questions, refer to the main repository documentation or the VJ Base documentation.