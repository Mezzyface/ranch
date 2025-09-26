extends Node

# Simple compilation test for AgeSystem

func _ready() -> void:
	print("Testing AgeSystem compilation...")

	# Test if AgeSystem can be loaded
	if GameCore:
		var age_system = GameCore.get_system("age")
		if age_system:
			print("✅ AgeSystem loaded successfully")
		else:
			print("❌ AgeSystem failed to load")
	else:
		print("❌ GameCore not available")

	# Exit immediately
	get_tree().quit()