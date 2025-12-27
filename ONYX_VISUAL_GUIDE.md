# Onyx UI Framework - Visual Design Guide

This document describes the visual appearance and user experience of the Onyx UI Framework and the three gamemaster tools.

## Color Palette

The Onyx UI Framework uses a modern, professional color scheme designed for readability and visual hierarchy:

```
Primary Colors:
- Steel Blue (#4682B4)     - Primary actions, highlights
- Cornflower Blue (#6495ED) - Hover states, secondary elements

Background Colors:
- Dark Gray (#232328)      - Main background
- Medium Gray (#2D2D32)    - Surface panels
- Light Gray (#3C3C41)     - Borders, separators

Text Colors:
- Off White (#F0F0F0)      - Primary text
- Dim Text (#B4B4B4)       - Secondary text

Semantic Colors:
- Green (#4CAF50)          - Success, active states
- Orange (#FF9800)         - Warnings, paused states
- Red (#F44336)            - Errors, danger actions
- Purple (#9C27B0)         - Accent, special features
```

## Typography

All UI elements use the Roboto font family with different weights and sizes:

- **Title**: 24pt, Weight 600 - Main headings
- **Heading**: 18pt, Weight 500 - Section headers
- **Body**: 14pt, Weight 400 - Standard text, buttons
- **Small**: 12pt, Weight 400 - Labels, descriptions

## Component Visual Specifications

### OnyxPanel
```
Appearance:
┌─────────────────────────────────┐
│                                 │  Shadow: Subtle black shadow (alpha 100-150)
│         Panel Content           │  Background: Medium Gray (#2D2D32)
│                                 │  Border: Optional 1px Light Gray
│                                 │  Corner Radius: 4-8px
└─────────────────────────────────┘

Hover Effect: Shadow alpha increases to 150
```

### OnyxButton
```
Normal State:
┌─────────────────┐
│  Button Text    │  Background: Steel Blue (#4682B4)
└─────────────────┘  Text: Off White (#F0F0F0)
                     Corner Radius: 4px

Hover State:
┌─────────────────┐
│  Button Text    │  Background: Cornflower Blue (#6495ED)
└─────────────────┘  Smooth color transition (0.2s lerp)

Pressed State:
┌───────────────┐    Scale: 95% (smooth animation)
│  Button Text  │    Visual "press down" effect
└───────────────┘
```

### OnyxSlider
```
┌─────────────────────────────────┐ Value: 50%
│━━━━━━━━━━━●────────────────────│
└─────────────────────────────────┘

Components:
- Track (background): Light Gray, 4px height
- Fill (left of thumb): Steel Blue
- Thumb: Cornflower Blue circle, 16px diameter
- Value Display: Right-aligned, shows "50%" with suffix
```

### OnyxTabs
```
┌────────┬────────┬────────┬─────────────────────┐
│ Tab 1  │ Tab 2  │ Tab 3  │                     │
├────────┴────────┴────────┴─────────────────────┤
│                                                 │
│              Tab Content Area                   │
│                                                 │
└─────────────────────────────────────────────────┘

Active Tab: Steel Blue background
Inactive Tab: Medium Gray background
Hover: Cornflower Blue background
```

### OnyxMinimap
```
┌─────────────────────────────────────────┐
│     N                                   │
│     ↑                                   │
│                                         │
│         ●  Spawn Point (Blue)          │
│                                         │
│              △                          │
│           Player                        │
│                                         │
│  Grid lines: 512 unit spacing          │
│  Background: Dark Gray (#232328)       │
│  Border: Light Gray                    │
└─────────────────────────────────────────┘

Features:
- Blue beam markers at spawn points
- Triangle player indicator (Cornflower Blue)
- Grid overlay (60% opacity)
- Click to add markers
- World bounds: -8192 to +8192
```

### OnyxTimeline
```
Time:  0:00      1:00      2:00      3:00      4:00
       │         │         │         │         │
       ├─────────┼─────────┼─────────┼─────────┤
       ██████░░░░│░░░░░███████████░░░│░░░░░███
       └─────┘   └──────────┘        └─────┘
       Phase 1   Phase 2             Phase 3

Components:
- Horizontal track line (Light Gray)
- Colored event blocks (Green, Orange, Red, Purple)
- Current time indicator (vertical Steel Blue line)
- Time labels at intervals
- Click to jump to time
```

