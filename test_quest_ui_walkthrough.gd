extends Node

# Quest System UI Walkthrough
# A comprehensive test scene for demonstrating and testing all quest features
# Run with: godot --scene test_quest_ui_walkthrough.tscn

var quest_system: QuestSystem
var signal_bus: SignalBus
var collection_system: Node
var step_index: int = 0
var test_creatures: Array[CreatureData] = []
var current_quest_id: String = ""

# UI State
var is_waiting_for_input: bool = false

func _ready() -> void:
	print("================================================================================")
	print("QUEST SYSTEM UI WALKTHROUGH")
	print("================================================================================")
	print("This walkthrough will demonstrate all quest system features.")
	print("Press SPACE to advance through each step.")
	print("Press ESC to quit.")
	print("================================================================================")

	# Initialize systems
	_setup_systems()
	_setup_signal_tracking()
	_generate_test_creatures()

	# Start the walkthrough
	_show_step()

func _setup_systems() -> void:
	print("🔧 Setting up quest system...")

	# Get required systems
	signal_bus = GameCore.get_signal_bus()
	collection_system = GameCore.get_system("collection")
	quest_system = GameCore.get_system("quest")

	if not quest_system:
		print("❌ QuestSystem not available!")
		return

	print("✅ Quest system initialized with %d quests loaded" % quest_system.quest_resources.size())

func _setup_signal_tracking() -> void:
	# Connect to quest signals for live feedback
	if signal_bus:
		if signal_bus.has_signal("quest_started"):
			signal_bus.quest_started.connect(_on_quest_started)
		if signal_bus.has_signal("quest_completed"):
			signal_bus.quest_completed.connect(_on_quest_completed)
		if signal_bus.has_signal("quest_objective_completed"):
			signal_bus.quest_objective_completed.connect(_on_quest_objective_completed)

func _generate_test_creatures() -> void:
	print("🐾 Generating test creatures for quest testing...")

	# Create diverse creatures for different quest types
	var creature_configs: Array[Dictionary] = [
		{"name": "Scout Alpha", "tags": ["scout"], "stats": {"strength": 15, "dexterity": 20}},
		{"name": "Guard Beta", "tags": ["guard"], "stats": {"strength": 25, "constitution": 22}},
		{"name": "Elite Guardian", "tags": ["guard", "elite"], "stats": {"strength": 30, "constitution": 25}},
		{"name": "Research Assistant", "tags": ["research"], "stats": {"intelligence": 20, "wisdom": 18}},
		{"name": "Basic Creature", "tags": [], "stats": {"strength": 10, "dexterity": 10}},
		{"name": "Powerful Scout", "tags": ["scout"], "stats": {"strength": 20, "dexterity": 25}},
		{"name": "Advanced Researcher", "tags": ["research"], "stats": {"intelligence": 25, "wisdom": 20}}
	]

	for config in creature_configs:
		var creature: CreatureData = CreatureData.new()
		creature.id = "test_%s" % config.name.to_lower().replace(" ", "_")
		creature.creature_name = config.name
		creature.species_id = "scuttleguard"
		creature.age_weeks = 10
		creature.lifespan_weeks = 100

		# Set stats
		for stat_name in config.stats.keys():
			creature.set_stat(stat_name, config.stats[stat_name])

		# Set tags
		for tag in config.tags:
			creature.tags.append(tag)

		test_creatures.append(creature)

	print("✅ Generated %d test creatures" % test_creatures.size())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_SPACE and event.pressed):
		if is_waiting_for_input:
			_advance_step()
	elif event.is_action_pressed("ui_cancel"):
		print("\n👋 Exiting quest walkthrough...")
		get_tree().quit()

func _advance_step() -> void:
	is_waiting_for_input = false
	step_index += 1
	_show_step()

