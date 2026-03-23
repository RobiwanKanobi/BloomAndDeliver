class_name UpgradeData
extends Resource

@export var id: String = ""
@export var category: String = ""  # "greenhouse", "shop", "travel"
@export var display_name: String = ""
@export var description: String = ""
@export var cost_money: int = 0
@export var cost_reputation: int = 0
@export var prerequisites: Array[String] = []
@export var effect_type: String = ""  # "greenhouse_slots", "bouquet_slots", "unlock_location", etc.
@export var effect_value: int = 0
