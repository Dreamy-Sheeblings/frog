extends Node

@onready var progress_bar: TextureProgressBar = $ProgressBar

@onready var rage_timer: Timer = $RageTimer

const FULL_RAGE = 100

var raging: bool = false

func _ready() -> void:
	progress_bar.value = 0
	progress_bar.material.set_shader_parameter("percentage", 0)
	GameEvents.rage_increased.connect(on_rage_amount_increased)
	rage_timer.timeout.connect(on_rage_timer_timeout)

func on_rage_timer_timeout() -> void:
	raging = false
	AudioManager.rage_exit_sfx.play()
	set_rainbow_frog(0)
	GameEvents.emit_rage_active(false)

func _process(_delta: float) -> void:
	if raging:
		var rage_progress := rage_timer.time_left / rage_timer.wait_time
		render_rage_progress(rage_progress)

func on_rage_amount_increased(amount: float) -> void:
	var rage_value = progress_bar.value * FULL_RAGE + amount
	var rage_percentage = rage_value / FULL_RAGE
	render_rage_progress(rage_percentage)
	if rage_value >= FULL_RAGE and not raging:
		activate_rage_mode()

func activate_rage_mode() -> void:
	raging = true
	AudioManager.rage_enter_sfx.play()
	set_rainbow_frog(1)
	GameEvents.emit_rage_active(true)
	rage_timer.start()

func render_rage_progress(progress: float) -> void:
	progress_bar.value = progress
	progress_bar.material.set_shader_parameter("percentage", progress - 0.03)

func set_rainbow_frog(outline_size: float) -> void:
	var frog_node = get_tree().get_first_node_in_group("frog") as Frog
	if not frog_node:
		return
	frog_node.frog_sprite.material.set_shader_parameter("outline_size", outline_size)
