extends AnimatedSprite2D

# Creature Sprite Controller - Handles movement and animation in facility view

# Movement parameters (kept for helper methods)
const BOUNDARY_MARGIN: float = 20.0

# State machine
var state_machine: CreatureStateMachine

# State variables (accessible by states)
var target_position: Vector2 = Vector2.ZERO
var assigned_facility_id: String = ""
var creature_data: CreatureData = null

# Area boundaries (set by parent)
var area_bounds: Rect2 = Rect2()

# Facility positions map
var facility_positions: Dictionary = {}

# Systems
var signal_bus: Node
var facility_system: Node
var collection_system: Node

func _ready() -> void:
	_initialize_systems()
	_setup_signals()
	_setup_animation()

	# Initialize state machine
	state_machine = CreatureStateMachine.new(self)

	# Ensure sprite is visible and properly scaled
	visible = true
	modulate = Color.WHITE
	scale = Vector2(2, 2)  # Match the scale in the scene file

	# Wait a frame for the parent control to be properly sized
	await get_tree().process_frame

	# Set initial position within bounds
	_update_area_bounds()

	# If no initial position set or out of bounds, center in area
	if area_bounds.size != Vector2.ZERO:
		var center = area_bounds.position + area_bounds.size / 2
		position = center

	# Enable input processing for drag and drop - using _input for higher priority
	set_process_input(true)

	# Debug: Print sprite info
	print("CreatureSprite ready at position: ", position, " with global: ", global_position)

	# Start the state machine in idle state
	state_machine.start("Idle")

func _initialize_systems() -> void:
	signal_bus = GameCore.get_signal_bus()
	facility_system = GameCore.get_system("facility")
	collection_system = GameCore.get_system("collection")

	if not signal_bus:
		push_error("CreatureSpriteController: SignalBus not found")
	if not facility_system:
		push_error("CreatureSpriteController: FacilitySystem not found")
	if not collection_system:
		push_error("CreatureSpriteController: PlayerCollection not found")

func _setup_signals() -> void:
	if not signal_bus:
		return

	# Connect to facility assignment signals
	if signal_bus.has_signal("creature_assigned_to_facility"):
		signal_bus.creature_assigned_to_facility.connect(_on_creature_assigned_to_facility)

	if signal_bus.has_signal("facility_assignment_removed"):
		signal_bus.facility_assignment_removed.connect(_on_facility_assignment_removed)

func _setup_animation() -> void:
	# Try to load the Scuttle Guard sprite frames
	var scuttle_guard_frames = load("res://assets/sprites/creatures/scuttleguard/scutleguard.tres")

	if scuttle_guard_frames and scuttle_guard_frames is SpriteFrames:
		sprite_frames = scuttle_guard_frames

		# Check if it has the animations we need
		if not sprite_frames.has_animation("idle"):
			# If no idle animation, use default animation or first available
			if sprite_frames.has_animation("default"):
				play("default")
			else:
				var anims = sprite_frames.get_animation_names()
				if anims.size() > 0:
					play(anims[0])
		else:
			play("idle")

		# For walking, we can use idle animation if walk doesn't exist
		if not sprite_frames.has_animation("walk") and sprite_frames.has_animation("idle"):
			# We'll just use idle for both states
			pass
	else:
		# Fallback to placeholder if Scuttle Guard sprites can't be loaded
		sprite_frames = SpriteFrames.new()

		# Create a placeholder texture (colored rectangle)
		var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		image.fill(Color(0.4, 0.7, 1.0, 1.0))  # Light blue color

		# Add border for visibility
		for x in range(32):
			image.set_pixel(x, 0, Color.WHITE)
			image.set_pixel(x, 31, Color.WHITE)
		for y in range(32):
			image.set_pixel(0, y, Color.WHITE)
			image.set_pixel(31, y, Color.WHITE)

		var texture = ImageTexture.create_from_image(image)

		# Add placeholder animations with the texture
		sprite_frames.add_animation("idle")
		sprite_frames.add_animation("walk")

		# Add frames to animations
		sprite_frames.add_frame("idle", texture, 1.0, 0)
		sprite_frames.add_frame("walk", texture, 1.0, 0)

		# Set animation speeds
		sprite_frames.set_animation_speed("idle", 5.0)
		sprite_frames.set_animation_speed("walk", 8.0)

		# Start with idle animation
		play("idle")

func _process(delta: float) -> void:
	if state_machine:
		state_machine.update(delta)

