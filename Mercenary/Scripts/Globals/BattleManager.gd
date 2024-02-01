extends Node

# Basic function to handle two units battling each other
# This function returns whether the attacker defeats the defender
func handle_battle(attacker: Unit, defender: Unit) -> bool:
	# Super basic damage calcs to start...
	var damage = calc_damage(attacker.ATTACK, defender.DEFENSE)
	print_debug("Attacker is attacking Defender")
	defender.take_damage(damage)
	print_debug("Defender Current HP = ", defender.CUR_HP)
	
	if defender.CUR_HP <= 0:
		# End combat immediately
		return true
	
	# Check to see if defender can retaliate
	# TODO: This logic needs to updated, probably...
	if defender.attack_distance <= attacker.attack_distance and int(defender.cell.distance_to(attacker.cell)) > defender.attack_distance:
		return false
	# Now defender gets to attack back if still alive
	damage = calc_damage(defender.ATTACK, attacker.DEFENSE)
	print_debug("Defender is attacking Attacker")
	attacker.take_damage(damage)
	print_debug("Attacker Current HP = ", attacker.CUR_HP)
	
	return false

func calc_damage(atk: int, def: int) -> int:
	var dif = atk - def
	print_debug("Damage: ", dif)
	return 0 if dif < 0 else dif

# Basic turn order array setter
func update_unit_round_order(units: Dictionary) -> Array:
	var turn_order := []
	for unit in units:
		turn_order.append(units[unit])
	turn_order.sort_custom(sort_by_speed)
	return turn_order

# Basic turn order sorter
func sort_by_speed(a: Unit, b: Unit) -> bool:
	if a.SPEED > b.SPEED:
		return true
	return false

# If unit is destroyed and removed from gameboard, need to update turn list
func check_units_list_for_updates(units: Dictionary, current_order: Array) -> Array:
	var updated_turn_order := current_order
	var units_list : Array = units.values()
	for unit in updated_turn_order:
		if !units_list.has(unit):
			updated_turn_order.erase(unit)
	return updated_turn_order
