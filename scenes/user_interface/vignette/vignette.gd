extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.death_warning.connect(on_death_warning)

func on_death_warning(warn: bool) -> void:
	if warn:
		$AnimPlayer.play("death_warn")
	else:
		$AnimPlayer.play("RESET")
