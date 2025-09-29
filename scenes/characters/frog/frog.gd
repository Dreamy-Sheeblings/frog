class_name Frog
extends Node2D

@onready var tongue_target = $TongueTarget
@onready var tongue_cooldown_bar: TextureProgressBar = $TongueTarget/CooldownBar
@onready var anim_player: AnimationPlayer = $AnimPlayer
@onready var swallow_timer: Timer = $Timers/SwallowTimer
@onready var frog_sprite: Sprite2D = $Sprite
@onready var time_manager: Node = $TimeManager

var tongue_scene: PackedScene = preload("res://scenes/characters/frog/frog_tongue/frog_tongue.tscn")
var end_screen_scene: PackedScene = preload("res://scenes/user_interface/end_screen/end_screen.tscn")
@onready var tongue_list: Node2D = $TongueList

var time: float = 0
var lickable: bool = true
var multi_lickable: bool = false
var devour_combo_counter := 0
var hunger_point: float = 30
var combo_multiplier: float = 0.25
#Stats
const BASE_SHOOT_SPEED = 500
const BASE_RAGE_AMOUNT_INCREMENT = 5
var shoot_speed = BASE_SHOOT_SPEED
var base_swallow_time
const BASE_TONGUE_TOUGHNESS = 3.5
var tongue_toughness = BASE_TONGUE_TOUGHNESS
var tongue_stuck := false
var rage_amount_increment := 0
var rage_combo: bool = false
var sway_speed: float = 2.0
var tongue_piercing: bool = false
var died: bool = false
var cry_began: bool = false

enum States {
	SWAY,
	EAT,
	DIE
}

var current_state: States = States.SWAY

func _ready() -> void:
	GameEvents.frog_devour_something.connect(on_frog_devour_something)
	GameEvents.emit_hunger_progress_updated(hunger_point)
	GameEvents.hunger_progress_updated.connect(on_hunger_progress_updated)
	GameEvents.upgrade_added.connect(on_upgrade_added)
	GameEvents.tongue_stuck.connect(on_tongue_stuck)
	GameEvents.rage_active.connect(on_rage_activated)
	time_manager.difficulty_changed.connect(on_difficulty_changed)
	base_swallow_time = swallow_timer.wait_time
	swallow_timer.timeout.connect(on_swallow_timer_timeout)

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_accept") or event.is_action_pressed("left_click")) and lickable and current_state == States.SWAY:
		var tongue_instance = tongue_scene.instantiate() as FrogTongue
		tongue_list.add_child(tongue_instance)
		AudioManager.tongue_shoot_sfx.play()
		tongue_instance.global_position = tongue_target.global_position
		tongue_instance.rotation_degrees = tongue_target.rotation_degrees
		tongue_instance.shoot_speed = shoot_speed
		tongue_instance.toughness = tongue_toughness
		tongue_instance.rage_increase_amount = rage_amount_increment
		tongue_instance.pierced = tongue_piercing
		if not multi_lickable:
			current_state = States.EAT

func _process(delta: float) -> void:
	var tongue_cooldown_elapsed := swallow_timer.wait_time - swallow_timer.time_left
	var tongue_cooldown_progress := tongue_cooldown_elapsed / swallow_timer.wait_time
	tongue_cooldown_bar.value = tongue_cooldown_progress
	if tongue_list.get_child_count() > 0:
		if tongue_stuck:
			anim_player.play("stuck")
		else:
			anim_player.play("open_mouth")
	else:
		if not died:
			anim_player.play("idle")
		else:
			if not cry_began:
				anim_player.play("cry_begin")
	var cicada_buzz_sounds = get_tree().get_nodes_in_group("cicada_buzz") as Array[AudioStreamPlayer2D]
	for buzz_sound in cicada_buzz_sounds:
		if buzz_sound.playing:
			sway_speed = 4
			break
		else:
			sway_speed = 2
		
	match current_state:
		States.SWAY:
			tongue_target.visible = true
					
			time += delta
			var angle_degrees = sin(time * sway_speed) * 75.0
			tongue_target.rotation_degrees = angle_degrees

		States.EAT:
			tongue_target.visible = false
			lickable = false
			if tongue_list.get_child_count() == 0:
				current_state = States.SWAY
				swallow_timer.start()

