class_name FinalScore
extends Node2D

@onready var player_score: RichTextLabel = $CanvasLayer/Control/VBoxContainer/HBoxContainer/PlayerScore
@onready var cpu_score: RichTextLabel = $CanvasLayer/Control/VBoxContainer/HBoxContainer/CPUScore
@onready var player_box_score: GridContainer = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/PlayerBoxScore/GridContainer
@onready var cpu_box_score: GridContainer = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/CPUBoxScore/GridContainer
@onready var quarter_scores_container: GridContainer = $CanvasLayer/Control/VBoxContainer/QuarterScores/GridContainer
@onready var continue_button: Button = $CanvasLayer/Control/VBoxContainer/Button
@onready var quarter_headers = [
	$CanvasLayer/Control/VBoxContainer/QuarterScores/GridContainer/Q1Header,
	$CanvasLayer/Control/VBoxContainer/QuarterScores/GridContainer/Q2Header,
	$CanvasLayer/Control/VBoxContainer/QuarterScores/GridContainer/Q3Header,
	$CanvasLayer/Control/VBoxContainer/QuarterScores/GridContainer/Q4Header,
]

@export var box_score_row: PackedScene

func _ready():
	player_score.text = "[center][font_size=30]Player[center][center][font_size=60]" + str(SceneVariables.player_score) + "[center]"
	cpu_score.text = "[center][font_size=30]CPU[center][center][font_size=60]" + str(SceneVariables.cpu_score) + "[center]"
	for statline in SceneVariables.full_player_scorer_statlines.values() as Array[Game.BoxScoreStatLine]:
		add_statline_row(statline, player_box_score)
	for statline in SceneVariables.full_cpu_scorer_statlines.values() as Array[Game.BoxScoreStatLine]:
		add_statline_row(statline, cpu_box_score)
	var quarter_scores = SceneVariables.quarter_scores
	if quarter_scores.has("player"):
		add_quarter_scores_row(quarter_scores["player"], Game.Side.PLAYER, SceneVariables.player_score)
	if quarter_scores.has("cpu"):
		add_quarter_scores_row(quarter_scores["cpu"], Game.Side.CPU, SceneVariables.cpu_score)
	continue_button.pressed.connect(go_to_next_scene)

func add_quarter_scores_row(scores, side: Game.Side, total_score):
	init_box_score_column_headers(scores)
	var side_label_row = box_score_row.instantiate() as BoxScoreRow
	quarter_scores_container.add_child(side_label_row)
	var team_side = "Player" if side == Game.Side.PLAYER else "CPU"
	side_label_row.box_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	side_label_row.set_value(team_side)
	for score in scores:
		var quarter_score_row = box_score_row.instantiate() as BoxScoreRow
		quarter_scores_container.add_child(quarter_score_row)
		quarter_score_row.box_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		quarter_score_row.set_value(str(score))
	var total_score_row = box_score_row.instantiate() as BoxScoreRow
	quarter_scores_container.add_child(total_score_row)
	total_score_row.box_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_score_row.set_value(str(total_score))

func add_statline_row(statline: Game.BoxScoreStatLine, parent: GridContainer):
	var name_row = box_score_row.instantiate() as BoxScoreRow
	var points_row = box_score_row.instantiate() as BoxScoreRow
	var assists_row = box_score_row.instantiate() as BoxScoreRow
	var rebounds_row = box_score_row.instantiate() as BoxScoreRow
	parent.add_child(name_row)
	parent.add_child(points_row)
	parent.add_child(assists_row)
	parent.add_child(rebounds_row)
	name_row.box_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_row.set_value(statline.full_name)
	points_row.set_value(str(statline.points))
	assists_row.set_value(str(statline.assists))
	rebounds_row.set_value(str(statline.rebounds))

func init_box_score_column_headers(scores):
	for header in quarter_headers:
		header.hide()
	for i in range(0, scores.size()):
		quarter_headers[i].show()
	quarter_scores_container.columns = scores.size() + 2

func go_to_next_scene():
	if SceneVariables.player_score > SceneVariables.cpu_score:
		get_tree().change_scene_to_file("res://scenes/PostGameRewards.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
