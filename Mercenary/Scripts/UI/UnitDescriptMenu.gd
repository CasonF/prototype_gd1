class_name UnitDescriptMenu
extends Control

@onready var STR := $Value_STR
@onready var DEX := $Value_DEX
@onready var CON := $Value_CON
@onready var INT := $Value_INT
@onready var WIS := $Value_WIS
@onready var CHA := $Value_CHA

@onready var HP := $Value_HP
@onready var NAME := $Value_Name

@onready var hp_bar := $Health_Bar

func _initialize(unit: Unit) -> void:
	STR.text = str(unit.unit_data.base_str)
	DEX.text = str(unit.unit_data.base_dex)
	CON.text = str(unit.unit_data.base_con)
	INT.text = str(unit.unit_data.base_int)
	WIS.text = str(unit.unit_data.base_wis)
	CHA.text = str(unit.unit_data.base_cha)
	NAME.text = unit.NAME
	HP.text = str(unit.CUR_HP) + "/" + str(unit.MAX_HP)
	_initialize_hpbar(unit.CUR_HP, unit.MAX_HP)

func _initialize_hpbar(current: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current
	
	if float(current) / float(max_hp) <= 0.25:
		hp_bar.modulate = GlobalVariables.QUARTER_HP_COLOR
	elif float(current) / float(max_hp) <= 0.5:
		hp_bar.modulate = GlobalVariables.HALF_HP_COLOR
	else:
		hp_bar.modulate = GlobalVariables.MAX_HP_COLOR
