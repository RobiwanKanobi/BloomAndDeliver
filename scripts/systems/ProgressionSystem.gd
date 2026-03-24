class_name ProgressionSystem
extends RefCounted

const STARTER_FLOWERS := ["daisy_yellow", "daisy_white", "tulip_pink", "wildflower_yellow"]
const PHASE_2_FLOWERS := ["rose_red", "rose_white", "lavender_purple", "sunflower_yellow", "poppy_red", "carnation_pink"]
const PHASE_3_FLOWERS := ["lily_white", "bluebell_blue", "peony_pink", "marigold_orange", "chrysanthemum_yellow", "clover_green"]

const STARTER_SEEDS := {"daisy_yellow": 4, "daisy_white": 2, "tulip_pink": 2, "wildflower_yellow": 3}


static func get_phase(day: int) -> int:
	if day <= 8:
		return 1
	elif day <= 16:
		return 2
	else:
		return 3


static func get_flowers_for_phase(phase: int) -> Array:
	var result := STARTER_FLOWERS.duplicate()
	if phase >= 2:
		result.append_array(PHASE_2_FLOWERS)
	if phase >= 3:
		result.append_array(PHASE_3_FLOWERS)
	return result


static func check_unlocks(day: int, reputation: int) -> void:
	var phase = get_phase(day)
	var available = get_flowers_for_phase(phase)
	for fid in available:
		if fid not in GameState.unlocked_flowers:
			GameState.unlocked_flowers.append(fid)
			EventBus.flower_unlocked.emit(fid)


static func init_new_game() -> void:
	GameState.unlocked_flowers.clear()
	for f in STARTER_FLOWERS:
		GameState.unlocked_flowers.append(f)
	GameState.seed_inventory = STARTER_SEEDS.duplicate()
	GameState.add_flower("daisy_yellow", 2)
	GameState.add_flower("wildflower_yellow", 1)


static func get_seed_shop_offerings() -> Array:
	var result := []
	for fid in GameState.unlocked_flowers:
		var flower = ContentDB.get_flower(fid)
		if flower:
			result.append({
				"flower_id": fid,
				"display_name": flower.display_name,
				"cost": _seed_cost(flower),
			})
	return result


static func _seed_cost(flower: FlowerData) -> int:
	return max(3, flower.base_value / 2)


static func buy_seed(flower_id: String) -> bool:
	var flower = ContentDB.get_flower(flower_id)
	if flower == null:
		return false
	var cost = _seed_cost(flower)
	if GameState.money < cost:
		return false
	GameState.money -= cost
	if GameState.seed_inventory.has(flower_id):
		GameState.seed_inventory[flower_id] += 1
	else:
		GameState.seed_inventory[flower_id] = 1
	GameState.money_changed.emit()
	return true
