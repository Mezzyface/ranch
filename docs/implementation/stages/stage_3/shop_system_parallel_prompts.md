# Shop System Implementation - Parallel Prompts for Sonnet

## Overview
The shop system allows players to purchase creatures, items, and upgrades. Each prompt can run in parallel.

## Parallel Execution Strategy
- **Can run simultaneously:** Prompts 1, 2, 3, and 4
- **Sequential dependency:** Prompt 5 (integration) after others complete

---

## PROMPT 1: Shop System Core Backend (Can Run Parallel)

```
Create the shop system backend for a Godot 4 project at scripts/systems/shop_system.gd:

CONTEXT:
- GameCore at scripts/core/game_core.gd for system registration
- SignalBus at scripts/core/signal_bus.gd for events
- ResourceTracker at scripts/systems/resource_tracker.gd for gold management
- ItemManager at scripts/systems/item_manager.gd for item definitions
- PlayerCollection at scripts/systems/player_collection.gd for creature storage

REQUIREMENTS:
1. Shop system extends Node, registers with GameCore as "shop"
2. Properties:
   - shop_inventory: Dictionary (category -> Array[ShopItem])
   - restock_timer: int (weeks until restock)
   - discount_rate: float (current sale percentage)
   - purchase_history: Array[String] (item IDs)

3. Core methods:
   - _ready(): Initialize shop with default inventory
   - purchase_item(item_id: String, quantity: int) -> bool
   - can_afford(item_id: String, quantity: int) -> bool
   - restock_inventory() -> void
   - get_item_price(item_id: String) -> int
   - get_inventory_by_category(category: String) -> Array
   - apply_discount(discount: float) -> void

4. Add to SignalBus:
   - signal shop_item_purchased(item_id: String, quantity: int, total_cost: int)
   - signal shop_inventory_updated()
   - signal shop_restocked()
   - signal insufficient_funds(item_id: String, cost: int)

5. Inventory categories:
   - "creatures": Array of creature IDs for sale
   - "food": Training food items
   - "equipment": Tools and gear
   - "facilities": Facility upgrades

6. Implement save/load:
   - get_save_data() -> Dictionary
   - load_save_data(data: Dictionary) -> void

Test with: godot --headless --scene tests/individual/test_shop.tscn
```

---

## PROMPT 2: Shop Item Data Structure (Can Run Parallel)

```
Create shop item data structures for a Godot 4 project:

1. Create ShopItemResource at scripts/resources/shop_item_resource.gd:
   - Extends Resource with @tool
   - Properties:
     - @export item_id: String
     - @export display_name: String
     - @export description: String
     - @export category: String (creatures/food/equipment/facilities)
     - @export base_price: int
     - @export icon_path: String
     - @export stock_quantity: int (-1 for unlimited)
     - @export unlock_requirements: Dictionary
     - @export item_data: Resource (CreatureData or ItemResource)
   - Method: is_valid() -> bool

2. Create initial shop items in data/shop/:
   - starter_wolf.tres (creature, 1000g)
   - power_bar.tres (food, 50g)
   - energy_drink.tres (food, 100g)
   - training_whistle.tres (equipment, 500g)
   - facility_upgrade_1.tres (facility, 5000g)

3. Create ShopInventoryManager at scripts/systems/shop_inventory_manager.gd:
   - Load all .tres files from data/shop/
   - Generate daily deals (random discounts)
   - Track stock quantities
   - Handle rare item rotation
   - Method: get_available_items() -> Array[ShopItemResource]
   - Method: generate_weekly_inventory() -> Dictionary

4. Price calculation formulas:
   - Base price adjusted by rarity
   - Bulk discounts for quantity purchases
   - Weekly sales (10-30% off)
   - Loyalty discounts based on purchase history

Ensure all .tres files use proper Godot Resource format.
```

---

## PROMPT 3: Shop UI Interface (Can Run Parallel)

