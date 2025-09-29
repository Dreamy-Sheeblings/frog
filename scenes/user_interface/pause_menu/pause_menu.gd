extends CanvasLayer

@onready var panel: PanelContainer = %Panel

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var window_button: Button = %WinModeToggleButton

@onready var resume_button: TextureButton = %ResumeButton
@onready var replay_button: TextureButton = %ReplayButton
@onready var quit_button: TextureButton = %QuitButton

var is_closing: bool = false

func _ready() -> void:
	get_tree().paused = true

	panel.pivot_offset = panel.size / 2

	window_button.pressed.connect(on_window_button_toggled)
	music_slider.value_changed.connect(on_audio_slider_changed.bind("music"))
	sfx_slider.value_changed.connect(on_audio_slider_changed.bind("sfx"))

	update_display()

	resume_button.pressed.connect(on_resume_pressed)
	replay_button.pressed.connect(on_replay_pressed)
	quit_button.pressed.connect(on_quit_pressed)

	$AnimPlayer.play("default")
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel, "scale", Vector2.ONE, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func update_display():
	window_button.text = "Windowed"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_button.text = "Fullscreen"
	sfx_slider.value = get_bus_volume_percent("sfx")
	music_slider.value = get_bus_volume_percent("music")

func on_window_button_toggled() -> void:
	var mode = DisplayServer.window_get_mode()

	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	update_display()


func on_resume_pressed() -> void:
	close()

func on_replay_pressed() -> void:
	AudioManager.rain_sfx.stop()
	AudioManager.click_sfx.play()
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func close() -> Signal:
	if is_closing:
		return get_tree().create_timer(0).timeout # return dummy signal if already closing
	AudioManager.click_sfx.play()
	is_closing = true
	$AnimPlayer.play_backwards("default")

	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0)
	tween.tween_property(panel, "scale", Vector2.ZERO, .3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

	await tween.finished

	get_tree().paused = false
	queue_free()

	return get_tree().create_timer(0).timeout


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		close()
		get_tree().root.set_input_as_handled()

		
# Audio
func get_bus_volume_percent(bus_name: String) -> float:
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)

func set_bus_volume_percent(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)

func on_audio_slider_changed(value: float, bus_name: String) -> void:
	set_bus_volume_percent(bus_name, value)

func on_quit_pressed() -> void:
	AudioManager.rain_sfx.stop()
	AudioManager.click_sfx.play()
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
