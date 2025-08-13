class_name Frog
extends Node2D

@onready var tongue_target = $TongueTarget
@onready var anim_sprite = $AnimSprite
@onready var swallow_timer: Timer = $SwallowTimer
@onready var tongue_scene: PackedScene = preload("res://characters/frog/frog_tongue/frog_tongue.tscn")
@onready var tongue_list: Node2D = $TongueList

var time: float = 0
var lickable: bool = true
var multi_lickable: bool = false

enum States {
	SWAY,
	EAT,
}

var current_state: States = States.SWAY

func _ready() -> void:
	swallow_timer.timeout.connect(on_swallow_timer_timeout)

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
