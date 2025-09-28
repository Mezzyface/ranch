class_name PlayerCollection
extends Node

# === CONSTANTS ===
const COLLECTION_SAVE_KEY: String = "player_collection"

# === MILESTONES ===
const MILESTONES: Dictionary = {
	"first_creature": 1,
	"small_collection": 5,
	"growing_collection": 10,
	"large_collection": 25,
	"huge_collection": 50,
	"master_collection": 100
}

# === SYSTEM REFERENCES ===
var signal_bus: SignalBus = null
var save_system: Node = null
var age_system: Node = null
var tag_system: Node = null
var facility_system: Node = null

# === COLLECTION DATA ===
# Note: "Active" creatures are now those assigned to facilities (tracked by FacilitySystem)
# All owned creatures are stored in the main collection
var creature_collection: Dictionary = {}  # creature_id -> CreatureData
var collection_metadata: Dictionary = {
	"total_acquired": 0,
	"total_released": 0,
	"species_counts": {},
	"acquisition_history": [],
	"milestones_reached": []
}

# Legacy active roster system (deprecated but still referenced)
const MAX_ACTIVE_CREATURES: int = 6
var active_roster: Array[CreatureData] = []
var stable_collection: Dictionary = {}  # creature_id -> CreatureData
var _active_lookup: Dictionary = {}     # creature_id -> index in active_roster
var _stable_lookup: Dictionary = {}     # creature_id -> CreatureData

# === PERFORMANCE OPTIMIZATIONS ===
var _stats_cache: Dictionary = {}    # cached collection statistics
var _stats_cache_dirty: bool = true
var _quiet_mode: bool = false        # Reduce logging during bulk operations

# === INITIALIZATION ===
func _ready() -> void:
	# Initialize system references
	signal_bus = GameCore.get_signal_bus()

	# Connect to relevant signals
	if signal_bus:
		signal_bus.creature_expired.connect(_on_creature_expired)
		signal_bus.creature_created.connect(_on_creature_created)

	print("PlayerCollection initialized with active/stable roster management")

	# NOTE: Starting creature initialization now handled by starter popup system
	# call_deferred("_initialize_starting_creature")

# === QUIET MODE CONTROL ===
func set_quiet_mode(enabled: bool) -> void:
	"""Enable or disable quiet mode to reduce logging during bulk operations."""
	_quiet_mode = enabled

# === SYSTEM LOADING ===
func _ensure_systems_loaded() -> void:
	"""Ensure required systems are loaded on-demand."""
	if save_system == null:
		save_system = GameCore.get_system("save")
	if age_system == null:
		age_system = GameCore.get_system("age")
	if tag_system == null:
		tag_system = GameCore.get_system("tag")
	if facility_system == null:
		facility_system = GameCore.get_system("facility")

# === CREATURE COLLECTION MANAGEMENT ===
func acquire_creature(creature_data: CreatureData, source: String) -> bool:
	"""Add a creature to the player's collection."""
	if creature_data == null:
		push_error("PlayerCollection: Cannot acquire null creature")
		return false

	if creature_data.id in creature_collection:
		push_warning("PlayerCollection: Creature '%s' already in collection" % creature_data.creature_name)
		return true

	# Add to main collection
	creature_collection[creature_data.id] = creature_data
	_invalidate_stats_cache()

	# Update species tracking
	_update_species_count(creature_data.species_id, 1)

	# Update metadata
	collection_metadata.total_acquired += 1
	_add_to_acquisition_history(creature_data, source)
	_check_milestones()

	# Emit signals
	if signal_bus:
		signal_bus.emit_creature_acquired(creature_data, source)
		# Update active roster signal to use facility-assigned creatures
		signal_bus.emit_active_roster_changed(get_active_creatures())

	if not _quiet_mode:
		print("PlayerCollection: Acquired '%s' from '%s'" % [creature_data.creature_name, source])
	return true

