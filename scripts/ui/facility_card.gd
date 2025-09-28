@tool
extends Control

# Facility Card - Individual facility display component
# Visual states: Locked, Empty, Occupied, No Food Warning

# Note: Food items are now dynamically loaded from ItemManager

signal remove_pressed(facility_id: String)
signal unlock_pressed(facility_id: String)
signal food_selection_requested(facility_id: String)
signal activity_selection_requested(facility_id: String)

@onready var background: PanelContainer = $Background
@onready var facility_icon: TextureRect = $Background/VBoxContainer/FacilityIcon
@onready var facility_name: Label = $Background/VBoxContainer/FacilityName
@onready var creature_container: Control = $Background/CreatureContainer if has_node("Background/CreatureContainer") else null
@onready var creature_portrait: TextureRect = $Background/CreatureContainer/CreaturePortrait if has_node("Background/CreatureContainer/CreaturePortrait") else null
@onready var empty_portrait_label: Label = $Background/CreatureContainer/EmptyPortraitLabel if has_node("Background/CreatureContainer/EmptyPortraitLabel") else null
@onready var activity_container: HBoxContainer = $Background/VBoxContainer/HBoxContainer
@onready var activity_icon: TextureRect = $Background/VBoxContainer/HBoxContainer/ActivityIcon if has_node("Background/VBoxContainer/HBoxContainer/ActivityIcon") else null
@onready var food_button: Button = $Background/VBoxContainer/HBoxContainer/Food if has_node("Background/VBoxContainer/HBoxContainer/Food") else null
@onready var activity_button: Button = $Background/VBoxContainer/HBoxContainer/Activity if has_node("Background/VBoxContainer/HBoxContainer/Activity") else null
@onready var action_button: Button = $Background/VBoxContainer/ActionButton if has_node("Background/VBoxContainer/ActionButton") else null
@onready var lock_overlay: ColorRect = $Background/LockOverlay
@onready var cost_label: Label = $Background/LockOverlay/LockContainer/CostLabel
@onready var unlock_button: Button = $Background/LockOverlay/LockContainer/UnlockButton
@onready var no_food_warning: ColorRect = $NoFoodWarning

var facility_resource: FacilityResource
var current_assignment: FacilityAssignmentData
var _is_hovered: bool = false
var _missing_food: bool = false
var _override_unlock_status: bool = false
var _has_unlock_override: bool = false

# Selected food/activity state for drag-drop assignments
var _selected_food_type: int = -1
var _selected_activity: int = -1
var _is_drag_highlighted: bool = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		_setup_signals()

func _setup_signals() -> void:
	# Use the main card for hover detection instead of a separate hover area
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	if action_button:
		action_button.pressed.connect(_on_action_button_pressed)

	if unlock_button:
		unlock_button.pressed.connect(_on_unlock_button_pressed)

	if food_button:
		food_button.pressed.connect(_on_food_button_pressed)

	if activity_button:
		activity_button.pressed.connect(_on_activity_button_pressed)

func set_facility(facility: FacilityResource) -> void:
	facility_resource = facility
	current_assignment = null
	_has_unlock_override = false
	# Defer the update to ensure all @onready nodes are ready
	call_deferred("update_display")

func set_assignment(assignment: FacilityAssignmentData) -> void:
	current_assignment = assignment
	update_display()

func set_unlock_status(is_unlocked: bool) -> void:
	"""Override unlock status from FacilitySystem"""
	_override_unlock_status = is_unlocked
	_has_unlock_override = true
	# Defer the update to ensure all nodes are ready
	call_deferred("update_display")

func update_display() -> void:
	if not facility_resource:
		return

	_update_facility_info()
	_update_visual_state()
	_update_assignment_info()
	_update_action_button()

func _update_facility_info() -> void:
	# Update facility name
	if facility_name:
		facility_name.text = facility_resource.display_name

	# Update facility icon
	if facility_icon:
		_load_facility_icon()

