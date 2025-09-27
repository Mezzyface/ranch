@tool
extends Control

# Shop Item Card - Individual item display component for shop grid
# Optimized for performance with 50+ items displayed

signal item_selected(item: Dictionary)

@onready var background: Panel = $Background
@onready var item_icon: TextureRect = $Background/VBoxContainer/ItemIcon
@onready var item_name: Label = $Background/VBoxContainer/ItemName
@onready var item_price: Label = $Background/VBoxContainer/ItemPrice
@onready var item_stock: Label = $Background/VBoxContainer/ItemStock
@onready var purchase_button: Button = $Background/VBoxContainer/PurchaseButton
@onready var hover_area: Button = $HoverArea

var item_data: Dictionary
var vendor_id: String
var shop_system: Node
var _is_hovered: bool = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		_setup_signals()

func _setup_signals() -> void:
	if hover_area:
		hover_area.mouse_entered.connect(_on_mouse_entered)
		hover_area.mouse_exited.connect(_on_mouse_exited)
		hover_area.pressed.connect(_on_card_clicked)

	if purchase_button:
		purchase_button.pressed.connect(_on_purchase_pressed)

func setup_item(item: Dictionary, vendor: String, system: Node) -> void:
	item_data = item
	vendor_id = vendor
	shop_system = system
	_update_display()

func _update_display() -> void:
	if item_data.is_empty():
		return

	# Update item name
	if item_name:
		item_name.text = item_data.get("display_name", "Unknown Item")

	# Update icon
	if item_icon:
		_load_item_icon()

	# Update price
	if item_price:
		var price = item_data.get("final_price", 0)
		item_price.text = "%d g" % price

	# Update stock
	if item_stock:
		var stock = item_data.get("stock_quantity", 0)
		item_stock.text = "Stock: %d" % stock
		item_stock.modulate = Color.WHITE if stock > 0 else Color.RED

	# Update purchase button
	if purchase_button:
		var stock = item_data.get("stock_quantity", 0)
		purchase_button.disabled = stock <= 0
		purchase_button.text = "Buy" if stock > 0 else "Out of Stock"

	# Update background based on availability
	if background:
		var bg_color = Color(0.2, 0.2, 0.3, 0.8)
		var stock = item_data.get("stock_quantity", 0)
		if stock <= 0:
			bg_color = Color(0.3, 0.2, 0.2, 0.8)  # Reddish for out of stock
		background.self_modulate = bg_color

func refresh_display() -> void:
	_update_display()

func _on_mouse_entered() -> void:
	_is_hovered = true
	if background:
		var tween = create_tween()
		tween.tween_property(background, "scale", Vector2(1.05, 1.05), 0.1)

func _on_mouse_exited() -> void:
	_is_hovered = false
	if background:
		var tween = create_tween()
		tween.tween_property(background, "scale", Vector2.ONE, 0.1)

func _on_card_clicked() -> void:
	if not item_data.is_empty():
		item_selected.emit(item_data)

func _on_purchase_pressed() -> void:
	if not item_data.is_empty() and item_data.get("stock_quantity", 0) > 0:
		item_selected.emit(item_data)

func get_item_data() -> Dictionary:
	return item_data

func update_stock(new_stock: int) -> void:
	if not item_data.is_empty():
		item_data["stock_quantity"] = new_stock
		_update_display()

func _load_item_icon() -> void:
	if not item_icon or item_data.is_empty():
		return

	var item_id = item_data.get("item_id", "")
	if item_id.is_empty():
		return

	# Get the actual ItemResource from ItemManager
	var item_manager = GameCore.get_system("item_manager")
	if not item_manager:
		_set_fallback_icon()
		return

	var item_resource = item_manager.get_item_resource(item_id)
	if not item_resource:
		_set_fallback_icon()
		return

	# Load the icon texture
	var icon_path = item_resource.icon_path
	if icon_path.is_empty():
		_set_fallback_icon()
		return

	# Load the texture
	if ResourceLoader.exists(icon_path):
		var texture = load(icon_path)
		if texture is Texture2D:
			item_icon.texture = texture
		else:
			_set_fallback_icon()
	else:
		_set_fallback_icon()

func _set_fallback_icon() -> void:
	# Create a simple colored texture as fallback
	if not item_icon:
		return

	# Try to determine item type for fallback color
	var item_id = item_data.get("item_id", "")
	var fallback_color = Color(0.5, 0.5, 0.5, 1)  # Default gray

	# Set colors based on item type
	if "egg" in item_id:
		fallback_color = Color(0.9, 0.8, 0.6, 1)  # Cream for eggs
	elif "food" in item_id or "grain" in item_id or "hay" in item_id:
		fallback_color = Color(0.6, 0.8, 0.4, 1)  # Green for food
	elif "potion" in item_id or "elixir" in item_id:
		fallback_color = Color(0.6, 0.4, 0.8, 1)  # Purple for potions

	# Create a simple texture
	var image = Image.create(80, 80, false, Image.FORMAT_RGBA8)
	image.fill(fallback_color)
	var texture = ImageTexture.new()
	texture.set_image(image)
	item_icon.texture = texture