extends Area2D

@onready var life_timer: Timer = $LifeTimer

var speed := 80.0
var noise := FastNoiseLite.new()
var noise_offset := 0.0

var change_dir_timer := 0.0
var dir_change_interval := 1.5

var direction := Vector2.RIGHT
var hover_center := Vector2.ZERO
var hover_radius := 100.0

var viewport_rect: Rect2
var pollinate_target: Node = null

var pollinate_yet: bool = false

enum States {
	BEE_IN,
	BEE_OUT,
	HOVER,
	FLY_TO_FLOWER,
	BEE_POLLINATE
}

var current_state = States.BEE_IN

func _ready() -> void:
	randomize()
	viewport_rect = get_viewport().get_visible_rect()
	life_timer.timeout.connect(on_life_timer_timeout)
	# Pick hover center inside viewport
	hover_center = Vector2(
		randf_range(viewport_rect.position.x + 100, viewport_rect.end.x - 100),
		randf_range(viewport_rect.position.y + 100, viewport_rect.end.y - 150)
	)

	# Noise setup
	noise.seed = randi()
	noise.frequency = 1.5
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

func _process(delta: float) -> void:
	match current_state:
		States.BEE_IN:
			var to_target = hover_center - global_position
			if to_target.length() > 5.0:
				global_position += to_target.normalized() * speed * delta
				rotation = to_target.angle()
			else:
				current_state = States.HOVER
				life_timer.start()
				change_dir_timer = 0.0

		States.HOVER:
			_hover_behavior(delta)

		States.BEE_POLLINATE:
			pollinate_yet = true

		States.FLY_TO_FLOWER:
			if pollinate_target and pollinate_target.is_inside_tree():
				var flower_pos = pollinate_target.global_position - Vector2(0, 40)
				if global_position.distance_to(flower_pos) <= 1:
					current_state = States.BEE_POLLINATE
				else:
					var to_target = flower_pos - global_position
					global_position += to_target.normalized() * speed * delta
			else:
				current_state = States.BEE_OUT

		States.BEE_OUT:
			global_position += direction * speed * delta
			rotation = direction.angle()
			

func _hover_behavior(delta: float) -> void:
	noise_offset += delta * 1.5
	change_dir_timer -= delta
	if change_dir_timer <= 0.0:
		direction = direction.rotated(randf_range(-0.5, 0.5)).normalized()
		change_dir_timer = randf_range(dir_change_interval * 0.7, dir_change_interval * 1.3)

	if global_position.distance_to(hover_center) > hover_radius:
		direction = (hover_center - global_position).normalized()

	var wobble_x = noise.get_noise_1d(noise_offset) * 30.0
	var wobble_y = noise.get_noise_1d(noise_offset + 100.0) * 30.0

	global_position += (direction * speed * delta) + Vector2(wobble_x, wobble_y) * delta
	rotation = direction.angle()

func on_life_timer_timeout() -> void:
	if pollinate_yet:
		current_state = States.BEE_OUT
		return

	var flowers = get_tree().get_nodes_in_group("flower")
	if flowers.size() > 0:
		pollinate_target = flowers[randi() % flowers.size()]
		current_state = States.FLY_TO_FLOWER