func _show_step() -> void:
	match step_index:
		0:
			_step_introduction()
		1:
			_step_list_available_quests()
		2:
			_step_show_quest_details()
		3:
			_step_start_first_quest()
		4:
			_step_show_creature_collection()
		5:
			_step_test_quest_matching()
		6:
			_step_complete_quest_objective()
		7:
			_step_complete_quest()
		8:
			_step_start_advanced_quest()
		9:
			_step_test_multiple_objectives()
		10:
			_step_demonstrate_prerequisites()
		11:
			_step_show_quest_progress()
		12:
			_step_test_reward_system()
		13:
			_step_conclusion()
		_:
			_finish_walkthrough()

# === WALKTHROUGH STEPS ===

func _step_introduction() -> void:
	print("\n============================================================")
	print("STEP 1: INTRODUCTION TO QUEST SYSTEM")
	print("============================================================")
	print("The quest system provides:")
	print("• 📜 Quest resource loading and management")
	print("• 🎯 Objective matching with creature requirements")
	print("• 📊 Progress tracking and completion")
	print("• 🎁 Reward granting")
	print("• 💾 Save/load support")
	print("• 🔔 Signal-based event notifications")
	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_list_available_quests() -> void:
	print("\n" + "============================================================")
	print("STEP 2: AVAILABLE QUESTS")
	print("============================================================")

	var available_quests: Array[String] = quest_system.get_available_quests()
	print("📋 Available quests (%d total):" % available_quests.size())

	for quest_id in available_quests:
		var quest_resource: Dictionary = quest_system.get_quest_resource(quest_id)
		print("  • %s: %s" % [quest_id, quest_resource.get("title", "Unknown Title")])
		print("    %s" % quest_resource.get("description", "No description"))

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_show_quest_details() -> void:
	print("\n" + "============================================================")
	print("STEP 3: QUEST DETAILS - TIM-01")
	print("============================================================")

	current_quest_id = "TIM-01"
	var quest_resource: Dictionary = quest_system.get_quest_resource(current_quest_id)

	print("📄 Quest: %s" % quest_resource.get("title", "Unknown"))
	print("📝 Description: %s" % quest_resource.get("description", "No description"))

	var objectives: Array = quest_resource.get("objectives", [])
	print("🎯 Objectives (%d):" % objectives.size())
	for i in range(objectives.size()):
		var obj: Dictionary = objectives[i]
		print("  %d. %s" % [i + 1, obj.get("description", "No description")])
		print("     Type: %s | Count: %d" % [obj.get("type", "unknown"), obj.get("count", 1)])
		if obj.has("tags") and not obj.tags.is_empty():
			print("     Required tags: %s" % str(obj.tags))
		if obj.has("species") and not obj.species.is_empty():
			print("     Required species: %s" % obj.species)

	var rewards: Dictionary = quest_resource.get("rewards", {})
	print("🎁 Rewards:")
	for reward_type in rewards.keys():
		print("  • %s: %s" % [reward_type, str(rewards[reward_type])])

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_start_first_quest() -> void:
	print("\n" + "============================================================")
	print("STEP 4: STARTING QUEST")
	print("============================================================")

	print("🚀 Starting quest: %s" % current_quest_id)

	# Check prerequisites
	var can_start: bool = quest_system.check_prerequisites(current_quest_id)
	print("✅ Prerequisites check: %s" % ("PASSED" if can_start else "FAILED"))

	if can_start:
		var success: bool = quest_system.start_quest(current_quest_id)
		if success:
			print("✅ Quest started successfully!")
			print("📊 Quest is now active: %s" % quest_system.is_quest_active(current_quest_id))
		else:
			print("❌ Failed to start quest")
	else:
		print("❌ Cannot start quest - prerequisites not met")

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_show_creature_collection() -> void:
	print("\n" + "============================================================")
	print("STEP 5: CREATURE COLLECTION")
	print("============================================================")

	print("🐾 Available test creatures:")
	for i in range(test_creatures.size()):
		var creature: CreatureData = test_creatures[i]
		print("  %d. %s (ID: %s)" % [i + 1, creature.creature_name, creature.id])
		print("     Species: %s | Age: %d weeks" % [creature.species_id, creature.age_weeks])
		print("     Tags: %s" % str(creature.tags))
		print("     Stats: STR=%d DEX=%d CON=%d INT=%d WIS=%d" % [
			creature.get_stat("strength"),
			creature.get_stat("dexterity"),
			creature.get_stat("constitution"),
			creature.get_stat("intelligence"),
			creature.get_stat("wisdom")
		])
		print()

	print("Press SPACE to continue...")
	is_waiting_for_input = true

