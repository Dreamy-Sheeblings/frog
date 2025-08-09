extends Node

@export var fly_scene: PackedScene

const MARGIN := 15

func _ready() -> void:
	$Timer.timeout.connect(on_timer_timeout)

func on_timer_timeout() -> void:
	var viewport_rect = get_viewport().get_visible_rect()
	var side = randi() % 3
	var spawn_position = Vector2()

	match side:
		0:
			spawn_position = Vector2(randf_range(viewport_rect.position.x, viewport_rect.end.x), -MARGIN)
		1:
			spawn_position = Vector2(-MARGIN, randf_range(viewport_rect.position.y, viewport_rect.end.y - 100))
		2:
			spawn_position = Vector2(viewport_rect.end.x + MARGIN, randf_range(viewport_rect.position.y, viewport_rect.end.y - 100))
	
	var fly_instance = fly_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(fly_instance)
	fly_instance.global_position = spawn_position
