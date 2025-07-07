class_name DraftScene
extends Control

@onready var bp_card_container = $VBoxContainer/MarginContainer/ScrollContainer/HBoxContainer2 as HBoxContainer
@export var bp_card_scene: PackedScene
@export var bp_card_preview_scene: PackedScene
@export var num_random_players = 8

var all_player_stats = {}
var selected_bp_card_stat
var bp_card_preview: BPCardPreview

func _ready():
  load_all_players()
  init_random_players()

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

    var callable = Callable(self, "on_click_card").bind(random_player_stat)
    bp_card.button.pressed.connect(callable)

func on_click_card(bp_stat: BallPlayerStats):
  selected_bp_card_stat = bp_stat
  bp_card_preview = bp_card_preview_scene.instantiate() as BPCardPreview
  bp_card_preview.bp_stat_to_preview = bp_stat
  add_child(bp_card_preview)
  bp_card_preview.on_close.connect(close_bp_card_preview)

  var callable = Callable(self, "select_bp_card_stat").bind(bp_stat)
  bp_card_preview.on_selected.connect(callable)

func close_bp_card_preview():
  bp_card_preview.queue_free()

func select_bp_card_stat(bp_stat: BallPlayerStats):
  selected_bp_card_stat = bp_stat
  close_bp_card_preview()