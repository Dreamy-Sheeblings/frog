extends ParallaxBackground

const CLOUD_SPEED := 5

@onready var thunder_strike_timer: Timer = $ThunderStrikeTimer
@onready var cloud_layer: ParallaxLayer = $Cloud
@onready var sky_layer: ParallaxLayer = $Sky
@onready var rain: GPUParticles2D = $RainParticles
@onready var thunder_layer: ParallaxLayer = $Thunder
@onready var thunder_scene: PackedScene = preload("res://scenes/environment/thunder/thunder.tscn")

var thunder_strike_time_remaining: int = 0

func _ready() -> void:
	GameEvents.storm_casted.connect(on_storm_casted)
	GameEvents.frog_died.connect(on_frog_died)
	thunder_strike_timer.timeout.connect(on_thunder_strike)

func _process(delta: float) -> void:
	cloud_layer.motion_offset.x -= CLOUD_SPEED * delta

func on_storm_casted(is_stormy: bool) -> void:
	if is_stormy:
		cast_storm()

func cast_storm() -> void:
	AudioManager.rain_sfx.play()
	thunder_strike_time_remaining = randi_range(7, 10)
	var delay_before_thunder = randf_range(10.0, 15.0)
	get_tree().create_timer(delay_before_thunder).timeout.connect(on_thunder_appear)
	var storm_tween := create_tween()
	rain.emitting = true
	storm_tween.set_parallel()
	storm_tween.tween_property(sky_layer, "modulate", Color(175.0 / 255.0, 175.0 / 255.0, 175.0 / 255.0), 2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	storm_tween.tween_property(cloud_layer, "modulate", Color(100.0 / 255.0, 100.0 / 255.0, 100.0 / 255.0), 2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	storm_tween.chain()

func on_thunder_strike() -> void:
	var bg_modulate = get_tree().get_first_node_in_group("bg_modulate") as CanvasModulate
	if not bg_modulate:
		return
	var thunder_instance = thunder_scene.instantiate()
	var strike_tween := create_tween()
	strike_tween.tween_property(bg_modulate, "color", Color(0.75, 0.75, 0.75), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	thunder_layer.add_child(thunder_instance)
	thunder_instance.global_position = Vector2(randi_range(150, 470), 64)
	AudioManager.thunder_sfx.play()
	strike_tween.tween_property(bg_modulate, "color", Color(0.02, 0.02, 0.02), 2.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	strike_tween.tween_callback(thunder_strike_callback).set_delay(1)

func thunder_strike_callback() -> void:
	thunder_strike_time_remaining -= 1
	if thunder_strike_time_remaining <= 0:
		stop_storm()

func on_thunder_appear() -> void:
	thunder_strike_timer.start()

func stop_storm() -> void:
	thunder_strike_timer.stop()
	var bg_modulate = get_tree().get_first_node_in_group("bg_modulate") as CanvasModulate
	if bg_modulate:
		var tween := create_tween()
		tween.tween_property(bg_modulate, "color", Color(0.75, 0.75, 0.75), 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		var delay_after_storm = randf_range(10.0, 15.0)
		get_tree().create_timer(delay_after_storm).timeout.connect(func():
			rain.emitting = false
			AudioManager.rain_sfx.stop()
			var stop_rain_tween = create_tween()
			stop_rain_tween.set_parallel()
			stop_rain_tween.tween_property(sky_layer, "modulate", Color(1, 1, 1), 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
			stop_rain_tween.tween_property(cloud_layer, "modulate", Color(1, 1, 1), 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
			stop_rain_tween.chain()
			stop_rain_tween.tween_property(bg_modulate, "color", Color(1, 1, 1), 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		)
	get_tree().create_timer(15).timeout.connect(func():
		GameEvents.emit_storm_cast(false)
	)

func on_frog_died() -> void:
	thunder_strike_time_remaining = 0