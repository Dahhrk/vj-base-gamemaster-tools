--[[
    Onyx UI Framework - Minimap Component
    Interactive minimap for visualizing spawn points and entities
]]--

if CLIENT then
    
    local PANEL = {}
    
    function PANEL:Init()
        self.markers = {}
        self.zoom = 1.0
        self.panOffset = Vector(0, 0, 0)
        self.centerPos = Vector(0, 0, 0)
        self.worldBounds = {
            min = Vector(-8192, -8192, 0),
            max = Vector(8192, 8192, 0)
        }
        self.dragging = false
        self.dragStart = nil
        self.dragStartPan = nil
        self.backgroundColor = Onyx.Colors.Background
        self.gridColor = Color(60, 60, 65, 100)
        self.showGrid = true
        self.gridSize = 512
        
        -- Player marker
        self.playerMarkerColor = Color(100, 200, 255)
        
        -- Auto-update timer
        self.lastUpdate = 0
        self.updateInterval = 0.1
        
        -- Zoom settings
        self.minZoom = 0.1
        self.maxZoom = 5.0
        self.zoomSensitivity = 0.1
        
        -- Marker clustering
        self.enableClustering = true
        self.clusterRadius = 30  -- pixels
        self.clusters = {}
        
        -- Performance optimization
        self.markersDirty = true
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
        -- Build clusters if markers are dirty
        if self.markersDirty then
            self:BuildClusters(w, h)
            self.markersDirty = false
        end
        
        if self.enableClustering and #self.markers > 20 then
            -- Draw clusters
            for _, cluster in ipairs(self.clusters) do
                self:DrawCluster(cluster, w, h)
            end
        else
            -- Draw individual markers when clustering is disabled or few markers
            for _, marker in ipairs(self.markers) do
                local screenX, screenY = self:WorldToScreen(marker.pos, w, h)
                
                if screenX >= -50 and screenX <= w + 50 and screenY >= -50 and screenY <= h + 50 then
                    self:DrawMarker(marker, screenX, screenY)
                end
            end
        end
    end
    
    function PANEL:DrawMarker(marker, screenX, screenY)
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
    
    function PANEL:BuildClusters(w, h)
        self.clusters = {}
        local processed = {}
        
        for i, marker in ipairs(self.markers) do
            if not processed[i] then
                local cluster = {
                    markers = {marker},
                    centerPos = Vector(marker.pos.x, marker.pos.y, marker.pos.z),
                    indices = {i}
                }
                
                local screenX, screenY = self:WorldToScreen(marker.pos, w, h)
                
                -- Find nearby markers to cluster
                for j, otherMarker in ipairs(self.markers) do
                    if i ~= j and not processed[j] then
                        local otherScreenX, otherScreenY = self:WorldToScreen(otherMarker.pos, w, h)
                        local distance = math.sqrt((screenX - otherScreenX)^2 + (screenY - otherScreenY)^2)
                        
                        if distance < self.clusterRadius then
                            table.insert(cluster.markers, otherMarker)
                            table.insert(cluster.indices, j)
                            processed[j] = true
                            
                            -- Update cluster center
                            cluster.centerPos = cluster.centerPos + otherMarker.pos
                        end
                    end
                end
                
                -- Average the center position
                cluster.centerPos = cluster.centerPos / #cluster.markers
                processed[i] = true
                table.insert(self.clusters, cluster)
            end
        end
    end
    
    function PANEL:DrawCluster(cluster, w, h)
        local screenX, screenY = self:WorldToScreen(cluster.centerPos, w, h)
        
        if screenX >= -50 and screenX <= w + 50 and screenY >= -50 and screenY <= h + 50 then
            local count = #cluster.markers
            
            if count == 1 then
                -- Draw single marker normally
                self:DrawMarker(cluster.markers[1], screenX, screenY)
            else
                -- Draw cluster indicator
                local clusterSize = math.Clamp(15 + count * 2, 15, 40)
                local clusterColor = Color(255, 150, 50, 200)
                
                -- Draw outer circle
                draw.RoundedBox(clusterSize / 2, screenX - clusterSize / 2, screenY - clusterSize / 2, clusterSize, clusterSize, clusterColor)
                
                -- Draw inner circle
                local innerSize = clusterSize * 0.7
                draw.RoundedBox(innerSize / 2, screenX - innerSize / 2, screenY - innerSize / 2, innerSize, innerSize, Color(40, 40, 45, 255))
                
                -- Draw count
                draw.SimpleText(
                    tostring(count),
                    Onyx.Fonts.Body,
                    screenX,
                    screenY,
                    Color(255, 255, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
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
        
        -- Apply pan offset to world position
        local adjustedPos = worldPos - self.panOffset
        
        local normalized = Vector(
            (adjustedPos.x - self.worldBounds.min.x) / worldSize.x,
            (adjustedPos.y - self.worldBounds.min.y) / worldSize.y,
            0
        )
        
        -- Center the view
        local centerX = w / 2
        local centerY = h / 2
        
        -- Apply zoom around center
        local screenX = centerX + (normalized.x - 0.5) * w * self.zoom
        local screenY = centerY + (0.5 - normalized.y) * h * self.zoom  -- Flip Y axis
        
        return screenX, screenY
    end
    
    function PANEL:ScreenToWorld(screenX, screenY, w, h)
        local worldSize = self.worldBounds.max - self.worldBounds.min
        
        -- Center the view
        local centerX = w / 2
        local centerY = h / 2
        
        -- Reverse zoom transform
        local normalizedX = 0.5 + (screenX - centerX) / (w * self.zoom)
        local normalizedY = 0.5 - (screenY - centerY) / (h * self.zoom)
        
        local worldX = self.worldBounds.min.x + normalizedX * worldSize.x
        local worldY = self.worldBounds.min.y + normalizedY * worldSize.y
        
        -- Apply pan offset
        return Vector(worldX + self.panOffset.x, worldY + self.panOffset.y, 0)
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
        self.markersDirty = true
        return marker
    end
    
    function PANEL:UpdateMarker(id, options)
        for i, marker in ipairs(self.markers) do
            if marker.id == id then
                if options.pos then marker.pos = options.pos end
                if options.color then marker.color = options.color end
                if options.size then marker.size = options.size end
                if options.shape then marker.shape = options.shape end
                if options.label then marker.label = options.label end
                
                self.markersDirty = true
                return true
            end
        end
        return false
    end
    
    function PANEL:BatchUpdateMarkers(updates)
        local updated = false
        for _, update in ipairs(updates) do
            if update.id and update.options then
                if self:UpdateMarker(update.id, update.options) then
                    updated = true
                end
            end
        end
        return updated
    end
    
    function PANEL:GetMarker(id)
        for _, marker in ipairs(self.markers) do
            if marker.id == id then
                return marker
            end
        end
        return nil
    end
    
    function PANEL:RemoveMarker(id)
        for i, marker in ipairs(self.markers) do
            if marker.id == id then
                table.remove(self.markers, i)
                self.markersDirty = true
                return true
            end
        end
        return false
    end
    
    function PANEL:ClearMarkers()
        self.markers = {}
        self.markersDirty = true
    end
    
    function PANEL:SetWorldBounds(min, max)
        self.worldBounds.min = min
        self.worldBounds.max = max
    end
    
    function PANEL:SetZoom(zoom)
        local oldZoom = self.zoom
        self.zoom = math.Clamp(zoom, self.minZoom, self.maxZoom)
        
        if math.abs(oldZoom - self.zoom) > 0.05 then
            self.markersDirty = true
        end
    end
    
    function PANEL:GetZoom()
        return self.zoom
    end
    
    function PANEL:SetPan(x, y)
        self.panOffset = Vector(x, y, 0)
    end
    
    function PANEL:GetPan()
        return self.panOffset.x, self.panOffset.y
    end
    
    function PANEL:ResetView()
        self.zoom = 1.0
        self.panOffset = Vector(0, 0, 0)
        self.markersDirty = true
    end
    
    function PANEL:SetClusteringEnabled(enabled)
        self.enableClustering = enabled
        self.markersDirty = true
    end
    
    function PANEL:SetClusterRadius(radius)
        self.clusterRadius = math.Clamp(radius, 10, 100)
        self.markersDirty = true
    end
    
    function PANEL:OnMousePressed(keyCode)
        if keyCode == MOUSE_LEFT then
            local w, h = self:GetSize()
            local mouseX, mouseY = self:CursorPos()
            local worldPos = self:ScreenToWorld(mouseX, mouseY, w, h)
            
            self:OnMapClicked(worldPos, mouseX, mouseY)
        elseif keyCode == MOUSE_RIGHT or keyCode == MOUSE_MIDDLE then
            -- Start panning
            self.dragging = true
            self.dragStart = Vector(self:CursorPos())
            self.dragStartPan = Vector(self.panOffset.x, self.panOffset.y, 0)
        end
    end
    
    function PANEL:OnMouseReleased(keyCode)
        if keyCode == MOUSE_RIGHT or keyCode == MOUSE_MIDDLE then
            self.dragging = false
            self.dragStart = nil
            self.dragStartPan = nil
        end
    end
    
    function PANEL:OnMouseWheeled(delta)
        local oldZoom = self.zoom
        self.zoom = math.Clamp(self.zoom + delta * self.zoomSensitivity, self.minZoom, self.maxZoom)
        
        -- Mark clusters as dirty when zoom changes significantly
        if math.abs(oldZoom - self.zoom) > 0.05 then
            self.markersDirty = true
        end
        
        return true
    end
    
    function PANEL:Think()
        -- Handle panning
        if self.dragging and self.dragStart then
            local w, h = self:GetSize()
            local mouseX, mouseY = self:CursorPos()
            local deltaX = mouseX - self.dragStart.x
            local deltaY = mouseY - self.dragStart.y
            
            -- Convert screen delta to world delta
            local worldSize = self.worldBounds.max - self.worldBounds.min
            local worldDeltaX = -(deltaX / w) * (worldSize.x / self.zoom)
            local worldDeltaY = (deltaY / h) * (worldSize.y / self.zoom)
            
            self.panOffset.x = self.dragStartPan.x + worldDeltaX
            self.panOffset.y = self.dragStartPan.y + worldDeltaY
        end
        
        -- Auto-update markers if needed
        local curTime = CurTime()
        if curTime - self.lastUpdate > self.updateInterval then
            self.lastUpdate = curTime
            if self.OnAutoUpdate then
                self:OnAutoUpdate()
            end
        end
    end
    
    function PANEL:OnMapClicked(worldPos, screenX, screenY)
        -- Override this function to handle clicks
    end
    
    function PANEL:OnAutoUpdate()
        -- Override this function to handle automatic updates
    end
    
    vgui.Register("OnyxMinimap", PANEL, "DPanel")
    
end