func _update_visual_state() -> void:
	if not facility_resource:
		return

	# Handle locked state
	if lock_overlay:
		var is_unlocked: bool
		if _has_unlock_override:
			is_unlocked = _override_unlock_status
		else:
			is_unlocked = facility_resource.is_unlocked
		var is_locked = not is_unlocked
		lock_overlay.visible = is_locked

		if is_locked and cost_label:
			cost_label.text = "%d g" % facility_resource.unlock_cost

	# Note: lock_overlay might not be ready during early initialization

	# Handle food warning
	if no_food_warning:
		no_food_warning.visible = _missing_food
		if _missing_food:
			# Red border effect
			var tween = create_tween()
			tween.set_loops()
			tween.tween_method(_set_warning_border, 0.0, 1.0, 1.0)
			tween.tween_method(_set_warning_border, 1.0, 0.0, 1.0)

func _update_assignment_info() -> void:
	var is_assigned = current_assignment != null and current_assignment.is_valid()

	# Update creature portrait
	if creature_portrait and empty_portrait_label:
		if is_assigned:
			empty_portrait_label.visible = false
			creature_portrait.visible = true
			_load_creature_portrait()
		else:
			creature_portrait.visible = false
			empty_portrait_label.visible = true

	# Update activity info
	if activity_button:
		_update_activity_button()

	# Update food info - always show food icon regardless of assignment status
	if food_button:
		_update_food_display()

func _update_food_display() -> void:
	# Check if food is available for assigned facilities
	if current_assignment:
		_missing_food = not _has_required_food()
	else:
		_missing_food = false

	# Always update food button icon
	if food_button:
		_load_food_icon()

func _update_action_button() -> void:
	if not action_button or not facility_resource:
		return

	var is_unlocked: bool
	if _has_unlock_override:
		is_unlocked = _override_unlock_status
	else:
		is_unlocked = facility_resource.is_unlocked
	var is_locked = not is_unlocked
	var is_assigned = current_assignment != null and current_assignment.is_valid()

	if is_locked:
		action_button.visible = false
	else:
		# Only show button if there's an assignment to remove
		if is_assigned:
			action_button.visible = true
			action_button.text = "Remove"
		else:
			action_button.visible = false

func _load_facility_icon() -> void:
	if not facility_icon or not facility_resource:
		return

	var icon_path = facility_resource.icon_path
	if icon_path.is_empty():
		_set_fallback_facility_icon()
		return

	if ResourceLoader.exists(icon_path):
		var texture = load(icon_path)
		if texture is Texture2D:
			facility_icon.texture = texture
		else:
			_set_fallback_facility_icon()
	else:
		_set_fallback_facility_icon()

func _load_creature_portrait() -> void:
	if not creature_portrait or not current_assignment:
		return

	# Get creature from collection system
	var collection = GameCore.get_system("collection")
	if not collection:
		_set_fallback_creature_portrait()
		return

	var creature_data = collection.get_creature_by_id(current_assignment.creature_id)
	if not creature_data:
		_set_fallback_creature_portrait()
		return

	# Load creature portrait - this would need to be implemented based on creature portrait system
	# For now, use a fallback
	_set_fallback_creature_portrait()

func _update_activity_button() -> void:
	if not activity_button:
		return

	# Get texture rect inside the activity button
	var texture_rect = activity_button.get_node_or_null("MarginContainer/TextureRect")
	if not texture_rect:
		return

	# Determine which activity to display
	var activity_to_show: int = -1
	if current_assignment and current_assignment.is_valid():
		# Show assigned activity
		activity_to_show = current_assignment.selected_activity
	elif facility_resource and facility_resource.supported_activities.size() > 0:
		# Show first supported activity as default
		activity_to_show = facility_resource.supported_activities[0]

	# Create activity icon based on type
	if activity_to_show >= 0:
		var activity_color = _get_activity_color(activity_to_show)
		var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		image.fill(activity_color)
		var texture = ImageTexture.new()
		texture.set_image(image)
		texture_rect.texture = texture
	else:
		# No activity - show gray
		var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		image.fill(Color(0.5, 0.5, 0.5, 1))
		var texture = ImageTexture.new()
		texture.set_image(image)
		texture_rect.texture = texture

