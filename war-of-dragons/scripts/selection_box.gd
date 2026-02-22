# THIS SCRIPT DRAWS THE SELECTION UI ELEMENT

extends Control

var drag_start := Vector2.ZERO
var drag_end := Vector2.ZERO
var dragging := false
var drag_threshold := 8.0

func _draw():
	if dragging:
		var rect = Rect2(drag_start, drag_end - drag_start).abs()
		draw_rect(rect, Color(0, 1, 0, 0.2))
		draw_rect(rect, Color(0, 1, 0), false)
