--[[
    Configuration Loader
    
    Loads all configuration files for the Dynamic NPC Spawner system
    This should be loaded first before other modules
]]--

VJGM = VJGM or {}
VJGM.Config = VJGM.Config or {}

-- Load configuration files
local configPath = "npc/config/"

-- Load spawner configuration
if SERVER then
    include(configPath .. "spawner_config.lua")
    include(configPath .. "wave_presets.lua")
    
    print("[VJGM] Configuration loaded successfully")
else
    -- Client-side config loading if needed in the future
end

-- Helper function to get config value with fallback
function VJGM.Config.Get(category, key, default)
    if VJGM.Config[category] and VJGM.Config[category][key] ~= nil then
        return VJGM.Config[category][key]
    end
    return default
end

-- Helper function to set config value at runtime
function VJGM.Config.Set(category, key, value)
    if not VJGM.Config[category] then
        VJGM.Config[category] = {}
    end
    VJGM.Config[category][key] = value
end

-- Helper function to get wave preset
function VJGM.Config.GetPreset(presetName)
    if VJGM.Config.WavePresets and VJGM.Config.WavePresets[presetName] then
        return table.Copy(VJGM.Config.WavePresets[presetName])
    end
    return nil
end

-- Helper function to list available presets
function VJGM.Config.ListPresets()
    local presets = {}
    if VJGM.Config.WavePresets then
        for name, _ in pairs(VJGM.Config.WavePresets) do
            table.insert(presets, name)
        end
    end
    return presets
end

return VJGM.Config
