class_name StrategyCardSelector
extends Control

@export var strategy_card_scene: PackedScene
@export var dice_roll_scene: PackedScene
@export var strategy_bonuses_scene: PackedScene

@onready var card_container: HBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer
@onready var close_button: Button = $CloseButton
@onready var game = get_node("/root/Main") as Game

var strategy_bonuses: StrategyBonuses
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
  close_button.pressed.connect(on_close_selector)
  var idx = 0
  for config in player_deck:
    var strategy_card = strategy_card_scene.instantiate() as StrategyCard
    strategy_card.strategy_card_config = config
    var on_select_callable = Callable(self, "select_strategy_card").bind(strategy_card, idx)
    card_container.add_child(strategy_card)
    strategy_card.button.pressed.connect(on_select_callable)
    idx += 1

func select_strategy_card(sc: StrategyCard, index: int):
  selected_strategy_card = sc
  sc.strategy_card_config.process(off_player, def_player)
  node_results = sc.strategy_card_config.blackboard.node_results as Array[StrategyCardNode.NodeResult]
  process_curr_node_result()
  on_strategy_card_selected.emit(index)

func process_curr_node_result():
  if curr_node_result_to_process_idx > node_results.size() - 1:
    return
  var curr_node_result = node_results[curr_node_result_to_process_idx] as StrategyCardNode.NodeResult
  if curr_node_result.node_ref.node_type == StrategyCardNode.NodeType.BONUS:
    process_bonus_node_result(curr_node_result)
  elif curr_node_result.node_ref.node_type == StrategyCardNode.NodeType.ACTION:
    process_action_node_result(curr_node_result)
  else:
    curr_node_result_to_process_idx += 1
    process_curr_node_result()

func process_bonus_node_result(curr_node_result):
  var node = curr_node_result.node_ref as StrategyCardBonusNode
  if strategy_bonuses == null:
    strategy_bonuses = strategy_bonuses_scene.instantiate() as StrategyBonuses
    add_child(strategy_bonuses)
    var callable = Callable(self, "apply_bonuses")
    strategy_bonuses.on_close.connect(callable)
  match (node.bonus_type):
    StrategyCardBonusNode.BonusType.STAT:
      var stat_bonus = node as StatBonus
      if stat_bonus.off_bonus_amount > 0:
        strategy_bonuses.add_bonus_line("Offense", stat_bonus.off_bonus_amount)
      if stat_bonus.def_bonus_amount > 0:
        strategy_bonuses.add_bonus_line("Defense", stat_bonus.def_bonus_amount)
    StrategyCardBonusNode.BonusType.MARKER:
      var marker_bonus = node as MarkerBonus
      match (marker_bonus.marker_type):
        MarkerBonus.MarkerType.HOT_ON_OFF:
          strategy_bonuses.add_bonus_line("Hot markers (off)", marker_bonus.num_markers)
        MarkerBonus.MarkerType.COLD_ON_OFF:
          strategy_bonuses.add_bonus_line("Cold markers (off)", marker_bonus.num_markers)
        MarkerBonus.MarkerType.HOT_ON_DEF:
          strategy_bonuses.add_bonus_line("Hot markers (def)", marker_bonus.num_markers)
        MarkerBonus.MarkerType.COLD_ON_DEF:
          strategy_bonuses.add_bonus_line("Cold markers (def)", marker_bonus.num_markers)
  curr_node_result_to_process_idx += 1
  process_curr_node_result()

func apply_bonuses():
  var bonuses = []
  for result in node_results:
    if result.node_ref.node_type == StrategyCardNode.NodeType.BONUS:
      bonuses.append(result.node_ref)
  matchup_container.apply_bonuses(bonuses)
  on_close.emit()

func process_action_node_result(curr_node_result: StrategyCardNode.NodeResult):
  var node = curr_node_result.node_ref as StrategyCardActionNode
  match (node.action_type):
    StrategyCardActionNode.ActionType.ROLL_DICE:
      var roll_dice_action = node as RollDiceAction
      show_dice_roll(roll_dice_action)

func show_dice_roll_result(dice_roll_window: DiceRoll):
  dice_roll_window.queue_free()
  curr_node_result_to_process_idx += 1
  process_curr_node_result()

func show_dice_roll(roll_dice_action: RollDiceAction):
  var dice_roll_window = dice_roll_scene.instantiate() as DiceRoll
  add_child(dice_roll_window)
  dice_roll_window.configure_dice_roll(roll_dice_action)
  dice_roll_window.roll_value(roll_dice_action.dice_roll_result)
  var callable = Callable(self, "show_dice_roll_result").bind(dice_roll_window)
  dice_roll_window.on_roll_complete.connect(callable)

func on_close_selector():
  on_close.emit()
