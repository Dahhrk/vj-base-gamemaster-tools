# OnyxMinimap Component Enhancements

## Overview

This document describes the enhancements made to the OnyxMinimap component to handle high-density marker scenarios with improved user experience through dynamic zoom, pan, intelligent clustering, and real-time updates.

## Enhanced Features

### 1. Dynamic Zoom Functionality

The minimap now supports smooth zoom controls for detailed viewing of specific areas.

**Implementation:**
- **Mouse Wheel Zoom**: Users can zoom in/out using the mouse wheel
- **Zoom Range**: 0.1x to 5.0x (configurable via `minZoom` and `maxZoom`)
- **Zoom Sensitivity**: Adjustable zoom speed (default: 0.1)
- **Center-Based Zoom**: Zooming occurs around the center of the view for intuitive navigation

**API:**
```lua
minimap:SetZoom(2.0)           -- Set zoom level
local zoom = minimap:GetZoom()  -- Get current zoom level
minimap:ResetView()             -- Reset zoom and pan to defaults
```

### 2. Pan/Drag Navigation

Users can navigate large maps by dragging the view with the mouse.

**Implementation:**
- **Right-Click Drag** or **Middle-Mouse Drag**: Pan the map view
- **World-Space Panning**: Pan offset is calculated in world coordinates
- **Smooth Dragging**: Real-time update during drag operation
- **Pan Persistence**: Pan state is maintained until reset

**API:**
```lua
minimap:SetPan(x, y)           -- Set pan offset
local x, y = minimap:GetPan()  -- Get current pan offset
```

### 3. Intelligent Marker Clustering

When dealing with high-density markers (20+ markers), the system automatically groups nearby markers to reduce visual clutter.

**Implementation:**
- **Automatic Clustering**: Activates when marker count exceeds 20
- **Proximity-Based Grouping**: Markers within `clusterRadius` pixels are grouped
- **Visual Cluster Indicators**: 
  - Circular badges show cluster size
  - Size scales with marker count (15px to 40px)
  - Inner circle displays the count number
- **Dynamic Updates**: Clusters rebuild when zoom changes or markers are modified
- **Performance Optimization**: Uses dirty flag system to minimize recalculation

**Cluster Visualization:**
- Orange outer circle with semi-transparency
- Dark inner circle for contrast
- White text showing marker count
- Single markers display normally

**API:**
```lua
minimap:SetClusteringEnabled(true)  -- Enable/disable clustering
minimap:SetClusterRadius(50)        -- Set clustering radius (10-100 pixels)
```

### 4. Real-Time Marker Updates

Support for dynamically updating markers without clearing and recreating them.

**Implementation:**
- **UpdateMarker**: Modify existing marker properties (position, color, size, shape, label)
- **BatchUpdateMarkers**: Update multiple markers efficiently in one operation
- **GetMarker**: Query marker state by ID
- **Dirty Flag System**: Only rebuild clusters when necessary
- **Auto-Update Hook**: `OnAutoUpdate()` callback for periodic updates

**API:**
```lua
-- Update a single marker
minimap:UpdateMarker("marker_1", {
    pos = Vector(100, 200, 0),
    color = Color(255, 0, 0),
    size = 12
})

-- Batch update
minimap:BatchUpdateMarkers({
    {id = "marker_1", options = {pos = Vector(100, 200, 0)}},
    {id = "marker_2", options = {color = Color(0, 255, 0)}}
})

-- Query marker
local marker = minimap:GetMarker("marker_1")

-- Auto-update callback
minimap.OnAutoUpdate = function(self)
    -- Called every updateInterval seconds (default: 0.1s)
    -- Update markers based on game state
end
```

### 5. Enhanced Coordinate System

Updated `WorldToScreen` and `ScreenToWorld` functions to properly handle zoom and pan transformations.

**Features:**
- Center-based coordinate system
- Zoom scaling around viewport center
- Pan offset integration
- Proper Y-axis flipping for screen coordinates

### 6. Performance Optimizations

**Dirty Flag System:**
- Markers are only reclustered when necessary (zoom change, marker updates)
- Reduces computational overhead during rendering

**Viewport Culling:**
- Markers outside the viewport (with buffer) are not rendered
- Improves performance with very large marker counts

**Think Hook:**
- Handles panning smoothly during drag operations
- Manages auto-update timer efficiently

## Analytics Dashboard Integration

The Events Dashboard now includes an enhanced minimap in the analytics panel.

**Location:** `lua/events/events_dashboard.lua`

**Features:**
- 300px height minimap section
- Pre-populated with 120+ sample markers for testing
- 5 marker clusters demonstrating clustering functionality
- Real-time marker updates every 0.1 seconds
- Automatic clustering for high-density areas

**Sample Data:**
- 120 evenly distributed markers of various types
- 5 clusters with 15 markers each (75 additional markers)
- Total: ~195 markers demonstrating high-density scenario

## Testing Tool

A dedicated testing tool has been created for validating all enhanced features.

**Location:** `lua/tools/minimap_test.lua`

**Command:** `vjgm_minimap_test`

**Features:**
- Interactive test window with controls
- Populate markers: 25, 50, 100, 200 options
- Zoom slider (0.1x to 5.0x)
- Reset view button
- Toggle clustering on/off
- Cluster radius slider (10-100px)
- Clear all markers
- Add cluster (20 markers)
- Click-to-add markers
- Visual instructions

