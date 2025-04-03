class_name MatchupContainer
extends Panel

@onready var hbox_container = $MarginContainer/VBoxContainer/HBoxContainer as HBoxContainer
@export var card_scene: PackedScene

var player_card: BallPlayerCard
var cpu_card: BallPlayerCard

func set_player_card(card: BallPlayerCard):
	player_card = card_scene.instantiate() as BallPlayerCard
	player_card.ball_player_stats = card.ball_player_stats.duplicate()
	hbox_container.add_child(player_card)

func set_cpu_card(card: BallPlayerCard):
	cpu_card = card_scene.instantiate() as BallPlayerCard
	cpu_card.ball_player_stats = card.ball_player_stats.duplicate()
	hbox_container.add_child(cpu_card)
