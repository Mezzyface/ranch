# UX Design Specification - Creature Collection Game

## 📋 Document Overview

This document outlines all user interface screens, workflows, and interactions needed for the creature collection/breeding game. The game is built for **desktop/PC** with a **1280x720** resolution and uses **mouse and keyboard** controls.

## 🎯 Core Game Loop & User Journey

**Primary Flow**: Quest → Analyze Collection → Shop/Train/Breed → Fulfill Quest → Rewards

1. Player receives quest with creature requirements
2. Player checks creature collection for matches
3. If no match: Shop for eggs, train existing creatures, or breed new ones
4. Player assigns creatures to fulfill quest
5. Player receives rewards and progresses

## 🖥️ Screen Categories & Priorities

### 🔴 **CRITICAL SCREENS (MVP Essential)**
Core gameplay screens needed for basic functionality.

### 🟡 **IMPORTANT SCREENS (Early Release)**
Screens that enhance core experience and add depth.

### 🟢 **ENHANCEMENT SCREENS (Future Updates)**
Nice-to-have screens for polish and advanced features.

---

## 📱 **SCREEN SPECIFICATIONS**

## 🔴 **CRITICAL SCREENS**

### 1. Main Menu
**Priority**: CRITICAL
**Purpose**: Game entry point and navigation hub

**Elements**:
- New Game button
- Load Game button
- Settings button
- Exit button
- Background art with creatures
- Game title/logo
- Save slot selection modal (when loading)

**Interactions**:
- Click buttons to navigate
- Hover effects on buttons
- Keyboard shortcuts (N for new, L for load, etc.)

---

### 2. Main Game View (Hub Screen)
**Priority**: CRITICAL
**Purpose**: Central gameplay hub where players make all major decisions

**Layout**: Dashboard-style interface with multiple panels

**Core Panels**:
- **Player Status Bar** (top): Gold, current week, active quest indicators
- **Quick Actions Bar**: Advance Time, Open Shop, Open Quests buttons
- **Active Creatures Panel** (left): 5 creature slots with portraits
- **Quest Summary Panel** (center): Current quest requirements and progress
- **Resource Panel** (bottom right): Food inventory quick view

**Elements**:
- Gold counter (e.g., "💰 1,250 Gold")
- Current week display (e.g., "Week 15")
- Advance Time button (large, prominent)
- Active quest name and basic requirements
- Creature portraits with health/stamina indicators
- Quick navigation buttons to all major screens

**Interactions**:
- Click creature portraits to open details
- Click Advance Time to progress game
- Click buttons to open other screens
- Hover tooltips for all interactive elements

---

### 3. Creature Collection Screen
**Priority**: CRITICAL
**Purpose**: Manage active and stable creatures, view stats and tags

**Layout**: Two-panel layout with filters

**Panels**:
- **Active Roster** (left): 5 slots for creatures that age and participate
- **Stable Collection** (right): Scrollable grid of all owned creatures
- **Filter Bar** (top): Filter by tags, species, stats, age

**Creature Display Cards**:
- Creature portrait/sprite
- Name and species
- Age category indicator
- Primary stats (STR, CON, DEX, INT, WIS, DIS)
- Tag icons
- Active/Stable state indicator

**Elements**:
- Drag-and-drop between Active and Stable
- Search bar for creature names
- Sort options (by stats, age, species)
- "Add New" button (leads to shop)
- Creature counter (e.g., "Active: 3/5, Stable: 12")

**Interactions**:
- Click creature cards to view detailed stats
- Drag creatures between panels
- Filter and search functionality
- Right-click for quick actions menu

---

### 4. Quest Journal
**Priority**: CRITICAL
**Purpose**: View available quests, requirements, and progress tracking

**Layout**: List-detail layout

**Quest List Panel** (left):
- Available quests
- Active quest (highlighted)
- Completed quests (collapsed section)
- Quest giver icons (Tim, etc.)