## Tool Visual Designs

### 1. Spawn Point Editor

```
┌────────────────── Spawn Point Editor ──────────────────┐
│                                                          │
│  ┌─── Minimap (600px) ───┐  ┌─── Controls (400px) ───┐ │
│  │                        │  │ Spawn Point Controls   │ │
│  │  Grid Pattern          │  │                        │ │
│  │      ● ● ●             │  │ Spawn Group:           │ │
│  │    Markers             │  │ [  default      ▼]     │ │
│  │        △               │  │                        │ │
│  │      Player            │  │ Spawn Radius:          │ │
│  │    ● ●                 │  │ ━━━━━●─────  100 units │ │
│  │  ●                     │  │                        │ │
│  │                        │  │ [Add at Crosshair]     │ │
│  │                        │  │ [Delete Nearest]       │ │
│  │                        │  │ [Refresh Points]       │ │
│  │                        │  │                        │ │
│  └────────────────────────┘  │ Info:                  │ │
│                               │ Click minimap to add   │ │
│                               │ spawn points. Use      │ │
│                               │ groups to organize.    │ │
│                               └────────────────────────┘ │
└──────────────────────────────────────────────────────────┘

Visual Features:
- Left: Interactive minimap with grid and markers
- Right: Control panel with dropdowns, sliders, buttons
- Color-coded spawn groups (blue, red, green, yellow, magenta)
- Real-time marker updates
```

### 2. Wave Manager

```
┌──────────────────── Wave Manager ──────────────────────┐
│                                                          │
│  ┌─ Active Waves ─┬─ Templates ─┬─ Statistics ─┬─ Settings ─┐
│  │                                                        │
│  │  Total Active Waves: 3  │  Total NPCs: 45            │
│  │                                                        │
│  │  ┌─────────────────────── Wave Card ──────────┐      │
│  │  │ Wave 1                                      │      │
│  │  │ Progress: 5/10 | NPCs: 15 | Status: Active │      │
│  │  │ ████████████████░░░░░░░░░░░░ 50%            │      │
│  │  │ [Pause] [Stop] [Restart]                   │      │
│  │  └────────────────────────────────────────────┘      │
│  │                                                        │
│  │  ┌─────────────────────── Wave Card ──────────┐      │
│  │  │ Wave 2                                      │      │
│  │  │ Progress: 8/12 | NPCs: 20 | Status: Active │      │
│  │  │ ████████████████████████░░░░ 67%            │      │
│  │  │ [Pause] [Stop] [Restart]                   │      │
│  │  └────────────────────────────────────────────┘      │
│  │                                                        │
│  │  ┌─────────────────────── Wave Card ──────────┐      │
│  │  │ Wave 3                                      │      │
│  │  │ Progress: 3/15 | NPCs: 10 | Status: Paused │      │
│  │  │ ██████░░░░░░░░░░░░░░░░░░░░░░ 20%            │      │
│  │  │ [Resume] [Stop] [Restart]                  │      │
│  │  └────────────────────────────────────────────┘      │
│  └────────────────────────────────────────────────────────┘
└──────────────────────────────────────────────────────────┘

Visual Features:
- Tab navigation at top
- Statistics header with totals
- Visual wave cards with:
  - Colored status bar (green=active, orange=paused)
  - Progress bars showing wave completion
  - Control buttons for each wave
  - NPC count and status display
```

### 3. Dynamic Events Dashboard