func _physics_process(delta: float) -> void:
	if state_machine:
		state_machine.physics_update(delta)

func _input(event: InputEvent) -> void:
	# Debug: Log ALL input events to see if we're getting them
	if event is InputEventMouseButton:
		print("[CreatureSprite] Got MouseButton event - Button: ", event.button_index, " Pressed: ", event.pressed, " Position: ", event.global_position)
	elif event is InputEventMouseMotion:
		# Only log motion if dragging
		if state_machine and state_machine.is_in_state("Dragging"):
			print("[CreatureSprite] Mouse motion while dragging: ", event.global_position)

	# Handle mouse input for drag and drop
	if not creature_data:
		print("[CreatureSprite] No creature data - ignoring input")
		return  # Can't drag if no creature is assigned

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		print("[CreatureSprite] Processing mouse button: ", mouse_event.button_index)

		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			print("[CreatureSprite] Not left button - ignoring")
			return

		# Get mouse position in global coordinates
		var mouse_global = event.global_position
		var sprite_global = global_position

		# Calculate sprite bounds (considering scale and sprite size)
		var sprite_size = Vector2(64, 64)  # Approximate sprite size
		var scaled_size = sprite_size * scale
		var half_size = scaled_size / 2

		# Create a rect for the sprite bounds
		var sprite_rect = Rect2(sprite_global - half_size, scaled_size)

		# Debug output
		print("[CreatureSprite] Mouse at: ", mouse_global, " Sprite at: ", sprite_global)
		print("[CreatureSprite] Sprite rect: ", sprite_rect)
		print("[CreatureSprite] Mouse in sprite bounds: ", sprite_rect.has_point(mouse_global))

		# Check if mouse is within sprite bounds for starting drag
		if mouse_event.pressed:
			if sprite_rect.has_point(mouse_global):
				# Start dragging
				if state_machine and not state_machine.is_in_state("Assigned"):
					state_machine.transition_to("Dragging")
					get_viewport().set_input_as_handled()
					print("[CreatureSprite] STARTED DRAGGING!")
				else:
					print("[CreatureSprite] Can't start drag - already assigned or no state machine")
			else:
				print("[CreatureSprite] Click outside sprite bounds - not starting drag")
		else:
			print("[CreatureSprite] Mouse released")
			# Handle mouse release anywhere on screen
			if state_machine and state_machine.is_in_state("Dragging"):
				# Exit dragging state, which will handle the drop
				state_machine.transition_to("Idle")
				get_viewport().set_input_as_handled()
				print("[CreatureSprite] STOPPED DRAGGING!")
			else:
				print("[CreatureSprite] Mouse released but not dragging")

func _play_safe_animation(anim_name: String) -> void:
	"""Play an animation, falling back to alternatives if it doesn't exist"""
	if not sprite_frames:
		return

	# Don't restart the same animation if it's already playing
	if animation == anim_name and is_playing():
		return

	if sprite_frames.has_animation(anim_name):
		play(anim_name)
	elif anim_name.begins_with("walk"):
		# If a specific walk animation doesn't exist, try generic walk
		if sprite_frames.has_animation("walk"):
			play("walk")
		elif sprite_frames.has_animation("move"):
			play("move")
		elif sprite_frames.has_animation("idle"):
			play("idle")
	elif sprite_frames.has_animation("idle"):
		play("idle")
	elif sprite_frames.has_animation("default"):
		play("default")
	else:
		# Play first available animation
		var anims = sprite_frames.get_animation_names()
		if anims.size() > 0:
			play(anims[0])

func _get_random_position_in_bounds() -> Vector2:
	if area_bounds.size == Vector2.ZERO:
		# Use parent control size if bounds not set
		var parent = get_parent()
		if parent and parent is Control:
			area_bounds = Rect2(Vector2.ZERO, parent.size)
		else:
			area_bounds = Rect2(0, 0, 800, 200)

	var x = randf_range(
		area_bounds.position.x + BOUNDARY_MARGIN,
		area_bounds.position.x + area_bounds.size.x - BOUNDARY_MARGIN
	)
	var y = randf_range(
		area_bounds.position.y + BOUNDARY_MARGIN,
		area_bounds.position.y + area_bounds.size.y - BOUNDARY_MARGIN
	)

	return Vector2(x, y)

