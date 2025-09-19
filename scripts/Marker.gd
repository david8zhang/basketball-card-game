class_name Marker
extends HBoxContainer

enum MarkerType {
	NONE,
	HOT,
	COLD
}

@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $TextureRect

var curr_marker_type: MarkerType = MarkerType.NONE
var curr_marker_count := 0

func set_marker_type(marker_type: MarkerType):
	var marker_resource_path = "res://assets/hot-marker.png" if marker_type == MarkerType.HOT else "res://assets/cold-marker.png"
	texture_rect.texture = load(marker_resource_path)
	curr_marker_type = marker_type

func update_marker_count(count: int):
	curr_marker_count += count
	label.text = str(curr_marker_count)
	hide_or_show_based_on_count()

func update_marker_with_type(count: int, marker_type: MarkerType):
	if curr_marker_type != marker_type and curr_marker_type != MarkerType.NONE:
		curr_marker_count -= count
		curr_marker_count = abs(curr_marker_count)
		if curr_marker_count < 0:
			set_marker_type(marker_type)
		elif curr_marker_count == 0:
			set_marker_type(MarkerType.NONE)
		label.text = str(curr_marker_count)
	else:
		set_marker_type(marker_type)
		curr_marker_count += count
		label.text = str(curr_marker_count)
	hide_or_show_based_on_count()

func set_marker_type_and_count(count: int, marker_type: MarkerType):
	set_marker_type(marker_type)
	curr_marker_count = count
	label.text = str(curr_marker_count)
	hide_or_show_based_on_count()

func add_hot_marker():
	if curr_marker_type == MarkerType.COLD:
		update_marker_count(-1)
	else:
		update_marker_count(1)
		if curr_marker_type == MarkerType.NONE:
			set_marker_type(MarkerType.HOT)
	hide_or_show_based_on_count()

func add_cold_marker():
	if curr_marker_type == MarkerType.HOT:
		update_marker_count(-1)
	else:
		update_marker_count(1)
		if curr_marker_type == MarkerType.NONE:
			set_marker_type(MarkerType.COLD)
	hide_or_show_based_on_count()

func copy_from_marker(other_marker: Marker):
	set_marker_type(other_marker.curr_marker_type)
	curr_marker_count = other_marker.curr_marker_count
	label.text = str(curr_marker_count)
	hide_or_show_based_on_count()

func hide_or_show_based_on_count():
	if curr_marker_count == 0:
		hide()
	else:
		show()