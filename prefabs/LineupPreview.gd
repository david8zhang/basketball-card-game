class_name LineupPreview
extends PanelContainer

@onready var starter_container = $MarginContainer/VBoxContainer/ScrollContainer/StarterContainer
@onready var bench_container = $MarginContainer/VBoxContainer/ScrollContainer2/BenchContainer
@onready var exit_button = $MarginContainer/Button
@onready var reset_lineups_button = $MarginContainer/Button2
@onready var bench_label = $MarginContainer/VBoxContainer/BenchLabel

@export var bp_card_scene: PackedScene
@export var bp_card_preview_scene: PackedScene
@export var allow_replacement := false

var bp_card_preview
var show_bench := true
var selected_bp_card

var updated_player_team_bp_configs = {}
var updated_player_team_bench = []

signal on_exit_pressed

func _ready() -> void:
	generate_team_and_bench_if_empty()
	var on_exit = func _on_exit():
		if allow_replacement:
			SceneVariables.player_team_bp_configs = updated_player_team_bp_configs
			SceneVariables.player_team_bench = updated_player_team_bench
		on_exit_pressed.emit()
	exit_button.pressed.connect(on_exit)
	reset_lineups_button.pressed.connect(reset_lineups)
	reset_lineups_button.visible = allow_replacement

func generate_team_and_bench_if_empty():
	if SceneVariables.player_team_bp_configs.is_empty():
		SceneVariables.player_team_bp_configs = SceneVariables.assemble_random_lineup()
	if SceneVariables.player_team_bench.is_empty():
		SceneVariables.player_team_bench = SceneVariables.assemble_random_bench()
	updated_player_team_bp_configs = SceneVariables.player_team_bp_configs.duplicate(true)
	updated_player_team_bench = SceneVariables.player_team_bench.duplicate(true)
	display_default_lineups()

func reset_lineups():
	updated_player_team_bp_configs = SceneVariables.player_team_bp_configs.duplicate(true)
	updated_player_team_bench = SceneVariables.player_team_bench.duplicate(true)
	display_default_lineups()

func display_default_lineups():
	display_specific_lineups(SceneVariables.player_team_bp_configs, SceneVariables.player_team_bench)

func display_specific_lineups(player_team_bp_configs, player_team_bench):
	var positions = player_team_bp_configs.keys()
	positions.sort()
	clear_prev_children()
	for p in positions:
		init_card(starter_container, player_team_bp_configs[p])
	if show_bench:
		for bp_stat in player_team_bench:
			init_card(bench_container, bp_stat)
	bench_label.visible = show_bench

func clear_prev_children():
	for c in starter_container.get_children():
		c.queue_free()
	for c in bench_container.get_children():
		c.queue_free()
		
func init_card(container: HBoxContainer, bp_stat: BallPlayerStats):
	var bp_card = bp_card_scene.instantiate() as BallPlayerCard
	bp_card.on_bp_card_clicked.connect(on_click_card)
	bp_card.ball_player_stats = bp_stat
	container.add_child(bp_card)

func on_click_card(bp_card: BallPlayerCard):
	if selected_bp_card != null:
		exit_button.text = "Save & Exit"
		var assigned_position = get_assigned_position(bp_card, updated_player_team_bp_configs)
		updated_player_team_bp_configs[assigned_position] = selected_bp_card.ball_player_stats
		updated_player_team_bench = updated_player_team_bench.filter(func (p): return p.get_full_name() != selected_bp_card.get_full_name())
		updated_player_team_bench.append(bp_card.ball_player_stats)
		selected_bp_card.disable_highlight()
		selected_bp_card = null
		display_specific_lineups(updated_player_team_bp_configs, updated_player_team_bench)
	else:
		bp_card_preview = bp_card_preview_scene.instantiate() as BPCardPreview
		bp_card_preview.bp_stat_to_preview = bp_card.ball_player_stats
		bp_card_preview.show_select_button = allow_replacement
		bp_card_preview.on_close.connect(close_bp_card_preview)
		var callable = Callable(self, "select_bp_card").bind(bp_card)
		bp_card_preview.on_selected.connect(callable)
		add_child(bp_card_preview)

func get_assigned_position(bp_card: BallPlayerCard, team_bp_configs: Dictionary):
	for k in team_bp_configs.keys():
		if team_bp_configs[k].get_full_name() == bp_card.get_full_name():
			return k

func close_bp_card_preview():
	bp_card_preview.queue_free()

func select_bp_card(bp_card: BallPlayerCard):
	if selected_bp_card != null:
		selected_bp_card.disable_highlight()
	selected_bp_card = bp_card
	selected_bp_card.enable_highlight()
	close_bp_card_preview()
