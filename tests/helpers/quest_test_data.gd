@tool
class_name QuestTestData

# Test data generator for quest system validation
# Generates mock creatures and quest scenarios for comprehensive testing

# === MOCK CREATURE GENERATION ===

## Generate a creature that exactly matches the given objective requirements
static func create_matching_creature(objective: QuestObjective) -> CreatureData:
	var creature: CreatureData = _create_base_creature()

	# Apply required tags directly to the tags array
	for tag in objective.required_tags:
		if not creature.tags.has(tag):
			creature.tags.append(tag)

	# Set minimum required stats
	for stat_name in objective.required_stats.keys():
		var required_value: int = objective.required_stats[stat_name]
		creature.set_stat(stat_name, required_value)

	return creature

## Generate a creature that fails to match objective requirements (missing one requirement)
static func create_failing_creature(objective: QuestObjective) -> CreatureData:
	var creature: CreatureData = _create_base_creature()

	# Apply most requirements but deliberately fail one
	if not objective.required_tags.is_empty():
		# Add all tags except the first one
		for i in range(1, objective.required_tags.size()):
			if not creature.tags.has(objective.required_tags[i]):
				creature.tags.append(objective.required_tags[i])
	elif not objective.required_stats.is_empty():
		# If no tag requirements, set stats below threshold
		for stat_name in objective.required_stats.keys():
			var required_value: int = objective.required_stats[stat_name]
			creature.set_stat(stat_name, max(0, required_value - 1))
	else:
		# For objectives with no specific requirements (like TIM-01),
		# we can't create a truly "failing" creature since any creature matches.
		# This is actually correct behavior - return a valid creature.
		pass

	return creature

## Generate a creature that exceeds all objective requirements (over-qualified)
static func create_overqualified_creature(objective: QuestObjective) -> CreatureData:
	var creature: CreatureData = _create_base_creature()

	# Apply all required tags plus extras
	for tag in objective.required_tags:
		if not creature.tags.has(tag):
			creature.tags.append(tag)

	# Add some bonus tags for variety
	var bonus_tags: Array[String] = ["rare", "powerful", "ancient"]
	for tag in bonus_tags:
		if not objective.required_tags.has(tag) and not creature.tags.has(tag):
			creature.tags.append(tag)

	# Set stats significantly above requirements
	for stat_name in objective.required_stats.keys():
		var required_value: int = objective.required_stats[stat_name]
		creature.set_stat(stat_name, required_value + 20)

	return creature

## Generate a collection of mixed creatures for testing
static func create_mixed_creature_collection(objective: QuestObjective, total_count: int = 10) -> Array[CreatureData]:
	var collection: Array[CreatureData] = []

	# Create a balanced mix of creature types
	var matching_count: int = max(1, total_count / 3)
	var failing_count: int = max(1, total_count / 3)
	var overqualified_count: int = total_count - matching_count - failing_count

	# Add matching creatures
	for i in range(matching_count):
		var creature: CreatureData = create_matching_creature(objective)
		creature.creature_name = "Match_%d" % i
		creature.id = "match_%d" % i
		collection.append(creature)

	# Add failing creatures
	for i in range(failing_count):
		var creature: CreatureData = create_failing_creature(objective)
		creature.creature_name = "Fail_%d" % i
		creature.id = "fail_%d" % i
		collection.append(creature)

	# Add overqualified creatures
	for i in range(overqualified_count):
		var creature: CreatureData = create_overqualified_creature(objective)
		creature.creature_name = "Over_%d" % i
		creature.id = "over_%d" % i
		collection.append(creature)

	return collection

# === TIM QUEST TEST CASES ===

## Generate test objectives for all 6 Tim quests
static func get_tim_quest_objectives() -> Dictionary:
	var objectives: Dictionary = {}

	# TIM-01: First Steps - Basic collection objective
	objectives["TIM-01"] = QuestObjective.new(
		QuestObjective.ObjectiveType.PROVIDE_CREATURE,
		[],  # No specific tags required
		{},  # No stat requirements
		1,   # Just need 1 creature
		"Acquire your first creature"
	)

	# TIM-02: Show me a Scout - Specific tag requirement
	objectives["TIM-02"] = QuestObjective.new(
		QuestObjective.ObjectiveType.PROVIDE_CREATURE,
		["scout"],
		{},
		1,
		"Provide a creature with scout capabilities"
	)

	# TIM-03: Strong and Swift - Multiple stat requirements
	objectives["TIM-03"] = QuestObjective.new(
		QuestObjective.ObjectiveType.PROVIDE_CREATURE,
		[],
		{"strength": 15, "dexterity": 12},
		1,
		"Provide a creature with high strength and dexterity"
	)

	# TIM-04: Multiple Scouts - Quantity requirement
	objectives["TIM-04"] = QuestObjective.new(
		QuestObjective.ObjectiveType.PROVIDE_MULTIPLE,
		["scout"],
		{},
		3,
		"Provide 3 creatures with scout capabilities"
	)

	# TIM-05: Elite Guard - High stat and tag requirements
	objectives["TIM-05"] = QuestObjective.new(
		QuestObjective.ObjectiveType.PROVIDE_CREATURE,
		["guard", "elite"],
		{"strength": 20, "constitution": 18},
		1,
		"Provide an elite guard with exceptional combat stats"
	)

	# TIM-06: Research Team - Multiple creatures with different specializations
	objectives["TIM-06"] = QuestObjective.new(
		QuestObjective.ObjectiveType.PROVIDE_MULTIPLE,
		["research"],
		{"intelligence": 15},
		2,
		"Provide 2 research specialists with high intelligence"
	)

	return objectives

