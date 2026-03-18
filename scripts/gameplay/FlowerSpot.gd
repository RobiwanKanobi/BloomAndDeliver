extends Area2D

signal flower_collected(flower_id: String, quantity: int)

@export var flower_id: String = ""
@export var quantity: int = 1

var is_collected: bool = false

@onready var _label: Label = $Label
@onready var _color_rect: ColorRect = $ColorRect


func _ready() -> void:
	if _label and flower_id != "":
		var flower = GameState.flowers_db.get(flower_id)
		if flower:
			_label.text = "%s x%d" % [flower.display_name, quantity]
		else:
			_label.text = "%s x%d" % [flower_id, quantity]
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_collected:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		collect()


func _on_mouse_entered() -> void:
	if not is_collected and _color_rect:
		_color_rect.color = _color_rect.color.lightened(0.2)


func _on_mouse_exited() -> void:
	if not is_collected:
		_refresh_color()


func collect() -> void:
	if is_collected:
		return
	is_collected = true
	GameState.add_flower(flower_id, quantity)
	GameState.flowers_collected_today += 1
	flower_collected.emit(flower_id, quantity)
	if _color_rect:
		_color_rect.modulate.a = 0.3
	if _label:
		_label.text = "(collected)"


func _refresh_color() -> void:
	if not _color_rect:
		return
	var flower = GameState.flowers_db.get(flower_id)
	if flower:
		match flower.color_tag:
			"Yellow":
				_color_rect.color = Color(1.0, 0.9, 0.3)
			"White":
				_color_rect.color = Color(0.95, 0.95, 0.95)
			"Pink":
				_color_rect.color = Color(1.0, 0.6, 0.7)
			_:
				_color_rect.color = Color(0.7, 0.9, 0.5)


func reset_spot() -> void:
	is_collected = false
	if _color_rect:
		_color_rect.modulate.a = 1.0
	_refresh_color()
	if _label and flower_id != "":
		var flower = GameState.flowers_db.get(flower_id)
		if flower:
			_label.text = "%s x%d" % [flower.display_name, quantity]
