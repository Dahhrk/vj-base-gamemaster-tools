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
        Create Active Waves tab content
        @param panel: Parent panel
    ]]--
    function VJGM.GUIController.CreateActiveWavesTab(panel)
        -- Header
        local header = vgui.Create("DLabel", panel)
        header:SetPos(10, 10)
        header:SetSize(panel:GetWide() - 20, 20)
        header:SetText("Active Wave Management")
        header:SetFont("DermaDefaultBold")
        
        -- Refresh button
        local refreshBtn = vgui.Create("DButton", panel)
        refreshBtn:SetPos(10, 35)
        refreshBtn:SetSize(100, 25)
        refreshBtn:SetText("Refresh")
        refreshBtn.DoClick = function()
            net.Start("VJGM_RequestWaveList")
            net.SendToServer()
        end
        
        -- Stop All button
        local stopAllBtn = vgui.Create("DButton", panel)
        stopAllBtn:SetPos(120, 35)
        stopAllBtn:SetSize(100, 25)
        stopAllBtn:SetText("Stop All")
        stopAllBtn.DoClick = function()
            if not LocalPlayer():IsAdmin() then return end
            RunConsoleCommand("vjgm_wave_stop_all")
            timer.Simple(0.5, function()
                net.Start("VJGM_RequestWaveList")
                net.SendToServer()
            end)
        end
        
        -- Wave list
        local waveList = vgui.Create("DListView", panel)
        waveList:SetPos(10, 70)
        waveList:SetSize(panel:GetWide() - 20, panel:GetTall() - 140)
        waveList:SetMultiSelect(false)
        waveList:AddColumn("Wave ID")
        waveList:AddColumn("Current/Total")
        waveList:AddColumn("NPCs Alive")
        waveList:AddColumn("Status")
        
        panel.WaveList = waveList
        
        -- Control buttons
        local pauseBtn = vgui.Create("DButton", panel)
        pauseBtn:SetPos(10, panel:GetTall() - 60)
        pauseBtn:SetSize(100, 25)
        pauseBtn:SetText("Pause")
        pauseBtn.DoClick = function()
            local selected = waveList:GetSelectedLine()
            if selected then
                local waveID = waveList:GetLine(selected):GetValue(1)
                RunConsoleCommand("vjgm_wave_pause", waveID)
            end
        end
        
        local resumeBtn = vgui.Create("DButton", panel)
        resumeBtn:SetPos(120, panel:GetTall() - 60)
        resumeBtn:SetSize(100, 25)
        resumeBtn:SetText("Resume")
        resumeBtn.DoClick = function()
            local selected = waveList:GetSelectedLine()
            if selected then
                local waveID = waveList:GetLine(selected):GetValue(1)
                RunConsoleCommand("vjgm_wave_resume", waveID)
            end
        end
        
        local stopBtn = vgui.Create("DButton", panel)
        stopBtn:SetPos(230, panel:GetTall() - 60)
        stopBtn:SetSize(100, 25)
        stopBtn:SetText("Stop")
        stopBtn.DoClick = function()
            local selected = waveList:GetSelectedLine()
            if selected then
                local waveID = waveList:GetLine(selected):GetValue(1)
                RunConsoleCommand("vjgm_wave_stop", waveID)
                timer.Simple(0.5, function()
                    net.Start("VJGM_RequestWaveList")
                    net.SendToServer()
                end)
            end
        end
        
        -- Request initial data
        timer.Simple(0.1, function()
            net.Start("VJGM_RequestWaveList")
            net.SendToServer()
        end)
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
        presetsLabel:SetText("Quick Presets:")
        presetsLabel:SetFont("DermaDefaultBold")
        
        local basicBtn = vgui.Create("DButton", panel)
        basicBtn:SetPos(10, 260)
        basicBtn:SetSize(150, 25)
        basicBtn:SetText("Basic Wave")
        basicBtn.DoClick = function()
            RunConsoleCommand("vjgm_test_basic")
        end
        
        local roleBtn = vgui.Create("DButton", panel)
        roleBtn:SetPos(170, 260)
        roleBtn:SetSize(150, 25)
        roleBtn:SetText("Role Squad Wave")
        roleBtn.DoClick = function()
            RunConsoleCommand("vjgm_test_role_wave")
        end
        
        local vehicleBtn = vgui.Create("DButton", panel)
        vehicleBtn:SetPos(330, 260)
        vehicleBtn:SetSize(150, 25)
        vehicleBtn:SetText("Vehicle Wave")
        vehicleBtn.DoClick = function()
            RunConsoleCommand("vjgm_test_vehicle_wave")
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
            
            table.insert(waves, {
                id = waveID,
                current = currentWave,
                total = totalWaves,
                npcs = aliveNPCs,
                active = isActive
            })
        end
        
        -- Update active panel if it exists
        if IsValid(activePanel) and activePanel.WaveList then
            local list = activePanel.WaveList
            list:Clear()
            
            for _, wave in ipairs(waves) do
                local status = wave.active and "Active" or "Inactive"
                list:AddLine(wave.id, wave.current .. "/" .. wave.total, wave.npcs, status)
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
