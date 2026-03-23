extends Node

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 2


func save_game() -> void:
	var greenhouse_save := {}
	for key in GameState.greenhouse_slots:
		greenhouse_save[str(key)] = GameState.greenhouse_slots[key]

	var data := {
		"save_version": SAVE_VERSION,
		"current_day": GameState.current_day,
		"money": GameState.money,
		"reputation": GameState.reputation,
		"inventory": GameState.inventory.duplicate(),
		"seed_inventory": GameState.seed_inventory.duplicate(),
		"has_seen_tutorial": GameState.has_seen_tutorial,
		"unlocked_flowers": GameState.unlocked_flowers.duplicate(),
		"purchased_upgrades": GameState.purchased_upgrades.duplicate(),
		"relationship_points": GameState.relationship_points.duplicate(),
		"story_flags": GameState.story_flags.duplicate(),
		"unlocked_locations": GameState.unlocked_locations.duplicate(),
		"completed_order_ids": GameState.completed_order_ids.duplicate(),
		"greenhouse_slots": greenhouse_save,
		"journal_discovered_flowers": GameState.journal_discovered_flowers.duplicate(),
		"journal_delivery_count": GameState.journal_delivery_count.duplicate(),
		"total_deliveries": GameState.total_deliveries,
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

	var version = data.get("save_version", 1)

	GameState.current_day = data.get("current_day", 1)
	GameState.money = data.get("money", 0)
	GameState.reputation = data.get("reputation", 0)
	GameState.has_seen_tutorial = data.get("has_seen_tutorial", false)
	GameState.total_deliveries = data.get("total_deliveries", 0)

	GameState.inventory.clear()
	var inv = data.get("inventory", {})
	for key in inv:
		GameState.inventory[key] = inv[key]

	GameState.seed_inventory.clear()
	var seeds = data.get("seed_inventory", {})
	for key in seeds:
		GameState.seed_inventory[key] = seeds[key]

	GameState.unlocked_flowers.clear()
	var uf = data.get("unlocked_flowers", [])
	for f in uf:
		GameState.unlocked_flowers.append(f)

	GameState.purchased_upgrades.clear()
	var pu = data.get("purchased_upgrades", [])
	for u in pu:
		GameState.purchased_upgrades.append(u)

	GameState.relationship_points.clear()
	var rp = data.get("relationship_points", {})
	for key in rp:
		GameState.relationship_points[key] = rp[key]

	GameState.story_flags.clear()
	var sf = data.get("story_flags", {})
	for key in sf:
		GameState.story_flags[key] = sf[key]

	GameState.unlocked_locations.clear()
	var ul = data.get("unlocked_locations", ["flower_shop", "fox_house", "deer_house", "town_square", "player_home"])
	for l in ul:
		GameState.unlocked_locations.append(l)

	GameState.completed_order_ids.clear()
	var co = data.get("completed_order_ids", [])
	for o in co:
		GameState.completed_order_ids.append(o)

	GameState.greenhouse_slots.clear()
	var gs = data.get("greenhouse_slots", {})
	for key in gs:
		GameState.greenhouse_slots[int(key)] = gs[key]
	GreenhouseSystem.init_slots()

	GameState.journal_discovered_flowers.clear()
	var jdf = data.get("journal_discovered_flowers", [])
	for f in jdf:
		GameState.journal_discovered_flowers.append(f)

	GameState.journal_delivery_count.clear()
	var jdc = data.get("journal_delivery_count", {})
	for key in jdc:
		GameState.journal_delivery_count[key] = jdc[key]

	if version < 2 and GameState.unlocked_flowers.is_empty():
		ProgressionSystem.init_new_game()

	GameState.deliveries_completed_today = 0
	GameState.flowers_collected_today = 0
	GameState.current_order_id = ""
	GameState.current_delivery_target_id = ""
	GameState.current_bouquet_flower_ids.clear()
	GameState._money_at_day_start = GameState.money
	GameState._reputation_at_day_start = GameState.reputation

	GameState._generate_daily_orders()

	GameState.inventory_changed.emit()
	GameState.order_changed.emit()
	GameState.money_changed.emit()
	GameState.day_changed.emit()
	print("SaveManager: Game loaded from %s (v%d)" % [SAVE_PATH, version])
	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
		print("SaveManager: Save deleted")
