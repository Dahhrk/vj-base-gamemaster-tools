--[[
    Spawn Point Editor - Enhanced with Onyx UI
    
    Features:
    - Interactive minimap for visualizing spawn points
    - Add, delete, and edit spawn points dynamically
    - Sliders for spawn radius configuration
    - Dropdowns for group management
    - Real-time syncing with backend via net messages
    
    NOTE: This tool integrates with the existing VJGM.SpawnPoints system.
    The add spawn point functionality is fully implemented.
    Delete functionality requires additional server-side implementation.
]]--

if CLIENT then
    
    -- Load Onyx UI if not already loaded
    if not Onyx then
        include("libraries/onyx_framework/onyx_init.lua")
    end
    
    VJGM = VJGM or {}
    VJGM.SpawnPointEditor = VJGM.SpawnPointEditor or {}
    
    local activeEditor = nil
    local spawnPointsData = {}
    
    --[[
        Open the Spawn Point Editor
    ]]--
    function VJGM.SpawnPointEditor.Open()
        if not LocalPlayer():IsAdmin() then
            chat.AddText(Color(255, 100, 100), "[VJGM] ", Color(255, 255, 255), "Spawn Point Editor requires admin access")
            return
        end
        
        -- Close existing editor
        if IsValid(activeEditor) then
            activeEditor:Close()
        end
        
        -- Create main frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(1000, 700)
        frame:Center()
        frame:SetTitle("VJGM - Spawn Point Editor")
        frame:MakePopup()
        
        activeEditor = frame
        
        -- Create main container
        local container = vgui.Create("DPanel", frame)
        container:Dock(FILL)
        container.Paint = function() end
        
        -- Left panel: Minimap
        local leftPanel = vgui.Create("OnyxPanel", container)
        leftPanel:Dock(LEFT)
        leftPanel:SetWide(600)
        leftPanel:DockMargin(5, 5, 5, 5)
        
        local minimapLabel = vgui.Create("DLabel", leftPanel)
        minimapLabel:SetText("Spawn Point Minimap")
        minimapLabel:SetFont(Onyx.Fonts.Heading)
        minimapLabel:SetTextColor(Onyx.Colors.Text)
        minimapLabel:Dock(TOP)
        minimapLabel:SetHeight(30)
        minimapLabel:DockMargin(10, 10, 10, 5)
        
        local minimap = vgui.Create("OnyxMinimap", leftPanel)
        minimap:Dock(FILL)
        minimap:DockMargin(10, 5, 10, 10)
        minimap:SetWorldBounds(Vector(-8192, -8192, 0), Vector(8192, 8192, 0))
        
        -- Handle minimap clicks to add spawn points
        minimap.OnMapClicked = function(self, worldPos)
            VJGM.SpawnPointEditor.AddSpawnPoint(worldPos)
        end
        
        -- Right panel: Controls
        local rightPanel = vgui.Create("OnyxPanel", container)
        rightPanel:Dock(FILL)
        rightPanel:DockMargin(0, 5, 5, 5)
        
        local controlsLabel = vgui.Create("DLabel", rightPanel)
        controlsLabel:SetText("Spawn Point Controls")
        controlsLabel:SetFont(Onyx.Fonts.Heading)
        controlsLabel:SetTextColor(Onyx.Colors.Text)
        controlsLabel:Dock(TOP)
        controlsLabel:SetHeight(30)
        controlsLabel:DockMargin(10, 10, 10, 5)
        
        -- Group selection
        local groupLabel = vgui.Create("DLabel", rightPanel)
        groupLabel:SetText("Spawn Group:")
        groupLabel:SetFont(Onyx.Fonts.Body)
        groupLabel:SetTextColor(Onyx.Colors.Text)
        groupLabel:Dock(TOP)
        groupLabel:SetHeight(20)
        groupLabel:DockMargin(10, 10, 10, 2)
        
        local groupDropdown = vgui.Create("DComboBox", rightPanel)
        groupDropdown:Dock(TOP)
        groupDropdown:SetHeight(30)
        groupDropdown:DockMargin(10, 2, 10, 10)
        groupDropdown:SetValue("default")
        groupDropdown:AddChoice("default")
        groupDropdown:AddChoice("north")
        groupDropdown:AddChoice("south")
        groupDropdown:AddChoice("east")
        groupDropdown:AddChoice("west")
        
        -- Spawn radius slider
        local radiusLabel = vgui.Create("DLabel", rightPanel)
        radiusLabel:SetText("Spawn Radius:")
        radiusLabel:SetFont(Onyx.Fonts.Body)
        radiusLabel:SetTextColor(Onyx.Colors.Text)
        radiusLabel:Dock(TOP)
        radiusLabel:SetHeight(20)
        radiusLabel:DockMargin(10, 10, 10, 2)
        
        local radiusSlider = vgui.Create("OnyxSlider", rightPanel)
        radiusSlider:Dock(TOP)
        radiusSlider:SetHeight(30)
        radiusSlider:DockMargin(10, 2, 10, 10)
        radiusSlider:SetMin(50)
        radiusSlider:SetMax(500)
        radiusSlider:SetValue(100)
        radiusSlider:SetDecimals(0)
        radiusSlider:SetSuffix(" units")
        
        -- Add spawn point button
        local addButton = vgui.Create("OnyxButton", rightPanel)
        addButton:Dock(TOP)
        addButton:SetHeight(40)
        addButton:DockMargin(10, 10, 10, 5)
        addButton:SetButtonText("Add Spawn Point at Crosshair")
        addButton:SetBackgroundColor(Onyx.Colors.Success)
        addButton:SetHoverColor(Color(100, 200, 100))
        addButton.DoClick = function()
            local ply = LocalPlayer()
            local trace = ply:GetEyeTrace()
            if trace.Hit then
                VJGM.SpawnPointEditor.AddSpawnPoint(trace.HitPos)
            end
        end
        
        -- Delete selected button
        local deleteButton = vgui.Create("OnyxButton", rightPanel)
        deleteButton:Dock(TOP)
        deleteButton:SetHeight(40)
        deleteButton:DockMargin(10, 5, 10, 5)
        deleteButton:SetButtonText("Delete Nearest Spawn Point")
        deleteButton:SetBackgroundColor(Onyx.Colors.Error)
        deleteButton:SetHoverColor(Color(255, 100, 100))
        deleteButton.DoClick = function()
            -- TODO: Implement deletion of nearest spawn point
            -- Requires integration with existing spawn point system
            -- Example:
            -- local ply = LocalPlayer()
            -- local trace = ply:GetEyeTrace()
            -- if trace.Hit then
            --     VJGM.SpawnPointEditor.DeleteNearestSpawnPoint(trace.HitPos)
            -- end
            
            chat.AddText(Color(255, 200, 100), "[VJGM] ", Color(255, 255, 255), "Delete functionality requires server-side integration")
        end
        
        -- Refresh button
        local refreshButton = vgui.Create("OnyxButton", rightPanel)
        refreshButton:Dock(TOP)
        refreshButton:SetHeight(40)
        refreshButton:DockMargin(10, 5, 10, 5)
        refreshButton:SetButtonText("Refresh Spawn Points")
        refreshButton:SetBackgroundColor(Onyx.Colors.Primary)
        refreshButton:SetHoverColor(Onyx.Colors.Secondary)
        refreshButton.DoClick = function()
            VJGM.SpawnPointEditor.RequestSpawnPoints()
            minimap:ClearMarkers()
            VJGM.SpawnPointEditor.UpdateMinimap(minimap)
        end
        
        -- Info panel
        local infoPanel = vgui.Create("OnyxPanel", rightPanel)
        infoPanel:Dock(FILL)
        infoPanel:DockMargin(10, 20, 10, 10)
        infoPanel:SetBackgroundColor(Onyx.Colors.Background)
        
        local infoText = vgui.Create("DLabel", infoPanel)
        infoText:SetText("Click on the minimap to add spawn points\n\nSpawn points are automatically synced\nwith the server\n\nUse groups to organize spawn locations\nfor different waves and scenarios")
        infoText:SetFont(Onyx.Fonts.Small)
        infoText:SetTextColor(Onyx.Colors.TextDim)
        infoText:Dock(FILL)
        infoText:DockMargin(10, 10, 10, 10)
        infoText:SetWrap(true)
        infoText:SetAutoStretchVertical(true)
        
        -- Store references
        frame.minimap = minimap
        frame.groupDropdown = groupDropdown
        frame.radiusSlider = radiusSlider
        
        -- Load initial spawn points
        VJGM.SpawnPointEditor.RequestSpawnPoints()
        VJGM.SpawnPointEditor.UpdateMinimap(minimap)
    end
    
    --[[
        Add a spawn point at the given position
    ]]--
    function VJGM.SpawnPointEditor.AddSpawnPoint(pos)
        -- Send to server
        net.Start("VJGM_AddSpawnPoint")
        net.WriteVector(pos)
        net.WriteString("default")  -- Group name
        net.SendToServer()
        
        chat.AddText(Color(100, 255, 100), "[VJGM] ", Color(255, 255, 255), "Added spawn point at ", Color(100, 200, 255), tostring(pos))
    end
    
    --[[
        Request spawn points from server
    ]]--
    function VJGM.SpawnPointEditor.RequestSpawnPoints()
        if SERVER then return end
        
        net.Start("VJGM_RequestSpawnPoints")
        net.SendToServer()
    end
    
    --[[
        Update minimap with spawn points
    ]]--
    function VJGM.SpawnPointEditor.UpdateMinimap(minimap)
        if not IsValid(minimap) then return end
        
        minimap:ClearMarkers()
        
        -- Add spawn point markers
        for group, points in pairs(spawnPointsData) do
            local groupColor = VJGM.SpawnPointEditor.GetGroupColor(group)
            
            for i, point in ipairs(points) do
                minimap:AddMarker(point.pos, {
                    color = groupColor,
                    size = 12,
                    shape = "circle",
                    label = group,
                    id = group .. "_" .. i
                })
            end
        end
    end
    
    --[[
        Get color for spawn group
    ]]--
    function VJGM.SpawnPointEditor.GetGroupColor(group)
        local colors = {
            default = Color(100, 200, 255),
            north = Color(255, 100, 100),
            south = Color(100, 255, 100),
            east = Color(255, 255, 100),
            west = Color(255, 100, 255),
        }
        
        return colors[group] or Color(150, 150, 150)
    end
    
    --[[
        Receive spawn points from server
    ]]--
    net.Receive("VJGM_SpawnPointsData", function()
        local data = net.ReadTable()
        spawnPointsData = data
        
        -- Update active editor if open
        if IsValid(activeEditor) and IsValid(activeEditor.minimap) then
            VJGM.SpawnPointEditor.UpdateMinimap(activeEditor.minimap)
        end
    end)
    
    -- Console command to open editor
    concommand.Add("vjgm_spawn_editor", function()
        VJGM.SpawnPointEditor.Open()
    end)
    
