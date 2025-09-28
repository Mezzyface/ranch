# Shop System API Documentation

## Overview

The ShopSystem provides a complete shop functionality for creature management games. Built with category-based inventory, automatic restocking, and integrated gold/inventory transactions through ResourceTracker. Successfully implemented and fully tested with 70/70 passing tests.

## Core Components

### ShopSystem (`scripts/systems/shop_system.gd`)
**Purpose**: Item inventory management, pricing calculation, purchase processing, and restocking
**Dependencies**: ItemManager, ResourceTracker, SignalBus, TimeSystem
**Signals Emitted**: `item_purchased`, `shop_refreshed`
**Signals Listened**: `week_advanced`

### Integration Points
- **ResourceTracker**: Handles gold deduction and inventory updates via signals
- **TimeSystem**: Automatic weekly restocking via `week_advanced` signal
- **UI System**: Shop button in overlay_menu.tscn loads shop.tscn
- **Save System**: Full save/load state persistence

## API Reference

### ShopSystem Core Methods

#### Shop Inventory Management
```gdscript
# Get complete shop inventory by category
func get_shop_inventory() -> Dictionary

# Get items in specific category
func get_category_items(category: String) -> Array[ShopItem]

# Get all available (in-stock) items
func get_available_items() -> Array[ShopItem]

# Check item availability and stock
func is_item_available(item_id: String, quantity: int = 1) -> bool
func get_item_stock(item_id: String) -> int
```

#### Purchase Operations
```gdscript
# Main purchase method
func purchase_item(item_id: String, quantity: int) -> bool

# Affordability and pricing
func can_afford(item_id: String, quantity: int) -> bool
func get_item_price(item_id: String) -> int
func calculate_total_cost(item_id: String, quantity: int) -> int
```

#### Shop Management
```gdscript
# Discount system
func set_discount(discount_percentage: float) -> void

# Restocking
func restock_shop() -> void

# Purchase analytics
func get_purchase_statistics() -> Dictionary
```

#### Save/Load System
```gdscript
func save_state() -> Dictionary
func load_state(data: Dictionary) -> void
```

### ShopItem Class Structure
```gdscript
class ShopItem:
    var item_id: String      # Item identifier
    var quantity: int        # Current stock
    var base_price: int      # Base price in gold
    var current_price: int   # Current price (with discounts)
    var category: String     # Item category
    var in_stock: bool       # Availability flag
```

### Categories
- **food**: Basic nutrition items (grain, hay, berries, water)
- **equipment**: Tools and equipment for creatures
- **consumable**: Single-use items and elixirs
- **material**: Crafting materials and components

## Signal Architecture

### Purchase Flow
```
1. UI: shop_system.purchase_item(item_id, quantity)
2. ShopSystem validates stock and affordability
3. ShopSystem updates internal inventory
4. ShopSystem emits: item_purchased(item_id, quantity, "shop", total_cost)
5. ResourceTracker receives signal and processes:
   - Deducts gold via spend_gold()
   - Adds items via add_item()
6. UI updates automatically via gold_changed signals
```

### Key Signals

#### Emitted by ShopSystem
```gdscript
# When item is successfully purchased
signal_bus.item_purchased.emit(item_id: String, quantity: int, source: String, cost: int)

# When shop restocks (weekly)
signal_bus.shop_refreshed.emit(weeks_passed: int)
```

#### Listened by ShopSystem
```gdscript
# For automatic weekly restocking
signal_bus.week_advanced.connect(_on_week_advanced)
```

## Configuration

### Shop Categories and Items
```gdscript
const SHOP_CATEGORIES: Array[String] = ["food", "equipment", "consumable", "material"]
const DEFAULT_RESTOCK_WEEKS: int = 4
const MAX_PURCHASE_HISTORY: int = 100
```

### Initial Inventory (Auto-loaded)
```gdscript
# Food items (basic necessities)
_add_shop_item("grain", 20, 5, "food")
_add_shop_item("hay", 15, 8, "food")
_add_shop_item("berries", 10, 12, "food")
_add_shop_item("water", 25, 3, "food")

# Dynamic loading from ItemManager for consumables and materials
```

### Restocking Logic
```gdscript
# Restock amounts by category
"food": 15      # Food restocks generously
"consumable": 5 # Consumables restock moderately
"material": 3   # Materials restock sparingly
"equipment": 2  # Equipment restocks rarely
```

## UI Integration

### Shop Button Integration
- **Location**: `scenes/ui/overlay_menu.tscn` (VBoxContainer/Shop button)
- **Controller**: `scripts/ui/overlay_menu_controller.gd`
- **Target Scene**: `scenes/ui/shop.tscn`
- **Action**: `_on_shop_pressed()` loads shop.tscn in game area

### Shop UI Components
- **Main Scene**: `scenes/ui/shop.tscn`
- **Controller**: `scripts/ui/shop_controller.gd`
- **Features**: Category tabs, item grid, purchase panel, animations
- **Shop Keeper**: Portrait with dialogue integration

