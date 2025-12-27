--[[
    Objectives Command Handler
    Handles the !objectives chat command for opening the objectives menu
    
    Compatible with VJ Base Gamemaster Tools
]]--

if SERVER then
    
    -- Ensure objectives manager is loaded
    if not VJGM or not VJGM.Objectives then
        include("players/objectives_manager.lua")
    end
    
    --[[
        Handle PlayerSay hook for !objectives command
    ]]--
    hook.Add("PlayerSay", "VJGM_ObjectivesCommand", function(ply, text, teamChat)
        -- Check if the message is the objectives command
        local lowerText = string.lower(text)
        if lowerText == "!objectives" then
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