**Quest Detail Panel** (right):
- Quest title and description
- Detailed requirements with check boxes
- Reward information
- Accept/Complete buttons
- Progress indicators

**Quest Card Elements**:
- Quest giver portrait
- Quest title and brief description
- Difficulty indicator
- Reward preview (gold amount)
- Status indicator (Available, Active, Complete)

**Interactions**:
- Click quests to view details
- Accept quest button
- Complete quest button (when requirements met)
- Auto-validation of creature matches

---

### 5. Shop Interface
**Priority**: CRITICAL
**Purpose**: Purchase creature eggs and food items

**Layout**: Vendor-based tabs with product grid

**Vendor Tabs** (top):
- Armored Specialists Co.
- Aerial Dynamics Inc.
- BioLum Creatures Ltd.
- Food suppliers
- (More unlock over time)

**Product Grid**:
- Creature egg cards or food item cards
- Product image/icon
- Name and description
- Price and availability
- Guaranteed stats/tags for eggs
- Purchase button

**Shopping Cart**:
- Running total
- Quick purchase for single items
- Batch purchase option

**Elements**:
- Gold balance display
- Vendor descriptions and themes
- Unlock notifications for new vendors
- Purchase confirmation dialogs
- Inventory space warnings

**Interactions**:
- Tab switching between vendors
- Click to purchase items
- Hover for detailed tooltips
- Confirmation dialogs for expensive purchases

---

### 6. Training Assignment Screen
**Priority**: CRITICAL
**Purpose**: Assign weekly training activities to active creatures

**Layout**: Creature-centric assignment interface

**Creature Panels**: One panel per active creature showing:
- Creature portrait and stats
- Current age and stamina
- Training activity dropdown menu
- Food assignment dropdown
- Training effectiveness preview
- Assign button

**Training Activities** (dropdown options):
- Strength: Weight Lifting, Combat Practice, Heavy Labor, Boulder Pushing
- Constitution: Endurance Running, Exposure Training, Survival Challenges
- Dexterity: Agility Courses, Precision Tasks, Reaction Training
- Intelligence: Puzzle Solving, Learning Exercises, Cognitive Challenges
- Wisdom: Observation Exercises, Environmental Exposure, Alertness Drills
- Discipline: Obedience Training, Focus Exercises, Command Drills
- Rest: Recover stamina

**Elements**:
- Food effect indicators (+50% effectiveness, etc.)
- Stamina cost warnings
- Age modifier indicators (+20%, -20%)
- "Assign All" and "Clear All" buttons
- Training effectiveness calculator

**Interactions**:
- Dropdown selection for activities and food
- Preview of training outcomes
- Validation warnings (insufficient stamina, no food)
- Batch assignment tools

---

### 7. Time Progression Screen
**Priority**: CRITICAL
**Purpose**: Advance time and resolve weekly activities

**Layout**: Processing screen with results

**Phases**:
1. **Confirmation Phase**: "Ready to advance to Week X?" with summary
2. **Processing Phase**: Animated progress with activity descriptions
3. **Results Phase**: Show all outcomes and changes

**Activity Processing Display**:
- Each creature's assigned activity
- Animated progress bars
- Stat gain notifications
- Age progression indicators
- Food consumption confirmation

**Results Summary**:
- Stat changes for each creature
- Stamina updates
- Age progression
- Random events (if any)
- Resource consumption summary

**Elements**:
- Large "Advance Time" button
- Processing animations
- Result celebration effects
- Continue button to return to main view

**Interactions**:
- Confirmation before processing
- Skip animations option
- Click through results
- Return to main hub

---

## 🟡 **IMPORTANT SCREENS**

### 8. Creature Detail View
**Priority**: IMPORTANT
**Purpose**: In-depth view of individual creature stats, history, and options

**Layout**: Full-screen detailed view