```
┌───────────── Dynamic Events Dashboard ─────────────────┐
│                                                          │
│  Event Timeline:                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 0:00    1:00    2:00    3:00    4:00    5:00     │  │
│  │  │       │       │       │       │       │        │  │
│  │  ██████░░│░░░░███████░░░│░░░███████░░░░░│        │  │
│  │  │  Prep │ Wave 1│Inter │Wave 2 │ Boss  │        │  │
│  │  ────────┼───────┼──────┼───────┼───────┤        │  │
│  │          │       │      ↑ Current Time            │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌─── Controls ──────────┐  ┌─── Analytics ─────────┐ │
│  │ Environmental Effects │  │ Active Events:    3   │ │
│  │ [Fog] [Rain] [Fire]   │  │ ┌───────────────────┐ │ │
│  │ [Expl][Light][Clear]  │  │ │                   │ │ │
│  │                       │  │ │ Total NPCs:   45  │ │ │
│  │ Wave Triggers         │  │ │ ┌───────────────┐ │ │ │
│  │ [Light] [Standard]    │  │ │ │               │ │ │ │
│  │ [Heavy] [Boss]        │  │ │ │ Players:   8  │ │ │ │
│  │                       │  │ │ │ ┌───────────┐ │ │ │ │
│  │ Difficulty:           │  │ │ │ │           │ │ │ │ │
│  │ ━━━━━●──── 5          │  │ │ │ │ Time: 2:30│ │ │ │ │
│  └───────────────────────┘  │ └─┴─┴───────────┴─┴─┴─┘ │
│                              └───────────────────────────┘ │
│  Event Logs:                                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Time  │ Type        │ Description                │  │
│  │────────────────────────────────────────────────│  │
│  │ 0:00  │ System      │ Dashboard initialized     │  │
│  │ 0:15  │ Wave        │ Light wave spawned        │  │
│  │ 1:30  │ Environment │ Fog effect activated      │  │
│  │ 2:45  │ Wave        │ Standard wave spawned     │  │
│  └──────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘

Visual Features:
- Timeline at top showing event phases
- Current time indicator (vertical blue line)
- Left panel: Effect and wave trigger buttons in grid
- Right panel: Stat cards with large numbers
- Bottom: Scrollable event log with timestamps
- Color-coded event phases
```

## Animation Specifications

### Button Hover Animation
- Duration: 0.2 seconds
- Effect: Smooth color transition from Primary to Secondary
- Implementation: Onyx.Lerp() with 0.2 factor

### Button Press Animation
- Duration: 0.3 seconds
- Effect: Scale from 100% to 95% and back
- Implementation: Scale transform with lerp

### Panel Shadow Animation
- Duration: Gradual (0.1 lerp factor)
- Effect: Alpha fade from 100 to 150 on hover
- Implementation: Smooth alpha interpolation

### Slider Drag
- Duration: Immediate (follows mouse)
- Effect: Thumb position updates in real-time
- Value display updates simultaneously

### Tab Switch
- Duration: Instant
- Effect: Content panels show/hide
- Active tab background changes to Primary color

## Interaction Patterns

### Minimap Interaction
1. **Click**: Add spawn point at clicked world position
2. **Hover**: Show grid coordinates (future enhancement)
3. **Scroll**: Zoom in/out (future enhancement)

### Timeline Interaction
1. **Click**: Jump to clicked time position
2. **Drag**: Scrub through timeline (future enhancement)
3. **Event Hover**: Show event details (future enhancement)

### Wave Card Interaction
1. **Pause Button**: Toggle wave state
2. **Stop Button**: Terminate wave
3. **Restart Button**: Reset and restart wave
4. **Progress Bar**: Visual feedback only (non-interactive)

## Accessibility Considerations

### Color Contrast
- All text meets WCAG AA standards
- Primary text: White on dark backgrounds (21:1 ratio)
- Button text: White on colored backgrounds (4.5:1+ ratio)

### Interactive Elements
- All buttons have minimum 40px height
- Click targets are minimum 30px for precision
- Hover states provide clear feedback
- Sound feedback on button clicks

### Visual Hierarchy
- Title: 24pt, bold
- Headings: 18pt, medium weight
- Body: 14pt, regular weight
- Small: 12pt for non-critical info

## Responsive Behavior

### Panel Sizes
- Spawn Point Editor: 1000x700px
- Wave Manager: 900x600px
- Events Dashboard: 1100x700px

### Scaling
- All measurements use absolute pixels (Garry's Mod standard)
- Panels center on screen
- Content uses Dock() for responsive layout
- Scrollbars appear when content exceeds panel height

## Future Enhancements

Planned visual improvements:
- Custom icons for buttons
- Animated transitions between tabs
- Gradient backgrounds for panels
- Particle effects on timeline
- Heat map visualization for spawn density
- 3D world projection on minimap
- Zoom and pan controls
- Custom cursors for different tools
- Theme customization (light/dark modes)

---

This visual design guide provides developers and designers with a clear understanding of the Onyx UI Framework's appearance and behavior. All specifications are implemented in the component files under `libraries/onyx_framework/components/`.
