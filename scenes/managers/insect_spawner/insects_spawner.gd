extends Node

const DIFFICULTY_INTERVAL = 5

@export var round_time_manager: Node

@export var fly_scene: PackedScene
@export var firefly_scene: PackedScene
@export var spider_scene: PackedScene
@export var dragonfly_scene: PackedScene
@export var cicada_scene: PackedScene
@export var bee_scene: PackedScene

var honey_comb_scene: PackedScene = preload("res://scenes/objects/honey_comb/honey_comb.tscn")

@onready var spawn_timer: Timer = $SpawnTimer
@onready var bee_charge_timer: Timer = $BeeChargeTimer

var view_rect: Rect2
var insect_table: WeightedTable = WeightedTable.new()
const FLY_SPEED_CAP = 8
const FLY_SPEED_GROWTH = 0.25
var fly_speed: float = 4.0
var base_spawn_time = 0
var spawn_rate = 1
var raining = false
var first_spawn = false


const MARGIN := 15

func _ready() -> void:
	insect_table.add_item(fly_scene, 18)
	base_spawn_time = spawn_timer.wait_time
	randomize()
	GameEvents.storm_casted.connect(on_storm_casted)
	GameEvents.frog_died.connect(on_frog_died)
	GameEvents.honey_comb_collected.connect(on_honey_comb_collected)
	view_rect = get_viewport().get_visible_rect()
	round_time_manager.difficulty_changed.connect(on_difficult_timer_timeout)
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	bee_charge_timer.timeout.connect(on_bee_charge_timer_timeout)

func on_storm_casted(is_stormy: bool) -> void:
	if is_stormy:
		insect_table.add_item(firefly_scene, 20)
		insect_table.remove_item(cicada_scene)
		raining = true
	else:
		insect_table.remove_item(firefly_scene)
		insect_table.add_item(cicada_scene, 8)
		raining = false

func on_frog_died() -> void:
	spawn_timer.stop()

func on_spawn_timer_timeout() -> void:
	if not first_spawn:
		var saved_highscore: HighScore = load("res://resources/meta/high_score.tres")
		if not saved_highscore.tutorial_shown:
			print("showing tutorial")
			var tutorial_instance = preload("res://scenes/user_interface/tutorial/tutorial.tscn")
			var tutorial = tutorial_instance.instantiate()
			add_child(tutorial)
			var new_highscore = HighScore.new()
			new_highscore.value = saved_highscore.value
			new_highscore.tutorial_shown = true
			ResourceSaver.save(new_highscore, "res://resources/meta/high_score.tres")
		first_spawn = true
	spawn_timer.start()
	for i in range(spawn_rate):
		var insect_scene = insect_table.pick_item()
		var spawn_position = Vector2()
		
		var insect_instance = insect_scene.instantiate() as Node2D
		if insect_instance is Fly or insect_instance is FireFly or insect_instance is Cicada or insect_instance is Bee:
			if insect_instance is Bee:
				var object_layer = get_tree().get_first_node_in_group("objects_layer")
				var honey_comb_instance = honey_comb_scene.instantiate()
				object_layer.add_child(honey_comb_instance)
				var random_target = get_random_target_on_screen()
				honey_comb_instance.global_position = random_target
			spawn_position = spawn_random()
		elif insect_instance is Spider:
			var index = randi_range(2, 14)
			spawn_position = Vector2(40 * index, -MARGIN)
		elif insect_instance is Dragonfly:
			var side = randi() % 2
			match side:
				0:
					spawn_position = get_random_spawn_position_from_side(Sides.LEFT, raining)
				1:
					spawn_position = get_random_spawn_position_from_side(Sides.RIGHT, raining)
		
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		if insect_instance is Bee:
			for bee_count in range(2):
				var another_insect_instance = insect_scene.instantiate() as Node2D
				entities_layer.add_child(another_insect_instance)
				another_insect_instance.global_position = spawn_random()

		entities_layer.add_child(insect_instance)
		insect_instance.global_position = spawn_position
		if insect_instance is Fly:
			insect_instance.speed = fly_speed

func on_difficult_timer_timeout(difficulty: int) -> void:
	if difficulty % 5 == 0:
		fly_speed = min(fly_speed + FLY_SPEED_GROWTH, FLY_SPEED_CAP)
	match difficulty:
		2:
			insect_table.add_item(dragonfly_scene, 2)
		3:
			insect_table.add_item(spider_scene, 12)
		4:
			insect_table.add_item(cicada_scene, 13)
		6:
			insect_table.add_item(bee_scene, 15)
		50:
			spawn_rate = 2
		90:
			spawn_rate = 3
	var time_off = (1. / 12) * difficulty
	time_off = min(time_off, 0.5)
	spawn_timer.wait_time = base_spawn_time - time_off
	spawn_timer.start()

enum Sides {
	LEFT,
	RIGHT,
	TOP
}

func spawn_random() -> Vector2:
	var spawn_position = Vector2()
	var side = randi() % 3
	match side:
		0:
			spawn_position = get_random_spawn_position_from_side(Sides.TOP)
		1:
			spawn_position = get_random_spawn_position_from_side(Sides.RIGHT)
		2:
			spawn_position = get_random_spawn_position_from_side(Sides.LEFT)

	return spawn_position

func get_random_spawn_position_from_side(side: Sides, is_rain: bool = false) -> Vector2:
	var max_height = 25
	if is_rain:
		max_height = 120
	match side:
		Sides.LEFT:
			return Vector2(-MARGIN, randf_range(view_rect.position.y + max_height, view_rect.end.y - 200))
		Sides.RIGHT:
			return Vector2(view_rect.end.x + MARGIN, randf_range(view_rect.position.y + max_height, view_rect.end.y - 200))
		Sides.TOP:
			return Vector2(randf_range(view_rect.position.x, view_rect.end.x), -MARGIN)

	return Vector2.ZERO

func get_random_target_on_screen() -> Vector2:
	return Vector2(
		randf_range(view_rect.position.x + 75, view_rect.end.x - 75),
		randf_range(view_rect.position.y + 75, view_rect.end.y - 200)
	)

func on_honey_comb_collected(_honey_points: float) -> void:
	if bee_charge_timer.is_stopped():
		bee_charge_timer.start()
		

func on_bee_charge_timer_timeout() -> void:
	var bees = get_tree().get_nodes_in_group("bees")
	if bees.size() == 0:
		bee_charge_timer.stop()
		return
	var bee = get_tree().get_first_node_in_group("bees") as Bee
	if bee.current_state != Bee.States.ANGRY:
		return
	bee.charge_frog()