func _clamp_to_bounds(pos: Vector2) -> Vector2:
	"""Clamp a position to stay within the area bounds"""
	if area_bounds.size == Vector2.ZERO:
		_update_area_bounds()

	var clamped_pos = pos
	clamped_pos.x = clamp(
		clamped_pos.x,
		area_bounds.position.x + BOUNDARY_MARGIN,
		area_bounds.position.x + area_bounds.size.x - BOUNDARY_MARGIN
	)
	clamped_pos.y = clamp(
		clamped_pos.y,
		area_bounds.position.y + BOUNDARY_MARGIN,
		area_bounds.position.y + area_bounds.size.y - BOUNDARY_MARGIN
	)
	return clamped_pos

func _update_area_bounds() -> void:
	"""Update the area bounds from parent control"""
	var parent = get_parent()
	if parent and parent is Control:
		area_bounds = Rect2(Vector2.ZERO, parent.size)
	else:
		area_bounds = Rect2(0, 0, 800, 200)

func _update_movement_animation(direction: Vector2) -> void:
	"""Update animation and facing based on movement direction"""
	if direction.length() < 0.1:
		return

	# Determine primary movement direction
	var abs_x = abs(direction.x)
	var abs_y = abs(direction.y)

	var anim_name = "walk"

	# Check for directional animations (note: using hyphens to match the Scuttle Guard animations)
	if abs_y > abs_x:
		# Vertical movement
		if direction.y < 0:
			anim_name = "walk-up"
		else:
			anim_name = "walk-down"
	else:
		# Horizontal movement
		if direction.x < 0:
			anim_name = "walk-left"
		else:
			anim_name = "walk-right"

	# Play the appropriate animation
	_play_safe_animation(anim_name)

	# Don't flip sprite horizontally since we have dedicated left/right animations
	flip_h = false

func _update_facing(direction_x: float) -> void:
	# Flip sprite based on movement direction (legacy function)
	if abs(direction_x) > 0.1:
		flip_h = direction_x < 0

func set_creature(creature: CreatureData) -> void:
	creature_data = creature
	print("[CreatureSprite] Creature assigned: ", creature.creature_name if creature else "null", " ID: ", creature.id if creature else "null")
	# Could customize appearance based on creature species here

func set_area_bounds(bounds: Rect2) -> void:
	area_bounds = bounds

func assign_to_facility(facility_id: String, facility_position: Vector2) -> void:
	assigned_facility_id = facility_id
	target_position = facility_position

	if state_machine:
		state_machine.assign_to_facility(facility_id, facility_position)

func unassign_from_facility() -> void:
	assigned_facility_id = ""
	target_position = Vector2.ZERO

	if state_machine:
		state_machine.unassign_from_facility()

func add_facility_position(facility_id: String, position: Vector2) -> void:
	facility_positions[facility_id] = position

func _on_creature_assigned_to_facility(creature_id: String, facility_id: String, activity: int, food_type: int) -> void:
	# Check if this sprite represents the assigned creature
	if creature_data and creature_data.id == creature_id:
		# Get facility position from the facility cards
		var facility_position = _get_facility_card_position(facility_id)
		if facility_position != Vector2.ZERO:
			assign_to_facility(facility_id, facility_position)

func _on_facility_assignment_removed(facility_id: String, creature_id: String) -> void:
	# Check if this sprite was assigned to this facility
	if creature_data and creature_data.id == creature_id and assigned_facility_id == facility_id:
		unassign_from_facility()

func _get_facility_card_position(facility_id: String) -> Vector2:
	# Try to find the facility card position
	# This would be set by the facility view controller
	if facility_positions.has(facility_id):
		return facility_positions[facility_id]

	# Fallback: calculate approximate position based on facility index
	if facility_system:
		var facilities = facility_system.get_all_facilities()
		for i in range(facilities.size()):
			if facilities[i].facility_id == facility_id:
				# Approximate position based on grid layout
				var col = i % 3
				var row = i / 3
				var x = 150 + col * 250
				var y = 100 + row * 150
				return Vector2(x, y)

	return Vector2.ZERO

func play_entrance_effect() -> void:
	# Visual feedback when entering facility
	# Could add particles, scaling animation, etc.
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)

	# Scale up and down for bounce effect
	tween.tween_property(self, "scale", Vector2(2.5, 2.5), 0.2)
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.3)

	# Could also add color modulation
	modulate = Color(1.2, 1.2, 1.0, 1.0)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.5)

func play_exit_effect() -> void:
	# Visual feedback when leaving facility
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Small scale animation
	tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.15)
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.15)
