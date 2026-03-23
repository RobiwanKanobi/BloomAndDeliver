extends Node

signal inventory_changed
signal order_changed
signal delivery_target_changed
signal money_changed
signal day_changed

var current_day: int = 1
var money: int = 0
var reputation: int = 0
var inventory: Dictionary = {}
var current_order_id: String = ""
var current_delivery_target_id: String = ""
var current_bouquet_flower_ids: Array[String] = []
var deliveries_completed_today: int = 0
var flowers_collected_today: int = 0
var has_seen_tutorial: bool = false

var _money_at_day_start: int = 0
var _reputation_at_day_start: int = 0

# Full game state
var seed_inventory: Dictionary = {}
var greenhouse_slots: Dictionary = {}
var unlocked_flowers: Array[String] = []
var purchased_upgrades: Array[String] = []
var relationship_points: Dictionary = {}
var story_flags: Dictionary = {}
var unlocked_locations: Array[String] = []
var daily_orders: Array[OrderData] = []
var completed_order_ids: Array[String] = []
var journal_discovered_flowers: Array[String] = []
var journal_delivery_count: Dictionary = {}
var total_deliveries: int = 0

# Backward compat: expose data through ContentDB
var flowers_db: Dictionary:
	get: return ContentDB.flowers
var customers_db: Dictionary:
	get: return ContentDB.customers
var locations_db: Dictionary:
	get: return ContentDB.locations
var orders_db: Dictionary = {}


func _ready() -> void:
	pass


func reset_for_new_game() -> void:
	current_day = 1
	money = 15
	reputation = 0
	inventory.clear()
	current_order_id = ""
	current_delivery_target_id = ""
	current_bouquet_flower_ids.clear()
	deliveries_completed_today = 0
	flowers_collected_today = 0
	has_seen_tutorial = false
	_money_at_day_start = 15
	_reputation_at_day_start = 0

	seed_inventory.clear()
	greenhouse_slots.clear()
	unlocked_flowers.clear()
	purchased_upgrades.clear()
	relationship_points.clear()
	story_flags.clear()
	unlocked_locations.clear()
	daily_orders.clear()
	completed_order_ids.clear()
	orders_db.clear()
	journal_discovered_flowers.clear()
	journal_delivery_count.clear()
	total_deliveries = 0

	ProgressionSystem.init_new_game()
	GreenhouseSystem.init_slots()
	unlocked_locations = ["flower_shop", "fox_house", "deer_house", "town_square", "player_home"]

	_generate_daily_orders()

	inventory_changed.emit()
	order_changed.emit()
	money_changed.emit()
	day_changed.emit()


func reset_for_new_day() -> void:
	deliveries_completed_today = 0
	flowers_collected_today = 0
	current_order_id = ""
	current_delivery_target_id = ""
	current_bouquet_flower_ids.clear()
	_money_at_day_start = money
	_reputation_at_day_start = reputation
	current_day += 1

	GreenhouseSystem.advance_day()
	ProgressionSystem.check_unlocks(current_day, reputation)
	_generate_daily_orders()

	EventBus.day_started.emit(current_day)
	inventory_changed.emit()
	order_changed.emit()
	day_changed.emit()


func _generate_daily_orders() -> void:
	daily_orders.clear()
	orders_db.clear()
	var new_orders = OrderSystem.generate_daily_orders(current_day, reputation)
	for o in new_orders:
		daily_orders.append(o)
		orders_db[o.id] = o

	var story_orders = OrderSystem.get_available_story_orders(current_day, reputation, story_flags)
	for tmpl in story_orders:
		var so = OrderSystem._instantiate(tmpl)
		daily_orders.append(so)
		orders_db[so.id] = so


func add_flower(flower_id: String, quantity: int) -> void:
	if inventory.has(flower_id):
		inventory[flower_id] += quantity
	else:
		inventory[flower_id] = quantity
	JournalSystem.discover_flower(flower_id)
	inventory_changed.emit()


func remove_flower(flower_id: String, quantity: int) -> bool:
	if not inventory.has(flower_id):
		return false
	if inventory[flower_id] < quantity:
		return false
	inventory[flower_id] -= quantity
	if inventory[flower_id] <= 0:
		inventory.erase(flower_id)
	inventory_changed.emit()
	return true


func get_flower_quantity(flower_id: String) -> int:
	if inventory.has(flower_id):
		return inventory[flower_id]
	return 0


func get_inventory_array() -> Array:
	var result := []
	for flower_id in inventory:
		if inventory[flower_id] > 0:
			result.append({"id": flower_id, "quantity": inventory[flower_id]})
	return result


func set_current_order(order_id: String) -> void:
	current_order_id = order_id
	if orders_db.has(order_id):
		var order = orders_db[order_id]
		current_delivery_target_id = order.destination_location_id
	order_changed.emit()


func clear_current_order() -> void:
	current_order_id = ""
	order_changed.emit()


func set_delivery_target(location_id: String) -> void:
	current_delivery_target_id = location_id
	delivery_target_changed.emit()


func clear_delivery_target() -> void:
	current_delivery_target_id = ""
	delivery_target_changed.emit()


func clear_current_bouquet() -> void:
	current_bouquet_flower_ids.clear()


func get_next_order() -> OrderData:
	for o in daily_orders:
		if o.id not in completed_order_ids and o.id != current_order_id:
			return o
	return null


func complete_order(order_id: String) -> void:
	completed_order_ids.append(order_id)
	total_deliveries += 1


func is_location_unlocked(location_id: String) -> bool:
	return location_id in unlocked_locations


func unlock_location(location_id: String) -> void:
	if location_id not in unlocked_locations:
		unlocked_locations.append(location_id)
		EventBus.location_unlocked.emit(location_id)


func get_max_bouquet_slots() -> int:
	var base := 5
	for uid in purchased_upgrades:
		var u = ContentDB.get_upgrade(uid)
		if u and u.effect_type == "bouquet_slots":
			base += u.effect_value
	return base


func get_game_phase() -> int:
	return ProgressionSystem.get_phase(current_day)


func is_game_complete() -> bool:
	return story_flags.has("final_event_unlocked") and story_flags.has("final_celebration_done")


func get_daily_summary() -> Dictionary:
	return {
		"money_earned": money - _money_at_day_start,
		"deliveries_completed": deliveries_completed_today,
		"flowers_collected": flowers_collected_today,
		"reputation_gained": reputation - _reputation_at_day_start,
		"total_money": money,
		"total_reputation": reputation,
		"day": current_day,
		"phase": get_game_phase(),
		"total_deliveries": total_deliveries,
	}
