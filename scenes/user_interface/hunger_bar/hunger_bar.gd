extends Node

@onready var progress_bar: TextureProgressBar = $HungerProgressBar
@onready var timer: Timer = $Timer
@onready var difficulty_timer: Timer = $DifficultyTimer

const FULL_HUNGER = 100
const SHADER_RATE = 0.03

var tongue_stuck_dmg = 0
var tongue_stuck_reduction: float = 0.0
var hunger_reduction: float = 0.25

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	difficulty_timer.timeout.connect(on_difficulty_timer_timeout)
	GameEvents.hunger_progress_updated.connect(on_hunger_progress_updated)
	GameEvents.tongue_stuck.connect(on_tongue_stuck)

func on_tongue_stuck(is_tongue_stuck: bool) -> void:
	if is_tongue_stuck:
		tongue_stuck_reduction = tongue_stuck_dmg
	else:
		tongue_stuck_reduction = 0

func on_timer_timeout() -> void:
	render_hunger_progress(progress_bar.value - (hunger_reduction + tongue_stuck_reduction))
	GameEvents.emit_hunger_progress_updated(progress_bar.value)

func on_difficulty_timer_timeout() -> void:
	tongue_stuck_dmg = min(tongue_stuck_dmg + 0.15, 3)
	hunger_reduction = min(hunger_reduction + 0.15, 5)


func on_hunger_progress_updated(amount: float) -> void:
	render_hunger_progress(amount)

func render_hunger_progress(progress: float) -> void:
	progress_bar.value = progress
	progress_bar.material.set_shader_parameter("percentage", progress / FULL_HUNGER - SHADER_RATE)