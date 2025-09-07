class_name MatchupPreview
extends PanelContainer

@onready var player_lineup_container = $MarginContainer/VBoxContainer/ScrollContainer/PlayerLineupContainer
@onready var cpu_lineup_container = $MarginContainer/VBoxContainer/ScrollContainer2/CPULineupContainer
@onready var continue_button = $MarginContainer/Button
@onready var edit_lineups_button = $MarginContainer/Button2

@export var bp_card_scene: PackedScene
@export var bp_card_preview_scene: PackedScene

var selected_bp_card
var bp_card_preview

func display_specific_lineups(team_bp_configs, container):
	var positions = team_bp_configs.keys()
	positions.sort()
	clear_prev_children(container)
	for p in positions:
		init_card(container, team_bp_configs[p])

func clear_prev_children(container: HBoxContainer):
	for c in container.get_children():
		c.queue_free()

func init_card(container: HBoxContainer, bp_stat: BallPlayerStats):
	var bp_card = bp_card_scene.instantiate() as BallPlayerCard
	bp_card.on_bp_card_clicked.connect(on_click_card)
	bp_card.ball_player_stats = bp_stat
	container.add_child(bp_card)

func on_click_card(bp_card: BallPlayerCard):
	bp_card_preview = bp_card_preview_scene.instantiate() as BPCardPreview
	bp_card_preview.bp_stat_to_preview = bp_card.ball_player_stats
	bp_card_preview.on_close.connect(close_bp_card_preview)
	var callable = Callable(self, "select_bp_card").bind(bp_card)
	bp_card_preview.on_selected.connect(callable)
	add_child(bp_card_preview)

func close_bp_card_preview():
	bp_card_preview.queue_free()