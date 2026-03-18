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
	_create_flowers()
	_create_customers()
	_create_locations()
	_create_orders()
	demo_order_queue = ["order_01_red_fox", "order_02_deer", "order_03_mentor"]
	demo_order_index = 0


func _create_flowers() -> void:
	var data := [
		["daisy_yellow", "Yellow Daisy", "Daisy", "Yellow", 10, "A cheerful yellow daisy."],
		["daisy_white", "White Daisy", "Daisy", "White", 10, "A soft white daisy."],
		["tulip_pink", "Pink Tulip", "Tulip", "Pink", 15, "A lovely pink tulip."],
		["wildflower_yellow", "Yellow Wildflower", "Wildflower", "Yellow", 8, "A wild yellow flower."],
	]
	for d in data:
		var f := FlowerData.new()
		f.id = d[0]
		f.display_name = d[1]
		f.flower_type = d[2]
		f.color_tag = d[3]
		f.base_value = d[4]
		f.description = d[5]
		flowers_db[f.id] = f


func _create_customers() -> void:
	var data := [
		["florist_mentor", "Florist Mentor", "Mentor", "town_square"],
		["red_fox", "Red Fox", "Customer", "fox_house"],
		["white_tailed_deer", "White-Tailed Deer", "Customer", "deer_house"],
	]
	for d in data:
		var c := CustomerData.new()
		c.id = d[0]
		c.display_name = d[1]
		c.role = d[2]
		c.default_location_id = d[3]
		customers_db[c.id] = c


func _create_locations() -> void:
	var data := [
		["flower_shop", "Flower Shop", Vector2(960, 600), "Your cozy flower shop."],
		["fox_house", "Fox House", Vector2(400, 300), "Red Fox's warm burrow."],
		["deer_house", "Deer House", Vector2(1500, 300), "White-Tailed Deer's clearing."],
		["town_square", "Town Square", Vector2(960, 350), "The bustling center of town."],
		["player_home", "Home", Vector2(960, 800), "Your cozy home."],
	]
	for d in data:
		var l := LocationData.new()
		l.id = d[0]
		l.display_name = d[1]
		l.world_position = d[2]
		l.description = d[3]
		locations_db[l.id] = l


func _create_orders() -> void:
	var req1a := OrderRequirementData.new()
	req1a.requirement_type = "ColorTag"
	req1a.target_value = "Yellow"
	req1a.amount = 1
	var req1b := OrderRequirementData.new()
	req1b.requirement_type = "FlowerType"
	req1b.target_value = "Daisy"
	req1b.amount = 1
	var o1 := OrderData.new()
	o1.id = "order_01_red_fox"
	o1.customer_id = "red_fox"
	o1.request_text = "I need a cheerful bouquet with at least one yellow flower and one daisy."
	o1.requirements = [req1a, req1b]
	o1.reward_money = 30
	o1.reward_reputation = 1
	o1.destination_location_id = "fox_house"
	orders_db[o1.id] = o1

	var req2a := OrderRequirementData.new()
	req2a.requirement_type = "ColorTag"
	req2a.target_value = "White"
	req2a.amount = 1
	var req2b := OrderRequirementData.new()
	req2b.requirement_type = "FlowerType"
	req2b.target_value = "Daisy"
	req2b.amount = 1
	var o2 := OrderData.new()
	o2.id = "order_02_deer"
	o2.customer_id = "white_tailed_deer"
	o2.request_text = "Could I have something soft and gentle? Please include at least one white flower and one daisy."
	o2.requirements = [req2a, req2b]
	o2.reward_money = 35
	o2.reward_reputation = 1
	o2.destination_location_id = "deer_house"
	orders_db[o2.id] = o2

	var req3a := OrderRequirementData.new()
	req3a.requirement_type = "ColorTag"
	req3a.target_value = "Pink"
	req3a.amount = 1
	var o3 := OrderData.new()
	o3.id = "order_03_mentor"
	o3.customer_id = "florist_mentor"
	o3.request_text = "Let us keep it simple today. I would like one pink flower."
	o3.requirements = [req3a]
	o3.reward_money = 20
	o3.reward_reputation = 1
	o3.destination_location_id = "town_square"
	orders_db[o3.id] = o3


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
