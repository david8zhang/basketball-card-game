class_name QuarterEnd
extends Control

@export var box_score_row: PackedScene
@onready var player_score_label = $VBoxContainer/HBoxContainer/PlayerScore as RichTextLabel
@onready var cpu_score_label = $VBoxContainer/HBoxContainer/CPUScore as RichTextLabel
@onready var player_box_score = $VBoxContainer/HBoxContainer2/PlayerBoxScore/GridContainer as GridContainer
@onready var cpu_box_score = $VBoxContainer/HBoxContainer2/CPUBoxScore/GridContainer as GridContainer
@onready var continue_button = $VBoxContainer/Button as Button
@onready var title = $VBoxContainer/Title as Label

func update_quarter_number(quarter_num: int):
	title.text = "End of Q" + str(quarter_num)

func update_scores(player_score: int, cpu_score: int):
	player_score_label.text = "[center][font_size=30]Player[center][center][font_size=60]" + str(player_score) + "[center]"
	cpu_score_label.text = "[center][font_size=30]CPU[center][center][font_size=60]" + str(cpu_score) + "[center]"

func update_player_box_score(full_player_scorer_statlines: Dictionary):
	for statline in full_player_scorer_statlines.values() as Array[Game.BoxScoreStatLine]:
		add_statline_row(statline, player_box_score)

func update_cpu_box_score(full_cpu_scorer_statlines: Dictionary):
	for statline in full_cpu_scorer_statlines.values():
		add_statline_row(statline, cpu_box_score)

func add_statline_row(statline: Game.BoxScoreStatLine, parent: GridContainer):
	var name_row = box_score_row.instantiate() as BoxScoreRow
	var points_row = box_score_row.instantiate() as BoxScoreRow
	var assists_row = box_score_row.instantiate() as BoxScoreRow
	var rebounds_row = box_score_row.instantiate() as BoxScoreRow
	parent.add_child(name_row)
	parent.add_child(points_row)
	parent.add_child(assists_row)
	parent.add_child(rebounds_row)
	name_row.set_value(statline.bp_card.full_name())
	points_row.set_value(str(statline.points))
	assists_row.set_value(str(statline.assists))
	rebounds_row.set_value(str(statline.rebounds))
