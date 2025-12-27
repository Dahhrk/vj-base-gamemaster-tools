--[[
    Wave Templates - Preset Wave Configurations
    Pre-configured wave templates for quick event setup
    
    These templates can be used directly or modified through the UI editor
]]--

VJGM = VJGM or {}
VJGM.WaveTemplates = VJGM.WaveTemplates or {}

--[[
    Get all available wave templates
    @return Table of template definitions
]]--
function VJGM.WaveTemplates.GetAll()
    return {
        {
            id = "basic_light",
            name = "Light Infantry Wave",
            description = "Small wave of basic infantry units",
            difficulty = "Easy",
            icon = "icon16/user.png",
            config = {
                waves = {
                    {
                        npcs = {
                            {
                                class = "npc_vj_test_human",
                                count = 3,
                                customization = {
                                    health = 50,
                                    vjbase = {
                                        faction = "VJ_FACTION_ANTLION",
                                        canWander = true
                                    }
                                }
                            }
                        },
                        spawnPointGroup = "default",
                        interval = 30
                    }
                },
                defaultInterval = 30,
                cleanupOnComplete = false
            }
        },
        
        {
            id = "basic_medium",
            name = "Standard Infantry Wave",
            description = "Medium-sized wave of standard troops",
            difficulty = "Medium",
            icon = "icon16/group.png",
            config = {
                waves = {
                    {
                        npcs = {
                            {
                                class = "npc_vj_test_human",
                                count = 8,
                                customization = {
                                    health = 100,
                                    vjbase = {
                                        faction = "VJ_FACTION_ANTLION",
                                        canWander = true,
                                        callForHelp = true
                                    }
                                }
                            }
                        },
                        spawnPointGroup = "default",
                        interval = 30
                    }
                },
                defaultInterval = 30,
                cleanupOnComplete = false
            }
        },
        
        {
            id = "progressive_3wave",
            name = "Progressive 3-Wave Assault",
            description = "Three waves with increasing difficulty",
            difficulty = "Medium",
            icon = "icon16/chart_line.png",
            config = {
                waves = {
                    {
                        npcs = {
                            {
                                class = "npc_vj_test_human",
                                count = 4,
                                customization = { health = 75 }
                            }
                        },
                        spawnPointGroup = "default",
                        interval = 40
                    },
                    {
                        npcs = {
                            {
                                class = "npc_vj_test_human",
                                count = 6,
                                customization = { health = 100 }
                            }
                        },
                        spawnPointGroup = "default",
                        interval = 40
                    },
                    {
                        npcs = {
                            {
                                class = "npc_vj_test_human",
                                count = 8,
                                customization = { health = 125 }
                            }
                        },
                        spawnPointGroup = "default",
                        interval = 0
                    }
                },
                defaultInterval = 40,
                cleanupOnComplete = false
            }
        },
        
        {
            id = "mixed_squad",
            name = "Mixed Role Squad",
            description = "Squad with medics, heavies, and assault troops",
            difficulty = "Hard",
            icon = "icon16/group_gear.png",
            config = {
                waves = {
                    {
                        npcs = {
                            {
                                class = "npc_vj_test_human",
                                count = 5,
                                role = "assault",
                                customization = { health = 100 }
                            },
                            {
                                class = "npc_vj_test_human",
                                count = 2,
                                role = "medic",
                                customization = { health = 80 }
                            },
                            {
                                class = "npc_vj_test_human",
                                count = 2,
                                role = "heavy",
                                customization = { health = 150 }
                            }
                        },
                        spawnPointGroup = "default",
                        interval = 30
                    }
                },
                defaultInterval = 30,
                cleanupOnComplete = false
            }
        },
        
        {
            id = "defensive_holdout",
            name = "Defensive Holdout",
            description = "Multiple small waves with short intervals",
            difficulty = "Hard",
            icon = "icon16/shield.png",
            config = {
                waves = {
                    {
                        npcs = {
                            { class = "npc_vj_test_human", count = 3, customization = { health = 80 } }
                        },
                        spawnPointGroup = "default",
                        interval = 20
                    },
                    {
                        npcs = {
                            { class = "npc_vj_test_human", count = 4, customization = { health = 80 } }
                        },
                        spawnPointGroup = "default",
                        interval = 20
                    },
                    {
                        npcs = {
                            { class = "npc_vj_test_human", count = 5, customization = { health = 80 } }
                        },
                        spawnPointGroup = "default",
                        interval = 20
                    },
                    {
                        npcs = {
                            { class = "npc_vj_test_human", count = 6, customization = { health = 100 } }
                        },
                        spawnPointGroup = "default",
                        interval = 0
                    }
                },
                defaultInterval = 20,
                cleanupOnComplete = false
            }
        },
        
        {
            id = "elite_squad",
            name = "Elite Squad",
            description = "Small number of high-health elite units",
            difficulty = "Very Hard",
            icon = "icon16/star.png",
            config = {
                waves = {
                    {
                        npcs = {
                            {
                                class = "npc_vj_test_human",
                                count = 4,
                                customization = {
                                    health = 300,
                                    vjbase = {
                                        faction = "VJ_FACTION_ANTLION",
                                        canWander = false,
                                        callForHelp = true,
                                        sightDistance = 15000
                                    }
                                }
                            }
                        },
                        spawnPointGroup = "default",
                        interval = 30
                    }
                },
                defaultInterval = 30,
                cleanupOnComplete = false
            }
        },
        
        {
            id = "vehicle_assault",
            name = "Vehicle Assault",
            description = "Vehicle with crew escort",
            difficulty = "Hard",
            icon = "icon16/car.png",
            config = {
                waves = {
                    {
                        npcs = {
                            {
                                class = "npc_vj_test_human",
                                count = 4,
                                customization = { health = 100 }
                            }
                        },
                        vehicles = {
                            {
                                class = "prop_vehicle_jeep",
                                count = 1,
                                crew = {
                                    driver = { class = "npc_vj_test_human" },
                                    passengers = {
                                        { class = "npc_vj_test_human" }
                                    }
                                },
                                customization = {
                                    health = 500
                                }
                            }
                        },
                        spawnPointGroup = "default",
                        interval = 30
                    }
                },
                defaultInterval = 30,
                cleanupOnComplete = false
            }
        },
        
        {
            id = "boss_fight",
            name = "Boss Fight",
            description = "Single high-value target with support",
            difficulty = "Boss",
            icon = "icon16/medal_gold_1.png",
            config = {
                waves = {
                    {
                        npcs = {
                            {
                                class = "npc_vj_test_human",
                                count = 1,
                                customization = {
                                    health = 1000,
                                    vjbase = {
                                        faction = "VJ_FACTION_ANTLION",
                                        canWander = false,
                                        callForHelp = true,
                                        sightDistance = 20000
                                    }
                                }
                            },
                            {
                                class = "npc_vj_test_human",
                                count = 4,
                                customization = { health = 150 }
                            }
                        },
                        spawnPointGroup = "default",
                        interval = 30
                    }
                },
                defaultInterval = 30,
                cleanupOnComplete = false
            }
        },
        
        {
            id = "endless_horde",
            name = "Endless Horde",
            description = "Continuous waves until manually stopped",
            difficulty = "Endless",
            icon = "icon16/arrow_refresh.png",
            config = {
                waves = {
                    {
                        npcs = {
                            { class = "npc_vj_test_human", count = 5, customization = { health = 75 } }
                        },
                        spawnPointGroup = "default",
                        interval = 25
                    },
                    {
                        npcs = {
                            { class = "npc_vj_test_human", count = 6, customization = { health = 75 } }
                        },
                        spawnPointGroup = "default",
                        interval = 25
                    },
                    {
                        npcs = {
                            { class = "npc_vj_test_human", count = 7, customization = { health = 75 } }
                        },
                        spawnPointGroup = "default",
                        interval = 25
                    },
                    {
                        npcs = {
                            { class = "npc_vj_test_human", count = 8, customization = { health = 75 } }
                        },
                        spawnPointGroup = "default",
                        interval = 25
                    }
                },
                defaultInterval = 25,
                cleanupOnComplete = false
            }
        },
        
        {
            id = "sniper_team",
            name = "Sniper Team",
            description = "Long-range sniper units with spotter support",
            difficulty = "Medium",
            icon = "icon16/zoom.png",
            config = {
                waves = {
                    {
                        npcs = {
                            {
                                class = "npc_vj_test_human",
                                count = 3,
                                role = "sniper",
                                customization = { health = 80 }
                            },
                            {
                                class = "npc_vj_test_human",
                                count = 2,
                                role = "scout",
                                customization = { health = 75 }
                            }
                        },
                        spawnPointGroup = "default",
                        interval = 30
                    }
                },
                defaultInterval = 30,
                cleanupOnComplete = false
            }
        }
    }
