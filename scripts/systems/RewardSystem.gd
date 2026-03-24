class_name RewardSystem
extends RefCounted


static func calculate_delivery_reward(order: OrderData, bouquet_ids: Array) -> Dictionary:
	var base_money := order.reward_money
	var base_rep := order.reward_reputation

	var pref_bonus := RelationshipSystem.get_preference_bonus(order.customer_id, bouquet_ids)
	var variety_bonus := _variety_bonus(bouquet_ids)

	var total_money := base_money + pref_bonus + variety_bonus
	var total_rep := base_rep

	return {
		"money": total_money,
		"reputation": total_rep,
		"base_money": base_money,
		"preference_bonus": pref_bonus,
		"variety_bonus": variety_bonus,
	}


static func _variety_bonus(bouquet_ids: Array) -> int:
	var unique_types := {}
	for fid in bouquet_ids:
		var flower = ContentDB.get_flower(fid)
		if flower:
			unique_types[flower.flower_type] = true
	if unique_types.size() >= 3:
		return 10
	elif unique_types.size() >= 2:
		return 3
	return 0
