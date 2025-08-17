extends Area2D

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)

func on_timer_timeout() -> void:
	timer.stop()
	var disappear_tween = create_tween()
	disappear_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	disappear_tween.tween_callback(queue_free)
