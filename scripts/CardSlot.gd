class_name CardSlot
extends Control

@onready var position_label = $Button/PlayerPosition as Label
@onready var button = $Button as Button
@export var player_position := BallPlayerStats.PlayerPosition.PG

signal on_select_card(player_position)

func _ready():
	match player_position:
		BallPlayerStats.PlayerPosition.PG:
			position_label.text = "PG"
		BallPlayerStats.PlayerPosition.SG:
			position_label.text = "SG"
		BallPlayerStats.PlayerPosition.SF:
			position_label.text = "SF"
		BallPlayerStats.PlayerPosition.PF:
			position_label.text = "PF"
		BallPlayerStats.PlayerPosition.C:
			position_label.text = "C"
	
	button.pressed.connect(on_pressed)

func on_pressed():
	on_select_card.emit(player_position)
