class_name BallPlayerStats
extends Resource

enum PlayerPosition { PG, SG, SF, PF, C }

@export_group("Attributes")
@export var offense := 0
@export var defense := 0
@export var positions: Array[PlayerPosition] = []
@export var first_name := ""
@export var last_name := ""
@export var three_point_bonus := 0
@export var texture: Texture

@export_group("RollTable")
@export var roll_table: Array[RollTableRow] = []