--[[
    Testing Tools & Console Commands
    Provides debugging and testing utilities for the Dynamic NPC Spawner
    
    Compatible with VJ Base NPC system
]]--

if SERVER then
    
    -- Load configuration once
    include("npc/config/init.lua")
    include("npc/config/ai_test_config.lua")
    
    VJGM = VJGM or {}
    VJGM.TestingTools = VJGM.TestingTools or {}
    
    --[[
        Check if player is authorized (admin)
        @param ply: Player to check
        @return boolean: true if authorized
    ]]--
    function VJGM.TestingTools.IsAuthorized(ply)
        return not IsValid(ply) or ply:IsAdmin()
    end
    
    --[[
        Initialize testing tools
    ]]--
    function VJGM.TestingTools.Initialize()
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        print(prefix .. " Testing Tools initialized")
    end
    
    --[[
        Print detailed wave status
        @param waveID: Wave identifier (nil for all waves)
    ]]--
    function VJGM.TestingTools.PrintWaveStatus(waveID)
        if waveID then
            local status = VJGM.NPCSpawner.GetWaveStatus(waveID)
            if status then
                print("========== Wave Status: " .. waveID .. " ==========")
                print("  Current Wave: " .. status.currentWave .. " / " .. status.totalWaves)
                print("  Active: " .. tostring(status.isActive))
                print("  NPCs Alive: " .. status.aliveNPCs)
                print("==========================================")
            else
                print("Wave not found: " .. tostring(waveID))
            end
        else
            local activeWaves = VJGM.NPCSpawner.GetActiveWaves()
            print("========== All Active Waves ==========")
            print("  Total Active Waves: " .. #activeWaves)
            for _, wID in ipairs(activeWaves) do
                local status = VJGM.NPCSpawner.GetWaveStatus(wID)
                if status then
                    print("  [" .. wID .. "] Wave " .. status.currentWave .. "/" .. status.totalWaves .. " | NPCs: " .. status.aliveNPCs)
                end
            end
            print("======================================")
        end
    end
    
    --[[
        List all NPCs with their roles
    ]]--
    function VJGM.TestingTools.ListRoleNPCs()
        if not VJGM.RoleBasedNPCs then
            print("Role-Based NPCs system not loaded")
            return
        end
        
        print("========== Role-Based NPCs ==========")
        local roles = VJGM.RoleBasedNPCs.Roles
        for roleName, roleID in pairs(roles) do
            local npcs = VJGM.RoleBasedNPCs.GetNPCsByRole(roleID)
            print("  " .. roleName .. ": " .. #npcs .. " NPCs")
            for i, npc in ipairs(npcs) do
                if IsValid(npc) then
                    print("    [" .. i .. "] " .. npc:GetClass() .. " (HP: " .. npc:Health() .. "/" .. npc:GetMaxHealth() .. ")")
                end
            end
        end
        print("====================================")
    end
    
    --[[
        List all spawned vehicles
    ]]--
    function VJGM.TestingTools.ListVehicles()
        if not VJGM.VehicleSupport then
            print("Vehicle Support system not loaded")
            return
        end
        
        local vehicles = VJGM.VehicleSupport.GetSpawnedVehicles()
        print("========== Spawned Vehicles ==========")
        print("  Total Vehicles: " .. #vehicles)
        for i, vehicle in ipairs(vehicles) do
            if IsValid(vehicle) then
                print("  [" .. i .. "] " .. vehicle:GetClass() .. " (HP: " .. vehicle:Health() .. ")")
                if vehicle.VJGM_Crew then
                    print("    Crew:")
                    for role, crewNPC in pairs(vehicle.VJGM_Crew) do
                        if IsValid(crewNPC) then
                            print("      " .. role .. ": " .. crewNPC:GetClass())
                        end
                    end
                end
            end
        end
        print("======================================")
    end
    
    --[[
        Show spawn point information
        @param groupName: Spawn point group (nil for all groups)
    ]]--
    function VJGM.TestingTools.ShowSpawnPoints(groupName)
        if not VJGM.SpawnPoints then
            print("Spawn Points system not loaded")
            return
        end
        
        if groupName then
            local points = VJGM.SpawnPoints.GetPoints(groupName)
            print("========== Spawn Points: " .. groupName .. " ==========")
            print("  Count: " .. #points)
            for i, point in ipairs(points) do
                print("  [" .. i .. "] Pos: " .. tostring(point.pos) .. " | Angle: " .. tostring(point.angle))
            end
            print("==============================================")
        else
            local groups = VJGM.SpawnPoints.ListGroups()
            print("========== All Spawn Point Groups ==========")
            for _, group in ipairs(groups) do
                local count = VJGM.SpawnPoints.GetCount(group)
                print("  " .. group .. ": " .. count .. " points")
            end
            print("===========================================")
        end
    end
    
    --[[
        Test role-based squad creation
    ]]--
    function VJGM.TestingTools.TestRoleSquad()
        if not VJGM.RoleBasedNPCs then
            print("Role-Based NPCs system not loaded")
            return
        end
        
        local squadConfig = {
            roles = {
                { role = VJGM.RoleBasedNPCs.Roles.SQUAD_LEADER, count = 1 },
                { role = VJGM.RoleBasedNPCs.Roles.ASSAULT, count = 3 },
                { role = VJGM.RoleBasedNPCs.Roles.MEDIC, count = 1 },
                { role = VJGM.RoleBasedNPCs.Roles.HEAVY, count = 1 }
            },
            baseClass = "npc_vj_test_human",
            faction = "VJ_FACTION_PLAYER",
            squadName = "TestSquad_" .. math.random(1000, 9999)
        }
        
        local npcConfigs = VJGM.RoleBasedNPCs.CreateSquad(squadConfig)
        print("Created squad configuration with " .. #npcConfigs .. " NPCs")
        
        return npcConfigs
    end
    
    -- Hook for initialization
    hook.Add("Initialize", "VJGM_TestingTools_Init", function()
        VJGM.TestingTools.Initialize()
    end)
    
    -- Console Commands
    
    -- Wave control commands
    concommand.Add("vjgm_wave_status", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        local waveID = args[1]
        VJGM.TestingTools.PrintWaveStatus(waveID)
    end)
    
    concommand.Add("vjgm_wave_pause", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        local waveID = args[1]
        if waveID and VJGM.NPCSpawner then
            VJGM.NPCSpawner.PauseWave(waveID)
        else
            print("Usage: vjgm_wave_pause <wave_id>")
        end
    end)
    
    concommand.Add("vjgm_wave_resume", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        local waveID = args[1]
        if waveID and VJGM.NPCSpawner then
            VJGM.NPCSpawner.ResumeWave(waveID)
        else
            print("Usage: vjgm_wave_resume <wave_id>")
        end
    end)
    
    concommand.Add("vjgm_wave_stop", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        local waveID = args[1]
        if waveID and VJGM.NPCSpawner then
            VJGM.NPCSpawner.StopWave(waveID)
        else
            print("Usage: vjgm_wave_stop <wave_id>")
        end
    end)
    
    concommand.Add("vjgm_wave_stop_all", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        if VJGM.NPCSpawner then
            local waves = VJGM.NPCSpawner.GetActiveWaves()
            for _, waveID in ipairs(waves) do
                VJGM.NPCSpawner.StopWave(waveID)
            end
            print("Stopped " .. #waves .. " waves")
        end
    end)
    
    -- Role NPC commands
    concommand.Add("vjgm_list_roles", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        VJGM.TestingTools.ListRoleNPCs()
    end)
    
    concommand.Add("vjgm_test_squad", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        VJGM.TestingTools.TestRoleSquad()
    end)
    
    -- Vehicle commands
    concommand.Add("vjgm_list_vehicles", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        VJGM.TestingTools.ListVehicles()
    end)
    
    concommand.Add("vjgm_cleanup_vehicles", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        if VJGM.VehicleSupport then
            VJGM.VehicleSupport.CleanupAll()
        end
    end)
    
    -- Spawn point commands
    concommand.Add("vjgm_list_spawns", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        local groupName = args[1]
        VJGM.TestingTools.ShowSpawnPoints(groupName)
    end)
    
    concommand.Add("vjgm_clear_spawns", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        if VJGM.SpawnPoints then
            local groupName = args[1]
            VJGM.SpawnPoints.Clear(groupName)
        end
    end)
    
    -- Quick test wave with roles
    concommand.Add("vjgm_test_role_wave", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        
        -- Setup spawn points
        local spawnOffset = VJGM.Config.Get("TestingTools", "SpawnDistanceOffset", 300)
        local spawnPos = IsValid(ply) and ply:GetPos() + ply:GetForward() * spawnOffset or Vector(0, 0, 100)
        if VJGM.SpawnPoints then
            VJGM.SpawnPoints.RegisterInRadius("test_roles", spawnPos, 400, 6)
        end
        
        -- Create role-based wave
        local squadConfigs = VJGM.TestingTools.TestRoleSquad()
        
        if VJGM.WaveConfig and VJGM.NPCSpawner then
            local waveConfig = {
                waves = {
                    {
                        npcs = squadConfigs,
                        spawnPointGroup = "test_roles",
                        interval = 0
                    }
                },
                defaultInterval = 30,
                cleanupOnComplete = false
            }
            
            local waveID = VJGM.NPCSpawner.StartWave(waveConfig)
            print("Started test role wave: " .. tostring(waveID))
        end
    end)
    
    -- Test vehicle wave
    concommand.Add("vjgm_test_vehicle_wave", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        
        -- Setup spawn points
        local spawnOffset = VJGM.Config.Get("TestingTools", "SpawnDistanceOffset", 300)
        local spawnPos = IsValid(ply) and ply:GetPos() + ply:GetForward() * (spawnOffset * 1.67) or Vector(0, 0, 100)
        if VJGM.SpawnPoints then
            VJGM.SpawnPoints.RegisterInRadius("test_vehicles", spawnPos, 200, 3)
        end
        
        if VJGM.WaveConfig and VJGM.NPCSpawner and VJGM.VehicleSupport then
            local waveConfig = {
                waves = {
                    {
                        npcs = {},
                        vehicles = {
                            {
                                class = "prop_vehicle_jeep",
                                count = 1,
                                crew = {
                                    driver = {
                                        class = "npc_vj_test_human",
                                        customization = {
                                            health = 100,
                                            vjbase = {
                                                faction = "VJ_FACTION_PLAYER"
                                            }
                                        }
                                    }
                                },
                                customization = {
                                    health = 1000
                                }
                            }
                        },
                        spawnPointGroup = "test_vehicles",
                        interval = 0
                    }
                },
                defaultInterval = 30,
                cleanupOnComplete = false
            }
            
            local waveID = VJGM.NPCSpawner.StartWave(waveConfig)
            print("Started test vehicle wave: " .. tostring(waveID))
        end
    end)
    
    -- Help command
    -- AI Behaviors commands
    concommand.Add("vjgm_list_ai_npcs", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        if not VJGM.AIBehaviors then
            print("AI Behaviors system not loaded")
            return
        end
        
        local aiNPCs = VJGM.AIBehaviors.GetAINPCs()
        print("========== AI-Enabled NPCs ==========")
        print("  Total: " .. #aiNPCs)
        for i, npc in ipairs(aiNPCs) do
            if IsValid(npc) then
                local state = npc.VJGM_CombatState or "normal"
                print("  [" .. i .. "] " .. npc:GetClass() .. " | State: " .. state .. " | HP: " .. npc:Health() .. "/" .. npc:GetMaxHealth())
            end
        end
        print("====================================")
    end)
    
    -- AI Test scenario commands
    concommand.Add("vjgm_test_ai_cover", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        
        local scenario = VJGM.Config.AITestScenarios and VJGM.Config.AITestScenarios.CoverSeekingTest
        
        if not scenario then
            print("Scenario not found")
            return
        end
        
        local spawnPos = IsValid(ply) and ply:GetPos() + ply:GetForward() * 500 or Vector(0, 0, 100)
        
        -- Setup scenario
        if scenario.setup then
            scenario.setup(spawnPos)
        end
        
        -- Start wave
        if VJGM.NPCSpawner and scenario.wave then
            local waveID = VJGM.NPCSpawner.StartWave(scenario.wave)
            print("Started AI test: " .. scenario.name .. " (" .. tostring(waveID) .. ")")
        end
    end)
    
    concommand.Add("vjgm_test_ai_target", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        
        local scenario = VJGM.Config.AITestScenarios and VJGM.Config.AITestScenarios.TargetPriorityTest
        
        if not scenario then
            print("Scenario not found")
            return
        end
        
        local spawnPos = IsValid(ply) and ply:GetPos() + ply:GetForward() * 500 or Vector(0, 0, 100)
        
        if scenario.setup then
            scenario.setup(spawnPos)
        end
        
        if VJGM.NPCSpawner and scenario.wave then
            local waveID = VJGM.NPCSpawner.StartWave(scenario.wave)
            print("Started AI test: " .. scenario.name .. " (" .. tostring(waveID) .. ")")
        end
    end)
    
    concommand.Add("vjgm_test_ai_states", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        
        local scenario = VJGM.Config.AITestScenarios and VJGM.Config.AITestScenarios.CombatStatesTest
        
        if not scenario then
            print("Scenario not found")
            return
        end
        
        local spawnPos = IsValid(ply) and ply:GetPos() + ply:GetForward() * 500 or Vector(0, 0, 100)
        
        if scenario.setup then
            scenario.setup(spawnPos)
        end
        
        if VJGM.NPCSpawner and scenario.wave then
            local waveID = VJGM.NPCSpawner.StartWave(scenario.wave)
            print("Started AI test: " .. scenario.name .. " (" .. tostring(waveID) .. ")")
        end
    end)
    
    concommand.Add("vjgm_test_ai_comm", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        
        local scenario = VJGM.Config.AITestScenarios and VJGM.Config.AITestScenarios.GroupCommunicationTest
        
        if not scenario then
            print("Scenario not found")
            return
        end
        
        local spawnPos = IsValid(ply) and ply:GetPos() + ply:GetForward() * 500 or Vector(0, 0, 100)
        
        if scenario.setup then
            scenario.setup(spawnPos)
        end
        
        if VJGM.NPCSpawner and scenario.wave then
            local waveID = VJGM.NPCSpawner.StartWave(scenario.wave)
            print("Started AI test: " .. scenario.name .. " (" .. tostring(waveID) .. ")")
        end
    end)
    
    concommand.Add("vjgm_test_ai_full", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        
        local scenario = VJGM.Config.AITestScenarios and VJGM.Config.AITestScenarios.FullAITest
        
        if not scenario then
            print("Scenario not found")
            return
        end
        
        local spawnPos = IsValid(ply) and ply:GetPos() + ply:GetForward() * 500 or Vector(0, 0, 100)
        
        if scenario.setup then
            scenario.setup(spawnPos)
        end
        
        if VJGM.NPCSpawner and scenario.wave then
            local waveID = VJGM.NPCSpawner.StartWave(scenario.wave)
            print("Started AI test: " .. scenario.name .. " (" .. tostring(waveID) .. ")")
        end
    end)
    
    concommand.Add("vjgm_help", function(ply, cmd, args)
        if not VJGM.TestingTools.IsAuthorized(ply) then return end
        print("========== VJGM Testing Commands ==========")
        print("Wave Control:")
        print("  vjgm_wave_status [wave_id] - Show wave status")
        print("  vjgm_wave_pause <wave_id> - Pause a wave")
        print("  vjgm_wave_resume <wave_id> - Resume a wave")
        print("  vjgm_wave_stop <wave_id> - Stop a wave")
        print("  vjgm_wave_stop_all - Stop all waves")
        print("")
        print("Role-Based NPCs:")
        print("  vjgm_list_roles - List all role-based NPCs")
        print("  vjgm_test_squad - Test squad creation")
        print("  vjgm_test_role_wave - Spawn test wave with roles")
        print("")
        print("AI Behaviors:")
        print("  vjgm_list_ai_npcs - List all AI-enabled NPCs")
        print("  vjgm_test_ai_cover - Test cover-seeking behavior")
        print("  vjgm_test_ai_target - Test target prioritization")
        print("  vjgm_test_ai_states - Test combat states")
        print("  vjgm_test_ai_comm - Test group communication")
        print("  vjgm_test_ai_full - Test all AI features")
        print("")
        print("Vehicles:")
        print("  vjgm_list_vehicles - List all spawned vehicles")
        print("  vjgm_cleanup_vehicles - Remove all vehicles")
        print("  vjgm_test_vehicle_wave - Spawn test vehicle wave")
        print("")
        print("Spawn Points:")
        print("  vjgm_list_spawns [group] - List spawn points")
        print("  vjgm_clear_spawns [group] - Clear spawn points")
        print("")
        print("Testing:")
        print("  vjgm_test_basic - Basic wave test")
        print("  vjgm_test_clonewars - Clone Wars preset test")
        print("=========================================")
    end)
    
end
