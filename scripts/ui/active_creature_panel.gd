extends Control

@onready var active_grid: GridContainer = $MarginContainer/GridContainer
@export var child_width_reference: float = 100.0 # Set a reference width for your child nodes

var creature_card_scene = preload("res://scenes/ui/components/creature_card.tscn")

var collection_system
var _active_cards: Array[CreatureCard] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		_setup_collection_panel()

	# Connect to the resized signal of the GridContainer itself
	resized.connect(_on_grid_container_resized)
	# Optionally, call it once on ready to set initial columns
	_on_grid_container_resized()
	
func _setup_collection_panel() -> void:
	collection_system = GameCore.get_system("collection")

	if not collection_system:
		push_error("CollectionPanel: Collection system not found")
		return

	_setup_active_grid()
	_setup_signals()
	_update_active_roster()

func _setup_active_grid() -> void:
	active_grid.columns = 3

	for i in range(6):
		var card = creature_card_scene.instantiate() as CreatureCard
		card.slot_index = i
		card.is_active_slot = true
		card.is_empty_slot = true
		card.clicked.connect(_on_creature_clicked)
		active_grid.add_child(card)
		_active_cards.append(card)
		
	_on_grid_container_resized()

func _setup_signals() -> void:
	var signal_bus = GameCore.get_signal_bus()
	signal_bus.active_roster_changed.connect(_on_active_roster_changed)
	signal_bus.creature_acquired.connect(_on_creature_acquired)
	signal_bus.creature_released.connect(_on_creature_released)
	signal_bus.week_advanced.connect(_on_week_advanced)

func _on_creature_clicked(creature: CreatureData) -> void:
	print("CollectionPanel: Creature clicked: ", creature.creature_name)

func _on_active_roster_changed(new_roster: Array[CreatureData]) -> void:
	_update_active_roster()

func _on_creature_acquired(creature_data: CreatureData, source: String) -> void:
	_update_active_roster()

func _on_creature_released(creature_data: CreatureData, reason: String) -> void:
	_update_active_roster()
	
func _on_week_advanced(new_week: int, total_weeks: int) -> void:
	print("CollectionPanel: Week advanced to %d (total: %d) - refreshing display" % [new_week, total_weeks])
	_update_active_roster()

func _update_active_roster() -> void:
	if not collection_system:
		return

	var active_creatures = collection_system.get_active_creatures()

	for i in range(6):
		var card = _active_cards[i]
		if i < active_creatures.size():
			card.set_creature(active_creatures[i])
		else:
			card.clear_slot()
		
func _on_grid_container_resized():
	if active_grid.get_child_count() > 0:
		var new_column_amount = floor(size.x / child_width_reference)
		# Ensure a minimum of 1 column
		new_column_amount = max(1, new_column_amount) 

		if new_column_amount != active_grid.columns:
			active_grid.columns = new_column_amount