```
Create the shop UI for a Godot 4 project:

1. Create scenes/ui/shop.tscn:
   Shop (Control)
   ├── Background (Panel)
   ├── ShopHeader
   │   ├── Title (Label: "Creature Emporium")
   │   ├── GoldDisplay (HBoxContainer)
   │   │   ├── GoldIcon (TextureRect)
   │   │   └── GoldAmount (Label)
   │   └── CloseButton (Button)
   ├── MainContent (HSplitContainer)
   │   ├── CategoryPanel (VBoxContainer)
   │   │   ├── CreaturesTab (Button)
   │   │   ├── FoodTab (Button)
   │   │   ├── EquipmentTab (Button)
   │   │   └── FacilitiesTab (Button)
   │   └── ItemsPanel (ScrollContainer)
   │       └── ItemGrid (GridContainer, 3 columns)
   └── PurchasePanel (Panel)
       ├── SelectedItem (Label)
       ├── Quantity (SpinBox)
       ├── TotalCost (Label)
       └── BuyButton (Button)

2. Create scripts/ui/shop_controller.gd:
   - Load items from ShopSystem
   - Display items by category
   - Handle tab switching
   - Update gold display
   - Process purchases
   - Show purchase confirmation
   - Animate successful purchases
   - Display error for insufficient funds

3. Create scenes/ui/components/shop_item_card.tscn:
   - Panel with item icon
   - Item name and price
   - Stock quantity (if limited)
   - Discount badge (if on sale)
   - Hover preview with description
   - Click to select for purchase

4. Visual features:
   - Smooth category transitions
   - Item hover effects
   - Purchase success animation
   - Gold deduction animation
   - "SOLD OUT" overlay for empty stock
   - "NEW!" badge for recently added items

5. Connect to UIManager for scene management
```

---

## PROMPT 4: Shop Keeper NPC & Flavor (Can Run Parallel)

```
Create shop keeper NPC and flavor elements for a Godot 4 project:

1. Create ShopKeeperData at scripts/data/shop_keeper_data.gd:
   - Properties:
     - name: String ("Merchant Mallow")
     - portrait_path: String
     - dialogue_lines: Dictionary (context -> Array[String])
     - mood: String (happy/neutral/annoyed)

2. Dialogue contexts and lines:
   - greeting: ["Welcome!", "Looking for something special?"]
   - purchase_success: ["Excellent choice!", "Thank you for your business!"]
   - insufficient_funds: ["You'll need more gold for that.", "Perhaps something more affordable?"]
   - browse: ["Take your time.", "Let me know if you need help."]
   - farewell: ["Come again soon!", "Safe travels!"]
   - special_deal: ["I have a special offer today!", "Limited time discount!"]

3. Create scenes/ui/components/shop_keeper_portrait.tscn:
   - AnimatedSprite2D for keeper
   - Speech bubble (RichTextLabel)
   - Emotion indicators (!, ?, ...)
   - Idle animations (blink, gesture)

4. Add to shop UI:
   - Position keeper portrait in top-right
   - Show contextual dialogue
   - Animate on interactions
   - React to player actions
   - Special animations for big purchases

5. Create shop ambiance:
   - Background shop interior image
   - Ambient shop sounds (optional)
   - Item showcase animations
   - Decorative elements (shelves, counter)

6. Keeper reactions:
   - Happy when making sales
   - Excited for expensive purchases
   - Sympathetic for insufficient funds
   - Encouraging for first-time buyers

Add personality to make shop visits memorable!
```

---

## PROMPT 5: Shop Integration & Testing (Run After Others)

```
Integrate and test the complete shop system in a Godot 4 project:

CONTEXT:
- Shop system components have been created
- Need to wire everything together
- Integrate with game economy

REQUIREMENTS:
1. Integration tasks:
   - Add shop to GameCore loader
   - Connect shop to weekly update cycle (restock)
   - Link with ResourceTracker for transactions
   - Add shop button to overlay_menu.tscn
   - Connect purchase events to achievements
   - Update tutorial to introduce shop

2. Create tests/individual/test_shop.tscn:
   - Test purchase flow
   - Verify gold deduction
   - Check inventory updates
   - Test restock mechanism
   - Validate save/load
   - Test all item categories
   - Verify stock limits
   - Test bulk purchases

3. Balance testing:
   - Verify prices are appropriate
   - Check gold earning vs spending rate
   - Ensure progression feels good
   - Test early/mid/late game economies

4. Edge cases:
   - Purchasing with exact gold amount
   - Attempting purchase with 0 gold
   - Buying last stock of limited item
   - Multiple rapid purchases
   - Shop access during other activities

5. Performance:
   - Load 100+ shop items
   - Rapid category switching
   - Large purchase histories
   - Must maintain 60 FPS

Run tests:
godot --headless --scene tests/individual/test_shop.tscn
```

---

## Implementation Notes

### Shop Categories Reference
- **Creatures**: Starter creatures, rare breeds, special variants
- **Food**: Training foods with different stat bonuses
- **Equipment**: Tools that enhance training or breeding
- **Facilities**: Upgrades and new facility types

### Price Ranges
- Creatures: 500-10,000 gold
- Food: 20-500 gold
- Equipment: 200-5,000 gold
- Facilities: 1,000-50,000 gold

### Restock Mechanics
- Weekly restock of consumables
- Monthly rotation of creatures
- Seasonal special items
- Flash sales every 3-5 weeks

### Integration Points
- GameCore: System registration
- SignalBus: Purchase events
- ResourceTracker: Gold management
- PlayerCollection: Creature additions
- SaveSystem: Shop state persistence
- UIManager: Scene transitions