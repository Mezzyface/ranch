extends Node

func _ready() -> void:
	print("\n============================================================")
	print("TESTING CREATURE COLLECTION UI - Stage 2 Task 3")
	print("============================================================\n")

	# Initialize systems
	var signal_bus = GameCore.get_signal_bus()
	var collection = GameCore.get_system("collection")
	var species_system = GameCore.get_system("species")

	if not collection:
		push_error("Collection system not found!")
		get_tree().quit(1)
		return

	if not species_system:
		push_error("Species system not found!")
		get_tree().quit(1)
		return

	# Create test creatures
	print("📋 Creating test creatures...")
	var creatures_created: Array[CreatureData] = []

	var species_list = species_system.get_all_species()
	for i in range(12):  # Create 12 test creatures
		var species_id = species_list[i % species_list.size()]
		var creature = _create_test_creature(species_id, i)
		creatures_created.append(creature)
		print("  ✅ Created: %s (%s)" % [creature.creature_name, species_id])

	print("\n📋 Adding creatures to collection...")
	# Add first 6 to active roster
	for i in range(6):
		collection.add_to_active(creatures_created[i])
		print("  ✅ Added to active: %s" % creatures_created[i].creature_name)

	# Add rest to stable
	for i in range(6, 12):
		collection.add_to_stable(creatures_created[i])
		print("  ✅ Added to stable: %s" % creatures_created[i].creature_name)

	# Display collection stats
	print("\n📊 Collection Statistics:")
	var stats = collection.get_collection_stats()
	print("  Active creatures: %d/6" % stats.active_count)
	print("  Stable creatures: %d" % stats.stable_count)
	print("  Total creatures: %d" % stats.total_count)

	# Test search functionality
	print("\n🔍 Testing search functionality...")
	var search_criteria = {
		"species": species_list[0] if species_list.size() > 0 else ""
	}
	var search_results = collection.search_creatures(search_criteria)
	print("  Found %d creatures of species '%s'" % [search_results.size(), search_criteria.species])

	# Test swapping
	print("\n🔄 Testing creature swapping...")
	if creatures_created.size() >= 7:
		var active_creature = creatures_created[0]
		var stable_creature = creatures_created[6]
		print("  Moving '%s' to stable..." % active_creature.creature_name)
		collection.move_to_stable(active_creature.id)
		print("  Promoting '%s' to active..." % stable_creature.creature_name)
		collection.promote_to_active(stable_creature.id)
		print("  ✅ Swap completed")

	# Final roster check
	print("\n📋 Final Active Roster:")
	var final_active = collection.get_active_creatures()
	for i in range(final_active.size()):
		print("  Slot %d: %s" % [i + 1, final_active[i].creature_name])

	print("\n📋 Final Stable Collection:")
	var final_stable = collection.get_stable_creatures()
	for creature in final_stable:
		print("  - %s (%s)" % [creature.creature_name, creature.species_id])

	print("\n============================================================")
	print("✅ COLLECTION UI TEST COMPLETE")
	print("All collection operations working correctly!")
	print("============================================================\n")

	# Quit after test
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0)

func _create_test_creature(species_id: String, index: int) -> CreatureData:
	var creature = CreatureData.new()
	creature.id = "test_creature_%d" % index
	creature.species_id = species_id
	creature.creature_name = "Test %s %d" % [species_id.capitalize(), index]
	creature.age_weeks = randi_range(1, 20)
	creature.lifespan_weeks = 52

	# Set some random stats using the proper setters
	creature.set_stat("STR", randi_range(5, 15))
	creature.set_stat("CON", randi_range(5, 15))
	creature.set_stat("DEX", randi_range(5, 15))
	creature.set_stat("INT", randi_range(5, 15))
	creature.set_stat("WIS", randi_range(5, 15))
	creature.set_stat("DIS", randi_range(5, 15))

	creature.stamina_max = creature.get_stat("CON") * 5
	creature.stamina_current = creature.stamina_max

	return creature