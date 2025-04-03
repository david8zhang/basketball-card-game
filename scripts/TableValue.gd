class_name TableValue
extends PanelContainer

@onready var label = $Label as Label
var font_override_size = 8

func _ready():
  label.add_theme_font_size_override("font_size", font_override_size)