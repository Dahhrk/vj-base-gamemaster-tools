--[[
    Dynamic Events Dashboard - Enhanced with Onyx UI
    
    Features:
    - Event timeline visualization
    - Control buttons for environmental effects
    - Wave spawn triggers
    - Real-time analytics panel
    - Event logs display
]]--

if CLIENT then
    
    -- Load Onyx UI if not already loaded
    if not Onyx then
        include("libraries/onyx_framework/onyx_init.lua")
    end
    
    VJGM = VJGM or {}
    VJGM.EventsDashboard = VJGM.EventsDashboard or {}
    
    local activeDashboard = nil
    local eventLogs = {}
    local currentEventTime = 0
    
    --[[
        Open the Events Dashboard
    ]]--
    function VJGM.EventsDashboard.Open()
        if not LocalPlayer():IsAdmin() then
            chat.AddText(Color(255, 100, 100), "[VJGM] ", Color(255, 255, 255), "Events Dashboard requires admin access")
            return
        end
        
        -- Close existing dashboard
        if IsValid(activeDashboard) then
            activeDashboard:Close()
        end
        
        -- Create main frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(1100, 700)
        frame:Center()
        frame:SetTitle("VJGM - Dynamic Events Dashboard")
        frame:MakePopup()
        
        activeDashboard = frame
        
        -- Create main container
        local container = vgui.Create("DPanel", frame)
        container:Dock(FILL)
        container.Paint = function() end
        
        -- Top section: Timeline
        local timelinePanel = vgui.Create("OnyxPanel", container)
        timelinePanel:Dock(TOP)
        timelinePanel:SetHeight(150)
        timelinePanel:DockMargin(5, 5, 5, 5)
        
        local timelineLabel = vgui.Create("DLabel", timelinePanel)
        timelineLabel:SetText("Event Timeline")
        timelineLabel:SetFont(Onyx.Fonts.Heading)
        timelineLabel:SetTextColor(Onyx.Colors.Text)
        timelineLabel:Dock(TOP)
        timelineLabel:SetHeight(30)
        timelineLabel:DockMargin(10, 10, 10, 5)
        
        local timeline = vgui.Create("OnyxTimeline", timelinePanel)
        timeline:Dock(FILL)
        timeline:DockMargin(10, 5, 10, 10)
        timeline:SetMaxTime(600)  -- 10 minutes
        
        -- Add sample events
        timeline:AddEvent("Preparation Phase", 0, 60, Onyx.Colors.Primary)
        timeline:AddEvent("Wave 1", 60, 180, Onyx.Colors.Success)
        timeline:AddEvent("Intermission", 180, 210, Onyx.Colors.Warning)
        timeline:AddEvent("Wave 2", 210, 360, Onyx.Colors.Error)
        timeline:AddEvent("Boss Phase", 360, 540, Onyx.Colors.Accent)
        timeline:AddEvent("Cleanup", 540, 600, Onyx.Colors.Primary)
        
        timeline.OnTimelineClicked = function(self, time)
            VJGM.EventsDashboard.SetEventTime(time)
        end
        
        -- Middle section: Control Panel and Analytics
        local middlePanel = vgui.Create("DPanel", container)
        middlePanel:Dock(FILL)
        middlePanel:DockMargin(5, 0, 5, 5)
        middlePanel.Paint = function() end
        
        -- Left: Control Panel
        local controlPanel = vgui.Create("OnyxPanel", middlePanel)
        controlPanel:Dock(LEFT)
        controlPanel:SetWide(500)
        controlPanel:DockMargin(0, 0, 5, 0)
        
        VJGM.EventsDashboard.CreateControlPanel(controlPanel)
        
        -- Right: Analytics Panel
        local analyticsPanel = vgui.Create("OnyxPanel", middlePanel)
        analyticsPanel:Dock(FILL)
        
        VJGM.EventsDashboard.CreateAnalyticsPanel(analyticsPanel)
        
        -- Bottom section: Event Logs
        local logsPanel = vgui.Create("OnyxPanel", container)
        logsPanel:Dock(BOTTOM)
        logsPanel:SetHeight(150)
        logsPanel:DockMargin(5, 0, 5, 5)
        
        VJGM.EventsDashboard.CreateLogsPanel(logsPanel)
        
        -- Store references
        frame.timeline = timeline
        frame.controlPanel = controlPanel
        frame.analyticsPanel = analyticsPanel
        frame.logsPanel = logsPanel
        
        -- Start update timer
        timer.Create("VJGM_EventsDashboard_Update", 1, 0, function()
            if IsValid(frame) then
                currentEventTime = currentEventTime + 1
                if currentEventTime > 600 then currentEventTime = 0 end
                timeline:SetCurrentTime(currentEventTime)
            else
                timer.Remove("VJGM_EventsDashboard_Update")
            end
        end)
    end
    
    --[[
        Create Control Panel
    ]]--
    function VJGM.EventsDashboard.CreateControlPanel(parent)
        local titleLabel = vgui.Create("DLabel", parent)
        titleLabel:SetText("Event Controls")
        titleLabel:SetFont(Onyx.Fonts.Heading)
        titleLabel:SetTextColor(Onyx.Colors.Text)
        titleLabel:Dock(TOP)
        titleLabel:SetHeight(30)
        titleLabel:DockMargin(10, 10, 10, 10)
        
        local scroll = vgui.Create("DScrollPanel", parent)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 0, 10, 10)
        
        -- Environmental Effects Section
        local envSection = vgui.Create("OnyxPanel", scroll)
        envSection:Dock(TOP)
        envSection:SetHeight(200)
        envSection:DockMargin(0, 0, 0, 10)
        envSection:SetBackgroundColor(Onyx.Colors.Background)
        
        local envLabel = vgui.Create("DLabel", envSection)
        envLabel:SetText("Environmental Effects")
        envLabel:SetFont(Onyx.Fonts.Body)
        envLabel:SetTextColor(Onyx.Colors.Text)
        envLabel:Dock(TOP)
        envLabel:DockMargin(10, 10, 10, 5)
        
        -- Effect buttons in a grid
        local buttonGrid = vgui.Create("DPanel", envSection)
        buttonGrid:Dock(FILL)
        buttonGrid:DockMargin(10, 5, 10, 10)
        buttonGrid.Paint = function() end
        
        local buttons = {
            {name = "Fog", color = Onyx.Colors.TextDim, effect = "fog"},
            {name = "Rain", color = Color(100, 150, 200), effect = "rain"},
            {name = "Fire", color = Onyx.Colors.Error, effect = "fire"},
            {name = "Explosions", color = Onyx.Colors.Warning, effect = "explosions"},
            {name = "Lightning", color = Color(255, 255, 100), effect = "lightning"},
            {name = "Clear Effects", color = Onyx.Colors.Success, effect = "clear"},
        }
        
        local buttonW = 140
        local buttonH = 40
        local spacing = 10
        local col = 0
        local row = 0
        
        for i, btnData in ipairs(buttons) do
            local btn = vgui.Create("OnyxButton", buttonGrid)
            btn:SetPos(col * (buttonW + spacing), row * (buttonH + spacing))
            btn:SetSize(buttonW, buttonH)
            btn:SetButtonText(btnData.name)
            btn:SetBackgroundColor(btnData.color)
            btn.DoClick = function()
                VJGM.EventsDashboard.TriggerEffect(btnData.effect)
            end
            
            col = col + 1
            if col >= 3 then
                col = 0
                row = row + 1
            end
        end
        
        -- Wave Triggers Section
        local waveSection = vgui.Create("OnyxPanel", scroll)
        waveSection:Dock(TOP)
        waveSection:SetHeight(150)
        waveSection:DockMargin(0, 0, 0, 10)
        waveSection:SetBackgroundColor(Onyx.Colors.Background)
        
        local waveLabel = vgui.Create("DLabel", waveSection)
        waveLabel:SetText("Wave Triggers")
        waveLabel:SetFont(Onyx.Fonts.Body)
        waveLabel:SetTextColor(Onyx.Colors.Text)
        waveLabel:Dock(TOP)
        waveLabel:DockMargin(10, 10, 10, 5)
        
        local waveButtons = vgui.Create("DPanel", waveSection)
        waveButtons:Dock(FILL)
        waveButtons:DockMargin(10, 5, 10, 10)
        waveButtons.Paint = function() end
        
        local waves = {
            {name = "Light Wave", difficulty = "Easy"},
            {name = "Standard Wave", difficulty = "Medium"},
            {name = "Heavy Wave", difficulty = "Hard"},
            {name = "Boss Wave", difficulty = "Boss"},
        }
        
        col = 0
        row = 0
        
        for i, waveData in ipairs(waves) do
            local btn = vgui.Create("OnyxButton", waveButtons)
            btn:SetPos(col * (buttonW + spacing), row * (buttonH + spacing))
            btn:SetSize(buttonW, buttonH)
            btn:SetButtonText(waveData.name)
            btn:SetBackgroundColor(Onyx.Colors.Primary)
            btn.DoClick = function()
                VJGM.EventsDashboard.TriggerWave(waveData.name)
            end
            
            col = col + 1
            if col >= 3 then
                col = 0
                row = row + 1
            end
        end
        
        -- Modifications Section
        local modSection = vgui.Create("OnyxPanel", scroll)
        modSection:Dock(TOP)
        modSection:SetHeight(120)
        modSection:DockMargin(0, 0, 0, 10)
        modSection:SetBackgroundColor(Onyx.Colors.Background)
        
        local modLabel = vgui.Create("DLabel", modSection)
        modLabel:SetText("Event Modifications")
        modLabel:SetFont(Onyx.Fonts.Body)
        modLabel:SetTextColor(Onyx.Colors.Text)
        modLabel:Dock(TOP)
        modLabel:DockMargin(10, 10, 10, 5)
        
        local modInfo = vgui.Create("DLabel", modSection)
        modInfo:SetText("Real-time event modifications and adjustments")
        modInfo:SetFont(Onyx.Fonts.Small)
        modInfo:SetTextColor(Onyx.Colors.TextDim)
        modInfo:Dock(TOP)
        modInfo:DockMargin(10, 2, 10, 5)
        
        local difficultySlider = vgui.Create("OnyxSlider", modSection)
        difficultySlider:Dock(TOP)
        difficultySlider:SetHeight(30)
        difficultySlider:DockMargin(10, 5, 10, 10)
        difficultySlider:SetMin(1)
        difficultySlider:SetMax(10)
        difficultySlider:SetValue(5)
        difficultySlider:SetDecimals(0)
        difficultySlider:SetSuffix(" (Difficulty)")
        difficultySlider.OnValueChanged = function(self, value)
            VJGM.EventsDashboard.SetDifficulty(value)
        end
    end
    
    --[[
        Create Analytics Panel
    ]]--
    function VJGM.EventsDashboard.CreateAnalyticsPanel(parent)
        local titleLabel = vgui.Create("DLabel", parent)
        titleLabel:SetText("Event Analytics")
        titleLabel:SetFont(Onyx.Fonts.Heading)
        titleLabel:SetTextColor(Onyx.Colors.Text)
        titleLabel:Dock(TOP)
        titleLabel:SetHeight(30)
        titleLabel:DockMargin(10, 10, 10, 10)
        
        local scroll = vgui.Create("DScrollPanel", parent)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 0, 10, 10)
        
        -- Stats cards
        local stats = {
            {label = "Active Events", value = "0", color = Onyx.Colors.Primary},
            {label = "Total NPCs Spawned", value = "0", color = Onyx.Colors.Success},
            {label = "Players Participating", value = "0", color = Onyx.Colors.Warning},
            {label = "Event Duration", value = "0:00", color = Onyx.Colors.Accent},
        }
        
        for i, stat in ipairs(stats) do
            local statCard = vgui.Create("OnyxPanel", scroll)
            statCard:Dock(TOP)
            statCard:SetHeight(80)
            statCard:DockMargin(0, 0, 0, 10)
            statCard:SetBackgroundColor(stat.color)
            
            local statLabel = vgui.Create("DLabel", statCard)
            statLabel:SetText(stat.label)
            statLabel:SetFont(Onyx.Fonts.Small)
            statLabel:SetTextColor(Onyx.Colors.Text)
            statLabel:Dock(TOP)
            statLabel:DockMargin(10, 10, 10, 2)
            
            local statValue = vgui.Create("DLabel", statCard)
            statValue:SetText(stat.value)
            statValue:SetFont(Onyx.Fonts.Title)
            statValue:SetTextColor(Onyx.Colors.Text)
            statValue:Dock(TOP)
            statValue:DockMargin(10, 2, 10, 10)
        end
    end
    
    --[[
        Create Logs Panel
    ]]--
    function VJGM.EventsDashboard.CreateLogsPanel(parent)
        local titleLabel = vgui.Create("DLabel", parent)
        titleLabel:SetText("Event Logs")
        titleLabel:SetFont(Onyx.Fonts.Heading)
        titleLabel:SetTextColor(Onyx.Colors.Text)
        titleLabel:Dock(TOP)
        titleLabel:SetHeight(30)
        titleLabel:DockMargin(10, 10, 10, 5)
        
        local logsList = vgui.Create("DListView", parent)
        logsList:Dock(FILL)
        logsList:DockMargin(10, 5, 10, 10)
        logsList:AddColumn("Time")
        logsList:AddColumn("Event Type")
        logsList:AddColumn("Description")
        logsList:SetMultiSelect(false)
        
        -- Add sample logs
        logsList:AddLine("0:00", "System", "Event dashboard initialized")
        logsList:AddLine("0:15", "Wave", "Light wave spawned")
        logsList:AddLine("1:30", "Environmental", "Fog effect activated")
        logsList:AddLine("2:45", "Wave", "Standard wave spawned")
        
        parent.logsList = logsList
    end
    
    --[[
        Event Control Functions
    ]]--
    function VJGM.EventsDashboard.TriggerEffect(effectName)
        net.Start("VJGM_TriggerEffect")
        net.WriteString(effectName)
        net.SendToServer()
        
        VJGM.EventsDashboard.AddLog("Environmental", "Triggered effect: " .. effectName)
    end
    
    function VJGM.EventsDashboard.TriggerWave(waveName)
        net.Start("VJGM_TriggerWave")
        net.WriteString(waveName)
        net.SendToServer()
        
        VJGM.EventsDashboard.AddLog("Wave", "Triggered wave: " .. waveName)
    end
    
    function VJGM.EventsDashboard.SetDifficulty(value)
        net.Start("VJGM_SetDifficulty")
        net.WriteInt(value, 8)
        net.SendToServer()
        
        VJGM.EventsDashboard.AddLog("System", "Set difficulty to: " .. value)
    end
    
    function VJGM.EventsDashboard.SetEventTime(time)
        currentEventTime = time
        VJGM.EventsDashboard.AddLog("System", "Jumped to time: " .. math.floor(time) .. "s")
    end
    
    function VJGM.EventsDashboard.AddLog(eventType, description)
        local minutes = math.floor(currentEventTime / 60)
        local seconds = currentEventTime % 60
        local timeStr = string.format("%d:%02d", minutes, seconds)
        
        table.insert(eventLogs, {
            time = timeStr,
            type = eventType,
            description = description
        })
        
        -- Update logs panel if open
        if IsValid(activeDashboard) and IsValid(activeDashboard.logsPanel) and IsValid(activeDashboard.logsPanel.logsList) then
            activeDashboard.logsPanel.logsList:AddLine(timeStr, eventType, description)
        end
    end
    
    -- Console command to open dashboard
    concommand.Add("vjgm_events_dashboard", function()
        VJGM.EventsDashboard.Open()
    end)
    
end

--[[
    SERVER-SIDE NETWORKING
]]--
if SERVER then
    
    util.AddNetworkString("VJGM_TriggerEffect")
    util.AddNetworkString("VJGM_TriggerWave")
    util.AddNetworkString("VJGM_SetDifficulty")
    
    -- Handle trigger effect
    net.Receive("VJGM_TriggerEffect", function(len, ply)
        if not ply:IsAdmin() then return end
        local effectName = net.ReadString()
        -- TODO: Implement environmental effects
        print("[VJGM] " .. ply:Nick() .. " triggered effect: " .. effectName)
    end)
    
    -- Handle trigger wave
    net.Receive("VJGM_TriggerWave", function(len, ply)
        if not ply:IsAdmin() then return end
        local waveName = net.ReadString()
        -- TODO: Implement wave triggering
        print("[VJGM] " .. ply:Nick() .. " triggered wave: " .. waveName)
    end)
    
    -- Handle set difficulty
    net.Receive("VJGM_SetDifficulty", function(len, ply)
        if not ply:IsAdmin() then return end
        local difficulty = net.ReadInt(8)
        -- TODO: Implement difficulty adjustment
        print("[VJGM] " .. ply:Nick() .. " set difficulty to: " .. difficulty)
    end)
    
end
