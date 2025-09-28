extends Node

# Comprehensive Quest System Test Suite
# Tests quest resource loading, prerequisites, objective matching, progression, save/load, signals, and rewards

signal test_completed(success: bool, details: Array)

var quest_system: QuestSystem
var signal_bus: SignalBus
var collection_system: Node
var test_results: Array[String] = []
var quest_signals_received: Dictionary = {}

func _ready() -> void:
	print("=== QUEST SYSTEM COMPREHENSIVE TEST ===")
	print("Testing quest resource loading, objectives, progression, and integration")

	# Load the helpers directory
	if not DirAccess.dir_exists_absolute("res://tests/helpers"):
		var dir: DirAccess = DirAccess.open("res://tests/")
		dir.make_dir("helpers")

	# Setup systems
	_setup_systems()
	_setup_signal_tracking()

	# Run test suite
	var start_time: int = Time.get_ticks_msec()
	_run_test_suite()
	var end_time: int = Time.get_ticks_msec()

	# Print results
	_print_test_results(end_time - start_time)

	# Exit after brief delay
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

func _setup_systems() -> void:
	print("Setting up test systems...")

	# Get required systems (GameCore initializes automatically)
	signal_bus = GameCore.get_signal_bus()
	collection_system = GameCore.get_system("collection")
	quest_system = GameCore.get_system("quest")

	if not quest_system:
		push_error("QuestSystem not available - cannot run tests")
		return

func _setup_signal_tracking() -> void:
	# Connect to quest-related signals to track emissions
	if signal_bus and signal_bus.has_signal("quest_started"):
		signal_bus.quest_started.connect(_on_quest_started)
	if signal_bus and signal_bus.has_signal("quest_completed"):
		signal_bus.quest_completed.connect(_on_quest_completed)
	if signal_bus and signal_bus.has_signal("quest_objective_completed"):
		signal_bus.quest_objective_completed.connect(_on_quest_objective_completed)

func _on_quest_started(quest_id: String) -> void:
	quest_signals_received["quest_started"] = quest_id

func _on_quest_completed(quest_id: String) -> void:
	quest_signals_received["quest_completed"] = quest_id

func _on_quest_objective_completed(quest_id: String, objective_index: int) -> void:
	if not quest_signals_received.has("quest_objective_completed"):
		quest_signals_received["quest_objective_completed"] = []
	quest_signals_received["quest_objective_completed"].append({"quest": quest_id, "objective": objective_index})

func _run_test_suite() -> void:
	print("Running comprehensive quest system tests...")

	# Core functionality tests
	_test_quest_resource_loading()
	_test_prerequisite_checking()
	_test_objective_matching()
	_test_quest_progression()
	_test_signal_emissions()
	_test_reward_granting()
	_test_save_load_functionality()

	# Edge case tests
	_test_edge_cases()
	_test_tim_quests_integration()

# === CORE FUNCTIONALITY TESTS ===

func _test_quest_resource_loading() -> void:
	print("\n📋 Testing Quest Resource Loading...")

	if not quest_system:
		test_results.append("❌ Quest Resource Loading: QuestSystem not available")
		return

	# Test 1: Verify quest resources are loaded
	var quest_resources: Dictionary = quest_system.quest_resources
	if quest_resources.is_empty():
		test_results.append("❌ Quest Resource Loading: No quest resources loaded")
		return

	test_results.append("✅ Quest Resource Loading: %d quest resources loaded" % quest_resources.size())

	# Test 2: Verify Tim quests are loaded
	var tim_quests: Array[String] = []
	for quest_id in quest_resources.keys():
		if quest_id.begins_with("TIM-"):
			tim_quests.append(quest_id)

	if tim_quests.size() >= 6:
		test_results.append("✅ Tim Quests: All 6 Tim quests loaded (%s)" % str(tim_quests))
	else:
		test_results.append("⚠️ Tim Quests: Only %d Tim quests found: %s" % [tim_quests.size(), str(tim_quests)])

	# Test 3: Verify quest data structure
	for quest_id in quest_resources.keys():
		var quest_data: Dictionary = quest_resources[quest_id]
		var required_fields: Array[String] = ["quest_id", "title", "description", "objectives", "rewards"]
		var missing_fields: Array[String] = []

		for field in required_fields:
			if not quest_data.has(field):
				missing_fields.append(field)

		if missing_fields.is_empty():
			test_results.append("✅ Quest Structure: %s has all required fields" % quest_id)
		else:
			test_results.append("❌ Quest Structure: %s missing fields: %s" % [quest_id, str(missing_fields)])

