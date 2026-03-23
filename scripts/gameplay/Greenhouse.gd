extends Node2D

@onready var _inventory_label: Label = $CanvasLayer/UI/InventoryLabel
@onready var _money_label: Label = $CanvasLayer/UI/MoneyLabel
@onready var _go_to_shop_button: Button = $CanvasLayer/UI/GoToShopButton
@onready var _title_label: Label = $CanvasLayer/UI/TitleLabel


func _ready() -> void:
	_go_to_shop_button.pressed.connect(_on_go_to_shop)
	_go_to_shop_button.disabled = true
	GameState.inventory_changed.connect(_refresh_ui)
	for spot in $FlowerSpots.get_children():
		if spot.has_signal("flower_collected"):
			spot.flower_collected.connect(_on_flower_collected)
	_title_label.text = "Greenhouse - Day %d" % GameState.current_day
	_update_money_display()
	_refresh_ui()


func _on_flower_collected(_flower_id: String, _quantity: int) -> void:
	_refresh_ui()


func _refresh_ui() -> void:
	var inv := GameState.get_inventory_array()
	if inv.size() == 0:
		_inventory_label.text = "Inventory: (empty)\nClick flowers to collect them!"
	else:
		var text := "Inventory:\n"
		for item in inv:
			var flower = GameState.flowers_db.get(item.id)
			var name_str = flower.display_name if flower else item.id
			text += "  %s x%d\n" % [name_str, item.quantity]
		_inventory_label.text = text
	_go_to_shop_button.disabled = inv.size() == 0


func _update_money_display() -> void:
	_money_label.text = "Coins: %d" % GameState.money


func _on_go_to_shop() -> void:
	SceneRouter.go_to_shop_counter()
