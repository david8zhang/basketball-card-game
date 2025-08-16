class_name StartingLineup
extends HBoxContainer

@export var card_scene: PackedScene
var starting_lineup_cards = []

func init_cards(pos_to_player_map: Dictionary):
	var sorted_positions = pos_to_player_map.keys()
	sorted_positions.sort()
	for pos in sorted_positions:
		var player_stat = pos_to_player_map[pos]
		var card = card_scene.instantiate() as BallPlayerCard
		card.ball_player_stats = player_stat
		card.assigned_position = pos
		add_child(card)
		starting_lineup_cards.append(card)

func get_card_at_position(pos: BallPlayerStats.PlayerPosition):
	for card in starting_lineup_cards:
		if card.assigned_position == pos:
			return card
	return null