**Sections**:
- **Portrait & Basic Info**: Large creature image, name, species, age
- **Stats Panel**: Detailed stats with progress bars and modifiers
- **Tags Panel**: All tags with descriptions and categories
- **History Panel**: Training history, quest participation, achievements
- **Actions Panel**: Rename, release, special actions

**Detailed Elements**:
- Stat breakdown with age modifiers shown
- Tag tooltips explaining benefits
- Training history with dates and gains
- Lineage information (parents, offspring)
- Performance in competitions and quests

**Interactions**:
- Edit creature name
- View tag descriptions
- Review history timeline
- Access breeding options (if adult)
- Release creature (with confirmation)

---

### 9. Competition Interface
**Priority**: IMPORTANT
**Purpose**: Enter creatures in weekly competitions for gold rewards

**Layout**: Competition-focused activity assignment

**Competition Categories**:
- Combat (Strength, Endurance challenges)
- Agility (Speed races, Obstacle courses)
- Intelligence (Logic tournaments, Strategy games)
- Awareness (Tracking contests, Guard trials)
- Discipline (Obedience trials, Service competitions)

**Competition Cards**:
- Competition type and description
- Primary and secondary stat requirements
- Entry fee and potential rewards
- Competition tier (Beginner, Intermediate, Advanced, Elite)
- Participant creature assignment

**Elements**:
- Creature performance predictor
- Entry fee warnings
- Reward tier breakdown
- Historical performance tracking
- Schedule of weekly competitions

**Interactions**:
- Select competitions for creatures
- Review competition requirements
- Confirm entries and pay fees
- View results after time advancement

---

### 10. Food Management Screen
**Priority**: IMPORTANT
**Purpose**: Manage food inventory and understand food effects

**Layout**: Inventory grid with food categories

**Food Categories** (tabs):
- Basic Foods (Grain, Hay, Berries)
- Training Foods (stat-specific bonuses)
- Premium Foods (powerful effects)
- Specialty Foods (breeding, competition)
- Exotic Foods (rare effects)

**Food Item Cards**:
- Food image/icon
- Name and description
- Effect description (+50% STR training)
- Quantity owned
- Price (if viewing in shop context)
- Usage recommendations

**Elements**:
- Inventory quantity indicators
- Food effect calculator
- Usage history and recommendations
- Shopping list functionality
- Food combinations warnings

**Interactions**:
- View detailed food effects
- Plan food assignments
- Shopping integration
- Usage tracking

---

### 11. Species Browser
**Priority**: IMPORTANT
**Purpose**: Learn about different creature species and their characteristics

**Layout**: Encyclopedia-style browser

**Species Cards**:
- Species artwork/sprite
- Name and classification
- Stat ranges and typical tags
- Habitat and behavior description
- Availability (shop, breeding, wild)
- Rarity indicator

**Filter Options**:
- By egg group (for breeding planning)
- By primary stats
- By available tags
- By rarity
- By acquisition method

**Elements**:
- Search functionality
- Favorites system
- Breeding compatibility checker
- Collection tracking (owned vs. total)
- Unlock progression indicators

**Interactions**:
- Browse species catalog
- Plan breeding combinations
- Check shop availability
- Mark favorites for easy reference

---

## 🟢 **ENHANCEMENT SCREENS**

### 12. Breeding Laboratory
**Priority**: ENHANCEMENT
**Purpose**: Advanced breeding interface with genetic preview

**Layout**: Lab-style interface with parent selection and offspring prediction

**Parent Selection**:
- Two creature selection slots
- Compatibility checker
- Breeding requirements validation
- Special breeding materials slot

**Offspring Preview**:
- Possible stat ranges
- Tag inheritance probabilities
- Genetic quality indicators
- Multiple outcome scenarios

**Elements**:
- Genetic algorithm visualization
- Breeding cost calculator
- Success probability indicators
- Breeding history and lineage trees
- Advanced breeding options

**Interactions**:
- Select parent creatures
- Add breeding materials
- Preview possible outcomes
- Confirm breeding process
- Review breeding history

---

