class_name Frog
extends Node2D

@onready var tongue_target = $TongueTarget
@onready var anim_sprite = $AnimSprite
@onready var swallow_timer: Timer = $Timers/SwallowTimer
@onready var rage_timer: Timer = $Timers/RageTimer
@onready var tongue_scene: PackedScene = preload("res://scenes/characters/frog/frog_tongue/frog_tongue.tscn")
@onready var tongue_list: Node2D = $TongueList

var time: float = 0
var lickable: bool = true
var multi_lickable: bool = false
var rage_amount := 0
var devour_combo_counter := 0
var hunger_point: float = 50

enum States {
	SWAY,
	EAT,
}

var current_state: States = States.SWAY

func _ready() -> void:
	GameEvents.rage_increased.connect(on_rage_increased)
	GameEvents.frog_devour_something.connect(on_frog_devour_something)
	GameEvents.emit_hunger_progress_updated(hunger_point)
	swallow_timer.timeout.connect(on_swallow_timer_timeout)
	rage_timer.timeout.connect(on_rage_timer_timeout)

func _process(delta: float) -> void:
	if tongue_list.get_child_count() > 0:
		anim_sprite.play("mouth_opened")
	else:
		anim_sprite.play("idle")
	match current_state:
		States.SWAY:
			tongue_target.visible = true
			if Input.is_action_just_pressed("ui_accept") and lickable:
				var tongue_instance = tongue_scene.instantiate() as Node2D
				tongue_list.add_child(tongue_instance)
				tongue_instance.global_position = tongue_target.global_position
				tongue_instance.rotation_degrees = tongue_target.rotation_degrees
				if not multi_lickable:
					current_state = States.EAT
					
			time += delta
			var angle_degrees = sin(time * 2.0) * 60.0
			tongue_target.rotation_degrees = angle_degrees

		States.EAT:
			tongue_target.visible = false
			lickable = false
			if tongue_list.get_child_count() == 0:
				current_state = States.SWAY
				swallow_timer.start()


func on_swallow_timer_timeout() -> void:
	lickable = true

func on_rage_timer_timeout() -> void:
	rage_timer.stop()
	multi_lickable = false
	lickable = false
	rage_amount = 0
	GameEvents.emit_rage_amount_updated(rage_amount)

func on_rage_increased(number: int) -> void:
	rage_amount += number
	GameEvents.emit_rage_amount_updated(rage_amount)
	if rage_amount >= 100 and not multi_lickable:
		multi_lickable = true
		rage_timer.start()

func on_frog_devour_something(number: int) -> void:
	if number == 1:
		devour_combo_counter += 1
		hunger_point += 15
		GameEvents.emit_hunger_progress_updated(hunger_point)
	else:
		if not multi_lickable:
			devour_combo_counter = 0
	GameEvents.emit_devour_combo_text_updated(devour_combo_counter)
