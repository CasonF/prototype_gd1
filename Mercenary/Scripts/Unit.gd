## Represents a unit on the game board.
## The board manages its position inside the game grid.
## The unit itself holds stats and a visual representation that moves smoothly in the game world.
@tool
class_name Unit
extends Path2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished

## Shared resource of type Grid, used to calculate map coordinates.
@export var grid: Resource
## Distance to which the unit can walk in cells.
@export var move_range : int = 7
## Distance that the unit can target other units to attack.
@export_enum("CARDINAL", "SQUARE", "RANGE") var attack_type : String = "CARDINAL"
# Attack distance/offset - if Cardinal and 2, should only be able to hit units
# that are a full space away rather than adjacent
@export var attack_distance : int = 1
## The unit's move speed when it's moving along a path.
@export var move_speed := 600.0
## Texture representing the unit.
@export var skin: Texture:
	set(value):
		skin = value
		if not _sprite:
			# This will resume execution after this node's _ready()
			await ready
		_sprite.texture = value
## Offset to apply to the `skin` sprite in pixels.
@export var skin_offset := Vector2.ZERO:
	set(value):
		skin_offset = value
		if not _sprite:
			await ready
		_sprite.position = value

# TODO: Reorganize and categorize unit variables using export_category
## Custom Resource that defines base unit stats and abilities
@export var unit_data : UnitTemplate
var MAX_HP : int = 15
var CUR_HP : int
var ATTACK : int = 5
var DEFENSE : int = 1
var SPEED : int = 3

@export var NAME : String = ""
@export var LEVEL : int = 1
@export_enum("BLUE:0", "RED:1", "YELLOW:2", "GREEN:3") var unit_team : int
func _is_friendly_unit(target: Unit) -> bool:
	return unit_team==target.unit_team
@export var is_npc_unit : bool = false
# Default to Closest. This value should not even be checked if is_nps_unit is false
@export_enum("CLOSEST", "ATTACK_RANGE") var AI_TARGET : String = "CLOSEST"


## Coordinates of the current cell the cursor moved to.
var cell := Vector2.ZERO:
	set(value):
		# When changing the cell's value, we don't want to allow coordinates outside
		#	the grid, so we clamp them
		cell = grid.grid_clamp(value)
## Toggles the "selected" animation on the unit.
var is_selected := false:
	set(value):
		is_selected = value
		if is_selected and has_active_turn:
			_selection_glow.hide()
			_anim_player.stop()
		elif has_active_turn:
			_selection_glow.show()
			_anim_player.play("current_turn_flash")

# Pseudos are used to handle AI stuff
var pseudo_is_selected : bool = false
func set_psuedo_selected(value: bool) -> void:
	pseudo_is_selected = value

# Don't flash if character is already selected... No need to be obnoxious (yet)
var has_active_turn := false:
	set(value):
		has_active_turn = value
		if has_active_turn:
			_selection_glow.show()
			_anim_player.play("current_turn_flash")
		else:
			_selection_glow.hide()
			_anim_player.stop()

var is_attacking := false:
	set(value):
		is_attacking = value
		if is_attacking and has_active_turn:
			_selection_glow.hide()
			_anim_player.stop()
		elif has_active_turn:
			_selection_glow.show()
			_anim_player.play("current_turn_flash")

var _is_walking := false:
	set(value):
		_is_walking = value
		if _is_walking and has_active_turn:
			_selection_glow.hide()
			_anim_player.stop()
		elif has_active_turn:
			_selection_glow.show()
			_anim_player.play("current_turn_flash")
		set_process(_is_walking)

@onready var _sprite: Sprite2D = $PathFollow2D/Sprite2D
@onready var _selection_glow : Sprite2D = $PathFollow2D/SelectionGlow
# @onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D
@onready var _unit_menu := $UnitMenu
@onready var _unit_area := $Area2D
@onready var _anim_player := $AnimationPlayer

var _has_moved_this_turn := false:
	set(value):
		_has_moved_this_turn = value

var _has_attacked_this_turn := false:
	set(value):
		_has_attacked_this_turn = value

func _ready() -> void:
	set_process(false)
	_path_follow.rotates = false
	
	setup_unit_signals()
	initialize_stats()

	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

	# We create the curve resource here because creating it in the editor prevents us from
	# moving the unit.
	if not Engine.is_editor_hint():
		curve = Curve2D.new()

func setup_unit_signals() -> void:
	_unit_area.mouse_entered.connect(Callable(_show_descript_menu))
	_unit_area.mouse_exited.connect(Callable(_hide_descript_menu))

func initialize_stats() -> void:
	if unit_data:
		move_range = unit_data.move_range
		#!!! UNCOMMENT this after - testing only !!!
		# attack_range = unit_data.attack_range
		
		# This will need changing and abstraction...
		ATTACK = (unit_data.base_str / 2) + LEVEL + (LEVEL / 3)
		DEFENSE = 1
		SPEED = (unit_data.base_dex / 2) + LEVEL - ((unit_data.base_con + unit_data.base_str) / 3)
		MAX_HP = unit_data.base_con + (unit_data.base_con / 2)
	# Always initialize CUR_HP
	CUR_HP = MAX_HP

func take_damage(damage: int) -> void:
	if damage > CUR_HP:
		CUR_HP = 0
	else:
		CUR_HP -= damage

func _process(delta: float) -> void:
	_path_follow.progress += move_speed * delta

	if _path_follow.progress_ratio >= 1.0:
		_is_walking = false
		# Setting this value to 0.0 causes a Zero Length Interval error
		_path_follow.progress = 0.00001
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")
	

func _show_descript_menu() -> void:
	SignalBus.mouse_hover_show_unit_info.emit(self)

func _hide_descript_menu() -> void:
	SignalBus.mouse_hover_hide_unit_info.emit()

## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return
	
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	_is_walking = true

func _get_sprite_texture() -> Texture:
	return skin

func _get_sprite_scale() -> Vector2:
	return _sprite.scale
