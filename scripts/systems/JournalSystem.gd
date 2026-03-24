class_name JournalSystem
extends RefCounted


static func discover_flower(flower_id: String) -> void:
	if flower_id not in GameState.journal_discovered_flowers:
		GameState.journal_discovered_flowers.append(flower_id)
		EventBus.journal_entry_unlocked.emit("flower_" + flower_id)


static func record_delivery(customer_id: String, _order_id: String) -> void:
	if not GameState.journal_delivery_count.has(customer_id):
		GameState.journal_delivery_count[customer_id] = 0
	GameState.journal_delivery_count[customer_id] += 1


static func get_flower_discoveries() -> Array:
	var result := []
	for fid in GameState.journal_discovered_flowers:
		var flower = ContentDB.get_flower(fid)
		if flower:
			result.append(flower)
	return result


static func get_delivery_stats() -> Dictionary:
	return GameState.journal_delivery_count.duplicate()


static func get_total_deliveries() -> int:
	var total := 0
	for v in GameState.journal_delivery_count.values():
		total += v
	return total