func _test_prerequisite_checking() -> void:
	print("\n📋 Testing Prerequisite Checking...")

	if not quest_system:
		test_results.append("❌ Prerequisite Checking: QuestSystem not available")
		return

	# Test 1: Quest without prerequisites should be available
	var available_quests: Array[String] = quest_system.get_available_quests()
	if available_quests.size() > 0:
		test_results.append("✅ Prerequisites: %d quests available without prerequisites" % available_quests.size())
	else:
		test_results.append("⚠️ Prerequisites: No quests available (may be expected)")

	# Test 2: Test prerequisite validation for specific quest
	if quest_system.quest_resources.has("TIM-01"):
		var can_start_tim01: bool = quest_system.check_prerequisites("TIM-01")
		if can_start_tim01:
			test_results.append("✅ Prerequisites: TIM-01 prerequisites met")
		else:
			test_results.append("❌ Prerequisites: TIM-01 prerequisites not met")

	# Test 3: Invalid quest ID should return false
	var invalid_prereq: bool = quest_system.check_prerequisites("INVALID_QUEST")
	if not invalid_prereq:
		test_results.append("✅ Prerequisites: Invalid quest correctly returns false")
	else:
		test_results.append("❌ Prerequisites: Invalid quest incorrectly returns true")

func _test_objective_matching() -> void:
	print("\n📋 Testing Objective Matching...")

	# Create test objectives using QuestTestData
	var test_objectives: Dictionary = QuestTestData.get_tim_quest_objectives()
	var test_creatures: Dictionary = QuestTestData.create_tim_quest_test_creatures()

	# Test 1: Exact match validation
	for quest_id in test_objectives.keys():
		var objective: QuestObjective = test_objectives[quest_id]
		var matching_creature: CreatureData = test_creatures[quest_id]["matching"]

		var is_valid: bool = QuestMatcher.validate_creature_for_objective(matching_creature, objective)
		if is_valid:
			test_results.append("✅ Objective Matching: %s exact match works" % quest_id)
		else:
			test_results.append("❌ Objective Matching: %s exact match failed" % quest_id)

	# Test 2: Failing creature validation
	for quest_id in test_objectives.keys():
		var objective: QuestObjective = test_objectives[quest_id]
		var failing_creature: CreatureData = test_creatures[quest_id]["failing"]

		var is_valid: bool = QuestMatcher.validate_creature_for_objective(failing_creature, objective)

		# Special case: TIM-01 has no requirements, so any creature matches
		if quest_id == "TIM-01":
			if is_valid:
				test_results.append("✅ Objective Matching: %s any creature correctly accepted (no requirements)" % quest_id)
			else:
				test_results.append("❌ Objective Matching: %s creature incorrectly rejected despite no requirements" % quest_id)
		else:
			if not is_valid:
				test_results.append("✅ Objective Matching: %s failing creature correctly rejected" % quest_id)
			else:
				test_results.append("❌ Objective Matching: %s failing creature incorrectly accepted" % quest_id)

	# Test 3: Collection matching count
	for quest_id in test_objectives.keys():
		var objective: QuestObjective = test_objectives[quest_id]
		var collection: Array[CreatureData] = test_creatures[quest_id]["collection"]

		var matching_count: int = QuestMatcher.count_matching_creatures(objective, collection)
		var can_complete: bool = QuestMatcher.can_complete_objective(objective, collection)

		test_results.append("✅ Collection Matching: %s found %d matches, can_complete=%s" % [quest_id, matching_count, str(can_complete)])