func _load_food_icon() -> void:
	if not food_button:
		return

	var item_manager = GameCore.get_system("item_manager")
	if not item_manager:
		_set_fallback_food_icon()
		return

	# Get food item based on assignment or show default
	var food_item_id: String
	if current_assignment:
		food_item_id = _get_food_item_id(current_assignment.food_type)
	else:
		# Show default food icon when no assignment
		var default_foods = item_manager.get_items_by_type_enum(GlobalEnums.ItemType.FOOD)
		if default_foods.size() > 0:
			food_item_id = default_foods[0].item_id

	if food_item_id.is_empty():
		_set_fallback_food_icon()
		return

	var item_resource = item_manager.get_item_resource(food_item_id)
	if not item_resource:
		_set_fallback_food_icon()
		return

	var icon_path = item_resource.icon_path
	if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		var texture = load(icon_path)
		if texture is Texture2D:
			# Update the food button's texture rect
			var texture_rect = food_button.get_node_or_null("MarginContainer/TextureRect")
			if texture_rect:
				texture_rect.texture = texture
		else:
			_set_fallback_food_icon()
	else:
		_set_fallback_food_icon()

func _set_fallback_facility_icon() -> void:
	if not facility_icon:
		return

	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.6, 0.6, 0.8, 1))  # Light blue for facilities
	var texture = ImageTexture.new()
	texture.set_image(image)
	facility_icon.texture = texture

func _set_fallback_creature_portrait() -> void:
	if not creature_portrait:
		return

	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.8, 0.6, 0.4, 1))  # Brown for creatures
	var texture = ImageTexture.new()
	texture.set_image(image)
	creature_portrait.texture = texture

func _set_fallback_food_icon() -> void:
	if not food_button:
		return

	var texture_rect = food_button.get_node_or_null("MarginContainer/TextureRect")
	if texture_rect:
		var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
		image.fill(Color(0.6, 0.8, 0.4, 1))  # Green for food
		var texture = ImageTexture.new()
		texture.set_image(image)
		texture_rect.texture = texture

func _get_activity_color(activity: int) -> Color:
	match activity:
		0: return Color(0.8, 0.4, 0.4, 1)  # Red for Physical
		1: return Color(0.4, 0.8, 0.4, 1)  # Green for Agility
		2: return Color(0.4, 0.4, 0.8, 1)  # Blue for Mental
		3: return Color(0.8, 0.8, 0.4, 1)  # Yellow for Discipline
		_: return Color(0.5, 0.5, 0.5, 1)  # Gray for unknown

func _get_food_type_name(food_type: int) -> String:
	# Get display name from item resource
	var item_id = _get_food_item_id(food_type)
	if item_id.is_empty():
		return "Unknown Food"

	var item_manager = GameCore.get_system("item_manager")
	if not item_manager:
		return item_id.capitalize()

	var item_resource = item_manager.get_item_resource(item_id)
	return item_resource.display_name if item_resource else item_id.capitalize()

func _get_food_item_id(food_type: int) -> String:
	# Get item ID from ItemManager (matches food selection logic)
	var item_manager = GameCore.get_system("item_manager")
	var resource_tracker = GameCore.get_system("resource")
	if not item_manager or not resource_tracker:
		return ""

	var inventory = resource_tracker.get_inventory()

	# Get all consumable food items that are in stock
	var food_items = item_manager.get_items_by_type_enum(GlobalEnums.ItemType.FOOD)
	var available_foods: Array[ItemResource] = []
	for item_resource in food_items:
		if item_resource.is_consumable:
			var quantity = inventory.get(item_resource.item_id, 0)
			if quantity > 0:  # Only include items we have in stock
				available_foods.append(item_resource)

	# Return item ID at the specified index
	if food_type >= 0 and food_type < available_foods.size():
		return available_foods[food_type].item_id
	return ""

func _has_required_food() -> bool:
	if not current_assignment:
		return true

	var resource_tracker = GameCore.get_system("resource")
	if not resource_tracker:
		return false

	var food_item_id = _get_food_item_id(current_assignment.food_type)
	if food_item_id.is_empty():
		return false

	return resource_tracker.get_item_count(food_item_id) > 0

func _set_warning_border(alpha: float) -> void:
	if no_food_warning:
		no_food_warning.color = Color(1, 0, 0, alpha * 0.3)

