# Shop System API Documentation

## Overview

The ShopSystem manages 6 specialized vendors with dynamic inventory, pricing, and transaction processing. Built for Stage 3 Tasks 3.4-3.5, it integrates with ItemManager and ResourceTracker through a signal-based architecture.

## Core Components

### ShopSystem (`scripts/systems/shop_system.gd`)
**Purpose**: Vendor management, inventory tracking, pricing calculation, and transaction processing
**Dependencies**: ItemManager, SignalBus
**Signals Emitted**: `item_purchased`

### ResourceTracker (`scripts/systems/resource_tracker.gd`)
**Purpose**: Player gold and inventory management
**Dependencies**: ItemManager, SignalBus
**Signals Listened**: `item_purchased`
**Signals Emitted**: `gold_spent`, `item_added`

### Shop UI (`scripts/ui/shop_panel_controller.gd`)
**Purpose**: Shop interface, vendor selection, item browsing, purchase interaction
**Dependencies**: ShopSystem, ResourceTracker (read-only)

## API Reference

### ShopSystem Methods

#### Core Shop Operations
```gdscript
# Vendor Management
func get_all_vendors() -> Array[VendorResource]
func get_unlocked_vendors() -> Array[VendorResource]
func get_vendor(vendor_id: String) -> VendorResource
func is_vendor_unlocked(vendor_id: String) -> bool

# Inventory Operations
func get_vendor_inventory(vendor_id: String) -> Array[Dictionary]
func restock_vendor(vendor_id: String) -> void
func restock_all_vendors() -> void

# Purchase Operations
func can_purchase_item(vendor_id: String, item_id: String, player_gold: int) -> Dictionary
func purchase_item(vendor_id: String, item_id: String, player_gold: int) -> Dictionary

# Pricing
func calculate_item_price(vendor_id: String, item_id: String) -> int
func get_reputation_discount(vendor_id: String) -> float
```

#### Return Types
```gdscript
# can_purchase_item() returns:
{
    "can_purchase": bool,
    "reason": String  # If can_purchase is false
}

# purchase_item() returns:
{
    "success": bool,
    "gold_spent": int,
    "item_received": {"item_id": String, "quantity": int},
    "message": String
}
```

### ResourceTracker Methods

#### Currency Management
```gdscript
func get_balance() -> int
func add_gold(amount: int, source: String = "unknown") -> bool
func spend_gold(amount: int, purpose: String = "unknown") -> bool
func can_afford(cost: int) -> bool
```

#### Inventory Management
```gdscript
func add_item(item_id: String, quantity: int = 1) -> bool
func remove_item(item_id: String, quantity: int = 1) -> bool
func get_item_count(item_id: String) -> int
func has_item(item_id: String, quantity: int = 1) -> bool
func get_inventory() -> Dictionary  # item_id -> quantity
```

## Signal Architecture

### Purchase Flow
```
1. UI: shop_system.purchase_item(vendor_id, item_id, player_gold)
2. ShopSystem validates & updates vendor stock
3. ShopSystem emits: item_purchased(item_id, quantity, vendor_id, cost)
4. ResourceTracker receives signal
5. ResourceTracker.spend_gold() + ResourceTracker.add_item()
6. ResourceTracker emits: gold_spent(amount, purpose)
7. UI updates via gold_spent signal
```

### Key Signals

#### Emitted by ShopSystem
```gdscript
# When item is successfully purchased
signal_bus.item_purchased.emit(item_id: String, quantity: int, vendor_id: String, cost: int)
```

#### Emitted by ResourceTracker
```gdscript
# When gold is spent
signal_bus.gold_spent.emit(amount: int, purpose: String)

# When item is added to inventory
signal_bus.item_added.emit(item_id: String, quantity: int, total: int)
```

## Configuration

### EconomyConfig (`data/economy_config.tres`)
```gdscript
# Base pricing
creature_egg_base_price: int = 200
food_base_price_per_week: int = 5
training_item_base_price: int = 50

# Discounts & modifiers
reputation_discount_per_10_points: float = 0.01  # 1% per 10 reputation
vendor_markup_range: Vector2 = Vector2(0.8, 1.2)  # 80%-120% base price

# Restocking
weekly_restock_percentage: float = 0.3  # 30% of max stock
max_stock_per_item: int = 20
min_stock_per_item: int = 5

# Quest budgeting
weekly_quest_budget: int = 100
monthly_quest_budget: int = 500
```