## Generate test creatures specifically for Tim quest validation
static func create_tim_quest_test_creatures() -> Dictionary:
	var test_creatures: Dictionary = {}
	var objectives: Dictionary = get_tim_quest_objectives()

	for quest_id in objectives.keys():
		var objective: QuestObjective = objectives[quest_id]
		test_creatures[quest_id] = {
			"matching": create_matching_creature(objective),
			"failing": create_failing_creature(objective),
			"overqualified": create_overqualified_creature(objective),
			"collection": create_mixed_creature_collection(objective, 8)
		}

	return test_creatures

# === EDGE CASE SCENARIOS ===

## Create edge case test scenarios
static func create_edge_case_scenarios() -> Dictionary:
	var scenarios: Dictionary = {}

	# Scenario 1: Null/empty inputs
	scenarios["null_objective"] = {
		"objective": null,
		"creatures": [_create_base_creature()]
	}

	scenarios["empty_collection"] = {
		"objective": QuestObjective.new(QuestObjective.ObjectiveType.PROVIDE_CREATURE, ["scout"], {}, 1),
		"creatures": []
	}

	# Scenario 2: Borderline stat cases
	var borderline_objective: QuestObjective = QuestObjective.new(
		QuestObjective.ObjectiveType.PROVIDE_CREATURE,
		[],
		{"strength": 10},
		1
	)

	var exactly_meeting_creature: CreatureData = _create_base_creature()
	exactly_meeting_creature.set_stat("strength", 10)

	var just_below_creature: CreatureData = _create_base_creature()
	just_below_creature.set_stat("strength", 9)

	scenarios["borderline_stats"] = {
		"objective": borderline_objective,
		"exactly_meeting": exactly_meeting_creature,
		"just_below": just_below_creature
	}

	# Scenario 3: Large quantity requirements
	scenarios["high_quantity"] = {
		"objective": QuestObjective.new(QuestObjective.ObjectiveType.PROVIDE_MULTIPLE, ["common"], {}, 10),
		"sufficient_collection": _create_creatures_with_tags(["common"], 10),
		"insufficient_collection": _create_creatures_with_tags(["common"], 5)
	}

	return scenarios

# === SAVE/LOAD TEST DATA ===

## Generate quest progress states for save/load testing
static func create_quest_progress_test_data() -> Dictionary:
	var progress_data: Dictionary = {}

	# Fresh quest (just started)
	progress_data["fresh_quest"] = {
		"quest_id": "TIM-01",
		"started_at": Time.get_ticks_msec(),
		"objectives": [{"completed": false, "completed_at": 0}],
		"completed_at": 0
	}

	# Partially completed quest
	progress_data["partial_quest"] = {
		"quest_id": "TIM-04",
		"started_at": Time.get_ticks_msec() - 60000,  # Started 1 minute ago
		"objectives": [
			{"completed": true, "completed_at": Time.get_ticks_msec() - 30000},
			{"completed": false, "completed_at": 0}
		],
		"completed_at": 0
	}

	# Completed quest
	progress_data["completed_quest"] = {
		"quest_id": "TIM-02",
		"started_at": Time.get_ticks_msec() - 120000,  # Started 2 minutes ago
		"objectives": [{"completed": true, "completed_at": Time.get_ticks_msec() - 60000}],
		"completed_at": Time.get_ticks_msec() - 60000
	}

	return progress_data

# === PRIVATE HELPERS ===

static func _create_base_creature() -> CreatureData:
	var creature: CreatureData = CreatureData.new()
	creature.id = "test_creature_%d" % randi()
	creature.creature_name = "Test Creature"
	creature.species_id = "scuttleguard"
	creature.age_weeks = 5
	creature.lifespan_weeks = 100

	# Set base stats using valid stat names
	creature.set_stat("strength", 10)
	creature.set_stat("dexterity", 10)
	creature.set_stat("constitution", 10)
	creature.set_stat("intelligence", 10)

	return creature

static func _create_creatures_with_tags(tags: Array[String], count: int) -> Array[CreatureData]:
	var creatures: Array[CreatureData] = []

	for i in range(count):
		var creature: CreatureData = _create_base_creature()
		creature.id = "tagged_creature_%d" % i
		creature.creature_name = "Tagged_%d" % i

		for tag in tags:
			if not creature.tags.has(tag):
				creature.tags.append(tag)

		creatures.append(creature)

	return creatures