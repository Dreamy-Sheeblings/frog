extends ParallaxBackground

const CLOUD_SPEED := 5

@onready var thunder_strike_timer: Timer = $ThunderStrikeTimer
@onready var cloud_layer: ParallaxLayer = $Cloud
@onready var sky_layer: ParallaxLayer = $Sky
@onready var rain: GPUParticles2D = $RainParticles
@onready var thunder_layer: ParallaxLayer = $Thunder
@onready var thunder_scene: PackedScene = preload("res://scenes/environment/thunder/thunder.tscn")

func _ready() -> void:
	GameEvents.storm_casted.connect(cast_storm)
	thunder_strike_timer.timeout.connect(on_thunder_strike)

func _process(delta: float) -> void:
	cloud_layer.motion_offset.x -= CLOUD_SPEED * delta

func cast_storm(is_storm_casted: bool) -> void:
	if not is_storm_casted:
		return
	AudioManager.rain_sfx.play()
	var weather_color_rect = get_tree().get_first_node_in_group("color_weather") as ColorRect
	weather_color_rect.visible = true
	get_tree().create_timer(4).timeout.connect(on_thunder_appear)
	var storm_tween := create_tween()
	rain.emitting = true
	storm_tween.set_parallel()
	storm_tween.tween_property(sky_layer, "modulate", Color(175.0 / 255.0, 175.0 / 255.0, 175.0 / 255.0, 1.0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	storm_tween.tween_property(cloud_layer, "modulate", Color(100.0 / 255.0, 100.0 / 255.0, 100.0 / 255.0, 1.0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	storm_tween.chain()

func on_thunder_appear() -> void:
	var weather_color_rect = get_tree().get_first_node_in_group("color_weather") as ColorRect
	var thunder_tween := create_tween()
	thunder_tween.tween_property(weather_color_rect, "color", Color(20.0 / 255.0, 20.0 / 255.0, 20.0 / 255.0, 0.98), 0.4)
	thunder_strike_timer.start()

func stop_storm() -> void:
	rain.emitting = false

func on_thunder_strike() -> void:
	var weather_color_rect = get_tree().get_first_node_in_group("color_weather") as ColorRect
	var thunder_instance = thunder_scene.instantiate()
	
	var strike_tween := create_tween()
	strike_tween.tween_property(weather_color_rect, "color", Color(20.0 / 255.0, 20.0 / 255.0, 20.0 / 255.0, 0.3), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	thunder_layer.add_child(thunder_instance)
	thunder_instance.global_position = Vector2(randi_range(150, 470), 64)
	AudioManager.thunder_sfx.play()
	strike_tween.tween_property(weather_color_rect, "color", Color(20.0 / 255.0, 20.0 / 255.0, 20.0 / 255.0, 0.98), 3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
