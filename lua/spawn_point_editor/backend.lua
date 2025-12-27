-- Backend Module for Spawn Point Management

local spawn_points = {}

-- Default spawn groups
local default_groups = { "Default", "Wave_1", "Allies", "Enemies" }

-- Adds a new spawn point
function add_spawn_point(x, y, angle, radius, group)
    table.insert(spawn_points, {
        position = {x = x, y = y},
        angle = angle,
        radius = radius,
        group = group or "Default"
    })
end

-- Removes a spawn point by index
function remove_spawn_point(index)
    table.remove(spawn_points, index)
end

-- Edits an existing spawn point
function edit_spawn_point(index, new_data)
    if spawn_points[index] then
        for k, v in pairs(new_data) do
            spawn_points[index][k] = v
        end
    end
end

-- Sends the spawn points to the client
function sync_spawn_points()
    net.Start("SyncSpawnPoints")
    net.WriteTable(spawn_points)
    net.Send() -- Send to all clients; adjust as needed
end

-- Command bindings
concommand.Add("add_spawn_point", function(ply, cmd, args)
    -- Add example spawn point; in practice, validate args
    add_spawn_point(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), tonumber(args[4]), args[5])
    sync_spawn_points()
end)

concommand.Add("remove_spawn_point", function(ply, cmd, args)
    -- Remove by index; in practice, validate args
    remove_spawn_point(tonumber(args[1]))
    sync_spawn_points()
end)

-- Net message setup
util.AddNetworkString("SyncSpawnPoints")