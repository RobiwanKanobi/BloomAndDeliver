extends Node

const SAVE_PATH := "user://savegame.json"


func save_game() -> void:
	var data := {
		"current_day": GameState.current_day,
		"money": GameState.money,
		"reputation": GameState.reputation,
		"inventory": GameState.inventory.duplicate(),
		"has_seen_tutorial": GameState.has_seen_tutorial,
		"demo_order_index": GameState.demo_order_index,
	}
	var json_string := JSON.stringify(data, "\t")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("SaveManager: Game saved to %s" % SAVE_PATH)
	else:
		push_error("SaveManager: Failed to save game")


func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var json_string := file.get_as_text()
	file.close()
	var json := JSON.new()
	var result := json.parse(json_string)
	if result != OK:
		push_error("SaveManager: Failed to parse save file")
		return false
	var data: Dictionary = json.data
	GameState.current_day = data.get("current_day", 1)
	GameState.money = data.get("money", 0)
	GameState.reputation = data.get("reputation", 0)
	GameState.has_seen_tutorial = data.get("has_seen_tutorial", false)
	GameState.demo_order_index = data.get("demo_order_index", 0)
	GameState.inventory.clear()
	var inv = data.get("inventory", {})
	for key in inv:
		GameState.inventory[key] = inv[key]
	GameState.deliveries_completed_today = 0
	GameState.flowers_collected_today = 0
	GameState.current_order_id = ""
	GameState.current_delivery_target_id = ""
	GameState.current_bouquet_flower_ids.clear()
	GameState._money_at_day_start = GameState.money
	GameState._reputation_at_day_start = GameState.reputation
	GameState.inventory_changed.emit()
	GameState.order_changed.emit()
	GameState.money_changed.emit()
	GameState.day_changed.emit()
	print("SaveManager: Game loaded from %s" % SAVE_PATH)
	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
		print("SaveManager: Save deleted")
