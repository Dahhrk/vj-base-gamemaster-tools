--[[
    Objectives UI - Client-side objectives management interface
    Provides a VGUI-based interface for gamemasters to manage objectives
    
    Compatible with VJ Base Gamemaster Tools
]]--

if CLIENT then
    
    VJGM = VJGM or {}
    VJGM.ObjectivesUI = VJGM.ObjectivesUI or {}
    
    -- Store objectives data locally
    local objectives = {}
    local activePanel = nil
    
    --[[
        Receive objectives sync from server
    ]]--
    net.Receive("VJGM_ObjectivesSync", function()
        objectives = net.ReadTable()
        
        -- Refresh the UI if it's open
        if IsValid(activePanel) then
            VJGM.ObjectivesUI.RefreshObjectivesList(activePanel)
        end
        
        -- Update player display
        if VJGM.ObjectivesDisplay then
            VJGM.ObjectivesDisplay.Update(objectives)
        end
    end)
    
    --[[
        Open the objectives menu
    ]]--
    net.Receive("VJGM_OpenObjectivesMenu", function()
        VJGM.ObjectivesUI.OpenMenu()
    end)
    
    --[[
        Request objectives from server
    ]]--
    function VJGM.ObjectivesUI.RequestObjectives()
        net.Start("VJGM_RequestObjectives")
        net.SendToServer()
    end
    
    --[[
        Open the objectives management menu
    ]]--
    function VJGM.ObjectivesUI.OpenMenu()
        -- Close existing panel
        if IsValid(activePanel) then
            activePanel:Close()
        end
        
        -- Create main frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(800, 600)
        frame:Center()
        frame:SetTitle("VJGM - Objectives Manager")
        frame:MakePopup()
        frame:SetDeleteOnClose(true)
        
        activePanel = frame
        
        -- Create main container
        local container = vgui.Create("DPanel", frame)
        container:Dock(FILL)
        container:DockMargin(5, 5, 5, 5)
        container.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35))
        end
        
        -- Create header with add button
        local header = vgui.Create("DPanel", container)
        header:Dock(TOP)
        header:SetHeight(40)
        header:DockMargin(5, 5, 5, 5)
        header.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(45, 45, 45))
        end
        
        local addButton = vgui.Create("DButton", header)
        addButton:Dock(LEFT)
        addButton:SetWidth(150)
        addButton:DockMargin(5, 5, 5, 5)
        addButton:SetText("+ Add Objective")
        addButton:SetTextColor(Color(255, 255, 255))
        addButton.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(80, 150, 80) or Color(60, 120, 60)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        addButton.DoClick = function()
            VJGM.ObjectivesUI.ShowAddObjectiveDialog()
        end
        
        -- Create objectives list container
        local listContainer = vgui.Create("DScrollPanel", container)
        listContainer:Dock(FILL)
        listContainer:DockMargin(5, 5, 5, 5)
        
        -- Store reference for refreshing
        frame.listContainer = listContainer
        
        -- Populate the list
        VJGM.ObjectivesUI.RefreshObjectivesList(frame)
        
        -- Request latest objectives from server
        VJGM.ObjectivesUI.RequestObjectives()
    end
    
    --[[
        Refresh the objectives list
    ]]--
    function VJGM.ObjectivesUI.RefreshObjectivesList(frame)
        if not IsValid(frame) or not IsValid(frame.listContainer) then return end
        
        local listContainer = frame.listContainer
        listContainer:Clear()
        
        -- Sort objectives by ID
        local sortedObjectives = {}
        for id, obj in pairs(objectives) do
            table.insert(sortedObjectives, obj)
        end
        table.sort(sortedObjectives, function(a, b) return a.id < b.id end)
        
        -- Create objective cards
        for _, obj in ipairs(sortedObjectives) do
            VJGM.ObjectivesUI.CreateObjectiveCard(listContainer, obj)
        end
        
        -- Show empty state if no objectives
        if table.Count(objectives) == 0 then
            local emptyLabel = vgui.Create("DLabel", listContainer)
            emptyLabel:Dock(TOP)
            emptyLabel:SetHeight(100)
            emptyLabel:SetText("No objectives yet. Click '+ Add Objective' to create one.")
            emptyLabel:SetTextColor(Color(150, 150, 150))
            emptyLabel:SetFont("DermaLarge")
            emptyLabel:SetContentAlignment(5)
        end
    end
    
    --[[
        Create an objective card
    ]]--
    function VJGM.ObjectivesUI.CreateObjectiveCard(parent, obj)
        local card = vgui.Create("DPanel", parent)
        card:Dock(TOP)
        card:SetHeight(120)
        card:DockMargin(5, 5, 5, 5)
        
        card.Paint = function(self, w, h)
            -- Main background
            draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 45))
            
            -- Status bar on the left
            local statusColor = obj.completed and Color(60, 180, 60) or Color(100, 100, 100)
            draw.RoundedBox(6, 0, 0, 6, h, statusColor)
            
            -- Visibility indicator
            if not obj.visible then
                draw.RoundedBox(0, w - 8, 0, 8, h, Color(180, 60, 60))
            end
        end
        
        -- Content container
        local content = vgui.Create("DPanel", card)
        content:Dock(FILL)
        content:DockMargin(15, 10, 10, 10)
        content.Paint = nil
        
        -- Title
        local title = vgui.Create("DLabel", content)
        title:Dock(TOP)
        title:SetHeight(25)
        title:SetText(obj.title)
        title:SetTextColor(Color(255, 255, 255))
        title:SetFont("DermaLarge")
        
        -- Description
        local description = vgui.Create("DLabel", content)
        description:Dock(TOP)
        description:SetHeight(30)
        description:SetText(obj.description)
        description:SetTextColor(Color(200, 200, 200))
        description:SetWrap(true)
        description:SetAutoStretchVertical(true)
        
        -- Buttons container
        local buttons = vgui.Create("DPanel", content)
        buttons:Dock(BOTTOM)
        buttons:SetHeight(30)
        buttons:DockMargin(0, 5, 0, 0)
        buttons.Paint = nil
        
        -- Edit button
        local editBtn = vgui.Create("DButton", buttons)
        editBtn:Dock(LEFT)
        editBtn:SetWidth(80)
        editBtn:DockMargin(0, 0, 5, 0)
        editBtn:SetText("Edit")
        editBtn:SetTextColor(Color(255, 255, 255))
        editBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(70, 120, 180) or Color(50, 100, 150)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        editBtn.DoClick = function()
            VJGM.ObjectivesUI.ShowEditObjectiveDialog(obj)
        end
        
        -- Complete/Incomplete button
        local completeBtn = vgui.Create("DButton", buttons)
        completeBtn:Dock(LEFT)
        completeBtn:SetWidth(120)
        completeBtn:DockMargin(0, 0, 5, 0)
        completeBtn:SetText(obj.completed and "Mark Incomplete" or "Mark Complete")
        completeBtn:SetTextColor(Color(255, 255, 255))
        completeBtn.Paint = function(self, w, h)
            local col = obj.completed and Color(100, 100, 100) or Color(60, 120, 60)
            if self:IsHovered() then
                col = Color(col.r + 20, col.g + 20, col.b + 20)
            end
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        completeBtn.DoClick = function()
            net.Start("VJGM_ObjectiveToggleComplete")
            net.WriteInt(obj.id, 32)
            net.SendToServer()
        end
        
        -- Visibility button
        local visibilityBtn = vgui.Create("DButton", buttons)
        visibilityBtn:Dock(LEFT)
        visibilityBtn:SetWidth(100)
        visibilityBtn:DockMargin(0, 0, 5, 0)
        visibilityBtn:SetText(obj.visible and "Hide" or "Show")
        visibilityBtn:SetTextColor(Color(255, 255, 255))
        visibilityBtn.Paint = function(self, w, h)
            local col = obj.visible and Color(150, 100, 50) or Color(100, 150, 50)
            if self:IsHovered() then
                col = Color(col.r + 20, col.g + 20, col.b + 20)
            end
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        visibilityBtn.DoClick = function()
            net.Start("VJGM_ObjectiveToggleVisibility")
            net.WriteInt(obj.id, 32)
            net.SendToServer()
        end
        
        -- Delete button
        local deleteBtn = vgui.Create("DButton", buttons)
        deleteBtn:Dock(RIGHT)
        deleteBtn:SetWidth(80)
        deleteBtn:SetText("Delete")
        deleteBtn:SetTextColor(Color(255, 255, 255))
        deleteBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(200, 60, 60) or Color(150, 50, 50)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        deleteBtn.DoClick = function()
            VJGM.ObjectivesUI.ShowDeleteConfirmation(obj)
        end
    end
    
    --[[
        Show add objective dialog
    ]]--
    function VJGM.ObjectivesUI.ShowAddObjectiveDialog()
        local dialog = vgui.Create("DFrame")
        dialog:SetSize(500, 250)
        dialog:Center()
        dialog:SetTitle("Add New Objective")
        dialog:MakePopup()
        dialog:SetDeleteOnClose(true)
        
        -- Title input
        local titleLabel = vgui.Create("DLabel", dialog)
        titleLabel:SetPos(20, 35)
        titleLabel:SetSize(460, 20)
        titleLabel:SetText("Title:")
        titleLabel:SetTextColor(Color(255, 255, 255))
        
        local titleEntry = vgui.Create("DTextEntry", dialog)
        titleEntry:SetPos(20, 55)
        titleEntry:SetSize(460, 25)
        titleEntry:SetPlaceholderText("Enter objective title...")
        
        -- Description input
        local descLabel = vgui.Create("DLabel", dialog)
        descLabel:SetPos(20, 90)
        descLabel:SetSize(460, 20)
        descLabel:SetText("Description:")
        descLabel:SetTextColor(Color(255, 255, 255))
        
        local descEntry = vgui.Create("DTextEntry", dialog)
        descEntry:SetPos(20, 110)
        descEntry:SetSize(460, 60)
        descEntry:SetPlaceholderText("Enter objective description...")
        descEntry:SetMultiline(true)
        
        -- Add button
        local addBtn = vgui.Create("DButton", dialog)
        addBtn:SetPos(20, 185)
        addBtn:SetSize(220, 35)
        addBtn:SetText("Add Objective")
        addBtn:SetTextColor(Color(255, 255, 255))
        addBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(80, 150, 80) or Color(60, 120, 60)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        addBtn.DoClick = function()
            local title = titleEntry:GetValue()
            local description = descEntry:GetValue()
            
            if title == "" then
                Derma_Message("Please enter a title for the objective.", "Error", "OK")
                return
            end
            
            net.Start("VJGM_ObjectiveAdd")
            net.WriteString(title)
            net.WriteString(description)
            net.SendToServer()
            
            dialog:Close()
        end
        
        -- Cancel button
        local cancelBtn = vgui.Create("DButton", dialog)
        cancelBtn:SetPos(260, 185)
        cancelBtn:SetSize(220, 35)
        cancelBtn:SetText("Cancel")
        cancelBtn:SetTextColor(Color(255, 255, 255))
        cancelBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(100, 100, 100) or Color(70, 70, 70)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        cancelBtn.DoClick = function()
            dialog:Close()
        end
    end
    
    --[[
        Show edit objective dialog
    ]]--
    function VJGM.ObjectivesUI.ShowEditObjectiveDialog(obj)
        local dialog = vgui.Create("DFrame")
        dialog:SetSize(500, 250)
        dialog:Center()
        dialog:SetTitle("Edit Objective")
        dialog:MakePopup()
        dialog:SetDeleteOnClose(true)
        
        -- Title input
        local titleLabel = vgui.Create("DLabel", dialog)
        titleLabel:SetPos(20, 35)
        titleLabel:SetSize(460, 20)
        titleLabel:SetText("Title:")
        titleLabel:SetTextColor(Color(255, 255, 255))
        
        local titleEntry = vgui.Create("DTextEntry", dialog)
        titleEntry:SetPos(20, 55)
        titleEntry:SetSize(460, 25)
        titleEntry:SetValue(obj.title)
        
        -- Description input
        local descLabel = vgui.Create("DLabel", dialog)
        descLabel:SetPos(20, 90)
        descLabel:SetSize(460, 20)
        descLabel:SetText("Description:")
        descLabel:SetTextColor(Color(255, 255, 255))
        
        local descEntry = vgui.Create("DTextEntry", dialog)
        descEntry:SetPos(20, 110)
        descEntry:SetSize(460, 60)
        descEntry:SetValue(obj.description)
        descEntry:SetMultiline(true)
        
        -- Save button
        local saveBtn = vgui.Create("DButton", dialog)
        saveBtn:SetPos(20, 185)
        saveBtn:SetSize(220, 35)
        saveBtn:SetText("Save Changes")
        saveBtn:SetTextColor(Color(255, 255, 255))
        saveBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(70, 120, 180) or Color(50, 100, 150)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        saveBtn.DoClick = function()
            local title = titleEntry:GetValue()
            local description = descEntry:GetValue()
            
            if title == "" then
                Derma_Message("Please enter a title for the objective.", "Error", "OK")
                return
            end
            
            net.Start("VJGM_ObjectiveEdit")
            net.WriteInt(obj.id, 32)
            net.WriteString(title)
            net.WriteString(description)
            net.SendToServer()
            
            dialog:Close()
        end
        
        -- Cancel button
        local cancelBtn = vgui.Create("DButton", dialog)
        cancelBtn:SetPos(260, 185)
        cancelBtn:SetSize(220, 35)
        cancelBtn:SetText("Cancel")
        cancelBtn:SetTextColor(Color(255, 255, 255))
        cancelBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(100, 100, 100) or Color(70, 70, 70)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        cancelBtn.DoClick = function()
            dialog:Close()
        end
    end
    
    --[[
        Show delete confirmation dialog
    ]]--
    function VJGM.ObjectivesUI.ShowDeleteConfirmation(obj)
        Derma_Query(
            "Are you sure you want to delete the objective:\n'" .. obj.title .. "'?",
            "Confirm Delete",
            "Delete",
            function()
                net.Start("VJGM_ObjectiveDelete")
                net.WriteInt(obj.id, 32)
                net.SendToServer()
            end,
            "Cancel",
            function() end
        )
    end
    
    -- Console command to open the menu
    concommand.Add("vjgm_objectives", function()
        VJGM.ObjectivesUI.OpenMenu()
    end)
    
    print("[VJGM] Objectives UI initialized")
end
