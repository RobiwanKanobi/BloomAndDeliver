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

var flowers_db: Dictionary = {}
var customers_db: Dictionary = {}
var orders_db: Dictionary = {}
var locations_db: Dictionary = {}

var demo_order_queue: Array[String] = []
var demo_order_index: int = 0


func _ready() -> void:
	_load_databases()


func _load_databases() -> void:
	var flower_ids := ["daisy_yellow", "daisy_white", "tulip_pink", "wildflower_yellow"]
	for fid in flower_ids:
		var res = load("res://resources/flowers/%s.tres" % fid)
		if res:
			flowers_db[fid] = res

	var customer_ids := ["florist_mentor", "red_fox", "white_tailed_deer"]
	for cid in customer_ids:
		var res = load("res://resources/customers/%s.tres" % cid)
		if res:
			customers_db[cid] = res

	var order_ids := ["order_01_red_fox", "order_02_deer", "order_03_mentor"]
	for oid in order_ids:
		var res = load("res://resources/orders/%s.tres" % oid)
		if res:
			orders_db[oid] = res

	var location_ids := ["flower_shop", "fox_house", "deer_house", "town_square", "player_home"]
	for lid in location_ids:
		var res = load("res://resources/locations/%s.tres" % lid)
		if res:
			locations_db[lid] = res

	demo_order_queue = order_ids.duplicate()
	demo_order_index = 0


func reset_for_new_game() -> void:
	current_day = 1
	money = 0
	reputation = 0
	inventory.clear()
	current_order_id = ""
	current_delivery_target_id = ""
	current_bouquet_flower_ids.clear()
	deliveries_completed_today = 0
	flowers_collected_today = 0
	has_seen_tutorial = false
	demo_order_index = 0
	_money_at_day_start = 0
	_reputation_at_day_start = 0
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
	inventory_changed.emit()
	order_changed.emit()
	day_changed.emit()


func add_flower(flower_id: String, quantity: int) -> void:
	if inventory.has(flower_id):
		inventory[flower_id] += quantity
	else:
		inventory[flower_id] = quantity
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


func get_next_demo_order_id() -> String:
	if demo_order_index >= demo_order_queue.size():
		demo_order_index = 0
	var oid = demo_order_queue[demo_order_index]
	demo_order_index += 1
	return oid


func get_daily_summary() -> Dictionary:
	return {
		"money_earned": money - _money_at_day_start,
		"deliveries_completed": deliveries_completed_today,
		"flowers_collected": flowers_collected_today,
		"reputation_gained": reputation - _reputation_at_day_start,
		"total_money": money,
		"total_reputation": reputation,
		"day": current_day,
	}
