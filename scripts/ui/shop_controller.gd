@tool
extends Control
class_name ShopController

# Shop Controller - Main UI controller for the creature emporium
# Manages item display, purchasing, and visual effects

# === NODE REFERENCES ===
@onready var background: Panel = $Background
@onready var title_label: Label = $Background/VBoxContainer/ShopHeader/Title
@onready var close_button: Button = $Background/VBoxContainer/ShopHeader/CloseButton

# Category tabs
@onready var creatures_tab: Button = $Background/VBoxContainer/MainContent/CategoryPanel/CreaturesTab
@onready var food_tab: Button = $Background/VBoxContainer/MainContent/CategoryPanel/FoodTab
@onready var equipment_tab: Button = $Background/VBoxContainer/MainContent/CategoryPanel/EquipmentTab
@onready var facilities_tab: Button = $Background/VBoxContainer/MainContent/CategoryPanel/FacilitiesTab
@onready var consumables_tab: Button = $Background/VBoxContainer/MainContent/CategoryPanel/ConsumablesTab

# Item display
@onready var items_panel: ScrollContainer = $Background/VBoxContainer/MainContent/ItemsPanel
@onready var item_grid: GridContainer = $Background/VBoxContainer/MainContent/ItemsPanel/ItemGrid

# Purchase panel
@onready var purchase_panel: Panel = $Background/VBoxContainer/PurchasePanel
@onready var selected_item_label: Label = $Background/VBoxContainer/PurchasePanel/PurchaseContent/DetailsContainer/LeftColumn/SelectedItem
@onready var item_description_label: Label = $Background/VBoxContainer/PurchasePanel/PurchaseContent/DetailsContainer/LeftColumn/ItemDescription
@onready var quantity_spinbox: SpinBox = $Background/VBoxContainer/PurchasePanel/PurchaseContent/DetailsContainer/RightColumn/QuantityContainer/Quantity
@onready var total_cost_label: Label = $Background/VBoxContainer/PurchasePanel/PurchaseContent/DetailsContainer/RightColumn/TotalCost
@onready var buy_button: Button = $Background/VBoxContainer/PurchasePanel/PurchaseContent/DetailsContainer/RightColumn/BuyButton

# Animation elements
@onready var animation_container: Control = $AnimationContainer
@onready var purchase_animation: Control = $AnimationContainer/PurchaseAnimation
@onready var success_label: Label = $AnimationContainer/PurchaseAnimation/SuccessLabel
@onready var gold_animation: Control = $AnimationContainer/GoldAnimation
@onready var gold_change_label: Label = $AnimationContainer/GoldAnimation/GoldChangeLabel

# Shop keeper elements
@onready var shop_keeper_area: Control = $Background/VBoxContainer/ShopKeeperArea
@onready var shop_keeper_container: Control = $Background/VBoxContainer/ShopKeeperArea/ShopKeeperPortrait

var shop_keeper_portrait # Optional ShopKeeperPortraitController

# === PROPERTIES ===
var shop_system: Node
var resource_tracker: Node
var item_manager: Node
var ui_manager: Node
var signal_bus: SignalBus

var current_category: String = "food"
var selected_item_data: Dictionary = {}
var item_cards: Array[Control] = []
var category_tabs: Array[Button] = []

# Shop item card scene
const SHOP_ITEM_CARD_SCENE = preload("res://scenes/ui/components/shop_item_card.tscn")
# Optional shop keeper scene - comment out if not available
const SHOP_KEEPER_PORTRAIT_SCENE = preload("res://scenes/ui/components/shop_keeper_portrait.tscn")
# const SHOP_KEEPER_PORTRAIT_SCENE = null

# === INITIALIZATION ===

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_initialize_systems()
	_setup_ui()
	_connect_signals()
	_load_initial_data()

func _initialize_systems() -> void:
	"""Initialize required systems."""
	shop_system = GameCore.get_system("shop")
	resource_tracker = GameCore.get_system("resource")
	item_manager = GameCore.get_system("item_manager")
	ui_manager = GameCore.get_system("ui")
	signal_bus = GameCore.get_signal_bus()

	if not shop_system:
		push_error("ShopController: ShopSystem required but not loaded")
		return

	if not resource_tracker:
		push_error("ShopController: ResourceTracker required but not loaded")
		return

	if not item_manager:
		push_error("ShopController: ItemManager required but not loaded")
		return

