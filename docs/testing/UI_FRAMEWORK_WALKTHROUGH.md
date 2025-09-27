# UI Framework Manual Testing Walkthrough

## Overview
This document provides a comprehensive manual testing guide for the UI framework implemented in Stage 2 Task 2. The framework includes scene management, navigation, theming, and input handling.

## Architecture Summary
- **Main Scene**: Persistent container (`scenes/main/main.tscn`)
- **Game Controller**: Manages all game state (`scripts/controllers/game_controller.gd`)
- **UI Manager**: Handles scene transitions and windows (`scripts/ui/ui_manager.gd`)
- **UI Scenes**: Swappable children (main menu, game UI)

## Prerequisites
- Game compiled and ready to run
- No additional setup required
- All systems initialized automatically

---

## 🎮 MAIN TEST SEQUENCE

### Phase 1: Application Startup
**Expected**: Main menu appears with proper layout

**Steps**:
1. Launch the game
2. Verify main menu loads correctly

**✅ Pass Criteria**:
- Dark blue background appears
- "Creature Collection Game" title visible
- Four buttons present: New Game, Load Game, Settings, Quit
- Focus on "New Game" button

**❌ Fail Indicators**:
- Black screen or crash
- Missing UI elements
- Error messages in console

---

### Phase 2: Basic Navigation Testing
**Expected**: All navigation methods work correctly

#### Test 2.1: Keyboard Navigation
**Steps**:
1. Press `Tab` → Focus moves to "Load Game"
2. Press `Tab` again → Focus moves to "Settings"
3. Press `Shift+Tab` → Focus moves back to "Load Game"
4. Press `Enter` or `Space` → Load Game activates

**✅ Pass Criteria**:
- Focus visually moves between buttons
- Enter/Space activates focused button
- Keyboard navigation is smooth

#### Test 2.2: Mouse Navigation
**Steps**:
1. Click each button in sequence
2. Verify buttons respond to clicks

**✅ Pass Criteria**:
- Buttons highlight on hover
- Click actions execute

---

### Phase 3: Scene Transitions
**Expected**: Smooth transitions between main menu and game UI

#### Test 3.1: New Game Flow
**Steps**:
1. From main menu, click "New Game"
2. Verify transition to game UI
3. Press `Escape`
4. Verify return to main menu

**✅ Pass Criteria**:
- Scene transitions are smooth (fade effect)
- Game UI loads with proper layout
- Escape key returns to main menu
- No visual glitches during transitions

#### Test 3.2: Load Game Flow
**Steps**:
1. From main menu, click "Load Game"
2. Check console for load messages
3. Verify transition to game UI (if successful)

**✅ Pass Criteria**:
- Console shows: "MainMenu: Loading game"
- Console shows: "SaveSystem: Game state loaded from 'default'"
- Transitions to game UI (even with empty save)

---

### Phase 4: Game UI Testing
**Expected**: All game UI elements display and function correctly

#### Test 4.1: Layout Verification
**Steps**:
1. Navigate to game UI (New Game or Load Game)
2. Verify layout elements

**✅ Pass Criteria**:
- **Top Bar**: Menu button (left), "Week 1" (center), "Gold: 100" (right)
- **Left Panel**: "Active Creatures" label with empty list
- **Bottom Bar**: Collect, Shop, Quest buttons
- **Main Area**: Central content area with placeholder text

#### Test 4.2: UI Interactions
**Steps**:
1. Click "Menu" button → Should return to main menu
2. Navigate back to game UI
3. Click each bottom bar button (Collect, Shop, Quest)

**✅ Pass Criteria**:
- Menu button works correctly
- Bottom buttons respond (expect error messages for Shop/Quest)
- Console shows button press confirmations

---

### Phase 5: Global Input Testing
**Expected**: All keyboard shortcuts work from any screen

#### Test 5.1: Save/Load System
**Steps**:
1. From game UI, press `Ctrl+S`
2. Press `Ctrl+L`
3. Check console output

**✅ Pass Criteria**:
- Console shows: "Save game input detected!"
- Console shows: "Save result: true"
- Console shows: "Load game input detected!"
- Console shows: "Load result: true"

#### Test 5.2: Time System
**Steps**:
1. From game UI, note current week display
2. Press `Space` (advance time)
3. Verify week number increases

