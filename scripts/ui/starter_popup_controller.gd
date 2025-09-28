class_name StarterPopupController
extends Control

# UI References
@onready var creature_sprite: AnimatedSprite2D = $Panel/MarginContainer/VBoxContainer/CreatureContainer/CreatureSprite
@onready var start_button: Button = $Panel/MarginContainer/VBoxContainer/StartButton
@onready var food_label: Label = $Panel/MarginContainer/VBoxContainer/ItemsContainer/Panel/FoodLabel
@onready var creature_name_label: Label = $Panel/MarginContainer/VBoxContainer/CreatureContainer/CreatureName
@onready var gold_label: Label = $Panel/MarginContainer/VBoxContainer/ItemsContainer/Panel3/GoldLabel

# Starter creature data
var starter_creature: CreatureData

func _ready() -> void:
	# Connect button signal
	start_button.pressed.connect(_on_start_button_pressed)

	# Initialize with default values and prepare for display
	_setup_starter_data()
	_update_display()

func _setup_starter_data() -> void:
	"""Create starter creature and setup initial resources."""
	# Create a starter creature (using species system)
	var species_system = GameCore.get_system("species")
	var collection_system = GameCore.get_system("collection")

	# Get a basic species for the starter (using first available species)
	var available_species = species_system.get_all_species()
	if available_species.size() > 0:
		# Generate creature with fixed name "Kevin"
		starter_creature = CreatureGenerator.generate_creature_data(available_species[0], GlobalEnums.GenerationType.UNIFORM, "Kevin")
	else:
		# Fallback if no species available
		push_error("StarterPopupController: No species available for starter creature")
		return

func _update_display() -> void:
	"""Update the popup display with starter items."""
	if starter_creature:
		creature_name_label.text = starter_creature.creature_name
		#creature_sprite.sprite_frames = starter_creature

		# Setup animated sprite (placeholder animation)
		if creature_sprite and creature_sprite.sprite_frames:
			creature_sprite.play("idle")

	# Display starter resources
	food_label.text = "x5"
	gold_label.text = "500g"

func _on_start_button_pressed() -> void:
	"""Handle start button press - give starter items and close popup."""
	_give_starter_items()
	_close_popup()

func _give_starter_items() -> void:
	"""Give the player their starter creature and resources."""
	var resource_tracker = GameCore.get_system("resource")
	var collection_system = GameCore.get_system("collection")
	var item_manager = GameCore.get_system("item_manager")

	# Add starter creature to collection
	if starter_creature:
		collection_system.acquire_creature(starter_creature, "starting_gift")

	# Add starting gold
	resource_tracker.add_gold(500, "starting_gift")

	# Add starting food (find a basic food item)
	var food_item_ids = item_manager.get_items_by_type("food")
	if food_item_ids.size() > 0:
		var basic_food_id = food_item_ids[0]  # Get first food item ID
		resource_tracker.add_item(basic_food_id, 5)

func _close_popup() -> void:
	"""Close the popup and emit signal."""
	var signal_bus = GameCore.get_signal_bus()
	signal_bus.emit_starter_popup_closed()

	# Hide/remove the popup
	queue_free()

func show_popup() -> void:
	"""Show the popup (called externally)."""
	visible = true

	# Center the popup on screen
	var viewport_size = get_viewport().get_visible_rect().size
	position = (viewport_size - size) / 2
