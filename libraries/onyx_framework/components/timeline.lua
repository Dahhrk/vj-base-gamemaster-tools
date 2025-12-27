--[[
    Onyx UI Framework - Timeline Component
    Event timeline for visualizing event phases and progression
]]--

if CLIENT then
    
    local PANEL = {}
    
    function PANEL:Init()
        self.events = {}
        self.currentTime = 0
        self.maxTime = 600  -- 10 minutes default
        self.backgroundColor = Onyx.Colors.Background
        self.timelineColor = Onyx.Colors.Border
        self.currentTimeColor = Onyx.Colors.Primary
        self.showLabels = true
        self.timelineHeight = 40
        self.font = Onyx.Fonts.Small
        
        -- Scrolling
        self.scrollOffset = 0
        self.scrollable = true
        
        -- Listen for theme changes
        self.themeHook = "OnyxTimeline_ThemeChange_" .. tostring(self)
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
        self.backgroundColor = Onyx.Colors.Background
        self.timelineColor = Onyx.Colors.Border
        self.currentTimeColor = Onyx.Colors.Primary
    end
    
    function PANEL:OnRemove()
        hook.Remove("OnyxThemeChanged", self.themeHook)
    end
    
    function PANEL:Paint(w, h)
        -- Draw background
        Onyx.DrawRoundedBox(0, 0, w, h, 4, self.backgroundColor)
        
        -- Draw timeline track
        local trackY = h / 2
        surface.SetDrawColor(self.timelineColor)
        surface.DrawLine(0, trackY, w, trackY)
        
        -- Draw time markers
        self:DrawTimeMarkers(w, h, trackY)
        
        -- Draw events
        self:DrawEvents(w, h, trackY)
        
        -- Draw current time indicator
        self:DrawCurrentTime(w, h, trackY)
        
        -- Draw border
        surface.SetDrawColor(Onyx.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    function PANEL:DrawTimeMarkers(w, h, trackY)
        local timeInterval = 60  -- 1 minute intervals
        local numMarkers = math.ceil(self.maxTime / timeInterval)
        
        for i = 0, numMarkers do
            local time = i * timeInterval
            local x = (time / self.maxTime) * w
            
            -- Draw marker line
            surface.SetDrawColor(self.timelineColor)
            surface.DrawLine(x, trackY - 5, x, trackY + 5)
            
            -- Draw time label
            if self.showLabels then
                local minutes = math.floor(time / 60)
                local seconds = time % 60
                local label = string.format("%d:%02d", minutes, seconds)
                
                draw.SimpleText(
                    label,
                    self.font,
                    x,
                    trackY + 15,
                    Onyx.Colors.TextDim,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_TOP
                )
            end
        end
    end
    
    function PANEL:DrawEvents(w, h, trackY)
        for _, event in ipairs(self.events) do
            local startX = (event.startTime / self.maxTime) * w
            local endX = (event.endTime / self.maxTime) * w
            local width = endX - startX
            
            if width < 2 then width = 2 end  -- Minimum width for visibility
            
            -- Draw event block
            local eventY = trackY - 20
            local eventHeight = 40
            local eventColor = event.color or Onyx.Colors.Success
            
            Onyx.DrawRoundedBox(startX, eventY, width, eventHeight, 4, eventColor)
            
            -- Draw event label
            if self.showLabels and width > 50 then
                draw.SimpleText(
                    event.name or "Event",
                    self.font,
                    startX + width / 2,
                    eventY + eventHeight / 2,
                    Onyx.Colors.Text,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
            end
        end
    end
    
    function PANEL:DrawCurrentTime(w, h, trackY)
        local x = (self.currentTime / self.maxTime) * w
        
        -- Draw vertical line
        surface.SetDrawColor(self.currentTimeColor)
        surface.DrawLine(x, 0, x, h)
        
        -- Draw marker at top
        draw.RoundedBox(4, x - 4, 0, 8, 8, self.currentTimeColor)
    end
    
    function PANEL:AddEvent(name, startTime, endTime, color)
        local event = {
            name = name,
            startTime = startTime,
            endTime = endTime,
            color = color or Onyx.Colors.Success,
            id = #self.events + 1,
        }
        
        table.insert(self.events, event)
        return event
    end
    
    function PANEL:RemoveEvent(id)
        for i, event in ipairs(self.events) do
            if event.id == id then
                table.remove(self.events, i)
                return true
            end
        end
        return false
    end
    
    function PANEL:ClearEvents()
        self.events = {}
    end
    
    function PANEL:SetCurrentTime(time)
        self.currentTime = math.Clamp(time, 0, self.maxTime)
    end
    
    function PANEL:SetMaxTime(time)
        self.maxTime = time
    end
    
    function PANEL:SetShowLabels(show)
        self.showLabels = show
    end
    
    function PANEL:OnMousePressed(keyCode)
        if keyCode == MOUSE_LEFT then
            local w = self:GetWide()
            local mouseX = self:CursorPos()
            local clickedTime = (mouseX / w) * self.maxTime
            
            self:OnTimelineClicked(clickedTime)
        end
    end
    
    function PANEL:OnTimelineClicked(time)
        -- Override this function to handle clicks
    end
    
    vgui.Register("OnyxTimeline", PANEL, "DPanel")
    
end
