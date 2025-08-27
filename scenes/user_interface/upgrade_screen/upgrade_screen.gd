extends CanvasLayer

signal upgrade_selected(upgrade: Upgrade)

@export var upgrade_card_scene: PackedScene

@onready var card_row: HBoxContainer = $%CardRow

func _ready() -> void:
	get_tree().paused = true

func on_upgrade_selected(upgrade: Upgrade) -> void:
	upgrade_selected.emit(upgrade)
	get_tree().paused = false
	queue_free()

func set_upgrade_list(upgrades: Array[Upgrade]):
	for upgrade in upgrades:
		var card_instance = upgrade_card_scene.instantiate()
		card_row.add_child(card_instance)
		card_instance.set_upgrade_info(upgrade)
		card_instance.selected.connect(on_upgrade_selected.bind(upgrade))
