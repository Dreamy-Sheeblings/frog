class_name ScoreCounter
extends Node2D

@onready var score_label: RichTextLabel = $NumberLabel
@onready var title_label: RichTextLabel = $TextLabel

var current_score: int

func _ready() -> void:
	current_score = 0
	score_label.pivot_offset = score_label.get_size() / 2
	score_label.text = "[shake rate=10.0 level=1]0"
	GameEvents.score_increased.connect(set_score)
	GameEvents.frog_died.connect(text_disappear)

func set_score(amount: int) -> void:
	var tween = create_tween()
	tween.tween_method(
		func(v): score_label.text = "[shake rate=10.0 level=1]" + str(round(v)),
		current_score, current_score + amount, 0.5 # duration: 0.5 sec
	)
	current_score += amount

func text_disappear():
	var disappear_tween = create_tween()
	disappear_tween.set_parallel()
	disappear_tween.tween_property(score_label, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	disappear_tween.tween_property(title_label, "self_modulate", Color(1, 1, 1, 0), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)