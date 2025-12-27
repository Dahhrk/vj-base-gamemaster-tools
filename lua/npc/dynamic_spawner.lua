--[[
    Dynamic NPC Spawner - Clone Wars Roleplay
    Main spawner module for managing dynamic wave-based NPC spawning
    
    Compatible with VJ Base NPC system
    Requires: VJ Base addon (https://steamcommunity.com/sharedfiles/filedetails/?id=131759821)
    
    Features:
    - Wave-based spawning system
    - Configurable spawn intervals
    - Event-driven wave triggers
    - Integration with customization and spawn point systems
    - VJ Base NPC support with advanced AI options
]]--

if SERVER then
    
    -- Load configuration
    include("npc/config/init.lua")
    
    -- Module namespace
    VJGM = VJGM or {}
    VJGM.NPCSpawner = VJGM.NPCSpawner or {}
    
    -- Active wave tracking
    local activeWaves = {}
    local waveTimers = {}
    local globalSpawnID = 0
    
    --[[
        Initialize the NPC spawner system
    ]]--
    function VJGM.NPCSpawner.Initialize()
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local showVJWarning = VJGM.Config.Get("Spawner", "ShowVJBaseWarning", true)
        
        print(prefix .. " Dynamic NPC Spawner initialized")
        
        -- Check for VJ Base
        if not VJ and showVJWarning then
            print(prefix .. " WARNING: VJ Base not detected! Some features may not work correctly.")
            print(prefix .. " Install VJ Base from: https://steamcommunity.com/sharedfiles/filedetails/?id=131759821")
        elseif VJ then
            print(prefix .. " VJ Base detected - Enhanced NPC features enabled")
        end
        
        activeWaves = {}
        waveTimers = {}
    end
    
    --[[
        Start a wave configuration
        @param waveConfig: Table containing wave configuration (see wave_config.lua)
        @param eventTrigger: Optional event trigger data for staged events
        @return waveID: Unique identifier for this wave instance
    ]]--
    function VJGM.NPCSpawner.StartWave(waveConfig, eventTrigger)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local maxWaves = VJGM.Config.Get("Spawner", "MaxActiveWaves", 10)
        
        if not waveConfig then
            ErrorNoHalt(prefix .. " StartWave: No wave configuration provided\n")
            return nil
        end
        
        -- Check max active waves limit
        if table.Count(activeWaves) >= maxWaves then
            ErrorNoHalt(prefix .. " StartWave: Maximum active waves limit reached (" .. maxWaves .. ")\n")
            return nil
        end
        
        -- Validate wave configuration
        if not VJGM.WaveConfig or not VJGM.WaveConfig.Validate(waveConfig) then
            ErrorNoHalt(prefix .. " StartWave: Invalid wave configuration\n")
            return nil
        end
        
        globalSpawnID = globalSpawnID + 1
        local waveID = "wave_" .. globalSpawnID
        
        -- Store wave state
        activeWaves[waveID] = {
            config = waveConfig,
            currentWaveIndex = 1,
            spawnedNPCs = {},
            isActive = true,
            eventTrigger = eventTrigger or {}
        }
        
        print(prefix .. " Starting wave: " .. waveID)
        
        -- Start the first wave
        VJGM.NPCSpawner.SpawnNextWave(waveID)
        
        return waveID
    end
    
    --[[
        Spawn the next wave in sequence
        @param waveID: The wave instance identifier
    ]]--
    function VJGM.NPCSpawner.SpawnNextWave(waveID)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local defaultInterval = VJGM.Config.Get("Spawner", "DefaultWaveInterval", 30)
        local timerPrefix = VJGM.Config.Get("Spawner", "TimerPrefix", "VJGM_Wave_")
        
        local waveData = activeWaves[waveID]
        if not waveData or not waveData.isActive then return end
        
        local waveIndex = waveData.currentWaveIndex
        local waves = waveData.config.waves
        
        if waveIndex > #waves then
            print(prefix .. " Wave " .. waveID .. " completed all waves")
            VJGM.NPCSpawner.StopWave(waveID)
            return
        end
        
        local currentWave = waves[waveIndex]
        print(prefix .. " Spawning wave " .. waveIndex .. " of " .. #waves .. " for " .. waveID)
        
        -- Spawn NPCs for this wave
        VJGM.NPCSpawner.SpawnWaveNPCs(waveID, currentWave)
        
        -- Schedule next wave if there are more
        if waveIndex < #waves then
            local interval = currentWave.interval or waveData.config.defaultInterval or defaultInterval
            
            waveTimers[waveID] = timer.Create(timerPrefix .. waveID .. "_" .. waveIndex, interval, 1, function()
                if activeWaves[waveID] then
                    activeWaves[waveID].currentWaveIndex = activeWaves[waveID].currentWaveIndex + 1
                    VJGM.NPCSpawner.SpawnNextWave(waveID)
                end
            end)
        else
            -- This was the last wave
            VJGM.NPCSpawner.StopWave(waveID)
        end
    end
    
    --[[
        Spawn NPCs for a specific wave
        @param waveID: The wave instance identifier
        @param waveData: The wave configuration data
    ]]--
    function VJGM.NPCSpawner.SpawnWaveNPCs(waveID, waveData)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local spawnOffset = VJGM.Config.Get("Spawner", "SpawnHeightOffset", 10)
        local defaultNPCClass = VJGM.Config.Get("Spawner", "DefaultNPCClass", "npc_vj_test_human")
        local cleanupPrefix = VJGM.Config.Get("Spawner", "CleanupPrefix", "VJGM_Cleanup_")
        
        local activeWave = activeWaves[waveID]
        if not activeWave then return end
        
        -- Get spawn points
        local spawnPoints = VJGM.SpawnPoints and VJGM.SpawnPoints.GetPoints(waveData.spawnPointGroup) or {}
        
        if #spawnPoints == 0 then
            ErrorNoHalt(prefix .. " No spawn points available for wave\n")
            return
        end
        
        -- Spawn each NPC group
        for _, npcGroup in ipairs(waveData.npcs or {}) do
            local npcClass = npcGroup.class or defaultNPCClass
            local count = npcGroup.count or 1
            local customization = npcGroup.customization or {}
            
            for i = 1, count do
                -- Select spawn point
                local spawnPoint = spawnPoints[math.random(1, #spawnPoints)]
                
                -- Create NPC
                local npc = ents.Create(npcClass)
                if IsValid(npc) then
                    npc:SetPos(spawnPoint.pos + Vector(0, 0, spawnOffset))
                    
                    if spawnPoint.angle then
                        npc:SetAngles(spawnPoint.angle)
                    end
                    
                    -- Pre-spawn customization for VJ Base NPCs
                    if npc.IsVJBaseSNPC then
                        -- Apply VJ Base specific settings before spawn
                        if customization.vjbase then
                            VJGM.NPCSpawner.ApplyVJBaseSettings(npc, customization.vjbase)
                        end
                    end
                    
                    npc:Spawn()
                    npc:Activate()
                    
                    -- Post-spawn customization
                    if VJGM.NPCCustomizer then
                        VJGM.NPCCustomizer.Apply(npc, customization)
                    end
                    
                    -- Track spawned NPC
                    table.insert(activeWave.spawnedNPCs, npc)
                    
                    -- Cleanup on death/remove
                    npc:CallOnRemove(cleanupPrefix .. waveID, function()
                        table.RemoveByValue(activeWave.spawnedNPCs, npc)
                    end)
                end
            end
        end
        
        print(prefix .. " Spawned " .. #(waveData.npcs or {}) .. " NPC groups for " .. waveID)
    end
    
    --[[
        Apply VJ Base specific settings to an NPC
        @param npc: The NPC entity
        @param vjSettings: VJ Base settings table
    ]]--
    function VJGM.NPCSpawner.ApplyVJBaseSettings(npc, vjSettings)
        if not IsValid(npc) or not npc.IsVJBaseSNPC then return end
        
        local defaultFaction = VJGM.Config.Get("VJBase", "DefaultFaction", "VJ_FACTION_ANTLION")
        local defaultCallForHelp = VJGM.Config.Get("VJBase", "DefaultCallForHelp", true)
        local defaultCanWander = VJGM.Config.Get("VJBase", "DefaultCanWander", true)
        local defaultSightDistance = VJGM.Config.Get("VJBase", "DefaultSightDistance", 10000)
        local defaultHearingCoef = VJGM.Config.Get("VJBase", "DefaultHearingCoef", 1.0)
        local defaultMeleeDistance = VJGM.Config.Get("VJBase", "DefaultMeleeDistance", 0)
        
        -- Faction settings
        if vjSettings.faction then
            npc.VJ_NPC_Class = {vjSettings.faction}
        elseif defaultFaction then
            npc.VJ_NPC_Class = {defaultFaction}
        end
        
        -- AI behavior
        if vjSettings.callForHelp ~= nil then
            npc.CallForHelp = vjSettings.callForHelp
        else
            npc.CallForHelp = defaultCallForHelp
        end
        
        if vjSettings.followPlayer ~= nil then
            npc.FollowPlayer = vjSettings.followPlayer
        end
        
        if vjSettings.canWander ~= nil then
            npc.DisableWandering = not vjSettings.canWander
        else
            npc.DisableWandering = not defaultCanWander
        end
        
        -- Combat settings
        if vjSettings.meleeDistance then
            npc.MeleeAttackDistance = vjSettings.meleeDistance
        elseif defaultMeleeDistance > 0 then
            npc.MeleeAttackDistance = defaultMeleeDistance
        end
        
        if vjSettings.sightDistance then
            npc.SightDistance = vjSettings.sightDistance
        else
            npc.SightDistance = defaultSightDistance
        end
        
        if vjSettings.hearingCoef then
            npc.HearingCoefficient = vjSettings.hearingCoef
        else
            npc.HearingCoefficient = defaultHearingCoef
        end
        
        -- Squad name for coordination
        if vjSettings.squad then
            npc.VJ_NPC_SquadName = vjSettings.squad
        end
    end
    
    --[[
        Stop a wave and cleanup
        @param waveID: The wave instance identifier
    ]]--
    function VJGM.NPCSpawner.StopWave(waveID)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local timerPrefix = VJGM.Config.Get("Spawner", "TimerPrefix", "VJGM_Wave_")
        
        local waveData = activeWaves[waveID]
        if not waveData then return end
        
        print(prefix .. " Stopping wave: " .. waveID)
        
        waveData.isActive = false
        
        -- Remove any pending timers
        if timer.Exists(timerPrefix .. waveID) then
            timer.Remove(timerPrefix .. waveID)
        end
        
        -- Optionally cleanup spawned NPCs
        if waveData.config.cleanupOnComplete then
            for _, npc in ipairs(waveData.spawnedNPCs) do
                if IsValid(npc) then
                    npc:Remove()
                end
            end
        end
        
        activeWaves[waveID] = nil
    end
    
    --[[
        Get active waves
        @return Table of active wave IDs
    ]]--
    function VJGM.NPCSpawner.GetActiveWaves()
        local waves = {}
        for waveID, _ in pairs(activeWaves) do
            table.insert(waves, waveID)
        end
        return waves
    end
    
    --[[
        Get wave status
        @param waveID: The wave instance identifier
        @return Status table or nil
    ]]--
    function VJGM.NPCSpawner.GetWaveStatus(waveID)
        local waveData = activeWaves[waveID]
        if not waveData then return nil end
        
        return {
            waveID = waveID,
            currentWave = waveData.currentWaveIndex,
            totalWaves = #waveData.config.waves,
            isActive = waveData.isActive,
            aliveNPCs = #waveData.spawnedNPCs
        }
    end
    
    -- Initialize on load
    hook.Add("Initialize", "VJGM_NPCSpawner_Init", function()
        local autoInit = VJGM.Config.Get("Spawner", "AutoInitialize", true)
        if autoInit then
            VJGM.NPCSpawner.Initialize()
        end
    end)
    
end
