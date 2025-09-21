extends Node

@onready var play_button: Button = %PlayBtn
@onready var settings_button: Button = %SettingBtn
@onready var exit_button: Button = %ExitBtn

var settings_menu_scene: PackedScene = preload("res://scenes/user_interface/settings_menu/settings_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_button.pressed.connect(on_play_press)
	settings_button.pressed.connect(on_settings_pressed)
	exit_button.pressed.connect(on_exit_pressed)

func on_play_press() -> void:
	get_tree().paused = false
	AudioManager.click_sfx.play()
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func on_settings_pressed() -> void:
	AudioManager.pause_sfx.play()
	var settings_menu = settings_menu_scene.instantiate()
	add_child(settings_menu)

func on_exit_pressed() -> void:
	AudioManager.click_sfx.play()
	get_tree().quit()