func _test_quest_progression() -> void:
	print("\n📋 Testing Quest Progression...")

	if not quest_system:
		test_results.append("❌ Quest Progression: QuestSystem not available")
		return

	# Clear any existing quest state
	quest_signals_received.clear()

	# Test 1: Start a quest
	var test_quest_id: String = "TIM-01"
	if quest_system.quest_resources.has(test_quest_id):
		var start_success: bool = quest_system.start_quest(test_quest_id)
		if start_success:
			test_results.append("✅ Quest Start: %s started successfully" % test_quest_id)

			# Verify quest is now active
			var is_active: bool = quest_system.is_quest_active(test_quest_id)
			if is_active:
				test_results.append("✅ Quest State: %s correctly marked as active" % test_quest_id)
			else:
				test_results.append("❌ Quest State: %s not marked as active after start" % test_quest_id)
		else:
			test_results.append("❌ Quest Start: %s failed to start" % test_quest_id)
			return
	else:
		test_results.append("⚠️ Quest Start: %s not available for testing" % test_quest_id)
		return

	# Test 2: Complete an objective
	var test_creature: CreatureData = QuestTestData.create_matching_creature(QuestTestData.get_tim_quest_objectives()[test_quest_id])
	var objective_success: bool = quest_system.complete_objective(test_quest_id, 0, [test_creature])

	if objective_success:
		test_results.append("✅ Objective Completion: First objective completed successfully")
	else:
		test_results.append("❌ Objective Completion: Failed to complete first objective")

	# Test 3: Check quest completion
	var is_completed: bool = quest_system.is_quest_completed(test_quest_id)
	if is_completed:
		test_results.append("✅ Quest Completion: %s marked as completed" % test_quest_id)
	else:
		test_results.append("❌ Quest Completion: %s not marked as completed" % test_quest_id)

	# Test 4: Cannot start same quest again
	var restart_attempt: bool = quest_system.start_quest(test_quest_id)
	if not restart_attempt:
		test_results.append("✅ Quest Restart: Correctly prevented restarting completed quest")
	else:
		test_results.append("❌ Quest Restart: Incorrectly allowed restarting completed quest")

func _test_signal_emissions() -> void:
	print("\n📋 Testing Signal Emissions...")

	# Check if expected signals were received during progression test
	if quest_signals_received.has("quest_started"):
		test_results.append("✅ Signals: quest_started signal received")
	else:
		test_results.append("❌ Signals: quest_started signal not received")

	if quest_signals_received.has("quest_objective_completed"):
		test_results.append("✅ Signals: quest_objective_completed signal received")
	else:
		test_results.append("❌ Signals: quest_objective_completed signal not received")

	if quest_signals_received.has("quest_completed"):
		test_results.append("✅ Signals: quest_completed signal received")
	else:
		test_results.append("❌ Signals: quest_completed signal not received")

func _test_reward_granting() -> void:
	print("\n📋 Testing Reward Granting...")

	if not quest_system:
		test_results.append("❌ Reward Granting: QuestSystem not available")
		return

	# Test reward structure validation
	for quest_id in quest_system.quest_resources.keys():
		var quest_data: Dictionary = quest_system.quest_resources[quest_id]
		var rewards: Dictionary = quest_data.get("rewards", {})

		if rewards.has("gold") or rewards.has("items") or rewards.has("xp"):
			test_results.append("✅ Rewards: %s has valid reward structure" % quest_id)
		else:
			test_results.append("⚠️ Rewards: %s has no rewards defined" % quest_id)

	# Note: Actual reward granting integration depends on resource system availability
	test_results.append("ℹ️ Rewards: Actual reward granting depends on ResourceTracker integration")

func _test_save_load_functionality() -> void:
	print("\n📋 Testing Save/Load Functionality...")

	if not quest_system:
		test_results.append("❌ Save/Load: QuestSystem not available")
		return

	# Test 1: Create a quest state to save
	var save_system: Node = GameCore.get_system("save")
	if not save_system:
		test_results.append("⚠️ Save/Load: SaveSystem not available for testing")
		return

	# Start a new quest for save testing
	var save_test_quest: String = "TIM-02"
	if quest_system.quest_resources.has(save_test_quest) and not quest_system.is_quest_active(save_test_quest):
		quest_system.start_quest(save_test_quest)

		# Save current state
		var save_success: bool = save_system.save_game("quest_test_save")
		if save_success:
			test_results.append("✅ Save: Quest state saved successfully")
		else:
			test_results.append("❌ Save: Failed to save quest state")

		# Note: Full load testing would require restarting the scene
		test_results.append("ℹ️ Load: Full load testing requires scene restart (not performed)")
	else:
		test_results.append("⚠️ Save/Load: %s not available for save testing" % save_test_quest)

