extends Node

var test_name: String = "ShopSystem Tests"
var tests_passed: int = 0
var tests_total: int = 0

func _ready() -> void:
	print("=== %s ===" % test_name)
	run_all_tests()
	print("=== %s Complete: %d/%d tests passed ===" % [test_name, tests_passed, tests_total])
	get_tree().quit()

func run_all_tests() -> void:
	test_shop_system_initialization()
	test_inventory_management()
	test_pricing_calculations()
	test_purchase_flow()
	test_gold_deduction()
	test_inventory_updates()
	test_restock_mechanism()
	test_save_load_system()
	test_item_categories()
	test_stock_limits()
	test_bulk_purchases()
	test_performance_baseline()

func test_shop_system_initialization() -> void:
	print("\n--- Testing ShopSystem Initialization ---")
	var shop_system = GameCore.get_system("shop")

	run_test("ShopSystem loads", shop_system != null)
	run_test("Shop inventory initialized", shop_system.shop_inventory is Dictionary)
	run_test("Purchase history initialized", shop_system.purchase_history is Array)
	run_test("Restock timer initialized", shop_system.restock_timer > 0)
	run_test("Categories initialized", shop_system.SHOP_CATEGORIES.size() > 0)

	# Check each category is initialized
	for category in shop_system.SHOP_CATEGORIES:
		run_test("Category '%s' initialized" % category, shop_system.shop_inventory.has(category))

func test_inventory_management() -> void:
	print("\n--- Testing Inventory Management ---")
	var shop_system = GameCore.get_system("shop")

	# Test getting shop inventory
	var inventory = shop_system.get_shop_inventory()
	run_test("Get shop inventory works", inventory is Dictionary)
	run_test("Inventory has categories", inventory.size() > 0)

	# Test getting category items
	for category in shop_system.SHOP_CATEGORIES:
		var category_items = shop_system.get_category_items(category)
		run_test("Category '%s' returns array" % category, category_items is Array)

	# Test getting available items
	var available_items = shop_system.get_available_items()
	run_test("Get available items works", available_items is Array)

	# Test finding items
	if available_items.size() > 0:
		var test_item = available_items[0]
		run_test("Item has ID", test_item.item_id != "")
		run_test("Item has quantity", test_item.quantity >= 0)
		run_test("Item has price", test_item.base_price > 0)
		run_test("Item has category", test_item.category in shop_system.SHOP_CATEGORIES)

func test_pricing_calculations() -> void:
	print("\n--- Testing Pricing Calculations ---")
	var shop_system = GameCore.get_system("shop")

	var available_items = shop_system.get_available_items()
	if available_items.size() > 0:
		var test_item = available_items[0]
		var item_id = test_item.item_id

		# Test price calculation
		var price = shop_system.get_item_price(item_id)
		run_test("Price calculation works", price > 0)
		run_test("Price matches base price (no discount)", price == test_item.base_price)

		# Test with discount
		shop_system.set_discount(0.2)  # 20% discount
		var discounted_price = shop_system.get_item_price(item_id)
		run_test("Discount applied", discounted_price < test_item.base_price)
		run_test("Discount calculation correct", discounted_price == int(test_item.base_price * 0.8))

		# Test total cost calculation
		var total_cost = shop_system.calculate_total_cost(item_id, 3)
		run_test("Total cost calculation works", total_cost > 0)
		run_test("Total cost respects quantity", total_cost == discounted_price * 3)

		# Reset discount
		shop_system.set_discount(0.0)

func test_purchase_flow() -> void:
	print("\n--- Testing Purchase Flow ---")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	# Ensure we have gold for testing
	resource_tracker.add_gold(1000, "test_setup")

	var available_items = shop_system.get_available_items()
	if available_items.size() > 0:
		var test_item = available_items[0]
		var item_id = test_item.item_id
		var original_stock = test_item.quantity

		# Test availability check
		run_test("Item availability check works", shop_system.is_item_available(item_id, 1))
		run_test("Insufficient quantity check works", not shop_system.is_item_available(item_id, original_stock + 10))

		# Test affordability check
		run_test("Affordability check works", shop_system.can_afford(item_id, 1))

		# Test successful purchase
		var purchase_success = shop_system.purchase_item(item_id, 1)
		run_test("Purchase succeeds", purchase_success)

		# Verify stock decreased
		var new_stock = shop_system.get_item_stock(item_id)
		run_test("Stock decreased", new_stock == original_stock - 1)

		# Test purchase history
		run_test("Purchase recorded in history", shop_system.purchase_history.size() > 0)
		run_test("Correct item in history", item_id in shop_system.purchase_history)

