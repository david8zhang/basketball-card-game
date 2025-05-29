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
const NUM_STRATEGY_CARDS = 3

var cb_results = []
var curr_cb_result_to_process_idx = 0
var c_results = []
var curr_c_result_to_process_idx = 0
var b_results = []
var curr_b_result_to_process_idx = 0

signal on_close
signal on_cr_finished
signal on_br_finished

func _init():
	for file_name in DirAccess.get_files_at("res://resources/strategy"):
		if (file_name.get_extension() == "tres"):
			var strategy_card_config = load("res://resources/strategy/" + file_name) as StrategyCardConfig
			all_strategy_card_configs.append(strategy_card_config)
	on_cr_finished.connect(handle_cr_finished)
	on_br_finished.connect(handle_br_finished)

func _ready():
	close_button.pressed.connect(on_close_selector)
	for i in range(0, NUM_STRATEGY_CARDS):
		var strategy_card = strategy_card_scene.instantiate() as StrategyCard
		var random_config = all_strategy_card_configs.pick_random()
		strategy_card.strategy_card_config = random_config
		strategy_card.on_card_selected.connect(select_strategy_card)
		card_container.add_child(strategy_card)

func select_strategy_card(sc: StrategyCard):
	cb_results = sc.strategy_card_config.process(off_player, def_player) as Array[StrategyCardConfig.ConditionBonusResult]
	process_curr_cb_result()

func handle_cbr_finished():
	if curr_cb_result_to_process_idx == cb_results.size() - 1:
		print("Finished processing all condition bonus results!")
		on_close.emit()
	else:
		curr_cb_result_to_process_idx += 1
		process_curr_cb_result()

func process_curr_cb_result():
	var curr_cb_result = cb_results[curr_cb_result_to_process_idx] as StrategyCardConfig.ConditionBonusResult
	c_results = curr_cb_result.condition_results as Array[StrategyCardCondition.ConditionResult]
	b_results = curr_cb_result.bonus_results as Array[StrategyCardBonus.BonusResult]
	process_curr_condition()

func handle_cr_finished():
	if curr_c_result_to_process_idx == c_results.size() - 1:
		process_curr_bonus()
	else:
		curr_c_result_to_process_idx += 1
		process_curr_condition()

func process_curr_condition():
	var condition_result = c_results[curr_c_result_to_process_idx] as StrategyCardCondition.ConditionResult
	match condition_result.condition_type:
		StrategyCardCondition.StrategyCardConditionType.DICE_ROLL:
			var dice_roll_cr = condition_result as DiceRollCondition.DiceRollConditionResult
			show_dice_roll(dice_roll_cr)

func show_dice_roll_result(dice_roll_window: DiceRoll):
	dice_roll_window.queue_free()
	on_cr_finished.emit()

func show_dice_roll(roll_result: DiceRollCondition.DiceRollConditionResult):
	var dice_roll_window = dice_roll_scene.instantiate() as DiceRoll
	add_child(dice_roll_window)
	var dice_roll_condition = roll_result.condition_ref as DiceRollCondition
	dice_roll_window.configure_dice_roll(dice_roll_condition, roll_result.result_type)
	dice_roll_window.roll_value(roll_result.dice_roll_result)
	var callable = Callable(self, "show_dice_roll_result").bind(dice_roll_window)
	dice_roll_window.on_roll_complete.connect(callable)

func handle_br_finished():
	if curr_b_result_to_process_idx == b_results.size() - 1 or b_results.is_empty():
		handle_cbr_finished()
	else:
		curr_b_result_to_process_idx += 1
		process_curr_bonus()

func process_curr_bonus():
	if b_results.size() > 0:
		var bonus_result = b_results[curr_b_result_to_process_idx] as StrategyCardBonus.BonusResult
		match bonus_result.bonus_type:
			StrategyCardBonus.StrategyCardBonusType.ROLL:
				var roll_br = bonus_result as RollBonus.RollBonusResult
				add_roll_bonus(roll_br)
	else:
		on_br_finished.emit()

func add_roll_bonus(roll_br: RollBonus.RollBonusResult):
	var bonus_amount = roll_br.roll_bonus_amount
	matchup_container.strategy_roll_bonuses = bonus_amount
	print("Add " + str(bonus_amount) + " to roll")
	on_br_finished.emit()

func on_close_selector():
	on_close.emit()
