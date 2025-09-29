extends Node2D

@onready var score_label: RichTextLabel = $NumberLabel

var current_score: int

func _ready() -> void:
	current_score = 0
	score_label.text = "[shake rate=10.0 level=1]0"
	GameEvents.score_increased.connect(set_score)

func set_score(amount: int) -> void:
	var tween = create_tween()
	tween.tween_method(
		func(v): score_label.text = "[shake rate=10.0 level=1]" + str(round(v)),
		current_score, current_score + amount, 0.5 # duration: 0.5 sec
	)
	current_score += amount