func remove_from_active(creature_id: String) -> bool:
	"""Remove a creature from the active roster."""
	if creature_id.is_empty():
		push_error("PlayerCollection: Cannot remove creature with empty ID")
		return false

	if creature_id not in _active_lookup:
		push_warning("PlayerCollection: Creature ID '%s' not found in active roster" % creature_id)
		return false

	var index: int = _active_lookup[creature_id]
	var creature_data: CreatureData = active_roster[index]

	# Remove from active roster
	active_roster.remove_at(index)
	_active_lookup.erase(creature_id)

	# Update indices in lookup table
	_rebuild_active_lookup()
	_invalidate_stats_cache()

	# Emit signals
	if signal_bus:
		signal_bus.emit_creature_deactivated(creature_data)
		signal_bus.emit_active_roster_changed(active_roster.duplicate())

	print("PlayerCollection: Removed '%s' from active roster (%d/%d)" % [creature_data.creature_name, active_roster.size(), MAX_ACTIVE_CREATURES])
	return true

func move_to_stable(creature_id: String) -> bool:
	"""Move a creature from active roster to stable collection."""
	if creature_id.is_empty():
		push_error("PlayerCollection: Cannot move creature with empty ID")
		return false

	if creature_id not in _active_lookup:
		push_warning("PlayerCollection: Creature ID '%s' not found in active roster" % creature_id)
		return false

	var index: int = _active_lookup[creature_id]
	var creature_data: CreatureData = active_roster[index]

	# Remove from active
	if not remove_from_active(creature_id):
		return false

	# Add to stable
	return add_to_stable(creature_data)

func get_active_creatures() -> Array[CreatureData]:
	"""Get creatures that are assigned to facilities (now considered 'active')."""
	_ensure_systems_loaded()
	var active_creatures: Array[CreatureData] = []

	if facility_system:
		# Get all facility assignments and collect the assigned creatures
		var assignments = facility_system.facility_assignments
		for facility_id in assignments:
			var assignment = assignments[facility_id]
			var creature_id = assignment.creature_id
			if creature_id in creature_collection:
				active_creatures.append(creature_collection[creature_id])

	return active_creatures

func get_all_creatures() -> Array[CreatureData]:
	"""Get all creatures in the collection."""
	var all_creatures: Array[CreatureData] = []
	for creature_data in creature_collection.values():
		all_creatures.append(creature_data)
	return all_creatures

func get_available_for_quest(required_tags: Array[String]) -> Array[CreatureData]:
	"""Get creatures available for quests (not assigned to facilities)."""
	var available: Array[CreatureData] = []
	_ensure_systems_loaded()

	# Get creatures not assigned to facilities
	var active_creature_ids: Array[String] = []
	if facility_system:
		var assignments = facility_system.facility_assignments
		for facility_id in assignments:
			var assignment = assignments[facility_id]
			active_creature_ids.append(assignment.creature_id)

	# Check all creatures for quest availability
	for creature in creature_collection.values():
		if creature == null:
			continue

		# Skip creatures assigned to facilities
		if creature.id in active_creature_ids:
			continue

		# Check if creature meets tag requirements
		var meets_requirements: bool = true
		if tag_system and not required_tags.is_empty():
			meets_requirements = tag_system.meets_tag_requirements(creature, required_tags)

		if meets_requirements:
			available.append(creature)

	return available

# === LEGACY ACTIVE ROSTER METHODS ===
func add_to_active(creature_data: CreatureData) -> bool:
	"""Add a creature to the active roster."""
	if creature_data == null:
		push_error("PlayerCollection: Cannot add null creature to active roster")
		return false

	if active_roster.size() >= MAX_ACTIVE_CREATURES:
		push_error("PlayerCollection: Active roster is full (%d/%d)" % [active_roster.size(), MAX_ACTIVE_CREATURES])
		return false

	if creature_data.id in _active_lookup:
		push_warning("PlayerCollection: Creature '%s' already in active roster" % creature_data.creature_name)
		return true

	# Add to active roster
	active_roster.append(creature_data)
	_active_lookup[creature_data.id] = active_roster.size() - 1
	_invalidate_stats_cache()

	# Add to main collection as well
	creature_collection[creature_data.id] = creature_data

	# Emit signals
	if signal_bus:
		signal_bus.emit_creature_activated(creature_data)
		signal_bus.emit_active_roster_changed(active_roster.duplicate())

	print("PlayerCollection: Added '%s' to active roster (%d/%d)" % [creature_data.creature_name, active_roster.size(), MAX_ACTIVE_CREATURES])
	return true

