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
"CalebMartin", "DerrickWhite", "CarisLevert", "DomantasSabonis", "CJMcCollum", "NormanPowell", "DeAaronFox", "JadenMcDaniels", "HaywoodHighsmith", "DeAnthonyMelton", "OnyekaOkongwu", "RoyceONeal", "ObiToppin", "TreMann", "TerenceDavis", "ScottieBarnes", "JamalMurray", "SethCurry", "CameronPayne", "DemarDeRozan", "DeanWade", "KentaviousCaldwellPope", "DavionMitchell", "TerrenceRoss", "TeranceMann", "ShaiGilgeousAlexander", "ChrisPaul", "AndreDrummond", "JalenJohnson", "PatrickWilliams", "NicolasBatum", "JalenMcDaniels", "AnthonyLamb", "JaeCrowder", "CediOsman", "RussellWestbrook", "RudyGobert", "KyleLowry", "JamesHarden", "IvicaZubac", "CamThomas", "FredVanvleet", "JoshOkogie", "RobertCovington", "ThaddeusYoung", "RJBarrett", "DariusGarland", "MilesMcBride", "JohnKonchar", "AnthonyEdwards", "AyoDosunmu", "GabeVincent", "PreciousAchiuwa", "DejounteMurray", "JoshRichardson", "SamHauser", "CobyWhite", "AndrewWiggins", "KawhiLeonard", "PatrickBeverley", "KenrichWilliams", "PaulReed", "MalcolmBrogdon", "SantiAldama", "JoeIngles", "GaryTrent", "MichaelPorterJr", "MikeMuscala", "ZachLavine", "AustinReaves", "ThomasBryant", "AlHorford", "KlayThompson", "BruceBrown", "GrantWilliams", "TobiasHarris", "RickyRubio", "AaronGordon", "JoelEmbiid", "SaddiqBey", "DeandreHunter", "IsaiahJoe", "JalenBrunson", "MalikBeasley", "RobertWilliams", "JonasValanciunas", "KyleAnderson", "JoeHarris", "JohnCollins", "ReggieJackson", "JimmyButler", "JockLandale", "PJTucker", "TreyLyles", "PatConnaughton", "JaylenBrown", "BrandonIngram", "OGAnunoby", "JaMorant", "NazReid", "JordanPoole", "DevinBooker", "DraymondGreen", "ImmanuelQuickley", "JevonCarter", "JalenWilliams", "TaureanPrince", "LebronJames", "KevonLooney", "BobbyPortis", "GiannisAntetokounmpo", "WillBarton", "QuentinGrimes", "JeffGreen", "JarenJacksonJr", "BonesHyland", "ClintCapela", "KarlAnthonyTowns", "MitchellRobinson", "TyreseMaxey", "LukeKennard", "JaysonTatum", "MarcusSmart", "PaulGeorge", "NicClaxton", "ZionWilliamson", "BamAdebayo", "DorianFinneySmith", "LuguentzDort", "AlexCaruso", "IsaacOkoro", "GeorgesNiang", "MalikMonk", "AaronWiggins", "DAngeloRussell", "BrandonClarke", "JaylinWilliams", "DennisSchroder", "JaylenNowell", "JuliusRandle", "JarredVanderbilt", "JrueHoliday", "MosesMoody", "CameronJohnson", "BrookLopez", "LarryNance", "StephenCurry", "DamionLee", "HarrisonBarnes", "LamarStevens", "ChristianBraun", "HerbertJones", "DesmondBane", "KeeganMurray", "BogdanBogdanovic", "AJGriffin", "KevinHuerter", "NickeilAlexanderWalker", "DeAndreAyton", "BenSimmons", "TyusJones", "DillonBrooks", "TylerHerro", "NikolaJokic", "JonathanKuminga", "EvanMobley", "TreyMurphy", "DonovanMitchell", "TroyBrown", "AnthonyDavis", "IsaiahHartenstein", "KevinLove", "JakobPoeltl", "MasonPlumlee", "PascalSiakam", "StevenAdams", "WenyenGabriel", "GraysonAllen", "JoseAlvarado", "MikalBridges", "NikolaVucevic", "NajiMarshall", "RuiHachimura", "JoshGiddey", "ChimezieMetu", "JoshHart", "MaxStrus", "TorreyCraig", "ChrisBoucher", "KevinDurant", "SpencerDinwiddie", "ShakeMilton", "DerrickJones", "VictorOladipo", "MikeConley", "DonteDivincenzo", "DarioSaric", "TraeYoung", "JarettAllen"
]
# var all_strategy_card_names = ["BlinkAndYoullMissHim", "HesHeatingUp", "Layup", "BoxingOut", "GoodPosition", "HalfCourtSet", "ChaseDownBlock", "AndOne", "DefensiveRebound", "KillerCrossover", "Jumper"]
var all_strategy_card_names = ["DefensiveRebound", "BoxingOut"]

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
		for i in range(0, 3):
			player_strategy_card_deck.append(all_strat_card_configs.pick_random())
	return player_strategy_card_deck