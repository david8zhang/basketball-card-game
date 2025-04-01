class_name StartingLineup
extends HBoxContainer

@export var card_scene: PackedScene
var starting_lineup_cards = []

func init_cards(player_stat_configs: Array[BallPlayerStats]):
	for stat_config in player_stat_configs:
		var card = card_scene.instantiate() as BallPlayerCard
		card.ball_player_stats = stat_config
		add_child(card)
		starting_lineup_cards.append(card)
