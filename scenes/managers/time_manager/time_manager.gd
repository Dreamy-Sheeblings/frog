extends Node

signal difficulty_changed(difficulty: int)

@onready var difficult_timer: Timer = $DifficultyTimer
@onready var weather_timer: Timer = $WeatherTimer

var weather_table: WeightedTable = WeightedTable.new()

var round_difficulty: int
var stormy: bool = false


func _ready() -> void:
	round_difficulty = 0
	difficult_timer.timeout.connect(on_difficult_timer_timeout)
	weather_timer.timeout.connect(on_weather_timer_timeout)
	GameEvents.storm_casted.connect(on_storm_casted)
	weather_table.add_item("sunny", 4)

func on_difficult_timer_timeout() -> void:
	round_difficulty += 1
	difficulty_changed.emit(round_difficulty)
	if round_difficulty == 5:
		weather_table.add_item("stormy", 2)
		stormy = true
		GameEvents.emit_storm_cast(stormy)
		weather_timer.start()

func on_storm_casted(is_stormy: bool) -> void:
	if not is_stormy:
		stormy = false

func on_weather_timer_timeout() -> void:
	if round_difficulty >= 6 and not stormy:
		var weather = weather_table.pick_item()
		if weather == "stormy":
			stormy = true
			GameEvents.emit_storm_cast(stormy)