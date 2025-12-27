--[[
    Spawn Point Manager
    Manages spawn point registration and selection for NPC spawning
    
    Compatible with VJ Base NPC system
]]--

if SERVER then
    
    -- Load configuration
    include("npc/config/init.lua")
    
    VJGM = VJGM or {}
    VJGM.SpawnPoints = VJGM.SpawnPoints or {}
    
    -- Spawn point storage
    local spawnPointGroups = {}
    
    --[[
        Initialize spawn point system
    ]]--
    function VJGM.SpawnPoints.Initialize()
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        spawnPointGroups = {}
        print(prefix .. " Spawn Point Manager initialized")
    end
    
    --[[
        Register a spawn point
        @param groupName: Name of the spawn point group
        @param pos: Vector position
        @param angle: Angle (optional)
        @return boolean: Success
    ]]--
    function VJGM.SpawnPoints.Register(groupName, pos, angle)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local defaultGroup = VJGM.Config.Get("SpawnPoints", "DefaultGroupName", "default")
        local defaultAngle = VJGM.Config.Get("SpawnPoints", "DefaultAngle", Angle(0, 0, 0))
        
        if not groupName or not pos then
            ErrorNoHalt(prefix .. " SpawnPoints: Invalid parameters for Register\n")
            return false
        end
        
        groupName = groupName or defaultGroup
        
        if not spawnPointGroups[groupName] then
            spawnPointGroups[groupName] = {}
        end
        
        table.insert(spawnPointGroups[groupName], {
            pos = pos,
            angle = angle or defaultAngle
        })
        
        return true
    end
    
    --[[
        Register multiple spawn points from entity class
        @param groupName: Name of the spawn point group
        @param entityClass: Entity class to use as spawn points (e.g., "info_player_start")
    ]]--
    function VJGM.SpawnPoints.RegisterFromEntities(groupName, entityClass)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local defaultGroup = VJGM.Config.Get("SpawnPoints", "DefaultGroupName", "default")
        local defaultEntityClass = VJGM.Config.Get("SpawnPoints", "DefaultEntityClass", "info_player_start")
        
        groupName = groupName or defaultGroup
        entityClass = entityClass or defaultEntityClass
        
        local spawnEnts = ents.FindByClass(entityClass)
        local count = 0
        
        for _, ent in ipairs(spawnEnts) do
            if IsValid(ent) then
                VJGM.SpawnPoints.Register(groupName, ent:GetPos(), ent:GetAngles())
                count = count + 1
            end
        end
        
        print(prefix .. " Registered " .. count .. " spawn points from " .. entityClass .. " to group: " .. groupName)
        return count
    end
    
    --[[
        Register spawn points in a radius around a position
        @param groupName: Name of the spawn point group
        @param centerPos: Center position
        @param radius: Radius to distribute points
        @param count: Number of points to create
        @param angle: Default angle for all points (optional)
    ]]--
    function VJGM.SpawnPoints.RegisterInRadius(groupName, centerPos, radius, count, angle)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local defaultGroup = VJGM.Config.Get("SpawnPoints", "DefaultGroupName", "default")
        local defaultRadius = VJGM.Config.Get("SpawnPoints", "DefaultRadius", 500)
        local defaultCount = VJGM.Config.Get("SpawnPoints", "DefaultRadialCount", 8)
        
        groupName = groupName or defaultGroup
        count = count or defaultCount
        radius = radius or defaultRadius
        
        -- Validate count to prevent division by zero
        if count <= 0 then
            ErrorNoHalt(prefix .. " SpawnPoints: Invalid count (must be > 0)\n")
            return
        end
        
        local angleStep = 360 / count
        
        for i = 1, count do
            local ang = math.rad(angleStep * i)
            local offset = Vector(math.cos(ang) * radius, math.sin(ang) * radius, 0)
            local spawnPos = centerPos + offset
            
            VJGM.SpawnPoints.Register(groupName, spawnPos, angle or Angle(0, angleStep * i, 0))
        end
        
        print(prefix .. " Registered " .. count .. " spawn points in radius for group: " .. groupName)
    end
    
    --[[
        Get spawn points for a group
        @param groupName: Name of the spawn point group
        @return Table of spawn points
    ]]--
    function VJGM.SpawnPoints.GetPoints(groupName)
        local defaultGroup = VJGM.Config.Get("SpawnPoints", "DefaultGroupName", "default")
        groupName = groupName or defaultGroup
        return spawnPointGroups[groupName] or {}
    end
    
    --[[
        Get a random spawn point from a group
        @param groupName: Name of the spawn point group
        @return Spawn point table or nil
    ]]--
    function VJGM.SpawnPoints.GetRandom(groupName)
        local points = VJGM.SpawnPoints.GetPoints(groupName)
        if #points == 0 then return nil end
        
        return points[math.random(1, #points)]
    end
    
    --[[
        Clear spawn points for a group
        @param groupName: Name of the spawn point group (nil for all groups)
    ]]--
    function VJGM.SpawnPoints.Clear(groupName)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        
        if groupName then
            spawnPointGroups[groupName] = nil
            print(prefix .. " Cleared spawn points for group: " .. groupName)
        else
            spawnPointGroups = {}
            print(prefix .. " Cleared all spawn points")
        end
    end
    
    --[[
        Get count of spawn points in a group
        @param groupName: Name of the spawn point group
        @return Number of spawn points
    ]]--
    function VJGM.SpawnPoints.GetCount(groupName)
        local points = VJGM.SpawnPoints.GetPoints(groupName)
        return #points
    end
    
    --[[
        List all spawn point groups
        @return Table of group names
    ]]--
    function VJGM.SpawnPoints.ListGroups()
        local groups = {}
        for groupName, _ in pairs(spawnPointGroups) do
            table.insert(groups, groupName)
        end
        return groups
    end
    
    --[[
        Get all spawn point groups with their data
        @return Table of group names
    ]]--
    function VJGM.SpawnPoints.GetAllGroups()
        local groups = {}
        for groupName, _ in pairs(spawnPointGroups) do
            table.insert(groups, groupName)
        end
        return groups
    end
    
    --[[
        Get all spawn points (all groups)
        @return Table with groups as keys and spawn point arrays as values
    ]]--
    function VJGM.SpawnPoints.GetAllSpawnPoints()
        return spawnPointGroups
    end
    
    -- Initialize on load
    hook.Add("Initialize", "VJGM_SpawnPoints_Init", function()
        VJGM.SpawnPoints.Initialize()
    end)
    
end
