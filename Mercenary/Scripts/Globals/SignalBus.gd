extends Node

# Display unit actions in UnitMenu (see unit.tscn)
# See GameBoard.gd for usage
signal btn_unit_select_move
signal btn_unit_select_attack
signal btn_unit_select_items
signal btn_unit_select_end_turn

# Display unit stats and info in the panel (see unit.tscn and any battle_map)
# See GameBoard.gd for usage
signal mouse_hover_show_unit_info(unit: Unit)
signal mouse_hover_hide_unit_info
