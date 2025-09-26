extends Node

# Test that catches common AI agent integration mistakes
# This test INTENTIONALLY tries wrong patterns to verify they fail properly

var errors_caught: int = 0
var expected_errors: int = 0

func _ready() -> void:
	print("=== AI Agent Common Mistakes Test ===")
	print("This test verifies that wrong patterns fail as expected")
	print("")

	# Test each common mistake
	_test_wrong_property_names()
	_test_wrong_method_locations()
	_test_wrong_array_types()
	_test_wrong_time_api()
	_test_wrong_system_loading()

	# Summary
	print("")
	print("=== Test Summary ===")
	if errors_caught == expected_errors:
		print("✅ All %d wrong patterns correctly failed!" % errors_caught)
		print("✅ The validation systems are working properly")
		get_tree().quit(0)
	else:
		print("❌ Expected %d errors but caught %d" % [expected_errors, errors_caught])
		print("❌ Some wrong patterns might not be failing!")
		get_tree().quit(1)

func _test_wrong_property_names() -> void:
	print("Testing wrong property names...")

	var creature: CreatureData = CreatureData.new()
	creature.id = "test_123"
	creature.species_id = "scuttleguard"

	# Try to access wrong property names
	# These SHOULD fail or return null/default values

	# Test 1: creature_id doesn't exist
	if not creature.has("creature_id"):
		print("  ✅ 'creature_id' correctly doesn't exist (use 'id')")
		errors_caught += 1
	else:
		print("  ❌ 'creature_id' somehow exists - this is wrong!")
	expected_errors += 1

	# Test 2: species doesn't exist as a property
	if not creature.has("species"):
		print("  ✅ 'species' correctly doesn't exist (use 'species_id')")
		errors_caught += 1
	else:
		print("  ❌ 'species' somehow exists - this is wrong!")
	expected_errors += 1

	print("")

func _test_wrong_method_locations() -> void:
	print("Testing wrong method locations...")

	var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	var age_system = GameCore.get_system("age")

	# Test 3: AgeSystem shouldn't have get_creature_age_category
	if not age_system.has_method("get_creature_age_category"):
		print("  ✅ age_system.get_creature_age_category() correctly doesn't exist")
		errors_caught += 1
	else:
		print("  ❌ age_system.get_creature_age_category() exists - this is wrong!")
	expected_errors += 1

	# Test 4: CreatureData SHOULD have get_age_category
	if creature.has_method("get_age_category"):
		print("  ✅ creature.get_age_category() correctly exists")
	else:
		print("  ❌ creature.get_age_category() missing - this is wrong!")

	# Test 5: TagSystem shouldn't have creature_meets_requirements
	var tag_system = GameCore.get_system("tag")
	if not tag_system.has_method("creature_meets_requirements"):
		print("  ✅ tag_system.creature_meets_requirements() correctly doesn't exist")
		errors_caught += 1
	else:
		print("  ❌ tag_system.creature_meets_requirements() exists - this is wrong!")
	expected_errors += 1

	print("")

func _test_wrong_array_types() -> void:
	print("Testing wrong array types...")

	# Test 6: Untyped arrays should cause issues with typed parameters
	var untyped_array = ["Flying", "Fast"]  # Untyped
	var typed_array: Array[String] = ["Flying", "Fast"]  # Typed

	# Check typing
	if untyped_array.get_typed_builtin() == TYPE_NIL:
		print("  ✅ Untyped array correctly identified as untyped")
		errors_caught += 1
	else:
		print("  ❌ Untyped array somehow has typing!")
	expected_errors += 1

	if typed_array.get_typed_builtin() == TYPE_STRING:
		print("  ✅ Typed array correctly identified as Array[String]")
	else:
		print("  ❌ Typed array doesn't have correct typing!")

	print("")

func _test_wrong_time_api() -> void:
	print("Testing wrong time API usage...")

	# Test 7: Time.get_time_dict_from_system() shouldn't have nanosecond
	var time_dict: Dictionary = Time.get_time_dict_from_system()
	if not time_dict.has("nanosecond"):
		print("  ✅ 'nanosecond' correctly doesn't exist in time dict")
		errors_caught += 1
	else:
		print("  ❌ 'nanosecond' somehow exists in time dict!")
	expected_errors += 1

	# Test 8: Correct API should work
	var ticks: int = Time.get_ticks_msec()
	if ticks > 0:
		print("  ✅ Time.get_ticks_msec() works correctly")
	else:
		print("  ❌ Time.get_ticks_msec() failed!")

	print("")

func _test_wrong_system_loading() -> void:
	print("Testing wrong system loading patterns...")

	# Test 9: Direct access to GameCore.systems should not be public
	# In proper encapsulation, this should fail or be null
	# We can't directly test this as it depends on implementation
	# but we can verify the correct way works

	var system = GameCore.get_system("collection")
	if system != null:
		print("  ✅ GameCore.get_system() works correctly")
	else:
		print("  ❌ GameCore.get_system() failed!")

	# Try to access a non-existent system
	var fake_system = GameCore.get_system("fake_system_that_doesnt_exist")
	if fake_system == null:
		print("  ✅ Non-existent systems correctly return null")
		errors_caught += 1
	else:
		print("  ❌ Non-existent system somehow loaded!")
	expected_errors += 1

	print("")