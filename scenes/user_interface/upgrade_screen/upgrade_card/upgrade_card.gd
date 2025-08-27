extends PanelContainer

signal selected

@onready var name_label: Label = $%NameLabel
@onready var description_label: Label = $%DescLabel

func _ready() -> void:
	gui_input.connect(on_gui_input)

func set_upgrade_info(upgrade: Upgrade):
	name_label.text = upgrade.name
	description_label.text = upgrade.description

func on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		selected.emit()
