extends PanelContainer

signal selected

@onready var anim_player: AnimationPlayer = $AnimPlayer

@onready var name_label: Label = $%NameLabel
@onready var description_label: Label = $%DescLabel
var disabled: bool = false

func _ready() -> void:
	gui_input.connect(on_gui_input)
	mouse_entered.connect(on_mouse_entered)

func set_upgrade_info(upgrade: Upgrade):
	name_label.text = upgrade.name
	description_label.text = upgrade.description

func on_gui_input(event: InputEvent) -> void:
	if disabled:
		return
	if event.is_action_pressed("left_click"):
		select_card()

func appear(delay: float = 0):
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	anim_player.play("in")

func disappear():
	anim_player.play("discard")

func select_card():
	disabled = true
	anim_player.play("selected")

	for other_card in get_tree().get_nodes_in_group("upgrade_card"):
		if other_card == self:
			continue
		other_card.disappear()
	await anim_player.animation_finished
	selected.emit()

func on_mouse_entered() -> void:
	if disabled:
		return
	$HoverAnimPlayer.play("hover")