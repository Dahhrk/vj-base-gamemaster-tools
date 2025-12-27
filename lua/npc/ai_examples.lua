--[[
    AI Behaviors - Usage Examples
    
    This file demonstrates how to use the AI Behaviors system
    Compatible with VJ Base NPC system
]]--

--[[
    Example 1: Basic AI-Enhanced NPC Spawning
    
    Enable AI behaviors for NPCs in a wave configuration
]]--
function ExampleBasicAIWave()
    -- Register spawn points
    local centerPos = Vector(0, 0, 0)  -- Replace with actual position
    VJGM.SpawnPoints.RegisterInRadius("ai_test", centerPos, 500, 8)
    
    -- Create wave with AI-enabled NPCs
    local waveConfig = {
        waves = {
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",
                        count = 5,
                        customization = {
                            health = 100,
                            weapons = {"weapon_vj_smg1"},
                            vjbase = {
                                faction = "VJ_FACTION_PLAYER",
                                squad = "ai_squad_1"
                            }
                        },
                        -- Enable AI behaviors
                        aiOptions = {
                            coverSeeking = true,
                            targetPriority = true,
                            combatStates = true,
                            groupComm = true,
                            weaponLogic = true
                        }
                    }
                },
                spawnPointGroup = "ai_test",
                interval = 20
            }
        },
        defaultInterval = 30,
        cleanupOnComplete = false
    }
    
    -- Start the wave
    local waveID = VJGM.NPCSpawner.StartWave(waveConfig)
    print("Started AI-enhanced wave: " .. tostring(waveID))
end

--[[
    Example 2: Selective AI Features
    
    Enable only specific AI features for different NPC types
]]--
function ExampleSelectiveAI()
    VJGM.SpawnPoints.RegisterInRadius("selective_ai", Vector(0, 0, 0), 400, 6)
    
    local waveConfig = {
        waves = {
            {
                npcs = {
                    -- Assault units: focus on combat and targeting
                    {
                        class = "npc_vj_test_human",
                        count = 3,
                        customization = {
                            health = 100,
                            vjbase = {
                                faction = "VJ_FACTION_PLAYER",
                                squad = "mixed_squad"
                            }
                        },
                        aiOptions = {
                            targetPriority = true,  -- Smart targeting
                            combatStates = true,    -- Dynamic states
                            weaponLogic = true      -- Weapon management
                        }
                    },
                    -- Support units: focus on positioning and communication
                    {
                        class = "npc_vj_test_human",
                        count = 2,
                        customization = {
                            health = 80,
                            vjbase = {
                                faction = "VJ_FACTION_PLAYER",
                                squad = "mixed_squad"
                            }
                        },
                        role = "medic",
                        aiOptions = {
                            coverSeeking = true,   -- Stay safe
                            groupComm = true       -- Coordinate with squad
                        }
                    }
                },
                spawnPointGroup = "selective_ai",
                interval = 0
            }
        },
        defaultInterval = 30,
        cleanupOnComplete = false
    }
    
    VJGM.NPCSpawner.StartWave(waveConfig)
end

--[[
    Example 3: Role-Based Squad with AI
    
    Combine role-based NPCs with AI behaviors
]]--
function ExampleRoleBasedAISquad()
    VJGM.SpawnPoints.RegisterInRadius("role_ai_squad", Vector(0, 0, 0), 300, 6)
    
    -- Create squad with roles and AI
    local squadConfig = {
        roles = {
            {
                role = VJGM.RoleBasedNPCs.Roles.SQUAD_LEADER,
                count = 1,
                customization = {
                    health = 150,
                    weapons = {"weapon_vj_ar2"}
                }
            },
            {
                role = VJGM.RoleBasedNPCs.Roles.ASSAULT,
                count = 3,
                customization = {
                    health = 100,
                    weapons = {"weapon_vj_smg1"}
                }
            },
            {
                role = VJGM.RoleBasedNPCs.Roles.MEDIC,
                count = 1,
                customization = {
                    health = 100
                }
            },
            {
                role = VJGM.RoleBasedNPCs.Roles.HEAVY,
                count = 1,
                customization = {
                    health = 200,
                    weapons = {"weapon_vj_ar2"}
                }
            }
        },
        baseClass = "npc_vj_test_human",
        faction = "VJ_FACTION_PLAYER",
        squadName = "Elite_Squad_1"
    }
    
    local npcConfigs = VJGM.RoleBasedNPCs.CreateSquad(squadConfig)
    
    -- Add AI options to each NPC config
    for _, npcConfig in ipairs(npcConfigs) do
        npcConfig.aiOptions = {
            coverSeeking = true,
            targetPriority = true,
            combatStates = true,
            groupComm = true,
            weaponLogic = true
        }
    end
    
    -- Create and start wave
    local waveConfig = {
        waves = {
            {
                npcs = npcConfigs,
                spawnPointGroup = "role_ai_squad",
                interval = 0
            }
        },
        defaultInterval = 30,
        cleanupOnComplete = false
    }
    
    VJGM.NPCSpawner.StartWave(waveConfig)
end

