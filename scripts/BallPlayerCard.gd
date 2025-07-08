class_name BallPlayerCard
extends Control

@onready var offense_value := $Panel/MarginContainer/VBoxContainer/HBoxContainer/Offense/OffenseValue as Label
@onready var defense_value := $Panel/MarginContainer/VBoxContainer/HBoxContainer/Defense/DefenseValue as Label
@onready var first_name := $Panel/MarginContainer/VBoxContainer/HBoxContainer2/PlayerName/First as Label
@onready var last_name := $Panel/MarginContainer/VBoxContainer/HBoxContainer2/PlayerName/Last as Label
@onready var player_position := $Panel/MarginContainer/VBoxContainer/Position as Label
@onready var three_point_bonus := $Panel/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer3/ThreePointBonus as Label
@onready var shot_line := $Panel/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer3/Panel/ShotLine as Label
@onready var roll_table := $Panel/MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/GridContainer as GridContainer
@onready var button := $Panel/Button as Button
@onready var panel_container := $Panel as Panel
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var marker = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/PlayerName/Marker as Marker
@onready var texture_rect = $Panel/MarginContainer/TextureRect as TextureRect
@onready var highlight = $Highlight as Panel

@export var roll_table_value_scene: PackedScene
@export var ball_player_stats: BallPlayerStats
@export var roll_table_font_override_size := 8
@export var assigned_position: BallPlayerStats.PlayerPosition
@export var show_roll_table = true

var roll_table_rows = []

func _ready():
	offense_value.text = str(ball_player_stats.offense)
	defense_value.text = str(ball_player_stats.defense)
	player_position.text = convert_positions_to_string(ball_player_stats.positions)
	texture_rect.texture = ball_player_stats.texture

	if ball_player_stats.three_point_bonus > 0:
		three_point_bonus.text = "3PT +" + str(ball_player_stats.three_point_bonus)
	else:
		three_point_bonus.hide()

	first_name.text = ball_player_stats.first_name.to_upper()
	last_name.text = ball_player_stats.last_name.to_upper()

	if show_roll_table:
		setup_roll_table()
	else:
		roll_table.hide()

func setup_roll_table():
	for row in ball_player_stats.roll_table:
		var table_row = row as RollTableRow
		var roll_range = roll_table_value_scene.instantiate() as TableValue
		var points_value = roll_table_value_scene.instantiate() as TableValue
		var assists_value = roll_table_value_scene.instantiate() as TableValue
		var rebounds_value = roll_table_value_scene.instantiate() as TableValue
		
		roll_range.font_override_size = roll_table_font_override_size
		points_value.font_override_size = roll_table_font_override_size
		assists_value.font_override_size = roll_table_font_override_size
		rebounds_value.font_override_size = roll_table_font_override_size

		roll_table.add_child(roll_range)
		roll_table.add_child(points_value)
		roll_table.add_child(assists_value)
		roll_table.add_child(rebounds_value)

		if table_row.high >= 30:
			roll_range.label.text = str(table_row.low) + "+"
		else:
			roll_range.label.text = str(table_row.low) + "-" + str(table_row.high)
		populate_label_value(points_value.label, table_row.points)
		populate_label_value(assists_value.label, table_row.assists)
		populate_label_value(rebounds_value.label, table_row.rebounds)

		var roll_table_row = {
			"data": table_row,
			"roll_range_label": roll_range,
			"points_label": points_value,
			"assists_label": assists_value,
			"rebounds_label": rebounds_value
		}
		roll_table_rows.append(roll_table_row)


func populate_label_value(label: Label, value: int):
	if value == 0:
		label.text = ""
	else:
		label.text = str(value)

func convert_positions_to_string(positions: Array[BallPlayerStats.PlayerPosition]):
	var player_position_name_mapping = ["PG", "SG", "SF", "PF", "C"]
	var position_names = positions.map(func(p): return player_position_name_mapping[int(p)])
	return "/".join(position_names)

func get_assigned_position():
	return assigned_position

func full_name():
	return ball_player_stats.first_name + " " + ball_player_stats.last_name

func add_hot_marker():
	marker.add_hot_marker()

func add_cold_marker():
	marker.add_cold_marker()

func enable_highlight():
	highlight.show()

func disable_highlight():
	highlight.hide()