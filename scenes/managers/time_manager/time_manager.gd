extends Node

signal difficulty_changed(difficulty: int)

@onready var difficult_timer: Timer = $DifficultyTimer
@onready var weather_timer: Timer = $WeatherTimer
@onready var round_timer: Timer = $RoundTimer
@onready var time_label: Label = %TimeLabel

var weather_table: WeightedTable = WeightedTable.new()

var round_difficulty: int
var stormy: bool = false
var total_time_in_seconds: int = 0

func _ready() -> void:
	round_difficulty = 0
	difficult_timer.timeout.connect(on_difficult_timer_timeout)
	weather_timer.timeout.connect(on_weather_timer_timeout)
	round_timer.timeout.connect(on_round_timer_timeout)
	GameEvents.storm_casted.connect(on_storm_casted)
	GameEvents.frog_died.connect(on_frog_died)
	weather_table.add_item("sunny", 8)

func on_round_timer_timeout() -> void:
	total_time_in_seconds += 1
	var m = int(total_time_in_seconds / 60.0)
	var s = total_time_in_seconds - m * 60
	time_label.text = "%02d:%02d" % [m, s]


func on_frog_died() -> void:
	difficult_timer.stop()
	weather_timer.stop()

func on_difficult_timer_timeout() -> void:
	round_difficulty += 1
	difficulty_changed.emit(round_difficulty)
	if round_difficulty == 8:
		weather_table.add_item("stormy", 2)
		stormy = true
		GameEvents.emit_storm_cast(stormy)
		weather_timer.start()

func on_storm_casted(is_stormy: bool) -> void:
	if not is_stormy:
		stormy = false

func on_weather_timer_timeout() -> void:
	if round_difficulty >= 10 and not stormy:
		var weather = weather_table.pick_item()
		if weather == "stormy":
			stormy = true
			GameEvents.emit_storm_cast(stormy)
