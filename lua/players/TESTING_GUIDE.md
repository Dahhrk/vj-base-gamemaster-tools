# Objectives System - Testing Guide

This guide helps you test the objectives system implementation.

## Prerequisites

1. Garry's Mod server or local game
2. Admin privileges on the server
3. VJ Base Gamemaster Tools installed

## Manual Testing Steps

### 1. Test Chat Command Access

**As Admin:**
1. Join the server as admin
2. Type `!objectives` in chat
3. **Expected:** Objectives Manager window opens
4. **Expected:** Chat message is suppressed (doesn't appear in chat)

**As Non-Admin:**
1. Join the server without admin privileges
2. Type `!objectives` in chat
3. **Expected:** Message appears: "You don't have permission to access the Objectives Menu."
4. **Expected:** No UI window opens

### 2. Test Adding Objectives

1. Open the Objectives Manager (`!objectives`)
2. Click "+ Add Objective" button
3. Enter a title: "Test Objective 1"
4. Enter a description: "This is a test objective"
5. Click "Add Objective"
6. **Expected:** Dialog closes
7. **Expected:** New objective card appears in the manager
8. **Expected:** All players see the objective in their display panel

### 3. Test Editing Objectives

1. Click "Edit" on an existing objective
2. Change the title to "Updated Test Objective"
3. Change the description to "Updated description"
4. Click "Save Changes"
5. **Expected:** Objective updates in the manager
6. **Expected:** All players see the updated objective

### 4. Test Completion Toggle

1. Click "Mark Complete" on an objective
2. **Expected:** Button changes to "Mark Incomplete"
3. **Expected:** Status bar turns green
4. **Expected:** Players see checkmark on completed objective
5. Click "Mark Incomplete"
6. **Expected:** Reverts to incomplete state

### 5. Test Visibility Toggle

1. Click "Hide" on an objective
2. **Expected:** Red indicator appears on the card
3. **Expected:** Players no longer see this objective
4. **Expected:** Objective still visible to admins in manager
5. Click "Show"
6. **Expected:** Objective becomes visible to players again

### 6. Test Delete Functionality

1. Click "Delete" on an objective
2. **Expected:** Confirmation dialog appears
3. Click "Delete" in the dialog
4. **Expected:** Objective removed from manager
5. **Expected:** Objective removed from all player displays

### 7. Test Real-Time Sync

1. Have two players connect (one admin, one regular player)
2. Admin opens Objectives Manager
3. Admin adds a new objective
4. **Expected:** Both players immediately see the objective
5. Admin toggles completion
6. **Expected:** Both players see the status change
7. Admin hides the objective
8. **Expected:** Regular player's display updates, admin still sees it

### 8. Test Player Display Panel

**Auto-Show/Hide:**
1. Start with no objectives
2. **Expected:** No display panel visible to players
3. Admin adds a visible objective
4. **Expected:** Panel appears automatically
5. Admin hides all objectives
6. **Expected:** Panel disappears

**Toggle Command:**
1. Type `vjgm_objectives_toggle` in console
2. **Expected:** Panel visibility toggles

### 9. Test Console Command

1. Type `vjgm_objectives` in console
2. **Expected:** Objectives Manager opens (if admin)

### 10. Test Persistence Across Reconnects

1. Create several objectives
2. Disconnect and reconnect
3. **Expected:** Objectives are synced to you on reconnect
4. **Expected:** Display panel shows visible objectives

## Server Console Testing

You can also test the backend API from the server console:

```lua
-- Add an objective
VJGM.Objectives.Add("Console Test", "Created from console")

-- Edit an objective (replace 1 with actual ID)
VJGM.Objectives.Edit(1, "Updated Title", "Updated Description")

-- Toggle completion
VJGM.Objectives.ToggleComplete(1)

-- Toggle visibility
VJGM.Objectives.ToggleVisibility(1)

-- Delete an objective
VJGM.Objectives.Delete(1)

-- Get all objectives
PrintTable(VJGM.Objectives.GetAll())

-- Sync to all players
VJGM.Objectives.SyncToAll()
```

## Common Issues and Solutions

### Issue: Chat command doesn't work
- **Solution:** Ensure all files are in `lua/players/` directory
- **Solution:** Restart the server/game

### Issue: UI doesn't open
- **Solution:** Check console for errors
- **Solution:** Ensure you have admin privileges

### Issue: Objectives don't sync
- **Solution:** Check server console for network errors
- **Solution:** Ensure all network strings are registered

### Issue: Player display doesn't show
- **Solution:** Wait 2 seconds after joining (initialization delay)
- **Solution:** Check if objectives are visible (not hidden)

## Expected Console Output

When working correctly, you should see:
```
[VJGM] Objectives Manager initialized
[VJGM] Objectives Command Handler initialized
[VJGM] Objectives UI initialized
[VJGM] Objectives Display initialized
```

When actions are performed:
```
[VJGM] Objective added: Test Objective
[VJGM] PlayerName opened the Objectives Menu
[VJGM] Objective edited: Test Objective
[VJGM] Objective completed: Test Objective
[VJGM] Objective visibility enabled: Test Objective
[VJGM] Objective deleted: Test Objective
```

## Performance Testing

Create multiple objectives to test performance:
1. Create 10-20 objectives
2. Toggle visibility on several
3. Mark some as complete
4. **Expected:** UI remains responsive
5. **Expected:** No lag when syncing

## Security Testing

1. Try to use objectives commands as non-admin
2. **Expected:** All requests blocked with console message
3. **Expected:** "Unauthorized attempt" messages in server console

## Success Criteria

✅ Chat command opens UI for admins only
✅ Add/Edit/Delete operations work correctly
✅ Completion toggle works and syncs to players
✅ Visibility toggle controls player view
✅ Real-time sync to all connected players
✅ Player display shows/hides automatically
✅ No console errors during normal operation
✅ Permission checks prevent unauthorized access
