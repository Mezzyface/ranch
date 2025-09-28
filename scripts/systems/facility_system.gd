extends Node
class_name FacilitySystem

# Implement ISaveable interface for save/load support
# Note: Godot doesn't have formal interfaces, so this is a contract-based implementation

# FacilitySystem - Manages training facilities where creatures can be assigned
# Handles facility unlocking, assignments, and resource management

# === CONSTANTS ===
const FACILITIES_DATA_PATH: String = "res://data/facilities/"
const FILE_EXTENSION: String = ".tres"

# === FACILITY DATA ===
var facility_registry: Dictionary = {}  # facility_id -> FacilityResource
var facility_unlock_status: Dictionary = {}  # facility_id -> bool
var facility_assignments: Dictionary = {}  # facility_id -> FacilityAssignmentData

# === SYSTEM DEPENDENCIES ===
var _signal_bus: SignalBus = null
var _collection_system = null
var _resource_tracker = null

func _ready() -> void:
	print("FacilitySystem initialized")
	_signal_bus = GameCore.get_signal_bus()
	_load_all_facilities()

func _load_all_facilities() -> void:
	"""Load all facility resources from data directory."""
	var dir: DirAccess = DirAccess.open(FACILITIES_DATA_PATH)
	if not dir:
		push_warning("FacilitySystem: Facilities data directory not found: %s" % FACILITIES_DATA_PATH)
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.ends_with(FILE_EXTENSION):
			var facility_path: String = FACILITIES_DATA_PATH + file_name
			_load_facility_from_file(facility_path)
		file_name = dir.get_next()

	print("FacilitySystem: Loaded %d facilities" % facility_registry.size())

func _load_facility_from_file(file_path: String) -> bool:
	"""Load a single facility from file."""
	var facility: FacilityResource = load(file_path) as FacilityResource
	if not facility:
		push_error("FacilitySystem: Failed to load facility from %s" % file_path)
		return false

	if not facility.is_valid():
		push_error("FacilitySystem: Invalid facility data in %s" % file_path)
		return false

	facility_registry[facility.facility_id] = facility
	facility_unlock_status[facility.facility_id] = facility.is_unlocked
	return true

# === PUBLIC API ===

func get_all_facilities() -> Array[FacilityResource]:
	"""Get all facility resources."""
	var facilities: Array[FacilityResource] = []
	for facility in facility_registry.values():
		facilities.append(facility)
	return facilities

func get_unlocked_facilities() -> Array[FacilityResource]:
	"""Get all unlocked facilities."""
	var unlocked: Array[FacilityResource] = []
	for facility_id in facility_registry:
		if is_facility_unlocked(facility_id):
			var facility = facility_registry[facility_id]
			unlocked.append(facility)
	return unlocked

func get_facility(facility_id: String) -> FacilityResource:
	"""Get facility resource by ID."""
	return facility_registry.get(facility_id, null)

func is_facility_unlocked(facility_id: String) -> bool:
	"""Check if facility is unlocked."""
	return facility_unlock_status.get(facility_id, false)

func unlock_facility(facility_id: String) -> bool:
	"""Unlock a facility if player has enough gold."""
	if not facility_id in facility_registry:
		push_error("FacilitySystem: Unknown facility ID: %s" % facility_id)
		return false

	if is_facility_unlocked(facility_id):
		push_error("FacilitySystem: Facility already unlocked: %s" % facility_id)
		return false

	var facility = facility_registry[facility_id]

	# Get ResourceTracker to check/spend gold
	if not _resource_tracker:
		_resource_tracker = GameCore.get_system("resource")

	if not _resource_tracker:
		push_error("FacilitySystem: ResourceTracker not available")
		return false

	# Validate gold cost
	if not _resource_tracker.can_afford(facility.unlock_cost):
		push_error("FacilitySystem: Insufficient gold to unlock %s (cost: %d)" % [facility.display_name, facility.unlock_cost])
		return false

	# Spend gold
	if not _resource_tracker.spend_gold(facility.unlock_cost):
		push_error("FacilitySystem: Failed to spend gold for facility unlock")
		return false

	# Unlock facility
	facility_unlock_status[facility_id] = true

	# Emit signal
	if _signal_bus:
		_signal_bus.facility_unlocked.emit(facility_id)

	return true