func on_hunger_progress_updated(value: float) -> void:
	hunger_point = value
	if hunger_point > 0 and hunger_point <= 10:
		GameEvents.emit_death_warning(true)
	else:
		GameEvents.emit_death_warning(false)
	if hunger_point <= 0:
		GameEvents.emit_frog_died()
		current_state = States.DIE
		died = true
		disappear_tongue()
		for tongue in tongue_list.get_children():
			if tongue is FrogTongue:
				tongue.on_frog_died()
		anim_player.play("cry_begin")
		GameEvents.hunger_progress_updated.disconnect(on_hunger_progress_updated)

func play_cry_idle() -> void:
	anim_player.play("cry_idle")

func on_swallow_timer_timeout() -> void:
	lickable = true
	swallow_timer.stop()

func on_rage_activated(is_active: bool) -> void:
	if is_active:
		multi_lickable = true
	else:
		multi_lickable = false
		lickable = false
		swallow_timer.start()

func on_frog_devour_something(hunger_num: int, exp_point, combo_points) -> void:
	if hunger_num > 0:
		devour_combo_counter += combo_points
		GameEvents.emit_score_increased((hunger_num * 10) + (combo_points * combo_multiplier))
		hunger_point += hunger_num
		AudioManager.swallow_sfx.play()
		await get_tree().create_timer(0.5).timeout
		GameEvents.emit_hunger_progress_updated(hunger_point + (devour_combo_counter * combo_multiplier))
		GameEvents.emit_exp_increased(exp_point)
	else:
		if not multi_lickable or not rage_combo:
			devour_combo_counter = 0
	GameEvents.emit_devour_combo_text_updated(devour_combo_counter)

func on_upgrade_added(upgrade: Upgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "tongue_swift":
		var percent_increment = current_upgrades["tongue_swift"]["quantity"] * 0.2
		shoot_speed = BASE_SHOOT_SPEED * (1 + percent_increment)
	if upgrade.id == "tongue_pierce":
		tongue_piercing = true
	if upgrade.id == "gobble_up":
		var percent_reduction = current_upgrades["gobble_up"]["quantity"] * 0.15
		swallow_timer.wait_time = base_swallow_time * (1 - percent_reduction)
		swallow_timer.start()
	if upgrade.id == "mighty_tongue":
		var percent_increment = current_upgrades["mighty_tongue"]["quantity"] * 0.5
		tongue_toughness = BASE_TONGUE_TOUGHNESS * (1 + percent_increment)
	if upgrade.id == "acquire_rage":
		rage_amount_increment = BASE_RAGE_AMOUNT_INCREMENT
	if upgrade.id == "rage_combo":
		rage_combo = true
	if upgrade.id == "rage_amount":
		var percent_increment = current_upgrades["rage_amount"]["quantity"] * 0.5
		rage_amount_increment = BASE_RAGE_AMOUNT_INCREMENT * (1 + percent_increment)

func on_difficulty_changed(difficulty: int) -> void:
	if difficulty % 15 == 0:
		combo_multiplier = min(combo_multiplier + 0.25, 1.5)
		

func on_tongue_stuck(is_tongue_stuck: bool) -> void:
	tongue_stuck = is_tongue_stuck

func begin_cry():
	cry_began = true
	render_end_screen()

func disappear_tongue():
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(tongue_target, "scale", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(tongue_target, "modulate", Color(1, 1, 1, 0), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.chain()

func render_end_screen():
	AudioManager.lose_sfx.play()
	var end_screen = end_screen_scene.instantiate()
	add_child(end_screen)