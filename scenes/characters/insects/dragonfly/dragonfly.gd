class_name Dragonfly
extends Area2D

var base_radius := 10.0 # Buzz radius (small for subtle wing noise)
var radius_jitter := 20.0
var buzz_speed := 6.0
var angle := 0.0

var center := Vector2.ZERO
var noise := FastNoiseLite.new()

var phase_offset := 0.0
var noise_seed_offset := 0.0

# Horizontal forward movement
var forward_speed := 100.0

# Vertical buzzing range
var vertical_range := 20.0 # How much up/down buzzing
var vertical_speed := 3.0 # Frequency of up/down buzzing

func _ready() -> void:
	randomize()
	center = global_position

	# Noise setup
	phase_offset = randf_range(0.0, TAU)
	noise_seed_offset = randf_range(0.0, 1000.0)
	noise.seed = randi()
	noise.frequency = 0.8
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

func _process(delta: float) -> void:
	angle += delta * buzz_speed
	var t := Time.get_ticks_msec() / 1000.0

	# Move forward horizontally
	center.x += forward_speed * delta

	# Vertical buzzing motion
	var buzz_y = sin(t * vertical_speed + phase_offset) * vertical_range

	# Extra small jitter
	var jitter = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 1.0

	# Final position
	global_position = center + Vector2(0, buzz_y) + jitter
