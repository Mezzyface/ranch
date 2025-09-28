# Testing Instructions: Task 3.3 - Facility as Main View

## Quick Validation Commands

### 1. System Validation (Required First)
```bash
# Validate project files
"C:\Program Files\Godot\Godot.exe" --check-only project.godot

# Run preflight check to ensure all systems working
"C:\Program Files\Godot\Godot.exe" --headless --scene tests/preflight_check.tscn
```
**Expected**: No errors, all checks should pass with "✅ ALL CHECKS PASSED"

### 2. Individual Component Tests
```bash
# Test facility system integration
"C:\Program Files\Godot\Godot.exe" --headless --scene tests/individual/test_facility.tscn

# Test main scene loading
"C:\Program Files\Godot\Godot.exe" --headless --scene scenes/main/main.tscn --quit-after 3

# Test overlay menu directly
"C:\Program Files\Godot\Godot.exe" --headless --scene scenes/ui/overlay_menu.tscn --quit-after 3

# Test facility view directly
"C:\Program Files\Godot\Godot.exe" --headless --scene scenes/ui/facility_view.tscn --quit-after 3
```
**Expected**: All scenes should load without errors and show system initialization messages.

## Interactive Testing (Visual)

### 3. Full Game Flow Test
```bash
# Launch the full game
"C:\Program Files\Godot\Godot.exe" --scene scenes/main/main.tscn
```

#### Test Sequence:
1. **Main Menu Launch**
   - ✅ Main menu should appear
   - ✅ Navigation buttons should be visible: New Game, Load Game, Collection, Settings, Quit

2. **Start New Game**
   - Click "New Game" button
   - ✅ Should transition to overlay menu interface
   - ✅ Should see sidebar with: Facilities, Shop, Inventory, Stable, Menu
   - ✅ Should see header with: "Year 0 Week 0" and "500 Gold"
   - ✅ Should see facility view in main content area

3. **Verify Facility View Integration**
   - ✅ Main content area should show "Training Facilities" title
   - ✅ Should see facility cards (initially locked)
   - ✅ Each facility card should have unlock/assign buttons

4. **Test Navigation Buttons**
   - Click "Facilities" button → ✅ Should reload/refresh facility view
   - Click "Shop" button → ✅ Should print "Shop button pressed" (not implemented yet)
   - Click "Inventory" button → ✅ Should print "Inventory button pressed" (not implemented yet)
   - Click "Stable" button → ✅ Should print "Stable button pressed" (not implemented yet)
   - Click "Menu" button → ✅ Should return to main menu

5. **Test Load Game Flow**
   - From main menu, click "Load Game"
   - ✅ Should transition to overlay menu (same as New Game)
   - ✅ Game state should be loaded if save exists

6. **Test Collection Flow**
   - From main menu, click "Collection"
   - ✅ Should transition to overlay menu with facility view

### 4. Status Display Testing
When in overlay menu:
- ✅ Time display should show "Year 0 Week 1" format
- ✅ Gold display should show "500 Gold" (not "0 Gold")
- ✅ Displays should update when game state changes

### 5. Facility Lock/Unlock Testing
- ✅ Training Gym should appear unlocked (no overlay, shows "Assign" button)
- ✅ Study Library should appear locked (dark overlay with "🔒 500 g Unlock" button)
- ✅ Click "Unlock" button on Study Library:
  - Should deduct 500 gold (display updates to "0 Gold")
  - Should remove lock overlay
  - Should show "Assign" button
  - Should display "Facility unlocked!" notification

### 6. Keyboard Shortcuts (if implemented)
- Press `Escape` → ✅ Should return to main menu
- Press `S` → ✅ Should trigger shop functionality
- Press `C` → ✅ Should trigger collection functionality
- Press `Space` → ✅ Should advance time
- Press `F11` → ✅ Should toggle fullscreen

## Troubleshooting

### Common Issues:

**"Scene not found" errors**
- Ensure all .tscn files exist in `scenes/ui/` directory
- Check that overlay_menu.tscn has the controller script attached

**"System not found" errors**
- Run preflight check first to verify all systems are loading
- Check GameCore initialization in console output

**Navigation not working**
- Verify overlay_menu_controller.gd is attached to overlay_menu.tscn
- Check button connections in overlay menu scene

**Blank game area**
- Check that facility_view.tscn loads correctly in isolation
- Verify GameController reference is being passed correctly

### Debug Console Output
Look for these messages when testing:

**Successful startup:**
```
SignalBus initialized with enhanced signal management
GameCore initialized
Main scene loaded successfully
ResourceTracker initialized with 500 starting gold
FacilitySystem initialized
FacilitySystem: Loaded 2 facilities
```

**Successful navigation:**
```
OverlayMenu: Facilities button pressed
OverlayMenu: Menu button pressed
MainMenu: Starting new game
```

**System errors (should NOT appear):**
```
ERROR: UIManager: Scene path cannot be empty
ERROR: FacilityViewController: FacilitySystem not found
ERROR: Cannot find system 'facility'
```

## Performance Benchmarks

During testing, check console for performance messages:
- Weekly updates: `<200ms`
- Facility processing: `<50ms`
- Scene transitions: Should be instant

## Files to Verify Exist

Before testing, ensure these files are present:
- ✅ `scripts/ui/overlay_menu_controller.gd`
- ✅ `scenes/ui/overlay_menu.tscn` (with script attached)
- ✅ `scenes/ui/facility_view.tscn`
- ✅ `docs/ui/TASK_3_3_FACILITY_MAIN_VIEW.md`

## Success Criteria

The implementation is successful if:
1. ✅ All validation commands pass without errors
2. ✅ Main menu navigates to overlay interface (not direct facility view)
3. ✅ Overlay menu shows navigation sidebar + facility content
4. ✅ All navigation buttons respond (even if some say "not implemented")
5. ✅ Status displays (time/gold) show correct values and update correctly
6. ✅ Menu button returns to main menu
7. ✅ No console errors during normal operation
8. ✅ Facility view displays properly in GameArea
9. ✅ Training Gym appears unlocked, Study Library appears locked
10. ✅ Unlock button on Study Library is clickable and functional
11. ✅ Gold deduction and facility unlock works end-to-end

## Reporting Issues

If any test fails, provide:
1. Which test step failed
2. Console error messages (if any)
3. Expected vs actual behavior
4. Screenshot of issue (if visual)