extends Node

# Balance Testing Script for Shop System
# Tests economic balance: prices, gold earning vs spending, progression feel

var test_name: String = "Shop Balance Tests"

func _ready() -> void:
	print("=== %s ===" % test_name)
	run_balance_tests()
	print("=== %s Complete ===" % test_name)
	get_tree().quit()

func run_balance_tests() -> void:
	test_price_appropriateness()
	test_gold_earning_vs_spending()
	test_early_game_economy()
	test_mid_game_economy()
	test_late_game_economy()

func test_price_appropriateness() -> void:
	print("\n--- Testing Price Appropriateness ---")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	var food_items = shop_system.get_category_items("food")
	var consumable_items = shop_system.get_category_items("consumable")
	var material_items = shop_system.get_category_items("material")

	# Test food items are affordable
	print("📋 Food Items Price Analysis:")
	for item in food_items:
		var price = shop_system.get_item_price(item.item_id)
		print("  - %s: %d gold (stock: %d)" % [item.item_id, price, item.quantity])
		if price > 0 and price <= 20:
			print("    ✅ Appropriate food price")
		else:
			print("    ⚠️ Food price may be too high: %d gold" % price)

	# Test progression: consumables should be more expensive than food
	print("📋 Price Progression Analysis:")
	if food_items.size() > 0 and consumable_items.size() > 0:
		var avg_food_price = 0
		for item in food_items:
			avg_food_price += shop_system.get_item_price(item.item_id)
		avg_food_price = avg_food_price / food_items.size()

		var avg_consumable_price = 0
		for item in consumable_items:
			avg_consumable_price += shop_system.get_item_price(item.item_id)
		if consumable_items.size() > 0:
			avg_consumable_price = avg_consumable_price / consumable_items.size()

		print("  - Average food price: %d gold" % avg_food_price)
		print("  - Average consumable price: %d gold" % avg_consumable_price)

		if avg_consumable_price > avg_food_price:
			print("    ✅ Good price progression (consumables > food)")
		else:
			print("    ⚠️ Consider raising consumable prices for better progression")

func test_gold_earning_vs_spending() -> void:
	print("\n--- Testing Gold Earning vs Spending Rate ---")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	# Simulate a typical shopping session
	var starting_gold = resource_tracker.get_balance()
	if starting_gold < 100:
		resource_tracker.add_gold(100 - starting_gold, "test_setup")
		starting_gold = 100

	# Try to buy basic necessities
	var food_items = shop_system.get_category_items("food")
	var total_spent = 0
	var items_bought = 0

	print("📋 Simulating basic shopping with %d gold:" % starting_gold)

	for item in food_items:
		if items_bought >= 3:  # Limit to 3 items for test
			break

		var price = shop_system.get_item_price(item.item_id)
		if shop_system.can_afford(item.item_id, 1):
			if shop_system.purchase_item(item.item_id, 1):
				total_spent += price
				items_bought += 1
				print("  - Bought %s for %d gold" % [item.item_id, price])

	var remaining_gold = resource_tracker.get_balance()
	var spend_ratio = float(total_spent) / float(starting_gold)

	print("📊 Shopping Results:")
	print("  - Items bought: %d" % items_bought)
	print("  - Total spent: %d gold" % total_spent)
	print("  - Remaining: %d gold" % remaining_gold)
	print("  - Spend ratio: %.1f%%" % (spend_ratio * 100))

	if spend_ratio >= 0.3 and spend_ratio <= 0.7:
		print("    ✅ Good spending balance (30-70% of starting gold)")
	elif spend_ratio < 0.3:
		print("    ⚠️ Prices may be too low (spent only %.1f%%)" % (spend_ratio * 100))
	else:
		print("    ⚠️ Prices may be too high (spent %.1f%%)" % (spend_ratio * 100))

func test_early_game_economy() -> void:
	print("\n--- Testing Early Game Economy ---")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	# Simulate early game: low gold, basic needs
	var early_game_gold = 50
	var current_gold = resource_tracker.get_balance()
	if current_gold < early_game_gold:
		resource_tracker.add_gold(early_game_gold - current_gold, "test_setup")
	elif current_gold > early_game_gold:
		print("  - Note: Using current gold (%d) instead of target (%d)" % [current_gold, early_game_gold])
		early_game_gold = current_gold

	print("📋 Early Game Scenario (50 gold):")

	# Test if player can afford basic food
	var food_items = shop_system.get_category_items("food")
	var affordable_food = 0

	for item in food_items:
		if shop_system.can_afford(item.item_id, 1):
			affordable_food += 1

	print("  - Affordable food items: %d/%d" % [affordable_food, food_items.size()])

	if affordable_food >= 2:
		print("    ✅ Good early game accessibility")
	else:
		print("    ⚠️ Early game may be too restrictive")

	# Test buying power
	var cheapest_food_price = 999
	for item in food_items:
		var price = shop_system.get_item_price(item.item_id)
		if price > 0 and price < cheapest_food_price:
			cheapest_food_price = price

	var max_food_possible = early_game_gold / cheapest_food_price if cheapest_food_price < 999 else 0
	print("  - Max food items possible: %d" % max_food_possible)

	if max_food_possible >= 5:
		print("    ✅ Good early game buying power")
	else:
		print("    ⚠️ Consider lowering basic food prices")

func test_mid_game_economy() -> void:
	print("\n--- Testing Mid Game Economy ---")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	# Simulate mid game: moderate gold, some luxuries
	var mid_game_gold = 200
	resource_tracker.add_gold(mid_game_gold, "test_setup")

	print("📋 Mid Game Scenario (200 gold):")

	# Test access to different item types
	var categories_affordable = 0
	for category in shop_system.SHOP_CATEGORIES:
		var items = shop_system.get_category_items(category)
		for item in items:
			if shop_system.can_afford(item.item_id, 1):
				categories_affordable += 1
				break  # Found one affordable item in this category

	print("  - Categories with affordable items: %d/%d" % [categories_affordable, shop_system.SHOP_CATEGORIES.size()])

	if categories_affordable >= 3:
		print("    ✅ Good mid game variety")
	else:
		print("    ⚠️ Mid game may need more affordable options")

func test_late_game_economy() -> void:
	print("\n--- Testing Late Game Economy ---")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	# Simulate late game: high gold, premium items
	var late_game_gold = 1000
	resource_tracker.add_gold(late_game_gold, "test_setup")

	print("📋 Late Game Scenario (1000 gold):")

	# Test if there are still meaningful purchases
	var expensive_items = 0
	var all_items = shop_system.get_available_items()

	for item in all_items:
		var price = shop_system.get_item_price(item.item_id)
		if price > 50:  # Define "expensive" as >50 gold
			expensive_items += 1

	print("  - Expensive items (>50g): %d/%d" % [expensive_items, all_items.size()])

	if expensive_items >= 2:
		print("    ✅ Good late game gold sinks")
	else:
		print("    ⚠️ Consider adding more expensive items for late game")

	# Test bulk purchasing power
	if all_items.size() > 0:
		var test_item = all_items[0]
		var max_quantity = late_game_gold / shop_system.get_item_price(test_item.item_id)
		print("  - Max quantity of %s possible: %d" % [test_item.item_id, max_quantity])

		if max_quantity >= 10:
			print("    ✅ Good late game bulk buying power")
		else:
			print("    ⚠️ Late game players may feel gold-poor")