class_name SaveSystem
extends Node

# === CONSTANTS ===
const SAVE_VERSION: int = 1
const SAVE_BASE_PATH: String = "user://saves/"
const GAME_DATA_FILE: String = "game_data.cfg"
const CREATURES_FOLDER: String = "creatures/"
const BACKUP_SUFFIX: String = "_backup"

# === SAVE PATHS ===
const DEFAULT_SLOT: String = "default"

# === AUTO-SAVE SETTINGS ===
var auto_save_enabled: bool = false
var auto_save_interval_minutes: int = 5
var auto_save_timer: Timer = null

# === SYSTEM REFERENCES ===
var signal_bus: SignalBus = null
var stat_system: Node = null
var age_system: Node = null
var creature_system: Node = null

# === PERFORMANCE TRACKING ===
var save_operations_count: int = 0
var load_operations_count: int = 0
var last_save_time: float = 0.0
var last_load_time: float = 0.0

func _ready() -> void:
	# Initialize system references
	signal_bus = GameCore.get_signal_bus()

	# Connect existing signals
	if signal_bus:
		signal_bus.save_requested.connect(_on_save_requested)
		signal_bus.load_requested.connect(_on_load_requested)

		# Add new save-specific signals to SignalBus if they don't exist
		_ensure_save_signals_exist()

	# Create save directories
	_ensure_save_directories()

	# Setup auto-save timer
	_setup_auto_save_timer()

	print("SaveSystem initialized with comprehensive save/load functionality")

# === CORE SAVE/LOAD OPERATIONS ===

func save_game_state(slot_name: String = DEFAULT_SLOT) -> bool:
	"""Save complete game state to specified slot."""
	var start_time: float = float(Time.get_ticks_msec())

	if not _validate_slot_name(slot_name):
		push_error("SaveSystem: Invalid slot name: %s" % slot_name)
		_emit_save_completed(false)
		return false

	var slot_path: String = get_slot_path(slot_name)
	_ensure_directory(slot_path)

	var success: bool = true

	# Save main game data (ConfigFile)
	success = success and _save_game_data(slot_name)

	# Save creature collection (hybrid approach)
	success = success and _save_creature_collection(slot_name)

	# Save system states
	success = success and _save_system_states(slot_name)

	# Update performance tracking
	save_operations_count += 1
	last_save_time = float(Time.get_ticks_msec()) - start_time

	if success:
		print("SaveSystem: Game state saved to '%s' in %.1fms" % [slot_name, last_save_time])
	else:
		push_error("SaveSystem: Failed to save game state to '%s'" % slot_name)

	_emit_save_completed(success)
	return success

func load_game_state(slot_name: String = DEFAULT_SLOT) -> bool:
	"""Load complete game state from specified slot."""
	var start_time: float = float(Time.get_ticks_msec())

	if not _validate_slot_exists(slot_name):
		push_error("SaveSystem: Save slot does not exist: %s" % slot_name)
		_emit_load_completed(false)
		return false

	# Validate save data integrity before loading
	var validation_result: Dictionary = validate_save_data(slot_name)
	if not validation_result.valid:
		push_error("SaveSystem: Save data validation failed: %s" % validation_result.error)
		_emit_load_completed(false)
		return false

	var success: bool = true

	# Load main game data
	success = success and _load_game_data(slot_name)

	# Load creature collection
	success = success and _load_creature_collection(slot_name)

	# Load system states
	success = success and _load_system_states(slot_name)

	# Update performance tracking
	load_operations_count += 1
	last_load_time = float(Time.get_ticks_msec()) - start_time

	if success:
		print("SaveSystem: Game state loaded from '%s' in %.1fms" % [slot_name, last_load_time])
	else:
		push_error("SaveSystem: Failed to load game state from '%s'" % slot_name)

	_emit_load_completed(success)
	return success