## Usage Examples

### Basic Setup
```lua
local minimap = vgui.Create("OnyxMinimap", parent)
minimap:Dock(FILL)
minimap:SetWorldBounds(Vector(-8192, -8192, 0), Vector(8192, 8192, 0))
```

### Adding Markers
```lua
minimap:AddMarker(Vector(100, 200, 0), {
    id = "spawn_1",
    color = Color(255, 100, 100),
    shape = "circle",
    label = "Spawn",
    size = 10
})
```

### High-Density Scenario
```lua
-- Add 100 markers
for i = 1, 100 do
    local angle = (i / 100) * math.pi * 2
    local radius = math.random(2000, 6000)
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius
    
    minimap:AddMarker(Vector(x, y, 0), {
        id = "marker_" .. i,
        color = Onyx.Colors.Primary,
        shape = "circle",
        size = 8
    })
end

-- Clustering will automatically activate
```

### Real-Time Updates
```lua
minimap.OnAutoUpdate = function(self)
    -- Update marker positions based on NPC locations
    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if IsValid(npc) then
            self:UpdateMarker(npc:EntIndex(), {
                pos = npc:GetPos()
            })
        end
    end
end
```

## Code Structure

**File:** `libraries/onyx_framework/components/minimap.lua` (461 lines)

**Key Functions:**
- `Init()` - Initialize component with enhanced settings
- `Paint(w, h)` - Main rendering function
- `Think()` - Handle panning and auto-updates
- `DrawMarkers(w, h)` - Render markers or clusters
- `DrawMarker(marker, x, y)` - Draw individual marker
- `DrawCluster(cluster, w, h)` - Draw cluster indicator
- `BuildClusters(w, h)` - Calculate marker clusters
- `WorldToScreen(pos, w, h)` - Convert world to screen coordinates
- `ScreenToWorld(x, y, w, h)` - Convert screen to world coordinates
- `OnMousePressed(keyCode)` - Handle click and drag start
- `OnMouseReleased(keyCode)` - Handle drag end
- `OnMouseWheeled(delta)` - Handle zoom
- `AddMarker(pos, options)` - Add new marker
- `UpdateMarker(id, options)` - Update existing marker
- `BatchUpdateMarkers(updates)` - Update multiple markers
- `RemoveMarker(id)` - Remove marker
- `ClearMarkers()` - Remove all markers
- `GetMarker(id)` - Query marker by ID
- `SetZoom(zoom)` / `GetZoom()` - Zoom control
- `SetPan(x, y)` / `GetPan()` - Pan control
- `ResetView()` - Reset zoom and pan
- `SetClusteringEnabled(enabled)` - Toggle clustering
- `SetClusterRadius(radius)` - Adjust cluster radius

## Directory Structure Corrections

**Issue Resolved:** The `events_dashboard.lua` was incorrectly placed in the `lua/tools/` directory.

**Correct Structure:**
- `lua/tools/` - Admin tools for editing (spawn editor, wave manager)
- `lua/events/` - Event orchestration systems (events dashboard)

**Changes Made:**
- Moved `events_dashboard.lua` from `tools/` to `events/`
- Updated `lua/tools/README.md` to document admin tools only
- Updated `lua/events/README.md` with complete event system documentation
- Updated main `README.md` with correct directory structure

## Performance Characteristics

**Marker Capacity:**
- Tested with 200+ markers
- Clustering activates at 20+ markers
- Performance optimized for 100-500 marker scenarios

**Clustering Efficiency:**
- O(n²) clustering algorithm (acceptable for < 500 markers)
- Dirty flag prevents unnecessary recalculation
- Only reclusters on zoom change or marker updates

**Update Frequency:**
- Default: 0.1 seconds (10 Hz)
- Configurable via `updateInterval`
- Dirty flag ensures efficient updates

## Browser Compatibility

This is a Garry's Mod addon using the Source engine's VGUI system. All features are implemented using Lua and GMod's drawing API.

## Future Enhancements

Potential improvements for future versions:

1. **Click-to-Expand Clusters**: Click on a cluster to zoom and expand
2. **Marker Filtering**: Filter markers by type/category
3. **Heat Maps**: Density visualization for spawn patterns
4. **Path Lines**: Connect related markers with lines
5. **Marker Search**: Find specific markers by ID or label
6. **Custom Marker Icons**: Support for image-based markers
7. **Minimap Overlay**: Semi-transparent overlay mode
8. **Spatial Indexing**: Quadtree for better clustering performance with 1000+ markers

## Related Documentation

- Main README: `README.md`
- Onyx Framework: `libraries/onyx_framework/README.md`
- Tools Documentation: `lua/tools/README.md`
- Events Documentation: `lua/events/README.md`
- Onyx Integration: `ONYX_INTEGRATION_SUMMARY.md`

## Changelog

**Version 2.0 - Enhanced Minimap**
- Added dynamic zoom with mouse wheel (0.1x to 5.0x)
- Added pan/drag navigation with right-click
- Implemented intelligent marker clustering for 20+ markers
- Added real-time marker update support
- Added batch update functionality
- Integrated enhanced minimap into Events Dashboard
- Created dedicated testing tool
- Fixed directory structure (moved events_dashboard to lua/events/)
- Updated all documentation

**Version 1.0 - Original**
- Basic minimap with static zoom
- Marker visualization (circle, square, diamond)
- World coordinate conversion
- Player marker
- Grid overlay
