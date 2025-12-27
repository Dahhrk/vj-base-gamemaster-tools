--[[
    Onyx UI Framework - Minimap Component
    Interactive minimap for visualizing spawn points and entities
]]--

if CLIENT then
    
    local PANEL = {}
    
    function PANEL:Init()
        self.markers = {}
        self.zoom = 1.0
        self.centerPos = Vector(0, 0, 0)
        self.worldBounds = {
            min = Vector(-8192, -8192, 0),
            max = Vector(8192, 8192, 0)
        }
        self.dragging = false
        self.dragStart = nil
        self.backgroundColor = Onyx.Colors.Background
        self.gridColor = Onyx.Colors.GridColor or Color(60, 60, 65, 100)
        self.showGrid = true
        self.gridSize = 512
        
        -- Player marker
        self.playerMarkerColor = Color(100, 200, 255)
        
        -- Auto-update timer
        self.lastUpdate = 0
        self.updateInterval = 0.1
        
        -- Listen for theme changes
        self.themeHook = "OnyxMinimap_ThemeChange_" .. tostring(self)
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
        self.gridColor = Onyx.Colors.GridColor or Color(60, 60, 65, 100)
    end
    
    function PANEL:OnRemove()
        hook.Remove("OnyxThemeChanged", self.themeHook)
    end
    
    function PANEL:Paint(w, h)
        -- Draw background
        Onyx.DrawRoundedBox(0, 0, w, h, 4, self.backgroundColor)
        
        -- Draw grid
        if self.showGrid then
            self:DrawGrid(w, h)
        end
        
        -- Draw markers
        self:DrawMarkers(w, h)
        
        -- Draw player position
        self:DrawPlayerMarker(w, h)
        
        -- Draw border
        surface.SetDrawColor(Onyx.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    function PANEL:DrawGrid(w, h)
        surface.SetDrawColor(self.gridColor)
        
        local worldSize = self.worldBounds.max - self.worldBounds.min
        local gridSpacing = (self.gridSize / worldSize.x) * w * self.zoom
        
        -- Vertical lines
        for x = 0, w, gridSpacing do
            surface.DrawLine(x, 0, x, h)
        end
        
        -- Horizontal lines
        for y = 0, h, gridSpacing do
            surface.DrawLine(0, y, w, y)
        end
    end
    
    function PANEL:DrawMarkers(w, h)
        for _, marker in ipairs(self.markers) do
            local screenX, screenY = self:WorldToScreen(marker.pos, w, h)
            
            if screenX >= 0 and screenX <= w and screenY >= 0 and screenY <= h then
                -- Draw marker
                local markerSize = marker.size or 8
                local markerColor = marker.color or Color(255, 100, 100)
                
                if marker.shape == "circle" then
                    draw.RoundedBox(markerSize / 2, screenX - markerSize / 2, screenY - markerSize / 2, markerSize, markerSize, markerColor)
                elseif marker.shape == "square" then
                    draw.RoundedBox(0, screenX - markerSize / 2, screenY - markerSize / 2, markerSize, markerSize, markerColor)
                else
                    -- Default: diamond
                    local points = {
                        {x = screenX, y = screenY - markerSize / 2},
                        {x = screenX + markerSize / 2, y = screenY},
                        {x = screenX, y = screenY + markerSize / 2},
                        {x = screenX - markerSize / 2, y = screenY},
                    }
                    draw.NoTexture()
                    surface.SetDrawColor(markerColor)
                    surface.DrawPoly(points)
                end
                
                -- Draw label
                if marker.label then
                    draw.SimpleText(
                        marker.label,
                        Onyx.Fonts.Small,
                        screenX,
                        screenY + markerSize,
                        Onyx.Colors.Text,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_TOP
                    )
                end
            end
        end
    end
    
    function PANEL:DrawPlayerMarker(w, h)
        if not IsValid(LocalPlayer()) then return end
        
        local playerPos = LocalPlayer():GetPos()
        local screenX, screenY = self:WorldToScreen(playerPos, w, h)
        
        -- Draw player marker as a triangle pointing up
        local size = 10
        local points = {
            {x = screenX, y = screenY - size},
            {x = screenX + size / 2, y = screenY + size / 2},
            {x = screenX - size / 2, y = screenY + size / 2},
        }
        
        draw.NoTexture()
        surface.SetDrawColor(self.playerMarkerColor)
        surface.DrawPoly(points)
    end
    
    function PANEL:WorldToScreen(worldPos, w, h)
        local worldSize = self.worldBounds.max - self.worldBounds.min
        local normalized = Vector(
            (worldPos.x - self.worldBounds.min.x) / worldSize.x,
            (worldPos.y - self.worldBounds.min.y) / worldSize.y,
            0
        )
        
        local screenX = normalized.x * w
        local screenY = (1 - normalized.y) * h  -- Flip Y axis
        
        return screenX, screenY
    end
    
    function PANEL:ScreenToWorld(screenX, screenY, w, h)
        local worldSize = self.worldBounds.max - self.worldBounds.min
        local normalized = Vector(
            screenX / w,
            1 - (screenY / h),  -- Flip Y axis back
            0
        )
        
        local worldX = self.worldBounds.min.x + normalized.x * worldSize.x
        local worldY = self.worldBounds.min.y + normalized.y * worldSize.y
        
        return Vector(worldX, worldY, 0)
    end
    
    function PANEL:AddMarker(pos, options)
        options = options or {}
        local marker = {
            pos = pos,
            color = options.color or Color(255, 100, 100),
            size = options.size or 8,
            shape = options.shape or "circle",
            label = options.label,
            id = options.id or tostring(pos),
        }
        
        table.insert(self.markers, marker)
        return marker
    end
    
    function PANEL:RemoveMarker(id)
        for i, marker in ipairs(self.markers) do
            if marker.id == id then
                table.remove(self.markers, i)
                return true
            end
        end
        return false
    end
    
    function PANEL:ClearMarkers()
        self.markers = {}
    end
    
    function PANEL:SetWorldBounds(min, max)
        self.worldBounds.min = min
        self.worldBounds.max = max
    end
    
    function PANEL:SetZoom(zoom)
        self.zoom = math.Clamp(zoom, 0.1, 5.0)
    end
    
    function PANEL:OnMousePressed(keyCode)
        if keyCode == MOUSE_LEFT then
            local w, h = self:GetSize()
            local mouseX, mouseY = self:CursorPos()
            local worldPos = self:ScreenToWorld(mouseX, mouseY, w, h)
            
            self:OnMapClicked(worldPos, mouseX, mouseY)
        end
    end
    
    function PANEL:OnMapClicked(worldPos, screenX, screenY)
        -- Override this function to handle clicks
    end
    
    vgui.Register("OnyxMinimap", PANEL, "DPanel")
    
end