func _step_test_quest_matching() -> void:
	print("\n" + "============================================================")
	print("STEP 6: QUEST OBJECTIVE MATCHING")
	print("============================================================")

	# Create test objective for demonstration
	var test_objective: QuestObjective = QuestTestData.get_tim_quest_objectives()["TIM-01"]

	print("🎯 Testing objective matching for %s:" % current_quest_id)
	print("   Required tags: %s" % str(test_objective.required_tags))
	print("   Required stats: %s" % str(test_objective.required_stats))
	print("   Quantity needed: %d" % test_objective.quantity)
	print()

	print("🔍 Checking each creature against objective:")
	for creature in test_creatures:
		var matches: bool = QuestMatcher.validate_creature_for_objective(creature, test_objective)
		var status: String = "✅ MATCH" if matches else "❌ NO MATCH"
		print("  • %s: %s" % [creature.creature_name, status])

		# Show validation details for failing creatures
		if not matches:
			var details: Dictionary = QuestMatcher.get_validation_details(creature, test_objective)
			if not details.missing_tags.is_empty():
				print("    Missing tags: %s" % str(details.missing_tags))
			if not details.insufficient_stats.is_empty():
				print("    Insufficient stats: %s" % str(details.insufficient_stats))

	# Show matching count
	var matching_count: int = QuestMatcher.count_matching_creatures(test_objective, test_creatures)
	var can_complete: bool = QuestMatcher.can_complete_objective(test_objective, test_creatures)
	print("\n📊 Summary: %d creatures match | Can complete: %s" % [matching_count, str(can_complete)])

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_complete_quest_objective() -> void:
	print("\n" + "============================================================")
	print("STEP 7: COMPLETING QUEST OBJECTIVE")
	print("============================================================")

	if not quest_system.is_quest_active(current_quest_id):
		print("❌ Quest %s is not active!" % current_quest_id)
		print("\nPress SPACE to continue...")
		is_waiting_for_input = true
		return

	# Get a suitable creature for the objective
	var test_objective: QuestObjective = QuestTestData.get_tim_quest_objectives()[current_quest_id]
	var suitable_creatures: Array[CreatureData] = QuestMatcher.find_matching_creatures(test_objective, test_creatures)

	if suitable_creatures.is_empty():
		print("❌ No suitable creatures found for objective!")
		print("\nPress SPACE to continue...")
		is_waiting_for_input = true
		return

	var selected_creature: CreatureData = suitable_creatures[0]
	print("🎯 Completing objective with creature: %s" % selected_creature.creature_name)

	# Complete the objective
	var success: bool = quest_system.complete_objective(current_quest_id, 0, [selected_creature])

	if success:
		print("✅ Objective completed successfully!")

		# Show quest progress
		var progress: Dictionary = quest_system.get_quest_progress(current_quest_id)
		print("📊 Quest progress: %d/%d objectives completed" % [
			progress.get("completed_objectives", 0),
			progress.get("total_objectives", 0)
		])
	else:
		print("❌ Failed to complete objective")

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_complete_quest() -> void:
	print("\n" + "============================================================")
	print("STEP 8: QUEST COMPLETION")
	print("============================================================")

	print("🏆 Checking quest completion status...")

	var is_completed: bool = quest_system.is_quest_completed(current_quest_id)
	var is_active: bool = quest_system.is_quest_active(current_quest_id)

	print("📊 Quest Status:")
	print("  • Active: %s" % str(is_active))
	print("  • Completed: %s" % str(is_completed))

	if is_completed:
		print("🎉 Quest %s has been completed!" % current_quest_id)

		# Show completed quest data
		var quest_resource: Dictionary = quest_system.get_quest_resource(current_quest_id)
		var rewards: Dictionary = quest_resource.get("rewards", {})
		print("🎁 Rewards granted:")
		for reward_type in rewards.keys():
			print("  • %s: %s" % [reward_type, str(rewards[reward_type])])
	else:
		print("⏳ Quest is still in progress")

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_start_advanced_quest() -> void:
	print("\n" + "============================================================")
	print("STEP 9: ADVANCED QUEST - TIM-02")
	print("============================================================")

	current_quest_id = "TIM-02"
	var quest_resource: Dictionary = quest_system.get_quest_resource(current_quest_id)

	print("🚀 Starting advanced quest: %s" % quest_resource.get("title", "Unknown"))
	print("📝 Description: %s" % quest_resource.get("description", "No description"))

	# Show this quest's specific requirements
	var test_objective: QuestObjective = QuestTestData.get_tim_quest_objectives()[current_quest_id]
	print("🎯 Requirements:")
	print("  • Required tags: %s" % str(test_objective.required_tags))
	print("  • Required stats: %s" % str(test_objective.required_stats))
	print("  • Quantity needed: %d" % test_objective.quantity)

	# Start the quest
	var success: bool = quest_system.start_quest(current_quest_id)
	if success:
		print("✅ Advanced quest started successfully!")
	else:
		print("❌ Failed to start advanced quest")

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_test_multiple_objectives() -> void:
	print("\n" + "============================================================")
	print("STEP 10: MULTIPLE OBJECTIVE TESTING")
	print("============================================================")

	print("🎯 Testing quest with specific tag requirements...")

	if quest_system.is_quest_active(current_quest_id):
		var test_objective: QuestObjective = QuestTestData.get_tim_quest_objectives()[current_quest_id]

		# Find matching creatures
		var matching_creatures: Array[CreatureData] = QuestMatcher.find_matching_creatures(test_objective, test_creatures)

		print("🔍 Creatures matching %s requirements:" % current_quest_id)
		for creature in matching_creatures:
			print("  ✅ %s (tags: %s)" % [creature.creature_name, str(creature.tags)])

		if not matching_creatures.is_empty():
			var selected_creature: CreatureData = matching_creatures[0]
			print("\n🎯 Completing objective with: %s" % selected_creature.creature_name)

			var success: bool = quest_system.complete_objective(current_quest_id, 0, [selected_creature])
			if success:
				print("✅ Objective completed!")
			else:
				print("❌ Failed to complete objective")
		else:
			print("❌ No suitable creatures found for this quest")
	else:
		print("❌ No active quest to test")

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_demonstrate_prerequisites() -> void:
	print("\n" + "============================================================")
	print("STEP 11: PREREQUISITE SYSTEM")
	print("============================================================")

	print("🔒 Testing quest prerequisite system...")

	# Show current completed quests
	print("📋 Completed quests:")
	for i in range(quest_system.completed_quests.size()):
		print("  • %s" % quest_system.completed_quests[i])

	# Test prerequisites for remaining quests
	var all_quest_ids: Array = quest_system.quest_resources.keys()
	print("\n🔍 Checking prerequisites for all quests:")

	for quest_id in all_quest_ids:
		var can_start: bool = quest_system.check_prerequisites(quest_id)
		var is_active: bool = quest_system.is_quest_active(quest_id)
		var is_completed: bool = quest_system.is_quest_completed(quest_id)

		var status: String = ""
		if is_completed:
			status = "✅ COMPLETED"
		elif is_active:
			status = "🔄 ACTIVE"
		elif can_start:
			status = "🟢 AVAILABLE"
		else:
			status = "🔒 LOCKED"

		print("  • %s: %s" % [quest_id, status])

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_show_quest_progress() -> void:
	print("\n" + "============================================================")
	print("STEP 12: QUEST PROGRESS TRACKING")
	print("============================================================")

	print("📊 Current quest system state:")

	# Show active quests
	var active_quest_count: int = quest_system.active_quests.size()
	print("🔄 Active quests: %d" % active_quest_count)
	for quest_id in quest_system.active_quests.keys():
		var progress: Dictionary = quest_system.get_quest_progress(quest_id)
		print("  • %s: %d/%d objectives completed" % [
			quest_id,
			progress.get("completed_objectives", 0),
			progress.get("total_objectives", 0)
		])

	# Show completed quests
	print("✅ Completed quests: %d" % quest_system.completed_quests.size())
	for quest_id in quest_system.completed_quests:
		print("  • %s" % quest_id)

	# Show available quests
	var available_quests: Array[String] = quest_system.get_available_quests()
	print("📋 Available quests: %d" % available_quests.size())
	for quest_id in available_quests:
		print("  • %s" % quest_id)

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_test_reward_system() -> void:
	print("\n" + "============================================================")
	print("STEP 13: REWARD SYSTEM")
	print("============================================================")

	print("🎁 Quest reward system overview:")
	print("The quest system supports multiple reward types:")
	print("  • 💰 Gold rewards")
	print("  • 📦 Item rewards")
	print("  • ⭐ Experience points")
	print("  • 🔓 Unlock rewards (features, abilities, etc.)")

	print("\n🔍 Analyzing reward data from all quests:")

	var total_gold: int = 0
	var total_xp: int = 0
	var all_items: Array[String] = []
	var all_unlocks: Array[String] = []

	for quest_id in quest_system.quest_resources.keys():
		var quest_resource: Dictionary = quest_system.quest_resources[quest_id]
		var rewards: Dictionary = quest_resource.get("rewards", {})

		if rewards.has("gold"):
			total_gold += rewards.gold
		if rewards.has("xp"):
			total_xp += rewards.xp
		if rewards.has("items"):
			for item in rewards.items:
				if not all_items.has(item):
					all_items.append(item)
		if rewards.has("unlocks"):
			for unlock in rewards.unlocks:
				if not all_unlocks.has(unlock):
					all_unlocks.append(unlock)

	print("📊 Total rewards available:")
	print("  • Gold: %d" % total_gold)
	print("  • Experience: %d XP" % total_xp)
	print("  • Unique items: %d" % all_items.size())
	print("  • Unlocks: %d" % all_unlocks.size())

	if not all_unlocks.is_empty():
		print("🔓 Available unlocks:")
		for unlock in all_unlocks:
			print("    • %s" % unlock)

	print("\nPress SPACE to continue...")
	is_waiting_for_input = true

