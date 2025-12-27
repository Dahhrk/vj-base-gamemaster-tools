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
Placeholder for vehicle spawning with crew assignment.

**Planned Features:**
- Vehicle spawn waves
- Crew assignment (pilots, gunners)
- Vehicle customization
- Patrol routes

### 6. `role_based_npcs.lua`
Placeholder for role-based NPC behaviors.

**Planned Features:**
- Medic NPCs (healing)
- Engineer NPCs (repairs)
- Squad leaders (buffs)
- Role-specific AI behaviors

### 7. `gui_controller.lua`
Placeholder for live GUI control panel.

**Planned Features:**
- Real-time wave monitoring
- Visual wave builder
- Spawn point editor
- Multi-gamemaster support

## Usage Examples

See `examples.lua` for comprehensive usage examples including:
- Basic wave spawning
- Wave builder usage
- Clone Wars themed events
- Advanced customization
- Event-triggered waves
- Wave management

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

- `vjgm_test_basic` - Test basic wave
- `vjgm_test_clonewars` - Test Clone Wars preset
- `vjgm_stop_all` - Stop all active waves
- `vjgm_list_waves` - List active waves

## Notes

- All NPC classes should be VJ Base SNPCs for full feature support
- Replace placeholder class names (e.g., `npc_vj_test_human`) with actual Clone Wars NPC classes
- Spawn points must be registered before starting waves
- Wave IDs are unique and returned when starting waves
- Use event triggers for staged, story-driven spawns

## Support

For issues or questions, refer to the main repository documentation or the VJ Base documentation.