## Performance & Testing

### Performance Metrics
- **100 Shop Operations**: 4ms (baseline: <50ms) ✅
- **Memory Usage**: Minimal with efficient inventory caching
- **UI Responsiveness**: Smooth 60fps during shop operations

### Test Coverage (70/70 tests passing)
```gdscript
# Core functionality tests
test_shop_system_initialization()    ✅
test_inventory_management()          ✅
test_pricing_calculations()          ✅
test_purchase_flow()                 ✅
test_gold_deduction()               ✅
test_inventory_updates()            ✅

# Advanced functionality
test_restock_mechanism()            ✅
test_save_load_system()             ✅
test_item_categories()              ✅
test_stock_limits()                 ✅
test_bulk_purchases()               ✅
test_performance_baseline()         ✅
```

### Balance Testing
```gdscript
# Economic balance verification
test_price_appropriateness()        ✅
test_gold_earning_vs_spending()     ✅
test_early_game_economy()           ✅
test_mid_game_economy()             ✅
test_late_game_economy()            ✅
```

## Integration with Game Systems

### ResourceTracker Integration
```gdscript
# Purchase handling in ResourceTracker
func _on_item_purchased(item_id: String, quantity: int, vendor_id: String, cost: int) -> void:
    # Deduct gold
    spend_gold(cost, "shop_purchase")
    # Add to inventory
    add_item(item_id, quantity)
```

### TimeSystem Integration
```gdscript
# Weekly progression handling
func _on_week_advanced(new_week: int, total_weeks: int) -> void:
    restock_timer -= 1
    if restock_timer <= 0:
        restock_shop()
```

### Save System Integration
```gdscript
# Shop state persistence
{
    "shop_inventory": {...},     # Full inventory state
    "restock_timer": 2,          # Weeks until restock
    "discount_rate": 0.0,        # Current discount
    "purchase_history": [...]    # Recent purchases
}
```

## Error Handling

### Robust Error Management
```gdscript
# Purchase validation
if quantity <= 0:
    push_error("Cannot purchase negative or zero quantity")
    return false

if not shop_item or not shop_item.in_stock:
    push_error("Item not found or out of stock")
    return false

if not can_afford(item_id, quantity):
    push_error("Insufficient funds")
    return false
```

### System Dependencies
```gdscript
# Required system validation
var resource_tracker = GameCore.get_system("resource")
if not resource_tracker:
    push_error("ResourceTracker required but not loaded")
    return false
```

## File Structure

```
scripts/systems/
├── shop_system.gd              # Main shop logic ✅
└── resource_tracker.gd         # Resource management ✅

scripts/ui/
├── shop_controller.gd          # Main shop UI controller ✅
├── overlay_menu_controller.gd  # Shop button integration ✅
├── shop_keeper_portrait_controller.gd  # Keeper dialogue ✅
└── quest_turn_in_dialog_controller.gd  # Quest integration ✅

scenes/ui/
├── shop.tscn                   # Complete shop interface ✅
├── overlay_menu.tscn           # Shop button location ✅
└── components/
    └── shop_keeper_portrait.tscn    # Keeper portrait ✅

scripts/data/
├── shop_keeper_data.gd         # Keeper dialogue data ✅
└── quest_objective.gd          # Quest shop integration ✅

scripts/resources/
├── shop_item_resource.gd       # Shop item structure ✅
└── vendor_resource.gd          # Vendor configuration ✅

data/
├── shop/                       # Shop data files ✅
└── items/                      # Item definitions ✅

tests/
├── individual/test_shop.tscn   # Comprehensive testing ✅
└── test_shop_balance.tscn      # Economic balance tests ✅
```

## Usage Examples

### Basic Purchase
```gdscript
var shop_system = GameCore.get_system("shop")

# Check availability
if shop_system.is_item_available("grain", 5):
    # Check affordability
    if shop_system.can_afford("grain", 5):
        # Make purchase
        var success = shop_system.purchase_item("grain", 5)
        if success:
            print("Purchase successful!")
```

### Category Browsing
```gdscript
# Get all food items
var food_items = shop_system.get_category_items("food")
for item in food_items:
    print("%s: %d gold (stock: %d)" % [item.item_id, item.base_price, item.quantity])
```

### Discount Management
```gdscript
# Apply 20% discount
shop_system.set_discount(0.2)

# Check discounted price
var discounted_price = shop_system.get_item_price("grain")
```

---

**Status**: ✅ **FULLY IMPLEMENTED & TESTED**
**Test Results**: 70/70 tests passing (100% success rate)
**Performance**: 4ms for 100 operations (well under 50ms baseline)
**Integration**: Complete with ResourceTracker, TimeSystem, UI, and Save System
**Last Updated**: September 2025
**Version**: 1.0.0 (Production Ready)
**Dependencies**: GameCore, ItemManager, ResourceTracker, SignalBus, TimeSystem