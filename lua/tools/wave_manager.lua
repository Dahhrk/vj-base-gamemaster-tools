--[[
    Wave Manager - Enhanced with Onyx UI
    
    Features:
    - Tabs for managing multiple waves
    - Control buttons (Start, Pause, Restart)
    - Real-time stats with progress bars
    - NPC count displays
    - Wave state management
    
    NOTE: This is a UI framework that requires integration with your wave spawning system.
    The server-side network message handlers contain example integration code.
    Connect these handlers to your existing VJGM.DynamicSpawner or similar system.
]]--

if CLIENT then
    
    -- Load Onyx UI if not already loaded
    if not Onyx then
        include("libraries/onyx_framework/onyx_init.lua")
    end
    
    VJGM = VJGM or {}
    VJGM.WaveManager = VJGM.WaveManager or {}
    
    local activeManager = nil
    local wavesData = {}
    local updateTimer = nil
    
    --[[
        Open the Wave Manager
    ]]--
    function VJGM.WaveManager.Open()
        if not LocalPlayer():IsAdmin() then
            chat.AddText(Color(255, 100, 100), "[VJGM] ", Color(255, 255, 255), "Wave Manager requires admin access")
            return
        end
        
        -- Close existing manager
        if IsValid(activeManager) then
            activeManager:Close()
        end
        
        -- Create main frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(900, 600)
        frame:Center()
        frame:SetTitle("VJGM - Wave Manager")
        frame:MakePopup()
        
        activeManager = frame
        
        -- Create main container
        local container = vgui.Create("DPanel", frame)
        container:Dock(FILL)
        container.Paint = function() end
        
        -- Create tabs
        local tabs = vgui.Create("OnyxTabs", container)
        tabs:Dock(FILL)
        tabs:DockMargin(5, 5, 5, 5)
        
        -- Active Waves Tab
        local activeWavesContent = tabs:AddTab("Active Waves", "icon16/application_view_list.png", function(panel)
            VJGM.WaveManager.CreateActiveWavesPanel(panel)
        end)
        
        -- Wave Templates Tab
        local templatesContent = tabs:AddTab("Wave Templates", "icon16/page_white_stack.png", function(panel)
            VJGM.WaveManager.CreateTemplatesPanel(panel)
        end)
        
        -- Wave Statistics Tab
        local statsContent = tabs:AddTab("Statistics", "icon16/chart_bar.png", function(panel)
            VJGM.WaveManager.CreateStatsPanel(panel)
        end)
        
        -- Settings Tab
        local settingsContent = tabs:AddTab("Settings", "icon16/cog.png", function(panel)
            VJGM.WaveManager.CreateSettingsPanel(panel)
        end)
        
        -- Store reference
        frame.tabs = tabs
        
        -- Start update timer
        VJGM.WaveManager.StartUpdateTimer()
        
        -- Request initial data
        VJGM.WaveManager.RequestWaveData()
    end
    
    --[[
        Create Active Waves Panel
    ]]--
    function VJGM.WaveManager.CreateActiveWavesPanel(parent)
        -- Scroll container
        local scroll = vgui.Create("DScrollPanel", parent)
        scroll:Dock(FILL)
        scroll:DockMargin(5, 5, 5, 5)
        
        -- Stats header
        local statsHeader = vgui.Create("OnyxPanel", scroll)
        statsHeader:Dock(TOP)
        statsHeader:SetHeight(80)
        statsHeader:DockMargin(0, 0, 0, 10)
        statsHeader:SetBackgroundColor(Onyx.Colors.Primary)
        
        local totalWavesLabel = vgui.Create("DLabel", statsHeader)
        totalWavesLabel:SetText("Total Active Waves: 0")
        totalWavesLabel:SetFont(Onyx.Fonts.Heading)
        totalWavesLabel:SetTextColor(Onyx.Colors.Text)
        totalWavesLabel:Dock(TOP)
        totalWavesLabel:DockMargin(15, 10, 15, 2)
        
        local totalNPCsLabel = vgui.Create("DLabel", statsHeader)
        totalNPCsLabel:SetText("Total NPCs Spawned: 0")
        totalNPCsLabel:SetFont(Onyx.Fonts.Body)
        totalNPCsLabel:SetTextColor(Onyx.Colors.Text)
        totalNPCsLabel:Dock(TOP)
        totalNPCsLabel:DockMargin(15, 2, 15, 10)
        
        -- Wave cards container
        local waveCards = vgui.Create("DPanel", scroll)
        waveCards:Dock(FILL)
        waveCards.Paint = function() end
        
        -- Store references
        parent.statsHeader = statsHeader
        parent.totalWavesLabel = totalWavesLabel
        parent.totalNPCsLabel = totalNPCsLabel
        parent.waveCards = waveCards
        
        -- Populate with waves
        VJGM.WaveManager.RefreshActiveWaves(parent)
    end
    
    --[[
        Refresh Active Waves Display
    ]]--
    function VJGM.WaveManager.RefreshActiveWaves(parent)
        if not IsValid(parent) or not IsValid(parent.waveCards) then return end
        
        parent.waveCards:Clear()
        
        local totalWaves = 0
        local totalNPCs = 0
        
        -- Create wave cards
        for waveID, waveData in pairs(wavesData) do
            totalWaves = totalWaves + 1
            totalNPCs = totalNPCs + (waveData.npcCount or 0)
            
            local card = VJGM.WaveManager.CreateWaveCard(parent.waveCards, waveData)
            card:Dock(TOP)
            card:DockMargin(0, 0, 0, 10)
        end
        
        -- Update stats
        if IsValid(parent.totalWavesLabel) then
            parent.totalWavesLabel:SetText("Total Active Waves: " .. totalWaves)
        end
        
        if IsValid(parent.totalNPCsLabel) then
            parent.totalNPCsLabel:SetText("Total NPCs Spawned: " .. totalNPCs)
        end
    end
    
    --[[
        Create Wave Card
    ]]--
    function VJGM.WaveManager.CreateWaveCard(parent, waveData)
        local card = vgui.Create("OnyxPanel", parent)
        card:SetHeight(120)
        card:SetBorderWidth(1)
        card:SetBorderColor(Onyx.Colors.Border)
        
        -- Wave name
        local nameLabel = vgui.Create("DLabel", card)
        nameLabel:SetText(waveData.name or "Wave " .. (waveData.id or "Unknown"))
        nameLabel:SetFont(Onyx.Fonts.Heading)
        nameLabel:SetTextColor(Onyx.Colors.Text)
        nameLabel:Dock(TOP)
        nameLabel:DockMargin(10, 10, 10, 2)
        
        -- Wave info
        local infoLabel = vgui.Create("DLabel", card)
        infoLabel:SetText(string.format("Progress: %d / %d | NPCs: %d | Status: %s", 
            waveData.current or 0,
            waveData.total or 0,
            waveData.npcCount or 0,
            waveData.active and "Active" or "Paused"
        ))
        infoLabel:SetFont(Onyx.Fonts.Small)
        infoLabel:SetTextColor(Onyx.Colors.TextDim)
        infoLabel:Dock(TOP)
        infoLabel:DockMargin(10, 2, 10, 5)
        
        -- Progress bar
        local progressBg = vgui.Create("DPanel", card)
        progressBg:Dock(TOP)
        progressBg:SetHeight(20)
        progressBg:DockMargin(10, 5, 10, 5)
        progressBg.Paint = function(self, w, h)
            -- Background
            draw.RoundedBox(4, 0, 0, w, h, Onyx.Colors.Background)
            
            -- Progress fill
            local progress = (waveData.current or 0) / math.max(waveData.total or 1, 1)
            local fillW = w * progress
            local fillColor = waveData.active and Onyx.Colors.Success or Onyx.Colors.Warning
            draw.RoundedBox(4, 0, 0, fillW, h, fillColor)
            
            -- Text
            draw.SimpleText(
                string.format("%d%%", progress * 100),
                Onyx.Fonts.Small,
                w / 2,
                h / 2,
                Onyx.Colors.Text,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
        end
        
        -- Control buttons
        local buttonPanel = vgui.Create("DPanel", card)
        buttonPanel:Dock(FILL)
        buttonPanel:DockMargin(10, 5, 10, 10)
        buttonPanel.Paint = function() end
        
        -- Pause/Resume button
        local pauseButton = vgui.Create("OnyxButton", buttonPanel)
        pauseButton:Dock(LEFT)
        pauseButton:SetWide(100)
        pauseButton:DockMargin(0, 0, 5, 0)
        pauseButton:SetButtonText(waveData.active and "Pause" or "Resume")
        pauseButton:SetBackgroundColor(waveData.active and Onyx.Colors.Warning or Onyx.Colors.Success)
        pauseButton.DoClick = function()
            VJGM.WaveManager.ToggleWave(waveData.id)
        end
        
        -- Stop button
        local stopButton = vgui.Create("OnyxButton", buttonPanel)
        stopButton:Dock(LEFT)
        stopButton:SetWide(100)
        stopButton:DockMargin(5, 0, 5, 0)
        stopButton:SetButtonText("Stop")
        stopButton:SetBackgroundColor(Onyx.Colors.Error)
        stopButton.DoClick = function()
            VJGM.WaveManager.StopWave(waveData.id)
        end
        
        -- Restart button
        local restartButton = vgui.Create("OnyxButton", buttonPanel)
        restartButton:Dock(LEFT)
        restartButton:SetWide(100)
        restartButton:DockMargin(5, 0, 0, 0)
        restartButton:SetButtonText("Restart")
        restartButton:SetBackgroundColor(Onyx.Colors.Primary)
        restartButton.DoClick = function()
            VJGM.WaveManager.RestartWave(waveData.id)
        end
        
        return card
    end
    
    --[[
        Create Templates Panel
    ]]--
    function VJGM.WaveManager.CreateTemplatesPanel(parent)
        local scroll = vgui.Create("DScrollPanel", parent)
        scroll:Dock(FILL)
        scroll:DockMargin(5, 5, 5, 5)
        
        local infoLabel = vgui.Create("DLabel", scroll)
        infoLabel:SetText("Wave Templates - Quick Start Configurations")
        infoLabel:SetFont(Onyx.Fonts.Heading)
        infoLabel:SetTextColor(Onyx.Colors.Text)
        infoLabel:Dock(TOP)
        infoLabel:DockMargin(10, 10, 10, 10)
        
        -- Template placeholder
        local templateInfo = vgui.Create("OnyxPanel", scroll)
        templateInfo:Dock(FILL)
        templateInfo:DockMargin(10, 0, 10, 10)
        
        local templateText = vgui.Create("DLabel", templateInfo)
        templateText:SetText("Wave templates from the existing system will appear here.\n\nUse the Wave Builder tab in the main panel to create waves from templates.")
        templateText:SetFont(Onyx.Fonts.Body)
        templateText:SetTextColor(Onyx.Colors.TextDim)
        templateText:Dock(FILL)
        templateText:DockMargin(15, 15, 15, 15)
        templateText:SetWrap(true)
        templateText:SetAutoStretchVertical(true)
    end
    
    --[[
        Create Statistics Panel
    ]]--
    function VJGM.WaveManager.CreateStatsPanel(parent)
        local scroll = vgui.Create("DScrollPanel", parent)
        scroll:Dock(FILL)
        scroll:DockMargin(5, 5, 5, 5)
        
        local titleLabel = vgui.Create("DLabel", scroll)
        titleLabel:SetText("Wave Statistics")
        titleLabel:SetFont(Onyx.Fonts.Heading)
        titleLabel:SetTextColor(Onyx.Colors.Text)
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(10, 10, 10, 10)
        
        -- Stats panel
        local statsPanel = vgui.Create("OnyxPanel", scroll)
        statsPanel:Dock(FILL)
        statsPanel:DockMargin(10, 0, 10, 10)
        
        local statsText = vgui.Create("DLabel", statsPanel)
        statsText:SetText("Detailed wave statistics and analytics will be displayed here.\n\nThis includes:\n- Wave completion rates\n- Average NPC survival time\n- Player performance metrics\n- Event timeline data")
        statsText:SetFont(Onyx.Fonts.Body)
        statsText:SetTextColor(Onyx.Colors.TextDim)
        statsText:Dock(FILL)
        statsText:DockMargin(15, 15, 15, 15)
        statsText:SetWrap(true)
        statsText:SetAutoStretchVertical(true)
    end
    
    --[[
        Create Settings Panel
    ]]--
    function VJGM.WaveManager.CreateSettingsPanel(parent)
        local scroll = vgui.Create("DScrollPanel", parent)
        scroll:Dock(FILL)
        scroll:DockMargin(5, 5, 5, 5)
        
        local titleLabel = vgui.Create("DLabel", scroll)
        titleLabel:SetText("Wave Manager Settings")
        titleLabel:SetFont(Onyx.Fonts.Heading)
        titleLabel:SetTextColor(Onyx.Colors.Text)
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(10, 10, 10, 10)
        
        -- Auto-refresh setting
        local autoRefreshPanel = vgui.Create("OnyxPanel", scroll)
        autoRefreshPanel:Dock(TOP)
        autoRefreshPanel:SetHeight(80)
        autoRefreshPanel:DockMargin(10, 0, 10, 10)
        
        local autoRefreshLabel = vgui.Create("DLabel", autoRefreshPanel)
        autoRefreshLabel:SetText("Auto-Refresh Interval (seconds):")
        autoRefreshLabel:SetFont(Onyx.Fonts.Body)
        autoRefreshLabel:SetTextColor(Onyx.Colors.Text)
        autoRefreshLabel:Dock(TOP)
        autoRefreshLabel:DockMargin(10, 10, 10, 5)
        
        local refreshSlider = vgui.Create("OnyxSlider", autoRefreshPanel)
        refreshSlider:Dock(TOP)
        refreshSlider:SetHeight(30)
        refreshSlider:DockMargin(10, 5, 10, 10)
        refreshSlider:SetMin(1)
        refreshSlider:SetMax(10)
        refreshSlider:SetValue(2)
        refreshSlider:SetDecimals(0)
        refreshSlider:SetSuffix("s")
    end
    
    --[[
        Wave Control Functions
    ]]--
    function VJGM.WaveManager.ToggleWave(waveID)
        net.Start("VJGM_ToggleWave")
        net.WriteString(tostring(waveID))
        net.SendToServer()
    end
    
    function VJGM.WaveManager.StopWave(waveID)
        net.Start("VJGM_StopWave")
        net.WriteString(tostring(waveID))
        net.SendToServer()
    end
    
    function VJGM.WaveManager.RestartWave(waveID)
        net.Start("VJGM_RestartWave")
        net.WriteString(tostring(waveID))
        net.SendToServer()
    end
    
    function VJGM.WaveManager.RequestWaveData()
        net.Start("VJGM_RequestWaveData")
        net.SendToServer()
    end
    
    --[[
        Update Timer
    ]]--
    function VJGM.WaveManager.StartUpdateTimer()
        if updateTimer then
            timer.Remove(updateTimer)
        end
        
        local timerName = "VJGM_WaveManager_Update"
        timer.Create(timerName, 2, 0, function()
            if IsValid(activeManager) then
                VJGM.WaveManager.RequestWaveData()
            else
                timer.Remove(timerName)
            end
        end)
        
        updateTimer = timerName
    end
    
    --[[
        Network Receivers
    ]]--
    net.Receive("VJGM_WaveData", function()
        local data = net.ReadTable()
        wavesData = data
        
        -- Update active manager if open
        if IsValid(activeManager) and IsValid(activeManager.tabs) then
            local activeTab = activeManager.tabs:GetActiveTab()
            if activeTab and activeTab.name == "Active Waves" then
                VJGM.WaveManager.RefreshActiveWaves(activeTab.content)
            end
        end
    end)
    
    -- Console command to open manager
    concommand.Add("vjgm_wave_manager", function()
        VJGM.WaveManager.Open()
    end)
    
end

--[[
    SERVER-SIDE NETWORKING
]]--
if SERVER then
    
    util.AddNetworkString("VJGM_ToggleWave")
    util.AddNetworkString("VJGM_StopWave")
    util.AddNetworkString("VJGM_RestartWave")
    util.AddNetworkString("VJGM_RequestWaveData")
    util.AddNetworkString("VJGM_WaveData")
    
    -- Handle toggle wave
    net.Receive("VJGM_ToggleWave", function(len, ply)
        if not ply:IsAdmin() then return end
        local waveID = net.ReadString()
        
        -- TODO: Integrate with existing wave system
        -- Example integration:
        -- if VJGM and VJGM.DynamicSpawner and VJGM.DynamicSpawner.ToggleWave then
        --     VJGM.DynamicSpawner.ToggleWave(waveID)
        -- end
        
        print("[VJGM Wave Manager] " .. ply:Nick() .. " toggled wave: " .. waveID)
    end)
    
    -- Handle stop wave
    net.Receive("VJGM_StopWave", function(len, ply)
        if not ply:IsAdmin() then return end
        local waveID = net.ReadString()
        
        -- TODO: Integrate with existing wave system
        -- Example integration:
        -- if VJGM and VJGM.DynamicSpawner and VJGM.DynamicSpawner.StopWave then
        --     VJGM.DynamicSpawner.StopWave(waveID)
        -- end
        
        print("[VJGM Wave Manager] " .. ply:Nick() .. " stopped wave: " .. waveID)
    end)
    
    -- Handle restart wave
    net.Receive("VJGM_RestartWave", function(len, ply)
        if not ply:IsAdmin() then return end
        local waveID = net.ReadString()
        
        -- TODO: Integrate with existing wave system
        -- Example integration:
        -- if VJGM and VJGM.DynamicSpawner and VJGM.DynamicSpawner.RestartWave then
        --     VJGM.DynamicSpawner.RestartWave(waveID)
        -- end
        
        print("[VJGM Wave Manager] " .. ply:Nick() .. " restarted wave: " .. waveID)
    end)
    
    -- Handle wave data request
    net.Receive("VJGM_RequestWaveData", function(len, ply)
        if not ply:IsAdmin() then return end
        
        local waveData = {}
        
        -- TODO: Collect wave data from existing wave system
        -- Example integration:
        -- if VJGM and VJGM.DynamicSpawner and VJGM.DynamicSpawner.GetActiveWaves then
        --     waveData = VJGM.DynamicSpawner.GetActiveWaves()
        -- end
        
        net.Start("VJGM_WaveData")
        net.WriteTable(waveData)
        net.Send(ply)
    end)
    
end