func _step_conclusion() -> void:
	print("\n" + "============================================================")
	print("STEP 14: WALKTHROUGH CONCLUSION")
	print("============================================================")

	print("🎉 Quest System Walkthrough Complete!")
	print("\n✅ Features demonstrated:")
	print("  • Quest resource loading and management")
	print("  • Prerequisite checking and quest availability")
	print("  • Objective matching with creature requirements")
	print("  • Quest progression and completion tracking")
	print("  • Signal-based event notifications")
	print("  • Reward system analysis")
	print("  • Progress tracking and state management")

	print("\n📊 Final System Statistics:")
	print("  • Total quests loaded: %d" % quest_system.quest_resources.size())
	print("  • Active quests: %d" % quest_system.active_quests.size())
	print("  • Completed quests: %d" % quest_system.completed_quests.size())
	print("  • Test creatures generated: %d" % test_creatures.size())

	print("\n🚀 The quest system is ready for production use!")
	print("📖 Refer to the quest system documentation for integration details.")

	print("\nPress SPACE to exit...")
	is_waiting_for_input = true

func _finish_walkthrough() -> void:
	print("\n👋 Thank you for testing the Quest System!")
	print("Exiting in 2 seconds...")
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

# === SIGNAL HANDLERS ===

func _on_quest_started(quest_id: String) -> void:
	print("🔔 SIGNAL: Quest started - %s" % quest_id)

func _on_quest_completed(quest_id: String) -> void:
	print("🔔 SIGNAL: Quest completed - %s" % quest_id)

func _on_quest_objective_completed(quest_id: String, objective_index: int) -> void:
	print("🔔 SIGNAL: Objective completed - %s (objective %d)" % [quest_id, objective_index])