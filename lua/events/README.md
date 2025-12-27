# Event Management Systems

This directory contains event orchestration and management systems for dynamic gameplay events.

## Events Dashboard

**Command:** `vjgm_events_dashboard`

Complete event orchestration interface with timeline visualization for managing dynamic gameplay events.

### Features

#### Event Timeline
- Visual timeline showing event phases
- Drag to jump to specific time
- Color-coded event phases
- Real-time progress indicator

#### Environmental Effects
Trigger atmospheric effects:
- Fog, Rain, Fire, Explosions, Lightning
- One-click activation
- Clear all effects option

#### Wave Triggers
Quick spawn buttons for different wave types:
- Light, Standard, Heavy, Boss waves
- Instant deployment

#### Event Modifications
Real-time adjustments:
- Difficulty slider (1-10)
- Dynamic event parameters

#### Analytics Panel with Enhanced Minimap
Live event statistics and visualization:
- Active events count
- Total NPCs spawned
- Player participation
- Event duration
- **Interactive minimap with real-time event markers**
- **Support for 100+ markers with intelligent clustering**
- **Zoom and pan controls for detailed viewing**

#### Event Logs
Chronological event history:
- Time-stamped entries
- Event type categorization
- Detailed descriptions

### Usage

```lua
-- Open the dashboard
vjgm_events_dashboard

-- Or programmatically
VJGM.EventsDashboard.Open()
```

### Triggering Events Programmatically

```lua
-- Trigger an environmental effect
VJGM.EventsDashboard.TriggerEffect("fog")

-- Trigger a wave
VJGM.EventsDashboard.TriggerWave("Heavy Wave")

-- Set difficulty
VJGM.EventsDashboard.SetDifficulty(8)
```

### Network Messages

- `VJGM_TriggerEffect` - Trigger environmental effect (Client → Server)
- `VJGM_TriggerWave` - Trigger wave spawn (Client → Server)
- `VJGM_SetDifficulty` - Adjust difficulty (Client → Server)

### Enhanced Minimap Features

The analytics panel now includes an interactive minimap with:

- **Dynamic Zoom**: Mouse wheel to zoom in/out (0.1x to 5.0x)
- **Pan Navigation**: Right-click and drag to pan across the map
- **Marker Clustering**: Automatically groups nearby markers when there are 20+ markers
- **Real-time Updates**: Markers update automatically every 0.1 seconds
- **High-Density Support**: Efficiently handles 100+ markers with clustering
- **Visual Cluster Indicators**: Shows count badges for clustered markers

## Integration with Onyx UI

The Events Dashboard uses the following Onyx components:
- **OnyxPanel** - Modern panels with shadows and borders
- **OnyxButton** - Animated buttons with hover effects
- **OnyxSlider** - Smooth value sliders with live updates
- **OnyxTimeline** - Event phase timeline with drag-to-seek
- **OnyxMinimap** - Enhanced interactive world map visualization

## Admin Access

The Events Dashboard requires admin privileges. Access is enforced both client-side and server-side.

## Future Enhancements

Planned features for the event system:
- Event recording and playback
- Custom event templates
- Multi-phase event sequencing
- Player objective integration
- Event performance analytics