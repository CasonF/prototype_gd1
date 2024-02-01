class_name StatsTemplate
extends Resource

@export_category("Constitution")
@export var constitution: int = 10
@export var con_bonus: int = 0
@export_enum("Very Slow", "Slow", "Normal", "Fast", "Very Fast", "Sporadic") var con_growth: String = "Normal"

@export_category("Dexterity")
@export var dexterity: int = 10
@export var dex_bonus: int = 0
@export_enum("Very Slow", "Slow", "Normal", "Fast", "Very Fast", "Sporadic") var dex_growth: String = "Normal"

@export_category("Strength")
@export var strength: int = 10
@export var str_bonus: int = 0
@export_enum("Very Slow", "Slow", "Normal", "Fast", "Very Fast", "Sporadic") var str_growth: String = "Normal"

@export_category("Intelligence")
@export var intelligence: int = 10
@export var int_bonus: int = 0
@export_enum("Very Slow", "Slow", "Normal", "Fast", "Very Fast", "Sporadic") var int_growth: String = "Normal"

@export_category("Wisdom")
@export var wisdom: int = 10
@export var wis_bonus: int = 0
@export_enum("Very Slow", "Slow", "Normal", "Fast", "Very Fast", "Sporadic") var wis_growth: String = "Normal"

@export_category("Charisma")
@export var charisma: int = 10
@export var cha_bonus: int = 0
@export_enum("Very Slow", "Slow", "Normal", "Fast", "Very Fast", "Sporadic") var cha_growth: String = "Normal"
