## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
@export var grid: Resource

## Mapping of coordinates of a cell to a reference to the unit it contains - Dictionary
var _units := {}
var _active_unit: Unit
var _target_unit: Unit
var _walkable_cells := []
var _attack_cells := []

@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath
@onready var _cursor : Cursor = $Cursor
@onready var _unit_descript_menu : UnitDescriptMenu = $UnitDescriptMenu

var _current_turn_order := []
var _next_turn_order := []:
	get:
		return BattleManager.update_unit_round_order(_units)
# This is only important if we implement abilities that are dependent on previous turn stuff
var _prev_turn_order := []
var _current_turn_unit : Unit

func _ready() -> void:
	_reinitialize()
	_connect_gameboard_signals()
	
	_current_turn_order = BattleManager.update_unit_round_order(_units)
	handle_turn_order()

func _connect_gameboard_signals() -> void:
	SignalBus.btn_unit_select_move.connect(Callable(_btn_select_unit_move))
	SignalBus.btn_unit_select_attack.connect(Callable(_btn_select_unit_attack))
	SignalBus.btn_unit_select_items.connect(Callable(_btn_select_unit_items))
	SignalBus.btn_unit_select_end_turn.connect(Callable(_btn_select_end_turn))
	SignalBus.mouse_hover_show_unit_info.connect(Callable(_mouse_hover_show_unit_stats))
	SignalBus.mouse_hover_hide_unit_info.connect(Callable(_mouse_hover_hide_unit_stats))

# If no unit in turn order and turn order.size > 0,
# get first unit and set previous turn order = current turn order
# else update turn order.
func handle_turn_order() -> void:
	if check_if_battle_end():
		print_debug("End of battle!")
	# 	handle_end_of_battle()
		return
	if _current_turn_order.size() > 0 and !_current_turn_unit:
		_prev_turn_order = _current_turn_order
		_current_turn_unit = _current_turn_order[0]
		_current_turn_unit._has_moved_this_turn = false
		_current_turn_unit._has_attacked_this_turn = false
		if _current_turn_unit.is_npc_unit:
			_active_unit = _current_turn_unit
			BattleAI.handle_enemy_turn(self)
		else:
			_current_turn_unit.has_active_turn = true
	else:
		update_current_turn_order()

# So many nested if statements... Probably need to refactor at some point
# This function handles removing units from current turn order and getting
# the next unit in turn order. If current_turn_order is empty, pull next_turn_order.
func update_current_turn_order() -> void:
	_current_turn_order = BattleManager.check_units_list_for_updates(_units, _current_turn_order)
	if _current_turn_order.size() > 0 and _current_turn_unit:
		_current_turn_unit.has_active_turn = false
		_current_turn_unit._has_moved_this_turn = false
		_current_turn_unit._has_attacked_this_turn = false
		_current_turn_order.pop_front()
		if _current_turn_order.size() > 0:
			_current_turn_unit = _current_turn_order[0]
			if _current_turn_unit.is_npc_unit:
				_active_unit = _current_turn_unit
				BattleAI.handle_enemy_turn(self)
			else:
				_current_turn_unit.has_active_turn = true
		# No more units in turn order - recursion time
		else:
			_current_turn_unit = null
			_current_turn_order = _next_turn_order
			handle_turn_order()

# Evaluates to true if all remaining units are on the same team
# NOTE: Currently it will technically handle a "draw" bc both team lists will be empty
# but we may want to set up a special case for it.
func check_if_battle_end() -> bool:
	var end_of_battle := false
	# Check if all remaining units are on same team
	var _enemies := []
	var _allies := []
	
	var unit_list : Array = _units.values()
	for unit in unit_list:
		# It is assumed that team 0 is player team
		if unit.unit_team != 0:
			_enemies.append(unit)
		else:
			_allies.append(unit)
	if _enemies.size() < 1 or _allies.size() < 1:
		end_of_battle = true
	
	return end_of_battle

# If you click escape, this triggers
func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_active_unit.is_attacking = false
		_deselect_active_unit()
		_clear_active_unit()