func _on_mouse_entered() -> void:
	_is_hovered = true
	if background:
		var tween = create_tween()
		tween.tween_property(background, "scale", Vector2(1.02, 1.02), 0.1)

func _on_mouse_exited() -> void:
	_is_hovered = false
	if background:
		var tween = create_tween()
		tween.tween_property(background, "scale", Vector2.ONE, 0.1)

func _on_action_button_pressed() -> void:
	if not facility_resource:
		return

	var is_assigned = current_assignment != null and current_assignment.is_valid()

	if is_assigned:
		remove_pressed.emit(facility_resource.facility_id)

func _on_unlock_button_pressed() -> void:
	if facility_resource:
		unlock_pressed.emit(facility_resource.facility_id)

func _on_food_button_pressed() -> void:
	"""Handle food button press - open food selection popup"""
	if not facility_resource:
		return

	# Only allow food selection for unlocked facilities
	var is_unlocked: bool
	if _has_unlock_override:
		is_unlocked = _override_unlock_status
	else:
		is_unlocked = facility_resource.is_unlocked

	if is_unlocked:
		food_selection_requested.emit(facility_resource.facility_id)

func _on_activity_button_pressed() -> void:
	"""Handle activity button press - open activity selection popup"""
	if not facility_resource:
		return

	# Only allow activity selection for unlocked facilities
	var is_unlocked: bool
	if _has_unlock_override:
		is_unlocked = _override_unlock_status
	else:
		is_unlocked = facility_resource.is_unlocked

	if is_unlocked:
		activity_selection_requested.emit(facility_resource.facility_id)

func get_facility_id() -> String:
	return facility_resource.facility_id if facility_resource else ""

func is_locked() -> bool:
	if not facility_resource:
		return true
	var is_unlocked: bool
	if _has_unlock_override:
		is_unlocked = _override_unlock_status
	else:
		is_unlocked = facility_resource.is_unlocked
	return not is_unlocked

func is_assigned() -> bool:
	return current_assignment != null and current_assignment.is_valid()

func set_food_warning(has_warning: bool) -> void:
	_missing_food = has_warning
	_update_visual_state()

func get_selected_food_type() -> int:
	"""Get the currently selected food type (for external access)"""
	return _get_selected_food_type()

func get_selected_activity() -> int:
	"""Get the currently selected activity (for external access)"""
	return _get_selected_activity()

func set_selected_food_type(food_type: int) -> void:
	"""Set the selected food type (called by food selection popup)"""
	_selected_food_type = food_type
	_update_food_display()

func set_selected_activity(activity: int) -> void:
	"""Set the selected activity (called by activity selection popup)"""
	_selected_activity = activity
	_update_activity_button()

func can_accept_creature() -> bool:
	"""Check if this facility can accept a new creature assignment"""
	if not facility_resource:
		return false

	# Check if unlocked
	var is_unlocked: bool
	if _has_unlock_override:
		is_unlocked = _override_unlock_status
	else:
		is_unlocked = facility_resource.is_unlocked

	if not is_unlocked:
		return false

	# Check if already has assignment
	if current_assignment and current_assignment.is_valid():
		return false  # Already occupied

	return true

func _can_drop_data(position: Vector2, data: Variant) -> bool:
	"""Check if we can accept dropped data"""
	if not can_accept_creature():
		return false

	# Check if it's creature data
	if data is Dictionary and data.has("creature_data"):
		var creature = data.get("creature_data")
		if creature is CreatureData:
			return true
	return false

func _drop_data(position: Vector2, data: Variant) -> void:
	"""Handle dropped data - create immediate assignment"""
	if not _can_drop_data(position, data):
		push_error("FacilityCard: Invalid drop attempted")
		return

	if data is Dictionary and data.has("creature_data"):
		var creature = data.get("creature_data") as CreatureData
		if creature:
			# Use selected food/activity or defaults
			var food_type = _get_selected_food_type()
			var activity = _get_selected_activity()

			# Create assignment immediately via FacilitySystem
			var success = _create_immediate_assignment(creature, activity, food_type)
			if success:
				print("[FacilityCard] Drag-drop assignment created for ", creature.creature_name)
			else:
				print("[FacilityCard] Failed to create assignment for ", creature.creature_name)

