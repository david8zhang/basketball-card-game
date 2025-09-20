class_name CPUTeam
extends Node

@onready var game = get_node("/root/Main") as Game
@onready var strategy_card_deck = $StrategyCardDeck as StrategyCardDeck
@export var strategy_card_processor_scene: PackedScene
@export var strategy_card_scene: PackedScene
@export var starting_lineup_scene: PackedScene
@export var starting_lineup_wrapper: VBoxContainer

var strategy_card: StrategyCard
var starting_lineup: StartingLineup
var strategy_card_processor: StrategyCardProcessor
var cards_in_play = []

func _ready():
	if starting_lineup_wrapper != null:
		starting_lineup = starting_lineup_scene.instantiate() as StartingLineup
		starting_lineup_wrapper.add_child(starting_lineup)
		if SceneVariables.cpu_team_bp_configs.is_empty():
			SceneVariables.instantiate_cpu_team()
		starting_lineup.init_cards(SceneVariables.cpu_team_bp_configs)
	cards_in_play = starting_lineup.starting_lineup_cards	

func get_card_at_position(pos: BallPlayerStats.PlayerPosition):
	return starting_lineup.get_card_at_position(pos)

func get_starting_cards():
	return starting_lineup.starting_lineup_cards

func get_cards_in_play():
	return cards_in_play

func get_strategy_card_deck() -> Array[StrategyCardConfig]:
	return strategy_card_deck.cards_in_play

func use_strategy_card(matchup_container: MatchupContainer, rand_index: int, cards_to_pick_from):
	if strategy_card != null:
		strategy_card.queue_free()
	strategy_card_processor = strategy_card_processor_scene.instantiate() as StrategyCardProcessor
	add_child(strategy_card_processor)
	var card_to_use_config_wrapper = cards_to_pick_from[rand_index]
	strategy_card = strategy_card_scene.instantiate() as StrategyCard
	add_child(strategy_card)
	strategy_card.global_position = Vector2(1200, 240)
	strategy_card.hide()
	strategy_card.strategy_card_config = card_to_use_config_wrapper.config
	strategy_card.config_id = card_to_use_config_wrapper.config_id
	strategy_card_processor.matchup_container = matchup_container
	strategy_card_processor.off_player = matchup_container.get_off_player_card()
	strategy_card_processor.def_player = matchup_container.get_def_player_card()
	strategy_card_processor.on_strategy_card_selected.connect(strategy_card_deck.on_strategy_card_selected)
	strategy_card_processor.display_complete.connect(strategy_card_processor.process_selected_card)
	strategy_card_processor.select_strategy_card(strategy_card)

func handle_substitutions():
	var bp_to_switch_out = []
	var cpu_team_bp_data_cache = SceneVariables.cpu_team_bp_data_cache
	# Switch out players that have either 0 or 1 stamina
	# For 1 stamina players, switch out with a 50/50 chance
	for p in cards_in_play:
		var bp = p as BallPlayerCard
		var cached_data = cpu_team_bp_data_cache[bp.get_full_name()]
		if cached_data["stamina"] == 0:
			bp_to_switch_out.append(bp)
		elif cached_data["stamina"] == 1:
			var should_switch = randi_range(0, 1) == 1
			if should_switch:
				bp_to_switch_out.append(bp)

	# For each player to switch out, check if there are any viable subs not currently in play
	var all_bp_stats = SceneVariables.cpu_team_bp_configs.values() + SceneVariables.cpu_team_bench
	var cards_in_play_names = cards_in_play.map(func (bp: BallPlayerCard): return bp.get_full_name())
	var not_in_play_stats = all_bp_stats.filter(func (bps: BallPlayerStats): return !cards_in_play_names.has(bps.get_full_name()))
	var subs_mapping = {}
	for p in bp_to_switch_out:
		var bp = p as BallPlayerCard
		var subs_for_position = get_subs_for_position(not_in_play_stats, bp, subs_mapping)
		if !subs_for_position.is_empty():
			var sub = subs_for_position.pick_random()
			subs_mapping[bp.get_full_name()] = sub.get_full_name()

	print(subs_mapping)
	
	# Make the actual substitution
	for k in subs_mapping.keys():
		var bp_stat_to_sub_out = Game.get_bps_by_name(k, all_bp_stats)
		var bp_stat_to_sub_in = Game.get_bps_by_name(subs_mapping[k], all_bp_stats)
		var pos = Game.get_pos_for_bps(k, SceneVariables.cpu_team_bp_configs)
		SceneVariables.cpu_team_bp_configs[pos] = bp_stat_to_sub_in
		SceneVariables.cpu_team_bench = SceneVariables.cpu_team_bench.filter(func (bps: BallPlayerStats): return bps.get_full_name() == subs_mapping[k])
		SceneVariables.cpu_team_bench.append(bp_stat_to_sub_out)
	starting_lineup.re_init_cards(SceneVariables.cpu_team_bp_configs)
	cards_in_play = starting_lineup.starting_lineup_cards


func get_subs_for_position(not_in_play_stats: Array, bp: BallPlayerCard, subs_mapping: Dictionary):
	var bp_to_sub_out_stats = bp.ball_player_stats
	
	# Check for benched players that play the same position as player in question
	var subs_for_position = not_in_play_stats.filter(func (bps: BallPlayerStats): return _intersect(bps.positions, bp_to_sub_out_stats.positions))
	
	# Check that the subbed player is not already being subbed out
	subs_for_position = subs_for_position.filter(func (sub: BallPlayerStats): return !subs_mapping.values().has(sub.get_full_name()))

	# Check that the subbed player has more stamina than the current player
	subs_for_position = subs_for_position.filter(func (sub: BallPlayerStats): return get_curr_stamina(sub) >= get_curr_stamina(bp.ball_player_stats))
	return subs_for_position
	
func _intersect(arr1: Array, arr2: Array):
	return arr1.filter(func (p): return arr2.has(p)).size() > 0

func get_curr_stamina(bps: BallPlayerStats):
	var cached_data = SceneVariables.cpu_team_bp_data_cache
	return cached_data[bps.get_full_name()]["stamina"]
