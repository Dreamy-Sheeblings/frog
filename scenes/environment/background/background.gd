extends ParallaxBackground

const CLOUD_SPEED := 5

@onready var cloud_layer: ParallaxLayer = $Cloud

func _process(delta: float) -> void:
	cloud_layer.motion_offset.x -= CLOUD_SPEED * delta
