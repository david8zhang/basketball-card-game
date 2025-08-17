class_name BPCardPreview
extends Control

@export var matchup_bp_card_scene: PackedScene
@onready var select_button = $SelectButton as Button
@onready var close_button = $CloseButton as Button

var bp_stat_to_preview: BallPlayerStats
var show_select_button: bool = true

signal on_selected
signal on_close

func _ready():
	var matchup_bp_card = matchup_bp_card_scene.instantiate() as MatchupPlayerCard
	matchup_bp_card.ball_player_stats = bp_stat_to_preview
	add_child(matchup_bp_card)
	close_button.pressed.connect(close)
	select_button.pressed.connect(select)
	select_button.visible = show_select_button

func close():
	on_close.emit()

func select():
	on_selected.emit()
