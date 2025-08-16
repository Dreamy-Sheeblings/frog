extends Area2D

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)

func on_timer_timeout() -> void:
	queue_free()
