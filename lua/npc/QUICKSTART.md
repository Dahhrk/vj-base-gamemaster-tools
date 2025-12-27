# Dynamic NPC Spawner - Quick Start Guide

This guide will help you get started with the Dynamic NPC Spawner for Clone Wars Roleplay.

## Prerequisites

1. **VJ Base** addon installed on your Garry's Mod server
   - Workshop ID: 131759821
   - https://steamcommunity.com/sharedfiles/filedetails/?id=131759821

2. Clone Wars NPC packs (or any VJ Base compatible NPCs)

3. This addon installed in your `garrysmod/addons/` folder

## Installation

1. Place the entire folder in your server's `addons` directory
2. Restart your server
3. The system will auto-initialize and be ready to use

## Basic Usage (5 Minutes to First Wave)

### Step 1: Register Spawn Points

In your map's Lua script or via console:

```lua
-- Option A: Create spawn points in a circle
local centerPos = Vector(0, 0, 0)  -- Replace with your position
VJGM.SpawnPoints.RegisterInRadius("frontline", centerPos, 500, 8)

-- Option B: Use existing map spawn points
VJGM.SpawnPoints.RegisterFromEntities("default", "info_player_start")

-- Option C: Manually place spawn points
VJGM.SpawnPoints.Register("attack", Vector(100, 200, 0), Angle(0, 90, 0))
```

### Step 2: Start a Wave

**Method A: Use a Preset**
```lua
-- Get Clone Wars Republic preset
local config = VJGM.Config.GetPreset("CloneWarsRepublic")

-- Start the wave
local waveID = VJGM.NPCSpawner.StartWave(config)
```

**Method B: Use the Builder**
```lua
local config = VJGM.WaveConfig.CreateBuilder()
    :SetDefaultInterval(30)
    :AddWave("frontline", 20)
    :AddNPCGroup("npc_vj_clone_trooper", 5, {
        health = 100,
        weapons = {"weapon_vj_dc15s"}
    })
    :Build()

VJGM.NPCSpawner.StartWave(config)
```

### Step 3: Monitor and Control

```lua
-- Check active waves
local waves = VJGM.NPCSpawner.GetActiveWaves()
print("Active waves: " .. #waves)

-- Get wave status
local status = VJGM.NPCSpawner.GetWaveStatus(waveID)
print("Wave " .. status.currentWave .. " of " .. status.totalWaves)

-- Stop a wave
VJGM.NPCSpawner.StopWave(waveID)
```

## Console Commands (For Testing)

These commands are available for admin testing:

```
vjgm_test_basic          - Test basic wave spawning
vjgm_test_clonewars      - Test Clone Wars preset
vjgm_stop_all            - Stop all active waves
vjgm_list_waves          - List all active waves
```

## Configuration

All configurable values are in `lua/npc/config/`:

### Quick Config Changes

Edit `lua/npc/config/spawner_config.lua`:

```lua
-- Change default wave interval
DefaultWaveInterval = 45,

-- Change default NPC class (replace with your Clone Trooper class)
DefaultNPCClass = "npc_vj_swrp_clone_trooper",

-- Disable debug messages
DebugMode = false,
```

### Adding Custom Wave Presets

Edit `lua/npc/config/wave_presets.lua`:

```lua
VJGM.Config.WavePresets.MyEvent = {
    waves = {
        {
            npcs = {
                {
                    class = "npc_vj_clone_trooper",
                    count = 10,
                    customization = {
                        health = 150,
                        weapons = {"weapon_vj_dc15a"},
                        vjbase = {
                            faction = "VJ_FACTION_PLAYER",
                            callForHelp = true,
                            squad = "alpha"
                        }
                    }
                }
            },
            spawnPointGroup = "default",
            interval = 30
        }
    },
    defaultInterval = 30,
    cleanupOnComplete = false
}
```

## Clone Wars Example Event

Here's a complete example for a Clone Wars battle:

```lua
-- Setup spawn points
local republicBase = Vector(1000, 0, 100)
local separatistBase = Vector(-1000, 0, 100)

VJGM.SpawnPoints.RegisterInRadius("republic", republicBase, 400, 6)
VJGM.SpawnPoints.RegisterInRadius("separatist", separatistBase, 400, 6)

-- Start Republic wave
local republicWave = VJGM.Config.GetPreset("CloneWarsRepublic")
local republicID = VJGM.NPCSpawner.StartWave(republicWave)

-- Start Separatist wave
local separatistWave = VJGM.Config.GetPreset("CloneWarsSeparatist")
local separatistID = VJGM.NPCSpawner.StartWave(separatistWave)

-- Monitor both waves
timer.Create("BattleMonitor", 5, 0, function()
    local repStatus = VJGM.NPCSpawner.GetWaveStatus(republicID)
    local sepStatus = VJGM.NPCSpawner.GetWaveStatus(separatistID)
    
    if repStatus and sepStatus then
        print("Republic: " .. repStatus.aliveNPCs .. " NPCs")
        print("Separatist: " .. sepStatus.aliveNPCs .. " NPCs")
    else
        timer.Remove("BattleMonitor")
    end
end)
```

## Common Scenarios

### Scenario 1: Defend the Base
```lua
-- Waves of enemies attacking a position
local attackWave = VJGM.WaveConfig.CreateBuilder()
    :SetDefaultInterval(45)
    :AddWave("entrance", 30)
    :AddNPCGroup("npc_vj_battle_droid", 8, {health = 80})
    :AddWave("entrance", 30)
    :AddNPCGroup("npc_vj_battle_droid", 12, {health = 80})
    :AddWave("entrance", 0)
    :AddNPCGroup("npc_vj_super_battle_droid", 5, {health = 200})
    :Build()

VJGM.NPCSpawner.StartWave(attackWave)
```

### Scenario 2: Reinforcements on Trigger
```lua
-- Call this when players reach a certain area
function SendReinforcements()
    local reinforcements = VJGM.Config.GetPreset("CloneWarsRepublic")
    VJGM.NPCSpawner.StartWave(reinforcements)
end

-- Hook to map trigger
hook.Add("PlayerEnteredZone", "ControlPoint", SendReinforcements)
```

### Scenario 3: Horde Mode
```lua
-- Use the horde preset
local hordeConfig = VJGM.Config.GetPreset("HordeMode")
VJGM.NPCSpawner.StartWave(hordeConfig)
```

## Troubleshooting

### NPCs Not Spawning
1. Check that spawn points are registered: `print(VJGM.SpawnPoints.GetCount("default"))`
2. Verify NPC class is correct and VJ Base is installed
3. Check console for error messages

### VJ Base Not Detected
- Install VJ Base from Steam Workshop
- Ensure VJ Base is loading before this addon
- Check console for the VJ Base detection message

### Waves Not Progressing
- Check wave configuration is valid
- Verify intervals are set correctly
- Look for timer-related errors in console

### Config Changes Not Applied
- Restart the server after editing config files
- Use `lua_reloadents` console command
- Check for Lua syntax errors in config files

## Advanced Topics

### VJ Base Settings

All VJ Base NPCs support these customization options:

```lua
vjbase = {
    faction = "VJ_FACTION_PLAYER",      -- NPC faction
    callForHelp = true,                  -- Call allies when attacked
    canWander = false,                   -- Allow wandering
    sightDistance = 10000,               -- How far NPC can see
    hearingCoef = 1.5,                   -- Hearing sensitivity
    meleeDistance = 100,                 -- Melee attack range
    squad = "alpha_squad"                -- Squad for coordination
}
```

### Performance Optimization

For large-scale battles:

1. Set `cleanupOnComplete = true` to remove NPCs after waves
2. Adjust `MaxActiveWaves` based on server performance
3. Use larger intervals between waves
4. Reduce NPC count in each wave

### Integration with Other Addons

The spawner can work with:
- DarkRP for roleplay events
- ULX/SAM for admin controls
- Custom map scripts
- Event management systems

## Next Steps

1. Read `lua/npc/README.md` for detailed module documentation
2. Read `lua/npc/config/README.md` for configuration details
3. Check `lua/npc/examples.lua` for more usage examples
4. Experiment with wave presets and customize them
5. Create your own presets for your server's events

## Support

- Check the documentation in `lua/npc/README.md`
- Review example code in `lua/npc/examples.lua`
- Consult VJ Base documentation for NPC-specific issues
- Check console output for error messages

## Credits

- VJ Base by Cpt. Hazama
- Dynamic NPC Spawner for Clone Wars Roleplay
- Compatible with Garry's Mod and VJ Base addons

Enjoy creating dynamic, engaging events for your players!
