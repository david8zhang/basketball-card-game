extends Node

var quarter_scores = {}
var full_cpu_scorer_statlines = {}
var full_player_scorer_statlines = {}
var player_score := 0
var cpu_score := 0
var player_team_bp_configs := {}
var player_strategy_card_deck := []
var cpu_team_bp_configs := {}
var salary_cap := 1750
var num_games_won := 0
var all_player_names = [
"DerrickWhite", "CarisLevert", "DomantasSabonis", "DeAaronFox", "DeAnthonyMelton", "JamalMurray", "CameronPayne", "DeanWade", "KentaviousCaldwellPope", "DavionMitchell", "ShaiGilgeousAlexander", "ChrisPaul", "JalenMcDaniels", "AnthonyLamb", "JaeCrowder", "CediOsman", "JamesHarden", "IvicaZubac", "CamThomas", "JoshOkogie", "DariusGarland", "JohnKonchar", "AndrewWiggins", "KawhiLeonard", "MalcolmBrogdon", "JoeIngles", "MichaelPorterJr", "AlHorford", "KlayThompson", "BruceBrown", "GrantWilliams", "AaronGordon", "JoelEmbiid", "JalenBrunson", "JoeHarris", "JockLandale", "JaylenBrown", "JaMorant", "JordanPoole", "DevinBooker", "DraymondGreen", "ImmanuelQuickley", "JevonCarter", "KevonLooney", "BobbyPortis", "GiannisAntetokounmpo", "JeffGreen", "JarenJacksonJr", "BonesHyland", "LukeKennard", "JaysonTatum", "MarcusSmart", "DorianFinneySmith", "IsaacOkoro", "GeorgesNiang", "MalikMonk", "BrandonClarke", "JuliusRandle", "JrueHoliday", "CameronJohnson", "BrookLopez", "DamionLee", "HarrisonBarnes", "LamarStevens", "ChristianBraun", "DesmondBane", "KeeganMurray", "KevinHuerter", "DeAndreAyton", "BenSimmons", "DillonBrooks", "JonathanKuminga", "EvanMobley", "DonovanMitchell", "IsaiahHartenstein", "MasonPlumlee", "GraysonAllen", "MikalBridges", "ChimezieMetu", "JoshHart", "KevinDurant", "DonteDivincenzo", "JarettAllen"
]
# var all_strategy_card_names = ["BlinkAndYoullMissHim", "HesHeatingUp", "Layup", "BoxingOut", "GoodPosition", "HalfCourtSet", "ChaseDownBlock", "AndOne", "DefensiveRebound", "KillerCrossover"]
var all_strategy_card_names = ["Jumper"]

var all_player_stat_configs: Array[BallPlayerStats] = []
var all_strat_card_configs: Array[StrategyCardConfig] = []

func _ready() -> void:
	for player_name in all_player_names:
		var stat_config = load("res://resources/players/" + player_name + ".tres") as BallPlayerStats
		all_player_stat_configs.append(stat_config)
	for strategy_name in SceneVariables.all_strategy_card_names:
		var strategy_card_config = load("res://resources/strategy/" + strategy_name + ".tres") as StrategyCardConfig
		all_strat_card_configs.append(strategy_card_config)

func get_player_max_cost_for_salary_cap(curr_salary_cap):
	if curr_salary_cap <= 1750:
		return 400
	elif curr_salary_cap > 1750 and curr_salary_cap <= 2250:
		return 650
	elif curr_salary_cap > 2250 and curr_salary_cap <= 2750:
		return 900
	elif curr_salary_cap > 3250 and curr_salary_cap <= 3750:
		return 1200
	else:
		return 2000

func get_players_for_salary_cap():
	var max_cost = get_player_max_cost_for_salary_cap(salary_cap)
	return all_player_stat_configs.filter(func (c): return c.player_cost <= max_cost)

func reset_player_data():
	quarter_scores = {}
	full_cpu_scorer_statlines = {}
	full_player_scorer_statlines = {}
	player_score = 0
	cpu_score = 0
	player_team_bp_configs = {}
	player_strategy_card_deck = []
	salary_cap = 1750
	num_games_won = 0

func instantiate_cpu_team():
	var position_to_players = {}
	for c in all_player_stat_configs:
		var stat_config = c as BallPlayerStats
		for position in stat_config.positions:
			if !position_to_players.has(position):
				position_to_players[position] = []
			position_to_players[position].append(stat_config)
	var selected_player_names = []
	for pos in position_to_players.keys():
		var players_to_select = filter_valid_players(position_to_players[pos], selected_player_names, salary_cap + 100)
		var player_to_add = players_to_select.pick_random() as BallPlayerStats
		selected_player_names.append(player_to_add.get_full_name())
		cpu_team_bp_configs[pos] = player_to_add

func filter_valid_players(players, selected_player_names, cap):
	return players.filter(func (p): return p.player_cost < get_player_max_cost_for_salary_cap(cap) and !selected_player_names.has(p.get_full_name()))

func get_players_for_position():
	var pos_to_bp_stat_map = {}
	for c in all_player_stat_configs:
		var config = c as BallPlayerStats
		for position in config.positions:
			if !pos_to_bp_stat_map.has(position):
				pos_to_bp_stat_map[position] = []
			pos_to_bp_stat_map[position].append(config)
	return pos_to_bp_stat_map

func assemble_random_lineup() -> Dictionary:
	var pos_to_player_map = {}
	var all_player_stats = get_players_for_position()
	var selected_players = []
	var positions = all_player_stats.keys()
	positions.sort()
	for pos in positions:
		var players_to_pick_from = filter_valid_players(all_player_stats[pos], selected_players, salary_cap)
		var random_player_stat = players_to_pick_from.pick_random() as BallPlayerStats
		pos_to_player_map[pos] = random_player_stat
		selected_players.append(random_player_stat.get_full_name())
	return pos_to_player_map

func get_player_lineup_or_gen_random_lineup():
	if player_team_bp_configs.is_empty():
		player_team_bp_configs = assemble_random_lineup()
	return player_team_bp_configs

func get_player_strat_card_deck_or_gen_random_deck():
	if player_strategy_card_deck.is_empty():
		for i in range(1, 3):
			player_strategy_card_deck.append(all_strat_card_configs.pick_random())
	return player_strategy_card_deck