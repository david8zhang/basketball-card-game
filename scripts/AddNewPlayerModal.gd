class_name AddNewPlayerModal
extends Control

@export var bp_card_scene: PackedScene
@export var bp_card_preview_scene: PackedScene
@onready var player_starting_lineup_slots = $VBoxContainer/HBoxContainer as HBoxContainer
@onready var player_bench_container = $VBoxContainer/MarginContainer2/ScrollContainer/HBoxContainer as HBoxContainer
@onready var player_bench_parent = $VBoxContainer/MarginContainer2
@onready var card_to_pick_container = $VBoxContainer/MarginContainer/ScrollContainer/HBoxContainer2 as HBoxContainer
@onready var card_cost_too_high = $CardCostTooHigh as Label
@onready var player_cost_total = $PlayerCostTotal as Label
@onready var continue_button = $Continue as Button
@onready var close_button = $Close as Button
@onready var switch_lineup_button = $SwitchLineup as Button
@onready var add_button = $AddButton as Button


var selected_bp_card: BallPlayerCard
var orig_reward_bp_stat: BallPlayerStats
var bp_card_preview: BPCardPreview
var is_showing_bench := false

signal on_add_player(new_lineup)

func _ready() -> void:
	init_test_data_if_needed()
	continue_button.hide()
	continue_button.pressed.connect(on_continue)
	close_button.pressed.connect(on_close)
	switch_lineup_button.pressed.connect(switch_lineup)
	add_button.pressed.connect(add_player_to_bench)
	add_button.hide()
	var child_nodes = player_starting_lineup_slots.get_children()
	for node in child_nodes:
		var card_slot = node as CardSlot
		var card_in_lineup_stat = SceneVariables.player_team_bp_configs[card_slot.player_position] as BallPlayerStats
		var bp_card = bp_card_scene.instantiate() as BallPlayerCard
		bp_card.ball_player_stats = card_in_lineup_stat
		card_slot.set_bp_card_in_slot(bp_card)
		card_slot.on_select_card.connect(on_set_bp_card)
	update_curr_player_cost_total()

func init_test_data_if_needed():
	if SceneVariables.player_team_bp_configs.is_empty():
		SceneVariables.player_team_bp_configs = SceneVariables.assemble_random_starting_lineup()
	if SceneVariables.player_team_bench.is_empty():
		SceneVariables.player_team_bench = SceneVariables.assemble_random_player_bench()
	if orig_reward_bp_stat == null:
		var bp_stat_to_add = generate_sample_reward_bp()
		set_bp_stat_to_add(bp_stat_to_add)
	SceneVariables.salary_cap = SceneVariables.get_curr_total_player_cost() + 1000

func generate_sample_reward_bp():
	var players_for_salary_cap = SceneVariables.get_players_for_salary_cap()
	var max_cost = SceneVariables.get_player_max_cost_for_salary_cap(SceneVariables.salary_cap)
	var players_to_exclude = SceneVariables.player_team_bp_configs.values().map(func (p): return p.get_full_name())
	var players_to_pick_from = SceneVariables.get_best_players(players_for_salary_cap, max_cost, players_to_exclude)
	return players_to_pick_from.pick_random()

func set_bp_stat_to_add(bp_stat: BallPlayerStats):
	var ball_player_card = bp_card_scene.instantiate() as BallPlayerCard
	ball_player_card.on_bp_card_clicked.connect(on_click_card)
	ball_player_card.ball_player_stats = bp_stat
	card_to_pick_container.add_child(ball_player_card)
	orig_reward_bp_stat = bp_stat

func on_set_bp_card(card_slot: CardSlot):
	if selected_bp_card != null:
		var selected_bp_card_cost = selected_bp_card.ball_player_stats.player_cost		
		var curr_cost_total = get_curr_cost_total()
		var curr_card_in_slot_cost = card_slot.card_in_slot.ball_player_stats.player_cost
		if curr_cost_total - curr_card_in_slot_cost + selected_bp_card_cost <= SceneVariables.salary_cap:
			replace_drafted_bp_card(card_slot)
			update_curr_player_cost_total()
		else:
			show_over_budget_alert()
		continue_button.visible = can_continue()
	else:
		on_click_card(card_slot.card_in_slot, false)

