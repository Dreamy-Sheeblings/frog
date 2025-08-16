extends CanvasLayer

@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar

func _ready() -> void:
	progress_bar.value = 0
	GameEvents.rage_amount_updated.connect(on_rage_amount_updated)

func on_rage_amount_updated(amount: int) -> void:
	progress_bar.value = amount