## Vendor System

### Vendor Types
1. **Starter Stable**: Basic creatures and supplies for beginners
2. **Exotic Imports**: Rare creatures and premium items
3. **Training Grounds**: Combat and skill-building equipment
4. **Gourmet Foods**: Specialized nutrition and treats
5. **Mystic Artifacts**: Magical items and enchantments
6. **Utility Services**: Tools, housing, and practical items

### Vendor Properties
```gdscript
# VendorResource structure
vendor_id: String
display_name: String
description: String
unlock_requirements: Dictionary
base_reputation: int
items_sold: Array[String]  # Item IDs
markup_modifier: float     # Price adjustment factor
```

## Performance Optimizations

### Caching System
- **Vendor Items Cache**: Prevents repeated inventory queries
- **Price Cache**: Stores calculated prices to avoid recalculation
- **Smart Cache Invalidation**: Clears cache only when necessary (purchases, restocks)

### Performance Targets
- Shop grid update: <16ms (60 FPS)
- Purchase transaction: <10ms
- Vendor inventory query: <5ms

## Integration Points

### With ItemManager
```gdscript
# Validates item existence and gets item resources
var item_manager = GameCore.get_system("item_manager")
var item_resource = item_manager.get_item_resource(item_id)
var is_valid = item_manager.is_valid_item(item_id)
```

### With TimeSystem
```gdscript
# For weekly restocking and time-based events
var time_system = GameCore.get_system("time")
var current_week = time_system.current_week
```

### With SignalBus
```gdscript
# All inter-system communication goes through SignalBus
var signal_bus = GameCore.get_signal_bus()
signal_bus.item_purchased.connect(_on_item_purchased)
signal_bus.gold_spent.emit(amount, purpose)
```

## Error Handling

### Common Error Cases
```gdscript
# Invalid item ID
"Invalid item ID: unknown_item"

# Insufficient funds
"Insufficient gold: have 50, need 100"

# Out of stock
"Item out of stock: fresh_water"

# Vendor locked
"Vendor not unlocked: exotic_imports"

# Failed inventory addition
"Failed to add purchased item to inventory"
```

### Error Recovery
- **Transaction Rollback**: If inventory addition fails, gold is not deducted
- **Stock Validation**: Double-check stock before finalizing purchase
- **System Validation**: Verify all required systems are available

## Testing

### Test Scenarios
1. **Basic Purchase Flow**: Buy item with sufficient funds
2. **Insufficient Funds**: Attempt purchase without enough gold
3. **Out of Stock**: Try to buy when vendor has no stock
4. **Vendor Unlocking**: Purchase from newly unlocked vendor
5. **Reputation Discounts**: Verify price reductions with high reputation
6. **Weekly Restocking**: Confirm inventory refresh on time advancement

### Debug Commands
```gdscript
# Add to ResourceTracker for testing
func debug_add_gold(amount: int) -> void
func debug_set_item_count(item_id: String, count: int) -> void

# Add to ShopSystem for testing
func debug_unlock_vendor(vendor_id: String) -> void
func debug_set_stock(vendor_id: String, item_id: String, stock: int) -> void
```

## File Structure

```
scripts/systems/
├── shop_system.gd          # Main shop logic
└── resource_tracker.gd     # Player resources

scripts/ui/
├── shop_panel_controller.gd    # Main shop UI
└── shop_item_card.gd          # Individual item display

scenes/ui/
├── panels/shop_panel.tscn     # Complete shop interface
└── components/shop_item_card.tscn  # Item card component

data/
├── economy_config.tres        # Economic parameters
└── vendors/                   # Vendor resource files
    ├── starter_stable.tres
    ├── exotic_imports.tres
    └── ...

scripts/resources/
└── economy_config.gd          # Economy configuration class
```

## Migration Notes

### From Previous Versions
- **Direct ResourceTracker calls**: Now uses signals
- **Hardcoded vendor data**: Now uses .tres resource files
- **UI polling**: Now uses event-driven updates
- **Mixed responsibilities**: Now has clear system separation

### Breaking Changes
- `item_purchased` signal now includes `cost` parameter
- Purchase methods no longer directly modify ResourceTracker
- Vendor data moved from hardcoded arrays to resource files

---

**Last Updated**: Stage 3 Task 3.5 Implementation
**Version**: 1.0.0
**Dependencies**: ItemManager, ResourceTracker, SignalBus, TimeSystem