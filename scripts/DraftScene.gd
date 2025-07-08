class_name DraftScene
extends Control

@onready var bp_card_container = $VBoxContainer/MarginContainer/ScrollContainer/HBoxContainer2 as HBoxContainer
@onready var card_slot_container = $VBoxContainer/HBoxContainer as HBoxContainer
@export var bp_card_scene: PackedScene
@export var bp_card_preview_scene: PackedScene
@export var num_random_players = 8

var all_player_stats = {}
var selected_bp_card: BallPlayerCard
var bp_card_preview: BPCardPreview

func _ready():
	load_all_players()
	init_random_players()
	var child_nodes = card_slot_container.get_children()
	for node in child_nodes:
		var card_slot = node as CardSlot
		card_slot.on_select_card.connect(on_set_bp_card)

func on_set_bp_card(card_slot: CardSlot):
	if selected_bp_card != null:
		var bp_card = bp_card_scene.instantiate() as BallPlayerCard
		bp_card.ball_player_stats = selected_bp_card.ball_player_stats
		card_slot.set_bp_card_in_slot(bp_card)
		selected_bp_card.disable_highlight()
		selected_bp_card = null

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
	var players_picked = []
	for i in range(0, num_random_players):
		var key_to_select = keys[i % keys.size()]
		var players_to_pick_from = all_player_stats[key_to_select].filter(func (s): return !players_picked.has(s.get_full_name()))
		var random_player_stat = players_to_pick_from.pick_random() as BallPlayerStats
		players_picked.append(random_player_stat.get_full_name())
		var bp_card = bp_card_scene.instantiate() as BallPlayerCard
		bp_card.ball_player_stats = random_player_stat
		bp_card_container.add_child(bp_card)
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
