class_name Game
extends Node2D

enum Side {
	PLAYER,
	CPU
}

var all_player_stats = {}
var selected_player_bp_card: BallPlayerCard
var selected_cpu_bp_card: BallPlayerCard

var player_completed_scorer_positions = []
var full_player_scorer_statlines = {}
var cpu_completed_scorer_positions = []
var full_cpu_scorer_statlines = {}

@onready var player_team: PlayerTeam = $PlayerTeam as PlayerTeam
@onready var cpu_team: CPUTeam = $CPUTeam as CPUTeam
@onready var canvas_layer: CanvasLayer = $CanvasLayer as CanvasLayer
@onready var player_score_label = $CanvasLayer/Scoreboard/PlayerScore as Label
@onready var player_assists_label = $CanvasLayer/Scoreboard/PlayerAssists as Label
@onready var player_rebounds_label = $CanvasLayer/Scoreboard/PlayerRebounds as Label
@onready var cpu_score_label = $CanvasLayer/Scoreboard/CPUScore as Label
@onready var cpu_assists_label = $CanvasLayer/Scoreboard/CPUAssists as Label
@onready var cpu_rebounds_label = $CanvasLayer/Scoreboard/CPURebounds as Label
@onready var quarter_label = $CanvasLayer/QuarterLabel as Label

@export var matchup_container_scene: PackedScene
@export var quarter_end_modal_scene: PackedScene
@export var rebound_tally_scene: PackedScene

var matchup_container: MatchupContainer
var quarter_end_modal: QuarterEnd
var quarter_number: int = 1
var quarter_scores = {
	"player": [],
	"cpu": []
}
var curr_player_quarter_score := 0
var curr_cpu_quarter_score := 0
var is_cpu_scoring := false

class BoxScoreStatLine:
	var full_name: String
	var points: int
	var assists: int
	var rebounds: int

	func _init(_full_name: String, _points: int, _assists: int, _rebounds: int):
		full_name = _full_name
		points = _points
		assists = _assists
		rebounds = _rebounds

# Called when the node enters the scene tree for the first time.
func _init():
	for file_name in DirAccess.get_files_at("res://resources/players"):
		if (file_name.get_extension() == "tres"):
			var stat_config = load("res://resources/players/" + file_name) as BallPlayerStats
			for p in stat_config.positions:
				if p not in all_player_stats:
					all_player_stats[p] = []
				all_player_stats[p].append(stat_config)

# func _ready():
# 	_tally_rebound_test()

func _tally_rebound_test():
	var player_score_data = {
		"points": 15,
		"rebounds": 3,
		"assists": 2
	}
	var cpu_score_data = {
		"points": 15,
		"rebounds": 3,
		"assists": 2
	}
	var reb_tally = rebound_tally_scene.instantiate() as ReboundTally
	canvas_layer.add_child(reb_tally)
	reb_tally.update_scoreboard(player_score_data, cpu_score_data)
	var cb = Callable(self, "on_tally_finished")
	reb_tally.tally_rebounds(cb)

func on_tally_finished():
	pass

func assemble_random_lineup() -> Dictionary:
	var pos_to_player_map = {}
	var picked_players = []
	var positions = all_player_stats.keys()
	positions.sort()

	var remove_invalid_players = func (p):
		var player_name = p.first_name + " " + p.last_name
		return !pos_to_player_map.values().has(p) and !picked_players.has(player_name)
	
	for pos in positions:
		var players_to_pick_from = all_player_stats[pos].filter(remove_invalid_players)
		var random_player_stat = players_to_pick_from.pick_random() as BallPlayerStats
		pos_to_player_map[pos] = random_player_stat
		picked_players.append(random_player_stat.first_name + " " + random_player_stat.last_name)
	return pos_to_player_map

func player_select_card_to_score_with(card: BallPlayerCard):
	if !player_completed_scorer_positions.has(card.get_assigned_position()) and !is_cpu_scoring:
		selected_player_bp_card = card
		var opp_matchup_bp_card = cpu_team.get_card_at_position(selected_player_bp_card.get_assigned_position())
		matchup_container = matchup_container_scene.instantiate() as MatchupContainer
		canvas_layer.add_child(matchup_container)
		matchup_container.set_player_card(card)
		matchup_container.set_cpu_card(opp_matchup_bp_card)
		matchup_container.set_offense_side(Side.PLAYER)
		matchup_container.set_curr_assists(get_assists(player_assists_label))
		matchup_container.matchup_complete.connect(on_matchup_complete)
		matchup_container.show()

