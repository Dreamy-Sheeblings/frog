extends CanvasLayer

@onready var progress_bar: TextureProgressBar = $HungerProgressBar
@onready var timer: Timer = $Timer

var tongue_stuck_dmg: float = 0.0

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	GameEvents.hunger_progress_updated.connect(on_hunger_progress_updated)
	GameEvents.tongue_stuck.connect(on_tongue_stuck)

func on_tongue_stuck(is_tongue_stuck: bool) -> void:
	if is_tongue_stuck:
		tongue_stuck_dmg = 3.0
	else:
		tongue_stuck_dmg = 0

func on_timer_timeout() -> void:
	progress_bar.value -= (3 + tongue_stuck_dmg)
	GameEvents.emit_hunger_progress_updated(progress_bar.value)

func on_hunger_progress_updated(amount: float) -> void:
	progress_bar.value = amount