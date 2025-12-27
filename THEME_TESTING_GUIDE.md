# Onyx UI Framework Theme System - Testing Guide

## Overview
This document provides testing instructions for the new light/dark theme capability implemented in the Onyx UI Framework.

## What Was Implemented

### 1. Core Theme System (`onyx_init.lua`)
- **Theme Definitions**: Two complete color schemes (dark and light)
- **Theme Functions**:
  - `Onyx.SetTheme(themeName)` - Switch to a specific theme
  - `Onyx.GetTheme()` - Get current theme name
  - `Onyx.ToggleTheme()` - Toggle between themes
  - `Onyx.LoadThemePreference()` - Load saved theme from cookies
- **Hook System**: `OnyxThemeChanged` hook triggered when theme changes
- **Persistence**: Theme preference saved in browser cookies

### 2. Component Updates
All Onyx components now support real-time theme switching:
- `OnyxPanel` - Updates background and border colors
- `OnyxButton` - Updates text, background, and hover colors
- `OnyxSlider` - Updates track, fill, thumb, and text colors
- `OnyxTabs` - Updates tab bar and active tab highlighting
- `OnyxMinimap` - Updates background and grid colors
- `OnyxTimeline` - Updates background, timeline, and marker colors

Each component:
- Registers a hook listener for `OnyxThemeChanged`
- Implements `OnThemeChanged()` method to update colors
- Cleans up hook on removal via `OnRemove()`

### 3. New Components
- **OnyxThemeToggle** (`theme_toggle.lua`) - A button component that toggles themes
  - Displays moon icon (☾) in dark theme
  - Displays sun icon (☼) in light theme
  - Smooth hover animations
  - Sound feedback on interaction

### 4. Demo Tool
- **Onyx Theme Demo** (`onyx_theme_demo.lua`) - A comprehensive demo tool
  - Shows all Onyx components in action
  - Includes theme toggle button
  - Displays current color palette
  - Provides theme system documentation
  - Command: `vjgm_theme_demo`

## Manual Testing Instructions

### Prerequisites
1. Garry's Mod must be installed
2. The addon must be loaded in the game
3. Must have admin access for most tools

### Testing Steps

#### 1. Test Theme Demo Tool
```lua
-- In Garry's Mod console
vjgm_theme_demo
```

**Expected Results:**
- Window opens with title "Onyx UI Framework - Theme Demo"
- Theme toggle button (☼/☾) visible in top-right corner
- Three tabs visible: "Components", "Colors", "Info"
- Default theme is dark (dark background, light text)

#### 2. Test Theme Toggle
**Actions:**
1. Click the theme toggle button (☼ or ☾)

**Expected Results:**
- Theme switches from dark to light (or vice versa)
- All visible components update their colors immediately
- No flickering or lag
- Theme toggle icon changes (☼ ↔ ☾)
- Console shows: `[Onyx] Theme changed to: light` (or dark)

#### 3. Test Component Updates
**Components Tab:**
1. Observe OnyxPanel components - background should change
2. Hover over buttons - hover effects should use new theme colors
3. Move sliders - colors should match new theme
4. All text should be readable in both themes

**Colors Tab:**
1. Review color swatches
2. Verify all colors match the theme definition
3. Check RGB values are displayed correctly

#### 4. Test Theme Persistence
**Actions:**
1. Set theme to light
2. Close the demo window
3. Reopen with `vjgm_theme_demo`

**Expected Results:**
- Window opens with light theme (your last selection)
- Theme preference was saved in cookies

**Alternative Test:**
1. Set theme to light
2. Close Garry's Mod completely
3. Restart and run `vjgm_theme_demo`
4. Should still be in light theme

#### 5. Test with Existing Tools

**Spawn Point Editor:**
```lua
vjgm_spawn_editor
```
**Expected:**
- Tool opens in current theme
- Can toggle theme while tool is open
- Minimap background changes with theme
- All panels and buttons update

**Wave Manager:**
```lua
vjgm_wave_manager
```
**Expected:**
- Tabs update with theme
- Cards and panels change colors
- Statistics displays remain readable

**Events Dashboard:**
```lua
vjgm_events_dashboard
```
**Expected:**
- Timeline updates colors
- All panels respond to theme changes
- Text remains readable in both themes

#### 6. Test Multiple Windows
**Actions:**
1. Open multiple tools: `vjgm_spawn_editor`, `vjgm_wave_manager`, `vjgm_theme_demo`
2. Toggle theme in any one of them

**Expected Results:**
- All open windows update simultaneously
- No window is left in the old theme
- All components across all windows respond to the change

## Color Schemes Reference

### Dark Theme (Default)
- Primary: Steel Blue (70, 130, 180)
- Secondary: Cornflower Blue (100, 149, 237)
- Background: Dark Gray (35, 35, 40)
- Surface: Medium Gray (45, 45, 50)
- Border: Light Gray (60, 60, 65)
- Text: Off White (240, 240, 240)
- TextDim: Dim Text (180, 180, 180)

### Light Theme
- Primary: Google Blue (66, 133, 244)
- Secondary: Google Green (52, 168, 83)
- Background: Light Gray (248, 249, 250)
- Surface: White (255, 255, 255)
- Border: Border Gray (218, 220, 224)
- Text: Almost Black (32, 33, 36)
- TextDim: Dim Gray (95, 99, 104)

## Known Limitations

1. **Garry's Mod Environment Only**: This is a Garry's Mod Lua addon and can only be tested within the game
2. **No Automated Tests**: Due to the nature of Garry's Mod UI, automated testing is not feasible
3. **Manual Testing Required**: Visual verification is necessary to ensure proper theme application

## Troubleshooting

### Theme doesn't change
- Check console for error messages
- Verify `Onyx` global table exists
- Ensure component files loaded successfully

### Theme doesn't persist
- Check browser cookie settings in Garry's Mod
- Verify cookie.Set/Get functions are available

### Components don't update
- Check if components properly registered theme change hooks
- Look for errors in console during theme switch
- Verify component is still valid when theme changes

## API Usage Examples

### For Tool Developers

Adding theme toggle to your tool:
```lua
-- Add to any frame or panel
local themeToggle = vgui.Create("OnyxThemeToggle", myFrame)
themeToggle:SetSize(30, 30)
themeToggle:SetPos(myFrame:GetWide() - 40, 5)
```

Making custom components theme-aware:
```lua
function PANEL:Init()
    -- ... other init code ...
    
    -- Listen for theme changes
    self.themeHook = "MyComponent_ThemeChange_" .. tostring(self)
    hook.Add("OnyxThemeChanged", self.themeHook, function()
        if IsValid(self) then
            self:OnThemeChanged()
        else
            hook.Remove("OnyxThemeChanged", self.themeHook)
        end
    end)
end

function PANEL:OnThemeChanged()
    -- Update your component's colors
    self.myColor = Onyx.Colors.Primary
end

function PANEL:OnRemove()
    hook.Remove("OnyxThemeChanged", self.themeHook)
end
```

## Success Criteria

The implementation is successful if:
- ✅ Theme can be toggled between light and dark
- ✅ All Onyx components update colors when theme changes
- ✅ Theme preference persists across sessions
- ✅ Multiple open tools update simultaneously
- ✅ No console errors during theme switching
- ✅ All text remains readable in both themes
- ✅ Visual consistency maintained across all components
