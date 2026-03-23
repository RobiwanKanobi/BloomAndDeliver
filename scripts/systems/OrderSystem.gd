class_name OrderSystem
extends RefCounted


static func generate_daily_orders(day: int, reputation: int) -> Array[OrderData]:
	var phase := _get_phase(day)
	var count := _get_order_count(day)
	var orders: Array[OrderData] = []
	var used_templates: Array[String] = []

	for _i in range(count):
		var tmpl := _pick_template(phase, reputation, used_templates)
		if tmpl == null:
			continue
		used_templates.append(tmpl.id)
		var order := _instantiate(tmpl)
		orders.append(order)
	return orders


static func _get_phase(day: int) -> int:
	if day <= 8:
		return 1
	elif day <= 16:
		return 2
	else:
		return 3


static func _get_order_count(day: int) -> int:
	if day <= 3:
		return 1
	elif day <= 8:
		return 2
	elif day <= 16:
		return 2
	else:
		return 3


static func _pick_template(phase: int, reputation: int, exclude: Array) -> OrderTemplateData:
	var candidates: Array = []
	for tmpl in ContentDB.order_templates.values():
		if tmpl.id in exclude:
			continue
		if phase not in tmpl.allowed_phases:
			continue
		if reputation < tmpl.min_reputation:
			continue
		if tmpl.request_type == "story":
			continue
		candidates.append(tmpl)
	if candidates.is_empty():
		return null
	return candidates[randi() % candidates.size()]


static func _instantiate(tmpl: OrderTemplateData) -> OrderData:
	var o := OrderData.new()
	o.id = "order_%d_%s" % [randi() % 99999, tmpl.id]
	o.requirements = tmpl.requirements.duplicate()
	o.reward_money = randi_range(tmpl.reward_money_min, tmpl.reward_money_max)
	o.reward_reputation = tmpl.reward_reputation

	if tmpl.preferred_customer_ids.size() > 0:
		o.customer_id = tmpl.preferred_customer_ids[randi() % tmpl.preferred_customer_ids.size()]
	else:
		var all_custs = ContentDB.customers.keys()
		o.customer_id = all_custs[randi() % all_custs.size()]

	if tmpl.destination_pool.size() > 0:
		o.destination_location_id = tmpl.destination_pool[randi() % tmpl.destination_pool.size()]
	else:
		var cust = ContentDB.get_customer(o.customer_id)
		o.destination_location_id = cust.default_location_id if cust else "town_square"

	if not GameState.is_location_unlocked(o.destination_location_id):
		o.destination_location_id = "town_square"

	if tmpl.request_texts.size() > 0:
		o.request_text = tmpl.request_texts[randi() % tmpl.request_texts.size()]
	else:
		o.request_text = "I need a bouquet."

	return o


static func get_available_story_orders(day: int, reputation: int, story_flags: Dictionary) -> Array[OrderTemplateData]:
	var phase := _get_phase(day)
	var result: Array[OrderTemplateData] = []
	for tmpl in ContentDB.order_templates.values():
		if tmpl.request_type != "story":
			continue
		if phase not in tmpl.allowed_phases:
			continue
		if reputation < tmpl.min_reputation:
			continue
		if story_flags.has("completed_" + tmpl.id):
			continue
		result.append(tmpl)
	return result
