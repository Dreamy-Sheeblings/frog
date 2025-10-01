extends CanvasLayer

func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("left_click"):
		$AnimPlayer.play_backwards("in")
		await $AnimPlayer.animation_finished
		queue_free()