# === STABLE COLLECTION MANAGEMENT ===
func add_to_stable(creature_data: CreatureData) -> bool:
	"""Add a creature to the stable collection (unlimited)."""
	if creature_data == null:
		push_error("PlayerCollection: Cannot add null creature to stable collection")
		return false

	if creature_data.id in stable_collection:
		push_warning("PlayerCollection: Creature '%s' already in stable collection" % creature_data.creature_name)
		return true

	# Remove from active roster if present
	if creature_data.id in _active_lookup:
		remove_from_active(creature_data.id)

	# Add to stable collection
	stable_collection[creature_data.id] = creature_data
	_stable_lookup[creature_data.id] = creature_data
	_invalidate_stats_cache()

	# Update species tracking
	_update_species_count(creature_data.species_id, 1)

	# Emit signals
	if signal_bus:
		signal_bus.emit_stable_collection_updated("added", creature_data.id)

	if not _quiet_mode:
		print("PlayerCollection: Added '%s' to stable collection (total: %d)" % [creature_data.creature_name, stable_collection.size()])
	return true

func remove_from_stable(creature_id: String) -> bool:
	"""Remove a creature from the stable collection."""
	if creature_id.is_empty():
		push_error("PlayerCollection: Cannot remove creature with empty ID")
		return false

	if creature_id not in stable_collection:
		push_warning("PlayerCollection: Creature ID '%s' not found in stable collection" % creature_id)
		return false

	var creature_data: CreatureData = stable_collection[creature_id]

	# Remove from stable collection
	stable_collection.erase(creature_id)
	_stable_lookup.erase(creature_id)
	_invalidate_stats_cache()

	# Emit signals
	if signal_bus:
		signal_bus.emit_stable_collection_updated("removed", creature_id)

	print("PlayerCollection: Removed '%s' from stable collection (total: %d)" % [creature_data.creature_name, stable_collection.size()])
	return true

func promote_to_active(creature_id: String) -> bool:
	"""Promote a creature from stable collection to active roster."""
	if creature_id.is_empty():
		push_error("PlayerCollection: Cannot promote creature with empty ID")
		return false

	if creature_id not in stable_collection:
		push_warning("PlayerCollection: Creature ID '%s' not found in stable collection" % creature_id)
		return false

	var creature_data: CreatureData = stable_collection[creature_id]

	# Remove from stable
	if not remove_from_stable(creature_id):
		return false

	# Add to active
	return add_to_active(creature_data)

func get_stable_creatures() -> Array[CreatureData]:
	"""Get array of all creatures in stable collection."""
	var creatures: Array[CreatureData] = []
	for creature_data in stable_collection.values():
		creatures.append(creature_data)
	return creatures

func search_creatures(criteria: Dictionary) -> Array[CreatureData]:
	"""Search creatures in stable collection based on criteria.
	Criteria can include: species, tags, min_stats, max_stats, age_category, etc."""
	var results: Array[CreatureData] = []
	var all_stable: Array[CreatureData] = get_stable_creatures()

	_ensure_systems_loaded()

	for creature in all_stable:
		if creature == null:
			continue

		var matches: bool = true

		# Species filter
		if criteria.has("species") and creature.species_id != criteria.species:
			matches = false

		# Tag requirements
		if matches and criteria.has("required_tags"):
			var required_tags: Array[String] = criteria.required_tags
			if tag_system and not tag_system.meets_tag_requirements(creature, required_tags):
				matches = false

		# Age category filter
		if matches and criteria.has("age_category"):
			var age_category: GlobalEnums.AgeCategory = creature.get_age_category()
			if age_category != criteria.age_category:
				matches = false

		# Stat filters
		if matches and criteria.has("min_stats"):
			var min_stats: Dictionary = criteria.min_stats
			for stat_name in min_stats:
				if creature.get_stat(stat_name) < min_stats[stat_name]:
					matches = false
					break

		if matches:
			results.append(creature)

	return results