func _setup_ui() -> void:
	"""Set up UI elements and initial state."""
	# Set up category tabs array for easier management
	category_tabs = [food_tab, equipment_tab, consumables_tab, creatures_tab, facilities_tab]

	# Hide animation elements initially
	if animation_container:
		animation_container.visible = false

	# Set up quantity spinbox
	if quantity_spinbox:
		quantity_spinbox.min_value = 1
		quantity_spinbox.max_value = 99
		quantity_spinbox.value = 1


	# Set up shop keeper
	_setup_shop_keeper()

func _setup_shop_keeper() -> void:
	"""Set up the shop keeper portrait."""
	if not shop_keeper_container or not SHOP_KEEPER_PORTRAIT_SCENE:
		return

	# Instantiate shop keeper portrait
	shop_keeper_portrait = SHOP_KEEPER_PORTRAIT_SCENE.instantiate()
	if shop_keeper_portrait:
		shop_keeper_container.add_child(shop_keeper_portrait)

func _connect_signals() -> void:
	"""Connect all UI signals and system signals."""
	# Category tab signals
	if food_tab:
		food_tab.pressed.connect(_on_category_selected.bind("food"))
	if equipment_tab:
		equipment_tab.pressed.connect(_on_category_selected.bind("equipment"))
	if consumables_tab:
		consumables_tab.pressed.connect(_on_category_selected.bind("consumable"))
	if creatures_tab:
		creatures_tab.pressed.connect(_on_category_selected.bind("creatures"))
	if facilities_tab:
		facilities_tab.pressed.connect(_on_category_selected.bind("facilities"))

	# Purchase panel signals
	if quantity_spinbox:
		quantity_spinbox.value_changed.connect(_on_quantity_changed)
	if buy_button:
		buy_button.pressed.connect(_on_buy_button_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)

	# System signals
	if signal_bus:
		signal_bus.gold_changed.connect(_on_gold_changed)
		signal_bus.item_purchased.connect(_on_item_purchased)
		signal_bus.shop_refreshed.connect(_on_shop_refreshed)

func _load_initial_data() -> void:
	"""Load initial shop data and display."""
	_switch_to_category(current_category)

# === CATEGORY MANAGEMENT ===

func _on_category_selected(category: String) -> void:
	"""Handle category tab selection."""
	_switch_to_category(category)

func _switch_to_category(category: String) -> void:
	"""Switch to display items from specified category."""
	current_category = category
	_update_tab_states()
	_load_category_items()
	_clear_selection()

func _update_tab_states() -> void:
	"""Update visual state of category tabs."""
	for tab in category_tabs:
		if not tab:
			continue
		tab.button_pressed = false

	# Set active tab
	match current_category:
		"food":
			if food_tab:
				food_tab.button_pressed = true
		"equipment":
			if equipment_tab:
				equipment_tab.button_pressed = true
		"consumable":
			if consumables_tab:
				consumables_tab.button_pressed = true
		"creatures":
			if creatures_tab:
				creatures_tab.button_pressed = true
		"facilities":
			if facilities_tab:
				facilities_tab.button_pressed = true

func _load_category_items() -> void:
	"""Load and display items for current category."""
	if not shop_system or not item_grid:
		return

	# Clear existing items
	_clear_item_grid()

	# Get items for current category
	var category_items = shop_system.get_category_items(current_category)

	# Special handling for facilities (not in shop system yet)
	if current_category == "facilities":
		category_items = _get_facility_items()

	# Create item cards
	for shop_item in category_items:
		_create_item_card(shop_item)

	print("ShopController: Loaded %d items for category '%s'" % [category_items.size(), current_category])


func _get_facility_items() -> Array:
	"""Get facility items (placeholder for future implementation)."""
	var facility_items: Array = []

	# Placeholder facilities
	var facilities = [
		{"item_id": "basic_incubator", "display_name": "Basic Incubator", "final_price": 500, "stock_quantity": 2},
		{"item_id": "training_grounds", "display_name": "Training Grounds", "final_price": 800, "stock_quantity": 1},
		{"item_id": "healing_pool", "display_name": "Healing Pool", "final_price": 600, "stock_quantity": 1}
	]

	for facility_data in facilities:
		var shop_item = shop_system.ShopItem.new(
			facility_data.item_id,
			facility_data.stock_quantity,
			facility_data.final_price,
			"facilities"
		)
		facility_items.append(shop_item)

	return facility_items

func _clear_item_grid() -> void:
	"""Clear all items from the grid."""
	for card in item_cards:
		if card and is_instance_valid(card):
			card.queue_free()
	item_cards.clear()

	# Clear grid children
	if item_grid:
		for child in item_grid.get_children():
			child.queue_free()

