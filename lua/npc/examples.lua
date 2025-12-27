--[[
    Dynamic NPC Spawner - Usage Examples
    
    This file demonstrates how to use the Dynamic NPC Spawner system
    Compatible with VJ Base NPC system
    
    Prerequisites:
    1. VJ Base addon installed
    2. Clone Wars NPC packs (or substitute with other VJ Base NPCs)
    3. All VJGM modules loaded
]]--

-- Example 1: Basic Wave Spawning
function ExampleBasicWave()
    -- First, register spawn points
    local centerPos = Vector(0, 0, 0)  -- Replace with actual position
    VJGM.SpawnPoints.RegisterInRadius("frontline", centerPos, 500, 8)
    
    -- Create a simple wave configuration
    local waveConfig = {
        waves = {
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",  -- Replace with VJ Base Clone Trooper
                        count = 5,
                        customization = {
                            health = 100,
                            weapons = {"weapon_vj_smg1"}
                        }
                    }
                },
                spawnPointGroup = "frontline",
                interval = 20
            }
        },
        defaultInterval = 30,
        cleanupOnComplete = false
    }
    
    -- Start the wave
    local waveID = VJGM.NPCSpawner.StartWave(waveConfig)
    print("Started wave: " .. tostring(waveID))
end

-- Example 2: Using the Wave Config Builder
function ExampleWaveBuilder()
    -- Register spawn points from map entities
    VJGM.SpawnPoints.RegisterFromEntities("default", "info_player_start")
    
    -- Build a wave configuration
    local waveConfig = VJGM.WaveConfig.CreateBuilder()
        :SetDefaultInterval(25)
        :SetCleanupOnComplete(false)
        :AddWave("default", 15)
        :AddNPCGroup("npc_vj_test_human", 3, {
            health = 100,
            weapons = {"weapon_vj_smg1"},
            vjbase = {
                faction = "VJ_FACTION_ANTLION",
                callForHelp = true,
                squad = "wave_1"
            }
        })
        :AddWave("default", 20)
        :AddNPCGroup("npc_vj_test_human", 5, {
            health = 150,
            weapons = {"weapon_vj_ar2"},
            vjbase = {
                faction = "VJ_FACTION_ANTLION",
                callForHelp = true,
                squad = "wave_2"
            }
        })
        :Build()
    
    if waveConfig then
        VJGM.NPCSpawner.StartWave(waveConfig)
    end
end

-- Example 3: Clone Wars Themed Event
function ExampleCloneWarsEvent()
    -- Setup multiple spawn point groups
    local republicSpawn = Vector(1000, 0, 0)  -- Replace with actual positions
    local separatistSpawn = Vector(-1000, 0, 0)
    
    VJGM.SpawnPoints.RegisterInRadius("republic", republicSpawn, 400, 6, Angle(0, 90, 0))
    VJGM.SpawnPoints.RegisterInRadius("separatist", separatistSpawn, 400, 6, Angle(0, 270, 0))
    
    -- Create Republic clone wave
    local republicWave = {
        waves = {
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",  -- Replace with Clone Trooper class
                        count = 8,
                        customization = {
                            health = 120,
                            weapons = {"weapon_vj_ar2"},
                            model = "models/player/clone_trooper.mdl",  -- Use actual model
                            vjbase = {
                                faction = "VJ_FACTION_PLAYER",
                                callForHelp = true,
                                canWander = false,
                                sightDistance = 10000,
                                squad = "republic_squad_1"
                            }
                        }
                    }
                },
                spawnPointGroup = "republic",
                interval = 30
            }
        },
        defaultInterval = 30,
        cleanupOnComplete = false
    }
    
    -- Create Separatist droid wave
    local separatistWave = {
        waves = {
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",  -- Replace with Battle Droid class
                        count = 12,
                        customization = {
                            health = 80,
                            weapons = {"weapon_vj_smg1"},
                            model = "models/battle_droid.mdl",  -- Use actual model
                            vjbase = {
                                faction = "VJ_FACTION_ANTLION",  -- Different faction
                                callForHelp = true,
                                canWander = false,
                                sightDistance = 8000,
                                squad = "separatist_squad_1"
                            }
                        }
                    }
                },
                spawnPointGroup = "separatist",
                interval = 25
            }
        },
        defaultInterval = 25,
        cleanupOnComplete = false
    }
    
    -- Start both waves
    local republicWaveID = VJGM.NPCSpawner.StartWave(republicWave)
    local separatistWaveID = VJGM.NPCSpawner.StartWave(separatistWave)
    
    print("Republic Wave: " .. tostring(republicWaveID))
    print("Separatist Wave: " .. tostring(separatistWaveID))
end