end

--[[
    Get a specific template by ID
    @param templateID: The template identifier
    @return Template config or nil
]]--
function VJGM.WaveTemplates.GetByID(templateID)
    local templates = VJGM.WaveTemplates.GetAll()
    
    for _, template in ipairs(templates) do
        if template.id == templateID then
            return template
        end
    end
    
    return nil
end

--[[
    Get templates filtered by difficulty
    @param difficulty: Difficulty level string
    @return Table of matching templates
]]--
function VJGM.WaveTemplates.GetByDifficulty(difficulty)
    local templates = VJGM.WaveTemplates.GetAll()
    local filtered = {}
    
    for _, template in ipairs(templates) do
        if template.difficulty == difficulty then
            table.insert(filtered, template)
        end
    end
    
    return filtered
end

--[[
    Spawn a wave from a template
    @param templateID: The template identifier
    @param spawnGroup: Optional spawn point group override
    @return Wave ID or nil
]]--
function VJGM.WaveTemplates.SpawnFromTemplate(templateID, spawnGroup)
    if SERVER then
        local template = VJGM.WaveTemplates.GetByID(templateID)
        
        if not template then
            ErrorNoHalt("[VJGM] Wave template not found: " .. tostring(templateID) .. "\n")
            return nil
        end
        
        -- Clone the config so we don't modify the template
        local waveConfig = table.Copy(template.config)
        
        -- Override spawn group if provided
        if spawnGroup then
            for _, wave in ipairs(waveConfig.waves) do
                wave.spawnPointGroup = spawnGroup
            end
        end
        
        -- Start the wave
        if VJGM.NPCSpawner then
            return VJGM.NPCSpawner.StartWave(waveConfig)
        end
        
        return nil
    end
end

return VJGM.WaveTemplates
