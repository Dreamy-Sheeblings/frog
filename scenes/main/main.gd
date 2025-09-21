extends Node

@onready var pause_button: TextureButton = %PauseButton

var pause_menu_scene: PackedScene = preload("res://scenes/user_interface/pause_menu/pause_menu.tscn")

func _ready() -> void:
	pause_button.pressed.connect(on_pause_pressed)
	GameEvents.frog_died.connect(on_frog_died)

func on_frog_died() -> void:
	pause_button.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		open_pause_menu()
		get_tree().root.set_input_as_handled()

func open_pause_menu() -> void:
	AudioManager.pause_sfx.play()
	var pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)

func on_pause_pressed() -> void:
	open_pause_menu()