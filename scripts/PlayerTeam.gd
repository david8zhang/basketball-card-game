class_name PlayerTeam
extends Node

@onready var game = get_node("/root/Main") as Game
@onready var strategy_card_deck = $StrategyCardDeck as StrategyCardDeck
@export var starting_lineup_scene: PackedScene
@export var lineup_selector_scene: PackedScene
@export var starting_lineup_wrapper: VBoxContainer

var starting_lineup: StartingLineup
var lineup_selector: LineupSelector
var is_bp_card_callbacks_hooked := false
const NUM_STRATEGY_CARDS = 3

func _ready():
	if starting_lineup_wrapper != null:
		starting_lineup = starting_lineup_scene.instantiate() as StartingLineup
		starting_lineup_wrapper.add_child(starting_lineup)
		starting_lineup.init_cards(SceneVariables.player_team_bp_configs)
	strategy_card_deck.init_strategy_card_deck(SceneVariables.player_strategy_card_deck)

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

func get_starting_cards():
	return starting_lineup.starting_lineup_cards

func get_strategy_card_deck() -> Array:
	return strategy_card_deck.cards_in_play

func reset_playable_strategy_cards():
	strategy_card_deck.init_strategy_card_deck(SceneVariables.player_strategy_card_deck)