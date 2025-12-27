--[[
    Live GUI Controller - PLACEHOLDER
    Future expansion for real-time wave control and monitoring interface
    
    Planned Features:
    - Real-time wave status monitoring
    - Manual wave triggering and control
    - Dynamic wave modification during events
    - NPC spawn preview and testing
    - Visual spawn point editor
    - Wave statistics and analytics
    - Multi-gamemaster support
    - Network synchronized controls
    
    Compatible with VJ Base and DarkRP frameworks
]]--

if CLIENT then
    
    -- Load configuration
    include("npc/config/init.lua")
    
    VJGM = VJGM or {}
    VJGM.GUIController = VJGM.GUIController or {}
    
    -- Store active GUI panels
    local activePanel = nil
    local waveMonitor = nil
    
    --[[
        Initialize GUI controller
    ]]--
    function VJGM.GUIController.Initialize()
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local enabled = VJGM.Config.Get("GUIController", "Enabled", true)
        
        if enabled then
            print(prefix .. " GUI Controller initialized")
        else
            print(prefix .. " GUI Controller disabled in config")
        end
    end
    
    --[[
        Open the main control panel
    ]]--
    function VJGM.GUIController.OpenControlPanel()
        local adminOnly = VJGM.Config.Get("GUIController", "AdminOnly", true)
        
        if adminOnly and not LocalPlayer():IsAdmin() then
            print("[VJGM] Control panel requires admin access")
            return
        end
        
        -- Close existing panel
        if IsValid(activePanel) then
            activePanel:Close()
        end
        
        -- Create main frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(800, 600)
        frame:Center()
        frame:SetTitle("VJGM - Dynamic NPC Spawner Control Panel")
        frame:MakePopup()
        
        activePanel = frame
        
        -- Create tab control
        local sheet = vgui.Create("DPropertySheet", frame)
        sheet:Dock(FILL)
        
        -- Active Waves Tab
        local wavesPanel = vgui.Create("DPanel")
        wavesPanel:Dock(FILL)
        VJGM.GUIController.CreateActiveWavesTab(wavesPanel)
        sheet:AddSheet("Active Waves", wavesPanel, "icon16/application_view_list.png")
        
        -- Wave Builder Tab
        local builderPanel = vgui.Create("DPanel")
        builderPanel:Dock(FILL)
        VJGM.GUIController.CreateWaveBuilderTab(builderPanel)
        sheet:AddSheet("Wave Builder", builderPanel, "icon16/cog.png")
        
        -- Spawn Points Tab
        local spawnPanel = vgui.Create("DPanel")
        spawnPanel:Dock(FILL)
        VJGM.GUIController.CreateSpawnPointsTab(spawnPanel)
        sheet:AddSheet("Spawn Points", spawnPanel, "icon16/map.png")
        
        -- Settings Tab
        local settingsPanel = vgui.Create("DPanel")
        settingsPanel:Dock(FILL)
        VJGM.GUIController.CreateSettingsTab(settingsPanel)
        sheet:AddSheet("Settings", settingsPanel, "icon16/wrench.png")
    end
    
    --[[
        Create wave builder interface
    ]]--
    function VJGM.GUIController.CreateWaveBuilder()
        VJGM.GUIController.OpenControlPanel()
    end
    
    --[[
        Create Active Waves tab content with enhanced visualization
        @param panel: Parent panel
    ]]--
    function VJGM.GUIController.CreateActiveWavesTab(panel)
        -- Header with statistics
        local header = vgui.Create("DLabel", panel)
        header:Dock(TOP)
        header:DockMargin(10, 10, 10, 5)
        header:SetTall(20)
        header:SetText("Active Wave Management")
        header:SetFont("DermaDefaultBold")
        
        -- Statistics panel
        local statsPanel = vgui.Create("DPanel", panel)
        statsPanel:Dock(TOP)
        statsPanel:DockMargin(10, 0, 10, 5)
        statsPanel:SetTall(30)
        statsPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 60, 255))
        end
        
        local statsLabel = vgui.Create("DLabel", statsPanel)
        statsLabel:Dock(FILL)
        statsLabel:DockMargin(10, 5, 10, 5)
        statsLabel:SetText("Total Waves: 0 | Total NPCs: 0 | Active: 0")
        statsLabel:SetContentAlignment(5)
        panel.StatsLabel = statsLabel
        
        -- Button toolbar
        local toolbar = vgui.Create("DPanel", panel)
        toolbar:Dock(TOP)
        toolbar:DockMargin(10, 0, 10, 5)
        toolbar:SetTall(30)
        toolbar:SetPaintBackground(false)
        
        -- Refresh button
        local refreshBtn = vgui.Create("DButton", toolbar)
        refreshBtn:Dock(LEFT)
        refreshBtn:DockMargin(0, 0, 5, 0)
        refreshBtn:SetWide(100)
        refreshBtn:SetText("🔄 Refresh")
        refreshBtn.DoClick = function()
            net.Start("VJGM_RequestWaveList")
            net.SendToServer()
        end
        
        -- Stop All button
        local stopAllBtn = vgui.Create("DButton", toolbar)
        stopAllBtn:Dock(LEFT)
        stopAllBtn:DockMargin(0, 0, 5, 0)
        stopAllBtn:SetWide(100)
        stopAllBtn:SetText("⏹ Stop All")
        stopAllBtn.DoClick = function()
            if not LocalPlayer():IsAdmin() then return end
            RunConsoleCommand("vjgm_wave_stop_all")
            timer.Simple(0.5, function()
                net.Start("VJGM_RequestWaveList")
                net.SendToServer()
            end)
        end
        
        -- Wave visualization scroll panel
        local scrollPanel = vgui.Create("DScrollPanel", panel)
        scrollPanel:Dock(FILL)
        scrollPanel:DockMargin(10, 0, 10, 5)
        
        -- Container for wave cards
        local waveContainer = vgui.Create("DPanel", scrollPanel)
        waveContainer:Dock(TOP)
        waveContainer:SetTall(0)
        waveContainer:SetPaintBackground(false)
        panel.WaveContainer = waveContainer
        
        -- Store wave cards for updates
        panel.WaveCards = {}
        
        -- Legacy wave list for compatibility
        local waveList = vgui.Create("DListView", panel)
        waveList:SetMultiSelect(false)
        waveList:AddColumn("Wave ID")
        waveList:AddColumn("Current/Total")
        waveList:AddColumn("NPCs Alive")
        waveList:AddColumn("Status")
        waveList:SetVisible(false) -- Hidden but still used for data
        panel.WaveList = waveList
        
        -- Request initial data
        timer.Simple(0.1, function()
            net.Start("VJGM_RequestWaveList")
            net.SendToServer()
        end)
    end
    
    --[[
        Create a visual wave card for display
        @param parent: Parent panel
        @param waveData: Wave information table
        @return Wave card panel
    ]]--
    function VJGM.GUIController.CreateWaveCard(parent, waveData)
        local card = vgui.Create("DPanel", parent)
        card:Dock(TOP)
        card:DockMargin(0, 0, 0, 10)
        card:SetTall(120)
        
        -- Color-coded based on status
        local statusColor = waveData.active and Color(50, 100, 50, 255) or Color(100, 50, 50, 255)
        
        card.Paint = function(self, w, h)
            -- Main card background
            draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 45, 255))
            
            -- Status bar on left
            draw.RoundedBox(6, 0, 0, 6, h, statusColor)
            
            -- Progress bar at bottom
            local progress = waveData.current / math.max(waveData.total, 1)
            draw.RoundedBox(0, 10, h - 8, (w - 20) * progress, 4, Color(100, 150, 255, 255))
            draw.RoundedBox(0, 10, h - 8, w - 20, 4, Color(30, 30, 30, 255))
        end
        
        -- Wave ID and status
        local headerLabel = vgui.Create("DLabel", card)
        headerLabel:SetPos(15, 10)
        headerLabel:SetSize(card:GetWide() - 130, 20)
        headerLabel:SetFont("DermaDefaultBold")
        headerLabel:SetText(waveData.id)
        
        -- Status indicator
        local statusLabel = vgui.Create("DLabel", card)
        statusLabel:SetPos(card:GetWide() - 115, 10)
        statusLabel:SetSize(100, 20)
        statusLabel:SetText(waveData.active and "● ACTIVE" or "● INACTIVE")
        statusLabel:SetTextColor(statusColor)
        statusLabel:SetContentAlignment(6)
        
        -- Wave progress
        local progressLabel = vgui.Create("DLabel", card)
        progressLabel:SetPos(15, 35)
        progressLabel:SetSize(150, 18)
        progressLabel:SetText("Wave Progress: " .. waveData.current .. " / " .. waveData.total)
        
        -- NPC count with icon
        local npcLabel = vgui.Create("DLabel", card)
        npcLabel:SetPos(15, 55)
        npcLabel:SetSize(150, 18)
        npcLabel:SetText("👥 NPCs Alive: " .. waveData.npcs)
        
        -- Percentage bar text
        local percentLabel = vgui.Create("DLabel", card)
        percentLabel:SetPos(15, 75)
        percentLabel:SetSize(150, 18)
        local percent = math.floor((waveData.current / math.max(waveData.total, 1)) * 100)
        percentLabel:SetText("Progress: " .. percent .. "%")
        
        -- Control buttons
        local btnY = 35
        local btnX = card:GetWide() - 110
        
        -- Pause/Resume button
        local pauseBtn = vgui.Create("DButton", card)
        pauseBtn:SetPos(btnX, btnY)
        pauseBtn:SetSize(100, 25)
        pauseBtn:SetText(waveData.paused and "▶ Resume" or "⏸ Pause")
        pauseBtn.DoClick = function()
            if waveData.paused then
                RunConsoleCommand("vjgm_wave_resume", waveData.id)
            else
                RunConsoleCommand("vjgm_wave_pause", waveData.id)
            end
            timer.Simple(0.2, function()
                net.Start("VJGM_RequestWaveList")
                net.SendToServer()
            end)
        end
        
        -- Stop button
        local stopBtn = vgui.Create("DButton", card)
        stopBtn:SetPos(btnX, btnY + 30)
        stopBtn:SetSize(100, 25)
        stopBtn:SetText("⏹ Stop Wave")
        stopBtn.DoClick = function()
            RunConsoleCommand("vjgm_wave_stop", waveData.id)
            timer.Simple(0.2, function()
                net.Start("VJGM_RequestWaveList")
                net.SendToServer()
            end)
        end
        
        card.waveData = waveData
        return card
    end
    
    --[[
        Create Wave Builder tab content
        @param panel: Parent panel
    ]]--
    function VJGM.GUIController.CreateWaveBuilderTab(panel)
        local header = vgui.Create("DLabel", panel)
        header:SetPos(10, 10)
        header:SetSize(panel:GetWide() - 20, 20)
        header:SetText("Quick Wave Builder")
        header:SetFont("DermaDefaultBold")
        
        -- NPC Class
        local classLabel = vgui.Create("DLabel", panel)
        classLabel:SetPos(10, 40)
        classLabel:SetText("NPC Class:")
        
        local classEntry = vgui.Create("DTextEntry", panel)
        classEntry:SetPos(100, 40)
        classEntry:SetSize(250, 25)
        classEntry:SetValue("npc_vj_test_human")
        
        -- NPC Count
        local countLabel = vgui.Create("DLabel", panel)
        countLabel:SetPos(10, 75)
        countLabel:SetText("NPC Count:")
        
        local countEntry = vgui.Create("DNumberWang", panel)
        countEntry:SetPos(100, 75)
        countEntry:SetSize(100, 25)
        countEntry:SetValue(5)
        countEntry:SetMin(1)
        countEntry:SetMax(50)
        
        -- Health
        local healthLabel = vgui.Create("DLabel", panel)
        healthLabel:SetPos(10, 110)
        healthLabel:SetText("Health:")
        
        local healthEntry = vgui.Create("DNumberWang", panel)
        healthEntry:SetPos(100, 110)
        healthEntry:SetSize(100, 25)
        healthEntry:SetValue(100)
        healthEntry:SetMin(1)
        healthEntry:SetMax(10000)
        
        -- Spawn Group
        local groupLabel = vgui.Create("DLabel", panel)
        groupLabel:SetPos(10, 145)
        groupLabel:SetText("Spawn Group:")
        
        local groupEntry = vgui.Create("DTextEntry", panel)
        groupEntry:SetPos(100, 145)
        groupEntry:SetSize(150, 25)
        groupEntry:SetValue("default")
        
        -- Spawn button
        local spawnBtn = vgui.Create("DButton", panel)
        spawnBtn:SetPos(10, 180)
        spawnBtn:SetSize(150, 30)
        spawnBtn:SetText("Spawn Wave")
        spawnBtn.DoClick = function()
            local npcClass = classEntry:GetValue()
            local count = tonumber(countEntry:GetValue()) or 5
            local health = tonumber(healthEntry:GetValue()) or 100
            local group = groupEntry:GetValue()
            
            net.Start("VJGM_SpawnQuickWave")
            net.WriteString(npcClass)
            net.WriteUInt(count, 8)
            net.WriteUInt(health, 16)
            net.WriteString(group)
            net.SendToServer()
        end
        
        -- Presets section
        local presetsLabel = vgui.Create("DLabel", panel)
        presetsLabel:SetPos(10, 230)
        presetsLabel:SetSize(panel:GetWide() - 20, 20)
        presetsLabel:SetText("Wave Templates:")
        presetsLabel:SetFont("DermaDefaultBold")
        
        -- Template browser
        local templateScroll = vgui.Create("DScrollPanel", panel)
        templateScroll:SetPos(10, 260)
        templateScroll:SetSize(panel:GetWide() - 20, 250)
        
        -- Load wave templates with error handling
        local templatesLoaded, templatesModule = pcall(function()
            include("npc/wave_templates.lua")
            return VJGM.WaveTemplates
        end)
        
        if templatesLoaded and templatesModule then
            local templates = VJGM.WaveTemplates.GetAll()
            local yPos = 0
            
            for _, template in ipairs(templates) do
                local templateCard = vgui.Create("DPanel", templateScroll)
                templateCard:SetPos(0, yPos)
                templateCard:SetSize(templateScroll:GetWide() - 20, 70)
                templateCard.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(55, 55, 55, 255))
                    
                    -- Difficulty color bar
                    local diffColor = Color(100, 100, 100, 255)
                    if template.difficulty == "Easy" then
                        diffColor = Color(100, 200, 100, 255)
                    elseif template.difficulty == "Medium" then
                        diffColor = Color(200, 200, 100, 255)
                    elseif template.difficulty == "Hard" or template.difficulty == "Very Hard" then
                        diffColor = Color(200, 100, 100, 255)
                    elseif template.difficulty == "Boss" or template.difficulty == "Endless" then
                        diffColor = Color(200, 100, 200, 255)
                    end
                    draw.RoundedBox(4, 0, 0, 4, h, diffColor)
                end
                
                -- Template name
                local nameLabel = vgui.Create("DLabel", templateCard)
                nameLabel:SetPos(10, 5)
                nameLabel:SetSize(templateCard:GetWide() - 130, 18)
                nameLabel:SetFont("DermaDefaultBold")
                nameLabel:SetText(template.name)
                
                -- Template description
                local descLabel = vgui.Create("DLabel", templateCard)
                descLabel:SetPos(10, 25)
                descLabel:SetSize(templateCard:GetWide() - 130, 16)
                descLabel:SetText(template.description)
                
                -- Difficulty badge
                local diffLabel = vgui.Create("DLabel", templateCard)
                diffLabel:SetPos(10, 45)
                diffLabel:SetSize(100, 16)
                diffLabel:SetText("⚡ " .. template.difficulty)
                diffLabel:SetTextColor(Color(150, 150, 150, 255))
                
                -- Spawn button
                local spawnTemplateBtn = vgui.Create("DButton", templateCard)
                spawnTemplateBtn:SetPos(templateCard:GetWide() - 115, 10)
                spawnTemplateBtn:SetSize(105, 50)
                spawnTemplateBtn:SetText("▶ Spawn Wave")
                spawnTemplateBtn.DoClick = function()
                    net.Start("VJGM_SpawnTemplate")
                    net.WriteString(template.id)
                    net.WriteString(groupEntry:GetValue())
                    net.SendToServer()
                    
                    -- Switch to Active Waves tab to see the result
                    timer.Simple(0.5, function()
                        if IsValid(panel:GetParent()) then
                            -- Request wave list update
                            net.Start("VJGM_RequestWaveList")
                            net.SendToServer()
                        end
                    end)
                end
                
                yPos = yPos + 75
            end
        end
    end
    
    --[[
        Create Spawn Points tab content
        @param panel: Parent panel
    ]]--
    function VJGM.GUIController.CreateSpawnPointsTab(panel)
        local header = vgui.Create("DLabel", panel)
        header:SetPos(10, 10)
        header:SetSize(panel:GetWide() - 20, 20)
        header:SetText("Spawn Point Management")
        header:SetFont("DermaDefaultBold")
        
        -- Group name
        local groupLabel = vgui.Create("DLabel", panel)
        groupLabel:SetPos(10, 40)
        groupLabel:SetText("Group Name:")
        
        local groupEntry = vgui.Create("DTextEntry", panel)
        groupEntry:SetPos(100, 40)
        groupEntry:SetSize(150, 25)
        groupEntry:SetValue("default")
        
        -- Radial spawn section
        local radialLabel = vgui.Create("DLabel", panel)
        radialLabel:SetPos(10, 80)
        radialLabel:SetSize(panel:GetWide() - 20, 20)
        radialLabel:SetText("Create Radial Spawn Points:")
        radialLabel:SetFont("DermaDefaultBold")
        
        local radiusLabel = vgui.Create("DLabel", panel)
        radiusLabel:SetPos(10, 110)
        radiusLabel:SetText("Radius:")
        
        local radiusEntry = vgui.Create("DNumberWang", panel)
        radiusEntry:SetPos(80, 110)
        radiusEntry:SetSize(100, 25)
        radiusEntry:SetValue(500)
        radiusEntry:SetMin(100)
        radiusEntry:SetMax(5000)
        
        local pointsLabel = vgui.Create("DLabel", panel)
        pointsLabel:SetPos(200, 110)
        pointsLabel:SetText("Points:")
        
        local pointsEntry = vgui.Create("DNumberWang", panel)
        pointsEntry:SetPos(260, 110)
        pointsEntry:SetSize(80, 25)
        pointsEntry:SetValue(8)
        pointsEntry:SetMin(1)
        pointsEntry:SetMax(32)
        
        local createRadialBtn = vgui.Create("DButton", panel)
        createRadialBtn:SetPos(10, 145)
        createRadialBtn:SetSize(200, 25)
        createRadialBtn:SetText("Create at Player Position")
        createRadialBtn.DoClick = function()
            local group = groupEntry:GetValue()
            local radius = tonumber(radiusEntry:GetValue()) or 500
            local points = tonumber(pointsEntry:GetValue()) or 8
            
            net.Start("VJGM_CreateRadialSpawns")
            net.WriteString(group)
            net.WriteUInt(radius, 16)
            net.WriteUInt(points, 8)
            net.SendToServer()
        end
        
        -- Import from entities
        local importLabel = vgui.Create("DLabel", panel)
        importLabel:SetPos(10, 190)
        importLabel:SetSize(panel:GetWide() - 20, 20)
        importLabel:SetText("Import from Map Entities:")
        importLabel:SetFont("DermaDefaultBold")
        
        local entityLabel = vgui.Create("DLabel", panel)
        entityLabel:SetPos(10, 220)
        entityLabel:SetText("Entity Class:")
        
        local entityEntry = vgui.Create("DTextEntry", panel)
        entityEntry:SetPos(100, 220)
        entityEntry:SetSize(200, 25)
        entityEntry:SetValue("info_player_start")
        
        local importBtn = vgui.Create("DButton", panel)
        importBtn:SetPos(10, 255)
        importBtn:SetSize(150, 25)
        importBtn:SetText("Import Spawns")
        importBtn.DoClick = function()
            local group = groupEntry:GetValue()
            local entityClass = entityEntry:GetValue()
            
            net.Start("VJGM_ImportSpawns")
            net.WriteString(group)
            net.WriteString(entityClass)
            net.SendToServer()
        end
        
        -- Clear spawns
        local clearBtn = vgui.Create("DButton", panel)
        clearBtn:SetPos(10, 300)
        clearBtn:SetSize(150, 25)
        clearBtn:SetText("Clear Spawn Group")
        clearBtn.DoClick = function()
            local group = groupEntry:GetValue()
            RunConsoleCommand("vjgm_clear_spawns", group)
        end
        
        -- List spawns
        local listBtn = vgui.Create("DButton", panel)
        listBtn:SetPos(170, 300)
        listBtn:SetSize(150, 25)
        listBtn:SetText("List Spawns (Console)")
        listBtn.DoClick = function()
            local group = groupEntry:GetValue()
            RunConsoleCommand("vjgm_list_spawns", group)
        end
        
        -- Visualization section
        local vizLabel = vgui.Create("DLabel", panel)
        vizLabel:SetPos(10, 345)
        vizLabel:SetSize(panel:GetWide() - 20, 20)
        vizLabel:SetText("3D Visualization:")
        vizLabel:SetFont("DermaDefaultBold")
        
        local toggleVizBtn = vgui.Create("DButton", panel)
        toggleVizBtn:SetPos(10, 375)
        toggleVizBtn:SetSize(150, 25)
        toggleVizBtn:SetText("Toggle Visualizer")
        toggleVizBtn.DoClick = function()
            RunConsoleCommand("vjgm_visualizer_toggle")
        end
        
        local showSpawnsBtn = vgui.Create("DButton", panel)
        showSpawnsBtn:SetPos(170, 375)
        showSpawnsBtn:SetSize(150, 25)
        showSpawnsBtn:SetText("Toggle Spawn Markers")
        showSpawnsBtn.DoClick = function()
            RunConsoleCommand("vjgm_visualizer_spawns")
        end
        
        local requestDataBtn = vgui.Create("DButton", panel)
        requestDataBtn:SetPos(10, 410)
        requestDataBtn:SetSize(150, 25)
        requestDataBtn:SetText("Refresh Visualization")
        requestDataBtn.DoClick = function()
            RunConsoleCommand("vjgm_visualizer_request_spawns")
        end
    end
    
    --[[
        Create Settings tab content
        @param panel: Parent panel
    ]]--
    function VJGM.GUIController.CreateSettingsTab(panel)
        local header = vgui.Create("DLabel", panel)
        header:SetPos(10, 10)
        header:SetSize(panel:GetWide() - 20, 20)
        header:SetText("Wave Scaling Settings")
        header:SetFont("DermaDefaultBold")
        
        local infoLabel = vgui.Create("DLabel", panel)
        infoLabel:SetPos(10, 40)
        infoLabel:SetSize(panel:GetWide() - 20, 60)
        infoLabel:SetText("These settings affect wave difficulty scaling.\nChanges require server administrator access.\nUse console commands or config file for permanent changes.")
        infoLabel:SetWrap(true)
        infoLabel:SetAutoStretchVertical(true)
        
        -- Commands section
        local commandsLabel = vgui.Create("DLabel", panel)
        commandsLabel:SetPos(10, 120)
        commandsLabel:SetSize(panel:GetWide() - 20, 20)
        commandsLabel:SetText("Quick Commands:")
        commandsLabel:SetFont("DermaDefaultBold")
        
        local helpBtn = vgui.Create("DButton", panel)
        helpBtn:SetPos(10, 150)
        helpBtn:SetSize(180, 25)
        helpBtn:SetText("Show Help (Console)")
        helpBtn.DoClick = function()
            RunConsoleCommand("vjgm_help")
        end
        
        local statusBtn = vgui.Create("DButton", panel)
        statusBtn:SetPos(200, 150)
        statusBtn:SetSize(180, 25)
        statusBtn:SetText("Wave Status (Console)")
        statusBtn.DoClick = function()
            RunConsoleCommand("vjgm_wave_status")
        end
        
        local rolesBtn = vgui.Create("DButton", panel)
        rolesBtn:SetPos(10, 185)
        rolesBtn:SetSize(180, 25)
        rolesBtn:SetText("List Roles (Console)")
        rolesBtn.DoClick = function()
            RunConsoleCommand("vjgm_list_roles")
        end
        
        local vehiclesBtn = vgui.Create("DButton", panel)
        vehiclesBtn:SetPos(200, 185)
        vehiclesBtn:SetSize(180, 25)
        vehiclesBtn:SetText("List Vehicles (Console)")
        vehiclesBtn.DoClick = function()
            RunConsoleCommand("vjgm_list_vehicles")
        end
        
        -- Visualization section
        local vizLabel = vgui.Create("DLabel", panel)
        vizLabel:SetPos(10, 230)
        vizLabel:SetSize(panel:GetWide() - 20, 20)
        vizLabel:SetText("Visualization Controls:")
        vizLabel:SetFont("DermaDefaultBold")
        
        local npcMarkersBtn = vgui.Create("DButton", panel)
        npcMarkersBtn:SetPos(10, 260)
        npcMarkersBtn:SetSize(180, 25)
        npcMarkersBtn:SetText("Toggle NPC Markers")
        npcMarkersBtn.DoClick = function()
            RunConsoleCommand("vjgm_visualizer_npcs")
        end
        
        local toggleAllVizBtn = vgui.Create("DButton", panel)
        toggleAllVizBtn:SetPos(200, 260)
        toggleAllVizBtn:SetSize(180, 25)
        toggleAllVizBtn:SetText("Toggle All Visualization")
        toggleAllVizBtn.DoClick = function()
            RunConsoleCommand("vjgm_visualizer_toggle")
        end
    end
    
    --[[
        Create wave builder interface
    ]]--
    function VJGM.GUIController.CreateWaveBuilder()
        VJGM.GUIController.OpenControlPanel()
    end
    
    --[[
        Show active waves monitor
    ]]--
    function VJGM.GUIController.ShowWaveMonitor()
        local adminOnly = VJGM.Config.Get("GUIController", "AdminOnly", true)
        
        if adminOnly and not LocalPlayer():IsAdmin() then
            print("[VJGM] Wave monitor requires admin access")
            return
        end
        
        -- Close existing monitor
        if IsValid(waveMonitor) then
            waveMonitor:Close()
        end
        
        -- Create monitor frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(500, 350)
        frame:SetPos(ScrW() - 520, 20)
        frame:SetTitle("VJGM - Wave Monitor")
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)
        frame:MakePopup()
        
        waveMonitor = frame
        
        -- Wave count
        local waveCountLabel = vgui.Create("DLabel", frame)
        waveCountLabel:SetPos(10, 30)
        waveCountLabel:SetSize(frame:GetWide() - 20, 20)
        waveCountLabel:SetText("Active Waves: 0")
        waveCountLabel:SetFont("DermaDefaultBold")
        frame.WaveCountLabel = waveCountLabel
        
        -- Wave list
        local waveList = vgui.Create("DListView", frame)
        waveList:SetPos(10, 55)
        waveList:SetSize(frame:GetWide() - 20, frame:GetTall() - 125)
        waveList:SetMultiSelect(false)
        waveList:AddColumn("Wave ID"):SetFixedWidth(100)
        waveList:AddColumn("Progress"):SetFixedWidth(80)
        waveList:AddColumn("NPCs"):SetFixedWidth(60)
        waveList:AddColumn("Status"):SetFixedWidth(80)
        frame.WaveList = waveList
        
        -- Control buttons
        local refreshBtn = vgui.Create("DButton", frame)
        refreshBtn:SetPos(10, frame:GetTall() - 60)
        refreshBtn:SetSize(80, 25)
        refreshBtn:SetText("Refresh")
        refreshBtn.DoClick = function()
            net.Start("VJGM_RequestWaveList")
            net.SendToServer()
        end
        
        local stopAllBtn = vgui.Create("DButton", frame)
        stopAllBtn:SetPos(100, frame:GetTall() - 60)
        stopAllBtn:SetSize(80, 25)
        stopAllBtn:SetText("Stop All")
        stopAllBtn.DoClick = function()
            RunConsoleCommand("vjgm_wave_stop_all")
        end
        
        local closeBtn = vgui.Create("DButton", frame)
        closeBtn:SetPos(frame:GetWide() - 90, frame:GetTall() - 60)
        closeBtn:SetSize(80, 25)
        closeBtn:SetText("Close")
        closeBtn.DoClick = function()
            frame:Close()
        end
        
        -- Auto-refresh timer
        local updateInterval = VJGM.Config.Get("GUIController", "MonitorUpdateInterval", 1)
        frame.Think = function(self)
            if not self.NextUpdate or CurTime() > self.NextUpdate then
                net.Start("VJGM_RequestWaveList")
                net.SendToServer()
                self.NextUpdate = CurTime() + updateInterval
            end
        end
        
        -- Initial refresh
        net.Start("VJGM_RequestWaveList")
        net.SendToServer()
    end
    
    --[[
        Spawn point editor (simplified version)
    ]]--
    function VJGM.GUIController.OpenSpawnPointEditor()
        -- Just open the control panel to spawn points tab
        VJGM.GUIController.OpenControlPanel()
    end
    
    -- Network message receivers
    net.Receive("VJGM_WaveListUpdate", function()
        local waveCount = net.ReadUInt(8)
        local waves = {}
        
        for i = 1, waveCount do
            local waveID = net.ReadString()
            local currentWave = net.ReadUInt(8)
            local totalWaves = net.ReadUInt(8)
            local aliveNPCs = net.ReadUInt(16)
            local isActive = net.ReadBool()
            local isPaused = net.ReadBool()
            
            table.insert(waves, {
                id = waveID,
                current = currentWave,
                total = totalWaves,
                npcs = aliveNPCs,
                active = isActive,
                paused = isPaused
            })
        end
        
        -- Update active panel if it exists
        if IsValid(activePanel) then
            -- Update statistics
            if activePanel.StatsLabel then
                local totalNPCs = 0
                local activeWaves = 0
                for _, wave in ipairs(waves) do
                    totalNPCs = totalNPCs + wave.npcs
                    if wave.active then activeWaves = activeWaves + 1 end
                end
                activePanel.StatsLabel:SetText(string.format("Total Waves: %d | Total NPCs: %d | Active: %d", 
                    waveCount, totalNPCs, activeWaves))
            end
            
            -- Update wave cards
            if activePanel.WaveContainer and activePanel.WaveCards then
                -- Clear existing cards
                for _, card in pairs(activePanel.WaveCards) do
                    if IsValid(card) then
                        card:Remove()
                    end
                end
                activePanel.WaveCards = {}
                
                -- Create new cards
                local totalHeight = 0
                for _, wave in ipairs(waves) do
                    local card = VJGM.GUIController.CreateWaveCard(activePanel.WaveContainer, wave)
                    table.insert(activePanel.WaveCards, card)
                    totalHeight = totalHeight + 130  -- Card height + margin
                end
                
                -- Update container height
                activePanel.WaveContainer:SetTall(math.max(totalHeight, 100))
            end
            
            -- Legacy list update for compatibility
            if activePanel.WaveList then
                local list = activePanel.WaveList
                list:Clear()
                
                for _, wave in ipairs(waves) do
                    local status = wave.active and "Active" or "Inactive"
                    list:AddLine(wave.id, wave.current .. "/" .. wave.total, wave.npcs, status)
                end
            end
        end
        
        -- Update wave monitor if it exists
        if IsValid(waveMonitor) then
            if waveMonitor.WaveCountLabel then
                waveMonitor.WaveCountLabel:SetText("Active Waves: " .. waveCount)
            end
            
            if waveMonitor.WaveList then
                local list = waveMonitor.WaveList
                list:Clear()
                
                for _, wave in ipairs(waves) do
                    local status = wave.active and "Active" or "Inactive"
                    list:AddLine(wave.id, wave.current .. "/" .. wave.total, wave.npcs, status)
                end
            end
        end
    end)
    
    -- Hook for future initialization
    hook.Add("Initialize", "VJGM_GUIController_Init", function()
        VJGM.GUIController.Initialize()
    end)
    
    -- Console commands for GUI access
    concommand.Add("vjgm_panel", function()
        if LocalPlayer():IsAdmin() then
            VJGM.GUIController.OpenControlPanel()
        end
    end)
    
    concommand.Add("vjgm_monitor", function()
        if LocalPlayer():IsAdmin() then
            VJGM.GUIController.ShowWaveMonitor()
        end
    end)
    
