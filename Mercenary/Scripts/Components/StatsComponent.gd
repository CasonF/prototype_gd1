class_name StatsComponent
extends Node

@export var stats: StatsTemplate

@export var level: int = 1

@export_category("HP/AC")
@export var max_hp: int = 10
@export var current_hp: int
@export var base_ac: int = 10 #Natural Armor
@export var current_ac: int

func _init() -> void:
	max_hp = stats.constitution + level + (stats.con_bonus * level)
	current_hp = max_hp
	base_ac = stats.dexterity + stats.dex_bonus
	current_ac = base_ac
