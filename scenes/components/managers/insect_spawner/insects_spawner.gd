extends Node

const DIFFICULTY_INTERVAL = 5

@export var fly_scene: PackedScene
@export var spider_scene: PackedScene
@export var dragonfly_scene: PackedScene
@onready var difficult_timer: Timer = $DifficultyTimer
@onready var spawn_timer: Timer = $SpawnTimer

var view_rect: Rect2
var insect_table: WeightedTable = WeightedTable.new()
var difficulty: int = 0
var base_spawn_time = 0

const MARGIN := 15

func _ready() -> void:
	insect_table.add_item(fly_scene, 15)
	base_spawn_time = spawn_timer.wait_time
	randomize()
	view_rect = get_viewport().get_visible_rect()
	difficult_timer.timeout.connect(on_difficult_timer_timeout)
	spawn_timer.timeout.connect(on_spawn_timer_timeout)

func on_spawn_timer_timeout() -> void:
	spawn_timer.start()
	var insect_scene = insect_table.pick_item()
	var spawn_position = Vector2()
	var insect_instance = insect_scene.instantiate() as Node2D
	if insect_instance is Fly:
		var side = randi() % 3
		match side:
			0:
				spawn_position = Vector2(randf_range(view_rect.position.x, view_rect.end.x), -MARGIN)
			1:
				spawn_position = Vector2(-MARGIN, randf_range(view_rect.position.y, view_rect.end.y - 100))
			2:
				spawn_position = Vector2(view_rect.end.x + MARGIN, randf_range(view_rect.position.y, view_rect.end.y - 100))
	elif insect_instance is Spider:
		var index = randi_range(2, 14)
		spawn_position = Vector2(40 * index, -MARGIN)
	elif insect_instance is Dragonfly:
		var side = randi() % 2
		match side:
			0: # Left side only
				spawn_position = Vector2(-MARGIN, randf_range(view_rect.position.y, view_rect.end.y - 100))
			1: # Right side only
				spawn_position = Vector2(view_rect.end.x + MARGIN, randf_range(view_rect.position.y, view_rect.end.y - 100))
	
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(insect_instance)
	insect_instance.global_position = spawn_position

func on_difficult_timer_timeout() -> void:
	difficulty += 1
	match difficulty:
		3:
			insect_table.add_item(dragonfly_scene, 3)
		4:
			insect_table.add_item(spider_scene, 10)
	var time_off = (0.5 / 12) * difficulty
	time_off = min(time_off, 1.2)
	spawn_timer.wait_time = base_spawn_time - time_off
	spawn_timer.start()
