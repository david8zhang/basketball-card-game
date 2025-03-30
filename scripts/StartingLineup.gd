class_name StartingLineup
extends HBoxContainer

@export var card_scene: PackedScene
var starting_lineup_cards = []

func init_cards():
	for i in range(0, 5):
		var card = card_scene.instantiate()
		add_child(card)
		starting_lineup_cards.append(card)
