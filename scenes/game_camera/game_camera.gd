extends Camera2D

func _ready() -> void:
	
	# Center the camera on the viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	global_position = viewport_size * 0.5