func delete_save_slot(slot_name: String) -> bool:
	"""Delete a save slot completely."""
	if not _validate_slot_exists(slot_name):
		push_error("SaveSystem: Cannot delete non-existent slot: %s" % slot_name)
		return false

	var slot_path: String = get_slot_path(slot_name)
	var dir: DirAccess = DirAccess.open(slot_path)

	if dir == null:
		push_error("SaveSystem: Cannot access slot directory: %s" % slot_path)
		return false

	# Delete all creature files
	var creatures_path: String = slot_path + CREATURES_FOLDER
	var creatures_dir: DirAccess = DirAccess.open(creatures_path)
	if creatures_dir:
		creatures_dir.list_dir_begin()
		var file_name: String = creatures_dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				creatures_dir.remove(file_name)
			file_name = creatures_dir.get_next()
		creatures_dir.list_dir_end()

	# Delete main game data file
	dir.remove(GAME_DATA_FILE)

	# Remove directories
	if creatures_dir:
		dir.remove(CREATURES_FOLDER)

	# Try to remove slot directory (will only work if empty)
	var base_dir: DirAccess = DirAccess.open(SAVE_BASE_PATH)
	if base_dir:
		base_dir.remove(slot_name)

	print("SaveSystem: Deleted save slot: %s" % slot_name)
	return true

func get_save_slots() -> Array[String]:
	"""Get list of all available save slots."""
	var slots: Array[String] = []
	var dir: DirAccess = DirAccess.open(SAVE_BASE_PATH)

	if dir == null:
		return slots

	dir.list_dir_begin()
	var slot_name: String = dir.get_next()
	while slot_name != "":
		if dir.current_is_dir() and not slot_name.begins_with("."):
			# Check if this is a valid save slot (has game data file)
			var game_data_path: String = SAVE_BASE_PATH + slot_name + "/" + GAME_DATA_FILE
			if FileAccess.file_exists(game_data_path):
				slots.append(slot_name)
		slot_name = dir.get_next()
	dir.list_dir_end()

	return slots

func get_save_info(slot_name: String) -> Dictionary:
	"""Get metadata about a save slot."""
	var info: Dictionary = {
		"exists": false,
		"slot_name": slot_name,
		"created_timestamp": 0,
		"last_modified": 0,
		"game_version": "",
		"player_name": "",
		"total_creatures": 0,
		"current_week": 0,
		"gold": 0,
		"save_version": 0,
		"file_size_mb": 0.0
	}

	if not _validate_slot_exists(slot_name):
		return info

	info.exists = true

	# Load metadata from ConfigFile
	var config: ConfigFile = ConfigFile.new()
	var game_data_path: String = get_slot_path(slot_name) + GAME_DATA_FILE

	if config.load(game_data_path) == OK:
		info.created_timestamp = config.get_value("save_metadata", "created_timestamp", 0)
		info.last_modified = config.get_value("save_metadata", "last_modified", 0)
		info.game_version = config.get_value("save_metadata", "game_version", "")
		info.player_name = config.get_value("save_metadata", "player_name", "")
		info.save_version = config.get_value("save_metadata", "version", 0)

		info.gold = config.get_value("player_data", "gold", 0)
		info.current_week = config.get_value("player_data", "current_week", 0)
		info.total_creatures = config.get_value("statistics", "total_creatures_owned", 0)

	# Calculate total file size
	info.file_size_mb = _calculate_slot_size(slot_name)

	return info

# === CREATURE COLLECTION MANAGEMENT ===

func save_creature_collection(creatures: Array[CreatureData], slot_name: String) -> bool:
	"""Save a collection of creatures using hybrid approach."""
	if creatures.is_empty():
		print("SaveSystem: No creatures to save")
		return true

	var start_time: float = float(Time.get_ticks_msec())
	var creatures_path: String = get_slot_path(slot_name) + CREATURES_FOLDER
	_ensure_directory(creatures_path)

	var success_count: int = 0
	var total_count: int = creatures.size()

	# Save each creature as individual resource file
	for creature in creatures:
		if creature == null or creature.id.is_empty():
			continue

		var creature_file: String = creatures_path + creature.id + ".tres"

		# Apply Godot 4.5 cache workaround
		creature.take_over_path(creature_file)

		if ResourceSaver.save(creature, creature_file) == OK:
			success_count += 1
		else:
			push_error("SaveSystem: Failed to save creature: %s" % creature.id)

	var save_time: float = float(Time.get_ticks_msec()) - start_time
	var success: bool = success_count == total_count

	print("SaveSystem: Saved %d/%d creatures in %.1fms" % [success_count, total_count, save_time])
	return success

