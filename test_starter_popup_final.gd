extends Control

# Test the final starter popup without duplicates
func _ready():
	print("=== Testing Starter Popup - No Duplicates ===")

	# Wait for systems to initialize
	await get_tree().process_frame

	var signal_bus = GameCore.get_signal_bus()
	var resource_tracker = GameCore.get_system("resource")
	var collection_system = GameCore.get_system("collection")

	if not signal_bus or not resource_tracker or not collection_system:
		print("ERROR: Required systems not available")
		get_tree().quit()
		return

	# Check initial state (should be empty now)
	print("=== Initial State Check ===")
	print("Initial gold: %d (should be 0)" % resource_tracker.get_balance())
	print("Initial active creatures: %d (should be 0)" % collection_system.get_active_roster().size())
	print("Initial stable creatures: %d (should be 0)" % collection_system.get_stable_collection().size())

	# Load overlay menu scene
	var overlay_scene = load("res://scenes/ui/overlay_menu.tscn")
	if not overlay_scene:
		print("ERROR: Could not load overlay menu scene")
		get_tree().quit()
		return

	var overlay_instance = overlay_scene.instantiate()
	add_child(overlay_instance)
	print("✓ Overlay menu loaded")

	# Wait for initialization
	await get_tree().create_timer(0.3).timeout

	# Connect to popup closed signal
	signal_bus.starter_popup_closed.connect(_on_popup_closed)

	# Record state before popup
	var gold_before = resource_tracker.get_balance()
	var creatures_before = collection_system.get_active_roster().size()

	# Trigger new game started signal
	print("=== Triggering New Game Started ===")
	signal_bus.emit_new_game_started()

	# Wait for popup to appear
	await get_tree().create_timer(0.5).timeout

	# Find and test the popup
	var found_popup = false
	var popup_node = null
	for child in overlay_instance.get_children():
		if "StarterPopup" in str(child.get_script()) or "StarterPopup" in str(child):
			found_popup = true
			popup_node = child
			break

	if not found_popup:
		print("ERROR: Popup not found")
		get_tree().quit()
		return

	print("✓ Popup found and displayed")

	# Check the creature name shown in popup
	if popup_node:
		var creature_name_label = popup_node.get_node("Panel/MarginContainer/VBoxContainer/CreatureContainer/CreatureName")
		if creature_name_label:
			print("Creature name in popup: '%s' (should be 'Kevin')" % creature_name_label.text)

	# Simulate clicking the start button
	if popup_node:
		var start_button = popup_node.get_node("Panel/MarginContainer/VBoxContainer/StartButton")
		if start_button:
			print("Clicking 'Start Adventure' button...")
			start_button.emit_signal("pressed")
			await get_tree().create_timer(0.3).timeout

	print("=== Final State Check ===")
	var gold_after = resource_tracker.get_balance()
	var creatures_after = collection_system.get_active_roster().size()

	print("Gold before: %d, after: %d (should increase by 500)" % [gold_before, gold_after])
	print("Creatures before: %d, after: %d (should increase by 1)" % [creatures_before, creatures_after])

	# Check creature name
	var active_roster = collection_system.get_active_roster()
	if active_roster.size() > 0:
		var kevin = active_roster[0]
		print("Creature name: '%s' (should be 'Kevin')" % kevin.creature_name)

	# Verify correct amounts
	if gold_after == gold_before + 500:
		print("✓ Gold correctly increased by 500")
	else:
		print("✗ Gold increase incorrect: expected +500, got +%d" % (gold_after - gold_before))

	if creatures_after == creatures_before + 1:
		print("✓ Exactly 1 creature added")
	else:
		print("✗ Creature count incorrect: expected +1, got +%d" % (creatures_after - creatures_before))

	print("=== Test Complete ===")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func _on_popup_closed():
	print("✓ Popup closed signal received")