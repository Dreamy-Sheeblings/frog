extends CanvasLayer

@onready var panel: PanelContainer = %Panel

@onready var replay_button: TextureButton = %ReplayButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.pivot_offset = panel.size / 2

	replay_button.pressed.connect(on_replay_pressed)
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel, "scale", Vector2.ONE, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func on_replay_pressed() -> void:
	AudioManager.click_sfx.play()
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")