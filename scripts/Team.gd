class_name Team
extends HBoxContainer

@export var card_scene: PackedScene

enum Side {
	PLAYER,
	CPU
}

var starting_lineup_cards = []

# Called when the node enters the scene tree for the first time.
func _ready():
	init_cards()

func init_cards():
	for i in range(0, 5):
		var card = card_scene.instantiate()
		add_child(card)
		starting_lineup_cards.append(card)