func load_creature_collection(slot_name: String) -> Array[CreatureData]:
	"""Load creature collection from save slot."""
	var creatures: Array[CreatureData] = []
	var creatures_path: String = get_slot_path(slot_name) + CREATURES_FOLDER

	if not DirAccess.dir_exists_absolute(creatures_path):
		print("SaveSystem: No creatures directory found in slot: %s" % slot_name)
		return creatures

	var start_time: float = float(Time.get_ticks_msec())
	var dir: DirAccess = DirAccess.open(creatures_path)

	if dir == null:
		push_error("SaveSystem: Cannot access creatures directory: %s" % creatures_path)
		return creatures

	# Load all creature resource files
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var creature_path: String = creatures_path + file_name

			# Use CACHE_MODE_IGNORE for reliable loading (Godot 4.5 workaround)
			var creature: CreatureData = ResourceLoader.load(creature_path, "", ResourceLoader.CACHE_MODE_IGNORE) as CreatureData

			if creature != null:
				# Validate loaded creature data
				if _validate_creature_data(creature):
					creatures.append(creature)
				else:
					push_error("SaveSystem: Invalid creature data in file: %s" % file_name)
			else:
				push_error("SaveSystem: Failed to load creature from: %s" % file_name)

		file_name = dir.get_next()
	dir.list_dir_end()

	var load_time: float = float(Time.get_ticks_msec()) - start_time
	print("SaveSystem: Loaded %d creatures in %.1fms" % [creatures.size(), load_time])
	return creatures

func save_individual_creature(creature: CreatureData, slot_name: String) -> bool:
	"""Save a single creature to the specified slot."""
	if creature == null or creature.id.is_empty():
		push_error("SaveSystem: Cannot save invalid creature")
		return false

	var creatures_path: String = get_slot_path(slot_name) + CREATURES_FOLDER
	_ensure_directory(creatures_path)

	var creature_file: String = creatures_path + creature.id + ".tres"

	# Apply Godot 4.5 cache workaround
	creature.take_over_path(creature_file)

	var success: bool = ResourceSaver.save(creature, creature_file) == OK

	if success:
		print("SaveSystem: Saved creature: %s" % creature.creature_name)
	else:
		push_error("SaveSystem: Failed to save creature: %s" % creature.creature_name)

	return success

func load_individual_creature(creature_id: String, slot_name: String) -> CreatureData:
	"""Load a single creature from the specified slot."""
	if creature_id.is_empty():
		push_error("SaveSystem: Cannot load creature with empty ID")
		return null

	var creature_file: String = get_slot_path(slot_name) + CREATURES_FOLDER + creature_id + ".tres"

	if not FileAccess.file_exists(creature_file):
		print("SaveSystem: Creature file not found: %s" % creature_id)
		return null

	# Use CACHE_MODE_IGNORE for reliable loading
	var creature: CreatureData = ResourceLoader.load(creature_file, "", ResourceLoader.CACHE_MODE_IGNORE) as CreatureData

	if creature != null and _validate_creature_data(creature):
		print("SaveSystem: Loaded creature: %s" % creature.creature_name)
		return creature
	else:
		push_error("SaveSystem: Failed to load or validate creature: %s" % creature_id)
		return null

# === AUTO-SAVE FUNCTIONALITY ===

func enable_auto_save(interval_minutes: int = 5) -> void:
	"""Enable automatic saving at specified intervals."""
	if interval_minutes < 1:
		push_error("SaveSystem: Auto-save interval must be at least 1 minute")
		return

	auto_save_enabled = true
	auto_save_interval_minutes = interval_minutes

	if auto_save_timer:
		auto_save_timer.wait_time = interval_minutes * 60.0
		auto_save_timer.start()

	print("SaveSystem: Auto-save enabled (every %d minutes)" % interval_minutes)

func disable_auto_save() -> void:
	"""Disable automatic saving."""
	auto_save_enabled = false

	if auto_save_timer:
		auto_save_timer.stop()

	print("SaveSystem: Auto-save disabled")

func trigger_auto_save() -> bool:
	"""Manually trigger an auto-save operation."""
	if not auto_save_enabled:
		return false

	print("SaveSystem: Auto-save triggered")
	_emit_auto_save_triggered()

	return save_game_state(DEFAULT_SLOT)

