--[[
    Wave Configuration System
    Defines and validates wave configurations for the Dynamic NPC Spawner
    
    Compatible with VJ Base NPC system
    
    Wave Structure:
    {
        waves = {
            {
                npcs = { ... },
                spawnPointGroup = "group_name",
                interval = 30  -- seconds until next wave
            }
        },
        defaultInterval = 30,
        cleanupOnComplete = false
    }
    
    NPC Group Structure (VJ Base Compatible):
    {
        class = "npc_vj_example",
        count = 5,
        customization = {
            health = 100,
            weapons = {"weapon_vj_example"},
            model = "models/example.mdl",
            vjbase = {
                faction = "VJ_FACTION_PLAYER",
                callForHelp = true,
                canWander = false,
                sightDistance = 10000,
                squad = "wave_1"
            }
        }
    }
]]--

if SERVER then
    
    -- Load configuration
    include("npc/config/init.lua")
    
    VJGM = VJGM or {}
    VJGM.WaveConfig = VJGM.WaveConfig or {}
    
    --[[
        Validate a wave configuration
        @param config: Wave configuration table
        @return boolean: true if valid, false otherwise
    ]]--
    function VJGM.WaveConfig.Validate(config)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        
        if not config then
            ErrorNoHalt(prefix .. " WaveConfig: Config is nil\n")
            return false
        end
        
        if not config.waves or type(config.waves) ~= "table" or #config.waves == 0 then
            ErrorNoHalt(prefix .. " WaveConfig: No waves defined or waves is not a table\n")
            return false
        end
        
        for i, wave in ipairs(config.waves) do
            if not wave.npcs or type(wave.npcs) ~= "table" or #wave.npcs == 0 then
                ErrorNoHalt(prefix .. " WaveConfig: Wave " .. i .. " has no NPCs defined\n")
                return false
            end
            
            for j, npcGroup in ipairs(wave.npcs) do
                if not npcGroup.class then
                    ErrorNoHalt(prefix .. " WaveConfig: Wave " .. i .. " NPC group " .. j .. " missing class\n")
                    return false
                end
            end
        end
        
        return true
    end
    
    --[[
        Create a basic wave configuration (VJ Base compatible)
        Uses preset from config
        @return Example wave configuration
    ]]--
    function VJGM.WaveConfig.CreateExample()
        return VJGM.Config.GetPreset("Basic") or {
            waves = {{npcs = {{class = "npc_vj_test_human", count = 1}}, spawnPointGroup = "default", interval = 30}},
            defaultInterval = 30,
            cleanupOnComplete = false
        }
    end
    
    --[[
        Create a Clone Wars specific wave configuration example (VJ Base)
        Uses preset from config
        Note: Replace with actual Clone Wars VJ Base NPC classes when available
        @return Clone Wars themed wave configuration
    ]]--
    function VJGM.WaveConfig.CreateCloneWarsExample()
        return VJGM.Config.GetPreset("CloneWarsRepublic") or VJGM.WaveConfig.CreateExample()
    end
    
    --[[
        Create a wave configuration builder
        @return Builder object
    ]]--
    function VJGM.WaveConfig.CreateBuilder()
        local defaultInterval = VJGM.Config.Get("Spawner", "DefaultWaveInterval", 30)
        local defaultCleanup = VJGM.Config.Get("Spawner", "DefaultCleanupOnComplete", false)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        
        local builder = {
            config = {
                waves = {},
                defaultInterval = defaultInterval,
                cleanupOnComplete = defaultCleanup
            }
        }
        
        function builder:SetDefaultInterval(interval)
            self.config.defaultInterval = interval
            return self
        end
        
        function builder:SetCleanupOnComplete(cleanup)
            self.config.cleanupOnComplete = cleanup
            return self
        end
        
        function builder:AddWave(spawnPointGroup, interval)
            local defaultGroup = VJGM.Config.Get("SpawnPoints", "DefaultGroupName", "default")
            table.insert(self.config.waves, {
                npcs = {},
                spawnPointGroup = spawnPointGroup or defaultGroup,
                interval = interval or self.config.defaultInterval
            })
            return self
        end
        
        function builder:AddNPCGroup(class, count, customization)
            local currentWave = self.config.waves[#self.config.waves]
            if not currentWave then
                ErrorNoHalt(prefix .. " WaveConfig Builder: No wave to add NPC group to. Call AddWave() first.\n")
                return self
            end
            
            table.insert(currentWave.npcs, {
                class = class,
                count = count or 1,
                customization = customization or {}
            })
            return self
        end
        
        function builder:Build()
            if VJGM.WaveConfig.Validate(self.config) then
                return self.config
            else
                ErrorNoHalt(prefix .. " WaveConfig Builder: Built configuration is invalid\n")
                return nil
            end
        end
        
        return builder
    end
    
end
