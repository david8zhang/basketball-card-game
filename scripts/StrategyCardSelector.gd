class_name StrategyCardSelector
extends Control

@export var strategy_card_scene: PackedScene
@export var strategy_card_processor_scene: PackedScene
@export var dice_roll_scene: PackedScene
@export var strategy_bonuses_scene: PackedScene

@onready var card_container: HBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer
@onready var margin_container: MarginContainer = $MarginContainer
@onready var close_button: Button = $CloseButton
@onready var game = get_node("/root/Main") as Game

var strategy_bonuses: StrategyBonuses
var strategy_card_processor: StrategyCardProcessor
var off_player: BallPlayerCard
var def_player: BallPlayerCard
var matchup_container: MatchupContainer
var strategy_cards = []
var selected_strategy_card: StrategyCard
const NUM_STRATEGY_CARDS = 3

var node_results = []
var curr_node_result_to_process_idx = 0

signal on_close
signal on_strategy_card_selected(selected_card_idx)

func _ready():
  var player_deck = game.player_team.get_strategy_card_deck()
  if matchup_container.offense_side == Game.Side.PLAYER:
    player_deck = player_deck.filter(func (card): return card.strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE)
  else:
    player_deck = player_deck.filter(func (card): return card.strategy_type == StrategyCardConfig.StrategyCardType.DEFENSE)
  close_button.pressed.connect(on_close_selector)
  var idx = 0
  for config in player_deck:
    var strategy_card = strategy_card_scene.instantiate() as StrategyCard
    strategy_card.strategy_card_config = config
    var on_select_callable = Callable(self, "select_strategy_card").bind(strategy_card, idx)
    card_container.add_child(strategy_card)
    strategy_card.button.pressed.connect(on_select_callable)
    idx += 1
  strategy_card_processor = strategy_card_processor_scene.instantiate() as StrategyCardProcessor
  matchup_container.add_child(strategy_card_processor)
  strategy_card_processor.off_player = off_player
  strategy_card_processor.def_player = def_player
  strategy_card_processor.matchup_container = matchup_container
  strategy_card_processor.before_apply_bonus.connect(on_close_selector)

func select_strategy_card(sc: StrategyCard, index: int):
  strategy_card_processor.select_strategy_card(sc, index)
  var callable = Callable(self, "process_strategy_card")
  strategy_card_processor.display_complete.connect(callable)
  hide()
  on_strategy_card_selected.emit(index)

func process_strategy_card():
  strategy_card_processor.process_selected_card()

func on_close_selector():
  on_close.emit()
