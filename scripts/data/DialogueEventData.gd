class_name DialogueEventData
extends Resource

@export var id: String = ""
@export var trigger_type: String = ""  # "relationship_level", "day", "order_complete", "story_flag"
@export var trigger_value: String = ""
@export var speaker_id: String = ""
@export var lines: Array[String] = []
@export var unlock_reward_type: String = ""  # "", "seed", "upgrade", "journal"
@export var unlock_reward_id: String = ""
@export var set_story_flag: String = ""