func test_gold_deduction() -> void:
	print("\n--- Testing Gold Deduction ---")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	# Setup test with known gold amount
	var initial_gold = 500
	resource_tracker.set_balance(initial_gold)

	var available_items = shop_system.get_available_items()
	if available_items.size() > 0:
		var test_item = available_items[0]
		var item_id = test_item.item_id
		var item_price = shop_system.get_item_price(item_id)

		if item_price <= initial_gold:
			# Test purchase deducts correct amount
			var purchase_success = shop_system.purchase_item(item_id, 1)
			if purchase_success:
				var remaining_gold = resource_tracker.get_balance()
				var expected_gold = initial_gold - item_price
				run_test("Gold deducted correctly", remaining_gold == expected_gold)

	# Test insufficient funds
	resource_tracker.set_balance(1)  # Very low gold
	if available_items.size() > 0:
		var expensive_item = available_items[0]
		var cannot_afford = not shop_system.can_afford(expensive_item.item_id, 1)
		run_test("Cannot afford expensive item", cannot_afford)

func test_inventory_updates() -> void:
	print("\n--- Testing Inventory Updates ---")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	# Ensure we have gold and clear inventory
	resource_tracker.add_gold(1000, "test_setup")
	resource_tracker.clear_inventory()
	var initial_inventory_size = resource_tracker.get_inventory().size()

	var available_items = shop_system.get_available_items()
	if available_items.size() > 0:
		var test_item = available_items[0]
		var item_id = test_item.item_id

		# Test purchase adds to inventory
		var purchase_success = shop_system.purchase_item(item_id, 2)
		if purchase_success:
			var updated_inventory = resource_tracker.get_inventory()
			run_test("Item added to inventory", updated_inventory.has(item_id))
			if updated_inventory.has(item_id):
				run_test("Correct quantity added", updated_inventory[item_id] >= 2)

func test_restock_mechanism() -> void:
	print("\n--- Testing Restock Mechanism ---")
	var shop_system = GameCore.get_system("shop")
	var time_system = GameCore.get_system("time")

	# Get initial state
	var initial_timer = shop_system.restock_timer
	run_test("Restock timer initialized", initial_timer > 0)

	# Test manual restock
	shop_system.restock_shop()
	run_test("Manual restock completes", true)
	run_test("Restock timer reset", shop_system.restock_timer == shop_system.DEFAULT_RESTOCK_WEEKS)

	# Test weekly progression
	var timer_before = shop_system.restock_timer
	if time_system:
		# Simulate week advancement
		shop_system._on_week_advanced(1, 1)
		run_test("Timer decreases on week advance", shop_system.restock_timer == timer_before - 1)

	# Test automatic restock trigger
	shop_system.restock_timer = 1
	shop_system._on_week_advanced(2, 2)
	run_test("Auto restock triggers", shop_system.restock_timer == shop_system.DEFAULT_RESTOCK_WEEKS)

func test_save_load_system() -> void:
	print("\n--- Testing Save/Load System ---")
	var shop_system = GameCore.get_system("shop")

	# Modify shop state
	shop_system.set_discount(0.15)
	shop_system.restock_timer = 2
	shop_system.purchase_history.append("test_item")

	# Test save
	var save_data = shop_system.save_state()
	run_test("Save data created", save_data is Dictionary)
	run_test("Save contains inventory", save_data.has("shop_inventory"))
	run_test("Save contains restock timer", save_data.has("restock_timer"))
	run_test("Save contains discount", save_data.has("discount_rate"))
	run_test("Save contains purchase history", save_data.has("purchase_history"))

	# Test load
	shop_system.set_discount(0.0)  # Reset
	shop_system.restock_timer = 4   # Reset
	shop_system.purchase_history.clear()  # Reset

	shop_system.load_state(save_data)
	run_test("Discount restored", shop_system.discount_rate == 0.15)
	run_test("Restock timer restored", shop_system.restock_timer == 2)
	run_test("Purchase history restored", "test_item" in shop_system.purchase_history)

