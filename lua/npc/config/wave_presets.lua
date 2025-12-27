--[[
    Wave Presets Configuration
    
    Pre-configured wave templates for common scenarios
    Gamemasters can add custom presets here
]]--

VJGM = VJGM or {}
VJGM.Config = VJGM.Config or {}
VJGM.Config.WavePresets = {}

-- Basic test wave preset
VJGM.Config.WavePresets.Basic = {
    waves = {
        {
            npcs = {
                {
                    class = "npc_vj_test_human",
                    count = 3,
                    customization = {
                        health = 100,
                        weapons = {"weapon_vj_smg1"},
                        vjbase = {
                            faction = "VJ_FACTION_ANTLION",
                            callForHelp = true,
                            canWander = true,
                            squad = "wave_1_group_1"
                        }
                    }
                }
            },
            spawnPointGroup = "default",
            interval = 15
        },
        {
            npcs = {
                {
                    class = "npc_vj_test_human",
                    count = 5,
                    customization = {
                        health = 150,
                        weapons = {"weapon_vj_ar2"},
                        vjbase = {
                            faction = "VJ_FACTION_ANTLION",
                            callForHelp = true,
                            sightDistance = 5000,
                            squad = "wave_2_group_1"
                        }
                    }
                }
            },
            spawnPointGroup = "default",
            interval = 20
        }
    },
    defaultInterval = 30,
    cleanupOnComplete = false
}

-- Clone Wars Republic preset
VJGM.Config.WavePresets.CloneWarsRepublic = {
    waves = {
        -- Wave 1: Light scout wave
        {
            npcs = {
                {
                    -- Replace with actual VJ Base Clone Trooper class
                    -- Example: "npc_vj_swrp_clone_trooper"
                    class = "npc_vj_test_human",
                    count = 4,
                    customization = {
                        health = 100,
                        weapons = {"weapon_vj_smg1"},  -- Replace with DC-15S
                        model = "models/player/clone_trooper.mdl",  -- Use actual model path
                        vjbase = {
                            faction = "VJ_FACTION_PLAYER",  -- Republic faction
                            callForHelp = true,
                            canWander = false,
                            sightDistance = 8000,
                            hearingCoef = 1.0,
                            squad = "clone_scout_wave_1"
                        }
                    }
                }
            },
            spawnPointGroup = "frontline",
            interval = 20
        },
        -- Wave 2: Medium assault wave with heavies
        {
            npcs = {
                {
                    class = "npc_vj_test_human",  -- Regular clone troopers
                    count = 6,
                    customization = {
                        health = 120,
                        weapons = {"weapon_vj_ar2"},  -- Replace with DC-15A
                        model = "models/player/clone_trooper.mdl",
                        vjbase = {
                            faction = "VJ_FACTION_PLAYER",
                            callForHelp = true,
                            canWander = false,
                            sightDistance = 10000,
                            squad = "clone_assault_wave_2"
                        }
                    }
                },
                {
                    class = "npc_vj_test_human",  -- Heavy troopers
                    count = 2,
                    customization = {
                        health = 200,
                        weapons = {"weapon_vj_rpg"},  -- Replace with Z-6 rotary
                        model = "models/player/clone_trooper_heavy.mdl",
                        vjbase = {
                            faction = "VJ_FACTION_PLAYER",
                            callForHelp = true,
                            canWander = false,
                            meleeDistance = 0,  -- Keep distance
                            sightDistance = 12000,
                            squad = "clone_assault_wave_2"
                        }
                    }
                }
            },
            spawnPointGroup = "frontline",
            interval = 30
        },
        -- Wave 3: Elite wave with ARC troopers
        {
            npcs = {
                {
                    class = "npc_vj_test_human",  -- Standard clones
                    count = 8,
                    customization = {
                        health = 150,
                        weapons = {"weapon_vj_ar2"},
                        model = "models/player/clone_trooper.mdl",
                        vjbase = {
                            faction = "VJ_FACTION_PLAYER",
                            callForHelp = true,
                            canWander = false,
                            sightDistance = 10000,
                            squad = "clone_elite_wave_3"
                        }
                    }
                },
                {
                    class = "npc_vj_test_human",  -- ARC Troopers
                    count = 2,
                    customization = {
                        health = 250,
                        weapons = {"weapon_vj_pistol", "weapon_vj_smg1"},
                        model = "models/player/arc_trooper.mdl",
                        vjbase = {
                            faction = "VJ_FACTION_PLAYER",
                            callForHelp = true,
                            canWander = false,
                            sightDistance = 15000,
                            hearingCoef = 1.5,
                            squad = "clone_elite_wave_3_arc"
                        }
                    }
                }
            },
            spawnPointGroup = "frontline",
            interval = 0  -- Last wave
        }
    },
    defaultInterval = 25,
    cleanupOnComplete = false
}

