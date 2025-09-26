@tool
extends EditorScript

func _run():
	print("=== CreatureGenerator Verification ===")

	# Test basic functionality
	var available_species = CreatureGenerator.get_available_species()
	print("Available species: %s" % str(available_species))

	# Test species validation
	if CreatureGenerator.is_valid_species("scuttleguard"):
		print("✅ Species validation works")
	else:
		print("❌ Species validation failed")

	# Test creature generation
	var creature = CreatureGenerator.generate_creature_data("scuttleguard")
	if creature:
		print("✅ Creature generation successful: %s" % creature.creature_name)
		print("   Stats: STR=%d, CON=%d, DEX=%d" % [creature.strength, creature.constitution, creature.dexterity])
		print("   Tags: %s" % str(creature.tags))
	else:
		print("❌ Creature generation failed")

	print("=== Verification Complete ===")