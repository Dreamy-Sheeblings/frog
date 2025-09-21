extends Node2D

@onready var label: RichTextLabel = $NumberLabel
@onready var text_label: RichTextLabel = $TextLabel

func _ready() -> void:
	label.text = "[shake rate=25.0 level=1]0"
	label.scale = Vector2.ZERO
	text_label.self_modulate = Color(1, 1, 1, 0)
	GameEvents.devour_combo_text_updated.connect(on_combo_text_updated)
	GameEvents.frog_died.connect(on_frog_died)

func on_frog_died() -> void:
	text_disappear()

func on_combo_text_updated(number: int) -> void:
	if number == 0:
		text_disappear()
		return
	else:
		text_label.self_modulate = Color(1, 1, 1, 1)
	label.text = "[shake rate=25.0 level=1]" + str(number)

	label.scale = Vector2.ONE * 1.5

	var scale_tween = create_tween()

	scale_tween.tween_property(label, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)

func text_disappear():
	var disappear_tween = create_tween()
	disappear_tween.set_parallel()
	disappear_tween.tween_property(label, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	disappear_tween.tween_property(text_label, "self_modulate", Color(1, 1, 1, 0), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)