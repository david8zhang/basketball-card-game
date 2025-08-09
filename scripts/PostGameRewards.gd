class_name PostGameRewards
extends Control

@onready var salary_cap_incr_amt = $VBoxContainer/HBoxContainer/SalaryCapIncrAmt
@onready var reward_container = $VBoxContainer/HBoxContainer2
@onready var skip_button = $Button as Button

@export var strategy_card_scene: PackedScene
@export var bp_card_scene: PackedScene
@export var add_new_player_modal_scene: PackedScene

func _ready() -> void:
	SceneVariables.salary_cap += 100
	salary_cap_incr_amt.text = "+100 " + "(" + str(SceneVariables.salary_cap) + ")"
	init_rewards()
	skip_button.pressed.connect(on_skip_reward)

func init_rewards():
	var players_to_pick_from = SceneVariables.get_players_for_salary_cap()
	var players_to_exclude = SceneVariables.player_team_bp_configs.values().map(func (p): return p.get_full_name())
	for i in range(0, 3):
		var rand_num = randi_range(0, 1)
		if rand_num == 0:
			players_to_pick_from = players_to_pick_from.filter(func (p): return !players_to_exclude.has(p.get_full_name()))
			var rand_bp_config = players_to_pick_from.pick_random() as BallPlayerStats
			var rand_bp_card = bp_card_scene.instantiate() as BallPlayerCard
			rand_bp_card.ball_player_stats = rand_bp_config
			rand_bp_card.on_bp_card_clicked.connect(show_add_player_modal)
			reward_container.add_child(rand_bp_card)
			players_to_exclude.append(rand_bp_config.get_full_name())
		else:
			var rand_strat_card_config = SceneVariables.all_strat_card_configs.pick_random()
			var strat_card = strategy_card_scene.instantiate() as StrategyCard
			strat_card.strategy_card_config = rand_strat_card_config
			strat_card.on_clicked.connect(on_add_strat_card)
			reward_container.add_child(strat_card)

func show_add_player_modal(bp_card: BallPlayerCard):
	var add_new_player_modal = add_new_player_modal_scene.instantiate() as AddNewPlayerModal
	add_child(add_new_player_modal)
	add_new_player_modal.on_add_player.connect(on_add_player)
	add_new_player_modal.set_bp_stat_to_add(bp_card.ball_player_stats)
	add_new_player_modal.show()

func on_add_player(new_lineup):
	SceneVariables.player_team_bp_configs = new_lineup
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func on_add_strat_card(strat_card: StrategyCard):
	SceneVariables.player_strategy_card_deck.append(strat_card.strategy_card_config)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func on_skip_reward():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
