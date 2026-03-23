extends Node

signal order_completed(order_id: String, customer_id: String)
signal delivery_completed(location_id: String, reward_money: int)
signal relationship_advanced(customer_id: String, new_level: int)
signal upgrade_purchased(upgrade_id: String)
signal journal_entry_unlocked(entry_id: String)
signal flower_unlocked(flower_id: String)
signal location_unlocked(location_id: String)
signal day_started(day: int)
signal day_ended(day: int)
signal story_flag_set(flag: String)
signal game_phase_changed(phase: int)
signal dialogue_requested(event_id: String)
signal final_event_triggered
