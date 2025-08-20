class_name ReboundTally
extends Control

@onready var scoreboard = $Scoreboard as HBoxContainer
@onready var player_score = $Scoreboard/PlayerScore as Label
@onready var player_assists = $Scoreboard/PlayerAssists as Label
@onready var player_rebounds = $Scoreboard/PlayerRebounds as Label
@onready var cpu_score = $Scoreboard/CPUScore as Label
@onready var cpu_assists = $Scoreboard/CPUAssists as Label
@onready var cpu_rebounds = $Scoreboard/CPURebounds as Label
@onready var bg_panel = $Panel as Panel

func update_scoreboard(player_stats, cpu_stats):
	player_score.text = str(player_stats["points"])
	player_assists.text = "A: " + str(player_stats["assists"])
	player_rebounds.text = "R: " + str(player_stats["rebounds"])
	cpu_score.text = str(cpu_stats["points"])
	cpu_assists.text = "A: " + str(cpu_stats["assists"])
	cpu_rebounds.text = "R: " + str(cpu_stats["rebounds"])

func tally_rebounds(on_tally_finished: Callable):
	var on_tween_bg_finished = func():
		var tween_scoreboard_down_finished = func():
			var on_player_reb_tally_complete = func():
				handle_rebound_tally_anims(cpu_rebounds, cpu_score, on_tally_finished)
			handle_rebound_tally_anims(player_rebounds, player_score, on_player_reb_tally_complete)
		var tween_scoreboard_down = create_tween()
		tween_scoreboard_down.set_trans(Tween.TRANS_SINE)
		tween_scoreboard_down.set_ease(Tween.EASE_IN_OUT)
		tween_scoreboard_down.tween_property(scoreboard, "global_position:y", 407, 1.0)
		tween_scoreboard_down.finished.connect(tween_scoreboard_down_finished)
	var tween_bg = create_tween()
	tween_bg.tween_property(bg_panel, "modulate:a", 1, 0.5)
	tween_bg.finished.connect(on_tween_bg_finished)

func handle_rebound_tally_anims(rebounds_text: Label, score_text: Label, on_complete: Callable):
	var reb_tween_finished = func():
		var reb_bonus_label = Label.new()
		@warning_ignore("integer_division")
		var num_points_to_add = Game.get_points_from_rebounds(int(rebounds_text.text))
		reb_bonus_label.text = "+" + str(num_points_to_add)
		add_child(reb_bonus_label)
		reb_bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reb_bonus_label.add_theme_font_size_override("font_size", 30)
		reb_bonus_label.global_position = Vector2(score_text.global_position.x + 30, score_text.global_position.y + 100)
		var add_reb_bonus_tween = create_tween()
		add_reb_bonus_tween.tween_property(reb_bonus_label, "global_position:y", score_text.global_position.y, 0.375).set_delay(0.5)
		var callable = Callable(self, "_on_bonus_added").bind(rebounds_text, score_text, reb_bonus_label, on_complete)
		add_reb_bonus_tween.finished.connect(callable)
	var reb_tween = create_tween()
	reb_tween.tween_property(rebounds_text, "scale", Vector2(1.25, 1.25), 0.25)
	reb_tween.finished.connect(reb_tween_finished)

func _on_bonus_added(rebounds_text: Label, score_text: Label, reb_bonus_label: Label, on_complete: Callable):
	var num_reb_to_add = int(rebounds_text.text)
	reb_bonus_label.queue_free()
	@warning_ignore("integer_division")
	var num_points_to_add = Game.get_points_from_rebounds(num_reb_to_add)
	score_text.text = str(int(score_text.text) + num_points_to_add)
	var reb_reset_tween = create_tween()
	reb_reset_tween.tween_property(rebounds_text, "scale", Vector2(1, 1), 0.25)
	if on_complete != null:
		reb_reset_tween.finished.connect(on_complete)