-- Example 4: Using Pre-made Clone Wars Configuration
function ExampleCloneWarsPreset()
    -- Setup spawn points
    local spawnPos = Vector(0, 0, 100)
    VJGM.SpawnPoints.RegisterInRadius("frontline", spawnPos, 600, 10)
    
    -- Use the pre-made Clone Wars configuration
    local waveConfig = VJGM.WaveConfig.CreateCloneWarsExample()
    
    -- Start the wave
    local waveID = VJGM.NPCSpawner.StartWave(waveConfig)
    
    -- Monitor wave progress
    timer.Create("WaveMonitor_" .. waveID, 5, 0, function()
        local status = VJGM.NPCSpawner.GetWaveStatus(waveID)
        if status then
            print(string.format("[Wave %s] Wave %d/%d | NPCs Alive: %d", 
                status.waveID, 
                status.currentWave, 
                status.totalWaves, 
                status.aliveNPCs
            ))
        else
            timer.Remove("WaveMonitor_" .. waveID)
        end
    end)
end

-- Example 5: Manual Spawn Point Creation
function ExampleManualSpawnPoints()
    -- Create specific spawn points manually
    VJGM.SpawnPoints.Register("entrance", Vector(500, 0, 0), Angle(0, 180, 0))
    VJGM.SpawnPoints.Register("entrance", Vector(600, 0, 0), Angle(0, 180, 0))
    VJGM.SpawnPoints.Register("entrance", Vector(550, 100, 0), Angle(0, 180, 0))
    
    VJGM.SpawnPoints.Register("flank", Vector(-200, 500, 0), Angle(0, 270, 0))
    VJGM.SpawnPoints.Register("flank", Vector(-200, 600, 0), Angle(0, 270, 0))
    
    -- Check spawn point counts
    print("Entrance points: " .. VJGM.SpawnPoints.GetCount("entrance"))
    print("Flank points: " .. VJGM.SpawnPoints.GetCount("flank"))
    
    -- List all groups
    local groups = VJGM.SpawnPoints.ListGroups()
    print("Spawn point groups: " .. table.concat(groups, ", "))
end

-- Example 6: Advanced Customization
function ExampleAdvancedCustomization()
    VJGM.SpawnPoints.RegisterInRadius("elite", Vector(0, 0, 0), 300, 5)
    
    local waveConfig = {
        waves = {
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",
                        count = 2,
                        customization = {
                            health = 500,
                            weapons = {"weapon_vj_rpg"},
                            model = "models/player/arc_trooper.mdl",
                            scale = 1.2,
                            color = Color(255, 100, 100),
                            skin = 1,
                            bodygroups = {
                                [0] = 1,
                                [1] = 2
                            },
                            vjbase = {
                                faction = "VJ_FACTION_PLAYER",
                                callForHelp = true,
                                canWander = false,
                                sightDistance = 15000,
                                meleeDistance = 0,
                                hearingCoef = 2.0,
                                squad = "elite_arc_troopers"
                            }
                        }
                    }
                },
                spawnPointGroup = "elite",
                interval = 0
            }
        },
        defaultInterval = 30,
        cleanupOnComplete = false
    }
    
    VJGM.NPCSpawner.StartWave(waveConfig)
end

-- Example 7: Event-Triggered Waves
function ExampleEventTriggeredWave()
    -- This can be called from a map trigger or other event
    local function OnPlayerReachesArea()
        local waveConfig = VJGM.WaveConfig.CreateExample()
        
        -- Add event trigger data for tracking
        local eventTrigger = {
            triggerType = "area_entered",
            triggerTime = CurTime(),
            triggerData = "control_point_alpha"
        }
        
        VJGM.NPCSpawner.StartWave(waveConfig, eventTrigger)
    end
    
    -- Example trigger setup (would typically be in a separate trigger script)
    -- hook.Add("PlayerEnteredArea", "ControlPointAlpha", OnPlayerReachesArea)
end

-- Example 8: Managing Active Waves
function ExampleWaveManagement()
    -- Get all active waves
    local activeWaves = VJGM.NPCSpawner.GetActiveWaves()
    print("Active waves: " .. #activeWaves)
    
    for _, waveID in ipairs(activeWaves) do
        local status = VJGM.NPCSpawner.GetWaveStatus(waveID)
        if status then
            print(string.format("Wave %s: %d/%d waves, %d NPCs alive, Active: %s",
                status.waveID,
                status.currentWave,
                status.totalWaves,
                status.aliveNPCs,
                tostring(status.isActive)
            ))
        end
    end
    
    -- Stop a specific wave
    if #activeWaves > 0 then
        VJGM.NPCSpawner.StopWave(activeWaves[1])
    end
end

--[[
    Console Commands for Testing
    Add these to your server's autorun to test the spawner
]]--

if SERVER then
    -- Command to test basic wave
    concommand.Add("vjgm_test_basic", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end
        ExampleBasicWave()
    end)
    
    -- Command to test Clone Wars preset
    concommand.Add("vjgm_test_clonewars", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end
        ExampleCloneWarsPreset()
    end)
    
    -- Command to stop all waves
    concommand.Add("vjgm_stop_all", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end
        local waves = VJGM.NPCSpawner.GetActiveWaves()
        for _, waveID in ipairs(waves) do
            VJGM.NPCSpawner.StopWave(waveID)
        end
        print("Stopped " .. #waves .. " waves")
    end)
    
    -- Command to list active waves
    concommand.Add("vjgm_list_waves", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end
        ExampleWaveManagement()
    end)
end
