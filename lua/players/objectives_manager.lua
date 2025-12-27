--[[
    Objectives Manager - Server-side objectives management
    Manages mission objectives that gamemasters can create and sync to players
    
    Compatible with VJ Base Gamemaster Tools
]]--

if SERVER then
    
    VJGM = VJGM or {}
    VJGM.Objectives = VJGM.Objectives or {}
    
    -- Store all objectives
    local objectives = {}
    local nextObjectiveID = 1
    
    -- Network message registration
    util.AddNetworkString("VJGM_ObjectivesSync")
    util.AddNetworkString("VJGM_ObjectiveAdd")
    util.AddNetworkString("VJGM_ObjectiveEdit")
    util.AddNetworkString("VJGM_ObjectiveDelete")
    util.AddNetworkString("VJGM_ObjectiveToggleComplete")
    util.AddNetworkString("VJGM_ObjectiveToggleVisibility")
    util.AddNetworkString("VJGM_RequestObjectives")
    
    --[[
        Check if player is authorized to manage objectives
        @param ply: Player to check
        @return boolean: true if authorized
    ]]--
    function VJGM.Objectives.IsAuthorized(ply)
        if not IsValid(ply) then return false end
        
        -- Check if player is admin
        if ply:IsAdmin() then return true end
        
        -- Check CPPI (Creative Protection for Prop Improvements) if available
        -- This can be extended to support other permission systems
        if CPPI and CPPI.GetPermissions then
            local perms = CPPI.GetPermissions(ply)
            if perms and perms.objectives then return true end
        end
        
        return false
    end
    
    --[[
        Add a new objective
        @param title: Objective title
        @param description: Objective description
        @return number: Objective ID
    ]]--
    function VJGM.Objectives.Add(title, description)
        local id = nextObjectiveID
        nextObjectiveID = nextObjectiveID + 1
        
        objectives[id] = {
            id = id,
            title = title or "New Objective",
            description = description or "",
            completed = false,
            visible = true
        }
        
        print("[VJGM] Objective added: " .. title)
        VJGM.Objectives.SyncToAll()
        
        return id
    end
    
    --[[
        Edit an existing objective
        @param id: Objective ID
        @param title: New title (optional)
        @param description: New description (optional)
    ]]--
    function VJGM.Objectives.Edit(id, title, description)
        if not objectives[id] then
            print("[VJGM] Objective not found: " .. tostring(id))
            return false
        end
        
        if title then
            objectives[id].title = title
        end
        
        if description then
            objectives[id].description = description
        end
        
        print("[VJGM] Objective edited: " .. objectives[id].title)
        VJGM.Objectives.SyncToAll()
        
        return true
    end
    
    --[[
        Delete an objective
        @param id: Objective ID
    ]]--
    function VJGM.Objectives.Delete(id)
        if not objectives[id] then
            print("[VJGM] Objective not found: " .. tostring(id))
            return false
        end
        
        local title = objectives[id].title
        objectives[id] = nil
        
        print("[VJGM] Objective deleted: " .. title)
        VJGM.Objectives.SyncToAll()
        
        return true
    end
    
    --[[
        Toggle objective completion status
        @param id: Objective ID
    ]]--
    function VJGM.Objectives.ToggleComplete(id)
        if not objectives[id] then
            print("[VJGM] Objective not found: " .. tostring(id))
            return false
        end
        
        objectives[id].completed = not objectives[id].completed
        
        print("[VJGM] Objective " .. (objectives[id].completed and "completed" or "uncompleted") .. ": " .. objectives[id].title)
        VJGM.Objectives.SyncToAll()
        
        return true
    end
    
    --[[
        Toggle objective visibility to players
        @param id: Objective ID
    ]]--
    function VJGM.Objectives.ToggleVisibility(id)
        if not objectives[id] then
            print("[VJGM] Objective not found: " .. tostring(id))
            return false
        end
        
        objectives[id].visible = not objectives[id].visible
        
        print("[VJGM] Objective visibility " .. (objectives[id].visible and "enabled" or "disabled") .. ": " .. objectives[id].title)
        VJGM.Objectives.SyncToAll()
        
        return true
    end
    
    --[[
        Get all objectives
        @return table: All objectives
    ]]--
    function VJGM.Objectives.GetAll()
        return objectives
    end
    
    --[[
        Get a specific objective
        @param id: Objective ID
        @return table: Objective data
    ]]--
    function VJGM.Objectives.Get(id)
        return objectives[id]
    end
    
    --[[
        Sync all objectives to all clients
    ]]--
    function VJGM.Objectives.SyncToAll()
        net.Start("VJGM_ObjectivesSync")
        net.WriteTable(objectives)
        net.Broadcast()
    end
    
    --[[
        Sync objectives to a specific player
        @param ply: Player to sync to
    ]]--
    function VJGM.Objectives.SyncToPlayer(ply)
        if not IsValid(ply) then return end
        
        net.Start("VJGM_ObjectivesSync")
        net.WriteTable(objectives)
        net.Send(ply)
    end
    
    -- Network message handlers
    net.Receive("VJGM_RequestObjectives", function(len, ply)
        VJGM.Objectives.SyncToPlayer(ply)
    end)
    
    net.Receive("VJGM_ObjectiveAdd", function(len, ply)
        if not VJGM.Objectives.IsAuthorized(ply) then
            print("[VJGM] Unauthorized objective add attempt by " .. ply:Nick())
            return
        end
        
        local title = net.ReadString()
        local description = net.ReadString()
        
        VJGM.Objectives.Add(title, description)
    end)
    
    net.Receive("VJGM_ObjectiveEdit", function(len, ply)
        if not VJGM.Objectives.IsAuthorized(ply) then
            print("[VJGM] Unauthorized objective edit attempt by " .. ply:Nick())
            return
        end
        
        local id = net.ReadInt(32)
        local title = net.ReadString()
        local description = net.ReadString()
        
        VJGM.Objectives.Edit(id, title, description)
    end)
    
    net.Receive("VJGM_ObjectiveDelete", function(len, ply)
        if not VJGM.Objectives.IsAuthorized(ply) then
            print("[VJGM] Unauthorized objective delete attempt by " .. ply:Nick())
            return
        end
        
        local id = net.ReadInt(32)
        
        VJGM.Objectives.Delete(id)
    end)
    
    net.Receive("VJGM_ObjectiveToggleComplete", function(len, ply)
        if not VJGM.Objectives.IsAuthorized(ply) then
            print("[VJGM] Unauthorized objective complete toggle attempt by " .. ply:Nick())
            return
        end
        
        local id = net.ReadInt(32)
        
        VJGM.Objectives.ToggleComplete(id)
    end)
    
    net.Receive("VJGM_ObjectiveToggleVisibility", function(len, ply)
        if not VJGM.Objectives.IsAuthorized(ply) then
            print("[VJGM] Unauthorized objective visibility toggle attempt by " .. ply:Nick())
            return
        end
        
        local id = net.ReadInt(32)
        
        VJGM.Objectives.ToggleVisibility(id)
    end)
    
    -- Sync objectives to new players when they connect
    hook.Add("PlayerInitialSpawn", "VJGM_ObjectivesSync", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then
                VJGM.Objectives.SyncToPlayer(ply)
            end
        end)
    end)
    
    print("[VJGM] Objectives Manager initialized")
end
