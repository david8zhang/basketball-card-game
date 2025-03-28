class_name BallPlayerCard
extends Control

@onready var offense_value = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Offense/OffenseValue as Label
@onready var defense_value = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Defense/DefenseValue as Label
@onready var player_name = $Panel/MarginContainer/VBoxContainer/HboxContainer2/PlayerName as Label
@onready var player_position = $Panel/MarginContainer/VBoxContainer/Position as Label
@onready var three_point_bonus = $Panel/MarginContainer/VBoxContainer/ThreePointBonus as Label
@onready var roll_table = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/GridContainer as GridContainer

@export var roll_table_value_scene: PackedScene
@export var ball_player_stats: BallPlayerStats

func _ready():
  offense_value.text = str(ball_player_stats.offense)
  defense_value.text = str(ball_player_stats.defense)
  player_name.text = str(ball_player_stats.player_name)
  player_position.text = convert_positions_to_string(ball_player_stats.positions)
  three_point_bonus.text = str(ball_player_stats.three_point_bonus)

  for row in ball_player_stats.roll_table:
    var table_row = row as RollTableRow
    var roll_range = roll_table_value_scene.instantiate() as TableValue
    var points_value = roll_table_value_scene.instantiate() as TableValue
    var assists_value = roll_table_value_scene.instantiate() as TableValue
    var rebounds_value = roll_table_value_scene.instantiate() as TableValue

    roll_range.label.text = str(table_row.low) + "-" + str(table_row.high)
    points_value.label.text = str(table_row.points)
    assists_value.label.text = str(table_row.assists)
    rebounds_value.label.text = str(table_row.rebounds)


func convert_positions_to_string(positions: Array[BallPlayerStats.PlayerPosition]):
  var player_position_name_mapping = ["PG", "SG", "SF", "PF", "C"]
  var position_names = positions.map(func(p): return player_position_name_mapping[int(p)])
  return "/".join(position_names)
