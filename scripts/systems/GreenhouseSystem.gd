class_name GreenhouseSystem
extends RefCounted

const BASE_SLOTS := 4
const GROWTH_DAYS := 3

static func get_total_slots() -> int:
	var bonus := 0
	for uid in GameState.purchased_upgrades:
		var u = ContentDB.get_upgrade(uid)
		if u and u.effect_type == "greenhouse_slots":
			bonus += u.effect_value
	return BASE_SLOTS + bonus


static func get_growth_speed_bonus() -> int:
	var bonus := 0
	for uid in GameState.purchased_upgrades:
		var u = ContentDB.get_upgrade(uid)
		if u and u.effect_type == "growth_speed":
			bonus += u.effect_value
	return bonus


static func get_harvest_yield_bonus() -> int:
	var bonus := 0
	for uid in GameState.purchased_upgrades:
		var u = ContentDB.get_upgrade(uid)
		if u and u.effect_type == "harvest_yield":
			bonus += u.effect_value
	return bonus


static func plant_seed(slot_index: int, flower_id: String) -> bool:
	if slot_index >= get_total_slots():
		return false
	if not GameState.seed_inventory.has(flower_id) or GameState.seed_inventory[flower_id] <= 0:
		return false
	GameState.seed_inventory[flower_id] -= 1
	if GameState.seed_inventory[flower_id] <= 0:
		GameState.seed_inventory.erase(flower_id)
	var days_needed = max(1, GROWTH_DAYS - get_growth_speed_bonus())
	GameState.greenhouse_slots[slot_index] = {
		"flower_id": flower_id,
		"state": "planted",
		"days_remaining": days_needed,
	}
	return true


static func advance_day() -> void:
	for i in GameState.greenhouse_slots:
		var slot = GameState.greenhouse_slots[i]
		if slot.state == "planted" or slot.state == "budding":
			slot.days_remaining -= 1
			if slot.days_remaining <= 1 and slot.state == "planted":
				slot.state = "budding"
			if slot.days_remaining <= 0:
				slot.state = "ready"


static func harvest_slot(slot_index: int) -> Dictionary:
	if not GameState.greenhouse_slots.has(slot_index):
		return {}
	var slot = GameState.greenhouse_slots[slot_index]
	if slot.state != "ready":
		return {}
	var flower_id = slot.flower_id
	var qty = 1 + get_harvest_yield_bonus()
	GameState.add_flower(flower_id, qty)
	GameState.flowers_collected_today += qty
	GameState.greenhouse_slots[slot_index] = {"flower_id": "", "state": "empty", "days_remaining": 0}
	return {"flower_id": flower_id, "quantity": qty}


static func init_slots() -> void:
	var total = get_total_slots()
	for i in range(total):
		if not GameState.greenhouse_slots.has(i):
			GameState.greenhouse_slots[i] = {"flower_id": "", "state": "empty", "days_remaining": 0}