func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return _units.has(cell)

func is_current_turn_unit(cell: Vector2) -> bool:
	return _units[cell].has_active_turn

## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.move_range)

func set_walkable_cells(cells: Array) -> void:
	_walkable_cells = cells

func get_target_cells(unit: Unit) -> Array:
	return _flood_fill_attack(unit.cell, unit.attack_type, unit.attack_distance)

## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()

	for child in $Units.get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit


## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
## Leveraged to get cells that can be targeted for attacks
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.size() == 0:
		var current = stack.pop_back()
		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue

		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				continue
			if coordinates in array:
				continue
			# Minor optimization: If this neighbor is already queued
			#	to be checked, we don't need to queue it again
			if coordinates in stack:
				continue

			stack.append(coordinates)
	array.pop_front()
	return array

# Updated attack flood fill. Handles different attack ranges and targeting types
func _flood_fill_attack(cell: Vector2, attack_type : String = "CARDINAL", offset : int = 1) -> Array:
	offset = 1 if offset < 1 else offset
	var array := []
	var stack := [cell]
	if "CARDINAL" == attack_type:
		for direction in DIRECTIONS:
			var coordinates: Vector2 = cell + (direction * offset)
			if not grid.is_within_bounds(coordinates):
				continue
			if coordinates in array:
				continue
			array.append(coordinates)
	elif "SQUARE" == attack_type:
		var sq_stack := []
		# Couldn't find a more elegant solution...
		for i in range(-offset, offset+1, 1):
			var bottom: Vector2 = cell + Vector2(i, -offset)
			var top: Vector2 = cell + Vector2(i, offset)
			var left: Vector2 = cell + Vector2(-offset, i)
			var right: Vector2 = cell + Vector2(offset, i)
			sq_stack.append(bottom)
			sq_stack.append(top)
			sq_stack.append(left)
			sq_stack.append(right)
		for coordinates in sq_stack:
			if not grid.is_within_bounds(coordinates):
				continue
			if coordinates in array:
				continue
			array.append(coordinates)
	elif "RANGE" == attack_type:
		while not stack.size() == 0:
			var current = stack.pop_back()
			if not grid.is_within_bounds(current):
				continue
			if current in array:
				continue

			var difference: Vector2 = (current - cell).abs()
			var distance := int(difference.x + difference.y)
			if distance > offset:
				continue

			array.append(current)
			for direction in DIRECTIONS:
				var coordinates: Vector2 = current + direction
				if coordinates in array:
					continue
				# Minor optimization: If this neighbor is already queued
				# to be checked, we don't need to queue it again
				if coordinates in stack:
					continue

				stack.append(coordinates)
		array.pop_front()
	return array


## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2, override: bool = false) -> void:
	# We use override to bypass checks we already performed in BattleAI.gd when selecting our new spot
	if !override:
		if is_occupied(new_cell) or not new_cell in _walkable_cells:
			return
	# warning-ignore:return_value_discarded
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.current_path)
	await _active_unit.walk_finished
	if _active_unit:
		_current_turn_unit._has_moved_this_turn = true
	_clear_active_unit()

func _attack_selected_unit(target_cell: Vector2, override: bool = false) -> void:
	if !override:
		if !is_occupied(target_cell) or not target_cell in _attack_cells:
			return
	
	_target_unit = _units[target_cell]
	var _target_defeated = BattleManager.handle_battle(_active_unit, _target_unit)
	# Attempt to refresh the stats menu
	_mouse_hover_hide_unit_stats()
	# Move dead units to DeadUnits, which is hidden
	move_dead_units(_active_unit, _target_unit)
	
	_active_unit.is_attacking = false
	if _active_unit:
		_current_turn_unit._has_attacked_this_turn = true
	_deselect_active_unit()
	_clear_active_unit()
	
	if check_if_battle_end():
		print_debug("Battle should end after this combat!")
	#	handle_battle_end()

