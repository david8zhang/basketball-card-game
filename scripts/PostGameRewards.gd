class_name PostGameRewards
extends Control

@onready var salary_cap_incr_amt = $VBoxContainer/HBoxContainer/SalaryCapIncrAmt
@onready var reward_container = $VBoxContainer/HBoxContainer2
@onready var skip_button = $Button as Button
@onready var lineup_preview = $LineupPreview as LineupPreview
@onready var matchup_preview = $MatchupPreview as MatchupPreview

@export var strategy_card_scene: PackedScene
@export var bp_card_scene: PackedScene
@export var add_new_player_modal_scene: PackedScene

var has_generated_new_cpu_lineup := false

func _ready() -> void:
	SceneVariables.salary_cap += 150
	salary_cap_incr_amt.text = "+150 " + "(" + str(SceneVariables.salary_cap) + ")"
	init_rewards()
	skip_button.pressed.connect(on_skip_reward)
	lineup_preview.hide()
	matchup_preview.hide()

func init_rewards():
	var players_for_salary_cap = SceneVariables.get_players_for_salary_cap()
	var max_cost = SceneVariables.get_player_max_cost_for_salary_cap(SceneVariables.salary_cap)
	var players_to_exclude = SceneVariables.player_team_bp_configs.values().map(func (p): return p.get_full_name())
	var players_to_pick_from = SceneVariables.get_best_players(players_for_salary_cap, max_cost, players_to_exclude)
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

func on_add_player():
	show_matchup_preview()

func on_add_strat_card(strat_card: StrategyCard):
	SceneVariables.player_strategy_card_deck.append(strat_card.strategy_card_config)
	show_matchup_preview()

func on_skip_reward():
	show_matchup_preview()

func go_to_next_scene():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

# Show preview of player lineup vs. cpu lineup
func show_matchup_preview():
	if !has_generated_new_cpu_lineup:
		SceneVariables.instantiate_cpu_team()	
		has_generated_new_cpu_lineup = true
	if matchup_preview.on_continue_clicked.get_connections().is_empty():
		var on_continue = func _on_continue():
			matchup_preview.hide()
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
		matchup_preview.on_continue_clicked.connect(on_continue)
	if matchup_preview.on_edit_lineups_clicked.get_connections().is_empty():
		var on_edit_lineups = func _on_edit_lineups():
			matchup_preview.hide()
			show_subs_modal()
		matchup_preview.on_edit_lineups_clicked.connect(on_edit_lineups)
	matchup_preview.update_lineups()
	matchup_preview.show()

func show_subs_modal():
	lineup_preview.allow_replacement = true
	if lineup_preview.on_exit_pressed.get_connections().is_empty():
		var on_exit = func _on_exit():
			lineup_preview.hide()
			show_matchup_preview()
		lineup_preview.on_exit_pressed.connect(on_exit)
	lineup_preview.show()
