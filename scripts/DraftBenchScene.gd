class_name DraftBenchScene
extends Control

@onready var bench_cards = $VBoxContainer/MarginContainer/ScrollContainer/HBoxContainer as HBoxContainer
@onready var cards_to_select_from_container = $VBoxContainer/MarginContainer2/ScrollContainer/HBoxContainer2 as HBoxContainer
@onready var continue_button = $Continue as Button
@onready var player_cost_total = $PlayerCostTotal as Label
@onready var card_cost_too_high = $CardCostTooHigh as Label

@export var bp_card_scene: PackedScene
@export var bp_card_preview_scene: PackedScene
@export var num_random_players = 8

var all_player_stats = {}
var bp_card_preview: BPCardPreview
var selected_bp_card: BallPlayerCard
var players_to_pick_from_cards: Array[BallPlayerCard] = []

func _ready():
	load_all_players()
	init_random_players()
	update_curr_player_cost_total()
	continue_button.pressed.connect(go_to_next_scene)

func update_curr_player_cost_total():
	var curr_cost = get_curr_cost_total()
	player_cost_total.text = "Total: " + str(curr_cost) + "/" + str(SceneVariables.salary_cap)

func load_all_players():
	for config in SceneVariables.all_player_stat_configs:
		for p in config.positions:
			if p not in all_player_stats:
				all_player_stats[p] = []
			all_player_stats[p].append(config)

func init_random_players():
	var keys = all_player_stats.keys()
	var selected_player_names = SceneVariables.player_team_bp_configs.values().map(func (bp_stat): return bp_stat.get_full_name())
	for i in range(0, num_random_players):
		var key_to_select = keys[i % keys.size()]
		var players_at_position = all_player_stats[key_to_select].filter(func(s): return is_eligible_player(s, selected_player_names))
		var random_player_stat = players_at_position.pick_random() as BallPlayerStats
		selected_player_names.append(random_player_stat.get_full_name())
		var bp_card = bp_card_scene.instantiate() as BallPlayerCard
		bp_card.ball_player_stats = random_player_stat
		cards_to_select_from_container.add_child(bp_card)
		players_to_pick_from_cards.append(bp_card)
		var callable = Callable(self, "on_click_card").bind(bp_card)
		bp_card.button.pressed.connect(callable)

func is_eligible_player(s: BallPlayerStats, selected_player_names):
	return !selected_player_names.has(s.get_full_name()) and is_player_within_max_cost(s)

func is_player_within_max_cost(ball_player_stats: BallPlayerStats):
	return ball_player_stats.player_cost <= SceneVariables.get_player_max_cost_for_salary_cap(SceneVariables.salary_cap)

func go_to_next_scene():
	get_tree().change_scene_to_file("res://scenes/PickStrategyCards.tscn")

func get_curr_cost_total():
	var curr_cost = 0
	for node in bench_cards.get_children():
		var bench_card = node as BallPlayerCard
		curr_cost += bench_card.ball_player_stats.player_cost
	# Add cost of starting lineup
	for c in SceneVariables.player_team_bp_configs.values():
		var bp_stat = c as BallPlayerStats
		curr_cost += bp_stat.player_cost
	return curr_cost

func on_click_card(bp_card: BallPlayerCard):
	bp_card_preview = bp_card_preview_scene.instantiate() as BPCardPreview
	bp_card_preview.bp_stat_to_preview = bp_card.ball_player_stats
	add_child(bp_card_preview)
	bp_card_preview.on_close.connect(close_bp_card_preview)
	var callable = Callable(self, "select_bp_card").bind(bp_card)
	bp_card_preview.on_selected.connect(callable)

func close_bp_card_preview():
	bp_card_preview.queue_free()

func select_bp_card(bp_card: BallPlayerCard):
	add_card_to_bench_if_possible(bp_card)
	close_bp_card_preview()

func add_card_to_bench_if_possible(bp_card_to_add: BallPlayerCard):
	var total_cost = get_curr_cost_total()
	var selected_bp_card_cost = bp_card_to_add.ball_player_stats.player_cost
	if selected_bp_card_cost + total_cost > SceneVariables.salary_cap:
		show_over_budget_alert()
	else:
		var callable = Callable(self, "remove_bp_from_bench").bind(bp_card_to_add)
		cards_to_select_from_container.remove_child(bp_card_to_add)
		disconnect_bp_card_click_connections(bp_card_to_add)
		bp_card_to_add.on_bp_card_clicked.connect(callable)
		bench_cards.add_child(bp_card_to_add)
		update_curr_player_cost_total()

func disconnect_bp_card_click_connections(bp_card: BallPlayerCard):
	if bp_card.on_bp_card_clicked.has_connections():
		for conn in bp_card.get_signal_connection_list("on_bp_card_clicked"):
			bp_card.disconnect("on_bp_card_clicked", conn.callable)

func remove_bp_from_bench(bp_card_to_remove: BallPlayerCard):
	bench_cards.remove_child(bp_card_to_remove)
	disconnect_bp_card_click_connections(bp_card_to_remove)
	var callable = Callable(self, "on_click_card").bind(bp_card_to_remove)
	bp_card_to_remove.on_bp_card_clicked.connect(callable)
	cards_to_select_from_container.add_child(bp_card_to_remove)
	update_curr_player_cost_total()

func show_over_budget_alert():
	card_cost_too_high.show()
	var timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = 1.5
	var callable = Callable(self, "hide_over_budget_alert").bind(timer)
	timer.timeout.connect(callable)
	add_child(timer)

func hide_over_budget_alert(timer: Timer):
	card_cost_too_high.hide()
	timer.queue_free()
