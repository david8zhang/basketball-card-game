class_name PlayerTeam
extends Node

@onready var game = get_node("/root/Main") as Game
@export var starting_lineup_scene: PackedScene
@export var lineup_selector_scene: PackedScene
@export var starting_lineup_wrapper: VBoxContainer

var starting_lineup: StartingLineup
var lineup_selector: LineupSelector
var is_bp_card_callbacks_hooked := false

func _ready():
	if starting_lineup_wrapper != null:
		starting_lineup = starting_lineup_scene.instantiate() as StartingLineup
		starting_lineup_wrapper.add_child(starting_lineup)
		var random_lineup = game.assemble_random_lineup()
		starting_lineup.init_cards(random_lineup)

func _process(_delta):
	if !is_bp_card_callbacks_hooked:
		hookup_bp_card_callbacks()

func hookup_bp_card_callbacks():
	for bp_card in starting_lineup.starting_lineup_cards:
		if bp_card.button != null:
			var callable = Callable(self, "on_bp_card_pressed").bind(bp_card)
			bp_card.button.pressed.connect(callable)
		else:
			return
	is_bp_card_callbacks_hooked = true

func on_bp_card_pressed(card: BallPlayerCard):
	game.player_select_card_to_score_with(card)

func get_card_at_position(pos: BallPlayerStats.PlayerPosition):
	return starting_lineup.get_card_at_position(pos)
