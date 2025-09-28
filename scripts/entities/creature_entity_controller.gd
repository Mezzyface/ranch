extends Control

# Creature Entity Controller - Visual Control wrapper for creatures in facility view
# Handles drag and drop, animations, and state management

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Movement parameters (kept for helper methods)
const BOUNDARY_MARGIN: float = 20.0

# Simple state management (simplified for initial implementation)
enum State { IDLE, WALKING, DRAGGING, ASSIGNED }
var current_state: State = State.IDLE

# State variables (accessible by states)
var target_position: Vector2 = Vector2.ZERO
var assigned_facility_id: String = ""
var creature_data: CreatureData = null

# Area boundaries (set by parent)
var area_bounds: Rect2 = Rect2()

# Facility positions map
var facility_positions: Dictionary = {}

# Drag and drop state
var is_dragging: bool = false
var drag_offset: Vector2

# Systems
var signal_bus: Node
var facility_system: Node
var collection_system: Node

func _ready() -> void:
	_initialize_systems()
	_setup_signals()
	_setup_control()
	_setup_animation()

	# Wait a frame for the parent control to be properly sized
	await get_tree().process_frame

	# Set initial position within bounds
	_update_area_bounds()

	# Enable mouse input
	mouse_filter = Control.MOUSE_FILTER_PASS

	# Enable drag and drop capabilities
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Start in idle state
	current_state = State.IDLE

func _initialize_systems() -> void:
	signal_bus = GameCore.get_signal_bus()
	facility_system = GameCore.get_system("facility")
	collection_system = GameCore.get_system("collection")

	if not signal_bus:
		push_error("CreatureEntityController: SignalBus not found")
	if not facility_system:
		push_error("CreatureEntityController: FacilitySystem not found")
	if not collection_system:
		push_error("CreatureEntityController: PlayerCollection not found")

func _setup_signals() -> void:
	if not signal_bus:
		return

	# Connect to facility assignment signals
	if signal_bus.has_signal("creature_assigned_to_facility"):
		signal_bus.creature_assigned_to_facility.connect(_on_creature_assigned_to_facility)

	if signal_bus.has_signal("facility_assignment_removed"):
		signal_bus.facility_assignment_removed.connect(_on_facility_assignment_removed)

func _setup_control() -> void:
	# Set minimum size to accommodate sprite
	var sprite_size = Vector2(64, 64)
	custom_minimum_size = sprite_size
	size = sprite_size

	# Ensure the sprite is properly positioned within the control
	if sprite:
		sprite.position = sprite_size / 2
		sprite.scale = Vector2(2, 2)  # Match the scale from original
		sprite.visible = true
		sprite.modulate = Color.WHITE

func _setup_animation() -> void:
	if not sprite:
		push_error("CreatureEntityController: AnimatedSprite2D not found")
		return

	# Try to load the Scuttle Guard sprite frames
	var scuttle_guard_frames = load("res://assets/sprites/creatures/scuttleguard/scutleguard.tres")

	if scuttle_guard_frames and scuttle_guard_frames is SpriteFrames:
		sprite.sprite_frames = scuttle_guard_frames

		# Check if it has the animations we need
		if not sprite.sprite_frames.has_animation("idle"):
			# If no idle animation, use default animation or first available
			if sprite.sprite_frames.has_animation("default"):
				sprite.play("default")
			else:
				var anims = sprite.sprite_frames.get_animation_names()
				if anims.size() > 0:
					sprite.play(anims[0])
		else:
			sprite.play("idle")

		# For walking, we can use idle animation if walk doesn't exist
		if not sprite.sprite_frames.has_animation("walk") and sprite.sprite_frames.has_animation("idle"):
			# We'll just use idle for both states
			pass
	else:
		# Fallback to placeholder if Scuttle Guard sprites can't be loaded
		sprite.sprite_frames = SpriteFrames.new()

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
		sprite.sprite_frames.add_animation("idle")
		sprite.sprite_frames.add_animation("walk")

		# Add frames to animations
		sprite.sprite_frames.add_frame("idle", texture, 1.0, 0)
		sprite.sprite_frames.add_frame("walk", texture, 1.0, 0)

		# Set animation speeds
		sprite.sprite_frames.set_animation_speed("idle", 5.0)
		sprite.sprite_frames.set_animation_speed("walk", 8.0)

		# Start with idle animation
		sprite.play("idle")

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_process_idle_state(delta)
		State.WALKING:
			_process_walking_state(delta)
		State.DRAGGING:
			_process_dragging_state(delta)
		State.ASSIGNED:
			_process_assigned_state(delta)

func _physics_process(delta: float) -> void:
	# Handle physics updates if needed
	pass

func _gui_input(event: InputEvent) -> void:
	if not creature_data:
		return

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				# Start drag - check if we're not already assigned
				if current_state != State.ASSIGNED:
					_start_drag()
					get_viewport().set_input_as_handled()
			else:
				# End drag
				if is_dragging:
					_end_drag()
					get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and is_dragging:
		global_position = event.global_position + drag_offset
		# Clamp to bounds if needed
		if area_bounds.size != Vector2.ZERO:
			global_position = _clamp_to_bounds(global_position)

