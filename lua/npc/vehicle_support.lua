--[[
    Vehicle Support - PLACEHOLDER
    Future expansion for vehicle spawning support in wave-based events
    
    Planned Features:
    - Vehicle spawn waves integrated with NPC waves
    - Vehicle crew assignment (pilots, gunners)
    - Vehicle customization (health, weapons, speed)
    - Synchronized vehicle and infantry waves
    - Vehicle patrol routes
    
    Compatible with VJ Base and custom vehicle addons
]]--

if SERVER then
    
    -- Load configuration
    include("npc/config/init.lua")
    
    VJGM = VJGM or {}
    VJGM.VehicleSupport = VJGM.VehicleSupport or {}
    
    -- Track spawned vehicles
    local spawnedVehicles = {}
    
    --[[
        Initialize vehicle support system
    ]]--
    function VJGM.VehicleSupport.Initialize()
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local enabled = VJGM.Config.Get("VehicleSupport", "Enabled", true)
        
        spawnedVehicles = {}
        
        if enabled then
            print(prefix .. " Vehicle Support system initialized")
        else
            print(prefix .. " Vehicle Support system disabled in config")
        end
    end
    
    --[[
        Spawn a vehicle with crew
        @param vehicleClass: Vehicle entity class
        @param pos: Spawn position
        @param angle: Spawn angle
        @param crew: Table of NPC configurations for crew members
        @return vehicle entity or nil
    ]]--
    function VJGM.VehicleSupport.SpawnVehicleWithCrew(vehicleClass, pos, angle, crew)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local defaultHealth = VJGM.Config.Get("VehicleSupport", "DefaultVehicleHealth", 1000)
        local heightOffset = VJGM.Config.Get("VehicleSupport", "VehicleSpawnHeightOffset", 20)
        local autoAssign = VJGM.Config.Get("VehicleSupport", "AutoAssignCrew", true)
        
        if not vehicleClass or not pos then
            ErrorNoHalt(prefix .. " VehicleSupport.SpawnVehicleWithCrew - Missing vehicle class or position\n")
            return nil
        end
        
        -- Create vehicle entity
        local vehicle = ents.Create(vehicleClass)
        if not IsValid(vehicle) then
            ErrorNoHalt(prefix .. " VehicleSupport.SpawnVehicleWithCrew - Failed to create vehicle: " .. vehicleClass .. "\n")
            return nil
        end
        
        -- Position and angle
        vehicle:SetPos(pos + Vector(0, 0, heightOffset))
        if angle then
            vehicle:SetAngles(angle)
        end
        
        vehicle:Spawn()
        vehicle:Activate()
        
        -- Set default health
        if vehicle.SetMaxHealth then
            vehicle:SetMaxHealth(defaultHealth)
            vehicle:SetHealth(defaultHealth)
        end
        
        -- Track vehicle
        table.insert(spawnedVehicles, vehicle)
        
        -- Spawn and assign crew if provided
        if crew and autoAssign then
            local crewNPCs = {}
            local crewRadius = VJGM.Config.Get("VehicleSupport", "CrewSpawnRadius", 50)
            local assignDelay = VJGM.Config.Get("VehicleSupport", "CrewAssignmentDelay", 0.1)
            
            -- Spawn crew NPCs near vehicle
            for seatName, crewConfig in pairs(crew) do
                if crewConfig.class then
                    local crewNPC = ents.Create(crewConfig.class)
                    if IsValid(crewNPC) then
                        crewNPC:SetPos(pos + Vector(math.random(-crewRadius, crewRadius), math.random(-crewRadius, crewRadius), 0))
                        
                        -- VJ Base pre-spawn settings
                        if crewNPC.IsVJBaseSNPC == true and crewConfig.customization and crewConfig.customization.vjbase then
                            if VJGM.NPCSpawner and VJGM.NPCSpawner.ApplyVJBaseSettings then
                                VJGM.NPCSpawner.ApplyVJBaseSettings(crewNPC, crewConfig.customization.vjbase)
                            end
                        end
                        
                        crewNPC:Spawn()
                        crewNPC:Activate()
                        
                        -- Post-spawn customization
                        if crewConfig.customization and VJGM.NPCCustomizer then
                            VJGM.NPCCustomizer.Apply(crewNPC, crewConfig.customization)
                        end
                        
                        -- Store crew reference
                        crewNPCs[seatName] = crewNPC
                        
                        -- Try to enter vehicle (for supported vehicle types)
                        timer.Simple(assignDelay, function()
                            if IsValid(crewNPC) and IsValid(vehicle) then
                                if vehicle.HandleNPCEntry then
                                    vehicle:HandleNPCEntry(crewNPC)
                                elseif crewNPC.EnterVehicle then
                                    crewNPC:EnterVehicle(vehicle)
                                end
                            end
                        end)
                    end
                end
            end
            
            vehicle.VJGM_Crew = crewNPCs
        end
        
        -- Cleanup callback
        vehicle:CallOnRemove("VJGM_VehicleCleanup_" .. vehicle:EntIndex(), function()
            table.RemoveByValue(spawnedVehicles, vehicle)
        end)
        
        return vehicle
    end
    
    --[[
        Add vehicle wave to configuration
        @param waveConfig: Wave configuration to modify
        @param vehicleWave: Vehicle wave configuration
    ]]--
    function VJGM.VehicleSupport.AddVehicleWave(waveConfig, vehicleWave)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local defaultInterval = VJGM.Config.Get("VehicleSupport", "DefaultVehicleInterval", 60)
        
        if not waveConfig or not waveConfig.waves then
            ErrorNoHalt(prefix .. " VehicleSupport.AddVehicleWave - Invalid wave configuration\n")
            return false
        end
        
        if not vehicleWave or not vehicleWave.vehicles then
            ErrorNoHalt(prefix .. " VehicleSupport.AddVehicleWave - Invalid vehicle wave configuration\n")
            return false
        end
        
        -- Create a wave entry for vehicles
        local wave = {
            npcs = {},
            vehicles = vehicleWave.vehicles,
            spawnPointGroup = vehicleWave.spawnPointGroup or "default",
            interval = vehicleWave.interval or defaultInterval
        }
        
        table.insert(waveConfig.waves, wave)
        
        return true
    end
    
    --[[
        Create vehicle patrol path
        @param vehicle: Vehicle entity
        @param waypoints: Table of Vector positions
    ]]--
    function VJGM.VehicleSupport.SetPatrolPath(vehicle, waypoints)
        if not IsValid(vehicle) or not waypoints or #waypoints == 0 then
            ErrorNoHalt("[VJGM] VehicleSupport.SetPatrolPath - Invalid vehicle or waypoints\n")
            return false
        end
        
        local patrolSpeed = VJGM.Config.Get("VehicleSupport", "PatrolSpeed", 200)
        local stopDistance = VJGM.Config.Get("VehicleSupport", "PatrolStopDistance", 100)
        
        vehicle.VJGM_PatrolWaypoints = waypoints
        vehicle.VJGM_CurrentWaypointIndex = 1
        vehicle.VJGM_PatrolSpeed = patrolSpeed
        
        -- Start patrol timer
        local timerName = "VJGM_VehiclePatrol_" .. vehicle:EntIndex()
        timer.Create(timerName, 0.1, 0, function()
            if not IsValid(vehicle) then
                timer.Remove(timerName)
                return
            end
            
            local currentWP = vehicle.VJGM_PatrolWaypoints[vehicle.VJGM_CurrentWaypointIndex]
            if not currentWP then return end
            
            local vehiclePos = vehicle:GetPos()
            local distToWP = vehiclePos:Distance(currentWP)
            
            -- Check if reached waypoint
            if distToWP < stopDistance then
                -- Move to next waypoint
                vehicle.VJGM_CurrentWaypointIndex = vehicle.VJGM_CurrentWaypointIndex + 1
                if vehicle.VJGM_CurrentWaypointIndex > #vehicle.VJGM_PatrolWaypoints then
                    vehicle.VJGM_CurrentWaypointIndex = 1
                end
            else
                -- Move towards waypoint (for NPCs driving vehicles)
                -- TODO: Implement vehicle movement for VJ Base NPCs
                -- This requires vehicle-specific logic depending on the vehicle type
                -- For scripted vehicles, commands can be sent to the driver NPC
                -- For simfphys or other vehicle addons, use their specific APIs
                if vehicle.VJGM_Crew and vehicle.VJGM_Crew.driver then
                    local driver = vehicle.VJGM_Crew.driver
                    if IsValid(driver) and driver.IsVJBaseSNPC then
                        -- VJ Base NPCs can be given movement commands
                        -- Note: Actual implementation depends on vehicle addon used
                        -- This is a placeholder for future vehicle-specific implementations
                    end
                end
            end
        end)
        
        return true
    end
    
    -- Hook for future initialization
    hook.Add("Initialize", "VJGM_VehicleSupport_Init", function()
        VJGM.VehicleSupport.Initialize()
    end)
    
    --[[
        Get all spawned vehicles
        @return Table of vehicle entities
    ]]--
    function VJGM.VehicleSupport.GetSpawnedVehicles()
        local vehicles = {}
        for _, vehicle in ipairs(spawnedVehicles) do
            if IsValid(vehicle) then
                table.insert(vehicles, vehicle)
            end
        end
        return vehicles
    end
    
    --[[
        Cleanup all spawned vehicles
    ]]--
    function VJGM.VehicleSupport.CleanupAll()
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local count = 0
        
        for _, vehicle in ipairs(spawnedVehicles) do
            if IsValid(vehicle) then
                vehicle:Remove()
                count = count + 1
            end
        end
        
        spawnedVehicles = {}
        print(prefix .. " Cleaned up " .. count .. " vehicles")
    end
    
end

--[[
    USAGE EXAMPLE (Future):
    
    -- Add vehicle wave to existing wave configuration
    local waveConfig = VJGM.WaveConfig.CreateCloneWarsExample()
    
    VJGM.VehicleSupport.AddVehicleWave(waveConfig, {
        vehicles = {
            {
                class = "prop_vehicle_prisoner_pod",  -- Replace with LAAT or AT-TE
                count = 1,
                crew = {
                    driver = {
                        class = "npc_vj_clone_pilot",
                        customization = {
                            health = 150,
                            weapons = {"weapon_vj_dc15s"}
                        }
                    }
                },
                customization = {
                    health = 5000,
                    skin = 0
                }
            }
        },
        spawnPointGroup = "vehicle_spawns",
        interval = 60
    })
]]--
