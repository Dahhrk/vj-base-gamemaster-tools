--[[
    Onyx UI Framework - Button Component
    Modern button with hover effects and animations
]]--

if CLIENT then
    
    local PANEL = {}
    
    function PANEL:Init()
        self:SetText("")
        self.buttonText = "Button"
        self.textColor = Onyx.Colors.Text
        self.backgroundColor = Onyx.Colors.Primary
        self.hoverColor = Onyx.Colors.Secondary
        self.currentColor = self.backgroundColor
        self.cornerRadius = 4
        self.font = Onyx.Fonts.Body
        self.icon = nil
        self.isHovered = false
        self.isPressing = false
        self.pressScale = 1.0
    end
    
    function PANEL:Paint(w, h)
        -- Smooth color transition
        self.currentColor = Color(
            Onyx.Lerp(self.currentColor.r, self.isHovered and self.hoverColor.r or self.backgroundColor.r, 0.2),
            Onyx.Lerp(self.currentColor.g, self.isHovered and self.hoverColor.g or self.backgroundColor.g, 0.2),
            Onyx.Lerp(self.currentColor.b, self.isHovered and self.hoverColor.b or self.backgroundColor.b, 0.2),
            255
        )
        
        -- Smooth press animation
        local targetScale = self.isPressing and 0.95 or 1.0
        self.pressScale = Onyx.Lerp(self.pressScale, targetScale, 0.3)
        
        local scaleOffset = (1 - self.pressScale) * w / 2
        local scaledW = w * self.pressScale
        local scaledH = h * self.pressScale
        
        -- Draw button background
        Onyx.DrawRoundedBox(scaleOffset, scaleOffset, scaledW, scaledH, self.cornerRadius, self.currentColor)
        
        -- Draw text
        draw.SimpleText(
            self.buttonText,
            self.font,
            w / 2,
            h / 2,
            self.textColor,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
        
        -- Draw icon if provided
        if self.icon then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(self.icon)
            local iconSize = h * 0.6
            surface.DrawTexturedRect(10, (h - iconSize) / 2, iconSize, iconSize)
        end
    end
    
    function PANEL:SetButtonText(text)
        self.buttonText = text
    end
    
    function PANEL:SetTextColor(color)
        self.textColor = color
    end
    
    function PANEL:SetBackgroundColor(color)
        self.backgroundColor = color
    end
    
    function PANEL:SetHoverColor(color)
        self.hoverColor = color
    end
    
    function PANEL:SetFont(font)
        self.font = font
    end
    
    function PANEL:SetIcon(material)
        self.icon = material
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
            self.isPressing = true
            surface.PlaySound("ui/buttonclick.wav")
        end
    end
    
    function PANEL:OnMouseReleased(keyCode)
        if keyCode == MOUSE_LEFT then
            self.isPressing = false
        end
    end
    
    vgui.Register("OnyxButton", PANEL, "DButton")
    
end
