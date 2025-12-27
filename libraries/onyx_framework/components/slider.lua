--[[
    Onyx UI Framework - Slider Component
    Modern slider with smooth animations and value display
]]--

if CLIENT then
    
    local PANEL = {}
    
    function PANEL:Init()
        self.trackColor = Onyx.Colors.Border
        self.fillColor = Onyx.Colors.Primary
        self.thumbColor = Onyx.Colors.Secondary
        self.textColor = Onyx.Colors.Text
        self.min = 0
        self.max = 100
        self.value = 50
        self.dragging = false
        self.thumbSize = 16
        self.trackHeight = 4
        self.showValue = true
        self.suffix = ""
        self.decimals = 0
        self.font = Onyx.Fonts.Small
    end
    
    function PANEL:Paint(w, h)
        local trackY = h / 2 - self.trackHeight / 2
        
        -- Draw track
        Onyx.DrawRoundedBox(0, 0, trackY, w, self.trackHeight, self.trackColor)
        
        -- Calculate fill width
        local fillWidth = (self.value - self.min) / (self.max - self.min) * w
        
        -- Draw fill
        Onyx.DrawRoundedBox(0, 0, trackY, fillWidth, self.trackHeight, self.fillColor)
        
        -- Draw thumb
        local thumbX = fillWidth - self.thumbSize / 2
        local thumbY = h / 2 - self.thumbSize / 2
        draw.RoundedBox(self.thumbSize / 2, thumbX, thumbY, self.thumbSize, self.thumbSize, self.thumbColor)
        
        -- Draw value
        if self.showValue then
            local displayValue = self.decimals > 0 
                and string.format("%." .. self.decimals .. "f", self.value) 
                or tostring(math.floor(self.value))
            
            draw.SimpleText(
                displayValue .. self.suffix,
                self.font,
                w + 5,
                h / 2,
                self.textColor,
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
            )
        end
    end
    
    function PANEL:OnMousePressed(keyCode)
        if keyCode == MOUSE_LEFT then
            self.dragging = true
            self:UpdateValueFromMouse()
        end
    end
    
    function PANEL:OnMouseReleased(keyCode)
        if keyCode == MOUSE_LEFT then
            self.dragging = false
        end
    end
    
    function PANEL:Think()
        if self.dragging then
            self:UpdateValueFromMouse()
        end
    end
    
    function PANEL:UpdateValueFromMouse()
        local mouseX = self:CursorPos()
        local w = self:GetWide()
        local fraction = math.Clamp(mouseX / w, 0, 1)
        local newValue = self.min + (self.max - self.min) * fraction
        
        if self.decimals == 0 then
            newValue = math.floor(newValue + 0.5)
        end
        
        if newValue ~= self.value then
            self.value = newValue
            self:OnValueChanged(self.value)
        end
    end
    
    function PANEL:SetMin(min)
        self.min = min
        self.value = math.Clamp(self.value, self.min, self.max)
    end
    
    function PANEL:SetMax(max)
        self.max = max
        self.value = math.Clamp(self.value, self.min, self.max)
    end
    
    function PANEL:SetValue(value)
        self.value = math.Clamp(value, self.min, self.max)
    end
    
    function PANEL:GetValue()
        return self.value
    end
    
    function PANEL:SetDecimals(decimals)
        self.decimals = decimals
    end
    
    function PANEL:SetSuffix(suffix)
        self.suffix = suffix
    end
    
    function PANEL:ShowValue(show)
        self.showValue = show
    end
    
    function PANEL:OnValueChanged(value)
        -- Override this function
    end
    
    vgui.Register("OnyxSlider", PANEL, "DPanel")
    
end
