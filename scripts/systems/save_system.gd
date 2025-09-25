class_name SaveSystem
extends Node

const SAVE_VERSION: int = 1
const SAVE_PATH: String = "user://save_slot_%d.cfg"

func _ready() -> void:
	var signal_bus := GameCore.get_signal_bus()
	signal_bus.save_requested.connect(_on_save_requested)
	signal_bus.load_requested.connect(_on_load_requested)
	print("SaveSystem initialized")

func save_game(slot: int = 0) -> bool:
	var config := ConfigFile.new()

	# Metadata
	config.set_value("meta", "version", SAVE_VERSION)
	config.set_value("meta", "timestamp", Time.get_unix_time_from_system())
	config.set_value("meta", "play_time", 0) # Will track later

	# Game state
	var creature_system: CreatureSystem = GameCore.get_system("creature") as CreatureSystem
	if creature_system:
		for creature in creature_system.get_all_creatures():
			config.set_value("creatures", creature.id, creature.to_dict())

	# Save to file
	var error := config.save(SAVE_PATH % slot)
	var success := error == OK

	GameCore.get_signal_bus().save_completed.emit(success)
	return success

func load_game(slot: int = 0) -> bool:
	var config := ConfigFile.new()
	var path := SAVE_PATH % slot

	if not FileAccess.file_exists(path):
		push_warning("Save file doesn't exist: " + path)
		GameCore.get_signal_bus().load_completed.emit(false)
		return false

	var error := config.load(path)
	if error != OK:
		push_error("Failed to load save file: " + path)
		GameCore.get_signal_bus().load_completed.emit(false)
		return false

	# Check version
	var version: int = config.get_value("meta", "version", 0)
	if version != SAVE_VERSION:
		print("Migrating save from version %d to %d" % [version, SAVE_VERSION])
		_migrate_save(config, version)

	# Load creatures
	var creature_system: CreatureSystem = GameCore.get_system("creature") as CreatureSystem
	if creature_system:
		creature_system.clear_all_creatures()

		if config.has_section("creatures"):
			for creature_id in config.get_section_keys("creatures"):
				var creature_dict: Dictionary = config.get_value("creatures", creature_id, {})
				creature_system.add_creature_from_dict(creature_dict)

	GameCore.get_signal_bus().load_completed.emit(true)
	return true

func _migrate_save(config: ConfigFile, from_version: int) -> void:
	# Handle save migration between versions
	pass

func _on_save_requested() -> void:
	print("SaveSystem: Save requested!")
	save_game()

func _on_load_requested() -> void:
	print("SaveSystem: Load requested!")
	load_game()