**✅ Pass Criteria**:
- Console shows: "Advance time input detected (Space key)!"
- Console shows: "Time advance result: true"
- Week display updates (Week 1 → Week 2)

#### Test 5.3: Window System
**Steps**:
1. From game UI, press `S` (shop)
2. Press `C` (creatures)
3. Press `Q` (quests)

**✅ Pass Criteria**:
- Console shows input detection
- Console shows expected error: "UIManager: Window 'shop' not registered"
- Same error pattern for creatures and quests

#### Test 5.4: Fullscreen Toggle
**Steps**:
1. Press `F11`
2. Verify fullscreen mode
3. Press `F11` again
4. Verify return to windowed mode

**✅ Pass Criteria**:
- Console shows: "Fullscreen toggle detected (F11)!"
- Window mode changes appropriately
- UI scales correctly in fullscreen

#### Test 5.5: Universal Menu Access
**Steps**:
1. From any screen (game UI), press `Escape`
2. Verify return to main menu

**✅ Pass Criteria**:
- Console shows: "Menu input detected (Escape key)!"
- Returns to main menu from anywhere

---

### Phase 6: Error Handling
**Expected**: Graceful handling of unimplemented features

#### Test 6.1: Settings Window
**Steps**:
1. From main menu, click "Settings"

**✅ Pass Criteria**:
- Console shows: "MainMenu: Opening settings"
- Console shows error: "UIManager: Window 'settings' not registered"
- Application doesn't crash

#### Test 6.2: Window Operations
**Steps**:
1. Try Shop/Quest buttons from game UI
2. Try S/C/Q hotkeys

**✅ Pass Criteria**:
- Error messages appear but don't crash
- User understands features aren't implemented yet

---

## 🚨 CRITICAL FAILURE POINTS

**Immediate Failure** (Stop testing):
- Application crashes on startup
- Main menu doesn't load
- Scene transitions cause crashes
- Save/load system throws errors

**Minor Issues** (Continue testing):
- Visual glitches in transitions
- Missing hover effects
- Console warnings (non-error)

---

## 📊 PERFORMANCE EXPECTATIONS

**Target Metrics**:
- Scene transitions: < 300ms
- Input response: < 50ms
- Memory usage: Stable (no leaks)
- 60 FPS maintained

**Performance Test**:
1. Transition between screens 10 times rapidly
2. Press hotkeys repeatedly
3. Monitor for slowdowns or memory growth

---

## 🔍 CONSOLE OUTPUT REFERENCE

**Normal Operation**:
```
SignalBus initialized with enhanced signal management
GameCore initialized
Main scene loaded successfully
Loaded system: ui
```

**Save/Load Operations**:
```
Save game input detected!
SaveSystem: Game state saved to 'default' in Xms
Save result: true
```

**Time Advancement**:
```
Advance time input detected (Space key)!
Time advance result: true
```

**Expected Errors** (Not failures):
```
UIManager: Window 'shop' not registered
UIManager: Window 'settings' not registered
```

---

## ✅ SUCCESS CRITERIA SUMMARY

**Core Functionality**:
- [x] Main menu navigation works
- [x] Scene transitions function
- [x] Game UI displays correctly
- [x] Save/load system operational
- [x] Time system advances
- [x] Input handling complete
- [x] Error handling graceful

**User Experience**:
- [x] Intuitive navigation
- [x] Responsive controls
- [x] Clear visual feedback
- [x] Stable performance

**Architecture**:
- [x] Clean separation of concerns
- [x] Proper controller pattern
- [x] System integration working
- [x] Extensible for future features

---

## 📝 TESTING NOTES

**Date**: ___________
**Tester**: ___________
**Build**: ___________

**Issues Found**:
- [ ] None
- [ ] Minor: ________________________________
- [ ] Major: ________________________________
- [ ] Critical: ____________________________

**Overall Assessment**:
- [ ] ✅ Pass - Ready for next stage
- [ ] ⚠️  Minor issues - Acceptable with notes
- [ ] ❌ Major issues - Requires fixes
- [ ] 🚨 Critical failure - Stop development

**Additional Notes**:
_________________________________________________
_________________________________________________
_________________________________________________