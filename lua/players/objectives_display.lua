--[[
    Objectives Display - Client-side player objectives display
    Shows visible objectives to all players in a minimal panel
    
    Compatible with VJ Base Gamemaster Tools
]]--

if CLIENT then
    
    VJGM = VJGM or {}
    VJGM.ObjectivesDisplay = VJGM.ObjectivesDisplay or {}
    
    -- Store objectives data
    local objectives = {}
    local displayPanel = nil
    local isVisible = false
    
    --[[
        Update objectives and refresh display
        @param newObjectives: Updated objectives table
    ]]--
    function VJGM.ObjectivesDisplay.Update(newObjectives)
        objectives = newObjectives or {}
        VJGM.ObjectivesDisplay.RefreshDisplay()
    end
    
    --[[
        Create the player display panel
    ]]--
    function VJGM.ObjectivesDisplay.CreatePanel()
        if IsValid(displayPanel) then
            displayPanel:Remove()
        end
        
        local panel = vgui.Create("DPanel")
        panel:SetPos(ScrW() - 320, 20)
        panel:SetSize(300, 400)
        
        panel.Paint = function(self, w, h)
            -- Semi-transparent background
            draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 200))
            
            -- Header bar
            draw.RoundedBox(8, 0, 0, w, 40, Color(40, 40, 40, 220))
            draw.SimpleText("OBJECTIVES", "DermaLarge", w/2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Objectives container
        local objectivesList = vgui.Create("DScrollPanel", panel)
        objectivesList:Dock(FILL)
        objectivesList:DockMargin(10, 45, 10, 10)
        
        panel.objectivesList = objectivesList
        
        displayPanel = panel
        displayPanel:SetVisible(false)
        
        return panel
    end
    
    --[[
        Refresh the objectives display
    ]]--
    function VJGM.ObjectivesDisplay.RefreshDisplay()
        -- Create panel if it doesn't exist
        if not IsValid(displayPanel) then
            VJGM.ObjectivesDisplay.CreatePanel()
        end
        
        local objectivesList = displayPanel.objectivesList
        if not IsValid(objectivesList) then return end
        
        objectivesList:Clear()
        
        -- Count visible objectives
        local visibleCount = 0
        local sortedObjectives = {}
        
        for id, obj in pairs(objectives) do
            if obj.visible then
                table.insert(sortedObjectives, obj)
                visibleCount = visibleCount + 1
            end
        end
        
        -- Hide panel if no visible objectives
        if visibleCount == 0 then
            displayPanel:SetVisible(false)
            isVisible = false
            return
        end
        
        -- Show panel
        displayPanel:SetVisible(true)
        isVisible = true
        
        -- Sort by ID
        table.sort(sortedObjectives, function(a, b) return a.id < b.id end)
        
        -- Create objective items
        for _, obj in ipairs(sortedObjectives) do
            VJGM.ObjectivesDisplay.CreateObjectiveItem(objectivesList, obj)
        end
        
        -- Adjust panel height based on content
        local contentHeight = math.min(visibleCount * 80 + 60, 500)
        displayPanel:SetSize(300, contentHeight)
    end
    
    --[[
        Create an objective item for display
    ]]--
    function VJGM.ObjectivesDisplay.CreateObjectiveItem(parent, obj)
        local item = vgui.Create("DPanel", parent)
        item:Dock(TOP)
        item:SetHeight(70)
        item:DockMargin(5, 5, 5, 5)
        
        item.Paint = function(self, w, h)
            -- Background
            local bgColor = obj.completed and Color(40, 80, 40, 180) or Color(60, 60, 60, 180)
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            
            -- Status indicator
            local statusColor = obj.completed and Color(80, 200, 80) or Color(200, 200, 80)
            draw.RoundedBox(6, 0, 0, 6, h, statusColor)
            
            -- Completion checkmark
            if obj.completed then
                draw.SimpleText("✓", "DermaLarge", w - 20, h/2, Color(80, 200, 80), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
        
        -- Content
        local content = vgui.Create("DPanel", item)
        content:Dock(FILL)
        content:DockMargin(15, 8, 25, 8)
        content.Paint = nil
        
        -- Title
        local title = vgui.Create("DLabel", content)
        title:Dock(TOP)
        title:SetHeight(20)
        title:SetText(obj.title)
        title:SetTextColor(Color(255, 255, 255))
        title:SetFont("DermaDefaultBold")
        
        -- Description
        if obj.description and obj.description ~= "" then
            local description = vgui.Create("DLabel", content)
            description:Dock(TOP)
            description:SetHeight(30)
            description:SetText(obj.description)
            description:SetTextColor(Color(200, 200, 200))
            description:SetWrap(true)
            description:SetAutoStretchVertical(true)
        end
    end
    
    --[[
        Toggle visibility of the display panel
    ]]--
    function VJGM.ObjectivesDisplay.Toggle()
        if IsValid(displayPanel) then
            isVisible = not isVisible
            displayPanel:SetVisible(isVisible)
        end
    end
    
    --[[
        Check if display is visible
    ]]--
    function VJGM.ObjectivesDisplay.IsVisible()
        return isVisible
    end
    
    -- Initialize when client spawns
    hook.Add("InitPostEntity", "VJGM_ObjectivesDisplay_Init", function()
        timer.Simple(2, function()
            VJGM.ObjectivesDisplay.CreatePanel()
        end)
    end)
    
    -- Console command to toggle display
    concommand.Add("vjgm_objectives_toggle", function()
        VJGM.ObjectivesDisplay.Toggle()
    end)
    
    print("[VJGM] Objectives Display initialized")
end
