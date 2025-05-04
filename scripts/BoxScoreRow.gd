class_name BoxScoreRow
extends PanelContainer

@onready var box_score_label = $Label as Label

func set_value(text: String):
	box_score_label.text = text
