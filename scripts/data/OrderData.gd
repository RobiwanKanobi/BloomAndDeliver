class_name OrderData
extends Resource

@export var id: String = ""
@export var customer_id: String = ""
@export var request_text: String = ""
@export var requirements: Array[OrderRequirementData] = []
@export var reward_money: int = 0
@export var reward_reputation: int = 0
@export var destination_location_id: String = ""
