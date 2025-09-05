class_name Frog
extends Node2D

@onready var tongue_target = $TongueTarget
@onready var tongue_cooldown_bar: TextureProgressBar = $TongueTarget/CooldownBar
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

#Stats
const BASE_SHOOT_SPEED = 500
var shoot_speed = BASE_SHOOT_SPEED
var base_swallow_time
const BASE_TONGUE_TOUGHNESS = 3.5
var tongue_toughness = BASE_TONGUE_TOUGHNESS

enum States {
	SWAY,
	EAT,
	DIE
}

var current_state: States = States.SWAY

func _ready() -> void:
	GameEvents.rage_increased.connect(on_rage_increased)
	GameEvents.frog_devour_something.connect(on_frog_devour_something)
	GameEvents.emit_hunger_progress_updated(hunger_point)
	GameEvents.hunger_progress_updated.connect(on_hunger_progress_updated)
	GameEvents.upgrade_added.connect(on_upgrade_added)
	base_swallow_time = swallow_timer.wait_time
	swallow_timer.timeout.connect(on_swallow_timer_timeout)
	rage_timer.timeout.connect(on_rage_timer_timeout)

func _process(delta: float) -> void:
	var tongue_cooldown_elapsed := swallow_timer.wait_time - swallow_timer.time_left
	var tongue_cooldown_progress := tongue_cooldown_elapsed / swallow_timer.wait_time
	tongue_cooldown_bar.value = tongue_cooldown_progress
	if tongue_list.get_child_count() > 0:
		if anim_sprite.animation != "mouth_opened":
			anim_sprite.play("mouth_opened")
	else:
		if anim_sprite.animation != "idle":
			anim_sprite.play("idle")
	match current_state:
		States.SWAY:
			tongue_target.visible = true
			if Input.is_action_just_pressed("ui_accept") and lickable:
				var tongue_instance = tongue_scene.instantiate() as FrogTongue
				tongue_list.add_child(tongue_instance)
				AudioManager.tongue_shoot_sfx.play()
				tongue_instance.global_position = tongue_target.global_position
				tongue_instance.rotation_degrees = tongue_target.rotation_degrees
				tongue_instance.shoot_speed = shoot_speed
				tongue_instance.toughness = tongue_toughness
				if not multi_lickable:
					current_state = States.EAT
					
			time += delta
			var angle_degrees = sin(time * 2.0) * 75.0
			tongue_target.rotation_degrees = angle_degrees

		States.EAT:
			tongue_target.visible = false
			lickable = false
			if tongue_list.get_child_count() == 0:
				current_state = States.SWAY
				swallow_timer.start()

		States.DIE:
			queue_free()

func on_hunger_progress_updated(value: float) -> void:
	hunger_point = value
	if hunger_point > 0 and hunger_point <= 10:
		GameEvents.emit_death_warning(true)
	else:
		GameEvents.emit_death_warning(false)
	if hunger_point <= 0:
		print("frog died")
		current_state = States.DIE
	if hunger_point >= 100:
		print("win")

func on_swallow_timer_timeout() -> void:
	lickable = true
	swallow_timer.stop()

func on_rage_timer_timeout() -> void:
	AudioManager.rage_exit_sfx.play()
	set_rainbow_shader(0)
	rage_timer.stop()
	multi_lickable = false
	lickable = false
	rage_amount = 0
	GameEvents.emit_rage_amount_updated(rage_amount)
	swallow_timer.start()

func on_rage_increased(number: int) -> void:
	rage_amount += number
	GameEvents.emit_rage_amount_updated(rage_amount)
	if rage_amount >= 100 and not multi_lickable:
		AudioManager.rage_enter_sfx.play()
		set_rainbow_shader(1)
		multi_lickable = true
		rage_timer.start()

func on_frog_devour_something(hunger_num: int, exp_point: ) -> void:
	if hunger_num > 0:
		devour_combo_counter += 1
		hunger_point += hunger_num
		AudioManager.swallow_sfx.play()
		await get_tree().create_timer(0.5).timeout
		GameEvents.emit_hunger_progress_updated(hunger_point + (devour_combo_counter * 0.25))
		GameEvents.emit_exp_increased(exp_point)
	else:
		if not multi_lickable:
			devour_combo_counter = 0
	GameEvents.emit_devour_combo_text_updated(devour_combo_counter)

func set_rainbow_shader(outline_size: float) -> void:
	anim_sprite.material.set_shader_parameter("outline_size", outline_size)

func on_upgrade_added(upgrade: Upgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "tongue_swift":
		var percent_increment = current_upgrades["tongue_swift"]["quantity"] * 0.2
		shoot_speed = BASE_SHOOT_SPEED * (1 + percent_increment)
	if upgrade.id == "gobble_up":
		var percent_reduction = current_upgrades["gobble_up"]["quantity"] * 0.15
		swallow_timer.wait_time = base_swallow_time * (1 - percent_reduction)
		swallow_timer.start()
	if upgrade.id == "mighty_tongue":
		var percent_increment = current_upgrades["mighty_tongue"]["quantity"] * 0.5
		tongue_toughness = BASE_TONGUE_TOUGHNESS * (1 + percent_increment)
