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

signal on_edit_lineups_clicked
signal on_continue_clicked

func _ready() -> void:
	if SceneVariables.player_team_bp_configs.is_empty():
		SceneVariables.player_team_bp_configs = SceneVariables.get_player_team_or_gen_random_team()
	if SceneVariables.cpu_team_bp_configs.is_empty():
		SceneVariables.instantiate_cpu_team()
	update_lineups()

	var on_edit_lineup = func _on_edit_lineup():
		on_edit_lineups_clicked.emit()
	edit_lineups_button.pressed.connect(on_edit_lineup)

	var on_continue = func _on_continue():
		on_continue_clicked.emit()
	continue_button.pressed.connect(on_continue)

func update_lineups():
	display_specific_lineups(SceneVariables.player_team_bp_configs, player_lineup_container, Game.Side.PLAYER)
	display_specific_lineups(SceneVariables.cpu_team_bp_configs, cpu_lineup_container, Game.Side.CPU)

func display_specific_lineups(team_bp_configs, container, side: Game.Side):
	var positions = team_bp_configs.keys()
	positions.sort()
	clear_prev_children(container)
	for p in positions:
		init_card(container, team_bp_configs[p])
	var bp_data_cache = SceneVariables.player_team_bp_data_cache if side == Game.Side.PLAYER else SceneVariables.cpu_team_bp_data_cache
	Game.load_bp_data_cache_for_team(container.get_children(), bp_data_cache)

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
	bp_card_preview.show_select_button = false
	bp_card_preview.bp_stat_to_preview = bp_card.ball_player_stats
	bp_card_preview.on_close.connect(close_bp_card_preview)
	var callable = Callable(self, "select_bp_card").bind(bp_card)
	bp_card_preview.on_selected.connect(callable)
	add_child(bp_card_preview)

func close_bp_card_preview():
	bp_card_preview.queue_free()