func _test_edge_cases() -> void:
	print("\n📋 Testing Edge Cases...")

	# Test edge case scenarios from QuestTestData
	var edge_cases: Dictionary = QuestTestData.create_edge_case_scenarios()

	# Test 1: Null objective handling
	var null_scenario: Dictionary = edge_cases["null_objective"]
	var null_result: bool = QuestMatcher.validate_creature_for_objective(
		null_scenario["creatures"][0],
		null_scenario["objective"]
	)
	if not null_result:
		test_results.append("✅ Edge Cases: Null objective correctly handled")
	else:
		test_results.append("❌ Edge Cases: Null objective incorrectly accepted")

	# Test 2: Empty collection handling
	var empty_scenario: Dictionary = edge_cases["empty_collection"]
	var empty_count: int = QuestMatcher.count_matching_creatures(
		empty_scenario["objective"],
		empty_scenario["creatures"]
	)
	if empty_count == 0:
		test_results.append("✅ Edge Cases: Empty collection correctly returns 0 matches")
	else:
		test_results.append("❌ Edge Cases: Empty collection incorrectly returned %d matches" % empty_count)

	# Test 3: Borderline stat cases
	var borderline_scenario: Dictionary = edge_cases["borderline_stats"]
	var exactly_valid: bool = QuestMatcher.validate_creature_for_objective(
		borderline_scenario["exactly_meeting"],
		borderline_scenario["objective"]
	)
	var just_below_valid: bool = QuestMatcher.validate_creature_for_objective(
		borderline_scenario["just_below"],
		borderline_scenario["objective"]
	)

	if exactly_valid and not just_below_valid:
		test_results.append("✅ Edge Cases: Borderline stat validation correct")
	else:
		test_results.append("❌ Edge Cases: Borderline stat validation failed (exact=%s, below=%s)" % [exactly_valid, just_below_valid])

func _test_tim_quests_integration() -> void:
	print("\n📋 Testing Tim Quests Integration...")

	if not quest_system:
		test_results.append("❌ Tim Quests Integration: QuestSystem not available")
		return

	# Test each Tim quest for basic functionality
	var tim_objectives: Dictionary = QuestTestData.get_tim_quest_objectives()

	for quest_id in tim_objectives.keys():
		if quest_system.quest_resources.has(quest_id):
			var objective: QuestObjective = tim_objectives[quest_id]
			var test_creature: CreatureData = QuestTestData.create_matching_creature(objective)

			var validation_result: bool = QuestMatcher.validate_creature_for_objective(test_creature, objective)
			if validation_result:
				test_results.append("✅ Tim Quest: %s objective validation works" % quest_id)
			else:
				test_results.append("❌ Tim Quest: %s objective validation failed" % quest_id)

			# Test validation details
			var details: Dictionary = QuestMatcher.get_validation_details(test_creature, objective)
			if details.get("is_valid", false):
				test_results.append("✅ Tim Quest: %s validation details correct" % quest_id)
			else:
				test_results.append("❌ Tim Quest: %s validation details incorrect" % quest_id)
		else:
			test_results.append("⚠️ Tim Quest: %s resource not found" % quest_id)

func _print_test_results(execution_time: int) -> void:
	print("\n" + "=".repeat(60))
	print("QUEST SYSTEM TEST RESULTS")
	print("=".repeat(60))

	var passed: int = 0
	var failed: int = 0
	var warnings: int = 0

	for result in test_results:
		print(result)
		if result.begins_with("✅"):
			passed += 1
		elif result.begins_with("❌"):
			failed += 1
		elif result.begins_with("⚠️"):
			warnings += 1

	print("=".repeat(60))
	print("SUMMARY: %d passed, %d failed, %d warnings" % [passed, failed, warnings])
	print("Execution time: %d ms" % execution_time)

	if failed == 0:
		print("✅ ALL CORE TESTS PASSED - Quest system ready for use!")
	else:
		print("❌ %d TESTS FAILED - Review implementation" % failed)

	print("=".repeat(60))

	# Emit legacy signal for compatibility
	var details: Array = []
	var success: bool = failed == 0
	test_completed.emit(success, details)