# Move dead units to DeadUnits node so that we can evaluate reward, etc. after all combat
# NOTE: Units and DeadUnits nodes do not update in Scene (on left) while testing,
# but debug proves they are moved properly.
func move_dead_units(active: Unit, target: Unit) -> void:
	if active.CUR_HP <= 0:
		_units.erase(active.cell)
		$Units.remove_child(active)
		$DeadUnits.add_child(active)
	if target.CUR_HP <= 0:
		_units.erase(target.cell)
		$Units.remove_child(target)
		$DeadUnits.add_child(target)

## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return
	# Prevent unit from being selected if not their turn
	if not _units[cell].has_active_turn:
		return
	
	_active_unit = _units[cell]
	_active_unit._unit_menu.show()
	
	var moveBtn : Button = _current_turn_unit._unit_menu.get_child(0)
	var atkBtn : Button = _current_turn_unit._unit_menu.get_child(1)
	# Disable move button if unit has moved this turn
	moveBtn.disabled = _current_turn_unit._has_moved_this_turn
	print_debug("Has moved this turn?: ", _current_turn_unit._has_moved_this_turn)
	# Disabled attack button if unit has attacked this turn
	atkBtn.disabled = _current_turn_unit._has_attacked_this_turn
	print_debug("Has attacked this turn?: ", _current_turn_unit._has_attacked_this_turn)
	_cursor.hide()

# Activated when click "Move" button in unit menu.
# Draws moveable tiles, appends unit image to cursor, and draws
# invisible path that unit will move along to get from a to b
func _btn_select_unit_move() -> void:
	_active_unit._unit_menu.hide()
	_active_unit.is_selected = true
	_cursor.show()
	_cursor._set_unit_image(_active_unit._get_sprite_texture())
	_cursor._set_unit_image_scale(_active_unit._get_sprite_scale())
	_cursor._show_unit_image()
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)

# Activated when click "Attack" button in unit menu.
# Draws targetable tiles; set 1 as id in draw to indicate to use red tiles instead of yellow (0/default)
func _btn_select_unit_attack() -> void:
	_active_unit._unit_menu.hide()
	_active_unit.is_attacking = true
	_cursor.show()
	_attack_cells = get_target_cells(_active_unit)
	# TileSet for Unit Overlay has yellow squares at index 0 and red squares at index 1
	_unit_overlay.draw(_attack_cells, 1)

# Activated when click "Items" in unit menu.
# Does nothing at the moment...
func _btn_select_unit_items() -> void:
	print_debug("Inside _btn_select_unit_items")
	_active_unit._unit_menu.hide()
	_cursor.show()
	_deselect_active_unit()
	_clear_active_unit()

# Ends turn for the active unit, proceed to next turn in turn order
func _btn_select_end_turn() -> void:
	_deselect_active_unit()
	_clear_active_unit()
	handle_turn_order()

# Activated when hovering over Area2D of unit.
# This displays unit info in the little popup in the bottom right of the screen
# NOTE: This should probably change to menu always visible but content changes on hover
func _mouse_hover_show_unit_stats(unit: Unit) -> void:
	if _unit_descript_menu:
		_unit_descript_menu._initialize(unit)
		_unit_descript_menu.show()

# Activated when mouse leaves Area2D of unit.
# This hides unit stat display in bottom right
func _mouse_hover_hide_unit_stats() -> void:
	if _unit_descript_menu:
		_unit_descript_menu.hide()


## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	if _active_unit:
		_active_unit.is_selected = false
		_active_unit._unit_menu.hide()
	_cursor._hide_unit_image()
	_unit_overlay.clear()
	_unit_path.stop()


## Clears the reference to the _active_unit and the corresponding walkable cells.
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()
	_attack_cells.clear()


## Selects or moves a unit based on where the cursor is.
func _on_cursor_accept_pressed(cell: Vector2) -> void:
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_active_unit(cell)
	elif _active_unit.is_attacking:
		_attack_selected_unit(cell)


## Updates the interactive path's drawing if there's an active and selected unit.
func _on_cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)
