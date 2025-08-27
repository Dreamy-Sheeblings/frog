extends CanvasLayer

@export var upgrade_manager: Node
@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar

func _ready() -> void:
	progress_bar.value = 0
	upgrade_manager.exp_updated.connect(on_exp_updated)

func on_exp_updated(current_exp: float, target_exp: float) -> void:
	var percent = current_exp / target_exp
	progress_bar.value = percent