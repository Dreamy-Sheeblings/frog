class_name Dragonfly
extends Area2D

@onready var anim_sprite: AnimatedSprite2D = $AnimSprite

var base_radius := 10.0 # Buzz radius (small for subtle wing noise)
var radius_jitter := 20.0
var buzz_speed := 6.0
var angle := 0.0

var center := Vector2.ZERO
var noise := FastNoiseLite.new()

var phase_offset := 0.0
var noise_seed_offset := 0.0

# Horizontal forward movement
var forward_speed := 120.0

# Vertical buzzing range
var vertical_range := 20.0 # How much up/down buzzing
var vertical_speed := 3.0 # Frequency of up/down buzzing

var view_rect: Rect2

func _ready() -> void:
	randomize()
	await get_tree().process_frame
	center = global_position
	if global_position.x > 0:
		forward_speed *= -1
		anim_sprite.flip_h = true
	# Noise setup
	phase_offset = randf_range(0.0, TAU)
	noise_seed_offset = randf_range(0.0, 1000.0)
	noise.seed = randi()
	noise.frequency = 0.8
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	get_tree().create_timer(10.0).timeout.connect(queue_free)

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
