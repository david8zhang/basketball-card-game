class_name Game
extends Node2D

enum Side {
	PLAYER,
	CPU
}

var all_player_stats = {}
var selected_player_bp_card: BallPlayerCard
var selected_cpu_bp_card: BallPlayerCard

var player_completed_scorers = []
var cpu_completed_scorers = []

@onready var player_team: PlayerTeam = $PlayerTeam as PlayerTeam
@onready var cpu_team: CPUTeam = $CPUTeam as CPUTeam
@onready var canvas_layer: CanvasLayer = $CanvasLayer as CanvasLayer

@onready var player_score_label = $CanvasLayer/Scoreboard/PlayerScore as Label
@onready var player_assists_label = $CanvasLayer/Scoreboard/PlayerAssists as Label
@onready var player_rebounds_label = $CanvasLayer/Scoreboard/PlayerRebounds as Label

@onready var cpu_score_label = $CanvasLayer/Scoreboard/CPUScore as Label
@onready var cpu_assists_label = $CanvasLayer/Scoreboard/CPUAssists as Label
@onready var cpu_rebounds_label = $CanvasLayer/Scoreboard/CPURebounds as Label

@export var matchup_container_scene: PackedScene
var matchup_container: MatchupContainer

# Called when the node enters the scene tree for the first time.
func _init():
	for file_name in DirAccess.get_files_at("res://resources"):
		if (file_name.get_extension() == "tres"):
			var stat_config = load("res://resources/" + file_name) as BallPlayerStats
			for p in stat_config.positions:
				if p not in all_player_stats:
					all_player_stats[p] = []
				all_player_stats[p].append(stat_config)

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
	if !player_completed_scorers.has(card.get_assigned_position()):
		selected_player_bp_card = card
		var opp_matchup_bp_card = cpu_team.get_card_at_position(selected_player_bp_card.get_assigned_position())
		matchup_container = matchup_container_scene.instantiate() as MatchupContainer
		canvas_layer.add_child(matchup_container)
		matchup_container.set_player_card(card)
		matchup_container.set_cpu_card(opp_matchup_bp_card)
		matchup_container.set_offense_side(Side.PLAYER)
		matchup_container.matchup_complete.connect(on_matchup_complete)
		matchup_container.show()

func cpu_select_card_to_score_with():
	var cpu_cards = cpu_team.starting_lineup.starting_lineup_cards
	var cards_to_score_with = cpu_cards.filter(func(c): return !cpu_completed_scorers.has(c.get_assigned_position()))
	selected_cpu_bp_card = cards_to_score_with.pick_random()
	var opp_matchup_bp_card = player_team.get_card_at_position(selected_cpu_bp_card.get_assigned_position())
	matchup_container = matchup_container_scene.instantiate() as MatchupContainer
	canvas_layer.add_child(matchup_container)
	matchup_container.set_player_card(opp_matchup_bp_card)
	matchup_container.set_cpu_card(selected_cpu_bp_card)
	matchup_container.set_offense_side(Side.CPU)
	matchup_container.matchup_complete.connect(on_matchup_complete)
	matchup_container.show()


func on_matchup_complete(all_stats: Dictionary, side: Side):
	add_stats_from_matchup(all_stats, side)
	if side == Side.PLAYER:
		cpu_select_card_to_score_with()

func add_stats_from_matchup(all_stats: Dictionary, side: Side):
	if side == Side.PLAYER:
		player_completed_scorers.append(selected_player_bp_card.get_assigned_position())
		selected_player_bp_card.button.flat = false
		player_score_label.text = str(int(player_score_label.text) + all_stats["points"])
		player_assists_label.text = "A: " + str(int(player_assists_label.text) + all_stats["assists"])
		player_rebounds_label.text = "R: " + str(int(player_rebounds_label.text) + all_stats["rebounds"])
	elif side == Side.CPU:
		cpu_completed_scorers.append(selected_cpu_bp_card.get_assigned_position())
		selected_cpu_bp_card.button.flat = false
		cpu_score_label.text = str(int(cpu_score_label.text) + all_stats["points"])
		cpu_assists_label.text = "A: " + str(int(cpu_assists_label.text) + all_stats["assists"])
		cpu_rebounds_label.text = "R: " + str(int(cpu_rebounds_label.text) + all_stats["rebounds"])
