extends Node

signal rage_increased(number: int)
signal rage_amount_updated(amount: int)
signal frog_devour_something(number: int)
signal devour_combo_text_updated(number: int)
signal hunger_progress_updated(amount: float)
signal exp_increased(amount: int)
signal upgrade_added(upgrade: Upgrade, current_upgrades: Dictionary)
signal tongue_stuck(is_tongue_stuck: bool)

func emit_rage_increased(number: int):
	rage_increased.emit(number)

func emit_rage_amount_updated(amount: int):
	rage_amount_updated.emit(amount)

func emit_frog_devour_something(number: int):
	frog_devour_something.emit(number)

func emit_devour_combo_text_updated(number: int):
	devour_combo_text_updated.emit(number)

func emit_hunger_progress_updated(amount: float):
	hunger_progress_updated.emit(amount)

func emit_exp_increased(amount: int):
	exp_increased.emit(amount)

func emit_upgrade_added(upgrade: Upgrade, current_upgrades: Dictionary):
	upgrade_added.emit(upgrade, current_upgrades)

func emit_tongue_stuck(is_tongue_stuck: bool):
	tongue_stuck.emit(is_tongue_stuck)