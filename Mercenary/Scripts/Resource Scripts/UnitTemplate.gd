extends Resource

class_name UnitTemplate

# Assign the sprite to the resource to load in the weapon scene
@export_group("Unit Info")
@export var sprite_folder_file_path : String
# This defines the type of unit for stats and weapon assignment
@export_enum("Archer", "Fighter", "Mage") var type : String
# This is the name of the weapon, i.e. Iron Sword, Shortbow, Glacial Lance...
@export var name : String
# This is the number of spaces the unit can move in a turn
@export var move_range : int = 5
@export var attack_range : int = 1
# Base stats used in combat or for misc purposes
@export_group("Base Stats")
@export var base_str : int
@export var base_dex : int
@export var base_con : int
@export var base_int : int
@export var base_wis : int
@export var base_cha : int
@export var base_luk : int
# A few additional battle modifiers
@export_category("Abilities")
# Map Abilities - abilities that can be triggered on the battle map as an action or bonus action
# The flag for the map ability being a bonus action is defaulted to false
@export_group("Map Abilities")
@export_enum("None", "SPD Boost", "ATK Boost", "CRIT Boost", "Heal Zone") var map_ability_1 : int = 0
@export var map_ability_1_is_bonus_action := false
@export_enum("None", "SPD Boost", "ATK Boost", "CRIT Boost", "Heal Zone") var map_ability_2 : int = 0
@export var map_ability_2_is_bonus_action := false
# Combat Abilities - passive abilities that can trigger during combat between units
# Bonus chance to trigger combat abilities is defaulted to 0; the value is additive, not multiplicative
@export_group("Combat Abilities")
@export_enum("None", "Crit Heal", "Penetrating Strike", "Vengeance", "Doctor") var combat_ability_1 : int = 0
@export var combat_ability_1_bonus_chance := 0.0
@export_enum("None", "Crit Heal", "Penetrating Strike", "Vengeance", "Doctor") var combat_ability_2 : int = 0
@export var combat_ability_2_bonus_chance := 0.0


# When creating a new resource via Unit.new(), can pass in parameters (as seen below) to initialize values
func _init(i_type = "Fighter", i_name = "Barbarian", i_move_range = 3, i_atk_range = 1,
i_str = 10, i_dex = 10, i_con = 10, i_int = 10, i_wis = 10, i_cha = 10, i_luk = 10) -> void:
	type = i_type
	name = i_name
	move_range = i_move_range
	attack_range = i_atk_range
	base_str = i_str
	base_dex = i_dex
	base_con = i_con
	base_int = i_int
	base_wis = i_wis
	base_cha = i_cha
	base_luk = i_luk
