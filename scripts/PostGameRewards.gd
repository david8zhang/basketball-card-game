class_name PostGameRewards
extends Control

@onready var salary_cap_incr_amt = $VBoxContainer/HBoxContainer/SalaryCapIncrAmt
@onready var reward_container = $VBoxContainer/HBoxContainer2
@export var strategy_card_scene: PackedScene
@export var bp_card_scene: PackedScene

func _ready() -> void:
	SceneVariables.salary_cap += 100
	salary_cap_incr_amt.text = "+100 " + "(" + str(SceneVariables.salary_cap) + ")"
	init_rewards()

func init_rewards():
	var players_to_pick_from = SceneVariables.get_players_for_salary_cap()
	for i in range(0, 3):
		var rand_num = randi_range(0, 1)
		if rand_num == 0:
			var rand_bp_config = players_to_pick_from.pick_random()
			var rand_bp_card = bp_card_scene.instantiate() as BallPlayerCard
			rand_bp_card.ball_player_stats = rand_bp_config
			reward_container.add_child(rand_bp_card)
		else:
			var rand_strat_card_config = SceneVariables.all_strat_card_configs.pick_random()
			var strat_card = strategy_card_scene.instantiate() as StrategyCard
			strat_card.strategy_card_config = rand_strat_card_config
			reward_container.add_child(strat_card)
