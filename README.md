# vj-base-gamemaster-tools

Enhance your Garry's Mod events with "vj-base-gamemaster-tools"! This project provides tools to automate event management, create dynamic battles, and improve roleplay experiences. Perfect for Gamemasters aiming to host engaging and immersive gameplay, the tools are designed for flexibility and adaptability to suit various event styles.

## Features

### Core Systems
- **Dynamic NPC Spawner**: Sophisticated wave-based NPC spawning system
- **AI Behaviors**: Context-aware NPC behaviors with cover-seeking, target prioritization, and group communication
- **Role-Based NPCs**: Customizable NPC roles (assault, medic, heavy, sniper, etc.)
- **Vehicle Support**: Integrate vehicles into spawned waves
- **Wave Templates**: Pre-configured wave scenarios for quick deployment

### Enhanced UI Tools (Onyx Framework)
The project now includes the **Onyx UI Framework** - a modern, component-based UI library that powers three advanced gamemaster tools:

#### 1. Spawn Point Editor (`vjgm_spawn_editor`)
- Interactive minimap for visualizing spawn points in world space
- Click-to-add spawn point functionality
- Color-coded spawn groups (default, north, south, east, west)
- Adjustable spawn radius with smooth sliders
- Real-time synchronization with server
- Add spawn points at crosshair location

#### 2. Wave Manager (`vjgm_wave_manager`)
- Tabbed interface for comprehensive wave control
- **Active Waves Tab**: Monitor running waves with visual cards showing progress bars and NPC counts
- Control buttons: Pause/Resume, Stop, Restart
- Real-time statistics dashboard
- Wave templates browser
- Auto-refresh functionality

#### 3. Dynamic Events Dashboard (`vjgm_events_dashboard`)
- Event timeline with visual phase representation
- Environmental effects controls (Fog, Rain, Fire, Explosions, Lightning)
- Quick wave trigger buttons
- Real-time difficulty adjustment
- Live analytics panel
- Event logging system

### Onyx UI Components
- **OnyxPanel**: Modern panels with shadows and animations
- **OnyxButton**: Smooth hover effects and press animations
- **OnyxSlider**: Interactive value sliders with live display
- **OnyxTabs**: Organized tab system for multi-section interfaces
- **OnyxMinimap**: Interactive world map visualization
- **OnyxTimeline**: Event phase timeline with drag-to-seek

## Quick Start

### Console Commands
```
vjgm_panel              - Open main control panel
vjgm_spawn_editor       - Open Spawn Point Editor (Onyx UI)
vjgm_wave_manager       - Open Wave Manager (Onyx UI)
vjgm_events_dashboard   - Open Dynamic Events Dashboard (Onyx UI)
```

### Basic Usage
1. Open the main control panel: `vjgm_panel`
2. Navigate to the "Enhanced Tools" tab to access Onyx-powered interfaces
3. Or use direct commands to launch specific tools

## Documentation

- **Main Documentation**: See `IMPLEMENTATION_SUMMARY.md` for AI behaviors
- **UI Editor Documentation**: See `UI_EDITOR_IMPLEMENTATION.md` for UI features
- **Onyx Framework**: See `libraries/onyx_framework/README.md`
- **Tools Documentation**: See `lua/tools/README.md`

## Requirements

- Garry's Mod
- VJ Base (optional but recommended for full NPC functionality)
- Admin privileges (required for all enhanced tools)

## Project Structure

```
vj-base-gamemaster-tools/
├── libraries/
│   └── onyx_framework/          # Onyx UI Framework
│       ├── components/          # UI components (buttons, panels, minimap, etc.)
│       └── onyx_init.lua        # Framework initialization
├── lua/
│   ├── npc/                     # NPC and wave management
│   │   ├── dynamic_spawner.lua  # Core spawning system
│   │   ├── ai_behaviors.lua     # AI behavior system
│   │   ├── gui_controller.lua   # Main GUI controller (now with Onyx integration)
│   │   └── config/              # Configuration files
│   ├── tools/                   # Enhanced gamemaster tools
│   │   ├── spawn_point_editor.lua    # Onyx-powered spawn editor
│   │   ├── wave_manager.lua          # Onyx-powered wave manager
│   │   └── events_dashboard.lua      # Onyx-powered events dashboard
│   ├── events/                  # Event management (future)
│   └── players/                 # Player interaction (future)
```

## Future Features

- Player/NPC Interaction Manager
- Objective/Checkpoint System
- Advanced formation controls
- Event recording and playback
- Heat maps for spawn density analysis

## License

See LICENSE file for details.