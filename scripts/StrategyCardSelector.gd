class_name StrategyCardSelector
extends Control

@export var strategy_card_scene: PackedScene
@export var dice_roll_scene: PackedScene

@onready var card_container: HBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer
@onready var close_button: Button = $CloseButton

var off_player: BallPlayerCard
var def_player: BallPlayerCard
var matchup_container: MatchupContainer
var all_strategy_card_configs = []
var strategy_cards = []
var selected_strategy_card: StrategyCard
const NUM_STRATEGY_CARDS = 3

var node_results = []
var curr_node_result_to_process_idx = 0

signal on_close
signal on_cr_finished
signal on_br_finished

func _init():
	for file_name in DirAccess.get_files_at("res://resources/strategy"):
		if (file_name.get_extension() == "tres"):
			var strategy_card_config = load("res://resources/strategy/" + file_name) as StrategyCardConfig
			all_strategy_card_configs.append(strategy_card_config)
	# on_cr_finished.connect(handle_cr_finished)
	# on_br_finished.connect(handle_br_finished)

func _ready():
	close_button.pressed.connect(on_close_selector)
	for i in range(0, NUM_STRATEGY_CARDS):
		var strategy_card = strategy_card_scene.instantiate() as StrategyCard
		var random_config = all_strategy_card_configs.pick_random()
		strategy_card.strategy_card_config = random_config
		strategy_card.on_card_selected.connect(select_strategy_card)
		card_container.add_child(strategy_card)

func select_strategy_card(sc: StrategyCard):
	selected_strategy_card = sc
	sc.strategy_card_config.process(off_player, def_player)
	node_results = sc.strategy_card_config.blackboard.node_results as Array[StrategyCardNode.NodeResult]
	process_curr_node_result()

# func handle_cbr_finished():
# 	if curr_cb_result_to_process_idx == cb_results.size() - 1:
# 		print("Finished processing all condition bonus results!")
# 		on_close.emit()
# 	else:
# 		curr_cb_result_to_process_idx += 1
# 		process_curr_cb_result()

func process_curr_node_result():
	if curr_node_result_to_process_idx > node_results.size() - 1:
		return
	var curr_node_result = node_results[curr_node_result_to_process_idx] as StrategyCardNode.NodeResult
	if curr_node_result.node_ref.node_type == StrategyCardNode.NodeType.BONUS:
		print("Processing bonus")
		pass
	elif curr_node_result.node_ref.node_type == StrategyCardNode.NodeType.ACTION:
		process_action_node_result(curr_node_result)
	else:
		curr_node_result_to_process_idx += 1
		process_curr_node_result()

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

# func handle_br_finished():
# 	if curr_b_result_to_process_idx == b_results.size() - 1 or b_results.is_empty():
# 		handle_cbr_finished()
# 	else:
# 		curr_b_result_to_process_idx += 1
# 		process_curr_bonus()

# func process_curr_bonus():
# 	if b_results.size() > 0:
# 		var bonus_result = b_results[curr_b_result_to_process_idx] as StrategyCardBonus.BonusResult
# 		match bonus_result.bonus_type:
# 			StrategyCardBonus.StrategyCardBonusType.ROLL:
# 				var roll_br = bonus_result as RollBonus.RollBonusResult
# 				add_roll_bonus(roll_br)
# 	else:
# 		on_br_finished.emit()

# func add_roll_bonus(roll_br: RollBonus.RollBonusResult):
# 	var bonus_amount = roll_br.roll_bonus_amount
# 	matchup_container.set_roll_bonus_from_strat(bonus_amount, selected_strategy_card.strategy_card_config)
# 	on_br_finished.emit()

func on_close_selector():
	on_close.emit()
