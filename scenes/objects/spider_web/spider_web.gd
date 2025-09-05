extends Area2D

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	var spawn_tween = create_tween()
	spawn_tween.tween_property(self, "scale", Vector2.ONE, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	area_exited.connect(on_tongue_exited)

func on_tongue_exited(area: Area2D) -> void:
	if area.is_in_group("tongue"):
		var disappear_tween = create_tween()
		disappear_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		disappear_tween.tween_callback(queue_free)

func on_timer_timeout() -> void:
	timer.stop()
	var disappear_tween = create_tween()
	disappear_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	disappear_tween.tween_callback(queue_free)