func on_set_bench_bp_card(bench_card: BallPlayerCard):
	if selected_bp_card != null:
		var selected_bp_card_cost = selected_bp_card.ball_player_stats.player_cost
		var curr_cost_total = get_curr_cost_total()
		var curr_bench_card_cost = bench_card.ball_player_stats.player_cost
		if curr_cost_total - curr_bench_card_cost + selected_bp_card_cost <= SceneVariables.salary_cap:
			replace_bench_bp_card(bench_card)
			update_curr_player_cost_total()
		else:
			show_over_budget_alert()
		continue_button.visible = can_continue()
	else:
		on_click_card(bench_card, false)

func can_continue():
	for child in player_starting_lineup_slots.get_children():
		var slot = child as CardSlot
		var card_in_slot = slot.card_in_slot as BallPlayerCard
		if card_in_slot.get_full_name() == orig_reward_bp_stat.get_full_name():
			return true
	return false

func replace_drafted_bp_card(card_slot: CardSlot):
	add_button.hide()
	# Put replaced player in card to add spot (in case we want to undo)
	var player_to_replace = card_slot.card_in_slot as BallPlayerCard
	var old_bp_card = bp_card_scene.instantiate() as BallPlayerCard
	old_bp_card.ball_player_stats = player_to_replace.ball_player_stats
	for child in card_to_pick_container.get_children():
		child.queue_free()
	card_to_pick_container.add_child(old_bp_card)
	var callable = Callable(self, "on_click_card").bind(old_bp_card)
	old_bp_card.button.pressed.connect(callable)

	# Set new bp card in replace player's slot
	var new_bp_card = bp_card_scene.instantiate() as BallPlayerCard
	new_bp_card.ball_player_stats = selected_bp_card.ball_player_stats
	card_slot.set_bp_card_in_slot(new_bp_card)
	selected_bp_card = null

func replace_bench_bp_card(bench_player_to_replace: BallPlayerCard):
	add_button.hide()
	bench_player_to_replace.on_bp_card_clicked.disconnect(on_set_bench_bp_card)
	bench_player_to_replace.on_bp_card_clicked.connect(on_click_card)
	selected_bp_card.on_bp_card_clicked.disconnect(on_click_card)
	selected_bp_card.on_bp_card_clicked.connect(on_set_bench_bp_card)

	player_bench_container.remove_child(bench_player_to_replace)
	card_to_pick_container.add_child(bench_player_to_replace)
	card_to_pick_container.remove_child(selected_bp_card)
	player_bench_container.add_child(selected_bp_card)
	player_bench_container.move_child(selected_bp_card, 0)
	selected_bp_card.disable_highlight()
	selected_bp_card = null

func update_curr_player_cost_total():
	var curr_cost = get_curr_cost_total()
	player_cost_total.text = "Total: " + str(curr_cost) + "/" + str(SceneVariables.salary_cap)

func show_over_budget_alert():
	add_button.hide()
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

func get_curr_cost_total():
	var curr_cost = 0
	for node in player_starting_lineup_slots.get_children():
		var card_slot = node as CardSlot
		if card_slot.card_in_slot != null:
			var card_in_slot = card_slot.card_in_slot as BallPlayerCard
			curr_cost += card_in_slot.ball_player_stats.player_cost
	for node in player_bench_container.get_children():
		var bp = node as BallPlayerCard
		curr_cost += bp.ball_player_stats.player_cost
	return curr_cost

func switch_lineup():
	if is_showing_bench:
		show_starting_lineup()
	else:
		show_bench_lineup()
	is_showing_bench = !is_showing_bench

