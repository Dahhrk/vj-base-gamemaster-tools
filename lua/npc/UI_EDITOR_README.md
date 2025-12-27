# UI Editor & Visualization System

## Overview
The VJGM UI Editor provides an interactive, visual interface for gamemasters to manage and configure game events in real-time. The system includes both 2D GUI panels and 3D world-space visualization.

## Features

### 1. Enhanced Wave Visualization
- **Visual Wave Cards**: Each active wave is displayed as a card with:
  - Color-coded status indicators (green for active, red for inactive)
  - Progress bars showing wave completion
  - Real-time NPC count
  - Quick action buttons (Pause/Resume, Stop)
  
- **Statistics Dashboard**: Live summary showing:
  - Total active waves
  - Total NPCs spawned
  - Number of active waves
  
- **Auto-refresh**: Wave status updates automatically

### 2. 3D World Visualization
The visualizer provides in-game 3D markers and overlays:

#### Spawn Point Markers
- Blue vertical beams marking spawn points
- Ground circles showing spawn radius
- Distance-based fade for better performance
- Group-based organization

#### NPC Markers
- Color-coded faction indicators above NPCs
- Real-time health bars
- Visible up to 3000 units away
- Faction colors:
  - Green: Friendly/Player faction
  - Red: Hostile/Enemy faction
  - Orange: Neutral faction

### 3. Wave Builder
Quick wave creation interface with:
- NPC class selection
- Spawn count configuration
- Health customization
- Spawn group selection
- Preset wave templates

### 4. Spawn Point Editor
Visual spawn point management:
- Create radial spawn patterns
- Import from map entities
- 3D visualization toggle
- Group management
- Clear and list functions

## Usage

### Opening the Control Panel
```lua
-- In-game console command
vjgm_panel
```
Or bind to a key in Garry's Mod settings.

### Console Commands

#### Panel Controls
- `vjgm_panel` - Open main control panel
- `vjgm_monitor` - Open floating wave monitor

#### Visualization Controls
- `vjgm_visualizer_toggle` - Toggle all 3D visualization
- `vjgm_visualizer_spawns` - Toggle spawn point markers
- `vjgm_visualizer_npcs` - Toggle NPC health/faction markers
- `vjgm_visualizer_request_spawns` - Refresh spawn point data

#### Wave Management
- `vjgm_wave_pause <waveID>` - Pause a specific wave
- `vjgm_wave_resume <waveID>` - Resume a paused wave
- `vjgm_wave_stop <waveID>` - Stop a specific wave
- `vjgm_wave_stop_all` - Stop all active waves

## Control Panel Tabs

### Active Waves Tab
Displays all currently active waves with:
- Visual cards for each wave
- Progress indicators
- Quick control buttons
- Statistics summary

**How to use:**
1. Click "Refresh" to update wave list
2. Use individual wave controls to pause/resume/stop
3. Use "Stop All" to end all waves immediately

### Wave Builder Tab
Create waves quickly without writing code:

**How to use:**
1. Enter NPC class (e.g., `npc_vj_test_human`)
2. Set spawn count
3. Configure health
4. Select spawn group
5. Click "Spawn Wave"

**Preset Buttons:**
- Basic Wave - Simple test wave
- Role Squad Wave - Squad with different roles
- Vehicle Wave - Wave with vehicles and crew

### Spawn Points Tab
Manage spawn point locations:

**Creating Radial Spawns:**
1. Enter group name
2. Set radius (100-5000 units)
3. Set number of points
4. Click "Create at Player Position"

**Importing from Map:**
1. Enter entity class (e.g., `info_player_start`)
2. Click "Import Spawns"

**Visualization:**
1. Click "Toggle Visualizer" to enable 3D view
2. Click "Toggle Spawn Markers" to show/hide markers
3. Click "Refresh Visualization" to update display

### Settings Tab
Access quick commands and visualization controls:
- Help commands
- Wave status
- Role and vehicle lists
- Visualization toggles

## 3D Visualization System

### Enabling Visualization
The 3D visualizer must be explicitly enabled:
1. Open Control Panel → Settings tab
2. Click "Toggle All Visualization"
3. OR use console: `vjgm_visualizer_toggle`

### Spawn Point Visualization
When enabled, you'll see:
- Blue vertical beams at each spawn point
- Ground circles indicating spawn area
- Markers fade with distance (max 5000 units)

### NPC Visualization
Shows real-time NPC information:
- Colored dots above NPCs indicating faction
- Health bars below faction indicator
- Automatically filters by distance

## Network Architecture

### Client-Server Communication
The UI system uses Garry's Mod's networking to sync data:

**Server → Client:**
- `VJGM_WaveListUpdate` - Active wave data
- `VJGM_SpawnPointData` - Spawn point locations

**Client → Server:**
- `VJGM_RequestWaveList` - Request wave updates
- `VJGM_RequestSpawnPointData` - Request spawn locations
- `VJGM_SpawnQuickWave` - Create new wave
- `VJGM_CreateRadialSpawns` - Create spawn pattern
- `VJGM_ImportSpawns` - Import from entities

