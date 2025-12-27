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
        
        -- Dynamic scaling
        self.scale = 1.0
        self.minScale = 0.5
        self.maxScale = 3.0
        
        -- Tooltip
        self.hoveredEvent = nil
        self.tooltip = nil
        
        -- Event rows for overlapping events
        self.eventRows = {}
        self.rowHeight = 35
        self.rowSpacing = 5
        
        -- Minimum event width for visibility
        self.minEventWidth = 2
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
        
        -- Draw events with overlap detection
        self:DrawEvents(w, h, trackY)
        
        -- Draw current time indicator
        self:DrawCurrentTime(w, h, trackY)
        
        -- Draw tooltip if hovering over event
        if self.hoveredEvent then
            self:DrawTooltip()
        end
        
        -- Draw border
        surface.SetDrawColor(Onyx.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    function PANEL:DrawTimeMarkers(w, h, trackY)
        local timeInterval = 60  -- 1 minute intervals
        local numMarkers = math.ceil(self.maxTime / timeInterval)
        
        for i = 0, numMarkers do
            local time = i * timeInterval
            local x = (time / self.maxTime) * w * self.scale
            
            -- Only draw if within visible bounds
            if x >= 0 and x <= w then
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
    end
    
    function PANEL:DrawEvents(w, h, trackY)
        -- Organize events into rows to handle overlaps
        self:OrganizeEventRows()
        
        -- Get mouse position for hover detection
        local mouseX, mouseY = self:CursorPos()
        self.hoveredEvent = nil
        
        for _, event in ipairs(self.events) do
            local startX = (event.startTime / self.maxTime) * w * self.scale
            local endX = (event.endTime / self.maxTime) * w * self.scale
            local width = endX - startX
            
            if width < self.minEventWidth then width = self.minEventWidth end
            
            -- Calculate event position with row support
            local row = event.row or 0
            local eventY = trackY - (self.rowHeight / 2) - (row * (self.rowHeight + self.rowSpacing))
            local eventHeight = self.rowHeight
            local eventColor = event.color or Onyx.Colors.Success
            
            -- Check if mouse is hovering over this event
            local isHovered = mouseX >= startX and mouseX <= startX + width and 
                             mouseY >= eventY and mouseY <= eventY + eventHeight
            
            if isHovered then
                self.hoveredEvent = event
                -- Brighten color on hover
                eventColor = Color(
                    math.min(eventColor.r + 30, 255),
                    math.min(eventColor.g + 30, 255),
                    math.min(eventColor.b + 30, 255)
                )
            end
            
            -- Draw event block
            Onyx.DrawRoundedBox(startX, eventY, width, eventHeight, 4, eventColor)
            
            -- Draw event border for better visibility
            surface.SetDrawColor(Color(0, 0, 0, 100))
            surface.DrawOutlinedRect(startX, eventY, width, eventHeight)
            
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
        local x = (self.currentTime / self.maxTime) * w * self.scale
        
        -- Only draw if within visible bounds
        if x >= 0 and x <= w then
            -- Draw vertical line
            surface.SetDrawColor(self.currentTimeColor)
            surface.DrawLine(x, 0, x, h)
            
            -- Draw marker at top
            draw.RoundedBox(4, x - 4, 0, 8, 8, self.currentTimeColor)
        end
    end
    
    function PANEL:OrganizeEventRows()
        -- Sort events by start time
        table.sort(self.events, function(a, b) return a.startTime < b.startTime end)
        
        -- Assign rows to events to prevent overlap
        local rows = {}
        
        for _, event in ipairs(self.events) do
            local placed = false
            
            -- Try to place in existing rows
            for rowIndex, row in ipairs(rows) do
                local canPlace = true
                
                for _, placedEvent in ipairs(row) do
                    -- Check for overlap
                    if not (event.endTime <= placedEvent.startTime or event.startTime >= placedEvent.endTime) then
                        canPlace = false
                        break
                    end
                end
                
                if canPlace then
                    table.insert(row, event)
                    event.row = rowIndex - 1
                    placed = true
                    break
                end
            end
            
            -- If couldn't place in existing row, create new row
            if not placed then
                table.insert(rows, {event})
                event.row = #rows - 1
            end
        end
        
        self.eventRows = rows
    end
    
    function PANEL:DrawTooltip()
        if not self.hoveredEvent then return end
        
        local event = self.hoveredEvent
        local mouseX, mouseY = self:LocalToScreen(self:CursorPos())
        
        -- Validate event has positive duration
        if event.endTime <= event.startTime then return end
        
        -- Calculate tooltip dimensions
        surface.SetFont(Onyx.Fonts.Small)
        local nameWidth, _ = surface.GetTextSize(event.name or "Event")
        
        local duration = event.endTime - event.startTime
        local durationText = string.format("Duration: %.1fs", duration)
        local durationWidth, _ = surface.GetTextSize(durationText)
        
        local startText = string.format("Start: %.1fs", event.startTime)
        local startWidth, _ = surface.GetTextSize(startText)
        
        local endText = string.format("End: %.1fs", event.endTime)
        local endWidth, _ = surface.GetTextSize(endText)
        
        local tooltipWidth = math.max(nameWidth, durationWidth, startWidth, endWidth) + 20
        local tooltipHeight = 80
        
        if event.description then
            local descWidth, _ = surface.GetTextSize(event.description)
            tooltipWidth = math.max(tooltipWidth, descWidth + 20)
            tooltipHeight = tooltipHeight + 20
        end
        
        -- Position tooltip near mouse
        local tooltipX = mouseX + 15
        local tooltipY = mouseY + 15
        
        -- Keep tooltip on screen
        local screenW, screenH = ScrW(), ScrH()
        if tooltipX + tooltipWidth > screenW then
            tooltipX = mouseX - tooltipWidth - 15
        end
        if tooltipY + tooltipHeight > screenH then
            tooltipY = mouseY - tooltipHeight - 15
        end
        
        -- Draw tooltip background
        Onyx.DrawRoundedBox(tooltipX, tooltipY, tooltipWidth, tooltipHeight, 4, Onyx.Colors.Surface)
        
        -- Draw border
        surface.SetDrawColor(Onyx.Colors.Border)
        surface.DrawOutlinedRect(tooltipX, tooltipY, tooltipWidth, tooltipHeight)
        
        -- Draw event info
        local yOffset = tooltipY + 10
        
        draw.SimpleText(event.name or "Event", Onyx.Fonts.Body, tooltipX + 10, yOffset, Onyx.Colors.Text)
        yOffset = yOffset + 20
        
        draw.SimpleText(startText, Onyx.Fonts.Small, tooltipX + 10, yOffset, Onyx.Colors.TextDim)
        yOffset = yOffset + 15
        
        draw.SimpleText(endText, Onyx.Fonts.Small, tooltipX + 10, yOffset, Onyx.Colors.TextDim)
        yOffset = yOffset + 15
        
        draw.SimpleText(durationText, Onyx.Fonts.Small, tooltipX + 10, yOffset, Onyx.Colors.TextDim)
        yOffset = yOffset + 15
        
        if event.description then
            draw.SimpleText(event.description, Onyx.Fonts.Small, tooltipX + 10, yOffset, Onyx.Colors.Text)
        end
    end
    
    function PANEL:AddEvent(name, startTime, endTime, color, description)
        local event = {
            name = name,
            startTime = startTime,
            endTime = endTime,
            color = color or Onyx.Colors.Success,
            description = description,
            id = #self.events + 1,
            row = 0,
        }
        
        table.insert(self.events, event)
        self:OrganizeEventRows()  -- Reorganize rows when new event is added
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
        self.eventRows = {}
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
    
    function PANEL:SetScale(scale)
        self.scale = math.Clamp(scale, self.minScale, self.maxScale)
    end
    
    function PANEL:GetScale()
        return self.scale
    end
    
    function PANEL:ZoomIn()
        self:SetScale(self.scale + 0.1)
    end
    
    function PANEL:ZoomOut()
        self:SetScale(self.scale - 0.1)
    end
    
    function PANEL:OnMousePressed(keyCode)
        if keyCode == MOUSE_LEFT then
            local w = self:GetWide()
            local mouseX = self:CursorPos()
            local clickedTime = (mouseX / (w * self.scale)) * self.maxTime
            
            self:OnTimelineClicked(clickedTime)
        end
    end
    
    function PANEL:OnMouseWheeled(delta)
        -- Zoom in/out with mouse wheel
        if delta > 0 then
            self:ZoomIn()
        else
            self:ZoomOut()
        end
        return true
    end
    
    function PANEL:OnTimelineClicked(time)
        -- Override this function to handle clicks
    end
    
    vgui.Register("OnyxTimeline", PANEL, "DPanel")
    
end
