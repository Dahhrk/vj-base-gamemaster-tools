--[[
    Timeline Component Test Suite
    Comprehensive testing for OnyxTimeline enhancements
    
    This file demonstrates and tests:
    - Dynamic scaling
    - Tooltip display
    - Overlapping event handling
    - Edge cases (very short events, long events, many overlaps)
]]--

if CLIENT then
    
    -- Load Onyx UI if not already loaded
    if not Onyx then
        include("libraries/onyx_framework/onyx_init.lua")
    end
    
    VJGM = VJGM or {}
    VJGM.TimelineTest = VJGM.TimelineTest or {}
    
    --[[
        Open the Timeline Test Window
    ]]--
    function VJGM.TimelineTest.Open()
        -- Create main frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(1200, 600)
        frame:Center()
        frame:SetTitle("VJGM - Timeline Component Test Suite")
        frame:MakePopup()
        
        -- Create main container
        local container = vgui.Create("DPanel", frame)
        container:Dock(FILL)
        container:DockMargin(5, 5, 5, 5)
        container.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Onyx.Colors.Background)
        end
        
        -- Title
        local title = vgui.Create("DLabel", container)
        title:SetText("Timeline Component - Enhanced Features Test")
        title:SetFont(Onyx.Fonts.Title)
        title:SetTextColor(Onyx.Colors.Text)
        title:Dock(TOP)
        title:SetHeight(40)
        title:DockMargin(10, 10, 10, 5)
        
        -- Instructions
        local instructions = vgui.Create("DLabel", container)
        instructions:SetText("Hover over events to see tooltips • Use mouse wheel to zoom • Click events to jump to time")
        instructions:SetFont(Onyx.Fonts.Body)
        instructions:SetTextColor(Onyx.Colors.TextDim)
        instructions:Dock(TOP)
        instructions:SetHeight(20)
        instructions:DockMargin(10, 0, 10, 10)
        
        -- Test Case 1: Basic Timeline
        VJGM.TimelineTest.CreateTestCase(container, "Test 1: Basic Events (No Overlap)", function(timeline)
            timeline:SetMaxTime(300)
            timeline:AddEvent("Event A", 0, 50, Onyx.Colors.Primary, "Simple event with no overlaps")
            timeline:AddEvent("Event B", 60, 110, Onyx.Colors.Success, "Another isolated event")
            timeline:AddEvent("Event C", 120, 200, Onyx.Colors.Warning, "Longer duration event")
            timeline:AddEvent("Event D", 210, 250, Onyx.Colors.Error, "Near the end")
        end)
        
        -- Test Case 2: Overlapping Events
        VJGM.TimelineTest.CreateTestCase(container, "Test 2: Overlapping Events (Multiple Rows)", function(timeline)
            timeline:SetMaxTime(300)
            timeline:AddEvent("Base Event", 0, 200, Onyx.Colors.Primary, "Long base event spanning most of timeline")
            timeline:AddEvent("Overlap 1", 30, 80, Onyx.Colors.Success, "First overlapping event")
            timeline:AddEvent("Overlap 2", 50, 100, Onyx.Colors.Warning, "Second overlapping event")
            timeline:AddEvent("Overlap 3", 70, 150, Onyx.Colors.Error, "Third overlapping event")
            timeline:AddEvent("Overlap 4", 120, 180, Onyx.Colors.Accent, "Fourth overlapping event")
        end)
        
        -- Test Case 3: Edge Cases
        VJGM.TimelineTest.CreateTestCase(container, "Test 3: Edge Cases (Very Short & Very Long)", function(timeline)
            timeline:SetMaxTime(500)
            timeline:AddEvent("Very Short", 10, 12, Color(255, 100, 100), "Event lasting only 2 seconds")
            timeline:AddEvent("Very Long", 50, 450, Onyx.Colors.Primary, "Event spanning almost entire timeline (400s)")
            timeline:AddEvent("Instant Event", 100, 101, Color(100, 255, 100), "Nearly instant event (1 second)")
            timeline:AddEvent("Medium", 200, 280, Onyx.Colors.Success, "Medium duration event")
            timeline:AddEvent("Another Short", 300, 305, Color(100, 100, 255), "5 second event")
        end)
        
        -- Test Case 4: Heavy Overlap Stress Test
        VJGM.TimelineTest.CreateTestCase(container, "Test 4: Stress Test (Many Overlapping Events)", function(timeline)
            timeline:SetMaxTime(200)
            
            -- Create multiple overlapping events at various times
            local colors = {
                Onyx.Colors.Primary,
                Onyx.Colors.Success,
                Onyx.Colors.Warning,
                Onyx.Colors.Error,
                Onyx.Colors.Accent,
                Color(100, 200, 255),
                Color(255, 200, 100),
                Color(200, 100, 255),
            }
            
            for i = 1, 15 do
                local startTime = math.random(0, 150)
                local duration = math.random(20, 80)
                local endTime = math.min(startTime + duration, 200)
                local color = colors[(i % #colors) + 1]
                
                timeline:AddEvent(
                    "Event " .. i,
                    startTime,
                    endTime,
                    color,
                    string.format("Random event %d: %ds duration", i, duration)
                )
            end
        end)
        
        -- Info panel
        local infoPanel = vgui.Create("OnyxPanel", container)
        infoPanel:Dock(BOTTOM)
        infoPanel:SetHeight(80)
        infoPanel:DockMargin(10, 5, 10, 10)
        infoPanel:SetBackgroundColor(Onyx.Colors.Surface)
        
        local infoTitle = vgui.Create("DLabel", infoPanel)
        infoTitle:SetText("Feature Summary")
        infoTitle:SetFont(Onyx.Fonts.Heading)
        infoTitle:SetTextColor(Onyx.Colors.Text)
        infoTitle:Dock(TOP)
        infoTitle:DockMargin(10, 10, 10, 2)
        
        local infoText = vgui.Create("DLabel", infoPanel)
        infoText:SetText("✓ Dynamic Scaling (Mouse Wheel) • ✓ Hover Tooltips • ✓ Multi-Row Overlapping Events • ✓ Proportional Duration Display")
        infoText:SetFont(Onyx.Fonts.Small)
        infoText:SetTextColor(Onyx.Colors.TextDim)
        infoText:Dock(FILL)
        infoText:DockMargin(10, 2, 10, 10)
        infoText:SetWrap(true)
    end
    
    --[[
        Create a test case panel with timeline
    ]]--
    function VJGM.TimelineTest.CreateTestCase(parent, title, setupFunc)
        local panel = vgui.Create("OnyxPanel", parent)
        panel:Dock(TOP)
        panel:SetHeight(120)
        panel:DockMargin(10, 0, 10, 10)
        panel:SetBackgroundColor(Onyx.Colors.Surface)
        
        local titleLabel = vgui.Create("DLabel", panel)
        titleLabel:SetText(title)
        titleLabel:SetFont(Onyx.Fonts.Body)
        titleLabel:SetTextColor(Onyx.Colors.Text)
        titleLabel:Dock(TOP)
        titleLabel:SetHeight(25)
        titleLabel:DockMargin(10, 10, 10, 5)
        
        local timeline = vgui.Create("OnyxTimeline", panel)
        timeline:Dock(FILL)
        timeline:DockMargin(10, 5, 10, 10)
        
        -- Apply test setup
        if setupFunc then
            setupFunc(timeline)
        end
        
        -- Add click handler
        timeline.OnTimelineClicked = function(self, time)
            chat.AddText(
                Color(100, 200, 255), "[Timeline Test] ",
                Color(255, 255, 255), "Clicked at time: ",
                Color(100, 255, 100), string.format("%.1fs", time)
            )
        end
        
        return panel
    end
    
    -- Console command to open test suite
    concommand.Add("vjgm_timeline_test", function()
        VJGM.TimelineTest.Open()
    end)
    
    -- Print message on load
    print("[VJGM Timeline Test] Test suite loaded. Use 'vjgm_timeline_test' to open the test window.")
    
end
