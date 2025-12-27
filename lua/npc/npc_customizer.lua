--[[
    NPC Customizer
    Applies customization to spawned NPCs
    
    Compatible with VJ Base NPC system
    Supports both standard GMod NPCs and VJ Base SNPCs
]]--

if SERVER then
    
    -- Load configuration
    include("npc/config/init.lua")
    
    VJGM = VJGM or {}
    VJGM.NPCCustomizer = VJGM.NPCCustomizer or {}
    
    --[[
        Apply customization to an NPC
        @param npc: The NPC entity
        @param customization: Customization table
    ]]--
    function VJGM.NPCCustomizer.Apply(npc, customization)
        if not IsValid(npc) or not customization then return end
        
        local enableHealth = VJGM.Config.Get("Customizer", "EnableHealthCustomization", true)
        local enableModel = VJGM.Config.Get("Customizer", "EnableModelCustomization", true)
        local enableWeapons = VJGM.Config.Get("Customizer", "EnableWeaponCustomization", true)
        local enableVJBase = VJGM.Config.Get("Customizer", "EnableVJBaseCustomization", true)
        
        -- Health customization
        if customization.health and enableHealth then
            VJGM.NPCCustomizer.SetHealth(npc, customization.health)
        end
        
        -- Model customization
        if customization.model and enableModel then
            VJGM.NPCCustomizer.SetModel(npc, customization.model)
        end
        
        -- Weapon customization
        if customization.weapons and enableWeapons then
            VJGM.NPCCustomizer.SetWeapons(npc, customization.weapons)
        end
        
        -- Color customization
        if customization.color then
            npc:SetColor(customization.color)
        end
        
        -- Material customization
        if customization.material then
            npc:SetMaterial(customization.material)
        end
        
        -- Skin customization
        if customization.skin then
            npc:SetSkin(customization.skin)
        end
        
        -- Bodygroup customization
        if customization.bodygroups then
            for bgID, bgValue in pairs(customization.bodygroups) do
                npc:SetBodygroup(bgID, bgValue)
            end
        end
        
        -- Scale customization
        if customization.scale then
            npc:SetModelScale(customization.scale, 0)
        end
        
        -- VJ Base specific customization (already applied in dynamic_spawner.lua pre-spawn)
        -- This is for any post-spawn VJ Base settings
        if npc.IsVJBaseSNPC and customization.vjbase and enableVJBase then
            VJGM.NPCCustomizer.ApplyVJBasePostSpawn(npc, customization.vjbase)
        end
    end
    
    --[[
        Set NPC health (with max health)
        @param npc: The NPC entity
        @param health: Health value
    ]]--
    function VJGM.NPCCustomizer.SetHealth(npc, health)
        if not IsValid(npc) or not health then return end
        
        local defaultHealth = VJGM.Config.Get("Spawner", "DefaultNPCHealth", 100)
        health = health or defaultHealth
        
        npc:SetMaxHealth(health)
        npc:SetHealth(health)
        
        -- VJ Base NPCs may have additional health variables
        if npc.IsVJBaseSNPC and npc.StartHealth then
            npc.StartHealth = health
        end
    end
    
    --[[
        Set NPC model
        @param npc: The NPC entity
        @param modelPath: Model file path
    ]]--
    function VJGM.NPCCustomizer.SetModel(npc, modelPath)
        if not IsValid(npc) or not modelPath then return end
        
        npc:SetModel(modelPath)
    end
    
    --[[
        Set NPC weapons
        @param npc: The NPC entity
        @param weapons: Table of weapon class names
    ]]--
    function VJGM.NPCCustomizer.SetWeapons(npc, weapons)
        if not IsValid(npc) or not weapons then return end
        
        -- For VJ Base NPCs
        if npc.IsVJBaseSNPC then
            -- VJ Base uses a weapon table system
            if type(weapons) == "table" and #weapons > 0 then
                npc.VJ_NPC_WeaponTable = weapons
                
                -- Give the first weapon immediately
                if npc.Give and weapons[1] then
                    npc:Give(weapons[1])
                end
            end
        else
            -- For standard GMod NPCs
            if type(weapons) == "table" and #weapons > 0 then
                local weapon = weapons[1]  -- Standard NPCs typically use one weapon
                if npc.Give then
                    npc:Give(weapon)
                end
            end
        end
    end
    
    --[[
        Apply VJ Base specific post-spawn settings
        @param npc: The NPC entity (must be VJ Base SNPC)
        @param vjSettings: VJ Base settings table
    ]]--
    function VJGM.NPCCustomizer.ApplyVJBasePostSpawn(npc, vjSettings)
        if not IsValid(npc) or not npc.IsVJBaseSNPC then return end
        
        -- Set target (if specified)
        if vjSettings.target and IsValid(vjSettings.target) then
            npc:VJ_DoSetEnemy(vjSettings.target, true)
        end
        
        -- Set alert state
        if vjSettings.alerted then
            npc:VJ_TASK_IDLE_STAND()
        end
        
        -- Movement speed modifiers
        if vjSettings.walkSpeed then
            if npc.VJ_Set_WalkSpeed then
                npc:VJ_Set_WalkSpeed(vjSettings.walkSpeed)
            end
        end
        
        if vjSettings.runSpeed then
            if npc.VJ_Set_RunSpeed then
                npc:VJ_Set_RunSpeed(vjSettings.runSpeed)
            end
        end
    end
    
    --[[
        Batch apply customization to multiple NPCs
        @param npcs: Table of NPC entities
        @param customization: Customization table
    ]]--
    function VJGM.NPCCustomizer.ApplyBatch(npcs, customization)
        if not npcs or not customization then return end
        
        for _, npc in ipairs(npcs) do
            VJGM.NPCCustomizer.Apply(npc, customization)
        end
    end
    
end
