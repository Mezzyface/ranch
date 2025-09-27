# Training System UI Test Walkthrough

This walkthrough tests the new GameController architecture and training system integration. Follow these steps to verify everything works correctly.

## Quick Start Test

### 1. Launch the Game
```bash
godot --scene scenes/main/main.tscn
```
OR run from Godot editor: **Play Scene** → `scenes/main/main.tscn`

### 2. Initial State Verification
**Upon launch, you should see:**
- Main game UI with bottom action buttons
- 8 test creatures automatically created
- 500 starting gold
- 5 of each training food type in inventory

**✅ Success Criteria:**
- No console errors
- UI loads completely
- Creatures visible in side panel

---

## Core UI Flow Test

### Test 1: Access Training Panel
1. **Click "Training" button** (bottom action bar)
2. **Verify Training Panel Opens** with 4 main sections:
   - **Top Left**: Facilities (4 training types)
   - **Top Right**: Controls (food, creatures, activities)
   - **Bottom Left**: Training Schedule
   - **Bottom Right**: Training Progress

**✅ Expected Results:**
- Panel opens smoothly
- All UI sections populated
- Console shows: `"TrainingPanelController initialized"`

### Test 2: Creature Selection
1. **Look at creature list** (top right panel)
2. **Verify creature display format**: `"Name (species) [STATUS] (+FOOD%)"`
3. **Click on a creature**
4. **Console should show**: `"Selected creature: [creature_id]"`

**✅ Success Criteria:**
- Creatures show with proper formatting
- Selection works (console confirmation)
- No duplicate names/IDs

### Test 3: Food System Integration
1. **Select a creature** from the list
2. **Click "Power Bar" button**
3. **Verify changes:**
   - Button text updates: `"Power Bar (4 available)"`
   - Creature list updates: `"Name (species) (+50% Power Bar)"`
   - Console shows: `"Consumed Power Bar for creature [id]"`

**Test Different Food Types:**
- **Speed Snack**: For agility training boost
- **Brain Food**: For mental training boost
- **Focus Tea**: For discipline training boost

**✅ Success Criteria:**
- Food consumption works
- UI updates automatically via signals
- Only one food effect per creature (latest overwrites)

---

## Training Workflow Test

### Test 4: Schedule Training
1. **Select a creature** (must have >10 stamina)
2. **Select activity**: Click "Physical Training" button
   - Button should highlight **green**
3. **Click "Schedule Training"**

**✅ Expected Results:**
- Console: `"Training scheduled successfully"`
- Training appears in **Schedule panel** as `"QUEUED: CreatureName - Physical Training"`
- Facility capacity updates: `"Capacity: 1/10"`
- Creature status shows `"[SCHEDULED]"`

### Test 5: Time Progression
1. **Schedule 2-3 trainings** for different creatures
2. **Click "Next Week"** button (bottom action bar)
3. **Verify queue changes**:
   - Queued → `"ACTIVE: CreatureName - Activity (1 weeks left)"`
4. **Click "Next Week" again**
5. **Verify completion**:
   - Active → `"COMPLETED: CreatureName - Activity (STR +8, CON +12)"`

**✅ Success Criteria:**
- Weekly progression works correctly
- Status updates automatically
- Stat gains displayed in completion

---

## Signal Integration Test

### Test 6: Real-Time Updates
1. **Open Training panel**
2. **Schedule a training**
3. **Switch to Collection panel** (click "Collect")
4. **Move creatures between active/stable**
5. **Return to Training panel**

**✅ Expected Results:**
- Training panel refreshes automatically
- Only active creatures available for training
- No manual refresh needed

### Test 7: Cross-Panel Communication
1. **In Training panel**: Consume food for a creature
2. **Switch to Shop panel**: Check if gold/inventory updated
3. **Return to Training**: Verify food counts still correct

**✅ Success Criteria:**
- Changes propagate across all panels
- Resource tracking consistent
- No data loss between panel switches

---

## Error Handling Test

### Test 8: Validation Testing
**Test Invalid Operations:**
1. **No creature selected** → Click "Schedule Training"
   - Expected: `"No creature selected"`
2. **No activity selected** → Select creature, click "Schedule Training"
   - Expected: `"No training activity selected"`
3. **Low stamina creature** → Schedule training for exhausted creature
   - Expected: `"Insufficient stamina for training"`
4. **Double booking** → Schedule same creature twice
   - Expected: `"Creature already in training"`

**✅ Success Criteria:**
- All error messages display correctly
- No crashes or silent failures
- UI remains responsive

---

## Performance Test

### Test 9: Batch Operations
1. **Schedule maximum trainings** (fill all facility slots)
2. **Advance multiple weeks rapidly** (click "Next Week" 5-10 times)
3. **Monitor console for performance logs**

**✅ Performance Targets:**
- Training processing: `<100ms`
- UI updates: No lag or freezing
- Console shows: `"AI_NOTE: performance(process_weekly_training) = [X]ms"`

---

## Architecture Verification

### Test 10: Console Output Verification
**Expected Console Messages:**
```
GameController initialized
TrainingPanelController initialized
Training scheduled: [Creature] - [Activity] at [Facility]
GameUI: Training data updated - refreshing training panel
Selected creature: [creature_id]
Consumed [Food] for creature [creature_id]
```

**✅ Architecture Success:**
- No direct system access errors
- All updates through GameController signals
- Proper data flow: UI → GameController → Systems

---

## Quick Smoke Test (5 minutes)

**If short on time, test these critical paths:**

1. **Launch game** → **Click Training** → Panel opens ✅
2. **Select creature** → **Click food** → Food consumed ✅
3. **Select activity** → **Schedule training** → Training queued ✅
4. **Next Week** → **Next Week** → Training completed ✅
5. **Check stats** → Verify gains applied ✅

---

## Troubleshooting

### Common Issues & Solutions

**Training Panel Won't Open:**
- Check console for script errors
- Verify GameController is initialized
- Check scene tree structure

**Food Buttons Disabled:**
- Verify starting inventory (should have 5 of each)
- Check ResourceTracker initialization
- Look for inventory deduction errors

**Training Won't Schedule:**
- Verify creature selection (should see creature ID in console)
- Check creature stamina levels
- Verify facility capacity available

**UI Not Updating:**
- Check GameController signal connections
- Verify training panel `set_game_controller()` called
- Look for signal emission in console

### Debug Console Commands
```gdscript
# Check system status
print(GameCore.get_system("training"))
print(GameCore.get_system("food"))

# Check GameController
print(game_controller.get_training_data())
print(game_controller.get_food_inventory())
```

---

## Success Criteria Summary

**✅ All Tests Pass When:**
- Training panel opens and displays correctly
- Food system integrates seamlessly
- Training scheduling and progression works
- Real-time updates via signals function
- Error handling is robust
- Performance meets targets (<100ms)
- No direct system access from UI
- GameController mediates all interactions

**🎯 Ready for Production When:**
- All 10 tests pass completely
- No console errors during normal operation
- UI remains responsive during batch operations
- Data consistency maintained across panels

This walkthrough validates the complete Training System UI integration with proper MVC architecture!