func assign_creature(facility_id: String, creature_id: String, activity: int, food_type: int) -> bool:
	"""Assign a creature to a facility with training activity and food type."""
	# Validate facility exists and is unlocked
	var facility = get_facility(facility_id)
	if not facility:
		push_error("FacilitySystem: Unknown facility: %s" % facility_id)
		return false

	if not is_facility_unlocked(facility_id):
		push_error("FacilitySystem: Facility not unlocked: %s" % facility_id)
		return false

	# Validate activity is supported (allow -1 for unset activity)
	if activity >= 0 and not facility.supports_activity(activity):
		push_error("FacilitySystem: Facility %s does not support activity %d" % [facility_id, activity])
		return false

	# Validate creature exists
	if not _collection_system:
		_collection_system = GameCore.get_system("collection")

	if not _collection_system:
		push_error("FacilitySystem: PlayerCollection not available")
		return false

	var creature = _collection_system.get_creature_by_id(creature_id)
	if not creature:
		push_error("FacilitySystem: Creature not found: %s" % creature_id)
		return false

	# Check if creature is already assigned elsewhere
	var existing_facility = get_creature_facility(creature_id)
	if not existing_facility.is_empty():
		push_error("FacilitySystem: Creature %s already assigned to facility %s" % [creature_id, existing_facility])
		return false

	# Check if facility already has a creature assigned
	if facility_assignments.has(facility_id):
		push_error("FacilitySystem: Facility %s already has creature assigned" % facility_id)
		return false

	# Create assignment
	var assignment = FacilityAssignmentData.new()
	assignment.facility_id = facility_id
	assignment.creature_id = creature_id
	assignment.selected_activity = activity
	assignment.food_type = food_type

	if not assignment.is_valid():
		push_error("FacilitySystem: Invalid assignment data")
		return false

	# Store assignment
	facility_assignments[facility_id] = assignment

	# Emit signal
	if _signal_bus:
		_signal_bus.creature_assigned_to_facility.emit(creature_id, facility_id, activity, food_type)

	return true

func remove_creature(facility_id: String) -> bool:
	"""Remove creature assignment from a facility."""
	if not facility_assignments.has(facility_id):
		push_error("FacilitySystem: No creature assigned to facility %s" % facility_id)
		return false

	var assignment = facility_assignments[facility_id]
	var creature_id = assignment.creature_id

	# Remove assignment
	facility_assignments.erase(facility_id)

	# Emit signal
	if _signal_bus:
		_signal_bus.facility_assignment_removed.emit(facility_id, creature_id)

	return true

func get_assignment(facility_id: String) -> FacilityAssignmentData:
	"""Get assignment data for a facility."""
	return facility_assignments.get(facility_id, null)

func set_assignment(assignment: FacilityAssignmentData) -> bool:
	"""Update an existing assignment."""
	if not assignment or not assignment.is_valid():
		push_error("FacilitySystem: Invalid assignment data")
		return false

	if not facility_assignments.has(assignment.facility_id):
		push_error("FacilitySystem: No existing assignment for facility %s" % assignment.facility_id)
		return false

	facility_assignments[assignment.facility_id] = assignment
	return true

func get_facility_resource(facility_id: String) -> FacilityResource:
	"""Get facility resource by ID (alias for get_facility)."""
	return get_facility(facility_id)

func get_creature_facility(creature_id: String) -> String:
	"""Get facility ID where creature is assigned, or empty string if none."""
	for facility_id in facility_assignments:
		var assignment = facility_assignments[facility_id]
		if assignment.creature_id == creature_id:
			return facility_id
	return ""

func has_food_for_all_facilities() -> bool:
	"""Check if all assigned facilities have required food available."""
	if not _resource_tracker:
		_resource_tracker = GameCore.get_system("resource")

	if not _resource_tracker:
		push_warning("FacilitySystem: ResourceTracker not available for food check")
		return false

	var inventory = _resource_tracker.get_inventory()

	# Define food item IDs (matches TrainingSystem pattern)
	var food_items = ["power_bar", "speed_snack", "brain_food", "focus_tea"]

	for facility_id in facility_assignments:
		var assignment = facility_assignments[facility_id]
		var food_type = assignment.food_type

		# Skip validation if no food type specified
		if food_type < 0 or food_type >= food_items.size():
			continue

		var item_id = food_items[food_type]
		if not inventory.has(item_id) or inventory[item_id] <= 0:
			return false

	return true

# === ISAVEABLE INTERFACE IMPLEMENTATION ===

