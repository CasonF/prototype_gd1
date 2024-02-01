extends Resource

class_name WeaponTemplate

# Assign the sprite to the resource to load in the weapon scene
@export var weapon_sprite : Texture2D
# This defines the type of weapon being used for RPS calcs
@export_enum("None", "Sword", "Spear", "Axe", "Bow", "Book") var type : String
# This is the name of the weapon, i.e. Iron Sword, Shortbow, Glacial Lance...
@export var name : String
# This is a range of the weapon in battle. Non-magic and non-ranged weapons should only have a range of 1
@export var map_range : int
# This is the base damage of the weapon used for damage calcs
@export var base_damage : int
# This is the element of the weapon, used for more RPS stuff
@export_enum("None", "Fire", "Ice", "Wind", "Light", "Dark") var element : String
# This is the probability (out of 100.0) that the attack will crit
@export var crit_hit_chance : float
# This is the multiplier for the crit damage, to be applied after all other damage calcs
@export var crit_damage_mult : float
# Durability may be overkill... Will have to see
@export var max_durability : int

# When creating a new resource via Weapon.new(), can pass in parameters (as seen below) to initialize values
func _init(i_type = "None", i_name = "None", i_range = 1, i_base_damage = 1, i_element = "None", i_crit_hit_chance = 2.5, i_crit_damage_mult = 1.5, i_max_durability = 50) -> void:
	type = i_type
	name = i_name
	map_range = i_range
	base_damage = i_base_damage
	element = i_element
	crit_hit_chance = i_crit_hit_chance
	crit_damage_mult = i_crit_damage_mult
	max_durability = i_max_durability
	
