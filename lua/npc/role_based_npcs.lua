--[[
    Role-Based NPCs - PLACEHOLDER
    Future expansion for advanced role-based NPC behaviors and assignments
    
    Planned Features:
    - Medic NPCs that heal allies
    - Engineer NPCs that repair vehicles/turrets
    - Squad leader NPCs that buff nearby allies
    - Sniper NPCs with enhanced accuracy and range
    - Scout NPCs with increased movement speed
    - Role-specific behavior patterns
    - Dynamic role assignment based on squad composition
    
    Compatible with VJ Base NPC system
]]--

if SERVER then
    
    -- Load configuration
    include("npc/config/init.lua")
    
    VJGM = VJGM or {}
    VJGM.RoleBasedNPCs = VJGM.RoleBasedNPCs or {}
    
    -- Role definitions (placeholder)
    local NPCRoles = {
        MEDIC = "medic",
        ENGINEER = "engineer",
        SQUAD_LEADER = "squad_leader",
        SNIPER = "sniper",
        SCOUT = "scout",
        HEAVY = "heavy",
        ASSAULT = "assault"
    }
    
    VJGM.RoleBasedNPCs.Roles = NPCRoles
    
    -- Storage for role-assigned NPCs
    local roleAssignedNPCs = {}
    
    --[[
        Initialize role-based NPC system
    ]]--
    function VJGM.RoleBasedNPCs.Initialize()
        local prefix = VJGM.Config.Get("Spawner", "ConsolePrefix", "[VJGM]")
        local enabled = VJGM.Config.Get("RoleBasedNPCs", "Enabled", true)
        
        roleAssignedNPCs = {}
        
        if enabled then
            print(prefix .. " Role-Based NPCs system initialized")
        else
            print(prefix .. " Role-Based NPCs system disabled in config")
        end
    end
    
    --[[
        Assign a role to an NPC
        @param npc: The NPC entity
        @param role: Role identifier (use VJGM.RoleBasedNPCs.Roles)
        @param roleConfig: Role-specific configuration
    ]]--
    function VJGM.RoleBasedNPCs.AssignRole(npc, role, roleConfig)
        if not IsValid(npc) then
            ErrorNoHalt("[VJGM] RoleBasedNPCs.AssignRole - Invalid NPC entity\n")
            return false
        end
        
        if not role then
            ErrorNoHalt("[VJGM] RoleBasedNPCs.AssignRole - No role specified\n")
            return false
        end
        
        roleConfig = roleConfig or {}
        
        -- Store role information on the NPC
        npc.VJGM_Role = role
        npc.VJGM_RoleConfig = roleConfig
        
        -- Track in global table
        if not roleAssignedNPCs[role] then
            roleAssignedNPCs[role] = {}
        end
        table.insert(roleAssignedNPCs[role], npc)
        
        -- Apply role-specific attributes
        if role == NPCRoles.MEDIC then
            local medicConfig = VJGM.Config.Get("RoleBasedNPCs", "Medic", {})
            npc.VJGM_HealAmount = roleConfig.healAmount or medicConfig.HealAmount or 25
            npc.VJGM_HealRange = roleConfig.healRange or medicConfig.HealRange or 300
            npc.VJGM_HealCooldown = roleConfig.healCooldown or medicConfig.HealCooldown or 10
            npc.VJGM_NextHealTime = 0
            
            -- Start medic behavior timer
            local timerName = "VJGM_Medic_" .. npc:EntIndex()
            timer.Create(timerName, 2, 0, function()
                if IsValid(npc) and npc:Health() > 0 then
                    VJGM.RoleBasedNPCs.MedicBehavior(npc)
                else
                    timer.Remove(timerName)
                end
            end)
            
        elseif role == NPCRoles.ENGINEER then
            local engineerConfig = VJGM.Config.Get("RoleBasedNPCs", "Engineer", {})
            npc.VJGM_RepairAmount = roleConfig.repairAmount or engineerConfig.RepairAmount or 50
            npc.VJGM_RepairRange = roleConfig.repairRange or engineerConfig.RepairRange or 300
            npc.VJGM_RepairCooldown = roleConfig.repairCooldown or engineerConfig.RepairCooldown or 15
            npc.VJGM_NextRepairTime = 0
            
        elseif role == NPCRoles.SQUAD_LEADER then
            local leaderConfig = VJGM.Config.Get("RoleBasedNPCs", "SquadLeader", {})
            npc.VJGM_BuffRange = roleConfig.buffRange or leaderConfig.BuffRange or 500
            npc.VJGM_DamageBuff = roleConfig.damageBuff or leaderConfig.DamageBuff or 1.2
            npc.VJGM_AccuracyBuff = roleConfig.accuracyBuff or leaderConfig.AccuracyBuff or 1.15
            npc.VJGM_BuffDuration = roleConfig.buffDuration or leaderConfig.BuffDuration or 5
            
            -- Start squad leader behavior timer
            local timerName = "VJGM_SquadLeader_" .. npc:EntIndex()
            timer.Create(timerName, 3, 0, function()
                if IsValid(npc) and npc:Health() > 0 then
                    VJGM.RoleBasedNPCs.SquadLeaderBehavior(npc)
                else
                    timer.Remove(timerName)
                end
            end)
            
        elseif role == NPCRoles.SNIPER then
            local sniperConfig = VJGM.Config.Get("RoleBasedNPCs", "Sniper", {})
            -- Enhanced accuracy and range for snipers (VJ Base compatible)
            if npc.IsVJBaseSNPC then
                npc.SightDistance = roleConfig.sightDistance or sniperConfig.SightDistance or 15000
                npc.SightAngle = roleConfig.sightAngle or sniperConfig.SightAngle or 60
            end
            
        elseif role == NPCRoles.SCOUT then
            local scoutConfig = VJGM.Config.Get("RoleBasedNPCs", "Scout", {})
            -- Increased movement speed for scouts (VJ Base compatible)
            if npc.IsVJBaseSNPC and npc.VJ_Set_WalkSpeed then
                local walkMult = roleConfig.walkSpeedMultiplier or scoutConfig.WalkSpeedMultiplier or 1.3
                local runMult = roleConfig.runSpeedMultiplier or scoutConfig.RunSpeedMultiplier or 1.3
                
                -- Get current speeds or use VJ Base defaults
                local baseWalk = npc.AnimTbl_Walk and 150 or 150
                local baseRun = npc.AnimTbl_Run and 250 or 250
                
                npc:VJ_Set_WalkSpeed(baseWalk * walkMult)
                npc:VJ_Set_RunSpeed(baseRun * runMult)
            end
            
        elseif role == NPCRoles.HEAVY then
            local heavyConfig = VJGM.Config.Get("RoleBasedNPCs", "Heavy", {})
            -- Increased health for heavy units
            local healthMultiplier = roleConfig.healthMultiplier or heavyConfig.HealthMultiplier or 1.5
            local currentMaxHealth = npc:GetMaxHealth()
            npc:SetMaxHealth(currentMaxHealth * healthMultiplier)
            npc:SetHealth(currentMaxHealth * healthMultiplier)
            
            -- Update VJ Base StartHealth if it exists
            if npc.IsVJBaseSNPC and npc.StartHealth then
                npc.StartHealth = currentMaxHealth * healthMultiplier
            end
        end
        
        -- Cleanup on death/remove
        npc:CallOnRemove("VJGM_RoleCleanup_" .. npc:EntIndex(), function()
            if roleAssignedNPCs[role] then
                table.RemoveByValue(roleAssignedNPCs[role], npc)
            end
        end)
        
        return true
    end
    
    --[[
        Create a balanced squad with roles
        @param squadConfig: Squad configuration with role distribution
        @return Table of NPC configurations
    ]]--
    function VJGM.RoleBasedNPCs.CreateSquad(squadConfig)
        if not squadConfig or not squadConfig.roles then
            ErrorNoHalt("[VJGM] RoleBasedNPCs.CreateSquad - Invalid squad configuration\n")
            return {}
        end
        
        local npcConfigs = {}
        local baseClass = squadConfig.baseClass or "npc_vj_test_human"
        local faction = squadConfig.faction or "VJ_FACTION_PLAYER"
        local squadName = squadConfig.squadName or "Squad_" .. math.random(1000, 9999)
        
        -- Generate NPC configs for each role
        for _, roleEntry in ipairs(squadConfig.roles) do
            local role = roleEntry.role
            local count = roleEntry.count or 1
            local roleCustomization = roleEntry.customization or {}
            
            for i = 1, count do
                local npcConfig = {
                    class = roleEntry.class or baseClass,
                    count = 1,
                    customization = table.Copy(roleCustomization),
                    role = role,
                    roleConfig = roleEntry.roleConfig or {}
                }
                
                -- Ensure vjbase configuration exists
                npcConfig.customization.vjbase = npcConfig.customization.vjbase or {}
                npcConfig.customization.vjbase.faction = faction
                npcConfig.customization.vjbase.squad = squadName
                
                -- Apply role-specific defaults
                if role == NPCRoles.MEDIC then
                    local medicConfig = VJGM.Config.Get("RoleBasedNPCs", "Medic", {})
                    npcConfig.customization.health = roleCustomization.health or medicConfig.DefaultHealth or 100
                elseif role == NPCRoles.HEAVY then
                    local heavyConfig = VJGM.Config.Get("RoleBasedNPCs", "Heavy", {})
                    npcConfig.customization.health = roleCustomization.health or heavyConfig.DefaultHealth or 200
                elseif role == NPCRoles.SQUAD_LEADER then
                    local leaderConfig = VJGM.Config.Get("RoleBasedNPCs", "SquadLeader", {})
                    npcConfig.customization.health = roleCustomization.health or leaderConfig.DefaultHealth or 150
                elseif role == NPCRoles.SCOUT then
                    local scoutConfig = VJGM.Config.Get("RoleBasedNPCs", "Scout", {})
                    npcConfig.customization.health = roleCustomization.health or scoutConfig.DefaultHealth or 80
                elseif role == NPCRoles.SNIPER then
                    local sniperConfig = VJGM.Config.Get("RoleBasedNPCs", "Sniper", {})
                    npcConfig.customization.health = roleCustomization.health or sniperConfig.DefaultHealth or 80
                elseif role == NPCRoles.ENGINEER then
                    local engineerConfig = VJGM.Config.Get("RoleBasedNPCs", "Engineer", {})
                    npcConfig.customization.health = roleCustomization.health or engineerConfig.DefaultHealth or 100
                elseif role == NPCRoles.ASSAULT then
                    local assaultConfig = VJGM.Config.Get("RoleBasedNPCs", "Assault", {})
                    npcConfig.customization.health = roleCustomization.health or assaultConfig.DefaultHealth or 100
                end
                
                table.insert(npcConfigs, npcConfig)
            end
        end
        
        return npcConfigs
    end
    
    --[[
        Get NPCs with specific role
        @param role: Role identifier
        @return Table of NPCs with that role
    ]]--
    function VJGM.RoleBasedNPCs.GetNPCsByRole(role)
        if not role then return {} end
        
        local npcs = {}
        if roleAssignedNPCs[role] then
            for _, npc in ipairs(roleAssignedNPCs[role]) do
                if IsValid(npc) and npc:Health() > 0 then
                    table.insert(npcs, npc)
                end
            end
        end
        
        return npcs
    end
    
    --[[
        Medic behavior - heal nearby allies
        @param medic: The medic NPC entity
    ]]--
    function VJGM.RoleBasedNPCs.MedicBehavior(medic)
        if not IsValid(medic) or medic:Health() <= 0 then return end
        if not medic.VJGM_Role or medic.VJGM_Role ~= NPCRoles.MEDIC then return end
        
        -- Check cooldown
        if CurTime() < (medic.VJGM_NextHealTime or 0) then return end
        
        local healAmount = medic.VJGM_HealAmount or 25
        local healRange = medic.VJGM_HealRange or 300
        local healCooldown = medic.VJGM_HealCooldown or 10
        
        -- Find injured allies nearby
        local allies = {}
        local medicPos = medic:GetPos()
        
        -- Get faction for VJ Base NPCs
        local medicFaction = nil
        if medic.IsVJBaseSNPC and medic.VJ_NPC_Class then
            medicFaction = medic.VJ_NPC_Class[1]
        end
        
        -- Find NPCs in range
        for _, npc in ipairs(ents.FindInSphere(medicPos, healRange)) do
            if IsValid(npc) and npc:IsNPC() and npc ~= medic and npc:Health() > 0 then
                local maxHealth = npc:GetMaxHealth()
                local currentHealth = npc:Health()
                
                -- Check if ally needs healing (below 80% health)
                if currentHealth < maxHealth * 0.8 then
                    -- Check if same faction (VJ Base)
                    local isSameFaction = false
                    if npc.IsVJBaseSNPC and npc.VJ_NPC_Class and medicFaction then
                        isSameFaction = npc.VJ_NPC_Class[1] == medicFaction
                    else
                        -- For non-VJ NPCs, check squad name if available
                        if medic.VJ_NPC_SquadName and npc.VJ_NPC_SquadName then
                            isSameFaction = medic.VJ_NPC_SquadName == npc.VJ_NPC_SquadName
                        end
                    end
                    
                    if isSameFaction then
                        table.insert(allies, {npc = npc, health = currentHealth})
                    end
                end
            end
        end
        
        -- Find most injured ally
        if #allies > 0 then
            table.sort(allies, function(a, b) return a.health < b.health end)
            local targetAlly = allies[1].npc
            
            -- Heal the ally
            local newHealth = math.min(targetAlly:Health() + healAmount, targetAlly:GetMaxHealth())
            targetAlly:SetHealth(newHealth)
            
            -- Visual effect (simple particle effect)
            local effectdata = EffectData()
            effectdata:SetOrigin(targetAlly:GetPos() + Vector(0, 0, 40))
            effectdata:SetScale(1)
            util.Effect("GlassImpact", effectdata)
            
            -- Set cooldown
            medic.VJGM_NextHealTime = CurTime() + healCooldown
        end
    end
    
    --[[
        Squad Leader behavior - buff nearby allies
        @param leader: The squad leader NPC entity
    ]]--
    function VJGM.RoleBasedNPCs.SquadLeaderBehavior(leader)
        if not IsValid(leader) or leader:Health() <= 0 then return end
        if not leader.VJGM_Role or leader.VJGM_Role ~= NPCRoles.SQUAD_LEADER then return end
        
        local buffRange = leader.VJGM_BuffRange or 500
        local damageBuff = leader.VJGM_DamageBuff or 1.2
        local accuracyBuff = leader.VJGM_AccuracyBuff or 1.15
        local buffDuration = leader.VJGM_BuffDuration or 5
        
        local leaderPos = leader:GetPos()
        
        -- Get faction for VJ Base NPCs
        local leaderFaction = nil
        if leader.IsVJBaseSNPC and leader.VJ_NPC_Class then
            leaderFaction = leader.VJ_NPC_Class[1]
        end
        
        -- Find and buff allies in range
        for _, npc in ipairs(ents.FindInSphere(leaderPos, buffRange)) do
            if IsValid(npc) and npc:IsNPC() and npc ~= leader and npc:Health() > 0 then
                -- Check if same faction
                local isSameFaction = false
                if npc.IsVJBaseSNPC and npc.VJ_NPC_Class and leaderFaction then
                    isSameFaction = npc.VJ_NPC_Class[1] == leaderFaction
                else
                    -- For non-VJ NPCs, check squad name if available
                    if leader.VJ_NPC_SquadName and npc.VJ_NPC_SquadName then
                        isSameFaction = leader.VJ_NPC_SquadName == npc.VJ_NPC_SquadName
                    end
                end
                
                if isSameFaction then
                    -- Apply buffs
                    npc.VJGM_SquadLeaderBuff = true
                    npc.VJGM_DamageMultiplier = damageBuff
                    
                    -- Apply VJ Base specific buffs
                    if npc.IsVJBaseSNPC then
                        -- Increase accuracy by reducing weapon spread
                        if npc.WeaponSpread then
                            npc.VJGM_OriginalSpread = npc.VJGM_OriginalSpread or npc.WeaponSpread
                            npc.WeaponSpread = npc.VJGM_OriginalSpread / accuracyBuff
                        end
                    end
                    
                    -- Visual buff indicator (temporary glow)
                    if not npc.VJGM_BuffEffectActive then
                        npc.VJGM_BuffEffectActive = true
                        timer.Simple(buffDuration, function()
                            if IsValid(npc) then
                                npc.VJGM_BuffEffectActive = false
                            end
                        end)
                    end
                end
            end
        end
    end
    
    -- Hook for future initialization
    hook.Add("Initialize", "VJGM_RoleBasedNPCs_Init", function()
        VJGM.RoleBasedNPCs.Initialize()
    end)
    
end

--[[
    USAGE EXAMPLE (Future):
    
    -- Create a balanced squad configuration
    local squadConfig = {
        roles = {
            { role = VJGM.RoleBasedNPCs.Roles.SQUAD_LEADER, count = 1 },
            { role = VJGM.RoleBasedNPCs.Roles.ASSAULT, count = 4 },
            { role = VJGM.RoleBasedNPCs.Roles.MEDIC, count = 1 },
            { role = VJGM.RoleBasedNPCs.Roles.HEAVY, count = 2 }
        },
        baseClass = "npc_vj_clone_trooper",
        faction = "VJ_FACTION_PLAYER"
    }
    
    -- Generate NPC configurations for wave
    local npcConfigs = VJGM.RoleBasedNPCs.CreateSquad(squadConfig)
    
    -- Use in wave configuration
    table.insert(waveConfig.waves[1].npcs, npcConfigs)
]]--