# === CREATURE LIFECYCLE MANAGEMENT ===
func release_creature(creature_id: String, reason: String) -> bool:
	"""Release a creature from the collection."""
	if creature_id.is_empty():
		push_error("PlayerCollection: Cannot release creature with empty ID")
		return false

	if reason.is_empty():
		reason = "player_choice"

	var creature_data: CreatureData = null
	var success: bool = false

	# Find and remove creature
	if creature_id in _active_lookup:
		creature_data = active_roster[_active_lookup[creature_id]]
		success = remove_from_active(creature_id)
	elif creature_id in stable_collection:
		creature_data = stable_collection[creature_id]
		success = remove_from_stable(creature_id)
	else:
		push_warning("PlayerCollection: Creature ID '%s' not found in collection" % creature_id)
		return false

	if success and creature_data != null:
		# Record release
		collection_metadata.total_released += 1

		# Update species counts
		_update_species_count(creature_data.species_id, -1)

		# Emit release signal
		if signal_bus:
			signal_bus.emit_creature_released(creature_data, reason)
			# Also emit cleanup signal for all systems to remove references
			signal_bus.creature_cleanup_required.emit(creature_id)

		print("PlayerCollection: Released '%s' (reason: %s)" % [creature_data.creature_name, reason])

	return success

# === CREATURE LOOKUP ===
func get_creature_by_id(creature_id: String) -> CreatureData:
	"""Get a creature by ID from the main collection."""
	if creature_id.is_empty():
		return null

	# Check main creature collection
	if creature_id in creature_collection:
		return creature_collection[creature_id]

	return null

# === COLLECTION STATISTICS ===
func get_collection_stats() -> Dictionary:
	"""Get comprehensive collection statistics."""
	if not _stats_cache_dirty and not _stats_cache.is_empty():
		return _stats_cache.duplicate()

	var stats: Dictionary = {
		"active_count": active_roster.size(),
		"stable_count": stable_collection.size(),
		"total_count": active_roster.size() + stable_collection.size(),
		"total_acquired": collection_metadata.total_acquired,
		"total_released": collection_metadata.total_released,
		"net_collection": collection_metadata.total_acquired - collection_metadata.total_released,
		"milestones_reached": collection_metadata.milestones_reached.duplicate(),
		"active_slots_remaining": MAX_ACTIVE_CREATURES - active_roster.size(),
		"species_diversity": collection_metadata.species_counts.size()
	}

	# Cache the results
	_stats_cache = stats.duplicate()
	_stats_cache_dirty = false

	return stats

func get_species_breakdown() -> Dictionary:
	"""Get breakdown of creatures by species."""
	return collection_metadata.species_counts.duplicate()

func get_performance_metrics() -> Dictionary:
	"""Get performance metrics for the collection."""
	_ensure_systems_loaded()

	var metrics: Dictionary = {
		"active_creatures": [],
		"stable_summary": {
			"count": stable_collection.size(),
			"avg_age": 0.0,
			"age_distribution": {}
		},
		"collection_health": "good"
	}

	# Active creature metrics
	for creature in active_roster:
		if creature == null:
			continue

		var creature_metrics: Dictionary = {
			"name": creature.creature_name,
			"species": creature.species_id,
			"performance_score": 0.0,
			"age_weeks": creature.age_weeks,
			"age_category": 0
		}

		# Calculate performance score (average of all stats)
		var total_stats: int = 0
		var stat_count: int = 0
		for stat_name in ["STR", "CON", "DEX", "INT", "WIS", "DIS"]:
			total_stats += creature.get_stat(stat_name)
			stat_count += 1
		creature_metrics.performance_score = float(total_stats) / float(stat_count)

		# Age category
		creature_metrics.age_category = creature.get_age_category()  # Returns GlobalEnums.AgeCategory

		metrics.active_creatures.append(creature_metrics)

	# Stable collection summary
	if stable_collection.size() > 0:
		var total_age: int = 0
		var age_categories: Dictionary = {}

		for creature_data in stable_collection.values():
			total_age += creature_data.age_weeks

			var age_cat: GlobalEnums.AgeCategory = creature_data.get_age_category()

			if not age_categories.has(age_cat):
				age_categories[age_cat] = 0
			age_categories[age_cat] += 1

		metrics.stable_summary.avg_age = float(total_age) / float(stable_collection.size())
		metrics.stable_summary.age_distribution = age_categories

	return metrics

