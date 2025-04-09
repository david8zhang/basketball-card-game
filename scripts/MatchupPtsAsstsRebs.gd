class_name MatchupPtsAsstsRebs
extends HBoxContainer

@onready var points_value = $Points/Value as Label
@onready var assists_value = $Assists/Value as Label
@onready var rebounds_value = $Rebounds/Value as Label

# Called when the node enters the scene tree for the first time.
func _ready():
	set_points_value(0)
	set_assists_value(0)
	set_rebounds_value(0)

func set_points_value(value: int):
	points_value.text = str(value)

func set_assists_value(value: int):
	assists_value.text = str(value)

func set_rebounds_value(value: int):
	rebounds_value.text = str(value)
