@tool
extends EditorScript

func _run() -> void:
	print("=== Testing Project Setup ===")

	# Test GameCore accessibility
	if GameCore != null:
		print("✅ GameCore autoload working")
	else:
		print("❌ GameCore autoload failed")
		return

	# Test SignalBus creation
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		print("✅ SignalBus created successfully")
	else:
		print("❌ SignalBus creation failed")
		return

	# Test system lazy loading
	var save_system = GameCore.get_system("save")
	if save_system and save_system is SaveSystem:
		print("✅ SaveSystem lazy loading works")
	else:
		print("❌ SaveSystem lazy loading failed")

	var creature_system = GameCore.get_system("creature")
	if creature_system and creature_system is CreatureSystem:
		print("✅ CreatureSystem lazy loading works")
	else:
		print("❌ CreatureSystem lazy loading failed")

	var quest_system = GameCore.get_system("quest")
	if quest_system and quest_system is QuestSystem:
		print("✅ QuestSystem lazy loading works")
	else:
		print("❌ QuestSystem lazy loading failed")

	print("=== Setup Test Complete ===")
	print("Project is ready for Stage 1 Task 2 (SignalBus)")