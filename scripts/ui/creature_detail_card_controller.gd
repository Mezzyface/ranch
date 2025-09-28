extends Control

@onready var creature_name_label: Label = $VBoxContainer/HeaderContainer/CreatureNameLabel
@onready var species_label: Label = $VBoxContainer/HeaderContainer/SpeciesLabel
@onready var age_label: Label = $VBoxContainer/InfoContainer/AgeContainer/AgeLabel
@onready var lifespan_label: Label = $VBoxContainer/InfoContainer/AgeContainer/LifespanLabel
@onready var happiness_label: Label = $VBoxContainer/InfoContainer/StatusContainer/HappinessLabel
@onready var loyalty_label: Label = $VBoxContainer/InfoContainer/StatusContainer/LoyaltyLabel
@onready var creature_sprite: AnimatedSprite2D = $VBoxContainer/CreatureContainer/CreatureSprite
@onready var stats_container: VBoxContainer = $VBoxContainer/StatsContainer
@onready var tags_container: HBoxContainer = $VBoxContainer/TagsContainer/TagsHBox
@onready var close_button: Button = $VBoxContainer/HeaderContainer/CloseButton

var current_creature_data: CreatureData

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)

func populate(creature_data: CreatureData) -> void:
	if not creature_data:
		push_error("CreatureDetailCardController: Cannot populate with null creature_data")
		return

	current_creature_data = creature_data

	# Populate basic info
	_populate_basic_info(creature_data)

	# Populate stats
	_populate_stats(creature_data)

	# Populate tags
	_populate_tags(creature_data)

	# Set creature sprite
	_setup_creature_sprite(creature_data)

func _populate_basic_info(creature_data: CreatureData) -> void:
	if creature_name_label:
		creature_name_label.text = creature_data.creature_name if creature_data.creature_name else "Unnamed Creature"

	if species_label:
		# Get species display name from SpeciesSystem
		var species_system = GameCore.get_system("species")
		var species_resource = species_system.get_species(creature_data.species_id)
		var species_name = species_resource.display_name if species_resource else creature_data.species_id
		species_label.text = species_name

	if age_label:
		age_label.text = "Age: %d weeks" % creature_data.age_weeks

	if lifespan_label:
		lifespan_label.text = "Lifespan: %d weeks" % creature_data.lifespan_weeks

	if happiness_label:
		happiness_label.text = "Happiness: %.1f" % creature_data.happiness

	if loyalty_label:
		loyalty_label.text = "Loyalty: %.1f" % creature_data.loyalty

func _populate_stats(creature_data: CreatureData) -> void:
	if not stats_container:
		return

	# Clear existing stat labels
	for child in stats_container.get_children():
		child.queue_free()

	# Add stat labels
	for stat_name in creature_data.stats.keys():
		var stat_value = creature_data.stats[stat_name]
		var stat_label = Label.new()
		stat_label.text = "%s: %d" % [stat_name.capitalize(), stat_value]
		stats_container.add_child(stat_label)

func _populate_tags(creature_data: CreatureData) -> void:
	if not tags_container:
		return

	# Clear existing tag labels
	for child in tags_container.get_children():
		child.queue_free()

	# Add tag labels
	for tag in creature_data.tags:
		var tag_label = Label.new()
		tag_label.text = tag
		# Apply basic styling for tags
		tag_label.add_theme_color_override("font_color", Color.WHITE)
		tag_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		tags_container.add_child(tag_label)

func _setup_creature_sprite(creature_data: CreatureData) -> void:
	if not creature_sprite:
		return

	# Get species resource for sprite information
	var species_system = GameCore.get_system("species")
	var species_resource = species_system.get_species(creature_data.species_id)

	if not species_resource:
		push_error("CreatureDetailCardController: Could not find species resource for species_id: %s" % creature_data.species_id)
		return

	# Load and set sprite frames
	if species_resource.sprite_frames_path:
		var sprite_frames = load(species_resource.sprite_frames_path) as SpriteFrames
		if sprite_frames:
			creature_sprite.sprite_frames = sprite_frames
			# Play idle animation if it exists
			if sprite_frames.has_animation("idle"):
				creature_sprite.play("idle")
			elif sprite_frames.has_animation("default"):
				creature_sprite.play("default")
		else:
			push_error("CreatureDetailCardController: Could not load sprite frames from path: %s" % species_resource.sprite_frames_path)

func _on_close_button_pressed() -> void:
	hide()
	# Optionally queue_free() if this is a dynamically created popup
	# queue_free()

func get_creature_data() -> CreatureData:
	return current_creature_data