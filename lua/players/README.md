# Player-Related Scripts

This folder contains player-related Lua scripts for the VJ Base Gamemaster Tools.

## Objectives System

The objectives system allows gamemasters to create, manage, and display mission objectives to players in real-time.

### Features

- **!objectives Command**: Gamemasters can type `!objectives` in chat to open the Objectives Manager
- **Objectives Manager UI**: Full-featured interface for adding, editing, deleting, and managing objectives
- **Real-Time Sync**: Changes are immediately synced to all connected players
- **Player Display**: Players see a clean, minimal panel showing active objectives
- **Permission-Based**: Only admins can manage objectives (configurable with OpenPermissions)

### Files

- **objectives_manager.lua** (Server): Backend logic for managing objectives and network sync
- **objectives_command.lua** (Server): Chat command handler for !objectives
- **objectives_ui.lua** (Client): Gamemaster interface for managing objectives
- **objectives_display.lua** (Client): Player-facing objectives display panel

### Usage

#### For Gamemasters

1. Type `!objectives` in chat to open the Objectives Manager
2. Click "+ Add Objective" to create a new objective
3. Fill in the title and description
4. Use the buttons on each objective card to:
   - **Edit**: Modify the title or description
   - **Mark Complete/Incomplete**: Toggle completion status
   - **Show/Hide**: Control visibility to players
   - **Delete**: Remove the objective

#### For Players

Players will automatically see visible objectives in a panel on the right side of their screen. The panel shows:
- Objective title and description
- Completion status (checkmark for completed)
- Color-coded indicators

#### Console Commands

- `vjgm_objectives` - Open the Objectives Manager (admins only)
- `vjgm_objectives_toggle` - Toggle the player objectives display

### Permission System

By default, only server admins can manage objectives. The system checks:
1. `ply:IsAdmin()` - Standard admin check
2. OpenPermissions (if available) - Custom permission: `objectives`

### Network Messages

The system uses the following network messages for real-time synchronization:
- `VJGM_ObjectivesSync` - Syncs all objectives to clients
- `VJGM_ObjectiveAdd` - Request to add a new objective
- `VJGM_ObjectiveEdit` - Request to edit an objective
- `VJGM_ObjectiveDelete` - Request to delete an objective
- `VJGM_ObjectiveToggleComplete` - Toggle completion status
- `VJGM_ObjectiveToggleVisibility` - Toggle visibility to players
- `VJGM_OpenObjectivesMenu` - Triggers the UI to open on client

### Examples

```lua
-- Server-side: Programmatically add an objective
VJGM.Objectives.Add("Secure the Area", "Eliminate all hostile NPCs in the sector")

-- Server-side: Mark an objective as complete
VJGM.Objectives.ToggleComplete(1)

-- Server-side: Hide an objective from players
VJGM.Objectives.ToggleVisibility(1)
```