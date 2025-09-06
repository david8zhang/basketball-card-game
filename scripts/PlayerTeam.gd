class_name PlayerTeam
extends Node

@onready var game = get_node("/root/Main") as Game
@onready var strategy_card_deck = $StrategyCardDeck as StrategyCardDeck
@export var starting_lineup_scene: PackedScene
@export var lineup_selector_scene: PackedScene
@export var starting_lineup_wrapper: VBoxContainer

var starting_lineup: StartingLineup
var lineup_selector: LineupSelector
var cards_in_play = []
const NUM_STRATEGY_CARDS = 3

func _ready():
	if starting_lineup_wrapper != null:
		starting_lineup = starting_lineup_scene.instantiate() as StartingLineup
		starting_lineup_wrapper.add_child(starting_lineup)
		starting_lineup.init_cards(SceneVariables.get_player_team_or_gen_random_team())
	strategy_card_deck.init_strategy_card_deck(SceneVariables.get_player_strat_card_deck_or_gen_random_deck())
	cards_in_play = starting_lineup.starting_lineup_cards
	hookup_bp_card_callbacks()

func update_lineup():
	starting_lineup.re_init_cards(SceneVariables.player_team_bp_configs)
	cards_in_play = starting_lineup.starting_lineup_cards
	hookup_bp_card_callbacks()

func hookup_bp_card_callbacks():
	for bp_card in starting_lineup.starting_lineup_cards:
		var callable = Callable(self, "on_bp_card_pressed")
		bp_card.on_bp_card_clicked.connect(callable)

func on_bp_card_pressed(card: BallPlayerCard):
	game.player_select_card_to_score_with(card)

func get_card_at_position(pos: BallPlayerStats.PlayerPosition):
	return starting_lineup.get_card_at_position(pos)

func get_starting_cards():
	return starting_lineup.starting_lineup_cards

func get_cards_in_play():
	return cards_in_play

func get_strategy_card_deck() -> Array:
	return strategy_card_deck.cards_in_play

func reset_playable_strategy_cards():
	strategy_card_deck.reset_strategy_card_deck(SceneVariables.player_strategy_card_deck)