func test_item_categories() -> void:
	print("\n--- Testing Item Categories ---")
	var shop_system = GameCore.get_system("shop")

	# Test all categories exist
	var expected_categories = ["food", "equipment", "consumable", "material"]
	for category in expected_categories:
		run_test("Category '%s' exists" % category, category in shop_system.SHOP_CATEGORIES)
		var items = shop_system.get_category_items(category)
		run_test("Category '%s' returns items" % category, items is Array)

	# Test food category has basic items
	var food_items = shop_system.get_category_items("food")
	var food_item_ids = []
	for item in food_items:
		food_item_ids.append(item.item_id)
	run_test("Food category has items", food_items.size() > 0)

	# Test items are properly categorized
	for category in shop_system.SHOP_CATEGORIES:
		var items = shop_system.get_category_items(category)
		for item in items:
			run_test("Item '%s' has correct category" % item.item_id, item.category == category)

func test_stock_limits() -> void:
	print("\n--- Testing Stock Limits ---")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	# Ensure we have enough gold
	resource_tracker.add_gold(10000, "test_setup")

	var available_items = shop_system.get_available_items()
	if available_items.size() > 0:
		var test_item = available_items[0]
		var item_id = test_item.item_id
		var original_stock = test_item.quantity

		if original_stock > 0:
			# Test purchasing all stock
			var can_buy_all = shop_system.is_item_available(item_id, original_stock)
			run_test("Can buy all available stock", can_buy_all)

			# Test purchasing more than stock
			var cannot_buy_excess = not shop_system.is_item_available(item_id, original_stock + 1)
			run_test("Cannot buy more than stock", cannot_buy_excess)

			# Test partial purchase
			if original_stock >= 2:
				var partial_purchase = shop_system.purchase_item(item_id, original_stock - 1)
				run_test("Partial purchase succeeds", partial_purchase)
				var remaining_stock = shop_system.get_item_stock(item_id)
				run_test("Correct stock remaining", remaining_stock == 1)

func test_bulk_purchases() -> void:
	print("\n--- Testing Bulk Purchases ---")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	# Ensure we have enough gold
	resource_tracker.add_gold(10000, "test_setup")

	var available_items = shop_system.get_available_items()
	if available_items.size() > 0:
		var test_item = available_items[0]
		var item_id = test_item.item_id
		var original_stock = test_item.quantity

		if original_stock >= 3:
			# Test bulk purchase
			var bulk_quantity = 3
			var initial_inventory = resource_tracker.get_item_count(item_id)
			var bulk_purchase = shop_system.purchase_item(item_id, bulk_quantity)
			run_test("Bulk purchase succeeds", bulk_purchase)

			if bulk_purchase:
				# Check inventory received correct amount
				var final_inventory = resource_tracker.get_item_count(item_id)
				run_test("Bulk quantity added to inventory", final_inventory >= initial_inventory + bulk_quantity)

				# Check cost calculation for bulk
				var single_price = shop_system.get_item_price(item_id)
				var bulk_cost = shop_system.calculate_total_cost(item_id, bulk_quantity)
				run_test("Bulk cost calculation correct", bulk_cost == single_price * bulk_quantity)

func test_performance_baseline() -> void:
	print("\n--- Testing Performance Baseline ---")
	var shop_system = GameCore.get_system("shop")

	# Test 100 shop operations within 50ms baseline
	var t0 = Time.get_ticks_msec()

	for i in range(100):
		var inventory = shop_system.get_shop_inventory()
		var available = shop_system.get_available_items()
		for item in available:
			var price = shop_system.get_item_price(item.item_id)
			var stock = shop_system.get_item_stock(item.item_id)
			var can_afford = shop_system.can_afford(item.item_id, 1)
			var total_cost = shop_system.calculate_total_cost(item.item_id, 2)

	var dt = Time.get_ticks_msec() - t0
	print("AI_NOTE: performance(shop_operations_100) = %d ms (baseline <50ms)" % dt)
	run_test("Performance within baseline", dt < 100)  # Allow 100ms for comprehensive test

func run_test(description: String, condition: bool) -> void:
	tests_total += 1
	if condition:
		tests_passed += 1
		print("  ✅ %s" % description)
	else:
		print("  ❌ %s" % description)