func cpu_select_card_to_score_with():
	is_cpu_scoring = true
	var cpu_cards = cpu_team.starting_lineup.starting_lineup_cards
	var cards_to_score_with = cpu_cards.filter(func(c): return !cpu_completed_scorer_positions.has(c.get_assigned_position()))
	selected_cpu_bp_card = cards_to_score_with.pick_random()
	
	# Play a little animation indicating a card was chosen
	var on_zoom_out_finished = func():
		var opp_matchup_bp_card = player_team.get_card_at_position(selected_cpu_bp_card.get_assigned_position())
		matchup_container = matchup_container_scene.instantiate() as MatchupContainer
		canvas_layer.add_child(matchup_container)
		matchup_container.set_player_card(opp_matchup_bp_card)
		matchup_container.set_cpu_card(selected_cpu_bp_card)
		matchup_container.set_offense_side(Side.CPU)
		matchup_container.set_curr_assists(get_assists(cpu_assists_label))
		matchup_container.matchup_complete.connect(on_matchup_complete)
		matchup_container.enable_use_assists()
		matchup_container.show()
		matchup_container.init_cpu_roll()
		matchup_container.cpu_use_off_strategy_card()

	var on_hold_finished = func():
		var zoom_out_card = create_tween()
		zoom_out_card.tween_property(selected_cpu_bp_card, "scale", Vector2(1, 1), 0.25)
		zoom_out_card.finished.connect(on_zoom_out_finished)

	var on_zoomed = func():
		var zoom_hold_timer = Timer.new()
		zoom_hold_timer.wait_time = 1.0
		zoom_hold_timer.autostart = true
		zoom_hold_timer.one_shot = true
		zoom_hold_timer.timeout.connect(on_hold_finished)
		add_child(zoom_hold_timer)

	var zoom_in_card = create_tween()
	zoom_in_card.tween_property(selected_cpu_bp_card, "scale", Vector2(1.05, 1.05), 0.25)
	zoom_in_card.finished.connect(on_zoomed)

func on_matchup_complete(all_stats: Dictionary, side: Side, assists_used: int):
	process_matchup_stats(all_stats, side, assists_used)
	if is_quarter_completed():
		is_cpu_scoring = false
		var rebound_tally = rebound_tally_scene.instantiate() as ReboundTally
		canvas_layer.add_child(rebound_tally)
		rebound_tally.hide()
		var on_rebound_tally_complete = func():
			var player_reb = get_rebounds(player_rebounds_label)
			var cpu_reb = get_rebounds(cpu_rebounds_label)
			curr_player_quarter_score += player_reb
			curr_cpu_quarter_score += cpu_reb
			player_score_label.text = str(get_player_score() + player_reb)
			cpu_score_label.text = str(get_cpu_score() + cpu_reb)
			rebound_tally.queue_free()
			show_quarter_end_info_modal()
		handle_rebound_tally(rebound_tally, on_rebound_tally_complete)
	elif side == Side.PLAYER:
		cpu_select_card_to_score_with()
	else:
		is_cpu_scoring = false

func handle_rebound_tally(rebound_tally: ReboundTally, cb: Callable):
	var player_score_data = {
		"points": get_player_score(),
		"assists": get_assists(player_assists_label),
		"rebounds": get_rebounds(player_rebounds_label)
	}
	var cpu_score_data = {
		"points": get_cpu_score(),
		"assists": get_assists(cpu_assists_label),
		"rebounds": get_rebounds(cpu_rebounds_label)
	}
	rebound_tally.show()
	rebound_tally.update_scoreboard(player_score_data, cpu_score_data)
	rebound_tally.tally_rebounds(cb)

func show_quarter_end_info_modal():
	quarter_scores["player"].append(curr_player_quarter_score)
	quarter_scores["cpu"].append(curr_cpu_quarter_score)
	curr_player_quarter_score = 0
	curr_cpu_quarter_score = 0
	if quarter_number == 4:
		SceneVariables.quarter_scores = quarter_scores
		SceneVariables.full_cpu_scorer_statlines = full_cpu_scorer_statlines
		SceneVariables.full_player_scorer_statlines = full_player_scorer_statlines
		SceneVariables.player_score = get_player_score()
		SceneVariables.cpu_score = get_cpu_score()
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
	else:
		quarter_end_modal = quarter_end_modal_scene.instantiate() as QuarterEnd
		canvas_layer.add_child(quarter_end_modal)
		quarter_end_modal.update_scores(get_player_score(), get_cpu_score())
		quarter_end_modal.update_player_box_score(full_player_scorer_statlines)
		quarter_end_modal.update_cpu_box_score(full_cpu_scorer_statlines)
		quarter_end_modal.update_quarter_number(quarter_number)
		var callable = Callable(self, "on_new_quarter_start")
		quarter_end_modal.continue_button.pressed.connect(callable)

