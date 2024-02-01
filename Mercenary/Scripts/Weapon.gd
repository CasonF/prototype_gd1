class_name Weapon
extends Node

@export var weapon_res : WeaponTemplate
# For MVP we should not worry to much about displaying the sprite of the weapon, except maybe in inventory
@onready var sprite := $Sprite2D

var current_durability : int

func _ready() -> void:
	if weapon_res:
		set_weapon_sprite()
	
	if !current_durability:
		current_durability = get_durability()

func set_weapon_sprite() -> void:
	if weapon_res.weapon_sprite:
		sprite.texture = weapon_res.weapon_sprite
	else:
		print_debug("No Sprite2D set for the weapon %d", weapon_res.name)


func get_base_damage() -> int:
	if weapon_res:
		return weapon_res.base_damage
	else:
		# In theory, this should not happen...
		print_debug("Weapon Resource not found.")
		return 0
	
func get_crit_chance() -> float:
	if weapon_res:
		return weapon_res.crit_hit_chance
	else:
		print_debug("Weapon Resource not found.")
		return 0.0
	
func get_crit_mult() -> float:
	if weapon_res:
		return weapon_res.crit_damage_mult
	else:
		print_debug("Weapon Resource not found.")
		return 0.0
	
func get_durability() -> int:
	if weapon_res:
		return weapon_res.max_durability
	else:
		print_debug("Weapon Resource not found.")
		return 0
	
func update_durability(value : int = -1):
	current_durability += value
