class_name RelationshipSystem
extends RefCounted

const MAX_LEVEL := 5
const POINTS_PER_LEVEL := [0, 3, 8, 15, 25]


static func add_points(customer_id: String, points: int) -> void:
	if not GameState.relationship_points.has(customer_id):
		GameState.relationship_points[customer_id] = 0
	var old_level := get_level(customer_id)
	GameState.relationship_points[customer_id] += points
	var new_level := get_level(customer_id)
	if new_level > old_level:
		EventBus.relationship_advanced.emit(customer_id, new_level)


static func get_level(customer_id: String) -> int:
	var points = GameState.relationship_points.get(customer_id, 0)
	var level := 0
	for i in range(POINTS_PER_LEVEL.size()):
		if points >= POINTS_PER_LEVEL[i]:
			level = i + 1
	return mini(level, MAX_LEVEL)


static func get_points(customer_id: String) -> int:
	return GameState.relationship_points.get(customer_id, 0)


static func get_preference_bonus(customer_id: String, bouquet_flower_ids: Array) -> int:
	var prefs := _get_preferences(customer_id)
	if prefs.is_empty():
		return 0
	var bonus := 0
	for fid in bouquet_flower_ids:
		var flower = ContentDB.get_flower(fid)
		if flower and flower.color_tag in prefs:
			bonus += 2
		if flower and flower.flower_type in prefs:
			bonus += 1
	return bonus


static func _get_preferences(customer_id: String) -> Array:
	match customer_id:
		"florist_mentor":
			return ["White", "elegant", "classic", "Lily", "Rose"]
		"red_fox":
			return ["Red", "Yellow", "bright", "striking", "Rose"]
		"white_tailed_deer":
			return ["White", "Purple", "gentle", "Lavender", "Lily"]
		"rabbit":
			return ["Blue", "Pink", "delicate", "Bluebell"]
		"otter":
			return ["Yellow", "Orange", "lively", "Sunflower"]
		"bear":
			return ["Yellow", "Orange", "warm", "abundant", "Marigold", "Chrysanthemum"]
		"sparrow":
			return ["Red", "Pink", "bright", "festive", "Poppy"]
		_:
			return []
