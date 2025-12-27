--[[
    Onyx UI Framework - Core Initialization
    A modern UI library for Garry's Mod gamemaster tools
    
    Features:
    - Reusable UI components (panels, buttons, sliders)
    - Modern styling with animations
    - Minimap visualization support
    - Tab management system
    - Event handling framework
]]--

if CLIENT then
    
    Onyx = Onyx or {}
    Onyx.Version = "1.0.0"
    Onyx.Components = Onyx.Components or {}
    
    -- Color scheme
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
    
    -- Font definitions
    Onyx.Fonts = {
        Title = "OnyxTitle",
        Heading = "OnyxHeading",
        Body = "OnyxBody",
        Small = "OnyxSmall",
    }
    
    -- Initialize fonts
    function Onyx.InitializeFonts()
        surface.CreateFont("OnyxTitle", {
            font = "Roboto",
            size = 24,
            weight = 600,
            antialias = true,
        })
        
        surface.CreateFont("OnyxHeading", {
            font = "Roboto",
            size = 18,
            weight = 500,
            antialias = true,
        })
        
        surface.CreateFont("OnyxBody", {
            font = "Roboto",
            size = 14,
            weight = 400,
            antialias = true,
        })
        
        surface.CreateFont("OnyxSmall", {
            font = "Roboto",
            size = 12,
            weight = 400,
            antialias = true,
        })
    end
    
    -- Load components
    function Onyx.LoadComponents()
        local componentPath = "onyx_framework/components/"
        local components = {
            "panel.lua",
            "button.lua",
            "slider.lua",
            "tabs.lua",
            "minimap.lua",
            "timeline.lua",
        }
        
        for _, component in ipairs(components) do
            local filePath = "libraries/" .. componentPath .. component
            if file.Exists("lua/" .. filePath, "GAME") then
                include(filePath)
                print("[Onyx] Loaded component: " .. component)
            else
                print("[Onyx] Warning: Component not found: " .. component)
            end
        end
    end
    
    -- Initialize Onyx UI Framework
    function Onyx.Initialize()
        print("[Onyx UI Framework] Initializing v" .. Onyx.Version)
        Onyx.InitializeFonts()
        Onyx.LoadComponents()
        print("[Onyx UI Framework] Initialization complete")
    end
    
    -- Helper function to create rounded box
    function Onyx.DrawRoundedBox(x, y, w, h, radius, color)
        draw.RoundedBox(radius or 4, x, y, w, h, color)
    end
    
    -- Helper function to create gradient
    function Onyx.DrawGradient(x, y, w, h, color1, color2, vertical)
        if vertical then
            surface.SetDrawColor(color1)
            surface.DrawRect(x, y, w, h / 2)
            surface.SetDrawColor(color2)
            surface.DrawRect(x, y + h / 2, w, h / 2)
        else
            surface.SetDrawColor(color1)
            surface.DrawRect(x, y, w / 2, h)
            surface.SetDrawColor(color2)
            surface.DrawRect(x + w / 2, y, w / 2, h)
        end
    end
    
    -- Helper function for smooth animations
    function Onyx.Lerp(from, to, speed)
        return from + (to - from) * speed
    end
    
    -- Auto-initialize on load
    hook.Add("Initialize", "Onyx_Initialize", function()
        Onyx.Initialize()
    end)
    
end
