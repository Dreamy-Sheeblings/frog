class_name HoneyComb
extends Area2D

@onready var cls: CollisionShape2D = $Cls
@onready var sprite: Sprite2D = $Sprite
@onready var duplicate_timer: Timer = $DuplicateTimer
@onready var grow_timer: Timer = $GrowTimer

var honey_points := 0.5
var view_rect: Rect2

func _ready() -> void:
	view_rect = get_viewport().get_visible_rect()
	GameEvents.frog_died.connect(disappear)
	scale = Vector2.ZERO

	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	var duplicate_comb = randi_range(1, 3)
	if duplicate_comb == 1:
		duplicate_timer.start()

	duplicate_timer.timeout.connect(duplicate_honey_comb)
	grow_timer.timeout.connect(on_grow)

func duplicate_honey_comb() -> void:
	duplicate_timer.stop()
	var bee = get_tree().get_first_node_in_group("bees")
	if bee == null:
		return
	var honey_comb_instance = preload("res://scenes/objects/honey_comb/honey_comb.tscn").instantiate()
	get_parent().add_child(honey_comb_instance)
	var random_target = get_random_target_on_screen()
	honey_comb_instance.global_position = random_target

func on_grow():
	grow_timer.stop()
	var scale_tween = create_tween()
	scale_tween.set_parallel()
	scale_tween.tween_property(sprite, "scale", Vector2(2, 2), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	scale_tween.tween_property(cls, "scale", Vector2(2, 2), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	scale_tween.chain()
	honey_points = 8

func disappear() -> void:
	var disappear_tween = create_tween()
	disappear_tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	disappear_tween.tween_callback(queue_free)

func disable_cls() -> void:
	cls.disabled = true

func be_collected() -> void:
	Callable(disable_cls).call_deferred()
	GameEvents.emit_honey_comb_collected(honey_points)
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, .5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", Vector2.ZERO, .5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.chain()

	tween.tween_callback(queue_free)

func tween_collect(percent: float, start_pos: Vector2) -> void:
	var frog = get_tree().get_first_node_in_group("frog") as Node2D
	if frog == null:
		return
	
	global_position = start_pos.lerp(frog.global_position, percent)

	var dir_from_start = frog.global_position - start_pos
	var target_rotation = dir_from_start.angle() + deg_to_rad(90)

	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time()))


func get_random_target_on_screen() -> Vector2:
	return Vector2(
		randf_range(view_rect.position.x + 50, view_rect.end.x - 50),
		randf_range(view_rect.position.y + 50, view_rect.end.y - 200)
	)