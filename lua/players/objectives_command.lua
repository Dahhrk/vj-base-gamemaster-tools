--[[
    Objectives Command Handler
    Handles the !objectives chat command for opening the objectives menu
    
    Compatible with VJ Base Gamemaster Tools
]]--

if SERVER then
    
    VJGM = VJGM or {}
    
    --[[
        Handle PlayerSay hook for !objectives command
    ]]--
    hook.Add("PlayerSay", "VJGM_ObjectivesCommand", function(ply, text, teamChat)
        -- Check if the message is the objectives command
        local lowerText = string.lower(text)
        if lowerText == "!objectives" then
            -- Ensure objectives manager is loaded
            if not VJGM.Objectives or not VJGM.Objectives.IsAuthorized then
                ply:ChatPrint("[VJGM] Objectives system not loaded. Please contact an administrator.")
                ErrorNoHalt("[VJGM] Objectives manager not loaded! Ensure objectives_manager.lua is loaded first.\n")
                return ""
            end
            
            -- Check authorization
            if not VJGM.Objectives.IsAuthorized(ply) then
                ply:ChatPrint("[VJGM] You don't have permission to access the Objectives Menu.")
                return ""
            end
            
            -- Send network message to open the menu on client
            net.Start("VJGM_OpenObjectivesMenu")
            net.Send(ply)
            
            print("[VJGM] " .. ply:Nick() .. " opened the Objectives Menu")
            
            -- Suppress the chat message
            return ""
        end
    end)
    
    -- Network message for opening the menu
    util.AddNetworkString("VJGM_OpenObjectivesMenu")
    
    print("[VJGM] Objectives Command Handler initialized")
end
