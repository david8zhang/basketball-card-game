class_name Game
extends Node2D

enum Side {
	PLAYER,
	CPU
}

var all_player_stats = {}

# Called when the node enters the scene tree for the first time.
func _init():
	for file_name in DirAccess.get_files_at("res://resources"):
		if (file_name.get_extension() == "tres"):
			var stat_config = load("res://resources/" + file_name) as BallPlayerStats
			for p in stat_config.positions:
				if p not in all_player_stats:
					all_player_stats[p] = []
				all_player_stats[p].append(stat_config)


func assemble_random_lineup() -> Array[BallPlayerStats]:
	var player_stats: Array[BallPlayerStats] = []
	var positions = all_player_stats.keys()
	positions.sort()
	for p in positions:
		var random_player_stat = all_player_stats[p].pick_random() as BallPlayerStats
		player_stats.append(random_player_stat)
	print(player_stats)
	return player_stats
