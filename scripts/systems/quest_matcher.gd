class_name QuestMatcher

# Static utility class for matching creatures to quest requirements
# Provides centralized quest validation logic following system patterns

# === CORE MATCHING METHODS ===

## Find all creatures from a collection that match the given objective
static func find_matching_creatures(objective: QuestObjective, collection: Array[CreatureData]) -> Array[CreatureData]:
	if not objective:
		push_error("QuestMatcher.find_matching_creatures: objective cannot be null")
		return []

	if collection.is_empty():
		return []

	var matching_creatures: Array[CreatureData] = []

	for creature in collection:
		if creature == null:
			continue

		if validate_creature_for_objective(creature, objective):
			matching_creatures.append(creature)

	return matching_creatures

## Validate a single creature against quest objective requirements
static func validate_creature_for_objective(creature: CreatureData, objective: QuestObjective) -> bool:
	if not creature or not objective:
		return false

	# Check tag requirements (AND logic - creature must have ALL required tags)
	if not _validate_tags(creature, objective.required_tags):
		return false

	# Check stat requirements (creature must meet ALL minimum stat requirements)
	if not _validate_stats(creature, objective.required_stats):
		return false

	return true

## Get the count of creatures that would satisfy the objective requirements
static func count_matching_creatures(objective: QuestObjective, collection: Array[CreatureData]) -> int:
	var matching_creatures: Array[CreatureData] = find_matching_creatures(objective, collection)
	return matching_creatures.size()

## Check if objective can be completed with available creatures
static func can_complete_objective(objective: QuestObjective, collection: Array[CreatureData]) -> bool:
	if not objective:
		return false

	var matching_count: int = count_matching_creatures(objective, collection)
	return matching_count >= objective.quantity

## Get detailed validation result for UI feedback
static func get_validation_details(creature: CreatureData, objective: QuestObjective) -> Dictionary:
	var result: Dictionary = {
		"is_valid": false,
		"missing_tags": [],
		"insufficient_stats": {}
	}

	if not creature or not objective:
		return result

	# Check tags
	var missing_tags: Array[String] = []
	for tag in objective.required_tags:
		if not creature.has_tag(tag):
			missing_tags.append(tag)

	result.missing_tags = missing_tags

	# Check stats
	var insufficient_stats: Dictionary = {}
	for stat_name in objective.required_stats.keys():
		var required_value: int = objective.required_stats[stat_name]
		var creature_value: int = creature.get_stat(stat_name)

		if creature_value < required_value:
			insufficient_stats[stat_name] = {
				"required": required_value,
				"actual": creature_value,
				"deficit": required_value - creature_value
			}

	result.insufficient_stats = insufficient_stats
	result.is_valid = missing_tags.is_empty() and insufficient_stats.is_empty()

	return result

## Sort creatures by how well they match objective requirements (best matches first)
static func sort_by_match_quality(creatures: Array[CreatureData], objective: QuestObjective) -> Array[CreatureData]:
	if not objective or creatures.is_empty():
		return creatures

	var sorted_creatures: Array[CreatureData] = creatures.duplicate()

	# Sort using a scoring system
	sorted_creatures.sort_custom(func(a: CreatureData, b: CreatureData) -> bool:
		var score_a: int = _calculate_match_score(a, objective)
		var score_b: int = _calculate_match_score(b, objective)
		return score_a > score_b  # Higher scores first
	)

	return sorted_creatures

# === PRIVATE VALIDATION HELPERS ===

static func _validate_tags(creature: CreatureData, required_tags: Array) -> bool:
	# Empty requirements always pass
	if required_tags.is_empty():
		return true

	# Creature must have ALL required tags (AND logic)
	for tag in required_tags:
		if not creature.has_tag(tag):
			return false

	return true

static func _validate_stats(creature: CreatureData, required_stats: Dictionary) -> bool:
	# Empty requirements always pass
	if required_stats.is_empty():
		return true

	# Creature must meet ALL minimum stat requirements
	for stat_name in required_stats.keys():
		var required_value: int = required_stats[stat_name]
		var creature_value: int = creature.get_stat(stat_name)

		if creature_value < required_value:
			return false

	return true

static func _calculate_match_score(creature: CreatureData, objective: QuestObjective) -> int:
	if not validate_creature_for_objective(creature, objective):
		return 0  # Invalid creatures get zero score

	var score: int = 1000  # Base score for valid creatures

	# Bonus points for exceeding stat requirements
	for stat_name in objective.required_stats.keys():
		var required_value: int = objective.required_stats[stat_name]
		var creature_value: int = creature.get_stat(stat_name)
		var excess: int = creature_value - required_value
		score += excess  # Higher stats = higher score

	# Bonus points for having extra relevant tags (optional enhancement)
	# This could be expanded later to weight certain tag combinations

	return score