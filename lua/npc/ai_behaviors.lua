--[[
    AI Behaviors Module
    Advanced AI enhancements for spawned NPCs
    
    Features:
    - Context-aware cover-seeking
    - Target prioritization system
    - Dynamic combat states (aggressive, defensive, retreat, suppressed)
    - Group communication and coordination
    - Expanded weapon logic and ammo management
    
    Compatible with VJ Base NPC system
    Designed to override existing templates minimally
]]--

if SERVER then
    
    -- Load configurations
    include("npc/config/init.lua")
    include("npc/config/ai_config.lua")
    
    VJGM = VJGM or {}
    VJGM.AIBehaviors = VJGM.AIBehaviors or {}
    
    -- AI state tracking
    local aiNPCs = {}
    local updateTimers = {}
    
    --[[
        Initialize the AI Behaviors system
    ]]--
    function VJGM.AIBehaviors.Initialize()
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local enabled = VJGM.Config.Get("AIBehaviors", "Enabled", true)
        
        aiNPCs = {}
        updateTimers = {}
        
        if enabled then
            print(prefix .. " AI Behaviors system initialized")
        else
            print(prefix .. " AI Behaviors system disabled in config")
        end
    end
    
    --[[
        Enable AI behaviors for an NPC
        @param npc: The NPC entity
        @param options: Optional configuration overrides
    ]]--
    function VJGM.AIBehaviors.EnableForNPC(npc, options)
        if not IsValid(npc) then return false end
        if not VJGM.Config.Get("AIBehaviors", "Enabled", true) then return false end
        
        options = options or {}
        
        -- Initialize AI state for this NPC
        local aiState = {
            npc = npc,
            combatState = "normal",
            lastStateChange = 0,
            currentCover = nil,
            lastCoverCheck = 0,
            lastTargetUpdate = 0,
            currentTarget = nil,
            lastDamageTime = 0,
            recentDamage = 0,
            suppressedUntil = 0,
            isReloading = false,
            lastCommunication = 0,
            ammoPercent = 1.0,
            
            -- Options
            enableCoverSeeking = options.coverSeeking ~= false and VJGM.Config.Get("CoverSeeking", "Enabled", true),
            enableTargetPriority = options.targetPriority ~= false and VJGM.Config.Get("TargetPrioritization", "Enabled", true),
            enableCombatStates = options.combatStates ~= false and VJGM.Config.Get("CombatStates", "Enabled", true),
            enableGroupComm = options.groupComm ~= false and VJGM.Config.Get("GroupCommunication", "Enabled", true),
            enableWeaponLogic = options.weaponLogic ~= false and VJGM.Config.Get("WeaponLogic", "Enabled", true),
        }
        
        -- Store AI state
        aiNPCs[npc:EntIndex()] = aiState
        
        -- Start AI update timer
        local updateInterval = VJGM.Config.Get("AIBehaviors", "UpdateInterval", 0.5)
        local timerName = "VJGM_AI_" .. npc:EntIndex()
        
        timer.Create(timerName, updateInterval, 0, function()
            if IsValid(npc) and npc:Health() > 0 then
                VJGM.AIBehaviors.UpdateNPC(npc)
            else
                timer.Remove(timerName)
                aiNPCs[npc:EntIndex()] = nil
            end
        end)
        
        -- Damage tracking hook
        npc.VJGM_OnTakeDamage = function(self, dmginfo)
            VJGM.AIBehaviors.OnNPCDamaged(self, dmginfo)
        end
        
        -- Cleanup on remove
        npc:CallOnRemove("VJGM_AI_Cleanup_" .. npc:EntIndex(), function()
            timer.Remove(timerName)
            aiNPCs[npc:EntIndex()] = nil
        end)
        
        return true
    end
    
    --[[
        Update AI for a specific NPC
        @param npc: The NPC entity
    ]]--
    function VJGM.AIBehaviors.UpdateNPC(npc)
        if not IsValid(npc) then return end
        
        local aiState = aiNPCs[npc:EntIndex()]
        if not aiState then return end
        
        -- Update combat state
        if aiState.enableCombatStates then
            VJGM.AIBehaviors.UpdateCombatState(npc, aiState)
        end
        
        -- Update target prioritization
        if aiState.enableTargetPriority then
            VJGM.AIBehaviors.UpdateTargetPriority(npc, aiState)
        end
        
        -- Update cover seeking
        if aiState.enableCoverSeeking then
            VJGM.AIBehaviors.UpdateCoverSeeking(npc, aiState)
        end
        
        -- Update group communication
        if aiState.enableGroupComm then
            VJGM.AIBehaviors.UpdateGroupCommunication(npc, aiState)
        end
        
        -- Update weapon logic
        if aiState.enableWeaponLogic then
            VJGM.AIBehaviors.UpdateWeaponLogic(npc, aiState)
        end
    end
    
    --[[
        Update combat state based on conditions
        @param npc: The NPC entity
        @param aiState: AI state table
    ]]--
    function VJGM.AIBehaviors.UpdateCombatState(npc, aiState)
        local evaluationInterval = VJGM.Config.Get("CombatStates", "EvaluationInterval", 1.5)
        if CurTime() - aiState.lastStateChange < evaluationInterval then return end
        
        local healthPercent = npc:Health() / npc:GetMaxHealth()
        local enemies = VJGM.AIBehaviors.GetNearbyEnemies(npc, 2000)
        local allies = VJGM.AIBehaviors.GetNearbyAllies(npc, 500)
        
        local newState = "normal"
        
        -- Check for suppressed state
        local suppressedConfig = VJGM.Config.Get("CombatStates", "Suppressed", {})
        if aiState.suppressedUntil > CurTime() then
            newState = "suppressed"
        -- Check for retreat state
        elseif healthPercent <= VJGM.Config.Get("CombatStates", "Retreat", {}).HealthThreshold or
               (#enemies >= VJGM.Config.Get("CombatStates", "Retreat", {}).EnemyCountThreshold and #allies == 0) then
            newState = "retreat"
        -- Check for defensive state
        elseif healthPercent <= VJGM.Config.Get("CombatStates", "Defensive", {}).HealthThreshold or
               #enemies >= VJGM.Config.Get("CombatStates", "Defensive", {}).EnemyCountThreshold then
            newState = "defensive"
        -- Check for aggressive state
        elseif healthPercent >= VJGM.Config.Get("CombatStates", "Aggressive", {}).HealthThreshold and
               #allies >= VJGM.Config.Get("CombatStates", "Aggressive", {}).MinAllyCount then
            newState = "aggressive"
        end
        
        -- Apply state changes
        if newState ~= aiState.combatState then
            VJGM.AIBehaviors.ApplyCombatState(npc, aiState, newState)
            aiState.combatState = newState
            aiState.lastStateChange = CurTime()
        end
    end
    
    --[[
        Apply combat state modifiers to NPC
        @param npc: The NPC entity
        @param aiState: AI state table
        @param state: New combat state
    ]]--
    function VJGM.AIBehaviors.ApplyCombatState(npc, aiState, state)
        local stateConfig = VJGM.Config.Get("CombatStates", state:gsub("^%l", string.upper), {})
        
        -- Apply VJ Base specific modifiers
        if npc.IsVJBaseSNPC then
            -- Adjust movement speed
            if stateConfig.SpeedMultiplier and npc.VJ_Set_WalkSpeed then
                local baseWalk = npc.VJGM_OriginalWalkSpeed or 150
                local baseRun = npc.VJGM_OriginalRunSpeed or 250
                
                if not npc.VJGM_OriginalWalkSpeed then
                    npc.VJGM_OriginalWalkSpeed = baseWalk
                    npc.VJGM_OriginalRunSpeed = baseRun
                end
                
                npc:VJ_Set_WalkSpeed(baseWalk * stateConfig.SpeedMultiplier)
                npc:VJ_Set_RunSpeed(baseRun * stateConfig.SpeedMultiplier)
            end
            
            -- Adjust weapon spread (accuracy)
            if stateConfig.AccuracyMultiplier and npc.WeaponSpread then
                if not npc.VJGM_OriginalSpread then
                    npc.VJGM_OriginalSpread = npc.WeaponSpread
                end
                npc.WeaponSpread = npc.VJGM_OriginalSpread * stateConfig.AccuracyMultiplier
            end
        end
        
        -- Store state-specific flags
        npc.VJGM_CombatState = state
        npc.VJGM_StateConfig = stateConfig
        
        -- Debug output
        if VJGM.Config.Get("AIBehaviors", "DebugMode", false) then
            print("[VJGM AI] " .. npc:GetClass() .. " entered " .. state .. " state")
        end
    end
    
    --[[
        Update target prioritization
        @param npc: The NPC entity
        @param aiState: AI state table
    ]]--
    function VJGM.AIBehaviors.UpdateTargetPriority(npc, aiState)
        local updateInterval = VJGM.Config.Get("TargetPrioritization", "UpdateInterval", 2.0)
        if CurTime() - aiState.lastTargetUpdate < updateInterval then return end
        
        aiState.lastTargetUpdate = CurTime()
        
        local maxDistance = VJGM.Config.Get("TargetPrioritization", "MaxTargetDistance", 10000)
        local enemies = VJGM.AIBehaviors.GetNearbyEnemies(npc, maxDistance)
        
        if #enemies == 0 then
            aiState.currentTarget = nil
            return
        end
        
        -- Calculate priority for each enemy
        local bestTarget = nil
        local bestPriority = 0
        
        for _, enemy in ipairs(enemies) do
            local priority = VJGM.AIBehaviors.CalculateTargetPriority(npc, enemy)
            if priority > bestPriority then
                bestPriority = priority
                bestTarget = enemy
            end
        end
        
        -- Set the best target
        if IsValid(bestTarget) and bestTarget ~= aiState.currentTarget then
            aiState.currentTarget = bestTarget
            
            -- Apply target to VJ Base NPC
            if npc.IsVJBaseSNPC and npc.VJ_DoSetEnemy then
                npc:VJ_DoSetEnemy(bestTarget, true)
            end
        end
    end
    
    --[[
        Calculate target priority score
        @param npc: The NPC entity
        @param target: Target entity
        @return number: Priority score
    ]]--
    function VJGM.AIBehaviors.CalculateTargetPriority(npc, target)
        if not IsValid(target) then return 0 end
        
        local config = VJGM.Config.Get("TargetPrioritization", {})
        local priority = 0
        
        local distance = npc:GetPos():Distance(target:GetPos())
        local maxDist = config.MaxTargetDistance or 10000
        
        -- Distance factor (closer = higher priority)
        local distanceFactor = 1 - (distance / maxDist)
        priority = priority + (distanceFactor * (config.DistanceWeight or 0.4))
        
        -- Health factor (lower health = higher priority for finishing)
        if target:Health() and target:GetMaxHealth() then
            local healthFactor = 1 - (target:Health() / target:GetMaxHealth())
            priority = priority + (healthFactor * (config.HealthWeight or 0.2))
        end
        
        -- Threat multiplier based on entity type
        local threatMult = 1.0
        if target:IsPlayer() then
            threatMult = config.ThreatMultipliers and config.ThreatMultipliers.player or 2.0
        elseif target:IsNPC() then
            local class = target:GetClass()
            if class:find("turret") then
                threatMult = config.ThreatMultipliers and config.ThreatMultipliers.npc_turret or 1.8
            elseif target.VJGM_Role == "medic" then
                threatMult = config.ThreatMultipliers and config.ThreatMultipliers.npc_medic or 1.6
            elseif target.VJGM_Role == "heavy" then
                threatMult = config.ThreatMultipliers and config.ThreatMultipliers.npc_heavy or 1.4
            elseif target.VJGM_Role == "sniper" then
                threatMult = config.ThreatMultipliers and config.ThreatMultipliers.npc_sniper or 1.7
            else
                threatMult = config.ThreatMultipliers and config.ThreatMultipliers.default or 1.0
            end
        elseif target:IsVehicle() then
            threatMult = config.ThreatMultipliers and config.ThreatMultipliers.vehicle or 1.5
        end
        
        priority = priority + (threatMult * (config.ThreatWeight or 0.3))
        
        -- Line of sight bonus
        local hasLOS = VJGM.AIBehaviors.HasLineOfSight(npc, target)
        if hasLOS then
            priority = priority + (config.LineOfSightWeight or 0.1)
        end
        
        return priority
    end
    
    --[[
        Update cover seeking behavior
        @param npc: The NPC entity
        @param aiState: AI state table
    ]]--
    function VJGM.AIBehaviors.UpdateCoverSeeking(npc, aiState)
        local checkInterval = VJGM.Config.Get("CoverSeeking", "CheckInterval", 3.0)
        if CurTime() - aiState.lastCoverCheck < checkInterval then return end
        
        aiState.lastCoverCheck = CurTime()
        
        -- Check if NPC should seek cover
        local shouldSeekCover = VJGM.AIBehaviors.ShouldSeekCover(npc, aiState)
        
        if shouldSeekCover then
            local coverPos = VJGM.AIBehaviors.FindBestCover(npc, aiState)
            
            if coverPos then
                aiState.currentCover = coverPos
                
                -- Move to cover (VJ Base compatible)
                if npc.IsVJBaseSNPC and npc.VJ_TASK_GOTO_LASTPOS then
                    npc:SetLastPosition(coverPos)
                    npc:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH")
                end
            end
        end
    end
    
    --[[
        Determine if NPC should seek cover
        @param npc: The NPC entity
        @param aiState: AI state table
        @return boolean: Should seek cover
    ]]--
    function VJGM.AIBehaviors.ShouldSeekCover(npc, aiState)
        local config = VJGM.Config.Get("CoverSeeking", {})
        
        -- Always seek cover if retreating
        if aiState.combatState == "retreat" and VJGM.Config.Get("CombatStates", "Retreat", {}).ForceCoverSeeking then
            return true
        end
        
        -- Seek cover if in defensive state
        if aiState.combatState == "defensive" and VJGM.Config.Get("CombatStates", "Defensive", {}).SeekCover then
            return true
        end
        
        -- Seek cover if suppressed
        if aiState.combatState == "suppressed" then
            return true
        end
        
        -- Seek cover if reloading
        if aiState.isReloading and VJGM.Config.Get("WeaponLogic", "AmmoManagement", {}).CoverDuringReload then
            return true
        end
        
        -- Seek cover if health is low
        local healthPercent = npc:Health() / npc:GetMaxHealth()
        if healthPercent <= (config.HealthThreshold or 0.7) then
            return true
        end
        
        return false
    end
    
    --[[
        Find the best cover position for NPC
        @param npc: The NPC entity
        @param aiState: AI state table
        @return Vector: Best cover position or nil
    ]]--
    function VJGM.AIBehaviors.FindBestCover(npc, aiState)
        local config = VJGM.Config.Get("CoverSeeking", {})
        local npcPos = npc:GetPos()
        
        local maxDistance = config.MaxCoverDistance or 1000
        local sampleCount = config.CoverSampleCount or 8
        local checkDistance = config.CoverCheckDistance or 100
        
        local bestCover = nil
        local bestScore = 0
        
        -- Get primary enemy
        local enemy = aiState.currentTarget or npc:GetEnemy()
        if not IsValid(enemy) then return nil end
        
        local enemyPos = enemy:GetPos()
        
        -- Sample positions in a circle around NPC
        for i = 1, sampleCount do
            local angle = (360 / sampleCount) * i
            local rad = math.rad(angle)
            local offset = Vector(math.cos(rad) * maxDistance, math.sin(rad) * maxDistance, 0)
            local testPos = npcPos + offset
            
            -- Trace to ground
            local tr = util.TraceLine({
                start = testPos + Vector(0, 0, 50),
                endpos = testPos - Vector(0, 0, 200),
                mask = MASK_SOLID_BRUSHONLY
            })
            
            if tr.Hit then
                testPos = tr.HitPos + Vector(0, 0, 20)
                
                -- Check if position provides cover from enemy
                local coverTrace = util.TraceLine({
                    start = testPos + Vector(0, 0, 50),
                    endpos = enemyPos,
                    mask = MASK_SOLID_BRUSHONLY
                })
                
                if coverTrace.Hit then
                    -- This position has cover
                    local score = VJGM.AIBehaviors.EvaluateCoverPosition(npc, testPos, enemyPos, aiState)
                    
                    if score > bestScore then
                        bestScore = score
                        bestCover = testPos
                    end
                end
            end
        end
        
        return bestCover
    end
    
    --[[
        Evaluate quality of a cover position
        @param npc: The NPC entity
        @param coverPos: Position to evaluate
        @param enemyPos: Enemy position
        @param aiState: AI state table
        @return number: Cover quality score
    ]]--
    function VJGM.AIBehaviors.EvaluateCoverPosition(npc, coverPos, enemyPos, aiState)
        local config = VJGM.Config.Get("CoverSeeking", {})
        local score = 100
        
        -- Prefer positions closer to NPC (less movement)
        local distanceToNPC = npc:GetPos():Distance(coverPos)
        score = score - (distanceToNPC / 10)
        
        -- Prefer elevated positions
        local heightDiff = coverPos.z - npc:GetPos().z
        if heightDiff > 0 then
            score = score + (config.ElevationBonus or 50)
        end
        
        -- Bonus for nearby allies
        local allies = VJGM.AIBehaviors.GetNearbyAllies(npc, 300)
        if #allies > 0 then
            score = score * (config.AllyProximityBonus or 1.2)
        end
        
        return score
    end
    
    --[[
        Update group communication
        @param npc: The NPC entity
        @param aiState: AI state table
    ]]--
    function VJGM.AIBehaviors.UpdateGroupCommunication(npc, aiState)
        local updateInterval = VJGM.Config.Get("GroupCommunication", "UpdateInterval", 1.0)
        if CurTime() - aiState.lastCommunication < updateInterval then return end
        
        aiState.lastCommunication = CurTime()
        
        local config = VJGM.Config.Get("GroupCommunication", {})
        
        -- Alert allies when spotting enemy
        if config.AlertOnEnemySighted and IsValid(aiState.currentTarget) then
            VJGM.AIBehaviors.CommunicateToSquad(npc, "enemy_spotted", aiState.currentTarget)
        end
        
        -- Report low ammo
        if config.ReportLowAmmo and aiState.ammoPercent <= (config.LowAmmoThreshold or 0.3) then
            VJGM.AIBehaviors.CommunicateToSquad(npc, "low_ammo", nil)
        end
        
        -- Report injuries
        local healthPercent = npc:Health() / npc:GetMaxHealth()
        if config.ReportInjuries and healthPercent <= (config.InjuryThreshold or 0.5) then
            VJGM.AIBehaviors.CommunicateToSquad(npc, "man_down", nil)
        end
        
        -- Request covering fire when retreating
        if aiState.combatState == "retreat" and config.RequestCoveringFire then
            VJGM.AIBehaviors.CommunicateToSquad(npc, "requesting_backup", nil)
        end
    end
    
    --[[
        Communicate message to squad members
        @param npc: The NPC entity
        @param messageType: Type of message
        @param data: Additional data
    ]]--
    function VJGM.AIBehaviors.CommunicateToSquad(npc, messageType, data)
        local config = VJGM.Config.Get("GroupCommunication", {})
        local maxRange = config.MaxRange or 2000
        
        local allies = VJGM.AIBehaviors.GetNearbyAllies(npc, maxRange)
        
        for _, ally in ipairs(allies) do
            if IsValid(ally) then
                local allyAI = aiNPCs[ally:EntIndex()]
                if allyAI then
                    VJGM.AIBehaviors.ReceiveMessage(ally, allyAI, messageType, data, npc)
                end
            end
        end
    end
    
    --[[
        Receive communication from squad member
        @param npc: The receiving NPC
        @param aiState: AI state table
        @param messageType: Type of message
        @param data: Additional data
        @param sender: Sending NPC
    ]]--
    function VJGM.AIBehaviors.ReceiveMessage(npc, aiState, messageType, data, sender)
        if messageType == "enemy_spotted" and IsValid(data) then
            -- Share target information
            if not IsValid(aiState.currentTarget) and npc.IsVJBaseSNPC and npc.VJ_DoSetEnemy then
                npc:VJ_DoSetEnemy(data, true)
            end
        elseif messageType == "requesting_backup" then
            -- Provide covering fire if able
            if aiState.combatState == "aggressive" or aiState.combatState == "normal" then
                aiState.providingCover = true
                aiState.coverUntil = CurTime() + (VJGM.Config.Get("GroupCommunication", {}).CoveringFireDuration or 5.0)
            end
        end
    end
    
    --[[
        Update weapon logic and ammo management
        @param npc: The NPC entity
        @param aiState: AI state table
    ]]--
    function VJGM.AIBehaviors.UpdateWeaponLogic(npc, aiState)
        -- Simulate ammo tracking (VJ Base doesn't expose ammo directly)
        -- This is a simplified simulation based on fire rate and time
        
        -- Check if NPC needs to reload (simplified)
        local ammoConfig = VJGM.Config.Get("WeaponLogic", "AmmoManagement", {})
        
        if aiState.ammoPercent <= (ammoConfig.ReloadThreshold or 0.3) and not aiState.isReloading then
            aiState.isReloading = true
            
            -- Simulate reload time
            timer.Simple(2, function()
                if IsValid(npc) then
                    aiState.isReloading = false
                    aiState.ammoPercent = 1.0
                end
            end)
            
            -- Alert squad if enabled
            if ammoConfig.AlertOnLowAmmo then
                VJGM.AIBehaviors.CommunicateToSquad(npc, "low_ammo", nil)
            end
        end
        
        -- Simulate ammo consumption (rough estimate)
        if IsValid(npc:GetEnemy()) and npc:GetEnemy():Health() > 0 then
            aiState.ammoPercent = math.max(0, aiState.ammoPercent - 0.01)
        end
    end
    
    --[[
        Handle NPC taking damage (for suppression system)
        @param npc: The NPC entity
        @param dmginfo: Damage info
    ]]--
    function VJGM.AIBehaviors.OnNPCDamaged(npc, dmginfo)
        local aiState = aiNPCs[npc:EntIndex()]
        if not aiState then return end
        
        local suppressedConfig = VJGM.Config.Get("CombatStates", "Suppressed", {})
        local damage = dmginfo:GetDamage()
        
        -- Track recent damage for suppression
        local timeWindow = suppressedConfig.TimeWindow or 3.0
        if CurTime() - aiState.lastDamageTime > timeWindow then
            aiState.recentDamage = 0
        end
        
        aiState.recentDamage = aiState.recentDamage + damage
        aiState.lastDamageTime = CurTime()
        
        -- Check if NPC should be suppressed
        local damageThreshold = suppressedConfig.DamageThreshold or 50
        if aiState.recentDamage >= damageThreshold then
            aiState.suppressedUntil = CurTime() + (suppressedConfig.Duration or 5.0)
            aiState.recentDamage = 0
        end
    end
    
    --[[
        Get nearby enemy entities
        @param npc: The NPC entity
        @param radius: Search radius
        @return table: List of enemy entities
    ]]--
    function VJGM.AIBehaviors.GetNearbyEnemies(npc, radius)
        local enemies = {}
        local npcPos = npc:GetPos()
        
        -- Get NPC faction
        local npcFaction = nil
        if npc.IsVJBaseSNPC and npc.VJ_NPC_Class then
            npcFaction = npc.VJ_NPC_Class[1]
        end
        
        -- Find potential enemies in radius
        for _, ent in ipairs(ents.FindInSphere(npcPos, radius)) do
            if IsValid(ent) and ent ~= npc and ent:Health() > 0 then
                local isEnemy = false
                
                -- Check players
                if ent:IsPlayer() then
                    isEnemy = true
                -- Check NPCs
                elseif ent:IsNPC() then
                    if ent.IsVJBaseSNPC and ent.VJ_NPC_Class and npcFaction then
                        -- Different faction = enemy
                        isEnemy = ent.VJ_NPC_Class[1] ~= npcFaction
                    else
                        -- Use VJ Base enemy check if available
                        if npc.IsVJBaseSNPC and npc.VJ_IsEnemy then
                            isEnemy = npc:VJ_IsEnemy(ent)
                        end
                    end
                end
                
                if isEnemy then
                    table.insert(enemies, ent)
                end
            end
        end
        
        return enemies
    end
    
    --[[
        Get nearby allied entities
        @param npc: The NPC entity
        @param radius: Search radius
        @return table: List of allied entities
    ]]--
    function VJGM.AIBehaviors.GetNearbyAllies(npc, radius)
        local allies = {}
        local npcPos = npc:GetPos()
        
        -- Get NPC faction
        local npcFaction = nil
        if npc.IsVJBaseSNPC and npc.VJ_NPC_Class then
            npcFaction = npc.VJ_NPC_Class[1]
        end
        
        -- Find potential allies in radius
        for _, ent in ipairs(ents.FindInSphere(npcPos, radius)) do
            if IsValid(ent) and ent ~= npc and ent:IsNPC() and ent:Health() > 0 then
                if ent.IsVJBaseSNPC and ent.VJ_NPC_Class and npcFaction then
                    -- Same faction = ally
                    if ent.VJ_NPC_Class[1] == npcFaction then
                        table.insert(allies, ent)
                    end
                end
            end
        end
        
        return allies
    end
    
    --[[
        Check if NPC has line of sight to target
        @param npc: The NPC entity
        @param target: Target entity
        @return boolean: Has line of sight
    ]]--
    function VJGM.AIBehaviors.HasLineOfSight(npc, target)
        if not IsValid(npc) or not IsValid(target) then return false end
        
        local startPos = npc:GetPos() + Vector(0, 0, 50)
        local endPos = target:GetPos() + Vector(0, 0, 50)
        
        local tr = util.TraceLine({
            start = startPos,
            endpos = endPos,
            filter = {npc, target},
            mask = MASK_SOLID_BRUSHONLY
        })
        
        return not tr.Hit
    end
    
    --[[
        Get all NPCs with AI behaviors enabled
        @return table: List of AI-enabled NPCs
    ]]--
    function VJGM.AIBehaviors.GetAINPCs()
        local npcs = {}
        for entIndex, aiState in pairs(aiNPCs) do
            if IsValid(aiState.npc) then
                table.insert(npcs, aiState.npc)
            end
        end
        return npcs
    end
    
    -- Hook for initialization
    hook.Add("Initialize", "VJGM_AIBehaviors_Init", function()
        VJGM.AIBehaviors.Initialize()
    end)
    
    -- Hook for damage tracking
    hook.Add("EntityTakeDamage", "VJGM_AIBehaviors_Damage", function(target, dmginfo)
        if IsValid(target) and target:IsNPC() and target.VJGM_OnTakeDamage then
            target:VJGM_OnTakeDamage(dmginfo)
        end
    end)
    
end