func get_save_namespace() -> String:
	"""Get unique namespace for facility system save data."""
	return "facility_system"

func save_state() -> Dictionary:
	"""Save facility system state with validation and versioning."""
	var assignments_save_data: Dictionary = {}

	# Save all current assignments
	for facility_id in facility_assignments:
		var assignment = facility_assignments[facility_id]
		assignments_save_data[facility_id] = {
			"facility_id": assignment.facility_id,
			"creature_id": assignment.creature_id,
			"selected_activity": assignment.selected_activity,
			"food_type": assignment.food_type
		}

	# Get list of unlocked facility IDs
	var unlocked_facilities: Array[String] = []
	for facility_id in facility_unlock_status:
		if facility_unlock_status[facility_id]:
			unlocked_facilities.append(facility_id)

	return {
		"version": 1,
		"unlocked_facilities": unlocked_facilities,
		"facility_assignments": assignments_save_data,
		"facility_unlock_status": facility_unlock_status.duplicate()
	}

func load_state(data: Dictionary) -> void:
	"""Load facility system state with validation and migration support."""
	# Handle missing/invalid data gracefully with defaults
	if data.is_empty():
		print("FacilitySystem: No save data found, using defaults")
		return

	# Check version for future migration support
	var save_version: int = data.get("version", 1)
	if save_version > 1:
		push_warning("FacilitySystem: Save version %d newer than supported (1)" % save_version)

	# Clear existing data
	facility_unlock_status.clear()
	facility_assignments.clear()

	# Load unlock status - prefer new array format, fallback to old dictionary
	var unlocked_facilities: Array = data.get("unlocked_facilities", [])
	if not unlocked_facilities.is_empty():
		# New format: array of facility IDs
		for facility_id in unlocked_facilities:
			if facility_id is String and not facility_id.is_empty():
				facility_unlock_status[facility_id] = true
	else:
		# Legacy format: dictionary
		var saved_unlocks = data.get("facility_unlock_status", {})
		for facility_id in saved_unlocks:
			facility_unlock_status[facility_id] = saved_unlocks[facility_id]

	# Load assignments with validation
	var saved_assignments = data.get("facility_assignments", {})
	var orphaned_assignments: Array[String] = []

	# Get collection system for creature validation
	if not _collection_system:
		_collection_system = GameCore.get_system("collection")

	for facility_id in saved_assignments:
		var assignment_data = saved_assignments[facility_id]
		var assignment = FacilityAssignmentData.new()
		assignment.facility_id = assignment_data.get("facility_id", "")
		assignment.creature_id = assignment_data.get("creature_id", "")
		assignment.selected_activity = assignment_data.get("selected_activity", -1)
		assignment.food_type = assignment_data.get("food_type", -1)

		# Validate assignment data structure
		if not assignment.is_valid():
			push_warning("FacilitySystem: Invalid assignment data for facility %s" % facility_id)
			continue

		# Verify facility still exists
		if not facility_registry.has(facility_id):
			push_warning("FacilitySystem: Assignment for unknown facility %s removed" % facility_id)
			continue

		# Verify assigned creature still exists
		if _collection_system:
			var creature = _collection_system.get_creature_by_id(assignment.creature_id)
			if not creature:
				orphaned_assignments.append(facility_id)
				push_warning("FacilitySystem: Removed assignment for missing creature %s from facility %s" % [assignment.creature_id, facility_id])
				continue

		# Assignment is valid, store it
		facility_assignments[facility_id] = assignment

	# Log cleanup summary
	if not orphaned_assignments.is_empty():
		print("FacilitySystem: Cleaned up %d orphaned assignments" % orphaned_assignments.size())

	print("FacilitySystem: Loaded %d facility unlocks and %d assignments" % [facility_unlock_status.values().count(true), facility_assignments.size()])

# === LEGACY SAVE/LOAD SUPPORT (for compatibility) ===

func get_save_data() -> Dictionary:
	"""Legacy save method - delegates to save_state()."""
	return save_state()

func load_save_data(data: Dictionary) -> void:
	"""Legacy load method - delegates to load_state()."""
	load_state(data)

# === STATISTICS ===

func get_facility_statistics() -> Dictionary:
	"""Get facility system statistics."""
	return {
		"total_facilities": facility_registry.size(),
		"unlocked_facilities": facility_unlock_status.values().count(true),
		"active_assignments": facility_assignments.size()
	}