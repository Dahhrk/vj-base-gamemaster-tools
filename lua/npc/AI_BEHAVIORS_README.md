# AI Behaviors System

Advanced AI enhancements for VJ Base NPCs in the VJGM (VJ Base Gamemaster Tools) system.

## Features

The AI Behaviors system provides context-aware, intelligent behaviors for spawned NPCs:

### 1. Cover-Seeking Behavior
- NPCs automatically seek cover when under fire or at low health
- Evaluates cover quality based on:
  - Protection from enemy fire
  - Proximity to current position
  - Elevation advantages
  - Nearby ally presence
- Configurable health thresholds and check intervals

### 2. Target Prioritization
- Intelligent target selection based on multiple factors:
  - Distance to target
  - Threat level (players, medics, and heavy units prioritized)
  - Target health
  - Line of sight availability
- Automatic re-evaluation at configurable intervals
- VJ Base faction-aware targeting

### 3. Dynamic Combat States
NPCs transition between combat states based on battlefield conditions:

- **Aggressive**: High health, allies nearby - increased damage and movement
- **Defensive**: Moderate threat - seeks cover, reduced movement
- **Retreat**: Low health or overwhelmed - fallback with cover seeking
- **Suppressed**: Under heavy fire - reduced accuracy and mobility

Each state applies appropriate modifiers to movement speed, accuracy, and behavior.

### 4. Group Communication
- Squad members share information:
  - Enemy sightings
  - Low ammo alerts
  - Injury reports
  - Backup requests
- Coordinated responses (covering fire, flanking)
- Squad leader priority communication
- Configurable communication ranges

### 5. Expanded Weapon Logic
- Ammo management and tracking
- Intelligent reload timing
- Seek cover while reloading
- Conservative fire when low on ammo
- Fire discipline (avoid friendly fire, controlled bursts)
- Suppressive fire capabilities

## Usage

### Basic Integration

Enable AI behaviors when spawning NPCs:

```lua
local waveConfig = {
    waves = {
        {
            npcs = {
                {
                    class = "npc_vj_test_human",
                    count = 5,
                    customization = {
                        health = 100,
                        vjbase = {
                            faction = "VJ_FACTION_PLAYER",
                            squad = "alpha_squad"
                        }
                    },
                    -- Enable AI behaviors
                    aiOptions = {
                        coverSeeking = true,
                        targetPriority = true,
                        combatStates = true,
                        groupComm = true,
                        weaponLogic = true
                    }
                }
            },
            spawnPointGroup = "spawn_group",
            interval = 0
        }
    }
}

VJGM.NPCSpawner.StartWave(waveConfig)
```

### Selective Features

Enable only specific AI features:

```lua
aiOptions = {
    coverSeeking = true,    -- Only cover-seeking
    targetPriority = true   -- Only smart targeting
    -- Other features disabled
}
```

### Enable for Existing NPC

```lua
VJGM.AIBehaviors.EnableForNPC(npc, {
    coverSeeking = true,
    combatStates = true
})
```

## Configuration

All AI behaviors are configurable in `lua/npc/config/ai_config.lua`:

### Cover-Seeking Settings
```lua
VJGM.Config.CoverSeeking = {
    Enabled = true,
    MaxCoverDistance = 1000,
    HealthThreshold = 0.7,
    CheckInterval = 3.0,
    -- ... more settings
}
```

### Target Prioritization Settings
```lua
VJGM.Config.TargetPrioritization = {
    Enabled = true,
    UpdateInterval = 2.0,
    DistanceWeight = 0.4,
    ThreatWeight = 0.3,
    -- ... more settings
}
```

### Combat States Settings
```lua
VJGM.Config.CombatStates = {
    Enabled = true,
    Aggressive = {
        HealthThreshold = 0.7,
        DamageMultiplier = 1.15,
        -- ... more settings
    },
    Defensive = { /* ... */ },
    Retreat = { /* ... */ },
    Suppressed = { /* ... */ }
}
```