func is_quarter_completed():
	var player_lineup_cards = player_team.get_starting_cards()
	var cpu_lineup_cards = cpu_team.get_starting_cards()
	return player_lineup_cards.size() == player_completed_scorer_positions.size() and \
		cpu_lineup_cards.size() == cpu_completed_scorer_positions.size()

func get_player_score():
	return int(player_score_label.text)

func get_cpu_score():
	return int(cpu_score_label.text)

func get_rebounds(rebounds_label: Label) -> int:
	var rebounds_value = rebounds_label.text.split(": ")
	if rebounds_value.size() > 1:
		return int(rebounds_value[1])
	return 0

func get_assists(assists_label: Label) -> int:
	var assists_value = assists_label.text.split(": ")
	if assists_value.size() > 1:
		return int(assists_value[1])
	return 0

func process_matchup_stats(all_stats: Dictionary, side: Side, assists_used: int):
	if side == Side.PLAYER:
		var full_name = selected_player_bp_card.full_name()
		var stat_line = BoxScoreStatLine.new(full_name, all_stats["points"], all_stats["assists"], all_stats["rebounds"])
		update_statlines(full_name, stat_line, full_player_scorer_statlines)
		player_completed_scorer_positions.append(selected_player_bp_card.get_assigned_position())
		selected_player_bp_card.marker.copy_from_marker(matchup_container.player_card.marker)
		selected_player_bp_card.button.flat = false
		player_score_label.text = str(int(player_score_label.text) + all_stats["points"])
		player_assists_label.text = "A: " + str(get_assists(player_assists_label) - assists_used + all_stats["assists"])
		player_rebounds_label.text = "R: " + str(get_rebounds(player_rebounds_label) + all_stats["rebounds"])
		curr_player_quarter_score += all_stats["points"]
	elif side == Side.CPU:
		var full_name = selected_cpu_bp_card.full_name()
		var stat_line = BoxScoreStatLine.new(full_name, all_stats["points"], all_stats["assists"], all_stats["rebounds"])
		update_statlines(full_name, stat_line, full_cpu_scorer_statlines)
		cpu_completed_scorer_positions.append(selected_cpu_bp_card.get_assigned_position())
		selected_cpu_bp_card.marker.copy_from_marker(matchup_container.cpu_card.marker)
		selected_cpu_bp_card.button.flat = false
		cpu_score_label.text = str(int(cpu_score_label.text) + all_stats["points"])
		cpu_assists_label.text = "A: " + str(get_assists(cpu_assists_label) - assists_used + all_stats["assists"])
		cpu_rebounds_label.text = "R: " + str(get_rebounds(cpu_rebounds_label) + all_stats["rebounds"])
		curr_cpu_quarter_score += all_stats["points"]
	matchup_container.queue_free()

# If defensive player uses a card that increases stats
func add_def_box_score_bonuses(side: Side, stat_type: BoxScoreBonus.StatType, value: int):
	var score_label = player_score_label if side == Side.PLAYER else cpu_score_label
	var assists_label = player_assists_label if side == Side.PLAYER else cpu_assists_label
	var rebounds_label = player_rebounds_label if side == Side.PLAYER else cpu_rebounds_label
	match stat_type:
		BoxScoreBonus.StatType.POINTS:
			score_label.text = str(int(player_score_label.text) + value)
		BoxScoreBonus.StatType.REBOUNDS:
			rebounds_label.text = "R:" + str(get_rebounds(rebounds_label) + value)
		BoxScoreBonus.StatType.ASSISTS:
			assists_label.text = "A:" + str(get_assists(assists_label)+ value)

func update_statlines(full_name: String, stat_line: BoxScoreStatLine, scorer_statline: Dictionary):
	if scorer_statline.has(full_name):
		var stat_line_to_update = scorer_statline[full_name] as BoxScoreStatLine
		stat_line_to_update.points += stat_line.points
		stat_line_to_update.assists += stat_line.assists
		stat_line_to_update.rebounds += stat_line.rebounds
	else:
		scorer_statline[full_name] = stat_line

func on_new_quarter_start():
	reset_rebounds()
	reset_assists()
	quarter_number += 1
	quarter_label.text = "Q" + str(quarter_number)
	player_completed_scorer_positions = []
	cpu_completed_scorer_positions = []
	quarter_end_modal.queue_free()
	for card in player_team.get_starting_cards():
		card.button.flat = true
	for card in cpu_team.get_starting_cards():
		card.button.flat = true

func reset_rebounds():
	player_rebounds_label.text = "R: 0"
	cpu_rebounds_label.text = "R: 0"

func reset_assists():
	player_assists_label.text = "A: 0"
	cpu_assists_label.text = "A: 0"
