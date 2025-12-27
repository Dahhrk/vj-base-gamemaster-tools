--[[
    Onyx Theme Demo Tool
    A demonstration tool for the Onyx UI Framework theme system
    Shows all components with a theme toggle button
]]--

if CLIENT then
    
    -- Load Onyx UI if not already loaded
    if not Onyx then
        include("libraries/onyx_framework/onyx_init.lua")
    end
    
    VJGM = VJGM or {}
    VJGM.OnyxThemeDemo = VJGM.OnyxThemeDemo or {}
    
    local activeDemo = nil
    
    --[[
        Open the Onyx Theme Demo
    ]]--
    function VJGM.OnyxThemeDemo.Open()
        -- Close existing demo
        if IsValid(activeDemo) then
            activeDemo:Close()
        end
        
        -- Create main frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(800, 600)
        frame:Center()
        frame:SetTitle("Onyx UI Framework - Theme Demo")
        frame:MakePopup()
        
        activeDemo = frame
        
        -- Theme toggle button in title bar
        local themeToggle = vgui.Create("OnyxThemeToggle", frame)
        themeToggle:SetSize(30, 30)
        themeToggle:SetPos(frame:GetWide() - 40, 5)
        
        -- Create main container
        local container = vgui.Create("DPanel", frame)
        container:Dock(FILL)
        container.Paint = function() end
        
        -- Create tabs
        local tabs = vgui.Create("OnyxTabs", container)
        tabs:Dock(FILL)
        
        -- Tab 1: Components Demo
        tabs:AddTab("Components", nil, function(panel)
            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:Dock(FILL)
            
            -- Panel demo
            local panelDemo = vgui.Create("OnyxPanel", scroll)
            panelDemo:Dock(TOP)
            panelDemo:DockMargin(10, 10, 10, 5)
            panelDemo:SetHeight(150)
            panelDemo:SetShadow(true)
            
            local panelLabel = vgui.Create("DLabel", panelDemo)
            panelLabel:SetText("OnyxPanel Component")
            panelLabel:SetFont(Onyx.Fonts.Heading)
            panelLabel:SetTextColor(Onyx.Colors.Text)
            panelLabel:Dock(TOP)
            panelLabel:DockMargin(10, 10, 10, 5)
            
            local panelDesc = vgui.Create("DLabel", panelDemo)
            panelDesc:SetText("Modern panel with shadow effects and customizable styling.")
            panelDesc:SetFont(Onyx.Fonts.Body)
            panelDesc:SetTextColor(Onyx.Colors.TextDim)
            panelDesc:Dock(TOP)
            panelDesc:DockMargin(10, 5, 10, 10)
            panelDesc:SetWrap(true)
            panelDesc:SetAutoStretchVertical(true)
            
            -- Button demo
            local buttonPanel = vgui.Create("OnyxPanel", scroll)
            buttonPanel:Dock(TOP)
            buttonPanel:DockMargin(10, 5, 10, 5)
            buttonPanel:SetHeight(120)
            
            local buttonLabel = vgui.Create("DLabel", buttonPanel)
            buttonLabel:SetText("OnyxButton Component")
            buttonLabel:SetFont(Onyx.Fonts.Heading)
            buttonLabel:SetTextColor(Onyx.Colors.Text)
            buttonLabel:Dock(TOP)
            buttonLabel:DockMargin(10, 10, 10, 5)
            
            local button1 = vgui.Create("OnyxButton", buttonPanel)
            button1:SetButtonText("Primary Button")
            button1:Dock(TOP)
            button1:DockMargin(10, 5, 10, 2)
            button1:SetHeight(35)
            button1.DoClick = function()
                chat.AddText(Color(100, 200, 255), "[Onyx] ", Color(255, 255, 255), "Primary button clicked!")
            end
            
            local button2 = vgui.Create("OnyxButton", buttonPanel)
            button2:SetButtonText("Success Button")
            button2:SetBackgroundColor(Onyx.Colors.Success)
            button2:SetHoverColor(Color(106, 205, 110))
            button2:Dock(TOP)
            button2:DockMargin(10, 2, 10, 5)
            button2:SetHeight(35)
            button2.DoClick = function()
                chat.AddText(Color(76, 175, 80), "[Onyx] ", Color(255, 255, 255), "Success button clicked!")
            end
            
            -- Slider demo
            local sliderPanel = vgui.Create("OnyxPanel", scroll)
            sliderPanel:Dock(TOP)
            sliderPanel:DockMargin(10, 5, 10, 5)
            sliderPanel:SetHeight(120)
            
            local sliderLabel = vgui.Create("DLabel", sliderPanel)
            sliderLabel:SetText("OnyxSlider Component")
            sliderLabel:SetFont(Onyx.Fonts.Heading)
            sliderLabel:SetTextColor(Onyx.Colors.Text)
            sliderLabel:Dock(TOP)
            sliderLabel:DockMargin(10, 10, 10, 5)
            
            local slider1 = vgui.Create("OnyxSlider", sliderPanel)
            slider1:SetMin(0)
            slider1:SetMax(100)
            slider1:SetValue(50)
            slider1:SetSuffix("%")
            slider1:Dock(TOP)
            slider1:DockMargin(10, 5, 100, 5)
            slider1:SetHeight(30)
            
            local slider2 = vgui.Create("OnyxSlider", sliderPanel)
            slider2:SetMin(0)
            slider2:SetMax(1000)
            slider2:SetValue(500)
            slider2:SetDecimals(0)
            slider2:Dock(TOP)
            slider2:DockMargin(10, 5, 100, 10)
            slider2:SetHeight(30)
        end)
        
        -- Tab 2: Color Palette
        tabs:AddTab("Colors", nil, function(panel)
            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:Dock(FILL)
            
            local paletteLabel = vgui.Create("DLabel", scroll)
            paletteLabel:SetText("Current Theme Color Palette")
            paletteLabel:SetFont(Onyx.Fonts.Heading)
            paletteLabel:SetTextColor(Onyx.Colors.Text)
            paletteLabel:Dock(TOP)
            paletteLabel:DockMargin(10, 10, 10, 10)
            
            -- Function to create color swatch
            local function CreateColorSwatch(parent, name, color)
                local swatch = vgui.Create("DPanel", parent)
                swatch:Dock(TOP)
                swatch:DockMargin(10, 5, 10, 5)
                swatch:SetHeight(50)
                swatch.Paint = function(self, w, h)
                    -- Color box
                    draw.RoundedBox(4, 0, 0, 60, h, color)
                    
                    -- Color name
                    draw.SimpleText(
                        name,
                        Onyx.Fonts.Body,
                        70,
                        10,
                        Onyx.Colors.Text,
                        TEXT_ALIGN_LEFT,
                        TEXT_ALIGN_TOP
                    )
                    
                    -- RGB values
                    local rgbText = string.format("RGB(%d, %d, %d)", color.r, color.g, color.b)
                    draw.SimpleText(
                        rgbText,
                        Onyx.Fonts.Small,
                        70,
                        30,
                        Onyx.Colors.TextDim,
                        TEXT_ALIGN_LEFT,
                        TEXT_ALIGN_TOP
                    )
                end
            end
            
            -- Create swatches for all colors
            CreateColorSwatch(scroll, "Primary", Onyx.Colors.Primary)
            CreateColorSwatch(scroll, "Secondary", Onyx.Colors.Secondary)
            CreateColorSwatch(scroll, "Background", Onyx.Colors.Background)
            CreateColorSwatch(scroll, "Surface", Onyx.Colors.Surface)
            CreateColorSwatch(scroll, "Border", Onyx.Colors.Border)
            CreateColorSwatch(scroll, "Text", Onyx.Colors.Text)
            CreateColorSwatch(scroll, "TextDim", Onyx.Colors.TextDim)
            CreateColorSwatch(scroll, "Success", Onyx.Colors.Success)
            CreateColorSwatch(scroll, "Warning", Onyx.Colors.Warning)
            CreateColorSwatch(scroll, "Error", Onyx.Colors.Error)
            CreateColorSwatch(scroll, "Accent", Onyx.Colors.Accent)
        end)
        
        -- Tab 3: Theme Info
        tabs:AddTab("Info", nil, function(panel)
            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:Dock(FILL)
            
            local infoPanel = vgui.Create("OnyxPanel", scroll)
            infoPanel:Dock(TOP)
            infoPanel:DockMargin(10, 10, 10, 10)
            infoPanel:SetHeight(400)
            
            local title = vgui.Create("DLabel", infoPanel)
            title:SetText("Theme System Information")
            title:SetFont(Onyx.Fonts.Heading)
            title:SetTextColor(Onyx.Colors.Text)
            title:Dock(TOP)
            title:DockMargin(10, 10, 10, 5)
            
            local infoText = [[
Onyx UI Framework now supports light and dark themes!

Features:
• Toggle between light and dark themes using the theme button (☼/☾)
• All components automatically update when theme changes
• Theme preference is saved in browser cookies
• Real-time color updates across all open tools

Available Themes:
• Dark Theme (default) - Modern dark color scheme
• Light Theme - Clean light color scheme

Usage:
• Click the theme toggle button to switch themes
• Theme preference persists across sessions
• All Onyx components respond to theme changes
• Compatible with all existing tools (Spawn Editor, Wave Manager, Events Dashboard)

API:
• Onyx.SetTheme(themeName) - Set theme by name
• Onyx.GetTheme() - Get current theme name
• Onyx.ToggleTheme() - Toggle between themes
• Hook: OnyxThemeChanged - Triggered when theme changes
            ]]
            
            local info = vgui.Create("DLabel", infoPanel)
            info:SetText(infoText)
            info:SetFont(Onyx.Fonts.Body)
            info:SetTextColor(Onyx.Colors.TextDim)
            info:Dock(FILL)
            info:DockMargin(10, 5, 10, 10)
            info:SetWrap(true)
            info:SetAutoStretchVertical(true)
        end)
    end
    
    -- Console command to open demo
    concommand.Add("vjgm_theme_demo", function()
        VJGM.OnyxThemeDemo.Open()
    end)
    
end