## Performance Considerations

### Optimization Features
1. **Distance-based culling**: Markers only render within range
2. **Update intervals**: Auto-refresh uses configurable intervals
3. **Lazy updates**: Visualization only updates when visible
4. **Network throttling**: Data sent only when requested

### Recommended Settings
For best performance:
- Keep spawn point count under 100 per group
- Use visualization only when needed
- Disable NPC markers if spawning 50+ NPCs
- Auto-refresh interval: 1-2 seconds (configurable in config)

## Configuration

### GUI Controller Settings
Located in `lua/npc/config/spawner_config.lua`:

```lua
VJGM.Config.GUIController = {
    Enabled = true,
    MonitorUpdateInterval = 1,  -- Seconds between updates
    AdminOnly = true,           -- Require admin access
    ShowNPCHealthBars = true,
    MaxNPCsInMonitor = 50,
}
```

### Customization
You can customize:
- Colors in wave cards (edit `CreateWaveCard` function)
- Visualization distance limits (in `ui_visualizer.lua`)
- Update intervals (in config files)
- UI layout (in `gui_controller.lua`)

## Access Control
By default, UI features require admin access:
- Only admins can open control panels
- Only admins can create/modify waves
- Only admins can use visualization

To change: Set `AdminOnly = false` in config (not recommended for public servers)

## Troubleshooting

### Panel Won't Open
- Ensure you're an admin: Check with `!admin` or similar
- Check console for errors
- Verify config: `GUIController.Enabled` should be `true`

### Visualization Not Showing
- Enable visualizer: `vjgm_visualizer_toggle`
- Request spawn data: `vjgm_visualizer_request_spawns`
- Check you're within range of spawn points (5000 units)
- Verify spawn points exist: `vjgm_list_spawns default`

### Wave Cards Not Updating
- Click "Refresh" button manually
- Check network connection (multiplayer)
- Verify waves are actually running: `vjgm_wave_status`

### NPC Markers Missing
- Toggle NPC markers: `vjgm_visualizer_npcs`
- Check distance (max 3000 units)
- Ensure NPCs are spawned and alive

## Examples

### Example 1: Quick Wave Spawn
1. Open panel: `vjgm_panel`
2. Go to "Wave Builder" tab
3. Enter class: `npc_vj_test_human`
4. Set count: 10
5. Click "Spawn Wave"
6. Go to "Active Waves" tab to monitor

### Example 2: Create Spawn Pattern
1. Open panel: `vjgm_panel`
2. Go to "Spawn Points" tab
3. Stand where you want the center
4. Set radius: 500
5. Set points: 8
6. Click "Create at Player Position"
7. Click "Toggle Visualizer" to see beams

### Example 3: Monitor Ongoing Event
1. Start some waves (via code or builder)
2. Open panel: `vjgm_panel`
3. View "Active Waves" tab
4. Watch progress bars and NPC counts
5. Pause/resume waves as needed
6. Use "Stop All" if event needs to end

## Advanced Features

### Custom Wave Cards
The wave card system can be extended to show:
- Custom wave types
- Different color schemes per faction
- Additional statistics
- Wave-specific controls

Edit `VJGM.GUIController.CreateWaveCard()` function to customize.

### Integration with Other Systems
The UI system integrates with:
- Dynamic Spawner (wave management)
- Spawn Points (location management)
- Role-Based NPCs (squad visualization)
- Vehicle Support (vehicle wave display)
- AI Behaviors (behavior indicators - future)

## Future Enhancements
Planned features:
- Wave templates library
- Drag-and-drop wave building
- Timeline view for staged events
- Heat maps for spawn density
- NPC path visualization
- Formation editor
- Event recording/playback

## API for Developers

### Creating Custom Visualizations
```lua
-- CLIENT
hook.Add("PostDrawTranslucentRenderables", "MyCustomViz", function()
    if VJGM.UIVisualizer.IsEnabled() then
        -- Your 3D rendering code here
        cam.Start3D()
            -- Draw custom markers
        cam.End3D()
    end
end)
```

### Adding Custom Wave Card Elements
```lua
-- Modify CreateWaveCard function
local customLabel = vgui.Create("DLabel", card)
customLabel:SetPos(15, 95)
customLabel:SetSize(150, 18)
customLabel:SetText("Custom: " .. waveData.customField)
```

### Network Custom Data
```lua
-- SERVER
util.AddNetworkString("MyCustomData")
net.Start("MyCustomData")
net.WriteString("data")
net.Send(ply)

-- CLIENT
net.Receive("MyCustomData", function()
    local data = net.ReadString()
    -- Handle data
end)
```

## Credits
Part of the VJ Base Gamemaster Tools suite.
Compatible with VJ Base NPC addon.

## Support
For issues or questions:
1. Check console for error messages
2. Verify all requirements are installed
3. Check configuration files
4. Ensure you have admin access
