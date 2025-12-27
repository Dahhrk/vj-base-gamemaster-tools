--[[
    OnyxMinimap Testing Tool
    
    This tool provides a standalone test interface for validating the enhanced
    OnyxMinimap component with high-density markers, zoom, pan, and clustering.
    
    Usage: Run `vjgm_minimap_test` in console
]]--

if CLIENT then
    
    -- Load Onyx UI if not already loaded
    if not Onyx then
        include("libraries/onyx_framework/onyx_init.lua")
    end
    
    VJGM = VJGM or {}
    VJGM.MinimapTest = VJGM.MinimapTest or {}
    
    -- Configuration
    local DEFAULT_MARKER_COUNT = 150
    local CLUSTER_MARKER_COUNT = 20
    
    local testWindow = nil
    
    --[[
        Open the Minimap Test Window
    ]]--
    function VJGM.MinimapTest.Open()
        -- Close existing window
        if IsValid(testWindow) then
            testWindow:Close()
        end
        
        -- Create test frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(900, 700)
        frame:Center()
        frame:SetTitle("OnyxMinimap - Enhanced Features Test")
        frame:MakePopup()
        
        testWindow = frame
        
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
        minimapLabel:SetText("Enhanced Minimap with Zoom, Pan & Clustering")
        minimapLabel:SetFont(Onyx.Fonts.Heading)
        minimapLabel:SetTextColor(Onyx.Colors.Text)
        minimapLabel:Dock(TOP)
        minimapLabel:SetHeight(30)
        minimapLabel:DockMargin(10, 10, 10, 5)
        
        local minimap = vgui.Create("OnyxMinimap", leftPanel)
        minimap:Dock(FILL)
        minimap:DockMargin(10, 5, 10, 50)
        minimap:SetWorldBounds(Vector(-8192, -8192, 0), Vector(8192, 8192, 0))
        
        -- Instructions
        local instructions = vgui.Create("DLabel", leftPanel)
        instructions:SetText("Mouse Wheel: Zoom | Right-Click Drag: Pan | Left-Click: Add Marker")
        instructions:SetFont(Onyx.Fonts.Small)
        instructions:SetTextColor(Onyx.Colors.TextDim)
        instructions:Dock(BOTTOM)
        instructions:SetHeight(30)
        instructions:DockMargin(10, 5, 10, 10)
        instructions:SetContentAlignment(5)
        
        -- Right panel: Controls
        local rightPanel = vgui.Create("OnyxPanel", container)
        rightPanel:Dock(FILL)
        rightPanel:DockMargin(0, 5, 5, 5)
        
        VJGM.MinimapTest.CreateControlPanel(rightPanel, minimap)
        
        -- Populate with test markers
        VJGM.MinimapTest.PopulateTestMarkers(minimap, DEFAULT_MARKER_COUNT)
        
        -- Enable click to add markers
        minimap.OnMapClicked = function(self, worldPos)
            local markerId = "manual_" .. CurTime()
            self:AddMarker(worldPos, {
                id = markerId,
                color = Color(100, 255, 100),
                shape = "circle",
                label = "M",
                size = 10
            })
            chat.AddText(Color(100, 255, 100), "[Test] ", Color(255, 255, 255), "Added marker at " .. tostring(worldPos))
        end
        
        frame.minimap = minimap
    end
    
    --[[
        Create Control Panel
    ]]--
    function VJGM.MinimapTest.CreateControlPanel(parent, minimap)
        local titleLabel = vgui.Create("DLabel", parent)
        titleLabel:SetText("Test Controls")
        titleLabel:SetFont(Onyx.Fonts.Heading)
        titleLabel:SetTextColor(Onyx.Colors.Text)
        titleLabel:Dock(TOP)
        titleLabel:SetHeight(30)
        titleLabel:DockMargin(10, 10, 10, 10)
        
        local scroll = vgui.Create("DScrollPanel", parent)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 0, 10, 10)
        
        -- Marker Count Section
        local markerSection = vgui.Create("OnyxPanel", scroll)
        markerSection:Dock(TOP)
        markerSection:SetHeight(150)
        markerSection:DockMargin(0, 0, 0, 10)
        
        local markerLabel = vgui.Create("DLabel", markerSection)
        markerLabel:SetText("Marker Count Test")
        markerLabel:SetFont(Onyx.Fonts.Body)
        markerLabel:SetTextColor(Onyx.Colors.Text)
        markerLabel:Dock(TOP)
        markerLabel:DockMargin(10, 10, 10, 5)
        
        local markerCounts = {25, 50, 100, 200}
        local buttonY = 40
        
        for _, count in ipairs(markerCounts) do
            local btn = vgui.Create("OnyxButton", markerSection)
            btn:SetPos(10, buttonY)
            btn:SetSize(260, 35)
            btn:SetButtonText(count .. " Markers")
            btn:SetBackgroundColor(Onyx.Colors.Primary)
            btn.DoClick = function()
                VJGM.MinimapTest.PopulateTestMarkers(minimap, count)
                chat.AddText(Color(100, 200, 255), "[Test] ", Color(255, 255, 255), "Populated " .. count .. " markers")
            end
            
            buttonY = buttonY + 45
        end
        
        -- Zoom Controls
        local zoomSection = vgui.Create("OnyxPanel", scroll)
        zoomSection:Dock(TOP)
        zoomSection:SetHeight(120)
        zoomSection:DockMargin(0, 0, 0, 10)
        
        local zoomLabel = vgui.Create("DLabel", zoomSection)
        zoomLabel:SetText("Zoom Controls")
        zoomLabel:SetFont(Onyx.Fonts.Body)
        zoomLabel:SetTextColor(Onyx.Colors.Text)
        zoomLabel:Dock(TOP)
        zoomLabel:DockMargin(10, 10, 10, 5)
        
        local zoomSlider = vgui.Create("OnyxSlider", zoomSection)
        zoomSlider:Dock(TOP)
        zoomSlider:SetHeight(30)
        zoomSlider:DockMargin(10, 5, 10, 10)
        zoomSlider:SetMin(0.1)
        zoomSlider:SetMax(5.0)
        zoomSlider:SetValue(1.0)
        zoomSlider:SetDecimals(1)
        zoomSlider:SetSuffix("x Zoom")
        zoomSlider.OnValueChanged = function(self, value)
            minimap:SetZoom(value)
        end
        
        local resetBtn = vgui.Create("OnyxButton", zoomSection)
        resetBtn:Dock(TOP)
        resetBtn:SetHeight(35)
        resetBtn:DockMargin(10, 5, 10, 10)
        resetBtn:SetButtonText("Reset View")
        resetBtn:SetBackgroundColor(Onyx.Colors.Success)
        resetBtn.DoClick = function()
            minimap:ResetView()
            zoomSlider:SetValue(1.0)
            chat.AddText(Color(100, 255, 100), "[Test] ", Color(255, 255, 255), "View reset")
        end
        
        -- Clustering Controls
        local clusterSection = vgui.Create("OnyxPanel", scroll)
        clusterSection:Dock(TOP)
        clusterSection:SetHeight(150)
        clusterSection:DockMargin(0, 0, 0, 10)
        
        local clusterLabel = vgui.Create("DLabel", clusterSection)
        clusterLabel:SetText("Clustering Controls")
        clusterLabel:SetFont(Onyx.Fonts.Body)
        clusterLabel:SetTextColor(Onyx.Colors.Text)
        clusterLabel:Dock(TOP)
        clusterLabel:DockMargin(10, 10, 10, 5)
        
        local toggleCluster = vgui.Create("OnyxButton", clusterSection)
        toggleCluster:Dock(TOP)
        toggleCluster:SetHeight(35)
        toggleCluster:DockMargin(10, 5, 10, 10)
        toggleCluster:SetButtonText("Toggle Clustering: ON")
        toggleCluster:SetBackgroundColor(Onyx.Colors.Success)
        
        local clusteringEnabled = true
        toggleCluster.DoClick = function()
            clusteringEnabled = not clusteringEnabled
            minimap:SetClusteringEnabled(clusteringEnabled)
            toggleCluster:SetButtonText("Toggle Clustering: " .. (clusteringEnabled and "ON" or "OFF"))
            toggleCluster:SetBackgroundColor(clusteringEnabled and Onyx.Colors.Success or Onyx.Colors.Error)
            chat.AddText(Color(100, 200, 255), "[Test] ", Color(255, 255, 255), "Clustering " .. (clusteringEnabled and "enabled" or "disabled"))
        end
        
        local radiusSlider = vgui.Create("OnyxSlider", clusterSection)
        radiusSlider:Dock(TOP)
        radiusSlider:SetHeight(30)
        radiusSlider:DockMargin(10, 5, 10, 10)
        radiusSlider:SetMin(10)
        radiusSlider:SetMax(100)
        radiusSlider:SetValue(30)
        radiusSlider:SetDecimals(0)
        radiusSlider:SetSuffix("px Radius")
        radiusSlider.OnValueChanged = function(self, value)
            minimap:SetClusterRadius(value)
        end
        
        -- Action Buttons
        local actionSection = vgui.Create("OnyxPanel", scroll)
        actionSection:Dock(TOP)
        actionSection:SetHeight(120)
        actionSection:DockMargin(0, 0, 0, 10)
        
        local actionLabel = vgui.Create("DLabel", actionSection)
        actionLabel:SetText("Actions")
        actionLabel:SetFont(Onyx.Fonts.Body)
        actionLabel:SetTextColor(Onyx.Colors.Text)
        actionLabel:Dock(TOP)
        actionLabel:DockMargin(10, 10, 10, 5)
        
        local clearBtn = vgui.Create("OnyxButton", actionSection)
        clearBtn:Dock(TOP)
        clearBtn:SetHeight(35)
        clearBtn:DockMargin(10, 5, 10, 5)
        clearBtn:SetButtonText("Clear All Markers")
        clearBtn:SetBackgroundColor(Onyx.Colors.Error)
        clearBtn.DoClick = function()
            minimap:ClearMarkers()
            chat.AddText(Color(255, 100, 100), "[Test] ", Color(255, 255, 255), "All markers cleared")
        end
        
        local addClusterBtn = vgui.Create("OnyxButton", actionSection)
        addClusterBtn:Dock(TOP)
        addClusterBtn:SetHeight(35)
        addClusterBtn:DockMargin(10, 5, 10, 10)
        addClusterBtn:SetButtonText("Add Cluster (" .. CLUSTER_MARKER_COUNT .. " markers)")
        addClusterBtn:SetBackgroundColor(Onyx.Colors.Warning)
        addClusterBtn.DoClick = function()
            VJGM.MinimapTest.AddMarkerCluster(minimap)
            chat.AddText(Color(255, 200, 100), "[Test] ", Color(255, 255, 255), "Added cluster of " .. CLUSTER_MARKER_COUNT .. " markers")
        end
    end
    
    --[[
        Populate Test Markers
    ]]--
    function VJGM.MinimapTest.PopulateTestMarkers(minimap, count)
        minimap:ClearMarkers()
        
        local shapes = {"circle", "square", "diamond"}
        local colors = {
            Onyx.Colors.Primary,
            Onyx.Colors.Success,
            Onyx.Colors.Warning,
            Onyx.Colors.Error,
            Onyx.Colors.Accent,
            Color(255, 100, 255),
            Color(100, 255, 255),
        }
        
        for i = 1, count do
            local angle = (i / count) * math.pi * 2
            local radius = math.random(1000, 7000)
            local x = math.cos(angle) * radius + math.random(-400, 400)
            local y = math.sin(angle) * radius + math.random(-400, 400)
            
            minimap:AddMarker(Vector(x, y, 0), {
                id = "test_marker_" .. i,
                color = colors[math.random(1, #colors)],
                shape = shapes[math.random(1, #shapes)],
                label = "M" .. i,
                size = math.random(6, 12)
            })
        end
    end
    
    --[[
        Add a Cluster of Markers
    ]]--
    function VJGM.MinimapTest.AddMarkerCluster(minimap)
        local centerX = math.random(-6000, 6000)
        local centerY = math.random(-6000, 6000)
        
        for i = 1, CLUSTER_MARKER_COUNT do
            local offsetX = math.random(-150, 150)
            local offsetY = math.random(-150, 150)
            
            minimap:AddMarker(Vector(centerX + offsetX, centerY + offsetY, 0), {
                id = "cluster_" .. CurTime() .. "_" .. i,
                color = Onyx.Colors.Accent,
                shape = "circle",
                label = "C",
                size = 8
            })
        end
    end
    
    -- Console command to open test window
    concommand.Add("vjgm_minimap_test", function()
        if not LocalPlayer():IsAdmin() then
            chat.AddText(Color(255, 100, 100), "[VJGM] ", Color(255, 255, 255), "Minimap test tool requires admin access")
            return
        end
        VJGM.MinimapTest.Open()
    end)
    
end
