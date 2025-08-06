class_name Fly
extends Area2D

@onready var state_timer := $StateTimer

var alive: bool = false
var base_radius := 20.0
var radius_jitter := 5.0

var speed := 4.0
var angle := 0.0

var center := Vector2.ZERO
var noise := FastNoiseLite.new()

var phase_offset := 0.0
var noise_seed_offset := 0.0

enum States {
	FLY_IN,
	BUZZ,
	FLY,
	FLY_OUT,
}

var current_state = States.FLY_IN
var fly_target: Vector2 = Vector2.ZERO
var viewport_rect: Rect2

func _ready() -> void:
	randomize()

	viewport_rect = get_viewport().get_visible_rect()
	state_timer.timeout.connect(_on_mode_timer_timeout)
	# Buzzing init
	phase_offset = randf_range(0.0, TAU)
	noise_seed_offset = randf_range(0.0, 1000.0)
	noise.seed = randi()
	noise.frequency = 0.8
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	# Flying into the screen
	fly_target = Vector2(
		randf_range(viewport_rect.position.x, viewport_rect.end.x),
		randf_range(viewport_rect.position.y, viewport_rect.end.y - 120)
	)

func _process(delta: float) -> void:
	if not alive:
		center = global_position
		alive = true
		
	else:
		angle += delta * speed
		var t := Time.get_ticks_msec() / 1000.0

		match current_state:
			States.FLY_IN:
				center = center.move_toward(fly_target, 40 * delta)
				if center.distance_to(fly_target) < 5.0:
					current_state = States.BUZZ
					_reset_timer()
			States.FLY:
				var to_target = fly_target - center
				if to_target.length() < 5.0:
					fly_target = Vector2(
									randf_range(viewport_rect.position.x + 25, viewport_rect.end.x - 25),
									randf_range(viewport_rect.position.y + 25, viewport_rect.end.y - 120)
								)
				else:
					center += to_target.normalized() * 40 * delta

		var jittered_radius = base_radius + noise.get_noise_1d(t + noise_seed_offset) * radius_jitter
		var offset_x = cos(angle + phase_offset) * jittered_radius
		var offset_y = sin((angle + phase_offset) * 1.3) * jittered_radius * 0.6
		var jitter = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 2.0

		global_position = center + Vector2(offset_x, offset_y) + jitter
		rotation = noise.get_noise_1d(t + 999 + noise_seed_offset) * 0.5

func _on_mode_timer_timeout() -> void:
	# Toggle between BUZZ and FLY
	current_state = States.FLY if current_state == States.BUZZ else States.BUZZ
	_reset_timer()

func _reset_timer() -> void:
	state_timer.wait_time = randf_range(3.0, 5.0)
	state_timer.start()
