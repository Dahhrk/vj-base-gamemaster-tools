# Objectives System - Developer Guide

This guide provides technical details for developers who want to extend or integrate with the objectives system.

## Architecture Overview

The objectives system consists of four main components:

1. **objectives_manager.lua** (Server) - Backend data management and network handling
2. **objectives_command.lua** (Server) - Chat command hook
3. **objectives_ui.lua** (Client) - Gamemaster management interface
4. **objectives_display.lua** (Client) - Player objectives display

## File Loading Order

The system is designed to be resilient to load order, but the recommended order is:

1. `objectives_manager.lua` - Initializes VJGM.Objectives namespace
2. `objectives_command.lua` - Registers chat command (with safety checks)
3. `objectives_ui.lua` - Sets up client UI handlers
4. `objectives_display.lua` - Initializes player display

## API Reference

### Server-Side API (VJGM.Objectives)

#### VJGM.Objectives.Add(title, description)
Creates a new objective and syncs to all clients.

```lua
local objID = VJGM.Objectives.Add("Secure the Area", "Eliminate all hostiles")
print("Created objective with ID: " .. objID)
```

**Parameters:**
- `title` (string): Objective title
- `description` (string): Objective description

**Returns:** 
- `number`: The ID of the created objective

#### VJGM.Objectives.Edit(id, title, description)
Modifies an existing objective.

```lua
VJGM.Objectives.Edit(1, "Updated Title", "Updated Description")
```

**Parameters:**
- `id` (number): Objective ID
- `title` (string, optional): New title
- `description` (string, optional): New description

**Returns:**
- `boolean`: Success status

#### VJGM.Objectives.Delete(id)
Removes an objective.

```lua
VJGM.Objectives.Delete(1)
```

**Parameters:**
- `id` (number): Objective ID

**Returns:**
- `boolean`: Success status

#### VJGM.Objectives.ToggleComplete(id)
Toggles completion status.

```lua
VJGM.Objectives.ToggleComplete(1)
```

**Parameters:**
- `id` (number): Objective ID

**Returns:**
- `boolean`: Success status

#### VJGM.Objectives.ToggleVisibility(id)
Toggles visibility to players.

```lua
VJGM.Objectives.ToggleVisibility(1)
```

**Parameters:**
- `id` (number): Objective ID

**Returns:**
- `boolean`: Success status

#### VJGM.Objectives.GetAll()
Returns all objectives.

```lua
local objectives = VJGM.Objectives.GetAll()
PrintTable(objectives)
```

**Returns:**
- `table`: All objectives indexed by ID

#### VJGM.Objectives.Get(id)
Returns a specific objective.

```lua
local obj = VJGM.Objectives.Get(1)
if obj then
    print(obj.title)
end
```

**Parameters:**
- `id` (number): Objective ID

**Returns:**
- `table`: Objective data or nil

#### VJGM.Objectives.IsAuthorized(ply)
Checks if a player can manage objectives.

```lua
if VJGM.Objectives.IsAuthorized(ply) then
    -- Allow access
end
```

**Parameters:**
- `ply` (Player): Player entity

**Returns:**
- `boolean`: Authorization status

#### VJGM.Objectives.SyncToAll()
Manually sync objectives to all clients.

```lua
VJGM.Objectives.SyncToAll()
```

#### VJGM.Objectives.SyncToPlayer(ply)
Sync objectives to a specific player.

```lua
VJGM.Objectives.SyncToPlayer(ply)
```

**Parameters:**
- `ply` (Player): Player entity

### Client-Side API

#### VJGM.ObjectivesUI.OpenMenu()
Opens the objectives manager UI.

```lua
VJGM.ObjectivesUI.OpenMenu()
```

#### VJGM.ObjectivesDisplay.Update(objectives)
Updates the player display with new objectives data.

```lua
VJGM.ObjectivesDisplay.Update(objectivesTable)
```

**Parameters:**
- `objectives` (table): Objectives data

#### VJGM.ObjectivesDisplay.Toggle()
Toggles visibility of the player display.

```lua
VJGM.ObjectivesDisplay.Toggle()
```

## Data Structure

### Objective Object