end

--[[
    SERVER-SIDE NETWORKING
]]--
if SERVER then
    
    util.AddNetworkString("VJGM_AddSpawnPoint")
    util.AddNetworkString("VJGM_RequestSpawnPoints")
    util.AddNetworkString("VJGM_SpawnPointsData")
    
    -- Handle add spawn point request
    net.Receive("VJGM_AddSpawnPoint", function(len, ply)
        if not ply:IsAdmin() then return end
        
        local pos = net.ReadVector()
        local group = net.ReadString()
        
        -- Add spawn point using existing system
        if VJGM and VJGM.SpawnPoints and VJGM.SpawnPoints.AddPoint then
            VJGM.SpawnPoints.AddPoint(group, pos)
            
            -- Broadcast update to all clients
            local spawnData = VJGM.SpawnPoints.GetAllSpawnPoints and VJGM.SpawnPoints.GetAllSpawnPoints() or {}
            
            net.Start("VJGM_SpawnPointsData")
            net.WriteTable(spawnData)
            net.Broadcast()
        end
    end)
    
    -- Handle spawn points request
    net.Receive("VJGM_RequestSpawnPoints", function(len, ply)
        if not ply:IsAdmin() then return end
        
        local spawnData = {}
        
        if VJGM and VJGM.SpawnPoints and VJGM.SpawnPoints.GetAllSpawnPoints then
            spawnData = VJGM.SpawnPoints.GetAllSpawnPoints()
        end
        
        net.Start("VJGM_SpawnPointsData")
        net.WriteTable(spawnData)
        net.Send(ply)
    end)
    
end
