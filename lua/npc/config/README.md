# Configuration Folder

This folder contains all configurable values for the Dynamic NPC Spawner system. Modify these files to customize the spawner behavior without editing the core modules.

## Configuration Files

### 1. `init.lua`
Configuration loader that loads all config files and provides helper functions.

**Helper Functions:**
- `VJGM.Config.Get(category, key, default)` - Get a config value with fallback
- `VJGM.Config.Set(category, key, value)` - Set a config value at runtime
- `VJGM.Config.GetPreset(presetName)` - Get a wave preset by name
- `VJGM.Config.ListPresets()` - List all available wave presets

### 2. `spawner_config.lua`
Main configuration for the spawner system.

**Spawner Settings:**
- `DefaultWaveInterval` - Default time between waves (default: 30 seconds)
- `DefaultNPCClass` - Default NPC class if none specified (default: "npc_vj_test_human")
- `SpawnHeightOffset` - Height offset above spawn point (default: 10 units)
- `DefaultCleanupOnComplete` - Auto-remove NPCs when wave completes (default: false)
- `DefaultNPCHealth` - Default NPC health if not specified (default: 100)
- `DebugMode` - Enable debug messages (default: true)
- `ConsolePrefix` - Prefix for console messages (default: "[VJGM]")
- `TimerPrefix` - Prefix for timer names (default: "VJGM_Wave_")
- `CleanupPrefix` - Prefix for cleanup callbacks (default: "VJGM_Cleanup_")
- `MaxActiveWaves` - Maximum simultaneous active waves (default: 10)
- `AutoInitialize` - Auto-initialize on server start (default: true)
- `ShowVJBaseWarning` - Show warning if VJ Base not detected (default: true)

**Spawn Point Settings:**
- `DefaultGroupName` - Default spawn point group name (default: "default")
- `DefaultAngle` - Default spawn angle (default: Angle(0, 0, 0))
- `DefaultRadius` - Default radius for radial spawn points (default: 500)
- `DefaultRadialCount` - Default number of points in radial pattern (default: 8)
- `DefaultEntityClass` - Default entity class to import spawns from (default: "info_player_start")

**Customizer Settings:**
- `EnableHealthCustomization` - Enable health customization (default: true)
- `EnableWeaponCustomization` - Enable weapon customization (default: true)
- `EnableModelCustomization` - Enable model customization (default: true)
- `EnableVJBaseCustomization` - Enable VJ Base settings (default: true)

**VJ Base Integration:**
- `DefaultFaction` - Default VJ Base faction (default: "VJ_FACTION_ANTLION")
- `DefaultCallForHelp` - Default call for help behavior (default: true)
- `DefaultCanWander` - Default wandering behavior (default: true)
- `DefaultSightDistance` - Default sight distance (default: 10000)
- `DefaultHearingCoef` - Default hearing coefficient (default: 1.0)
- `DefaultMeleeDistance` - Default melee distance (default: 0)

### 3. `wave_presets.lua`
Pre-configured wave templates for common scenarios.

**Available Presets:**
- `Basic` - Simple two-wave test configuration
- `CloneWarsRepublic` - Clone trooper assault waves (3 waves, escalating)
- `CloneWarsSeparatist` - Separatist droid waves (2 waves, mixed units)
- `HordeMode` - Increasing difficulty waves (4 waves, growing numbers)

**Usage:**
```lua
-- Get a preset
local config = VJGM.Config.GetPreset("CloneWarsRepublic")

-- Start the wave
VJGM.NPCSpawner.StartWave(config)
```

## Customization Guide

### Example: Changing Default Values

Edit `spawner_config.lua`:
```lua
-- Change default wave interval to 45 seconds
DefaultWaveInterval = 45,

-- Change default NPC class to your Clone Trooper
DefaultNPCClass = "npc_vj_swrp_clone_trooper",

-- Increase max active waves
MaxActiveWaves = 20,

-- Disable debug messages
DebugMode = false,
```

### Example: Adding Custom Presets

Edit `wave_presets.lua` and add your preset:
```lua
VJGM.Config.WavePresets.MyCustomWave = {
    waves = {
        {
            npcs = {
                {
                    class = "npc_vj_my_custom_npc",
                    count = 10,
                    customization = {
                        health = 200,
                        weapons = {"weapon_vj_custom"}
                    }
                }
            },
            spawnPointGroup = "custom_group",
            interval = 25
        }
    },
    defaultInterval = 25,
    cleanupOnComplete = true
}
```

Then use it:
```lua
local config = VJGM.Config.GetPreset("MyCustomWave")
VJGM.NPCSpawner.StartWave(config)
```

### Example: Runtime Configuration Changes

Change config values during gameplay:
```lua
-- Increase max waves at runtime
VJGM.Config.Set("Spawner", "MaxActiveWaves", 50)

-- Change default faction
VJGM.Config.Set("VJBase", "DefaultFaction", "VJ_FACTION_PLAYER")

-- Disable VJ Base warning
VJGM.Config.Set("Spawner", "ShowVJBaseWarning", false)
```

## Best Practices

1. **Backup Before Editing** - Always backup config files before making changes
2. **Test Changes** - Test configuration changes on a local server first
3. **Use Presets** - Create presets for different event types instead of hardcoding
4. **Version Control** - Keep track of config changes for easy rollback
5. **Document Custom Presets** - Add comments explaining custom wave presets
6. **Server-Specific** - Different servers can have different config values

## Troubleshooting

**Problem:** Changes not taking effect
- **Solution:** Restart the server or use `lua_reloadents` command

**Problem:** Waves not spawning
- **Solution:** Check `DefaultNPCClass` is a valid VJ Base NPC class

**Problem:** Console spam
- **Solution:** Set `DebugMode = false` in spawner_config.lua

**Problem:** Preset not found
- **Solution:** Use `VJGM.Config.ListPresets()` to see available presets

## Integration with Other Systems

The config system is designed to work seamlessly with other modules:

```lua
-- In your custom script
local spawnOffset = VJGM.Config.Get("Spawner", "SpawnHeightOffset", 10)
local faction = VJGM.Config.Get("VJBase", "DefaultFaction", "VJ_FACTION_ANTLION")
```

This ensures consistent behavior across all modules while allowing easy customization.
