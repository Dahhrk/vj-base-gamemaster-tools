--[[
    UI Visualizer - 3D World Space Visualization
    Provides visual overlays for spawn points, waves, and NPCs in the game world
    
    Features:
    - 3D spawn point markers with halos
    - Wave radius visualization
    - NPC faction indicators
    - Real-time wave progress overlays
]]--

if CLIENT then
    
    VJGM = VJGM or {}
    VJGM.UIVisualizer = VJGM.UIVisualizer or {}
    
    -- Visualization state
    local visualizationEnabled = false
    local showSpawnPoints = true
    local showWaveAreas = true
    local showNPCMarkers = true
    
    -- Cached spawn points for visualization
    local cachedSpawnPoints = {}
    
    --[[
        Enable/disable visualization
        @param enabled: Boolean
    ]]--
    function VJGM.UIVisualizer.SetEnabled(enabled)
        visualizationEnabled = enabled
        
        if enabled then
            print("[VJGM] UI Visualizer enabled")
        else
            print("[VJGM] UI Visualizer disabled")
        end
    end
    
    --[[
        Toggle visualization modes
        @param mode: "spawn_points", "wave_areas", "npc_markers"
        @param enabled: Boolean
    ]]--
    function VJGM.UIVisualizer.SetMode(mode, enabled)
        if mode == "spawn_points" then
            showSpawnPoints = enabled
        elseif mode == "wave_areas" then
            showWaveAreas = enabled
        elseif mode == "npc_markers" then
            showNPCMarkers = enabled
        end
    end
    
    --[[
        Update cached spawn points from server
        @param spawnData: Table of spawn point data
    ]]--
    function VJGM.UIVisualizer.UpdateSpawnPoints(spawnData)
        cachedSpawnPoints = spawnData or {}
    end
    
    --[[
        Draw 3D spawn point markers
    ]]--
    local function DrawSpawnPoints()
        if not showSpawnPoints then return end
        
        local plyPos = LocalPlayer():GetPos()
        local maxDist = 5000  -- Only show spawn points within this distance
        
        for group, points in pairs(cachedSpawnPoints) do
            for i, point in ipairs(points) do
                local dist = plyPos:Distance(point.pos)
                
                if dist < maxDist then
                    -- Draw 3D beam
                    local alpha = math.max(0, 255 - (dist / maxDist * 155))
                    local color = Color(100, 200, 255, alpha)
                    
                    -- Vertical beam
                    render.DrawBeam(point.pos, point.pos + Vector(0, 0, 100), 4, 0, 1, color)
                    
                    -- Ground circle
                    local circlePoints = {}
                    local segments = 16
                    for j = 0, segments do
                        local ang = (j / segments) * math.pi * 2
                        local offset = Vector(math.cos(ang) * 30, math.sin(ang) * 30, 5)
                        table.insert(circlePoints, point.pos + offset)
                    end
                    
                    -- Draw circle outline
                    for j = 1, #circlePoints - 1 do
                        render.DrawBeam(circlePoints[j], circlePoints[j + 1], 2, 0, 1, color)
                    end
                end
            end
        end
    end
    
    --[[
        Draw wave area indicators
    ]]--
    local function DrawWaveAreas()
        if not showWaveAreas then return end
        
        -- Request wave data from server
        -- This would be populated via network messages
        -- For now, this is a placeholder for future expansion
    end
    
    --[[
        Draw NPC faction markers above their heads
    ]]--
    local function DrawNPCMarkers()
        if not showNPCMarkers then return end
        
        local plyPos = LocalPlayer():GetPos()
        local maxDist = 3000
        
        for _, npc in ipairs(ents.FindByClass("npc_*")) do
            if IsValid(npc) and npc:Health() > 0 then
                local dist = plyPos:Distance(npc:GetPos())
                
                if dist < maxDist then
                    local pos = npc:GetPos() + Vector(0, 0, npc:OBBMaxs().z + 20)
                    local screenPos = pos:ToScreen()
                    
                    if screenPos.visible then
                        -- Draw faction indicator
                        local factionColor = Color(255, 255, 255, 200)
                        
                        -- Check if it's a VJ Base NPC
                        if npc.IsVJBaseSNPC then
                            if npc.VJ_NPC_Class and npc.VJ_NPC_Class[1] then
                                local faction = npc.VJ_NPC_Class[1]
                                
                                -- Color based on faction
                                if string.find(faction, "PLAYER") then
                                    factionColor = Color(100, 255, 100, 200)
                                elseif string.find(faction, "ANTLION") then
                                    factionColor = Color(255, 100, 100, 200)
                                else
                                    factionColor = Color(255, 200, 100, 200)
                                end
                            end
                        end
                        
                        -- Draw circle above NPC
                        surface.SetDrawColor(factionColor)
                        local radius = math.max(5, 15 - (dist / maxDist * 10))
                        VJGM.UIVisualizer.DrawCircle(screenPos.x, screenPos.y, radius, factionColor)
                        
                        -- Draw health bar
                        local healthPercent = npc:Health() / npc:GetMaxHealth()
                        local barWidth = 40
                        local barHeight = 4
                        
                        -- Background
                        surface.SetDrawColor(Color(0, 0, 0, 150))
                        surface.DrawRect(screenPos.x - barWidth/2, screenPos.y + 15, barWidth, barHeight)
                        
                        -- Health fill
                        local healthColor = Color(
                            255 * (1 - healthPercent), 
                            255 * healthPercent, 
                            0, 
                            200
                        )
                        surface.SetDrawColor(healthColor)
                        surface.DrawRect(screenPos.x - barWidth/2, screenPos.y + 15, barWidth * healthPercent, barHeight)
                    end
                end
            end
        end
    end
    
    --[[
        Main rendering hook
    ]]--
    hook.Add("PostDrawTranslucentRenderables", "VJGM_UIVisualizer_3D", function()
        if not visualizationEnabled then return end
        
        cam.Start3D()
            DrawSpawnPoints()
            DrawWaveAreas()
        cam.End3D()
    end)
    
    --[[
        2D HUD overlay hook
    ]]--
    hook.Add("HUDPaint", "VJGM_UIVisualizer_2D", function()
        if not visualizationEnabled then return end
        
        DrawNPCMarkers()
    end)
    
    --[[
        Network message to receive spawn point data
    ]]--
    net.Receive("VJGM_SpawnPointData", function()
        local groupCount = net.ReadUInt(8)
        local spawnData = {}
        
        for i = 1, groupCount do
            local groupName = net.ReadString()
            local pointCount = net.ReadUInt(8)
            
            spawnData[groupName] = {}
            
            for j = 1, pointCount do
                local pos = net.ReadVector()
                local ang = net.ReadAngle()
                
                table.insert(spawnData[groupName], {
                    pos = pos,
                    angle = ang
                })
            end
        end
        
        VJGM.UIVisualizer.UpdateSpawnPoints(spawnData)
    end)
    
    --[[
        Helper function for drawing circles
    ]]--
    local function DrawCircle(x, y, radius, color)
        local segmentCount = 32
        local poly = {}
        
        for i = 0, segmentCount do
            local angle = (i / segmentCount) * math.pi * 2
            local px = x + math.cos(angle) * radius
            local py = y + math.sin(angle) * radius
            
            table.insert(poly, {x = px, y = py})
        end
        
        surface.SetDrawColor(color)
        draw.NoTexture()
        surface.DrawPoly(poly)
    end
    
    -- Use local function instead of modifying global surface table
    VJGM.UIVisualizer.DrawCircle = DrawCircle
    
    -- Console commands for visualization control
    concommand.Add("vjgm_visualizer_toggle", function()
        if LocalPlayer():IsAdmin() then
            visualizationEnabled = not visualizationEnabled
            VJGM.UIVisualizer.SetEnabled(visualizationEnabled)
        end
    end)
    
    concommand.Add("vjgm_visualizer_spawns", function(ply, cmd, args)
        if LocalPlayer():IsAdmin() then
            showSpawnPoints = not showSpawnPoints
            print("[VJGM] Spawn point visualization: " .. (showSpawnPoints and "ON" or "OFF"))
        end
    end)
    
    concommand.Add("vjgm_visualizer_npcs", function()
        if LocalPlayer():IsAdmin() then
            showNPCMarkers = not showNPCMarkers
            print("[VJGM] NPC marker visualization: " .. (showNPCMarkers and "ON" or "OFF"))
        end
    end)
    
    concommand.Add("vjgm_visualizer_request_spawns", function()
        if LocalPlayer():IsAdmin() then
            net.Start("VJGM_RequestSpawnPointData")
            net.SendToServer()
        end
    end)
    