# === DATA VALIDATION & RECOVERY ===

func validate_save_data(slot_name: String) -> Dictionary:
	"""Comprehensive validation of save data integrity."""
	var result: Dictionary = {
		"valid": false,
		"error": "",
		"warnings": [],
		"checks_performed": 0,
		"checks_passed": 0
	}

	if not _validate_slot_exists(slot_name):
		result.error = "Save slot does not exist"
		return result

	var game_data_path: String = get_slot_path(slot_name) + GAME_DATA_FILE
	var config: ConfigFile = ConfigFile.new()

	# Check 1: Game data file loads
	result.checks_performed += 1
	if config.load(game_data_path) != OK:
		result.error = "Cannot load game data file"
		return result
	result.checks_passed += 1

	# Check 2: Save version compatibility
	result.checks_performed += 1
	var save_version: int = config.get_value("save_metadata", "version", -1)
	if save_version < 0 or save_version > SAVE_VERSION:
		result.error = "Incompatible save version: %d" % save_version
		return result
	if save_version < SAVE_VERSION:
		result.warnings.append("Save version %d will be migrated to %d" % [save_version, SAVE_VERSION])
	result.checks_passed += 1

	# Check 3: Required metadata exists
	result.checks_performed += 1
	var required_metadata: Array[String] = ["created_timestamp", "game_version"]
	for key in required_metadata:
		if not config.has_section_key("save_metadata", key):
			result.error = "Missing required metadata: %s" % key
			return result
	result.checks_passed += 1

	# Check 4: Creature files validation
	result.checks_performed += 1
	var total_creatures: int = config.get_value("statistics", "total_creatures_owned", 0)
	var creatures_path: String = get_slot_path(slot_name) + CREATURES_FOLDER

	if total_creatures > 0:
		if not DirAccess.dir_exists_absolute(creatures_path):
			result.error = "Missing creatures directory but %d creatures expected" % total_creatures
			return result

		# Count actual creature files
		var actual_creatures: int = 0
		var dir: DirAccess = DirAccess.open(creatures_path)
		if dir:
			dir.list_dir_begin()
			var file_name: String = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".tres"):
					actual_creatures += 1
				file_name = dir.get_next()
			dir.list_dir_end()

		if actual_creatures != total_creatures:
			result.warnings.append("Expected %d creatures, found %d files" % [total_creatures, actual_creatures])
	result.checks_passed += 1

	result.valid = true
	return result

func repair_corrupted_save(slot_name: String) -> bool:
	"""Attempt to repair corrupted save data."""
	print("SaveSystem: Attempting to repair corrupted save: %s" % slot_name)

	# For now, basic repair - ensure required sections exist
	var game_data_path: String = get_slot_path(slot_name) + GAME_DATA_FILE
	var config: ConfigFile = ConfigFile.new()

	if config.load(game_data_path) != OK:
		push_error("SaveSystem: Cannot load corrupted save for repair")
		return false

	# Ensure required sections exist with default values
	if not config.has_section("save_metadata"):
		config.set_value("save_metadata", "version", SAVE_VERSION)
		config.set_value("save_metadata", "created_timestamp", Time.get_unix_time_from_system())
		config.set_value("save_metadata", "game_version", "Stage1_Task7")

	if not config.has_section("player_data"):
		config.set_value("player_data", "gold", 500)
		config.set_value("player_data", "current_week", 1)

	if not config.has_section("statistics"):
		config.set_value("statistics", "total_creatures_owned", 0)

	var success: bool = config.save(game_data_path) == OK

	if success:
		print("SaveSystem: Save repair completed for: %s" % slot_name)
	else:
		push_error("SaveSystem: Save repair failed for: %s" % slot_name)

	return success

func create_backup(slot_name: String) -> bool:
	"""Create a backup of the specified save slot."""
	if not _validate_slot_exists(slot_name):
		push_error("SaveSystem: Cannot backup non-existent slot: %s" % slot_name)
		return false

	var backup_slot: String = slot_name + BACKUP_SUFFIX

	# Copy entire slot directory
	var success: bool = _copy_slot(slot_name, backup_slot)

	if success:
		print("SaveSystem: Backup created: %s -> %s" % [slot_name, backup_slot])
		if signal_bus:
			signal_bus.emit_backup_created(slot_name, backup_slot)
	else:
		push_error("SaveSystem: Failed to create backup for: %s" % slot_name)

	return success

