# Onyx UI Framework - Theme System Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     Onyx UI Framework                           │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                  Theme System Core                        │ │
│  │                  (onyx_init.lua)                          │ │
│  │                                                           │ │
│  │  ┌─────────────┐    ┌──────────────┐                    │ │
│  │  │ Dark Theme  │    │ Light Theme  │                    │ │
│  │  │             │    │              │                    │ │
│  │  │ • Primary   │    │ • Primary    │                    │ │
│  │  │ • Secondary │    │ • Secondary  │                    │ │
│  │  │ • Background│    │ • Background │                    │ │
│  │  │ • Surface   │    │ • Surface    │                    │ │
│  │  │ • Border    │    │ • Border     │                    │ │
│  │  │ • Text      │    │ • Text       │                    │ │
│  │  │ • TextDim   │    │ • TextDim    │                    │ │
│  │  │ • Success   │    │ • Success    │                    │ │
│  │  │ • Warning   │    │ • Warning    │                    │ │
│  │  │ • Error     │    │ • Error      │                    │ │
│  │  │ • Accent    │    │ • Accent     │                    │ │
│  │  │ • GridColor │    │ • GridColor  │                    │ │
│  │  └─────────────┘    └──────────────┘                    │ │
│  │                                                           │ │
│  │  ┌────────────────────────────────────────────┐         │ │
│  │  │         Active Colors (Onyx.Colors)        │         │ │
│  │  │  Points to current theme (dark or light)   │         │ │
│  │  └────────────────────────────────────────────┘         │ │
│  │                                                           │ │
│  │  ┌────────────────────────────────────────────┐         │ │
│  │  │           Theme Management API              │         │ │
│  │  │  • SetTheme(name)                          │         │ │
│  │  │  • GetTheme()                              │         │ │
│  │  │  • ToggleTheme()                           │         │ │
│  │  │  • LoadThemePreference()                   │         │ │
│  │  └────────────────────────────────────────────┘         │ │
│  │                                                           │ │
│  │  ┌────────────────────────────────────────────┐         │ │
│  │  │    Hook: OnyxThemeChanged(themeName)       │         │ │
│  │  └────────────────────────────────────────────┘         │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                  Onyx Components                          │ │
│  │                                                           │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐│ │
│  │  │OnyxPanel │  │OnyxButton│  │OnyxSlider│  │OnyxTabs  ││ │
│  │  │          │  │          │  │          │  │          ││ │
│  │  │Listens to│  │Listens to│  │Listens to│  │Listens to││ │
│  │  │hook      │  │hook      │  │hook      │  │hook      ││ │
│  │  │          │  │          │  │          │  │          ││ │
│  │  │Updates   │  │Updates   │  │Updates   │  │Updates   ││ │
│  │  │colors    │  │colors    │  │colors    │  │colors    ││ │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘│ │
│  │                                                           │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────┐          │ │
│  │  │OnyxMini  │  │OnyxTime  │  │OnyxTheme     │          │ │
│  │  │map       │  │line      │  │Toggle        │          │ │
│  │  │          │  │          │  │              │          │ │
│  │  │Listens to│  │Listens to│  │Triggers      │          │ │
│  │  │hook      │  │hook      │  │theme change  │          │ │
│  │  │          │  │          │  │              │          │ │
│  │  │Updates   │  │Updates   │  │Shows icon    │          │ │
│  │  │colors    │  │colors    │  │☼ / ☾         │          │ │
│  │  └──────────┘  └──────────┘  └──────────────┘          │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                    Tools Using Onyx                       │ │
│  │                                                           │ │
│  │  ┌────────────┐  ┌────────────┐  ┌─────────────────┐   │ │
│  │  │ Spawn      │  │ Wave       │  │ Events          │   │ │
│  │  │ Editor     │  │ Manager    │  │ Dashboard       │   │ │
│  │  │            │  │            │  │                 │   │ │
│  │  │ Uses Onyx  │  │ Uses Onyx  │  │ Uses Onyx       │   │ │
│  │  │ components │  │ components │  │ components      │   │ │
│  │  │            │  │            │  │                 │   │ │
│  │  │ Auto theme │  │ Auto theme │  │ Auto theme      │   │ │
│  │  │ support    │  │ support    │  │ support         │   │ │
│  │  └────────────┘  └────────────┘  └─────────────────┘   │ │
│  │                                                           │ │
│  │  ┌────────────────────────────────────────┐             │ │
│  │  │      Onyx Theme Demo Tool              │             │ │
│  │  │  • Showcases all components            │             │ │
│  │  │  • Displays color palette              │             │ │
│  │  │  • Provides documentation              │             │ │
│  │  │  • Includes theme toggle               │             │ │
│  │  └────────────────────────────────────────┘             │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                  Persistence Layer                        │ │
│  │                                                           │ │
│  │  ┌────────────────────────────────────────────┐         │ │
│  │  │  Browser Cookies (via Garry's Mod cookie API)  │     │ │
│  │  │  • Cookie name: "onyx_theme"               │         │ │
│  │  │  • Values: "dark" or "light"               │         │ │
│  │  │  • Auto-loads on framework initialization  │         │ │
│  │  └────────────────────────────────────────────┘         │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow: Theme Change

```
User Action
    │
    ▼
┌─────────────────────┐
│ OnyxThemeToggle     │  User clicks theme toggle button
│ button clicked      │
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ Onyx.ToggleTheme()  │  Determines new theme (dark ↔ light)
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ Onyx.SetTheme(name) │  Validates theme, updates Onyx.Colors
└─────────────────────┘
    │
    ├──────────────────────┐
    │                      │
    ▼                      ▼
┌─────────────────┐   ┌──────────────────┐
│ cookie.Set()    │   │ hook.Run()       │  Triggers hook with theme name
│ "onyx_theme"    │   │ "OnyxThemeChanged"│
└─────────────────┘   └──────────────────┘
                           │
                           ▼
              ┌────────────────────────────┐
              │  All components listening  │
              │  to OnyxThemeChanged hook  │
              └────────────────────────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │Component1│ │Component2│ │Component3│
        │:OnTheme  │ │:OnTheme  │ │:OnTheme  │
        │Changed() │ │Changed() │ │Changed() │
        └──────────┘ └──────────┘ └──────────┘
              │            │            │
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │Updates   │ │Updates   │ │Updates   │
        │colors    │ │colors    │ │colors    │
        │from      │ │from      │ │from      │
        │Onyx.     │ │Onyx.     │ │Onyx.     │
        │Colors    │ │Colors    │ │Colors    │
        └──────────┘ └──────────┘ └──────────┘
              │            │            │
              └────────────┼────────────┘
                           ▼
                    ┌──────────────┐
                    │ Visual       │
                    │ Update       │
                    │ Complete     │
                    └──────────────┘
```

## Component Lifecycle with Theme Support

```
┌────────────────────────────────────────────────────┐
│            Component Creation                      │
└────────────────────────────────────────────────────┘
                     │
                     ▼
           ┌─────────────────┐
           │ PANEL:Init()    │
           └─────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
┌─────────────┐ ┌─────────┐ ┌──────────────────┐
│Set initial  │ │Register │ │Store unique      │
│colors from  │ │theme    │ │hook ID           │
│Onyx.Colors  │ │hook     │ │(instance-based)  │
└─────────────┘ └─────────┘ └──────────────────┘

┌────────────────────────────────────────────────────┐
│            During Component Lifetime               │
└────────────────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │ OnyxThemeChanged hook  │
        │ fires                  │
        └────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │ PANEL:OnThemeChanged() │
        └────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │ Update colors from     │
        │ Onyx.Colors            │
        └────────────────────────┘

┌────────────────────────────────────────────────────┐
│            Component Removal                       │
└────────────────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │ PANEL:OnRemove()       │
        └────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │ hook.Remove()          │
        │ cleanup                │
        └────────────────────────┘
```

## Key Design Principles

1. **Centralized Theme Storage**: All theme data in `Onyx.Themes`
2. **Active Color Reference**: `Onyx.Colors` points to current theme
3. **Hook-based Updates**: Components listen for `OnyxThemeChanged`
4. **Instance-specific Hooks**: Each component instance has unique hook ID
5. **Automatic Cleanup**: Hooks removed on component destruction
6. **Persistent Preferences**: Theme saved in cookies, loaded on init
7. **Graceful Fallbacks**: Invalid themes fallback to "dark"
8. **Performance**: Color objects updated in-place, not recreated
