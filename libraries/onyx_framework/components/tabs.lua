--[[
    Onyx UI Framework - Tabs Component
    Modern tab system with smooth transitions
]]--

if CLIENT then
    
    local PANEL = {}
    
    function PANEL:Init()
        self.tabs = {}
        self.activeTab = nil
        self.tabHeight = 40
        self.tabBar = vgui.Create("DPanel", self)
        self.tabBar:Dock(TOP)
        self.tabBar:SetHeight(self.tabHeight)
        self.tabBar.Paint = function(pnl, w, h)
            Onyx.DrawRoundedBox(0, 0, w, h, 0, Onyx.Colors.Background)
            surface.SetDrawColor(Onyx.Colors.Border)
            surface.DrawLine(0, h - 1, w, h - 1)
        end
        
        self.contentArea = vgui.Create("DPanel", self)
        self.contentArea:Dock(FILL)
        self.contentArea:DockMargin(0, 0, 0, 0)
        self.contentArea.Paint = function() end
    end
    
    function PANEL:AddTab(name, icon, content)
        local tabButton = vgui.Create("OnyxButton", self.tabBar)
        tabButton:Dock(LEFT)
        tabButton:SetWide(120)
        tabButton:DockMargin(4, 4, 4, 4)
        tabButton:SetButtonText(name)
        tabButton:SetBackgroundColor(Onyx.Colors.Surface)
        tabButton:SetHoverColor(Onyx.Colors.Primary)
        
        -- Create content panel
        local contentPanel = vgui.Create("DPanel", self.contentArea)
        contentPanel:Dock(FILL)
        contentPanel:SetVisible(false)
        contentPanel.Paint = function() end
        
        -- Store tab data
        local tab = {
            name = name,
            icon = icon,
            button = tabButton,
            content = contentPanel,
            contentFunction = content
        }
        
        table.insert(self.tabs, tab)
        
        -- Tab click handler
        tabButton.DoClick = function()
            self:SetActiveTab(tab)
        end
        
        -- If content is a function, call it to populate the panel
        if isfunction(content) then
            content(contentPanel)
        elseif IsValid(content) then
            content:SetParent(contentPanel)
            content:Dock(FILL)
        end
        
        -- Activate first tab
        if #self.tabs == 1 then
            self:SetActiveTab(tab)
        end
        
        return contentPanel
    end
    
    function PANEL:SetActiveTab(tab)
        -- Deactivate current tab
        if self.activeTab then
            self.activeTab.content:SetVisible(false)
            self.activeTab.button:SetBackgroundColor(Onyx.Colors.Surface)
        end
        
        -- Activate new tab
        self.activeTab = tab
        tab.content:SetVisible(true)
        tab.button:SetBackgroundColor(Onyx.Colors.Primary)
    end
    
    function PANEL:GetActiveTab()
        return self.activeTab
    end
    
    function PANEL:RemoveTab(name)
        for i, tab in ipairs(self.tabs) do
            if tab.name == name then
                if IsValid(tab.button) then
                    tab.button:Remove()
                end
                if IsValid(tab.content) then
                    tab.content:Remove()
                end
                table.remove(self.tabs, i)
                
                -- Activate first remaining tab if we removed the active one
                if tab == self.activeTab and #self.tabs > 0 then
                    self:SetActiveTab(self.tabs[1])
                end
                break
            end
        end
    end
    
    function PANEL:SetTabHeight(height)
        self.tabHeight = height
        self.tabBar:SetHeight(height)
    end
    
    vgui.Register("OnyxTabs", PANEL, "DPanel")
    
end
