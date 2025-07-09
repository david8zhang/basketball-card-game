class_name DraftScene
extends Control

@onready var bp_card_container = $VBoxContainer/MarginContainer/ScrollContainer/HBoxContainer2 as HBoxContainer
@onready var card_slot_container = $VBoxContainer/HBoxContainer as HBoxContainer
@onready var continue_button = $Continue as Button
@onready var player_cost_total = $PlayerCostTotal as Label

@export var bp_card_scene: PackedScene
@export var bp_card_preview_scene: PackedScene
@export var num_random_players = 8
@export var player_cost_limit = 1500

var all_player_stats = {}
var selected_bp_card: BallPlayerCard
var bp_card_preview: BPCardPreview
var players_to_pick_from_cards: Array[BallPlayerCard] = []

func _ready():
	load_all_players()
	init_random_players()
	var child_nodes = card_slot_container.get_children()
	for node in child_nodes:
		var card_slot = node as CardSlot
		card_slot.on_select_card.connect(on_set_bp_card)
	continue_button.pressed.connect(go_to_game_scene)

func on_set_bp_card(card_slot: CardSlot):
	if selected_bp_card != null:
		var bp_card = bp_card_scene.instantiate() as BallPlayerCard
		bp_card.ball_player_stats = selected_bp_card.ball_player_stats
		if card_slot.card_in_slot != null:
			replace_drafted_bp_card(bp_card.full_name(), card_slot.card_in_slot)
		else:
			remove_drafted_bp_card(bp_card.full_name())
		card_slot.set_bp_card_in_slot(bp_card)
		selected_bp_card.disable_highlight()
		selected_bp_card = null
		check_can_continue()
		update_curr_player_cost_total()

func get_curr_cost_total():
	var curr_cost = 0
	for node in card_slot_container.get_children():
		var card_slot = node as CardSlot
		if card_slot.card_in_slot != null:
			var card_in_slot = card_slot.card_in_slot as BallPlayerCard
			curr_cost += card_in_slot.ball_player_stats.player_cost
	return curr_cost

func update_curr_player_cost_total():
	var curr_cost = get_curr_cost_total()
	player_cost_total.text = "Total: " + str(curr_cost) + "/" + str(player_cost_limit)

func check_can_continue():
	for node in card_slot_container.get_children():
		var card_slot = node as CardSlot
		if card_slot.card_in_slot == null:
			return
	continue_button.show()

func go_to_game_scene():
	var drafted_player_stats = {}
	for node in card_slot_container.get_children():
		var card_slot = node as CardSlot
		drafted_player_stats[card_slot.player_position] = card_slot.card_in_slot.ball_player_stats
	SceneVariables.player_team_bp_configs = drafted_player_stats
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func remove_drafted_bp_card(player_to_remove_name: String):
	for card in players_to_pick_from_cards:
		if is_instance_valid(card) and card.full_name() == player_to_remove_name:
			card.queue_free()

func replace_drafted_bp_card(player_to_remove_name: String, player_to_replace: BallPlayerCard):
	var bp_card = bp_card_scene.instantiate() as BallPlayerCard
	bp_card.ball_player_stats = player_to_replace.ball_player_stats
	bp_card_container.add_child(bp_card)
	bp_card_container.move_child(bp_card, 0)
	players_to_pick_from_cards.push_front(bp_card)
	var callable = Callable(self, "on_click_card").bind(bp_card)
	bp_card.button.pressed.connect(callable)
	remove_drafted_bp_card(player_to_remove_name)

func load_all_players():
	for file_name in DirAccess.get_files_at("res://resources/players"):
		if (file_name.get_extension() == "tres"):
			var stat_config = load("res://resources/players/" + file_name) as BallPlayerStats
			for p in stat_config.positions:
				if p not in all_player_stats:
					all_player_stats[p] = []
				all_player_stats[p].append(stat_config)

func init_random_players():
	var keys = all_player_stats.keys()
	var selected_player_names = []
	for i in range(0, num_random_players):
		var key_to_select = keys[i % keys.size()]
		var players_at_position = all_player_stats[key_to_select].filter(func (s): return !selected_player_names.has(s.get_full_name()))
		var random_player_stat = players_at_position.pick_random() as BallPlayerStats
		selected_player_names.append(random_player_stat.get_full_name())
		var bp_card = bp_card_scene.instantiate() as BallPlayerCard
		bp_card.ball_player_stats = random_player_stat
		bp_card_container.add_child(bp_card)
		players_to_pick_from_cards.append(bp_card)
		var callable = Callable(self, "on_click_card").bind(bp_card)
		bp_card.button.pressed.connect(callable)

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
	if selected_bp_card != null:
		selected_bp_card.disable_highlight()
	selected_bp_card = bp_card
	selected_bp_card.enable_highlight()
	close_bp_card_preview()
