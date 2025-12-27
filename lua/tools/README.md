# VJGM Gamemaster Tools

Enhanced UI admin tools powered by the Onyx UI Framework for managing spawn points and waves.

These are admin-only tools accessible via console commands, designed for in-game editing and management.

## Available Tools

### 1. Spawn Point Editor
**Command:** `vjgm_spawn_editor`

Interactive spawn point management with visual feedback.

**Features:**
- Interactive minimap showing all spawn points
- Click on minimap to add new spawn points
- Color-coded spawn groups (default, north, south, east, west)
- Adjustable spawn radius with slider
- Real-time sync with server
- Add spawn points at crosshair location

**Usage:**
```lua
-- Open the editor
vjgm_spawn_editor

-- Or programmatically
VJGM.SpawnPointEditor.Open()
```

### 2. Wave Manager
**Command:** `vjgm_wave_manager`

Comprehensive wave control system with tabbed interface.

**Features:**
- **Active Waves Tab:** Monitor all running waves with visual cards
  - Real-time progress bars
  - NPC count displays
  - Pause/Resume/Stop/Restart controls
  - Wave statistics dashboard
  
- **Wave Templates Tab:** Quick access to preset wave configurations

- **Statistics Tab:** Wave analytics and performance metrics

- **Settings Tab:** Configure auto-refresh and manager preferences

**Usage:**
```lua
-- Open the manager
vjgm_wave_manager

-- Or programmatically
VJGM.WaveManager.Open()
```

## Integration with Onyx UI

All tools are built using the Onyx UI Framework for consistent styling and behavior.

### Onyx Components Used:
- **OnyxPanel:** Modern panels with shadows and borders
- **OnyxButton:** Animated buttons with hover effects
- **OnyxSlider:** Smooth value sliders with live updates
- **OnyxTabs:** Tabbed interface system
- **OnyxMinimap:** Interactive world map visualization

## Network Messages

### Spawn Point Editor
- `VJGM_AddSpawnPoint` - Add new spawn point (Client → Server)
- `VJGM_RequestSpawnPoints` - Request spawn data (Client → Server)
- `VJGM_SpawnPointsData` - Send spawn data (Server → Client)

### Wave Manager
- `VJGM_ToggleWave` - Pause/Resume wave (Client → Server)
- `VJGM_StopWave` - Stop wave (Client → Server)
- `VJGM_RestartWave` - Restart wave (Client → Server)
- `VJGM_RequestWaveData` - Request wave data (Client → Server)
- `VJGM_WaveData` - Send wave data (Server → Client)

## Admin Access

All tools require admin privileges by default. This is enforced both client-side and server-side.

To check if a player is an admin:
```lua
if LocalPlayer():IsAdmin() then
    -- Player can use tools
end
```

## Examples

### Adding Spawn Points Programmatically
```lua
-- Add a spawn point at a specific position
local pos = Vector(100, 200, 0)
VJGM.SpawnPointEditor.AddSpawnPoint(pos)
```

### Custom Wave Control
```lua
-- Toggle a specific wave
VJGM.WaveManager.ToggleWave("wave_123")

-- Stop a wave
VJGM.WaveManager.StopWave("wave_123")

-- Restart a wave
VJGM.WaveManager.RestartWave("wave_123")
```

## Related Systems

For event orchestration and dynamic event management, see the Events Dashboard in `lua/events/events_dashboard.lua`.

## Future Features

Planned enhancements for future releases:

### Player/NPC Interaction Manager
- Real-time player tracking
- NPC behavior monitoring
- Interaction analytics
- Communication logs

### Objective/Checkpoint System
- Objective creation and management
- Checkpoint placement
- Progress tracking
- Reward management

## Troubleshooting

### Tools don't open
- Ensure you have admin privileges
- Check console for error messages
- Verify Onyx UI framework is loaded

### Minimap doesn't show spawn points
- Click "Refresh Spawn Points" button
- Ensure spawn points exist in the system
- Check network messages are being received

### Wave controls don't work
- Verify waves are running in the system
- Check server console for errors
- Ensure proper network string registration

## Dependencies

- Garry's Mod
- VJ Base (optional but recommended)
- Onyx UI Framework (included)

## License

Part of the vj-base-gamemaster-tools project.