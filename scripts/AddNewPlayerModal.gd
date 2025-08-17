class_name AddNewPlayerModal
extends Control

@export var bp_card_scene: PackedScene
@export var bp_card_preview_scene: PackedScene
@onready var player_lineup_slots = $VBoxContainer/HBoxContainer as HBoxContainer
@onready var card_to_pick_container = $VBoxContainer/MarginContainer/ScrollContainer/HBoxContainer2 as HBoxContainer
@onready var card_cost_too_high = $CardCostTooHigh as Label
@onready var player_cost_total = $PlayerCostTotal as Label
@onready var continue_button = $Continue as Button
@onready var close_button = $Close as Button

var selected_bp_card: BallPlayerCard
var orig_reward_bp_stat: BallPlayerStats
var bp_card_preview: BPCardPreview

signal on_add_player(new_lineup)

func _ready() -> void:
	continue_button.hide()
	continue_button.pressed.connect(on_continue)
	close_button.pressed.connect(on_close)
	var child_nodes = player_lineup_slots.get_children()
	for node in child_nodes:
		var card_slot = node as CardSlot
		var card_in_lineup_stat = SceneVariables.player_team_bp_configs[card_slot.player_position] as BallPlayerStats
		var bp_card = bp_card_scene.instantiate() as BallPlayerCard
		bp_card.ball_player_stats = card_in_lineup_stat
		card_slot.set_bp_card_in_slot(bp_card)
		card_slot.on_select_card.connect(on_set_bp_card)
	update_curr_player_cost_total()

func set_bp_stat_to_add(bp_stat: BallPlayerStats):
	var ball_player_card = bp_card_scene.instantiate() as BallPlayerCard
	ball_player_card.on_bp_card_clicked.connect(on_click_card)
	ball_player_card.ball_player_stats = bp_stat
	card_to_pick_container.add_child(ball_player_card)
	orig_reward_bp_stat = bp_stat

func on_set_bp_card(card_slot: CardSlot):
	if selected_bp_card != null:
		var bp_card = bp_card_scene.instantiate() as BallPlayerCard
		bp_card.ball_player_stats = selected_bp_card.ball_player_stats
		var selected_bp_card_cost = selected_bp_card.ball_player_stats.player_cost		
		var curr_cost_total = get_curr_cost_total()
		var curr_card_in_slot_cost = card_slot.card_in_slot.ball_player_stats.player_cost
		if curr_cost_total - curr_card_in_slot_cost + selected_bp_card_cost <= SceneVariables.salary_cap:
			replace_drafted_bp_card(card_slot.card_in_slot)
			card_slot.set_bp_card_in_slot(bp_card)
			update_curr_player_cost_total()
		else:
			show_over_budget_alert()
		continue_button.visible = can_continue()
	else:
		on_click_card(card_slot.card_in_slot, false)

func can_continue():
	for child in player_lineup_slots.get_children():
		var slot = child as CardSlot
		var card_in_slot = slot.card_in_slot as BallPlayerCard
		if card_in_slot.full_name() == orig_reward_bp_stat.get_full_name():
			return true
	return false

func replace_drafted_bp_card(player_to_replace: BallPlayerCard):
	var bp_card = bp_card_scene.instantiate() as BallPlayerCard
	bp_card.ball_player_stats = player_to_replace.ball_player_stats
	for child in card_to_pick_container.get_children():
		child.queue_free()
	card_to_pick_container.add_child(bp_card)
	var callable = Callable(self, "on_click_card").bind(bp_card)
	bp_card.button.pressed.connect(callable)

func update_curr_player_cost_total():
	var curr_cost = get_curr_cost_total()
	player_cost_total.text = "Total: " + str(curr_cost) + "/" + str(SceneVariables.salary_cap)

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

func get_curr_cost_total():
	var curr_cost = 0
	for node in player_lineup_slots.get_children():
		var card_slot = node as CardSlot
		if card_slot.card_in_slot != null:
			var card_in_slot = card_slot.card_in_slot as BallPlayerCard
			curr_cost += card_in_slot.ball_player_stats.player_cost
	return curr_cost

func on_continue():
	var new_lineup_config = {}
	for node in player_lineup_slots.get_children():
		var card_slot = node as CardSlot
		new_lineup_config[card_slot.player_position] = card_slot.card_in_slot.ball_player_stats
	on_add_player.emit(new_lineup_config)
	hide()

func on_close():
	queue_free()

func on_click_card(bp_card, show_select_button = true):
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
