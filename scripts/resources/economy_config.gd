@tool
class_name EconomyConfig
extends Resource

# Economy Configuration Resource for shop system balance tuning

# === BASE PRICING ===
@export_group("Base Pricing")
@export var creature_egg_base_price: int = 200
@export var food_base_price: int = 25
@export var training_item_base_price: int = 100
@export var special_item_base_price: int = 500

# === PRICING MODIFIERS ===
@export_group("Pricing Modifiers")
@export var reputation_discount_per_10_points: float = 0.01  # 1% discount per 10 reputation
@export var bulk_discount_3_items: float = 0.10  # 10% discount for 3+ items
@export var bulk_discount_5_items: float = 0.20  # 20% discount for 5+ items
@export var market_variance_range: float = 0.15  # ±15% random market variance

# === VENDOR MULTIPLIERS ===
@export_group("Vendor Multipliers")
@export var starter_vendor_markup: float = 0.8  # 20% discount for starter items
@export var premium_vendor_markup: float = 1.5  # 50% markup for premium vendors
@export var specialty_vendor_markup: float = 1.2  # 20% markup for specialty vendors

# === RESTOCK SETTINGS ===
@export_group("Restock Mechanics")
@export var weekly_restock_multiplier: float = 1.0
@export var basic_item_restock_rate: int = 5  # Items restocked per week
@export var rare_item_restock_rate: int = 1
@export var legendary_item_restock_rate: int = 1  # Every other week

# === STOCK LIMITS ===
@export_group("Stock Limits")
@export var basic_max_stock: int = 20
@export var rare_max_stock: int = 5
@export var legendary_max_stock: int = 2

# === CREATURE EGG PRICING ===
@export_group("Creature Egg Pricing")
@export var scuttleguard_price: int = 200
@export var wind_dancer_price: int = 500
@export var stone_sentinel_price: int = 800
@export var shadow_cat_price: int = 450
@export var sage_owl_price: int = 1500
@export var crystal_thinker_price: int = 2000

# === FOOD PRICING ===
@export_group("Food Pricing")
@export var grain_rations_price: int = 5
@export var fresh_hay_price: int = 8
@export var wild_berries_price: int = 10
@export var protein_mix_price: int = 25
@export var golden_nectar_price: int = 100

# === UNLOCK THRESHOLDS ===
@export_group("Unlock Requirements")
@export var shadow_market_unlock_quest: String = "TIM-01"
@export var savage_supplies_unlock_quest: String = "TIM-03"
@export var mystical_menagerie_unlock_quest: String = "TIM-05"

# === REPUTATION SYSTEM ===
@export_group("Reputation")
@export var purchase_reputation_gain: int = 1
@export var expensive_purchase_reputation_gain: int = 3  # For purchases >1000g
@export var max_vendor_reputation: int = 100
@export var reputation_unlock_thresholds: Array[int] = [25, 50, 75]  # Special item unlocks

# === QUEST REWARDS (for comparison) ===
@export_group("Quest Rewards Reference")
@export var tim_01_reward: int = 300
@export var tim_02_reward: int = 400
@export var tim_03_reward: int = 1500
@export var tim_04_reward: int = 1800
@export var tim_05_reward: int = 2500
@export var tim_06_reward: int = 7500

# === BALANCE PARAMETERS ===
@export_group("Balance Tuning")
@export var early_game_gold_target: int = 1000  # Target gold by TIM-03
@export var mid_game_gold_target: int = 5000   # Target gold by TIM-05
@export var late_game_gold_target: int = 15000 # Target gold by TIM-06

# Quest progression cost targets
@export var tim_01_cost_budget: int = 250   # Expected spend for TIM-01
@export var tim_02_cost_budget: int = 300   # Expected spend for TIM-02
@export var tim_03_cost_budget: int = 1400  # Expected spend for TIM-03
@export var tim_04_cost_budget: int = 1600  # Expected spend for TIM-04
@export var tim_05_cost_budget: int = 2000  # Expected spend for TIM-05
@export var tim_06_cost_budget: int = 5000  # Expected spend for TIM-06

# === DYNAMIC PRICING SETTINGS ===
@export_group("Dynamic Pricing")
@export var enable_market_fluctuations: bool = true
@export var fluctuation_period_weeks: int = 4  # Price changes every 4 weeks
@export var seasonal_modifier_amplitude: float = 0.1  # ±10% seasonal variance

# === SPECIAL DEALS SYSTEM ===
@export_group("Special Deals")
@export var weekly_featured_discount: float = 0.25  # 25% off featured items
@export var bundle_deal_threshold: int = 3  # Minimum items for bundle deals
@export var loyalty_discount_threshold: int = 50  # Reputation needed for loyalty discount

func _init() -> void:
	_validate_config()

func _validate_config() -> void:
	# Ensure pricing makes economic sense
	assert(creature_egg_base_price > 0, "Creature egg base price must be positive")
	assert(reputation_discount_per_10_points >= 0.0, "Reputation discount cannot be negative")
	assert(bulk_discount_3_items <= bulk_discount_5_items, "5-item discount should be >= 3-item discount")

func is_valid() -> bool:
	return creature_egg_base_price > 0 and food_base_price > 0

func get_creature_price(species_id: String) -> int:
	match species_id:
		"scuttleguard":
			return scuttleguard_price
		"wind_dancer":
			return wind_dancer_price
		"stone_sentinel":
			return stone_sentinel_price
		"shadow_cat":
			return shadow_cat_price
		"sage_owl":
			return sage_owl_price
		"crystal_thinker":
			return crystal_thinker_price
		_:
			return creature_egg_base_price

func get_food_price(food_id: String) -> int:
	match food_id:
		"grain_rations":
			return grain_rations_price
		"fresh_hay":
			return fresh_hay_price
		"wild_berries":
			return wild_berries_price
		"protein_mix":
			return protein_mix_price
		"golden_nectar":
			return golden_nectar_price
		_:
			return food_base_price

func calculate_reputation_discount(reputation: int) -> float:
	return (reputation / 10) * reputation_discount_per_10_points

func calculate_bulk_discount(item_count: int) -> float:
	if item_count >= 5:
		return bulk_discount_5_items
	elif item_count >= 3:
		return bulk_discount_3_items
	else:
		return 0.0

func get_vendor_markup(vendor_type: String) -> float:
	match vendor_type:
		"starter":
			return starter_vendor_markup
		"premium":
			return premium_vendor_markup
		"specialty":
			return specialty_vendor_markup
		_:
			return 1.0

func is_quest_unlock_met(quest_id: String, completed_quests: Array[String]) -> bool:
	return quest_id.is_empty() or quest_id in completed_quests

func get_quest_cost_budget(quest_id: String) -> int:
	match quest_id:
		"TIM-01":
			return tim_01_cost_budget
		"TIM-02":
			return tim_02_cost_budget
		"TIM-03":
			return tim_03_cost_budget
		"TIM-04":
			return tim_04_cost_budget
		"TIM-05":
			return tim_05_cost_budget
		"TIM-06":
			return tim_06_cost_budget
		_:
			return 0