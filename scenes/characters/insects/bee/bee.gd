class_name Bee
extends Area2D

@onready var state_timer := $StateTimer
@onready var anim_sprite: AnimatedSprite2D = $AnimSprite

var alive: bool = false

var speed := 10.0 # Cap: 8

var center := Vector2.ZERO

var base_position: Vector2
var amplitude: float = 5.0 # how far up/down
var jitter_strength: float = 2.0 # optional tiny shake

enum States {
	FLY_IN,
	BUZZ,
	FLY,
	FLY_OUT,
	ANGRY
}

var current_state = States.FLY_IN
var fly_target: Vector2 = Vector2.ZERO
var viewport_rect: Rect2
var last_position := Vector2.ZERO

func _ready() -> void:
	randomize()
	last_position = global_position
	viewport_rect = get_viewport().get_visible_rect()
	state_timer.timeout.connect(_on_mode_timer_timeout)
	# Flying into the screen
	fly_target = get_random_fly_target_on_screen()
	GameEvents.frog_died.connect(on_life_timer_timeout)
	GameEvents.honey_comb_collected.connect(on_honey_comb_collected)

func on_honey_comb_collected(_honey_points: float) -> void:
	anim_sprite.play("angry")
	state_timer.stop()
	current_state = States.ANGRY

func charge_frog() -> void:
	anim_sprite.material.set_shader_parameter("flash_enabled", true)
	var timer = get_tree().create_timer(1.0, false, true) # ignore_time_scale = true
	timer.timeout.connect(func():
		var tween = create_tween()
		tween.tween_method(tween_charge.bind(global_position), 0.0, 1.0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
		tween.tween_callback(queue_free)
	)

	
func tween_charge(percent: float, start_pos: Vector2) -> void:
	var frog = get_tree().get_first_node_in_group("frog") as Node2D
	if frog == null:
		return
	
	global_position = start_pos.lerp(frog.global_position, percent)

func _process(delta: float) -> void:
	if current_state == States.ANGRY:
		var frog = get_tree().get_first_node_in_group("frog") as Node2D
		anim_sprite.flip_h = (frog.global_position.x > global_position.x)
	else:
		$AnimSprite.flip_h = (fly_target.x > center.x)
	if not alive:
		center = global_position
		alive = true
	else:
		var t := Time.get_ticks_msec() / 1000.0

		match current_state:
			States.FLY_IN:
				center = center.move_toward(fly_target, 60 * delta)
				if center.distance_to(fly_target) < 5.0:
					current_state = States.BUZZ
					_reset_timer()
			States.FLY:
				var to_target = fly_target - center
				if to_target.length() < 5.0:
					fly_target = get_random_fly_target_on_screen()
				else:
					center += to_target.normalized() * 40 * delta
			States.FLY_OUT:
				var to_target = fly_target - center
				if to_target.length() < 5.0:
					queue_free()
				else:
					center += to_target.normalized() * 40 * delta

		var offset_y = sin(t * speed) * amplitude
		var jitter = Vector2(randf_range(-jitter_strength, jitter_strength), 0)
		global_position = center + Vector2(0, offset_y) + jitter

func _on_mode_timer_timeout() -> void:
	# Toggle between BUZZ and FLY
	current_state = States.FLY if current_state == States.BUZZ else States.BUZZ
	_reset_timer()

func get_random_fly_target_on_screen() -> Vector2:
	return Vector2(
		randf_range(viewport_rect.position.x + 25, viewport_rect.end.x - 25),
		randf_range(viewport_rect.position.y + 25, viewport_rect.end.y - 200)
	)

func get_random_offscreen_position(margin: float = 50.0) -> Vector2:
	var side := randi() % 3 # 0=Top, 1=Right, 2=Bottom, 3=Left

	match side:
		0: # Top
			return Vector2(
				randf_range(viewport_rect.position.x, viewport_rect.end.x),
				viewport_rect.position.y - margin
			)
		1: # Right
			return Vector2(
				viewport_rect.end.x + margin,
				randf_range(viewport_rect.position.y, viewport_rect.end.y)
			)
		2: # Left
			return Vector2(
				viewport_rect.position.x - margin,
				randf_range(viewport_rect.position.y, viewport_rect.end.y)
			)
	return Vector2.ZERO # fallback

func on_life_timer_timeout() -> void:
	anim_sprite.play("normal")
	anim_sprite.material.set_shader_parameter("flash_enabled", false)
	state_timer.stop()
	fly_target = get_random_offscreen_position()
	current_state = States.FLY_OUT

func _reset_timer() -> void:
	state_timer.wait_time = randf_range(3.0, 5.0)
	state_timer.start()