func restore_from_backup(slot_name: String, backup_name: String) -> bool:
	"""Restore a save slot from backup."""
	if not _validate_slot_exists(backup_name):
		push_error("SaveSystem: Backup does not exist: %s" % backup_name)
		return false

	# Delete current slot if it exists
	if _validate_slot_exists(slot_name):
		delete_save_slot(slot_name)

	# Copy backup to main slot
	var success: bool = _copy_slot(backup_name, slot_name)

	if success:
		print("SaveSystem: Restored from backup: %s -> %s" % [backup_name, slot_name])
		if signal_bus:
			signal_bus.emit_backup_restored(slot_name, backup_name)
	else:
		push_error("SaveSystem: Failed to restore from backup: %s" % backup_name)

	return success

# === PRIVATE IMPLEMENTATION ===

func _save_game_data(slot_name: String) -> bool:
	"""Save main game data using ConfigFile."""
	var config: ConfigFile = ConfigFile.new()
	var game_data_path: String = get_slot_path(slot_name) + GAME_DATA_FILE

	# Save metadata
	config.set_value("save_metadata", "version", SAVE_VERSION)
	config.set_value("save_metadata", "created_timestamp", Time.get_unix_time_from_system())
	config.set_value("save_metadata", "last_modified", Time.get_unix_time_from_system())
	config.set_value("save_metadata", "game_version", "Stage1_Task7")
	config.set_value("save_metadata", "player_name", "Player")  # Will get from player system later

	# Save player data (placeholder - will integrate with player system later)
	config.set_value("player_data", "gold", 1500)
	config.set_value("player_data", "current_week", 10)

	# Save game settings
	config.set_value("game_settings", "auto_save_enabled", auto_save_enabled)
	config.set_value("game_settings", "auto_save_interval", auto_save_interval_minutes)

	# Save statistics
	config.set_value("statistics", "total_play_time", 3600)  # Placeholder
	var creatures: Array[CreatureData] = []
	if creature_system:
		# Will integrate with creature system when available
		pass
	config.set_value("statistics", "total_creatures_owned", creatures.size())
	config.set_value("statistics", "save_operations", save_operations_count)
	config.set_value("statistics", "load_operations", load_operations_count)

	return config.save(game_data_path) == OK

func _load_game_data(slot_name: String) -> bool:
	"""Load main game data from ConfigFile."""
	var config: ConfigFile = ConfigFile.new()
	var game_data_path: String = get_slot_path(slot_name) + GAME_DATA_FILE

	if config.load(game_data_path) != OK:
		return false

	# Check version and migrate if needed
	var save_version: int = config.get_value("save_metadata", "version", 0)
	if save_version != SAVE_VERSION:
		print("SaveSystem: Migrating save from version %d to %d" % [save_version, SAVE_VERSION])
		_migrate_save(config, save_version)

	# Load settings
	auto_save_enabled = config.get_value("game_settings", "auto_save_enabled", false)
	auto_save_interval_minutes = config.get_value("game_settings", "auto_save_interval", 5)

	# Apply auto-save settings
	if auto_save_enabled:
		enable_auto_save(auto_save_interval_minutes)

	print("SaveSystem: Game data loaded successfully")
	return true

func _save_creature_collection(_slot_name: String) -> bool:
	"""Save creature collection for the specified slot."""
	# For now, placeholder - will integrate with creature system
	# This will call save_creature_collection with actual creature data
	print("SaveSystem: Creature collection save (placeholder)")
	return true

func _load_creature_collection(slot_name: String) -> bool:
	"""Load creature collection for the specified slot."""
	# For now, placeholder - will integrate with creature system
	# This will load creatures and add them to the creature system
	var creatures: Array[CreatureData] = load_creature_collection(slot_name)
	print("SaveSystem: Loaded %d creatures from save" % creatures.size())
	return true

