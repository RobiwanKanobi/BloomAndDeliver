extends Node

const SCENES := {
	"main_menu": "res://scenes/menus/MainMenu.tscn",
	"greenhouse": "res://scenes/greenhouse/Greenhouse.tscn",
	"shop_counter": "res://scenes/shop_counter/ShopCounter.tscn",
	"town_map": "res://scenes/town_map/TownMap.tscn",
	"bed_hub": "res://scenes/bed_hub/BedHub.tscn",
}

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _is_transitioning: bool = false


func _ready() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color.BLACK
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.modulate.a = 0.0
	_fade_layer.add_child(_fade_rect)


func go_to_main_menu() -> void:
	_change_scene("main_menu")


func go_to_greenhouse() -> void:
	_change_scene("greenhouse")


func go_to_shop_counter() -> void:
	_change_scene("shop_counter")


func go_to_town_map() -> void:
	_change_scene("town_map")


func go_to_bed_hub() -> void:
	_change_scene("bed_hub")


func _change_scene(scene_key: String) -> void:
	if _is_transitioning:
		return
	if not SCENES.has(scene_key):
		push_error("SceneRouter: Unknown scene key: %s" % scene_key)
		return
	_is_transitioning = true
	await _fade_out()
	get_tree().change_scene_to_file(SCENES[scene_key])
	await get_tree().process_frame
	await _fade_in()
	_is_transitioning = false


func _fade_out(duration: float = 0.3) -> void:
	var tween = create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 1.0, duration)
	await tween.finished


func _fade_in(duration: float = 0.3) -> void:
	var tween = create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 0.0, duration)
	await tween.finished