func show_starting_lineup():
	add_button.hide()
	player_bench_parent.hide()
	player_starting_lineup_slots.show()
	var child_nodes = player_starting_lineup_slots.get_children()
	for node in child_nodes:
		var card_slot = node as CardSlot
		var card_in_lineup_stat = SceneVariables.player_team_bp_configs[card_slot.player_position] as BallPlayerStats
		var bp_card = bp_card_scene.instantiate() as BallPlayerCard
		bp_card.ball_player_stats = card_in_lineup_stat
		card_slot.set_bp_card_in_slot(bp_card)
		card_slot.on_select_card.connect(on_set_bp_card)

func show_bench_lineup():
	player_bench_parent.show()
	player_starting_lineup_slots.hide()
	for c in player_bench_container.get_children():
		c.queue_free()
	player_bench_container.get_children().clear()
	for bp in SceneVariables.player_team_bench:
		var bp_stats = bp as BallPlayerStats
		var bp_card = bp_card_scene.instantiate() as BallPlayerCard
		bp_card.ball_player_stats = bp_stats
		bp_card.on_bp_card_clicked.connect(on_set_bench_bp_card)
		player_bench_container.add_child(bp_card)

func on_continue():
	var new_lineup_config = {}
	for node in player_starting_lineup_slots.get_children():
		var card_slot = node as CardSlot
		new_lineup_config[card_slot.player_position] = card_slot.card_in_slot.ball_player_stats
	var new_bench = []
	for node in player_bench_container.get_children():
		var player = node as BallPlayerCard
		new_bench.append(player.ball_player_stats)
	SceneVariables.player_team_bp_configs = new_lineup_config
	SceneVariables.player_team_bench = new_bench
	on_add_player.emit()
	hide()

func on_close():
	queue_free()

func on_click_card(bp_card, show_select_button = true):
	if is_showing_bench:
		add_button.show()
	bp_card_preview = bp_card_preview_scene.instantiate() as BPCardPreview
	bp_card_preview.show_select_button = show_select_button
	bp_card_preview.bp_stat_to_preview = bp_card.ball_player_stats
	add_child(bp_card_preview)
	bp_card_preview.on_close.connect(close_bp_card_preview)
	var callable = Callable(self, "select_bp_card").bind(bp_card)
	bp_card_preview.on_selected.connect(callable)

func close_bp_card_preview():
	bp_card_preview.queue_free()

func select_bp_card(bp_card: BallPlayerCard):
	if selected_bp_card != null:
		selected_bp_card.disable_highlight()
	selected_bp_card = bp_card
	selected_bp_card.enable_highlight()
	close_bp_card_preview()	

func remove_bench_card(bp_card: BallPlayerCard):
	player_bench_container.remove_child(bp_card)
	card_to_pick_container.add_child(bp_card)
	if bp_card.on_bp_card_clicked.has_connections():
		for conn in bp_card.get_signal_connection_list("on_bp_card_clicked"):
			bp_card.disconnect("on_bp_card_clicked", conn.callable)
	bp_card.on_bp_card_clicked.connect(on_click_card)


func add_player_to_bench():
	if selected_bp_card != null:
		var curr_cost_total = get_curr_cost_total()
		if curr_cost_total + selected_bp_card.ball_player_stats.player_cost <= SceneVariables.salary_cap:	
			if selected_bp_card.on_bp_card_clicked.has_connections():
				for conn in selected_bp_card.get_signal_connection_list("on_bp_card_clicked"):
					selected_bp_card.disconnect("on_bp_card_clicked", conn.callable)
			selected_bp_card.on_bp_card_clicked.connect(remove_bench_card)
			card_to_pick_container.remove_child(selected_bp_card)
			player_bench_container.add_child(selected_bp_card)
			player_bench_container.move_child(selected_bp_card, 0)
			selected_bp_card.disable_highlight()
			selected_bp_card = null
			add_button.hide()
		else:
			show_over_budget_alert()
		update_curr_player_cost_total()
