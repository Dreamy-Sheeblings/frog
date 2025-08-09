class_name Spider
extends Area2D

@onready var web_timer := $WebTimer

enum States {
	DESCEND,
	IDLE,
	WEB
}

var current_state = States.DESCEND # Start in DESCEND state

var start_position: Vector2 = position
var descend_duration: float = 1
var bounce_height: float = 10.0
var bounce_duration: float = 0.2

var web_shooted := false

func _ready() -> void:
	web_timer.timeout.connect(on_web_timer_timeout)
	drop_spider()

func _process(delta: float) -> void:
	match current_state:
		States.DESCEND:
			pass
		States.IDLE:
			web_timer.start()
		States.WEB:
			pass
		
func drop_spider() -> void:
	randomize()
	var descend_distance = randf_range(100, 180)
	var target_y = position.y + descend_distance
	var bounce_up_y = target_y - bounce_height
	var bounce_down_y = target_y + bounce_height
	var settle_y = target_y
	var tween := get_tree().create_tween()

	tween.tween_property(self, "position", Vector2(position.x, target_y), descend_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)

	# 2. Bounce up a little
	tween.tween_property(self, "position", Vector2(position.x, bounce_up_y), bounce_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "position", Vector2(position.x, bounce_down_y), bounce_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)

	# 3. Settle down
	tween.tween_property(self, "position", Vector2(position.x, settle_y), bounce_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)

	# 4. Final state
	tween.tween_callback(Callable(self, "_on_descend_finished"))

func _on_descend_finished() -> void:
	current_state = States.IDLE

func on_web_timer_timeout() -> void:
	current_state = States.WEB