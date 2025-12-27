# Onyx UI Framework

A modern, component-based UI library for Garry's Mod gamemaster tools.

## Features

- **Modern Design**: Clean, professional UI components with smooth animations
- **Reusable Components**: Pre-built panels, buttons, sliders, tabs, and more
- **Interactive Minimap**: Visualize spawn points and entities on a world map
- **Event Timeline**: Display and manage event phases with visual feedback
- **Customizable**: Easy color schemes and styling options

## Components

### OnyxPanel
Enhanced panel with modern styling, shadows, and customizable borders.

```lua
local panel = vgui.Create("OnyxPanel")
panel:SetBackgroundColor(Onyx.Colors.Surface)
panel:SetBorderWidth(1)
panel:SetCornerRadius(8)
panel:SetShadow(true)
```

### OnyxButton
Modern button with hover effects and smooth animations.

```lua
local button = vgui.Create("OnyxButton")
button:SetButtonText("Click Me")
button:SetBackgroundColor(Onyx.Colors.Primary)
button:SetHoverColor(Onyx.Colors.Secondary)
button.DoClick = function()
    print("Button clicked!")
end
```

### OnyxSlider
Smooth slider with value display and customizable range.

```lua
local slider = vgui.Create("OnyxSlider")
slider:SetMin(0)
slider:SetMax(100)
slider:SetValue(50)
slider:SetDecimals(0)
slider:SetSuffix("%")
slider.OnValueChanged = function(self, value)
    print("New value:", value)
end
```

### OnyxTabs
Tab system for organizing content with smooth transitions.

```lua
local tabs = vgui.Create("OnyxTabs")
tabs:AddTab("Tab 1", "icon16/page.png", function(panel)
    -- Populate tab 1 content
end)
tabs:AddTab("Tab 2", "icon16/page.png", function(panel)
    -- Populate tab 2 content
end)
```

### OnyxMinimap
Interactive minimap for visualizing world positions and spawn points.

```lua
local minimap = vgui.Create("OnyxMinimap")
minimap:SetWorldBounds(Vector(-8192, -8192, 0), Vector(8192, 8192, 0))

-- Add markers
minimap:AddMarker(Vector(100, 200, 0), {
    color = Color(255, 100, 100),
    size = 10,
    shape = "circle",
    label = "Spawn Point"
})

-- Handle clicks
minimap.OnMapClicked = function(self, worldPos)
    print("Clicked at:", worldPos)
end
```

### OnyxTimeline
Event timeline for visualizing event phases and progression.

```lua
local timeline = vgui.Create("OnyxTimeline")
timeline:SetMaxTime(600)  -- 10 minutes

-- Add events
timeline:AddEvent("Wave 1", 0, 120, Onyx.Colors.Success)
timeline:AddEvent("Wave 2", 120, 240, Onyx.Colors.Warning)
timeline:AddEvent("Boss Fight", 240, 360, Onyx.Colors.Error)

-- Update current time
timeline:SetCurrentTime(60)
```

## Color Scheme

```lua
Onyx.Colors = {
    Primary = Color(70, 130, 180),      -- Steel Blue
    Secondary = Color(100, 149, 237),    -- Cornflower Blue
    Background = Color(35, 35, 40),      -- Dark Gray
    Surface = Color(45, 45, 50),         -- Medium Gray
    Border = Color(60, 60, 65),          -- Light Gray
    Text = Color(240, 240, 240),         -- Off White
    TextDim = Color(180, 180, 180),      -- Dim Text
    Success = Color(76, 175, 80),        -- Green
    Warning = Color(255, 152, 0),        -- Orange
    Error = Color(244, 67, 54),          -- Red
    Accent = Color(156, 39, 176),        -- Purple
}
```

## Fonts

```lua
Onyx.Fonts = {
    Title = "OnyxTitle",      -- 24pt, weight 600
    Heading = "OnyxHeading",  -- 18pt, weight 500
    Body = "OnyxBody",        -- 14pt, weight 400
    Small = "OnyxSmall",      -- 12pt, weight 400
}
```

## Integration

The Onyx UI Framework is automatically initialized when included in your addon. To use it in your gamemaster tools:

1. Include the framework in your addon
2. Use Onyx components in your UI code
3. Customize colors and styling as needed

## Examples

See the integration examples in:
- `lua/tools/spawn_point_editor.lua` - Spawn Point Editor with minimap
- `lua/tools/wave_manager.lua` - Wave Manager with tabs
- `lua/tools/events_dashboard.lua` - Dynamic Events Dashboard with timeline

## Version

Current version: 1.0.0

## License

Part of the vj-base-gamemaster-tools project.