func _start_drag() -> void:
	"""Start the drag operation"""
	is_dragging = true
	drag_offset = global_position - get_global_mouse_position()
	current_state = State.DRAGGING

	# Visual feedback
	if sprite:
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.5)

func _end_drag() -> void:
	"""End the drag operation"""
	is_dragging = false
	current_state = State.IDLE

	# Restore visual state
	if sprite:
		sprite.modulate = Color.WHITE

func _play_safe_animation(anim_name: String) -> void:
	"""Play an animation, falling back to alternatives if it doesn't exist"""
	if not sprite or not sprite.sprite_frames:
		return

	# Don't restart the same animation if it's already playing
	if sprite.animation == anim_name and sprite.is_playing():
		return

	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	elif anim_name.begins_with("walk"):
		# If a specific walk animation doesn't exist, try generic walk
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
		elif sprite.sprite_frames.has_animation("move"):
			sprite.play("move")
		elif sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
	elif sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	elif sprite.sprite_frames.has_animation("default"):
		sprite.play("default")
	else:
		# Play first available animation
		var anims = sprite.sprite_frames.get_animation_names()
		if anims.size() > 0:
			sprite.play(anims[0])

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
	if sprite:
		sprite.flip_h = false

func _update_facing(direction_x: float) -> void:
	# Flip sprite based on movement direction (legacy function)
	if sprite and abs(direction_x) > 0.1:
		sprite.flip_h = direction_x < 0

func set_creature_data(data: CreatureData) -> void:
	creature_data = data
	print("[CreatureEntity] Creature assigned: ", creature_data.creature_name if creature_data else "null", " ID: ", creature_data.id if creature_data else "null")
	# Could customize appearance based on creature species here

func set_area_bounds(bounds: Rect2) -> void:
	area_bounds = bounds

func assign_to_facility(facility_id: String, facility_position: Vector2) -> void:
	assigned_facility_id = facility_id
	target_position = facility_position
	current_state = State.ASSIGNED

func unassign_from_facility() -> void:
	assigned_facility_id = ""
	target_position = Vector2.ZERO
	current_state = State.IDLE

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
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.2)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)

	# Could also add color modulation
	modulate = Color(1.2, 1.2, 1.0, 1.0)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.5)

func play_exit_effect() -> void:
	# Visual feedback when leaving facility
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Small scale animation
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.15)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

func _make_custom_tooltip(for_text: String) -> Object:
	"""Provide creature info on hover"""
	if not creature_data:
		return null

	var tooltip_label = Label.new()
	tooltip_label.text = "%s\nLevel: %d\nAge: %d weeks" % [
		creature_data.creature_name,
		creature_data.get_level(),
		creature_data.age_weeks
	]
	return tooltip_label

func _can_drop_data(position: Vector2, data: Variant) -> bool:
	"""Check if we can initiate drag from this entity"""
	# We are the source of drag data, not a drop target
	return false

func _get_drag_data(position: Vector2) -> Variant:
	"""Provide drag data when dragging starts"""
	if not creature_data or current_state == State.ASSIGNED:
		return null

	# Create drag preview
	var preview = Control.new()
	preview.custom_minimum_size = Vector2(64, 64)

	# Create a sprite copy for the preview
	var preview_sprite = sprite.duplicate() if sprite else AnimatedSprite2D.new()
	preview_sprite.position = Vector2(32, 32)
	preview_sprite.modulate.a = 0.7
	preview.add_child(preview_sprite)

	set_drag_preview(preview)

	# Start drag state
	is_dragging = true
	current_state = State.DRAGGING
	if sprite:
		sprite.modulate.a = 0.3

	# Return drag data
	return {
		"creature_data": creature_data,
		"source": self
	}

func _notification(what: int) -> void:
	"""Handle drag end notification"""
	if what == NOTIFICATION_DRAG_END:
		# Reset state when drag ends
		if is_dragging:
			is_dragging = false
			current_state = State.IDLE
			if sprite:
				sprite.modulate = Color.WHITE

# State processing functions
func _process_idle_state(delta: float) -> void:
	if sprite:
		_play_safe_animation("idle")

func _process_walking_state(delta: float) -> void:
	if target_position == Vector2.ZERO:
		current_state = State.IDLE
		return

	var distance = global_position.distance_to(target_position)
	if distance <= 5.0:
		current_state = State.IDLE
		return

	var direction = (target_position - global_position).normalized()
	var movement = direction * 50.0 * delta
	global_position += movement

	if sprite:
		_play_safe_animation("walk")
		_update_movement_animation(direction)

func _process_dragging_state(delta: float) -> void:
	if sprite:
		_play_safe_animation("walk")
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.8)

func _process_assigned_state(delta: float) -> void:
	if target_position == Vector2.ZERO:
		current_state = State.IDLE
		return

	var distance = global_position.distance_to(target_position)
	if distance > 15.0:
		# Move towards facility
		var direction = (target_position - global_position).normalized()
		var movement = direction * 75.0 * delta
		global_position += movement
		if sprite:
			_play_safe_animation("walk")
	else:
		# Hover around facility
		if sprite:
			_play_safe_animation("idle")