end

if SERVER then
    
    VJGM = VJGM or {}
    VJGM.UIVisualizer = VJGM.UIVisualizer or {}
    
    --[[
        Setup networking for visualizer
    ]]--
    function VJGM.UIVisualizer.SetupNetworking()
        util.AddNetworkString("VJGM_SpawnPointData")
        util.AddNetworkString("VJGM_RequestSpawnPointData")
        
        -- Handle spawn point data requests
        net.Receive("VJGM_RequestSpawnPointData", function(len, ply)
            if not ply:IsAdmin() then return end
            
            VJGM.UIVisualizer.SendSpawnPointData(ply)
        end)
    end
    
    --[[
        Send spawn point data to client
        @param ply: Player to send to
    ]]--
    function VJGM.UIVisualizer.SendSpawnPointData(ply)
        if not VJGM.SpawnPoints then return end
        
        -- Get all spawn point groups
        local allSpawnPoints = VJGM.SpawnPoints.GetAllSpawnPoints and VJGM.SpawnPoints.GetAllSpawnPoints() or {}
        local groups = {}
        
        -- Convert to array of group names
        for groupName, _ in pairs(allSpawnPoints) do
            table.insert(groups, groupName)
        end
        
        net.Start("VJGM_SpawnPointData")
        net.WriteUInt(math.min(#groups, 255), 8)
        
        for i = 1, math.min(#groups, 255) do
            local groupName = groups[i]
            local points = allSpawnPoints[groupName] or {}
            
            net.WriteString(groupName)
            net.WriteUInt(math.min(#points, 255), 8)
            
            for j = 1, math.min(#points, 255) do
                net.WriteVector(points[j].pos)
                net.WriteAngle(points[j].angle or Angle(0, 0, 0))
            end
        end
        
        net.Send(ply)
    end
    
    -- Setup networking on initialization
    hook.Add("Initialize", "VJGM_UIVisualizer_Server_Init", function()
        VJGM.UIVisualizer.SetupNetworking()
    end)
    
    -- Call immediately to ensure network strings are registered before use
    VJGM.UIVisualizer.SetupNetworking()
    
end
