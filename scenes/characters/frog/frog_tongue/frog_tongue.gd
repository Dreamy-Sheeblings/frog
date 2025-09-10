class_name FrogTongue
extends Node2D

const VIEW_MARGIN := 30

@onready var line = $TongueLine
@onready var head = $TongueHead
@onready var head_cls = $TongueHead/Cls

var shoot_speed = 0
var toughness := 0
var rage_increase_amount = 0
var return_speed := 1000.0
var camera: Camera2D
var cam_shake_noise: FastNoiseLite

enum States {
	RELEASE_OUT,
	PULL_BACK,
	STUCK,
	DISAPPEAR
}

var view_rect: Rect2
var current_state = States.RELEASE_OUT
var original_position = Vector2.ZERO
var shoot_direction = Vector2.ZERO
var touch_area: Area2D
var ate_sth: bool = false
var eaten_points: int = 0
var exp_points: int = 0

func _ready() -> void:
	camera = get_node("/root/Main/GameCam")
	view_rect = get_viewport().get_visible_rect()
	cam_shake_noise = FastNoiseLite.new()
	head.area_entered.connect(on_head_area_entered)
	head.area_exited.connect(on_head_area_exited)
	original_position = head.position
	shoot_direction = Vector2.UP.rotated(head.rotation)

func on_head_area_entered(area: Area2D) -> void:
	if area.is_in_group("edibles") and not ate_sth:
		if current_state == States.STUCK:
			return
		AudioManager.tongue_hit_sfx.play()
		current_state = States.PULL_BACK
		GameEvents.emit_rage_increased(rage_increase_amount)
		ate_sth = true
		if area is Fly or area is FireFly:
			eaten_points = 5
			exp_points = 1
		elif area is Dragonfly:
			eaten_points = 7
			exp_points = 999999
		elif area is Spider:
			eaten_points = 10
			exp_points = 2
		area.queue_free()
	if area.is_in_group("stuck"):
		return_speed = 500
		GameEvents.emit_tongue_stuck(true)
		AudioManager.tongue_stuck_sfx.play()
		touch_area = area
		current_state = States.STUCK

func on_head_area_exited(area: Area2D) -> void:
	if area.is_in_group("stuck") and area == touch_area:
		current_state = States.PULL_BACK
		ate_sth = false

func _process(delta: float) -> void:
	line.points = [position - Vector2(0, 8), to_local(head_cls.global_position)]
	match current_state:
		States.RELEASE_OUT:
			head_cls.disabled = false
			var move = shoot_direction * shoot_speed * delta
			head.position += move
			var safe_rect := view_rect.grow(-VIEW_MARGIN)
			if not safe_rect.has_point(head.global_position):
				current_state = States.PULL_BACK
			
		States.PULL_BACK:
			GameEvents.emit_tongue_stuck(false)
			head_cls.disabled = true
			var to_origin = original_position - head.position
			var move = to_origin.normalized() * return_speed * delta
			if move.length() >= to_origin.length():
				head.position = original_position
				current_state = States.DISAPPEAR
			else:
				head.position += move

		States.STUCK:
			var target_pos = to_local(touch_area.global_position)
			var dir = (target_pos - head.position).normalized()
			head.position += dir * delta
			if Input.is_action_just_pressed("ui_accept"):
				AudioManager.tongue_pull_sfx.play()
				var out_stuck_move = shoot_direction * toughness
				head.position = head.position - out_stuck_move
				var shake_tween = create_tween()
				shake_tween.tween_method(shake, 8, 1, 0.5)

		States.DISAPPEAR:
			GameEvents.emit_frog_devour_something(eaten_points, exp_points)
			queue_free()

func shake(intensity) -> void:
	var cam_offset = cam_shake_noise.get_noise_1d(Time.get_ticks_msec()) * intensity
	camera.offset.x = cam_offset
	camera.offset.y = cam_offset