func get_acquisition_history() -> Array[Dictionary]:
	"""Get history of creature acquisitions."""
	return collection_metadata.acquisition_history.duplicate()

# === PRIVATE HELPER METHODS ===
func _rebuild_active_lookup() -> void:
	"""Rebuild the active roster lookup table after removals."""
	_active_lookup.clear()
	for i in range(active_roster.size()):
		if active_roster[i] != null:
			_active_lookup[active_roster[i].id] = i

func _invalidate_stats_cache() -> void:
	"""Mark statistics cache as dirty."""
	_stats_cache_dirty = true

func _update_species_count(species_id: String, delta: int) -> void:
	"""Update species count in metadata (delta can be positive or negative)."""
	if species_id.is_empty():
		return

	if not collection_metadata.species_counts.has(species_id):
		collection_metadata.species_counts[species_id] = 0

	collection_metadata.species_counts[species_id] += delta

	# Remove species entry if count drops to zero or below
	if collection_metadata.species_counts[species_id] <= 0:
		collection_metadata.species_counts.erase(species_id)

func _check_milestones() -> void:
	"""Check and emit milestone achievement signals."""
	var total_count: int = active_roster.size() + stable_collection.size()

	for milestone_name in MILESTONES:
		var milestone_count: int = MILESTONES[milestone_name]
		if total_count >= milestone_count and milestone_name not in collection_metadata.milestones_reached:
			collection_metadata.milestones_reached.append(milestone_name)
			if signal_bus:
				signal_bus.emit_collection_milestone_reached(milestone_name, total_count)

# === SIGNAL HANDLERS ===
func _on_creature_expired(creature_data: CreatureData) -> void:
	"""Handle creature expiration from age system."""
	if creature_data == null:
		return

	# Remove expired creature from collection
	release_creature(creature_data.id, "age_expiration")

func _on_creature_created(creature_data: CreatureData) -> void:
	"""Handle new creature creation (for potential auto-acquisition)."""
	# This can be used for automatic acquisition of generated creatures
	# Currently just logs the event
	if creature_data != null:
		print("PlayerCollection: Detected creature creation: '%s'" % creature_data.creature_name)

# === STARTING GAME INITIALIZATION ===
func _initialize_starting_creature() -> void:
	"""Initialize starting creature for new players."""
	# Only initialize if collection is completely empty (indicating a new game)
	if active_roster.is_empty() and stable_collection.is_empty():
		print("PlayerCollection: Initializing starting creature for new game")

		# Generate a proper starting creature using CreatureGenerator
		var starter_entity = CreatureGenerator.generate_starter_creature("scuttleguard")
		if not starter_entity:
			push_error("PlayerCollection: Failed to generate starting creature")
			return

		# Set a friendly name for the starter
		starter_entity.data.creature_name = "Starter"

		# Acquire the creature
		if acquire_creature(starter_entity.data, "starting_gift"):
			print("PlayerCollection: Starting scuttleguard 'Starter' added to collection")
		else:
			push_error("PlayerCollection: Failed to add starting creature")