end

if SERVER then
    
    -- Load configuration
    include("npc/config/init.lua")
    
    VJGM = VJGM or {}
    VJGM.GUIController = VJGM.GUIController or {}
    
    --[[
        Setup network message handlers for GUI
    ]]--
    function VJGM.GUIController.SetupNetworking()
        -- Network strings
        util.AddNetworkString("VJGM_RequestWaveList")
        util.AddNetworkString("VJGM_WaveListUpdate")
        util.AddNetworkString("VJGM_SpawnQuickWave")
        util.AddNetworkString("VJGM_SpawnTemplate")
        util.AddNetworkString("VJGM_CreateRadialSpawns")
        util.AddNetworkString("VJGM_ImportSpawns")
        
        -- Request wave list
        net.Receive("VJGM_RequestWaveList", function(len, ply)
            if not ply:IsAdmin() then return end
            VJGM.GUIController.SendWaveList(ply)
        end)
        
        -- Spawn quick wave
        net.Receive("VJGM_SpawnQuickWave", function(len, ply)
            if not ply:IsAdmin() then return end
            
            local npcClass = net.ReadString()
            local count = net.ReadUInt(8)
            local health = net.ReadUInt(16)
            local group = net.ReadString()
            
            -- Create simple wave config
            if VJGM.WaveConfig and VJGM.NPCSpawner then
                local waveConfig = {
                    waves = {
                        {
                            npcs = {
                                {
                                    class = npcClass,
                                    count = count,
                                    customization = {
                                        health = health,
                                        vjbase = {
                                            faction = "VJ_FACTION_PLAYER"
                                        }
                                    }
                                }
                            },
                            spawnPointGroup = group,
                            interval = 0
                        }
                    },
                    defaultInterval = 30,
                    cleanupOnComplete = false
                }
                
                VJGM.NPCSpawner.StartWave(waveConfig)
            end
        end)
        
        -- Spawn from template
        net.Receive("VJGM_SpawnTemplate", function(len, ply)
            if not ply:IsAdmin() then return end
            
            local templateID = net.ReadString()
            local spawnGroup = net.ReadString()
            
            -- Wave templates should already be loaded
            if VJGM.WaveTemplates then
                local waveID = VJGM.WaveTemplates.SpawnFromTemplate(templateID, spawnGroup)
                
                if waveID then
                    print("[VJGM] Spawned wave from template: " .. templateID .. " (Wave ID: " .. waveID .. ")")
                else
                    ErrorNoHalt("[VJGM] Failed to spawn wave from template: " .. templateID .. "\n")
                end
            else
                ErrorNoHalt("[VJGM] Wave templates system not loaded\n")
            end
        end)
        
        -- Create radial spawns
        net.Receive("VJGM_CreateRadialSpawns", function(len, ply)
            if not ply:IsAdmin() then return end
            
            local group = net.ReadString()
            local radius = net.ReadUInt(16)
            local points = net.ReadUInt(8)
            
            if VJGM.SpawnPoints then
                local playerPos = ply:GetPos() + ply:GetForward() * 300
                VJGM.SpawnPoints.RegisterInRadius(group, playerPos, radius, points)
            end
        end)
        
        -- Import spawns
        net.Receive("VJGM_ImportSpawns", function(len, ply)
            if not ply:IsAdmin() then return end
            
            local group = net.ReadString()
            local entityClass = net.ReadString()
            
            if VJGM.SpawnPoints then
                VJGM.SpawnPoints.RegisterFromEntities(group, entityClass)
            end
        end)
    end
    
    --[[
        Send wave list to client
        @param ply: Player to send to
    ]]--
    function VJGM.GUIController.SendWaveList(ply)
        if not VJGM.NPCSpawner then return end
        
        local activeWaves = VJGM.NPCSpawner.GetActiveWaves()
        
        net.Start("VJGM_WaveListUpdate")
        net.WriteUInt(#activeWaves, 8)
        
        for _, waveID in ipairs(activeWaves) do
            local status = VJGM.NPCSpawner.GetWaveStatus(waveID)
            if status then
                net.WriteString(status.waveID)
                net.WriteUInt(status.currentWave, 8)
                net.WriteUInt(status.totalWaves, 8)
                net.WriteUInt(status.aliveNPCs, 16)
                net.WriteBool(status.isActive)
                net.WriteBool(status.isPaused)
            end
        end
        
        net.Send(ply)
    end
    
    --[[
        Broadcast wave status to all admins
        @param waveID: Wave instance identifier
    ]]--
    function VJGM.GUIController.BroadcastWaveStatus(waveID)
        if not VJGM.NPCSpawner then return end
        
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                VJGM.GUIController.SendWaveList(ply)
            end
        end
    end
    
    -- Setup networking on initialization
    hook.Add("Initialize", "VJGM_GUIController_Server_Init", function()
        VJGM.GUIController.SetupNetworking()
    end)
    
end

--[[
    USAGE EXAMPLE (Future):
    
    CLIENT:
    -- Open control panel (admin/gamemaster only)
    concommand.Add("vjgm_panel", function()
        if LocalPlayer():IsAdmin() then
            VJGM.GUIController.OpenControlPanel()
        end
    end)
    
    -- Quick wave monitor
    concommand.Add("vjgm_monitor", function()
        if LocalPlayer():IsAdmin() then
            VJGM.GUIController.ShowWaveMonitor()
        end
    end)
    
    SERVER:
    -- When wave status changes
    hook.Add("VJGM_WaveStatusChanged", "UpdateGUI", function(waveID)
        VJGM.GUIController.BroadcastWaveStatus(waveID)
    end)
]]--
