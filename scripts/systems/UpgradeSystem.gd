class_name UpgradeSystem
extends RefCounted


static func can_purchase(upgrade_id: String) -> bool:
	if upgrade_id in GameState.purchased_upgrades:
		return false
	var u = ContentDB.get_upgrade(upgrade_id)
	if u == null:
		return false
	if GameState.money < u.cost_money:
		return false
	if GameState.reputation < u.cost_reputation:
		return false
	for prereq in u.prerequisites:
		if prereq not in GameState.purchased_upgrades:
			return false
	return true


static func purchase(upgrade_id: String) -> bool:
	if not can_purchase(upgrade_id):
		return false
	var u = ContentDB.get_upgrade(upgrade_id)
	GameState.money -= u.cost_money
	GameState.purchased_upgrades.append(upgrade_id)
	_apply_effect(u)
	GameState.money_changed.emit()
	EventBus.upgrade_purchased.emit(upgrade_id)
	return true


static func _apply_effect(u: UpgradeData) -> void:
	match u.effect_type:
		"unlock_location":
			GameState.unlock_location(u.id.replace("unlock_", ""))
		"greenhouse_slots":
			GreenhouseSystem.init_slots()


static func get_available_upgrades() -> Array:
	var result := []
	for u in ContentDB.upgrades.values():
		if u.id not in GameState.purchased_upgrades:
			result.append(u)
	return result
