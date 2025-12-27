--[[
    Onyx UI Framework - Theme Toggle Component
    A button to toggle between light and dark themes
]]--

if CLIENT then
    
    local PANEL = {}
    
    function PANEL:Init()
        self:SetText("")
        self.cornerRadius = 4
        
        -- Icon symbols (Unicode characters for theme representation)
        self.darkIcon = "☾"  -- Moon (shown when in light theme - click to go dark)
        self.lightIcon = "☼"  -- Sun (shown when in dark theme - click to go light)
        
        -- Update appearance based on current theme
        self:UpdateAppearance()
        
        -- Listen for theme changes
        self.themeHook = "OnyxThemeToggle_ThemeChange_" .. tostring(self)
        hook.Add("OnyxThemeChanged", self.themeHook, function()
            if IsValid(self) then
                self:UpdateAppearance()
            else
                hook.Remove("OnyxThemeChanged", self.themeHook)
            end
        end)
    end
    
    function PANEL:UpdateAppearance()
        local isDark = Onyx.CurrentTheme == "dark"
        -- Show opposite icon to indicate what clicking will do
        -- In dark theme, show sun (☼) to indicate "switch to light"
        -- In light theme, show moon (☾) to indicate "switch to dark"
        self.currentIcon = isDark and self.lightIcon or self.darkIcon
        self.backgroundColor = Onyx.Colors.Surface
        self.hoverColor = Onyx.Colors.Primary
        self.textColor = Onyx.Colors.Text
        self.currentColor = self.backgroundColor
        self.isHovered = false
    end
    
    function PANEL:Paint(w, h)
        -- Smooth color transition
        self.currentColor = Color(
            Onyx.Lerp(self.currentColor.r, self.isHovered and self.hoverColor.r or self.backgroundColor.r, 0.2),
            Onyx.Lerp(self.currentColor.g, self.isHovered and self.hoverColor.g or self.backgroundColor.g, 0.2),
            Onyx.Lerp(self.currentColor.b, self.isHovered and self.hoverColor.b or self.backgroundColor.b, 0.2),
            255
        )
        
        -- Draw button background
        Onyx.DrawRoundedBox(0, 0, w, h, self.cornerRadius, self.currentColor)
        
        -- Draw icon
        draw.SimpleText(
            self.currentIcon,
            Onyx.Fonts.Heading,
            w / 2,
            h / 2,
            self.textColor,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
        
        -- Draw border
        surface.SetDrawColor(Onyx.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    function PANEL:OnCursorEntered()
        self.isHovered = true
        surface.PlaySound("ui/buttonrollover.wav")
    end
    
    function PANEL:OnCursorExited()
        self.isHovered = false
    end
    
    function PANEL:OnMousePressed(keyCode)
        if keyCode == MOUSE_LEFT then
            surface.PlaySound("ui/buttonclick.wav")
        end
    end
    
    function PANEL:OnMouseReleased(keyCode)
        if keyCode == MOUSE_LEFT then
            Onyx.ToggleTheme()
        end
    end
    
    function PANEL:OnRemove()
        hook.Remove("OnyxThemeChanged", self.themeHook)
    end
    
    vgui.Register("OnyxThemeToggle", PANEL, "DButton")
    
end