func _create_item_card(shop_item) -> void:
	"""Create and configure an item card."""
	if not SHOP_ITEM_CARD_SCENE or not item_grid:
		return

	var card = SHOP_ITEM_CARD_SCENE.instantiate()
	if not card:
		return

	# Set up item data dictionary
	var item_data = {
		"item_id": shop_item.item_id,
		"display_name": _get_item_display_name(shop_item.item_id),
		"final_price": shop_item.current_price,
		"stock_quantity": shop_item.quantity,
		"category": shop_item.category,
		"description": _get_item_description(shop_item.item_id)
	}

	# Add to grid and configure
	item_grid.add_child(card)
	item_cards.append(card)

	# Set up the card with item data
	card.setup_item(item_data, "shop", shop_system)

	# Connect item selection signal
	card.item_selected.connect(_on_item_selected)

func _get_item_display_name(item_id: String) -> String:
	"""Get display name for an item."""
	if not item_manager:
		return item_id.capitalize().replace("_", " ")

	var item_resource = item_manager.get_item_resource(item_id)
	if item_resource and item_resource.has_method("get_display_name"):
		return item_resource.get_display_name()
	elif item_resource and "display_name" in item_resource:
		return item_resource.display_name

	# Fallback to formatted item_id
	return item_id.capitalize().replace("_", " ")

func _get_item_description(item_id: String) -> String:
	"""Get description for an item."""
	if not item_manager:
		return "No description available."

	var item_resource = item_manager.get_item_resource(item_id)
	if item_resource and "description" in item_resource:
		return item_resource.description

	# Generate basic descriptions based on item type
	if "egg" in item_id:
		return "A precious egg that can be hatched into a creature."
	elif "food" in item_id or "grain" in item_id or "hay" in item_id:
		return "Nutritious food for your creatures."
	elif "potion" in item_id:
		return "A magical potion with beneficial effects."
	elif "incubator" in item_id:
		return "A facility for hatching creature eggs."
	elif "training" in item_id:
		return "A facility for improving creature abilities."

	return "A useful item for creature management."

# === ITEM SELECTION AND PURCHASING ===

func _on_item_selected(item_data: Dictionary) -> void:
	"""Handle item selection from item card."""
	selected_item_data = item_data
	_update_purchase_panel()

	# Shop keeper responds to browsing
	if shop_keeper_portrait:
		shop_keeper_portrait.show_dialogue("browse")

func _update_purchase_panel() -> void:
	"""Update the purchase panel with selected item details."""
	if selected_item_data.is_empty():
		_clear_selection()
		return

	# Update item info
	if selected_item_label:
		selected_item_label.text = selected_item_data.get("display_name", "Unknown Item")

	if item_description_label:
		item_description_label.text = selected_item_data.get("description", "No description available.")

	# Update quantity limits
	if quantity_spinbox:
		var max_stock = selected_item_data.get("stock_quantity", 0)
		quantity_spinbox.max_value = max(1, max_stock)
		quantity_spinbox.value = 1

	# Update costs and button state
	_update_purchase_costs()

func _clear_selection() -> void:
	"""Clear item selection and reset purchase panel."""
	selected_item_data.clear()

	if selected_item_label:
		selected_item_label.text = "No item selected"
	if item_description_label:
		item_description_label.text = "Select an item to see details"
	if total_cost_label:
		total_cost_label.text = "Total: 0 g"
	if buy_button:
		buy_button.disabled = true

func _on_quantity_changed(new_quantity: float) -> void:
	"""Handle quantity change in spinbox."""
	_update_purchase_costs()

func _update_purchase_costs() -> void:
	"""Update total cost and buy button state."""
	if selected_item_data.is_empty() or not quantity_spinbox:
		return

	var item_id = selected_item_data.get("item_id", "")
	var quantity = int(quantity_spinbox.value)
	var stock = selected_item_data.get("stock_quantity", 0)

	# Calculate total cost
	var total_cost = 0
	if shop_system:
		total_cost = shop_system.calculate_total_cost(item_id, quantity)

	# Update cost display
	if total_cost_label:
		total_cost_label.text = "Total: %d g" % total_cost

	# Update buy button state
	if buy_button:
		var can_afford = resource_tracker and resource_tracker.can_afford(total_cost)
		var in_stock = stock >= quantity
		buy_button.disabled = not (can_afford and in_stock and quantity > 0)

		if not in_stock:
			buy_button.text = "Out of Stock"
		elif not can_afford:
			buy_button.text = "Can't Afford"
			# Shop keeper responds to insufficient funds
			if shop_keeper_portrait:
				shop_keeper_portrait.show_dialogue("insufficient_funds")
		else:
			buy_button.text = "Buy"

