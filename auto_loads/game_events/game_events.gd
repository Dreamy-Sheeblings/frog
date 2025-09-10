extends Node

# Rage
signal rage_increased(number: float)
signal rage_active(is_active: bool)
# 
signal frog_devour_something(hunger_pnt: int, exp_pnt: int)
signal devour_combo_text_updated(number: int)
signal hunger_progress_updated(amount: float)
signal exp_increased(amount: int)
signal upgrade_added(upgrade: Upgrade, current_upgrades: Dictionary)
signal tongue_stuck(is_tongue_stuck: bool)
signal death_warning(warn: bool)
signal storm_casted(is_stormy: bool)

func emit_rage_increased(number: int):
	rage_increased.emit(number)

func emit_rage_active(is_active: bool):
	rage_active.emit(is_active)

func emit_frog_devour_something(hunger_pnt: int, exp_pnt: int):
	frog_devour_something.emit(hunger_pnt, exp_pnt)

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

func emit_death_warning(warn: bool):
	death_warning.emit(warn)

func emit_storm_cast(is_stormy: bool):
	storm_casted.emit(is_stormy)