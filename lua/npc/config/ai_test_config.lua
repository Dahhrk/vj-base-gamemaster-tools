--[[
    AI Behaviors Test Configuration
    Test scenarios and presets for AI behavior testing
    
    NOTE: These test scenarios use placeholder weapon names (weapon_vj_smg1, weapon_vj_ar2).
    Replace these with actual VJ Base weapon classes available on your server.
    Common VJ Base weapons include:
    - weapon_vj_9mmpistol
    - weapon_vj_ak47
    - weapon_vj_smg1
    - weapon_vj_ar2
    - weapon_vj_rpg
]]--

VJGM = VJGM or {}
VJGM.Config = VJGM.Config or {}

-- Test scenarios for AI behaviors
VJGM.Config.AITestScenarios = {
    
    -- Cover-seeking test scenario
    CoverSeekingTest = {
        name = "Cover Seeking Test",
        description = "Tests NPC cover-seeking behavior under fire",
        
        -- Setup function
        setup = function(spawnPos)
            if not VJGM.SpawnPoints then return end
            
            -- Create spawn points
            VJGM.SpawnPoints.RegisterInRadius("ai_cover_test", spawnPos, 400, 6)
            
            -- Create enemy spawn point
            local enemyPos = spawnPos + Vector(800, 0, 0)
            VJGM.SpawnPoints.RegisterInRadius("ai_cover_enemy", enemyPos, 200, 2)
        end,
        
        -- Wave configuration
        wave = {
            waves = {
                -- Friendly NPCs that should seek cover
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 3,
                            customization = {
                                health = 100,
                                weapons = {"weapon_vj_smg1"},
                                vjbase = {
                                    faction = "VJ_FACTION_PLAYER",
                                    squad = "cover_test_friendly"
                                }
                            },
                            aiOptions = {
                                coverSeeking = true,
                                targetPriority = true,
                                combatStates = true,
                            }
                        }
                    },
                    spawnPointGroup = "ai_cover_test",
                    interval = 0
                },
                -- Enemy NPCs to trigger cover behavior
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 2,
                            customization = {
                                health = 150,
                                weapons = {"weapon_vj_ar2"},
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION",
                                    squad = "cover_test_enemy"
                                }
                            }
                        }
                    },
                    spawnPointGroup = "ai_cover_enemy",
                    interval = 2
                }
            },
            defaultInterval = 30,
            cleanupOnComplete = false
        }
    },
    
    -- Target prioritization test
    TargetPriorityTest = {
        name = "Target Prioritization Test",
        description = "Tests NPCs selecting optimal targets based on threat",
        
        setup = function(spawnPos)
            if not VJGM.SpawnPoints then return end
            
            VJGM.SpawnPoints.RegisterInRadius("ai_priority_test", spawnPos, 300, 4)
            
            -- Multiple enemy types at different positions
            local enemyPos1 = spawnPos + Vector(600, 200, 0)  -- Normal enemy
            local enemyPos2 = spawnPos + Vector(600, -200, 0) -- Heavy enemy
            local enemyPos3 = spawnPos + Vector(800, 0, 0)    -- Medic enemy
            
            VJGM.SpawnPoints.Register("ai_enemy_normal", enemyPos1)
            VJGM.SpawnPoints.Register("ai_enemy_heavy", enemyPos2)
            VJGM.SpawnPoints.Register("ai_enemy_medic", enemyPos3)
        end,
        
        wave = {
            waves = {
                -- Friendly squad with AI
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 2,
                            customization = {
                                health = 120,
                                weapons = {"weapon_vj_smg1"},
                                vjbase = {
                                    faction = "VJ_FACTION_PLAYER"
                                }
                            },
                            aiOptions = {
                                targetPriority = true,
                                combatStates = true,
                            }
                        }
                    },
                    spawnPointGroup = "ai_priority_test",
                    interval = 0
                },
                -- Normal enemy
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 1,
                            customization = {
                                health = 80,
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION"
                                }
                            }
                        }
                    },
                    spawnPointGroup = "ai_enemy_normal",
                    interval = 1
                },
                -- Heavy enemy (should be medium priority)
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 1,
                            customization = {
                                health = 200,
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION"
                                }
                            },
                            role = "heavy"
                        }
                    },
                    spawnPointGroup = "ai_enemy_heavy",
                    interval = 1
                },
                -- Medic enemy (should be high priority)
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 1,
                            customization = {
                                health = 100,
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION"
                                }
                            },
                            role = "medic"
                        }
                    },
                    spawnPointGroup = "ai_enemy_medic",
                    interval = 1
                }
            },
            defaultInterval = 30,
            cleanupOnComplete = false
        }
    },
    
    -- Combat states test
    CombatStatesTest = {
        name = "Combat States Test",
        description = "Tests dynamic combat state transitions",
        
        setup = function(spawnPos)
            if not VJGM.SpawnPoints then return end
            
            VJGM.SpawnPoints.RegisterInRadius("ai_states_test", spawnPos, 400, 4)
            
            -- Waves of enemies to trigger different states
            local enemyWave1 = spawnPos + Vector(700, 0, 0)
            local enemyWave2 = spawnPos + Vector(700, 300, 0)
            local enemyWave3 = spawnPos + Vector(700, -300, 0)
            
            VJGM.SpawnPoints.Register("ai_enemy_wave1", enemyWave1)
            VJGM.SpawnPoints.Register("ai_enemy_wave2", enemyWave2)
            VJGM.SpawnPoints.Register("ai_enemy_wave3", enemyWave3)
        end,
        
        wave = {
            waves = {
                -- Test NPCs
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 3,
                            customization = {
                                health = 100,
                                weapons = {"weapon_vj_smg1"},
                                vjbase = {
                                    faction = "VJ_FACTION_PLAYER",
                                    squad = "states_test"
                                }
                            },
                            aiOptions = {
                                coverSeeking = true,
                                targetPriority = true,
                                combatStates = true,
                                groupComm = true,
                            }
                        }
                    },
                    spawnPointGroup = "ai_states_test",
                    interval = 0
                },
                -- First wave - should trigger aggressive state
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 1,
                            customization = {
                                health = 60,
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION"
                                }
                            }
                        }
                    },
                    spawnPointGroup = "ai_enemy_wave1",
                    interval = 3
                },
                -- Second wave - should trigger defensive state
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 3,
                            customization = {
                                health = 100,
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION"
                                }
                            }
                        }
                    },
                    spawnPointGroup = "ai_enemy_wave2",
                    interval = 10
                },
                -- Third wave - should trigger retreat state
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 5,
                            customization = {
                                health = 120,
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION"
                                }
                            }
                        }
                    },
                    spawnPointGroup = "ai_enemy_wave3",
                    interval = 20
                }
            },
            defaultInterval = 30,
            cleanupOnComplete = false
        }
    },
    
    -- Group communication test
    GroupCommunicationTest = {
        name = "Group Communication Test",
        description = "Tests squad coordination and communication",
        
        setup = function(spawnPos)
            if not VJGM.SpawnPoints then return end
            
            -- Squad spawn points
            VJGM.SpawnPoints.RegisterInRadius("ai_squad_test", spawnPos, 300, 5)
            
            -- Enemy spawn point
            local enemyPos = spawnPos + Vector(900, 0, 0)
            VJGM.SpawnPoints.RegisterInRadius("ai_squad_enemy", enemyPos, 400, 4)
        end,
        
        wave = {
            waves = {
                -- Coordinated squad
                {
                    npcs = {
                        -- Squad leader
                        {
                            class = "npc_vj_test_human",
                            count = 1,
                            customization = {
                                health = 150,
                                weapons = {"weapon_vj_ar2"},
                                vjbase = {
                                    faction = "VJ_FACTION_PLAYER",
                                    squad = "comm_test_alpha"
                                }
                            },
                            role = "squad_leader",
                            aiOptions = {
                                groupComm = true,
                                combatStates = true,
                                targetPriority = true,
                            }
                        },
                        -- Squad members
                        {
                            class = "npc_vj_test_human",
                            count = 3,
                            customization = {
                                health = 100,
                                weapons = {"weapon_vj_smg1"},
                                vjbase = {
                                    faction = "VJ_FACTION_PLAYER",
                                    squad = "comm_test_alpha"
                                }
                            },
                            aiOptions = {
                                groupComm = true,
                                combatStates = true,
                                targetPriority = true,
                            }
                        },
                        -- Medic
                        {
                            class = "npc_vj_test_human",
                            count = 1,
                            customization = {
                                health = 100,
                                weapons = {"weapon_vj_smg1"},
                                vjbase = {
                                    faction = "VJ_FACTION_PLAYER",
                                    squad = "comm_test_alpha"
                                }
                            },
                            role = "medic",
                            aiOptions = {
                                groupComm = true,
                            }
                        }
                    },
                    spawnPointGroup = "ai_squad_test",
                    interval = 0
                },
                -- Enemy squad
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 4,
                            customization = {
                                health = 100,
                                weapons = {"weapon_vj_ar2"},
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION",
                                    squad = "comm_test_enemy"
                                }
                            }
                        }
                    },
                    spawnPointGroup = "ai_squad_enemy",
                    interval = 3
                }
            },
            defaultInterval = 30,
            cleanupOnComplete = false
        }
    },
    
    -- Full AI feature test
    FullAITest = {
        name = "Full AI Feature Test",
        description = "Tests all AI features together in a complex scenario",
        
        setup = function(spawnPos)
            if not VJGM.SpawnPoints then return end
            
            -- Defensive position
            VJGM.SpawnPoints.RegisterInRadius("ai_full_defense", spawnPos, 400, 6)
            
            -- Multiple attack vectors
            local attackPos1 = spawnPos + Vector(1000, 0, 0)
            local attackPos2 = spawnPos + Vector(700, 700, 0)
            local attackPos3 = spawnPos + Vector(700, -700, 0)
            
            VJGM.SpawnPoints.RegisterInRadius("ai_full_attack1", attackPos1, 300, 3)
            VJGM.SpawnPoints.RegisterInRadius("ai_full_attack2", attackPos2, 300, 3)
            VJGM.SpawnPoints.RegisterInRadius("ai_full_attack3", attackPos3, 300, 3)
        end,
        
        wave = {
            waves = {
                -- Defending squad with all AI features
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 1,
                            customization = {
                                health = 150,
                                weapons = {"weapon_vj_ar2"},
                                vjbase = {
                                    faction = "VJ_FACTION_PLAYER",
                                    squad = "full_ai_defenders"
                                }
                            },
                            role = "squad_leader",
                            aiOptions = {
                                coverSeeking = true,
                                targetPriority = true,
                                combatStates = true,
                                groupComm = true,
                                weaponLogic = true,
                            }
                        },
                        {
                            class = "npc_vj_test_human",
                            count = 2,
                            customization = {
                                health = 100,
                                weapons = {"weapon_vj_smg1"},
                                vjbase = {
                                    faction = "VJ_FACTION_PLAYER",
                                    squad = "full_ai_defenders"
                                }
                            },
                            aiOptions = {
                                coverSeeking = true,
                                targetPriority = true,
                                combatStates = true,
                                groupComm = true,
                                weaponLogic = true,
                            }
                        },
                        {
                            class = "npc_vj_test_human",
                            count = 1,
                            customization = {
                                health = 100,
                                vjbase = {
                                    faction = "VJ_FACTION_PLAYER",
                                    squad = "full_ai_defenders"
                                }
                            },
                            role = "medic",
                            aiOptions = {
                                coverSeeking = true,
                                groupComm = true,
                            }
                        },
                        {
                            class = "npc_vj_test_human",
                            count = 1,
                            customization = {
                                health = 200,
                                weapons = {"weapon_vj_ar2"},
                                vjbase = {
                                    faction = "VJ_FACTION_PLAYER",
                                    squad = "full_ai_defenders"
                                }
                            },
                            role = "heavy",
                            aiOptions = {
                                targetPriority = true,
                                combatStates = true,
                                weaponLogic = true,
                            }
                        }
                    },
                    spawnPointGroup = "ai_full_defense",
                    interval = 0
                },
                -- Attack wave 1
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 3,
                            customization = {
                                health = 100,
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION"
                                }
                            }
                        }
                    },
                    spawnPointGroup = "ai_full_attack1",
                    interval = 5
                },
                -- Attack wave 2
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 2,
                            customization = {
                                health = 120,
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION"
                                }
                            }
                        }
                    },
                    spawnPointGroup = "ai_full_attack2",
                    interval = 10
                },
                -- Attack wave 3
                {
                    npcs = {
                        {
                            class = "npc_vj_test_human",
                            count = 2,
                            customization = {
                                health = 120,
                                vjbase = {
                                    faction = "VJ_FACTION_ANTLION"
                                }
                            }
                        }
                    },
                    spawnPointGroup = "ai_full_attack3",
                    interval = 10
                }
            },
            defaultInterval = 40,
            cleanupOnComplete = false
        }
    }
}

return VJGM.Config