### 13. Achievement Gallery
**Priority**: ENHANCEMENT
**Purpose**: Track player accomplishments and unlock rewards

**Layout**: Achievement grid with categories

**Achievement Categories**:
- Collection milestones
- Quest completion
- Training achievements
- Competition victories
- Breeding accomplishments
- Time-based milestones

**Achievement Cards**:
- Achievement icon and name
- Progress bar (if in progress)
- Description and requirements
- Reward information
- Unlock date
- Rarity indicator

**Elements**:
- Progress tracking
- Achievement notifications
- Reward claiming
- Social sharing options
- Statistics dashboard

**Interactions**:
- Browse achievement categories
- Track progress toward goals
- Claim achievement rewards
- View detailed statistics

---

### 14. Settings & Preferences
**Priority**: ENHANCEMENT
**Purpose**: Game configuration and customization options

**Categories**:
- **Display**: Resolution, fullscreen, UI scaling
- **Audio**: Master volume, music, sound effects
- **Gameplay**: Auto-save frequency, confirmation dialogs
- **Controls**: Keyboard shortcuts, mouse sensitivity
- **Accessibility**: Colorblind options, text size, screen reader

**Elements**:
- Slider controls for volumes
- Dropdown menus for display options
- Checkboxes for boolean settings
- Hotkey assignment interface
- Reset to defaults option

**Interactions**:
- Adjust all game settings
- Test audio/visual changes
- Customize controls
- Import/export settings

---

### 15. Statistics Dashboard
**Priority**: ENHANCEMENT
**Purpose**: Detailed game statistics and performance tracking

**Statistical Categories**:
- **Game Progress**: Total time played, weeks elapsed, quests completed
- **Collection Stats**: Creatures owned, species diversity, rarity distribution
- **Training Stats**: Total training sessions, stat improvements, efficiency
- **Economic Stats**: Gold earned/spent, shop purchases, quest rewards
- **Competition Stats**: Competitions entered, win rate, prize money

**Visualization**:
- Progress charts and graphs
- Comparison metrics
- Historical trends
- Achievement integration
- Export functionality

**Elements**:
- Interactive charts
- Date range selectors
- Category filters
- Comparison tools
- Export options

**Interactions**:
- Navigate through statistics
- Adjust time ranges and filters
- Export data or screenshots
- Compare performance over time

---

## 🎛️ **UI COMPONENTS & PATTERNS**

### Navigation Patterns
- **Main Hub**: Central dashboard with quick access to all features
- **Tab Navigation**: For categorized content (shop vendors, food types)
- **Modal Dialogs**: For confirmations, detailed views, and forms
- **Side Panels**: For secondary information and filters

### Common UI Elements
- **Button Styles**: Primary (prominent actions), Secondary (navigation), Danger (destructive actions)
- **Cards**: Consistent layout for creatures, items, quests, achievements
- **Progress Bars**: For stats, training progress, time advancement
- **Tooltips**: Contextual help and detailed information
- **Notifications**: Success messages, warnings, and alerts

### Data Display
- **Stat Bars**: Visual representation of creature stats (0-1000 scale)
- **Tag Icons**: Small, recognizable icons for different creature traits
- **Currency Display**: Clear gold amounts with coin icons
- **Status Indicators**: Age categories, active/stable states, quest progress

### Interactive Elements
- **Drag & Drop**: Moving creatures between active/stable rosters
- **Dropdown Menus**: Activity and food selection
- **Filter Controls**: Search, sort, and category filters
- **Confirmation Dialogs**: For important decisions and purchases

---

## 🔄 **USER WORKFLOWS**

### Primary Workflow: Complete a Quest
1. **Main Game View** → View current quest requirements
2. **Creature Collection** → Check for suitable creatures
3. **Quest Journal** → Accept quest if ready, or note requirements
4. **Shop** (if needed) → Purchase eggs or food
5. **Training Assignment** (if needed) → Improve creature stats
6. **Time Progression** → Advance weeks to complete training
7. **Quest Journal** → Complete quest and receive rewards
8. **Main Game View** → View updated status and new quests