--[[
    Example 4: Defensive Scenario with AI
    
    NPCs defending a position using AI behaviors
]]--
function ExampleDefensiveAI()
    -- Setup defensive position
    local defensePos = Vector(0, 0, 0)  -- Replace with actual position
    VJGM.SpawnPoints.RegisterInRadius("defense_point", defensePos, 400, 8)
    
    -- Enemy attack positions
    local attackPos1 = defensePos + Vector(1000, 0, 0)
    local attackPos2 = defensePos + Vector(700, 700, 0)
    
    VJGM.SpawnPoints.RegisterInRadius("attack_1", attackPos1, 300, 4)
    VJGM.SpawnPoints.RegisterInRadius("attack_2", attackPos2, 300, 4)
    
    local waveConfig = {
        waves = {
            -- Defenders with full AI
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",
                        count = 6,
                        customization = {
                            health = 120,
                            weapons = {"weapon_vj_ar2"},
                            vjbase = {
                                faction = "VJ_FACTION_PLAYER",
                                squad = "defenders"
                            }
                        },
                        aiOptions = {
                            coverSeeking = true,      -- Use cover effectively
                            targetPriority = true,    -- Focus on threats
                            combatStates = true,      -- Adapt to situation
                            groupComm = true,         -- Coordinate defense
                            weaponLogic = true        -- Manage ammo
                        }
                    }
                },
                spawnPointGroup = "defense_point",
                interval = 0
            },
            -- First attack wave
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",
                        count = 4,
                        customization = {
                            health = 100,
                            vjbase = {
                                faction = "VJ_FACTION_ANTLION"
                            }
                        }
                    }
                },
                spawnPointGroup = "attack_1",
                interval = 5
            },
            -- Second attack wave
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",
                        count = 4,
                        customization = {
                            health = 100,
                            vjbase = {
                                faction = "VJ_FACTION_ANTLION"
                            }
                        }
                    }
                },
                spawnPointGroup = "attack_2",
                interval = 15
            }
        },
        defaultInterval = 30,
        cleanupOnComplete = false
    }
    
    VJGM.NPCSpawner.StartWave(waveConfig)
end

--[[
    Example 5: Enable AI for Existing NPC
    
    Enable AI behaviors for an already spawned NPC
]]--
function ExampleEnableAIForExistingNPC(npc)
    if not IsValid(npc) or not VJGM.AIBehaviors then
        return false
    end
    
    -- Enable all AI features
    local success = VJGM.AIBehaviors.EnableForNPC(npc, {
        coverSeeking = true,
        targetPriority = true,
        combatStates = true,
        groupComm = true,
        weaponLogic = true
    })
    
    if success then
        print("AI behaviors enabled for " .. npc:GetClass())
    end
    
    return success
end

--[[
    Example 6: Custom AI Configuration Override
    
    Use custom AI settings for a specific scenario
]]--
function ExampleCustomAIConfig()
    -- Temporarily override AI config
    local originalCoverThreshold = VJGM.Config.Get("CoverSeeking", "HealthThreshold")
    
    -- Make NPCs more aggressive (seek cover only at lower health)
    VJGM.Config.CoverSeeking.HealthThreshold = 0.4
    
    -- Make NPCs retreat earlier
    VJGM.Config.CombatStates.Retreat.HealthThreshold = 0.4
    
    -- Spawn wave with custom settings
    VJGM.SpawnPoints.RegisterInRadius("custom_ai", Vector(0, 0, 0), 400, 6)
    
    local waveConfig = {
        waves = {
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",
                        count = 4,
                        customization = {
                            health = 100,
                            vjbase = {
                                faction = "VJ_FACTION_PLAYER"
                            }
                        },
                        aiOptions = {
                            coverSeeking = true,
                            combatStates = true
                        }
                    }
                },
                spawnPointGroup = "custom_ai",
                interval = 0
            }
        },
        defaultInterval = 30,
        cleanupOnComplete = false
    }
    
    VJGM.NPCSpawner.StartWave(waveConfig)
    
    -- Restore original settings
    timer.Simple(60, function()
        VJGM.Config.CoverSeeking.HealthThreshold = originalCoverThreshold
    end)
end

--[[
    Example 7: AI-Enhanced Clone Wars Battle
    
    Full featured battle scenario with AI behaviors
]]--
function ExampleCloneWarsAIBattle()
    -- Republic position
    local republicPos = Vector(1000, 0, 0)
    VJGM.SpawnPoints.RegisterInRadius("republic", republicPos, 400, 8, Angle(0, 90, 0))
    
    -- Separatist position
    local separatistPos = Vector(-1000, 0, 0)
    VJGM.SpawnPoints.RegisterInRadius("separatist", separatistPos, 400, 8, Angle(0, 270, 0))
    
    local waveConfig = {
        waves = {
            -- Republic forces with AI
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",  -- Replace with Clone Trooper
                        count = 8,
                        customization = {
                            health = 120,
                            weapons = {"weapon_vj_ar2"},
                            vjbase = {
                                faction = "VJ_FACTION_PLAYER",
                                squad = "republic_main"
                            }
                        },
                        aiOptions = {
                            coverSeeking = true,
                            targetPriority = true,
                            combatStates = true,
                            groupComm = true,
                            weaponLogic = true
                        }
                    }
                },
                spawnPointGroup = "republic",
                interval = 0
            },
            -- Separatist forces with AI
            {
                npcs = {
                    {
                        class = "npc_vj_test_human",  -- Replace with Battle Droid
                        count = 10,
                        customization = {
                            health = 80,
                            weapons = {"weapon_vj_smg1"},
                            vjbase = {
                                faction = "VJ_FACTION_ANTLION",
                                squad = "separatist_main"
                            }
                        },
                        aiOptions = {
                            coverSeeking = true,
                            targetPriority = true,
                            combatStates = true,
                            groupComm = true
                        }
                    }
                },
                spawnPointGroup = "separatist",
                interval = 2
            }
        },
        defaultInterval = 60,
        cleanupOnComplete = false
    }
    
    local waveID = VJGM.NPCSpawner.StartWave(waveConfig)
    print("Started Clone Wars AI Battle: " .. tostring(waveID))
end
