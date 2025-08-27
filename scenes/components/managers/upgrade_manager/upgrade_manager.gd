extends Node

signal exp_updated(current_exp: float, target_exp: float)

const TARGET_EXP_GROWTH = 2

@export var upgrade_pool: Array[Upgrade]
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}

var current_exp = 0
var target_exp = 1

var current_lvl = 1

func _ready() -> void:
	GameEvents.exp_increased.connect(on_exp_increased)

func on_exp_increased(amount: int) -> void:
	current_exp = min(current_exp + amount, target_exp)
	exp_updated.emit(current_exp, target_exp)
	if current_exp >= target_exp:
		current_lvl += 1
		target_exp += TARGET_EXP_GROWTH
		current_exp = 0
		exp_updated.emit(current_exp, target_exp)
		on_level_up(current_lvl)


func apply_upgrade(upgrade: Upgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resources": upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1

	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:
			upgrade_pool = upgrade_pool.filter(func(pool_upgrade): return pool_upgrade.id != upgrade.id)

	GameEvents.emit_upgrade_added(upgrade, current_upgrades)

func pick_upgrades():
	var chosen_upgrades: Array[Upgrade] = []
	var filtered_upgrades = upgrade_pool.duplicate()
	for i in 3:
		if filtered_upgrades.is_empty():
			break
		var chosen_upgrade = filtered_upgrades.pick_random() as Upgrade
		chosen_upgrades.append(chosen_upgrade)
		filtered_upgrades = filtered_upgrades.filter(func(upgrade): return upgrade.id != chosen_upgrade.id)
	return chosen_upgrades


func on_upgrade_selected(upgrade: Upgrade) -> void:
	apply_upgrade(upgrade)


func on_level_up(_current_level):
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)

	var chosen_upgrades = pick_upgrades()

	upgrade_screen_instance.set_upgrade_list(chosen_upgrades as Array[Upgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)