-- Clone Wars Separatist preset
VJGM.Config.WavePresets.CloneWarsSeparatist = {
    waves = {
        -- Wave 1: Battle droid scouts
        {
            npcs = {
                {
                    class = "npc_vj_test_human",  -- Replace with Battle Droid class
                    count = 8,
                    customization = {
                        health = 60,
                        weapons = {"weapon_vj_smg1"},
                        model = "models/battle_droid.mdl",
                        vjbase = {
                            faction = "VJ_FACTION_ANTLION",  -- Separatist faction
                            callForHelp = true,
                            canWander = false,
                            sightDistance = 7000,
                            squad = "droid_wave_1"
                        }
                    }
                }
            },
            spawnPointGroup = "separatist",
            interval = 15
        },
        -- Wave 2: Mixed droid force
        {
            npcs = {
                {
                    class = "npc_vj_test_human",  -- Battle droids
                    count = 10,
                    customization = {
                        health = 60,
                        weapons = {"weapon_vj_smg1"},
                        model = "models/battle_droid.mdl",
                        vjbase = {
                            faction = "VJ_FACTION_ANTLION",
                            callForHelp = true,
                            canWander = false,
                            sightDistance = 7000,
                            squad = "droid_wave_2"
                        }
                    }
                },
                {
                    class = "npc_vj_test_human",  -- Super battle droids
                    count = 3,
                    customization = {
                        health = 180,
                        weapons = {"weapon_vj_ar2"},
                        model = "models/super_battle_droid.mdl",
                        vjbase = {
                            faction = "VJ_FACTION_ANTLION",
                            callForHelp = true,
                            canWander = false,
                            sightDistance = 9000,
                            squad = "droid_wave_2"
                        }
                    }
                }
            },
            spawnPointGroup = "separatist",
            interval = 25
        }
    },
    defaultInterval = 20,
    cleanupOnComplete = false
}

-- Horde mode preset (increasing difficulty)
VJGM.Config.WavePresets.HordeMode = {
    waves = {
        {
            npcs = {
                {
                    class = "npc_vj_test_human",
                    count = 5,
                    customization = {
                        health = 80,
                        weapons = {"weapon_vj_smg1"}
                    }
                }
            },
            spawnPointGroup = "default",
            interval = 20
        },
        {
            npcs = {
                {
                    class = "npc_vj_test_human",
                    count = 8,
                    customization = {
                        health = 100,
                        weapons = {"weapon_vj_smg1"}
                    }
                }
            },
            spawnPointGroup = "default",
            interval = 20
        },
        {
            npcs = {
                {
                    class = "npc_vj_test_human",
                    count = 12,
                    customization = {
                        health = 120,
                        weapons = {"weapon_vj_ar2"}
                    }
                }
            },
            spawnPointGroup = "default",
            interval = 20
        },
        {
            npcs = {
                {
                    class = "npc_vj_test_human",
                    count = 15,
                    customization = {
                        health = 150,
                        weapons = {"weapon_vj_ar2"}
                    }
                }
            },
            spawnPointGroup = "default",
            interval = 0
        }
    },
    defaultInterval = 20,
    cleanupOnComplete = true
}

return VJGM.Config.WavePresets
