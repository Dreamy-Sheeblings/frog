extends Node

@export var fly_scene: PackedScene
@export var spider_scene: PackedScene

@onready var fly_timer: Timer = $FlyTimer
@onready var spider_timer: Timer = $SpiderTimer
@onready var difficult_timer: Timer = $DifficultyTimer

var view_rect: Rect2

var level := 1

const MARGIN := 15

func _ready() -> void:
	randomize()
	view_rect = get_viewport().get_visible_rect()
	fly_timer.timeout.connect(on_fly_timer_timeout)
	spider_timer.timeout.connect(on_spider_timer_timeout)
	difficult_timer.timeout.connect(on_difficult_timer_timeout)
	difficult_timer.start()
	fly_timer.start()

func on_fly_timer_timeout() -> void:
	var side = randi() % 3
	var spawn_position = Vector2()

	match side:
		0:
			spawn_position = Vector2(randf_range(view_rect.position.x, view_rect.end.x), -MARGIN)
		1:
			spawn_position = Vector2(-MARGIN, randf_range(view_rect.position.y, view_rect.end.y - 100))
		2:
			spawn_position = Vector2(view_rect.end.x + MARGIN, randf_range(view_rect.position.y, view_rect.end.y - 100))
	
	var fly_instance = fly_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(fly_instance)
	fly_instance.global_position = spawn_position

func on_spider_timer_timeout() -> void:
	var index = randi_range(1, 15)
	var spawn_position = Vector2(40 * index, -MARGIN)
	var spider_instance = spider_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(spider_instance)
	spider_instance.global_position = spawn_position
	spider_instance.position = spawn_position

func on_difficult_timer_timeout() -> void:
	level += 1
	match level:
		2:
			spider_timer.start()
