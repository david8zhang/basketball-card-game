class_name LineupPreview
extends PanelContainer

@onready var starter_container = $MarginContainer/VBoxContainer/ScrollContainer/StarterContainer
@onready var bench_container = $MarginContainer/VBoxContainer/ScrollContainer2/BenchContainer
@onready var exit_button = $MarginContainer/Button
@onready var bench_label = $MarginContainer/VBoxContainer/BenchLabel

@export var bp_card_scene: PackedScene
@export var bp_card_preview_scene: PackedScene

var bp_card_preview
var show_bench := true

signal on_exit_pressed

func _ready() -> void:
	var on_exit = func _on_exit():
		on_exit_pressed.emit()
	exit_button.pressed.connect(on_exit)

func display_lineups():
	var positions = SceneVariables.player_team_bp_configs.keys()
	positions.sort()
	clear_prev_children()
	for p in positions:
		init_card(starter_container, SceneVariables.player_team_bp_configs[p])
	if show_bench:
		for bp_stat in SceneVariables.player_team_bench:
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
	bp_card_preview = bp_card_preview_scene.instantiate() as BPCardPreview
	bp_card_preview.show_select_button = false
	bp_card_preview.bp_stat_to_preview = bp_card.ball_player_stats
	add_child(bp_card_preview)
	bp_card_preview.on_close.connect(close_bp_card_preview)
	var callable = Callable(self, "select_bp_card").bind(bp_card)
	bp_card_preview.on_selected.connect(callable)

func close_bp_card_preview():
	bp_card_preview.queue_free()