### Group Communication Settings
```lua
VJGM.Config.GroupCommunication = {
    Enabled = true,
    MaxRange = 2000,
    AlertOnEnemySighted = true,
    ShareTargetInfo = true,
    -- ... more settings
}
```

### Weapon Logic Settings
```lua
VJGM.Config.WeaponLogic = {
    Enabled = true,
    AmmoManagement = {
        ReloadThreshold = 0.3,
        CoverDuringReload = true,
        -- ... more settings
    },
    FireDiscipline = { /* ... */ },
    SuppressiveFire = { /* ... */ }
}
```

## Testing Commands

The system includes comprehensive testing commands (admin only):

```
vjgm_list_ai_npcs          - List all AI-enabled NPCs
vjgm_test_ai_cover         - Test cover-seeking behavior
vjgm_test_ai_target        - Test target prioritization
vjgm_test_ai_states        - Test combat states
vjgm_test_ai_comm          - Test group communication
vjgm_test_ai_full          - Test all AI features together
```

## Test Scenarios

Pre-configured test scenarios are available in `lua/npc/config/ai_test_config.lua`:

- **CoverSeekingTest**: Tests cover-seeking under fire
- **TargetPriorityTest**: Tests target selection with mixed threats
- **CombatStatesTest**: Tests state transitions under different conditions
- **GroupCommunicationTest**: Tests squad coordination
- **FullAITest**: Comprehensive test of all features

## VJ Base Compatibility

The AI Behaviors system is designed to work seamlessly with VJ Base SNPCs:

- Uses VJ Base's faction system for ally/enemy detection
- Compatible with VJ Base movement and pathfinding
- Integrates with VJ Base weapon systems
- Respects VJ Base NPC relationships
- Works with existing VJ Base customizations

## Minimal Override Approach

The system follows a minimal override philosophy:

1. **Non-invasive**: AI behaviors are opt-in per NPC
2. **Hook-based**: Uses existing VJ Base hooks where possible
3. **Modular**: Each feature can be enabled/disabled independently
4. **Configuration-driven**: All parameters in config files
5. **No core modifications**: Works alongside existing NPC behavior

## Examples

See `lua/npc/ai_examples.lua` for detailed usage examples:

1. Basic AI-enhanced NPC spawning
2. Selective AI features
3. Role-based squads with AI
4. Defensive scenarios
5. Enabling AI for existing NPCs
6. Custom AI configuration
7. Full battle scenarios

## Performance Considerations

- AI updates run at configurable intervals (default 0.5s)
- Efficient ally/enemy detection with caching
- Cover searching uses sampling, not exhaustive search
- Timers are cleaned up when NPCs are removed
- Group communication uses range-based filtering

## Requirements

- VJ Base addon (https://steamcommunity.com/sharedfiles/filedetails/?id=131759821)
- Server-side only (no client requirements)
- Compatible with existing VJGM modules

## Architecture

```
ai_behaviors.lua           - Main AI behavior logic
config/ai_config.lua       - Configuration parameters
config/ai_test_config.lua  - Test scenarios
ai_examples.lua            - Usage examples
testing_tools.lua          - Testing commands (updated)
dynamic_spawner.lua        - Integration hook (minimal changes)
```

## Future Enhancements

Potential future additions:

- Formation maintenance
- Tactical flanking coordination
- Advanced patrol patterns
- Dynamic difficulty adjustment
- Learning from player tactics
- Vehicle crew AI coordination

## Troubleshooting

### NPCs not using AI behaviors
- Ensure `aiOptions` is set in NPC configuration
- Check that AI system is enabled: `VJGM.Config.AIBehaviors.Enabled = true`
- Verify VJ Base is installed and loaded

### NPCs stuck or not moving
- Increase `UpdateInterval` if performance is an issue
- Check that spawn points have valid navigation
- Ensure VJ Base pathfinding is working

### Debug Mode
Enable debug output:
```lua
VJGM.Config.AIBehaviors.DebugMode = true
VJGM.Config.AIBehaviors.VisualDebug = true  -- Visual indicators
```

## Credits

Part of the VJ Base Gamemaster Tools project.
Designed for Garry's Mod event management and dynamic battles.