func _save_system_states(slot_name: String) -> bool:
	"""Save state of all game systems."""
	var config: ConfigFile = ConfigFile.new()
	var slot_path: String = get_slot_path(slot_name)
	_ensure_directory(slot_path)  # Ensure directory exists
	var systems_path: String = slot_path + "system_states.cfg"

	# Save StatSystem state (modifiers, temporary effects)
	if stat_system:
		# Placeholder - will integrate when StatSystem has persistent state
		config.set_value("stat_system", "initialized", true)
	else:
		# Mark as not available but still save the file
		config.set_value("stat_system", "not_loaded", true)

	# AgeSystem doesn't need persistent state (calculated from creature data)
	if age_system:
		config.set_value("age_system", "initialized", true)
	else:
		config.set_value("age_system", "not_loaded", true)

	# Save other system states as needed
	config.set_value("save_system", "auto_save_enabled", auto_save_enabled)
	config.set_value("save_system", "auto_save_interval", auto_save_interval_minutes)

	var save_result: int = config.save(systems_path)
	if save_result == OK:
		print("SaveSystem: System states saved to: %s" % systems_path)
		return true
	else:
		push_error("SaveSystem: Failed to save system states (error: %d)" % save_result)
		return false

func _load_system_states(slot_name: String) -> bool:
	"""Load state of all game systems."""
	var config: ConfigFile = ConfigFile.new()
	var systems_path: String = get_slot_path(slot_name) + "system_states.cfg"

	if not FileAccess.file_exists(systems_path):
		print("SaveSystem: No system states file found (using defaults)")
		return true

	if config.load(systems_path) != OK:
		push_error("SaveSystem: Failed to load system states")
		return false

	# Restore system states as needed
	print("SaveSystem: System states loaded successfully")
	return true

func _setup_auto_save_timer() -> void:
	"""Initialize the auto-save timer."""
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = auto_save_interval_minutes * 60.0
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)

func _ensure_save_directories() -> void:
	"""Create save directory structure."""
	if not DirAccess.dir_exists_absolute(SAVE_BASE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_BASE_PATH)

func _ensure_directory(path: String) -> void:
	"""Ensure directory exists, create if necessary."""
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

func get_slot_path(slot_name: String) -> String:
	"""Get full path to save slot directory."""
	return SAVE_BASE_PATH + slot_name + "/"

func _validate_slot_name(slot_name: String) -> bool:
	"""Validate save slot name."""
	if slot_name.is_empty() or slot_name.length() > 50:
		return false

	# Check for invalid characters
	var invalid_chars: String = "\\/:*?\"<>|"
	for i in range(invalid_chars.length()):
		if slot_name.contains(invalid_chars[i]):
			return false

	return true

func _validate_slot_exists(slot_name: String) -> bool:
	"""Check if save slot exists."""
	var game_data_path: String = get_slot_path(slot_name) + GAME_DATA_FILE
	return FileAccess.file_exists(game_data_path)

func _validate_creature_data(creature: CreatureData) -> bool:
	"""Validate loaded creature data."""
	if creature == null:
		return false

	# Check required fields
	if creature.id.is_empty() or creature.creature_name.is_empty():
		return false

	# Check stat ranges
	var stats: Array[String] = ["strength", "constitution", "dexterity", "intelligence", "wisdom", "discipline"]
	for stat in stats:
		var value: int = creature.get(stat)
		if value < 1 or value > 1000:
			return false

	return true

func _calculate_slot_size(slot_name: String) -> float:
	"""Calculate total size of save slot in MB."""
	var total_size: int = 0
	var slot_path: String = get_slot_path(slot_name)

	# Get size of game data file
	var game_data_path: String = slot_path + GAME_DATA_FILE
	if FileAccess.file_exists(game_data_path):
		var file: FileAccess = FileAccess.open(game_data_path, FileAccess.READ)
		if file:
			total_size += file.get_length()
			file.close()

	# Get size of creature files
	var creatures_path: String = slot_path + CREATURES_FOLDER
	if DirAccess.dir_exists_absolute(creatures_path):
		var dir: DirAccess = DirAccess.open(creatures_path)
		if dir:
			dir.list_dir_begin()
			var file_name: String = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".tres"):
					var file_path: String = creatures_path + file_name
					var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
					if file:
						total_size += file.get_length()
						file.close()
				file_name = dir.get_next()
			dir.list_dir_end()

	return total_size / (1024.0 * 1024.0)  # Convert to MB