func _create_immediate_assignment(creature_data: CreatureData, activity: int, food_type: int) -> bool:
	"""Create facility assignment immediately via FacilitySystem"""
	if not facility_resource or not creature_data:
		push_error("FacilityCard: Invalid parameters for assignment creation")
		return false

	# Get FacilitySystem
	var facility_system = GameCore.get_system("facility")
	if not facility_system:
		push_error("FacilityCard: FacilitySystem not available")
		return false

	# Create assignment through facility system
	var success = facility_system.assign_creature(
		facility_resource.facility_id,
		creature_data.id,
		activity,
		food_type
	)

	if not success:
		push_error("FacilityCard: Failed to assign creature ", creature_data.creature_name, " to facility ", facility_resource.facility_id)
		return false

	# Assignment successful - signals will be emitted by FacilitySystem
	return true

func _get_first_available_food_type() -> int:
	"""Get the index of the first available food item"""
	var item_manager = GameCore.get_system("item_manager")
	var resource_tracker = GameCore.get_system("resource")
	if not item_manager or not resource_tracker:
		return -1

	var inventory = resource_tracker.get_inventory()
	var food_items = item_manager.get_items_by_type_enum(GlobalEnums.ItemType.FOOD)

	for i in range(food_items.size()):
		var item_resource = food_items[i]
		if item_resource.is_consumable:
			var quantity = inventory.get(item_resource.item_id, 0)
			if quantity > 0:
				return i

	return -1

func _get_selected_food_type() -> int:
	"""Get currently selected food type or first available default"""
	if _selected_food_type >= 0:
		return _selected_food_type

	# Use assignment food if available
	if current_assignment and current_assignment.food_type >= 0:
		return current_assignment.food_type

	# Fall back to first available food
	return _get_first_available_food_type()

func _get_selected_activity() -> int:
	"""Get currently selected activity or first supported default"""
	if _selected_activity >= 0:
		return _selected_activity

	# Use assignment activity if available
	if current_assignment and current_assignment.selected_activity >= 0:
		return current_assignment.selected_activity

	# Fall back to first supported activity
	if facility_resource and facility_resource.supported_activities.size() > 0:
		return facility_resource.supported_activities[0]

	return -1

func _show_valid_drop_highlight() -> void:
	"""Show visual feedback for valid drop target"""
	_is_drag_highlighted = true
	# Green highlight for valid drop
	modulate = Color(0.8, 1.2, 0.8, 1.0)
	if background:
		var tween = create_tween()
		tween.tween_property(background, "scale", Vector2(1.05, 1.05), 0.1)

func _show_invalid_drop_highlight() -> void:
	"""Show visual feedback for invalid drop target"""
	_is_drag_highlighted = true
	# Red highlight for invalid drop
	modulate = Color(1.2, 0.8, 0.8, 1.0)
	if background:
		var tween = create_tween()
		tween.tween_property(background, "scale", Vector2(0.95, 0.95), 0.1)

func _clear_drag_highlight() -> void:
	"""Clear drag visual feedback"""
	if _is_drag_highlighted:
		_is_drag_highlighted = false
		modulate = Color.WHITE
		if background:
			var tween = create_tween()
			tween.tween_property(background, "scale", Vector2.ONE, 0.1)

func _notification(what: int) -> void:
	"""Handle drag and drop visual feedback"""
	match what:
		NOTIFICATION_DRAG_BEGIN:
			# Check if we can accept the drag data
			var viewport = get_viewport()
			if viewport:
				var drag_data = viewport.gui_get_drag_data()
				if _can_drop_data(Vector2.ZERO, drag_data):
					_show_valid_drop_highlight()
				else:
					_show_invalid_drop_highlight()
		NOTIFICATION_DRAG_END:
			# Reset visual state
			_clear_drag_highlight()


func update_food_selection(food_type: int) -> void:
	"""Update the food selection for this facility"""
	_selected_food_type = food_type
	if current_assignment:
		current_assignment.food_type = food_type
	_update_food_display()

func update_activity_selection(activity: int) -> void:
	"""Update the activity selection for this facility"""
	_selected_activity = activity
	if current_assignment:
		current_assignment.selected_activity = activity
	_update_activity_button()