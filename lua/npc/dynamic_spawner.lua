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
    local activeWaveCount = 0  -- Performance: track count instead of using table.Count()
    
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
        
        -- Check max active waves limit using counter
        if activeWaveCount >= maxWaves then
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
        
        activeWaveCount = activeWaveCount + 1
        
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
        
        -- Apply wave scaling
        local scaledWave = VJGM.NPCSpawner.ApplyWaveScaling(currentWave)
        
        -- Spawn NPCs for this wave
        VJGM.NPCSpawner.SpawnWaveNPCs(waveID, scaledWave)
        
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
        
        -- Spawn NPCs if present
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
                    if npc.IsVJBaseSNPC == true then
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
                    
                    -- Apply role if specified (VJ Base compatible)
                    if npcGroup.role and VJGM.RoleBasedNPCs then
                        VJGM.RoleBasedNPCs.AssignRole(npc, npcGroup.role, npcGroup.roleConfig or {})
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
        
        -- Spawn vehicles if present and VehicleSupport is available
        if waveData.vehicles and VJGM.VehicleSupport then
            for _, vehicleGroup in ipairs(waveData.vehicles) do
                local vehicleClass = vehicleGroup.class
                local count = vehicleGroup.count or 1
                local crew = vehicleGroup.crew
                local customization = vehicleGroup.customization or {}
                
                for i = 1, count do
                    -- Select spawn point
                    local spawnPoint = spawnPoints[math.random(1, #spawnPoints)]
                    
                    -- Spawn vehicle with crew
                    local vehicle = VJGM.VehicleSupport.SpawnVehicleWithCrew(
                        vehicleClass,
                        spawnPoint.pos,
                        spawnPoint.angle,
                        crew
                    )
                    
                    if IsValid(vehicle) then
                        -- Apply vehicle customization
                        if customization.health then
                            vehicle:SetMaxHealth(customization.health)
                            vehicle:SetHealth(customization.health)
                        end
                        
                        if customization.color then
                            vehicle:SetColor(customization.color)
                        end
                        
                        if customization.skin then
                            vehicle:SetSkin(customization.skin)
                        end
                        
                        -- Track spawned vehicle
                        table.insert(activeWave.spawnedNPCs, vehicle)
                        
                        -- Cleanup on death/remove
                        vehicle:CallOnRemove(cleanupPrefix .. waveID .. "_vehicle", function()
                            table.RemoveByValue(activeWave.spawnedNPCs, vehicle)
                        end)
                    end
                end
            end
        end
        
        local npcCount = #(waveData.npcs or {})
        local vehicleCount = waveData.vehicles and #waveData.vehicles or 0
        print(prefix .. " Spawned " .. npcCount .. " NPC groups and " .. vehicleCount .. " vehicle groups for " .. waveID)
    end
    
    --[[
        Apply VJ Base specific settings to an NPC
        @param npc: The NPC entity
        @param vjSettings: VJ Base settings table
    ]]--
    function VJGM.NPCSpawner.ApplyVJBaseSettings(npc, vjSettings)
        if not IsValid(npc) or npc.IsVJBaseSNPC ~= true then return end
        
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
        activeWaveCount = activeWaveCount - 1
    end
    
    --[[
        Pause a wave
        @param waveID: The wave instance identifier
    ]]--
    function VJGM.NPCSpawner.PauseWave(waveID)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local timerPrefix = VJGM.Config.Get("Spawner", "TimerPrefix", "VJGM_Wave_")
        
        local waveData = activeWaves[waveID]
        if not waveData then
            ErrorNoHalt(prefix .. " PauseWave: Wave not found: " .. tostring(waveID) .. "\n")
            return false
        end
        
        if waveData.isPaused then
            print(prefix .. " Wave already paused: " .. waveID)
            return false
        end
        
        waveData.isPaused = true
        
        -- Pause timer if it exists
        local timerName = timerPrefix .. waveID .. "_" .. waveData.currentWaveIndex
        if timer.Exists(timerName) then
            timer.Pause(timerName)
        end
        
        print(prefix .. " Paused wave: " .. waveID)
        return true
    end
    
    --[[
        Resume a paused wave
        @param waveID: The wave instance identifier
    ]]--
    function VJGM.NPCSpawner.ResumeWave(waveID)
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local timerPrefix = VJGM.Config.Get("Spawner", "TimerPrefix", "VJGM_Wave_")
        
        local waveData = activeWaves[waveID]
        if not waveData then
            ErrorNoHalt(prefix .. " ResumeWave: Wave not found: " .. tostring(waveID) .. "\n")
            return false
        end
        
        if not waveData.isPaused then
            print(prefix .. " Wave is not paused: " .. waveID)
            return false
        end
        
        waveData.isPaused = false
        
        -- Unpause timer if it exists
        local timerName = timerPrefix .. waveID .. "_" .. waveData.currentWaveIndex
        if timer.Exists(timerName) then
            timer.UnPause(timerName)
        end
        
        print(prefix .. " Resumed wave: " .. waveID)
        return true
    end
    
    --[[
        Apply wave scaling based on difficulty settings
        @param waveData: Wave configuration data
        @return Scaled wave configuration
    ]]--
    function VJGM.NPCSpawner.ApplyWaveScaling(waveData)
        local scalingEnabled = VJGM.Config.Get("WaveScaling", "Enabled", true)
        if not scalingEnabled then return waveData end
        
        local scaleByPlayer = VJGM.Config.Get("WaveScaling", "ScaleByPlayerCount", true)
        local difficultyPerPlayer = VJGM.Config.Get("WaveScaling", "DifficultyPerPlayer", 0.15)
        local maxDifficulty = VJGM.Config.Get("WaveScaling", "MaxDifficultyMultiplier", 3.0)
        local minPlayers = VJGM.Config.Get("WaveScaling", "MinPlayersForScaling", 1)
        local randomFactor = VJGM.Config.Get("WaveScaling", "RandomizationFactor", 0.15)
        
        local scaledWave = table.Copy(waveData)
        local difficultyMultiplier = 1.0
        
        -- Scale by player count
        if scaleByPlayer then
            local playerCount = #player.GetAll()
            if playerCount >= minPlayers then
                difficultyMultiplier = 1.0 + ((playerCount - 1) * difficultyPerPlayer)
                difficultyMultiplier = math.min(difficultyMultiplier, maxDifficulty)
            end
        end
        
        -- Apply scaling to NPC groups
        for _, npcGroup in ipairs(scaledWave.npcs or {}) do
            -- Scale NPC count
            local baseCount = npcGroup.count or 1
            local scaledCount = math.floor(baseCount * difficultyMultiplier)
            
            -- Apply randomization
            if randomFactor > 0 then
                -- Generate random value between -randomFactor and +randomFactor
                local randomMod = (math.random() - 0.5) * 2 * randomFactor
                scaledCount = math.max(1, math.floor(scaledCount * (1 + randomMod)))
            end
            
            npcGroup.count = scaledCount
            
            -- Optionally scale health
            if npcGroup.customization and npcGroup.customization.health then
                local baseHealth = npcGroup.customization.health
                npcGroup.customization.health = math.floor(baseHealth * difficultyMultiplier)
            end
        end
        
        return scaledWave
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
