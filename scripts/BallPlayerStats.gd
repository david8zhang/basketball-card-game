class_name BallPlayerStats
extends Resource

enum PlayerPosition { PG, SG, SF, PF, C, NONE }

@export_group("Attributes")
@export var offense := 0
@export var defense := 0
@export var positions: Array[PlayerPosition] = []
@export var first_name := ""
@export var last_name := ""
@export var three_point_bonus := 0
@export var player_cost := 0
@export var shot_check := 0
@export var texture: Texture
@export var first_name_size := 28
@export var last_name_size := 28

@export_group("RollTable")
@export var roll_table: Array[RollTableRow] = []

func get_full_name():
  return first_name + " " + last_name