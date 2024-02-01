class_name HealthComponent
extends Node

@export var max_hp : int = 15
var current_hp : int

## Only use this component if the unit does not have stats but you want it
## to be able to be killed/destroyed in combat, like a trap or statue.
func take_damage(damage: int) -> void:
	if damage > current_hp:
		current_hp = 0
	else:
		current_hp -= damage

func heal_hp(heal: int) -> void:
	if (current_hp + heal) > max_hp:
		current_hp = max_hp
	else:
		current_hp += heal

func heal_to_full() -> void:
	current_hp = max_hp
