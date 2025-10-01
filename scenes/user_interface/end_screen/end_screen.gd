extends CanvasLayer

@onready var panel: PanelContainer = %Panel

@onready var replay_button: TextureButton = %ReplayButton
@onready var quit_button: TextureButton = %QuitButton

@onready var announce_label: Label = %AnnounceLabel
@onready var score_label: Label = %ScoreLabel
@onready var best_score_label: Label = %BestScoreLabel
@onready var best_score_container: PanelContainer = %BestScoreContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.pivot_offset = panel.size / 2

	replay_button.pressed.connect(on_replay_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel, "scale", Vector2.ONE, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	var saved_highscore: HighScore = load("res://resources/meta/high_score.tres")

	var score_counter = get_tree().get_first_node_in_group("score") as ScoreCounter
	if score_counter.current_score > saved_highscore.value:
		var new_highscore = HighScore.new()
		new_highscore.value = score_counter.current_score
		new_highscore.tutorial_shown = true
		ResourceSaver.save(new_highscore, "res://resources/meta/high_score.tres")
		announce_label.text = "NEW HIGH SCORE!"
		best_score_container.visible = false

	else:
		best_score_label.text = str(saved_highscore.value) + " points"

	score_label.text = str(score_counter.current_score) + " points"
	

func on_replay_pressed() -> void:
	AudioManager.rain_sfx.stop()
	AudioManager.click_sfx.play()
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func on_quit_pressed() -> void:
	AudioManager.rain_sfx.stop()
	AudioManager.click_sfx.play()
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
