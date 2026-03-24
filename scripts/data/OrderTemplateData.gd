class_name OrderTemplateData
extends Resource

@export var id: String = ""
@export var request_type: String = "routine"  # "routine", "special", "story"
@export var allowed_phases: Array[int] = [1, 2, 3]
@export var requirements: Array[OrderRequirementData] = []
@export var reward_money_min: int = 0
@export var reward_money_max: int = 0
@export var reward_reputation: int = 1
@export var preferred_customer_ids: Array[String] = []
@export var destination_pool: Array[String] = []
@export var request_texts: Array[String] = []
@export var min_reputation: int = 0