# === SAVE/LOAD INTEGRATION ===
func save_collection_state(slot_name: String = "default") -> bool:
	"""Save collection state to the save system."""
	_ensure_systems_loaded()

	if save_system == null:
		push_error("PlayerCollection: SaveSystem not available")
		return false

	var collection_data: Dictionary = {
		"active_roster": _serialize_roster(active_roster),
		"stable_collection": _serialize_collection(stable_collection),
		"metadata": collection_metadata.duplicate(),
		"version": 1
	}

	# Use save system's custom data saving
	var config: ConfigFile = ConfigFile.new()
	config.set_value(COLLECTION_SAVE_KEY, "data", collection_data)
	var save_path: String = "user://saves/%s/collection.cfg" % slot_name

	# Ensure directory exists
	if not DirAccess.dir_exists_absolute("user://saves/%s" % slot_name):
		DirAccess.open("user://").make_dir_recursive("saves/%s" % slot_name)

	var error: Error = config.save(save_path)
	return error == OK

func load_collection_state(slot_name: String = "default") -> bool:
	"""Load collection state from the save system."""
	_ensure_systems_loaded()

	if save_system == null:
		push_error("PlayerCollection: SaveSystem not available")
		return false

	var save_path: String = "user://saves/%s/collection.cfg" % slot_name
	if not FileAccess.file_exists(save_path):
		print("PlayerCollection: No save file found at %s, using defaults" % save_path)
		return true

	var config: ConfigFile = ConfigFile.new()
	var error: Error = config.load(save_path)
	if error != OK:
		push_error("PlayerCollection: Failed to load collection data from %s" % save_path)
		return false

	var collection_data: Dictionary = config.get_value(COLLECTION_SAVE_KEY, "data", {})
	if collection_data.is_empty():
		print("PlayerCollection: Empty collection data, using defaults")
		return true

	# Load data
	active_roster = _deserialize_roster(collection_data.get("active_roster", []))
	stable_collection = _deserialize_collection(collection_data.get("stable_collection", {}))
	collection_metadata = collection_data.get("metadata", {})

	# Rebuild caches
	_rebuild_active_lookup()
	_rebuild_stable_lookup()
	_invalidate_stats_cache()

	print("PlayerCollection: Loaded collection with %d active and %d stable creatures" % [active_roster.size(), stable_collection.size()])
	return true

func _serialize_roster(roster: Array[CreatureData]) -> Array[Dictionary]:
	"""Serialize active roster for saving."""
	var serialized: Array[Dictionary] = []
	for creature in roster:
		if creature != null:
			serialized.append(creature.to_dict())
	return serialized

func _serialize_collection(collection: Dictionary) -> Dictionary:
	"""Serialize stable collection for saving."""
	var serialized: Dictionary = {}
	for creature_id in collection:
		var creature: CreatureData = collection[creature_id]
		if creature != null:
			serialized[creature_id] = creature.to_dict()
	return serialized

func _deserialize_roster(serialized_roster: Array[Dictionary]) -> Array[CreatureData]:
	"""Deserialize active roster from save data."""
	var roster: Array[CreatureData] = []
	for creature_dict in serialized_roster:
		var creature: CreatureData = CreatureData.new()
		creature.from_dict(creature_dict)
		roster.append(creature)
	return roster

func _deserialize_collection(serialized_collection: Dictionary) -> Dictionary:
	"""Deserialize stable collection from save data."""
	var collection: Dictionary = {}
	for creature_id in serialized_collection:
		var creature_dict: Dictionary = serialized_collection[creature_id]
		var creature: CreatureData = CreatureData.new()
		creature.from_dict(creature_dict)
		collection[creature_id] = creature
	return collection

func _rebuild_stable_lookup() -> void:
	"""Rebuild stable collection lookup cache."""
	_stable_lookup.clear()
	for creature_id in stable_collection:
		_stable_lookup[creature_id] = stable_collection[creature_id]

func _add_to_acquisition_history(creature_data: CreatureData, source: String) -> void:
	"""Add acquisition record to history."""
	var acquisition_record: Dictionary = {
		"creature_id": creature_data.id,
		"creature_name": creature_data.creature_name,
		"species_id": creature_data.species_id,
		"source": source,
		"timestamp": Time.get_unix_time_from_system()
	}
	collection_metadata.acquisition_history.append(acquisition_record)
