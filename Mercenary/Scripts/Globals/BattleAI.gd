extends Node

var _current_game_board : GameBoard

var _decide_move := false
# var _decide_attack := false

var _move_target : Vector2
var _attack_target_pos : Vector2

func handle_enemy_turn(scene: GameBoard) -> void:
	_current_game_board = scene
	initialize()
	handle_actions()

func initialize() -> void:
	_decide_move = false
#	_decide_attack = false
	_move_target = Vector2()
	_attack_target_pos = Vector2()

func handle_actions() -> void:
	action_handle_move()
	action_handle_attack()
	_current_game_board._btn_select_end_turn()

func action_handle_move() -> void:
	var _acting_unit : Unit = _current_game_board._current_turn_unit
	print_debug("Unit name: ", _acting_unit.NAME)
	var _move_pref := _acting_unit.AI_TARGET
	if _move_pref.matchn("CLOSEST"):
		print_debug("_move_pref = CLOSEST")
		_attack_target_pos = _get_closest_player_unit_pos(_acting_unit)
		_decide_move = _get_closest_player_unit_in_attack_range(_acting_unit, _attack_target_pos)
		if _decide_move:
			_move_target = _move_to_closest_legal_space(_acting_unit, _attack_target_pos)
			_current_game_board._unit_path.draw(_acting_unit.cell, _move_target)
			_current_game_board._move_active_unit(_move_target, true)
			await _acting_unit.walk_finished
	elif _move_pref.matchn("ATTACK_RANGE"):
		print_debug("_move_pref = ATTACK_RANGE")
		_attack_target_pos = _get_closest_player_unit_pos(_acting_unit)
		_decide_move = _get_closest_player_unit_in_attack_range(_acting_unit, _attack_target_pos)
		if _decide_move:
			_move_target = _move_to_furthest_space_can_attack(_acting_unit, _attack_target_pos)
			_current_game_board._unit_path.draw(_acting_unit.cell, _move_target)
			_current_game_board._move_active_unit(_move_target, true)
			await _acting_unit.walk_finished
	else:
		print_debug("AI_TARGET value not handled: ", _move_pref)

func action_handle_attack() -> void:
	var _acting_unit : Unit = _current_game_board._current_turn_unit
	# NOTE: Remove _decide_move check after adding turn end button/option
	# Good chance things just break if this check is not here for now...
	if !_get_closest_player_unit_in_attack_range(_acting_unit, _attack_target_pos):
		print_debug("Attempting to attack player unit...")
		_current_game_board._attack_selected_unit(_attack_target_pos, true)
	elif !_decide_move:
		print_debug("Unit did not move and did not attack...")

func _get_closest_player_unit_pos(_acting_unit: Unit) -> Vector2:
	var _closest := Vector2(499,-499) # This vector was selected arbitrarily
	var unit_list : Array = _current_game_board._units.keys()
	print_debug("Current cell: ", _acting_unit.cell)
	for unit in unit_list:
		if _check_if_enemy_unit(_acting_unit, unit) and _check_if_x_closer_than_y(_acting_unit.cell, unit, _closest):
			_closest = unit
	print_debug("_closest = ", _closest)
	return _closest

func _get_closest_player_unit_in_attack_range(_acting_unit: Unit, _target: Vector2) -> bool:
	var _must_move_to_attack := false
	var difference: Vector2 = (_acting_unit.cell - _target).abs()
	var distance := int(difference.x + difference.y)
	# NOTE: This needs improvement...
	if "RANGE" == _acting_unit.attack_type:
		if distance > _acting_unit.attack_distance:
			_must_move_to_attack = true
	else:
		if distance != _acting_unit.attack_distance:
			_must_move_to_attack = true
	return _must_move_to_attack

func _move_to_closest_legal_space(_acting_unit: Unit, _target: Vector2) -> Vector2:
	var _new_pos : Vector2 = _acting_unit.cell
	_acting_unit.set_psuedo_selected(true)
	var _walkable_cells : Array = _current_game_board.get_walkable_cells(_acting_unit)
	_current_game_board.set_walkable_cells(_walkable_cells)
	for cell in _walkable_cells:
		if _check_if_x_closer_than_y(_target, cell, _new_pos):
			_new_pos = cell
	_acting_unit.set_psuedo_selected(false)
	_current_game_board._unit_path.initialize(_walkable_cells)
	return _new_pos

func _move_to_furthest_space_can_attack(_acting_unit: Unit, _target: Vector2) -> Vector2:
	var _new_pos : Vector2 = _acting_unit.cell
	_acting_unit.set_psuedo_selected(true)
	var _walkable_cells : Array = _current_game_board.get_walkable_cells(_acting_unit)
	print_debug("Attack Range: ", _acting_unit.attack_distance)
	for cell in _walkable_cells:
		if _check_pos_at_max_attack_range(_target, cell, _acting_unit):
			_new_pos = cell
	# If no spaces close enough to attack, just close distance
	print_debug("New Pos: ", _new_pos)
	print_debug("Actor Cell: ", _acting_unit.cell)
	print_debug("Target Cell: ", _target)
	if _new_pos == _acting_unit.cell:
		for cell in _walkable_cells:
			if _check_if_x_closer_than_y(_target, cell, _new_pos):
				_new_pos = cell
	_acting_unit.set_psuedo_selected(false)
	_current_game_board._unit_path.initialize(_walkable_cells)
	return _new_pos

# If multiple legal units/cells are equidistant from this unit, we generate a random
# number to determine if we lock onto the new target that is equidistant or not
func _check_if_x_closer_than_y(target: Vector2, x: Vector2, y: Vector2) -> bool:
	var x_closer_than_y := false
	if x.distance_to(target) < y.distance_to(target):
		x_closer_than_y = true
	# 50% chance to change target if equidistant
	elif x.distance_to(target) == y.distance_to(target) and randf() <= 0.5:
		x_closer_than_y = true
	return x_closer_than_y
	
func _check_pos_at_max_attack_range(target: Vector2, cell: Vector2, _acting_unit: Unit) -> bool:
	var at_range := false
	var difference: Vector2 = (target - cell).abs()
	var distance := int(difference.x + difference.y)
	var x_is_attack_range : bool = (distance == _acting_unit.attack_distance)
	if x_is_attack_range:
		print_debug("Tile that is in attack range: ", cell)
	# 50% chance to change target if equidistant in other spot in attack range
	if cell == _acting_unit.cell and x_is_attack_range:
		at_range = true
	elif x_is_attack_range and randf() <= 0.5:
		at_range = true
	return at_range

# This evaluates to true if the target unit's "is_friendly_unit" is false
func _check_if_enemy_unit(actor: Unit, pos: Vector2) -> bool:
	var _is_enemy := false
	var _units_dict : Dictionary = _current_game_board._units
	var _target_unit : Unit = _units_dict.get(pos)
	if _target_unit:
		_is_enemy = !_target_unit._is_friendly_unit(actor)
	else:
		print_debug("Target unit could not be found.")
	return _is_enemy
