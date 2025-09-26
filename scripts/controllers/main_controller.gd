class_name MainController
extends Node2D

func _ready() -> void:
	print("Main scene loaded successfully")
	print("GameCore available: ", GameCore != null)
	print("SignalBus available: ", GameCore.get_signal_bus() != null)

	print("=== Manual CreatureGenerator Test ===")

	# Test 1: Basic generation
	var creature = CreatureGenerator.generate_creature_data("scuttleguard")
	print("Generated: %s (STR: %d)" % [creature.creature_name, creature.strength])

	# Test 2: Different algorithms
	var uniform = CreatureGenerator.generate_creature_data("stone_sentinel", CreatureGenerator.GenerationType.UNIFORM)
	var gaussian = CreatureGenerator.generate_creature_data("stone_sentinel", CreatureGenerator.GenerationType.GAUSSIAN)
	var high_roll = CreatureGenerator.generate_creature_data("stone_sentinel", CreatureGenerator.GenerationType.HIGH_ROLL)

	print("UNIFORM STR: %d, GAUSSIAN STR: %d, HIGH_ROLL STR: %d" % [uniform.strength, gaussian.strength, high_roll.strength])

	# Test 3: Population generation (performance test)
	var start_time = Time.get_ticks_msec()
	var population = CreatureGenerator.generate_population_data(1000)
	var end_time = Time.get_ticks_msec()

	print("Generated %d creatures in %dms" % [population.size(), end_time - start_time])

	# Test 4: Factory methods
	var starter = CreatureGenerator.generate_starter_creature()
	var premium_egg = CreatureGenerator.generate_from_egg("wind_dancer", "premium")

	print("Starter: %s, Premium egg: %s" % [starter.data.creature_name, premium_egg.creature_name])


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_save_game"):
		print("Save game input detected!")
		# Ensure SaveSystem is loaded before emitting signal
		GameCore.get_system("save")
		GameCore.get_signal_bus().save_requested.emit()
	elif event.is_action_pressed("ui_load_game"):
		print("Load game input detected!")
		# Ensure SaveSystem is loaded before emitting signal
		GameCore.get_system("save")
		GameCore.get_signal_bus().load_requested.emit()
	elif event.is_action_pressed("ui_open_shop"):
		print("Shop input detected (S key)!")
	elif event.is_action_pressed("ui_open_creatures"):
		print("Creatures input detected (C key)!")
	elif event.is_action_pressed("ui_open_quests"):
		print("Quests input detected (Q key)!")
	elif event.is_action_pressed("ui_advance_time"):
		print("Advance time input detected (Space key)!")
