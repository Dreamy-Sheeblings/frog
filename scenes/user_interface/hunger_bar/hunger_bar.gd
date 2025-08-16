extends CanvasLayer

@onready var progress_bar: TextureProgressBar = $HungerProgressBar
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	GameEvents.hunger_progress_updated.connect(on_hunger_progress_updated)

func on_timer_timeout() -> void:
	progress_bar.value -= 5

func on_hunger_progress_updated(amount: float) -> void:
	progress_bar.value = amount