func _copy_slot(source_slot: String, target_slot: String) -> bool:
	"""Copy entire save slot to another location."""
	var source_path: String = get_slot_path(source_slot)
	var target_path: String = get_slot_path(target_slot)

	_ensure_directory(target_path)

	# Copy game data file
	var source_game_data: String = source_path + GAME_DATA_FILE
	var target_game_data: String = target_path + GAME_DATA_FILE

	if FileAccess.file_exists(source_game_data):
		var source_file: FileAccess = FileAccess.open(source_game_data, FileAccess.READ)
		var target_file: FileAccess = FileAccess.open(target_game_data, FileAccess.WRITE)

		if source_file and target_file:
			target_file.store_buffer(source_file.get_buffer(source_file.get_length()))
			source_file.close()
			target_file.close()
		else:
			return false

	# Copy creature files
	var source_creatures: String = source_path + CREATURES_FOLDER
	var target_creatures: String = target_path + CREATURES_FOLDER

	if DirAccess.dir_exists_absolute(source_creatures):
		_ensure_directory(target_creatures)

		var dir: DirAccess = DirAccess.open(source_creatures)
		if dir:
			dir.list_dir_begin()
			var file_name: String = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".tres"):
					var source_file_path: String = source_creatures + file_name
					var target_file_path: String = target_creatures + file_name

					var source_file: FileAccess = FileAccess.open(source_file_path, FileAccess.READ)
					var target_file: FileAccess = FileAccess.open(target_file_path, FileAccess.WRITE)

					if source_file and target_file:
						target_file.store_buffer(source_file.get_buffer(source_file.get_length()))
						source_file.close()
						target_file.close()

				file_name = dir.get_next()
			dir.list_dir_end()

	return true

func _migrate_save(config: ConfigFile, from_version: int) -> void:
	"""Handle save migration between versions."""
	print("SaveSystem: Migrating save from version %d to %d" % [from_version, SAVE_VERSION])

	# Add migration logic for future versions
	match from_version:
		0:
			# Migrate from version 0 to 1
			if not config.has_section("save_metadata"):
				config.set_value("save_metadata", "created_timestamp", Time.get_unix_time_from_system())
				config.set_value("save_metadata", "game_version", "Stage1_Task7")

	# Update version
	config.set_value("save_metadata", "version", SAVE_VERSION)

func _ensure_save_signals_exist() -> void:
	"""Ensure required save signals exist in SignalBus."""
	# These signals should already exist from Task 1-6, but verify
	if not signal_bus.has_signal("auto_save_triggered"):
		push_warning("SaveSystem: auto_save_triggered signal not found in SignalBus")
	if not signal_bus.has_signal("save_progress"):
		push_warning("SaveSystem: save_progress signal not found in SignalBus")

# === SIGNAL EMISSION HELPERS ===

func _emit_save_completed(success: bool) -> void:
	"""Emit save completed signal with validation."""
	if signal_bus:
		signal_bus.save_completed.emit(success)

func _emit_load_completed(success: bool) -> void:
	"""Emit load completed signal with validation."""
	if signal_bus:
		signal_bus.load_completed.emit(success)

func _emit_auto_save_triggered() -> void:
	"""Emit auto-save triggered signal."""
	if signal_bus:
		signal_bus.emit_auto_save_triggered()

# === SIGNAL HANDLERS ===

func _on_save_requested() -> void:
	"""Handle save requested signal."""
	print("SaveSystem: Save requested via signal")
	save_game_state()

func _on_load_requested() -> void:
	"""Handle load requested signal."""
	print("SaveSystem: Load requested via signal")
	load_game_state()

func _on_auto_save_timeout() -> void:
	"""Handle auto-save timer timeout."""
	if auto_save_enabled:
		trigger_auto_save()

# === SYSTEM INTEGRATION GETTERS ===

func get_system_references() -> void:
	"""Lazy load system references when needed."""
	if stat_system == null:
		stat_system = GameCore.get_system("stat")
	if age_system == null:
		age_system = GameCore.get_system("age")
	if creature_system == null:
		creature_system = GameCore.get_system("creature")
