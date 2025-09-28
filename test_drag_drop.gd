extends SceneTree

func _init() -> void:
	print("Testing drag and drop implementation...")

	# Test that DraggingState compiles and can be instantiated
	var dummy_sprite = AnimatedSprite2D.new()
	var dummy_machine = CreatureStateMachine.new(dummy_sprite)

	# Check that dragging state exists
	if dummy_machine.states.has("Dragging"):
		print("✓ DraggingState successfully loaded")
	else:
		print("✗ DraggingState not found in state machine")
		push_error("DraggingState missing")

	# Test state transition
	dummy_machine.start("Idle")
	dummy_machine.transition_to("Dragging")
	if dummy_machine.get_current_state_name() == "Dragging":
		print("✓ Can transition to DraggingState")
	else:
		print("✗ Failed to transition to DraggingState")
		push_error("State transition failed")

	# Test transition back to idle
	dummy_machine.transition_to("Idle")
	if dummy_machine.get_current_state_name() == "Idle":
		print("✓ Can transition back from DraggingState")
	else:
		print("✗ Failed to transition from DraggingState")
		push_error("State transition from dragging failed")

	print("Drag and drop test complete!")
	quit()