```lua
{
    id = 1,                    -- Unique identifier
    title = "Objective Title", -- Display title
    description = "Details",   -- Description text
    completed = false,         -- Completion status
    visible = true            -- Visibility to players
}
```

## Network Messages

### Server → Client

- **VJGM_ObjectivesSync**: Syncs all objectives (sends table)
- **VJGM_OpenObjectivesMenu**: Triggers UI to open

### Client → Server

- **VJGM_RequestObjectives**: Request current objectives
- **VJGM_ObjectiveAdd**: Request to add objective (title, description)
- **VJGM_ObjectiveEdit**: Request to edit (id, title, description)
- **VJGM_ObjectiveDelete**: Request to delete (id)
- **VJGM_ObjectiveToggleComplete**: Toggle completion (id)
- **VJGM_ObjectiveToggleVisibility**: Toggle visibility (id)

## Hooks

### Server Hooks

- **PlayerSay** ("VJGM_ObjectivesCommand"): Handles !objectives command
- **PlayerInitialSpawn** ("VJGM_ObjectivesSync"): Syncs objectives to new players

### Client Hooks

- **InitPostEntity** ("VJGM_ObjectivesDisplay_Init"): Initializes player display

## Extending the System

### Adding Custom Permission Checks

Edit `objectives_manager.lua`, function `IsAuthorized`:

```lua
function VJGM.Objectives.IsAuthorized(ply)
    if not IsValid(ply) then return false end
    
    -- Standard admin check
    if ply:IsAdmin() then return true end
    
    -- Add your custom check here
    if MyCustomPermissionSystem then
        if MyCustomPermissionSystem.HasPermission(ply, "objectives") then
            return true
        end
    end
    
    return false
end
```

### Adding Custom Objective Properties

1. Modify the Add function in `objectives_manager.lua`:

```lua
objectives[id] = {
    id = id,
    title = title or "New Objective",
    description = description or "",
    completed = false,
    visible = true,
    priority = 1,  -- Add custom property
    category = "main"  -- Add another custom property
}
```

2. Update network messages to include new properties
3. Update UI to display/edit new properties

### Integration Examples

#### Event System Integration

```lua
-- When an event completes, mark objective as complete
hook.Add("EventCompleted", "VJGM_ObjectiveIntegration", function(eventID)
    if eventID == "secure_area" then
        VJGM.Objectives.ToggleComplete(1)
    end
end)
```

#### NPC Wave Integration

```lua
-- Create objectives when waves start
hook.Add("WaveStarted", "VJGM_ObjectiveIntegration", function(waveID)
    local objID = VJGM.Objectives.Add(
        "Survive Wave " .. waveID,
        "Defeat all incoming NPCs"
    )
    -- Store objID to mark complete later
end)

-- Complete objective when wave ends
hook.Add("WaveCompleted", "VJGM_ObjectiveIntegration", function(waveID)
    -- Mark the corresponding objective as complete
    VJGM.Objectives.ToggleComplete(storedObjID)
end)
```

#### Custom UI Integration

```lua
-- Open objectives menu from your custom UI
local btn = vgui.Create("DButton")
btn.DoClick = function()
    VJGM.ObjectivesUI.OpenMenu()
end
```

## Performance Considerations

- Objectives are stored in memory (not persisted)
- Network sync is triggered on every change
- Player display updates automatically when objectives change
- Use `SyncToPlayer` instead of `SyncToAll` when targeting specific players

## Security Notes

1. All network messages include authorization checks
2. Only admins (or custom permissions) can modify objectives
3. Players can only view visible objectives
4. Unauthorized attempts are logged to server console

## Troubleshooting

### Objectives not syncing
- Check server console for "Objectives Manager initialized"
- Verify network messages are registered
- Ensure client files are loaded

### Chat command not working
- Check for "Objectives Command Handler initialized" in console
- Verify PlayerSay hook is registered
- Ensure VJGM.Objectives exists before hook runs

### UI not opening
- Check client console for errors
- Verify "VJGM_OpenObjectivesMenu" network message
- Check if player has permission

### Player display not showing
- Ensure objectives are visible (not hidden)
- Check if display initialized (2 second delay after join)
- Verify objectives were synced to client