### Secondary Workflow: Acquire New Creature
1. **Shop** → Browse vendor catalogs
2. **Species Browser** → Research creature characteristics
3. **Shop** → Purchase creature egg
4. **Creature Collection** → Receive and name new creature
5. **Training Assignment** → Begin training regimen

### Management Workflow: Weekly Planning
1. **Main Game View** → Review current status
2. **Food Management** → Check food inventory
3. **Training Assignment** → Plan activities for active creatures
4. **Competition Interface** → Enter suitable creatures in competitions
5. **Time Progression** → Advance time and review results

---

## 📐 **TECHNICAL SPECIFICATIONS**

### Screen Resolution
- **Target**: 1280x720 (720p)
- **UI Scaling**: Support for 1920x1080 with UI scaling
- **Minimum**: 1024x768

### Control Scheme
- **Primary**: Mouse and keyboard
- **Mouse**: Left click (select/confirm), Right click (context menus), Scroll (lists/zoom)
- **Keyboard**: Hotkeys for common actions, Tab navigation, Enter/Escape for dialogs

### Performance Requirements
- **Target FPS**: 60 FPS for UI interactions
- **Load Times**: < 2 seconds between screens
- **Memory**: Efficient for 1000+ creatures in collection

### Accessibility
- **Color Blindness**: Avoid color-only information conveyance
- **Text Size**: Readable at 1280x720 resolution
- **Keyboard Navigation**: Full keyboard access for all features
- **Screen Reader**: Proper labeling for important elements

---

## 🎨 **VISUAL DESIGN NOTES**

### Art Style
- **Fantasy/Cartoon**: Colorful and approachable
- **Creature Focus**: Creatures are the visual stars
- **Clean UI**: Information-dense but organized
- **Consistent Theming**: Each vendor/system has visual identity

### Color Palette
- **Primary**: Earthy tones (browns, greens) for nature theme
- **Accent**: Bright colors for important actions and rewards
- **Status Colors**: Green (good), Yellow (warning), Red (danger)
- **Neutral**: Grays and whites for backgrounds and panels

### Typography
- **Headers**: Bold, fantasy-themed font
- **Body Text**: Clean, readable sans-serif
- **Numbers**: Monospace for stats and currency
- **Emphasis**: Color and weight changes, not just italics

### Iconography
- **Creature Tags**: Small, recognizable symbols
- **Stats**: Bar charts and numerical displays
- **Currency**: Coin icons with amounts
- **Actions**: Intuitive button icons (play, pause, shopping cart)

---

## 🚀 **IMPLEMENTATION PRIORITY**

### Phase 1: Core MVP (Critical Screens 1-7)
Essential screens for basic gameplay loop. Focus on functionality over polish.

### Phase 2: Enhanced Experience (Important Screens 8-11)
Screens that add depth and improve user experience. Higher polish level.

### Phase 3: Advanced Features (Enhancement Screens 12-15)
Screens for completeness and long-term engagement. Full polish and animations.

---

## 📝 **DESIGN DELIVERABLES CHECKLIST**

### For Each Screen:
- [ ] Wireframe layout showing all elements
- [ ] Interactive prototype showing user flows
- [ ] Visual mockups with final art style
- [ ] Responsive behavior documentation
- [ ] Accessibility considerations
- [ ] Animation and transition specifications

### Overall:
- [ ] Complete user flow diagrams
- [ ] UI component library/style guide
- [ ] Icon library and specifications
- [ ] Color palette and typography guide
- [ ] Interactive prototype of complete game flow
- [ ] Technical handoff documentation

---

**Total Screen Count: 15 screens** (7 Critical + 4 Important + 4 Enhancement)

This specification provides a comprehensive foundation for the UX design team to create a cohesive, user-friendly creature collection game experience.