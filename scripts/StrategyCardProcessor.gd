class_name StrategyCardProcessor
extends Node

@onready var strat_card_preview: StratCardPreview = $StratCardPreview
@export var strategy_bonuses_scene: PackedScene
@export var dice_roll_scene: PackedScene

var matchup_container: MatchupContainer
var node_results = []
var curr_node_result_to_process_idx = 0
var strategy_bonuses: StrategyBonuses
var selected_strategy_card: StrategyCard
var off_player: BallPlayerCard
var def_player: BallPlayerCard

signal before_apply_bonus
signal display_complete
signal on_strategy_card_selected(strategy_card_id: int)

func select_strategy_card(sc: StrategyCard):
	selected_strategy_card = sc
	on_strategy_card_selected.emit(sc.config_id)
	var callable = Callable(self, "on_display_complete")
	matchup_container.strategy_card_preview.show_strategy_card(sc, callable)

func on_display_complete():
	matchup_container.strategy_card_preview.hide_strategy_card()
	display_complete.emit()

func process_selected_card():
	var config = selected_strategy_card.strategy_card_config
	config.process(off_player, def_player)
	node_results = config.blackboard.node_results as Array[StrategyCardNode.NodeResult]
	process_curr_node_result()

func process_curr_node_result():
	if curr_node_result_to_process_idx > node_results.size() - 1:
		var strategy_type = selected_strategy_card.strategy_card_config.strategy_type
		matchup_container.on_strategy_card_processing_complete(strategy_type)
		return
	var curr_node_result = node_results[curr_node_result_to_process_idx] as StrategyCardNode.NodeResult
	if curr_node_result.node_ref.node_type == StrategyCardNode.NodeType.BONUS:
		if curr_node_result.result_type == StrategyCardNode.NodeResultType.FAILURE:
			curr_node_result_to_process_idx += 1
			process_curr_node_result()
		else:
			process_bonus_node_result(curr_node_result)
	elif curr_node_result.node_ref.node_type == StrategyCardNode.NodeType.ACTION:
		process_action_node_result(curr_node_result)
	else:
		curr_node_result_to_process_idx += 1
		process_curr_node_result()

func process_bonus_node_result(curr_node_result: StrategyCardNode.NodeResult):
	var node = curr_node_result.node_ref as StrategyCardBonusNode
	if strategy_bonuses == null or !is_instance_valid(strategy_bonuses):
		strategy_bonuses = strategy_bonuses_scene.instantiate() as StrategyBonuses
		matchup_container.add_child(strategy_bonuses)
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
		StrategyCardBonusNode.BonusType.BOX_SCORE:
			var box_score_bonus = node as BoxScoreBonus
			var suffix = "(Offense)" if box_score_bonus.target_side == BoxScoreBonus.TargetSide.OFFENSE else "(Defense)"
			match (box_score_bonus.bonus_stat_type):
				BoxScoreBonus.StatType.POINTS:
					strategy_bonuses.add_bonus_line("Points " + suffix, box_score_bonus.bonus_amt)
				BoxScoreBonus.StatType.ASSISTS:
					strategy_bonuses.add_bonus_line("Assists " + suffix, box_score_bonus.bonus_amt)
				BoxScoreBonus.StatType.REBOUNDS:
					strategy_bonuses.add_bonus_line("Rebounds " + suffix, box_score_bonus.bonus_amt)
		StrategyCardBonusNode.BonusType.ROLL:
			var roll_bonus = node as RollBonus
			var prefix = ""
			match (roll_bonus.roll_bonus_type):
				RollBonus.RollBonusType.OFF_DIFF:
					prefix = "(Off. Bonus)"
				RollBonus.RollBonusType.DEF_DIFF:
					prefix = "(Def. Bonus)"
				RollBonus.RollBonusType.THREE_PT_BONUS:
					prefix = "(3-Pt. Bonus)"
			strategy_bonuses.add_bonus_line("Roll", roll_bonus.roll_bonus_amount, prefix)
		StrategyCardBonusNode.BonusType.NOOP:
			strategy_bonuses.show_failure_message()

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
	matchup_container.add_child(dice_roll_window)
	dice_roll_window.configure_dice_roll(roll_dice_action)
	dice_roll_window.roll_value(roll_dice_action.dice_roll_result)
	var callable = Callable(self, "show_dice_roll_result").bind(dice_roll_window)
	dice_roll_window.on_roll_complete.connect(callable)

func apply_bonuses():
	strategy_bonuses.queue_free()
	strategy_bonuses = null
	# Signal that allows StrategyCardSelector to hook in and close itself
	var strategy_type = selected_strategy_card.strategy_card_config.strategy_type
	var on_bonus_finished = func _on_bonus_finished():
		curr_node_result_to_process_idx += 1
		process_curr_node_result()
	var node = node_results[curr_node_result_to_process_idx]
	matchup_container.apply_single_bonus(node.node_ref, strategy_type, on_bonus_finished)
