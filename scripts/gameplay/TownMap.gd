extends Node2D

@onready var _player_marker: Sprite2D = $PlayerMarker
@onready var _destination_label: Label = $CanvasLayer/UI/DestinationLabel
@onready var _status_label: Label = $CanvasLayer/UI/StatusLabel
@onready var _bed_hub_button: Button = $CanvasLayer/UI/BedHubButton
@onready var _locations_node: Node2D = $Locations

var _delivery_completed: bool = false
var _location_nodes: Dictionary = {}


func _ready() -> void:
	_bed_hub_button.visible = false
	_bed_hub_button.pressed.connect(_on_go_to_bed_hub)
	_create_player_marker_visual()
	_setup_locations()
	_update_destination_display()
	_player_marker.position = Vector2(1000, 640)


func _create_player_marker_visual() -> void:
	var marker_rect := ColorRect.new()
	marker_rect.color = Color(1.0, 0.4, 0.2, 1.0)
	marker_rect.size = Vector2(30, 30)
	marker_rect.position = Vector2(-15, -15)
	_player_marker.add_child(marker_rect)
	var marker_label := Label.new()
	marker_label.text = "YOU"
	marker_label.position = Vector2(-20, -35)
	marker_label.add_theme_font_size_override("font_size", 14)
	_player_marker.add_child(marker_label)


func _setup_locations() -> void:
	for loc_node in _locations_node.get_children():
		var location_id: String = loc_node.get_meta("location_id", "")
		if location_id == "":
			continue
		_location_nodes[location_id] = loc_node
		var btn: Button = loc_node.get_node_or_null("ClickButton")
		if btn:
			var lid = location_id
			btn.pressed.connect(func(): _on_location_button_pressed(lid))
		var is_target = (location_id == GameState.current_delivery_target_id)
		_style_location_node(loc_node, location_id, is_target)


func _style_location_node(loc_node: Node2D, location_id: String, is_target: bool) -> void:
	var btn = loc_node.get_node_or_null("ClickButton")
	if btn:
		var loc = GameState.locations_db.get(location_id)
		var name_text = loc.display_name if loc else location_id
		if is_target:
			btn.text = name_text + "\n[DELIVER HERE]"
			btn.modulate = Color(0.3, 1.0, 0.4, 1.0)
		else:
			btn.text = name_text
			btn.modulate = Color(0.7, 0.7, 0.9, 1.0)


func _on_location_button_pressed(location_id: String) -> void:
	if _delivery_completed:
		return
	_move_to_location(location_id)


func _move_to_location(location_id: String) -> void:
	var loc = GameState.locations_db.get(location_id)
	if not loc:
		return
	var target_pos: Vector2 = loc.world_position
	var loc_node = _location_nodes.get(location_id)
	if loc_node:
		target_pos = loc_node.position + Vector2(40, 40)
	var tween = create_tween()
	tween.tween_property(_player_marker, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE)
	await tween.finished
	if location_id == GameState.current_delivery_target_id:
		_complete_delivery()


func _complete_delivery() -> void:
	_delivery_completed = true
	var order = GameState.orders_db.get(GameState.current_order_id)
	if order:
		GameState.money += order.reward_money
		GameState.reputation += order.reward_reputation
		GameState.money_changed.emit()
	GameState.deliveries_completed_today += 1
	GameState.clear_current_order()
	GameState.clear_current_bouquet()
	GameState.clear_delivery_target()
	_status_label.text = "Delivery complete! Great job!"
	_destination_label.text = ""
	_bed_hub_button.visible = true
	for lid in _location_nodes:
		_style_location_node(_location_nodes[lid], lid, false)


func _update_destination_display() -> void:
	if GameState.current_delivery_target_id != "":
		var loc = GameState.locations_db.get(GameState.current_delivery_target_id)
		var dest_name = loc.display_name if loc else GameState.current_delivery_target_id
		_destination_label.text = "Deliver to: %s" % dest_name
		_status_label.text = "Click the highlighted location to deliver."
	else:
		_destination_label.text = "No active delivery."
		_status_label.text = ""


func _on_go_to_bed_hub() -> void:
	SceneRouter.go_to_bed_hub()
