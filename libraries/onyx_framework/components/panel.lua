--[[
    Onyx UI Framework - Panel Component
    Enhanced DPanel with modern styling and animations
]]--

if CLIENT then
    
    local PANEL = {}
    
    function PANEL:Init()
        self.backgroundColor = Onyx.Colors.Surface
        self.borderColor = Onyx.Colors.Border
        self.borderWidth = 0
        self.cornerRadius = 4
        self.padding = 8
        self.shadow = true
        self.shadowAlpha = 0
        self.targetShadowAlpha = 100
        
        -- Listen for theme changes
        self.themeHook = "OnyxPanel_ThemeChange_" .. tostring(self)
        hook.Add("OnyxThemeChanged", self.themeHook, function()
            if IsValid(self) then
                self:OnThemeChanged()
            else
                hook.Remove("OnyxThemeChanged", self.themeHook)
            end
        end)
    end
    
    function PANEL:OnThemeChanged()
        -- Update colors to match new theme
        self.backgroundColor = Onyx.Colors.Surface
        self.borderColor = Onyx.Colors.Border
    end
    
    function PANEL:OnRemove()
        hook.Remove("OnyxThemeChanged", self.themeHook)
    end
    
    function PANEL:Paint(w, h)
        -- Draw shadow
        if self.shadow then
            self.shadowAlpha = Onyx.Lerp(self.shadowAlpha, self.targetShadowAlpha, 0.1)
            if self.shadowAlpha > 1 then
                local shadowColor = Color(0, 0, 0, self.shadowAlpha)
                Onyx.DrawRoundedBox(2, 2, w, h, self.cornerRadius, shadowColor)
            end
        end
        
        -- Draw background
        Onyx.DrawRoundedBox(0, 0, w, h, self.cornerRadius, self.backgroundColor)
        
        -- Draw border
        if self.borderWidth > 0 then
            surface.SetDrawColor(self.borderColor)
            for i = 0, self.borderWidth - 1 do
                local offset = i
                surface.DrawOutlinedRect(offset, offset, w - offset * 2, h - offset * 2)
            end
        end
    end
    
    function PANEL:SetBackgroundColor(color)
        self.backgroundColor = color
    end
    
    function PANEL:SetBorderColor(color)
        self.borderColor = color
    end
    
    function PANEL:SetBorderWidth(width)
        self.borderWidth = width
    end
    
    function PANEL:SetCornerRadius(radius)
        self.cornerRadius = radius
    end
    
    function PANEL:SetShadow(enabled)
        self.shadow = enabled
        self.targetShadowAlpha = enabled and 100 or 0
    end
    
    function PANEL:OnCursorEntered()
        self.targetShadowAlpha = 150
    end
    
    function PANEL:OnCursorExited()
        self.targetShadowAlpha = 100
    end
    
    vgui.Register("OnyxPanel", PANEL, "DPanel")
    
end
