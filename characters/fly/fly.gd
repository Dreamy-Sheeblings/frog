class_name Fly
extends Area2D

var base_radius := 20.0
var radius_jitter := 5.0

var speed := 4.0
var angle := 0.0

var center := Vector2.ZERO
var noise := FastNoiseLite.new()

var phase_offset := 0.0
var noise_seed_offset := 0.0

func _ready() -> void:
	randomize()
	center = global_position
	phase_offset = randf_range(0.0, TAU) # Random start angle
	noise_seed_offset = randf_range(0.0, 1000.0) # Offset into the noise timeline
	noise.seed = randi()
	noise.frequency = 0.8
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

func _process(delta: float) -> void:

	angle += delta * speed

	var t := Time.get_ticks_msec() / 1000.0

	# Desynced noise
	var jittered_radius = base_radius + noise.get_noise_1d(t + noise_seed_offset) * radius_jitter

	# Elliptical motion with desynced angle
	var offset_x = cos(angle + phase_offset) * jittered_radius
	var offset_y = sin((angle + phase_offset) * 1.3) * jittered_radius * 0.6

	var jitter = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 2.0

	global_position = center + Vector2(offset_x, offset_y) + jitter
	
	rotation = noise.get_noise_1d(t + 999 + noise_seed_offset) * 0.5
