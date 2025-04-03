class_name Game
extends Node2D

enum Side {
	PLAYER,
	CPU
}

var all_player_stats = {}
var selected_player_bp_card: BallPlayerCard
var selected_cpu_bp_card: BallPlayerCard

@onready var matchup_container: MatchupContainer = $CanvasLayer/MatchupContainer

# Called when the node enters the scene tree for the first time.
func _init():
	for file_name in DirAccess.get_files_at("res://resources"):
		if (file_name.get_extension() == "tres"):
			var stat_config = load("res://resources/" + file_name) as BallPlayerStats
			for p in stat_config.positions:
				if p not in all_player_stats:
					all_player_stats[p] = []
				all_player_stats[p].append(stat_config)

func _ready():
	matchup_container.hide()

func assemble_random_lineup() -> Array[BallPlayerStats]:
	var player_stats: Array[BallPlayerStats] = []
	var positions = all_player_stats.keys()
	positions.sort()
	for pos in positions:
		var players_to_pick_from = all_player_stats[pos].filter(func(p): return !player_stats.has(p))
		var random_player_stat = players_to_pick_from.pick_random() as BallPlayerStats
		player_stats.append(random_player_stat)
	return player_stats

func player_select_card_to_score_with(card: BallPlayerCard):
	selected_player_bp_card = card
	matchup_container.set_player_card(card)
	matchup_container.show()