func _on_buy_button_pressed() -> void:
	"""Handle buy button press."""
	if selected_item_data.is_empty() or not shop_system or not quantity_spinbox:
		return

	var item_id = selected_item_data.get("item_id", "")
	var quantity = int(quantity_spinbox.value)

	# Attempt purchase
	var success = shop_system.purchase_item(item_id, quantity)

	if success:
		_animate_successful_purchase(quantity)
		_refresh_current_view()
		_clear_selection()
		# Shop keeper celebrates successful purchase
		if shop_keeper_portrait:
			shop_keeper_portrait.simulate_purchase_success()
	else:
		_show_purchase_error()
		# Shop keeper shows disappointment
		if shop_keeper_portrait:
			shop_keeper_portrait.simulate_insufficient_funds()

func _animate_successful_purchase(quantity: int) -> void:
	"""Animate successful purchase with visual feedback."""
	if not animation_container or not purchase_animation:
		return

	animation_container.visible = true

	# Success message animation
	success_label.text = "Purchase Successful!\n+%d item(s)" % quantity
	success_label.modulate = Color.TRANSPARENT
	purchase_animation.scale = Vector2(0.5, 0.5)

	var tween = create_tween()
	tween.set_parallel(true)

	# Fade in and scale up success message
	tween.tween_property(success_label, "modulate", Color.WHITE, 0.3)
	tween.tween_property(purchase_animation, "scale", Vector2.ONE, 0.3)

	# Hold for a moment
	tween.tween_interval(1.0)

	# Fade out
	tween.tween_property(success_label, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_property(purchase_animation, "scale", Vector2(1.2, 1.2), 0.3)

	# Hide container when done
	tween.tween_callback(func(): animation_container.visible = false)

func _animate_gold_deduction(amount: int) -> void:
	"""Animate gold amount change."""
	if not gold_change_label:
		return

	gold_change_label.text = "-%d g" % amount
	gold_change_label.modulate = Color.RED

	var start_pos = gold_change_label.position
	var end_pos = start_pos + Vector2(0, -50)

	var tween = create_tween()
	tween.set_parallel(true)

	# Move up and fade out
	tween.tween_property(gold_change_label, "position", end_pos, 1.0)
	tween.tween_property(gold_change_label, "modulate", Color.TRANSPARENT, 1.0)

	# Reset position after animation
	tween.tween_callback(func(): gold_change_label.position = start_pos)

func _show_purchase_error() -> void:
	"""Show error message for failed purchase."""
	if ui_manager:
		ui_manager.show_notification("Purchase failed! Check your gold and item availability.", 3.0)

# === DISPLAY UPDATES ===

func _refresh_current_view() -> void:
	"""Refresh the current category view."""
	_load_category_items()

# === SIGNAL HANDLERS ===

func _on_gold_changed(old_amount: int, new_amount: int, change: int) -> void:
	"""Handle gold amount changes."""

	# Animate gold deduction if it's a purchase
	if change < 0:
		_animate_gold_deduction(-change)

	# Update purchase panel in case affordability changed
	if not selected_item_data.is_empty():
		_update_purchase_costs()

func _on_item_purchased(item_id: String, quantity: int, source: String, cost: int) -> void:
	"""Handle item purchase notifications."""
	if source == "shop":
		print("ShopController: Item purchased - %s x%d for %d gold" % [item_id, quantity, cost])

func _on_shop_refreshed(restock_weeks: int) -> void:
	"""Handle shop restocking."""
	_refresh_current_view()
	if ui_manager:
		ui_manager.show_notification("Shop restocked! New items available.", 3.0)
	# Shop keeper announces special deals
	if shop_keeper_portrait:
		shop_keeper_portrait.simulate_special_deal()

func _on_close_button_pressed() -> void:
	"""Handle close button press."""
	# Shop keeper says farewell
	if shop_keeper_portrait:
		shop_keeper_portrait.show_farewell()

	if ui_manager:
		ui_manager.change_scene("res://scenes/ui/overlay_menu.tscn")
	else:
		# Fallback - hide this control
		visible = false

# === PUBLIC INTERFACE ===

func refresh_shop() -> void:
	"""Public method to refresh shop display."""
	_refresh_current_view()

func select_category(category: String) -> void:
	"""Public method to select a specific category."""
	if category in ["food", "equipment", "consumable", "creatures", "facilities"]:
		_switch_to_category(category)

func get_current_category() -> String:
	"""Get the currently selected category."""
	return current_category
