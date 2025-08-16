class_name FrogTongue
extends Node2D

@onready var line = $TongueLine
@onready var head = $TongueHead
@onready var head_cls = $TongueHead/Cls

var shoot_speed = 800.0
var return_speed := 1000.0

enum States {
	RELEASE_OUT,
	PULL_BACK,
	STUCK,
	DISAPPEAR
}

var current_state = States.RELEASE_OUT
var original_position = Vector2.ZERO
var shoot_direction = Vector2.ZERO
var traveled_distance := 0.0
var max_distance := 310.0
var stuck_area: Area2D
var ate_sth: bool = false

func _ready() -> void:
	head.area_entered.connect(on_head_area_entered)
	head.area_exited.connect(on_head_area_exited)
	original_position = head.position
	shoot_direction = Vector2.UP.rotated(head.rotation)

func on_head_area_entered(area: Area2D) -> void:
	if area.is_in_group("edibles"):
		if current_state == States.STUCK:
			return
		current_state = States.PULL_BACK
		GameEvents.emit_rage_increased(5)
		ate_sth = true
		area.queue_free()
	if area.is_in_group("stuck"):
		stuck_area = area
		current_state = States.STUCK

func on_head_area_exited(area: Area2D) -> void:
	if area.is_in_group("stuck") and area == stuck_area:
		stuck_area.queue_free()
		current_state = States.PULL_BACK

func _process(delta: float) -> void:
	line.points = [position - Vector2(0, 8), to_local(head_cls.global_position)]
	match current_state:
		States.RELEASE_OUT:
			head_cls.disabled = false
			var move = shoot_direction * shoot_speed * delta
			head.position += move
			traveled_distance += move.length()
			if traveled_distance >= max_distance:
				current_state = States.PULL_BACK
			
		States.PULL_BACK:
			head_cls.disabled = true
			var to_origin = original_position - head.position
			var move = to_origin.normalized() * return_speed * delta
			if move.length() >= to_origin.length():
				head.position = original_position
				current_state = States.DISAPPEAR
			else:
				head.position += move

		States.STUCK:
			if Input.is_action_just_pressed("ui_accept"):
				var out_stuck_move = shoot_direction * 10
				head.position = head.position - out_stuck_move

		States.DISAPPEAR:
			if ate_sth:
				GameEvents.emit_frog_devour_something(1)
			else:
				GameEvents.emit_frog_devour_something(0)
			queue_free()
