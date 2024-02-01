extends Button

func _pressed():
	SignalBus.btn_unit_select_items.emit()
