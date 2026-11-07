extends Control
## Scale diagram measured from f12–f14. Content and the false weight use LOCK data.

var data: Dictionary
var tried_weight := -1
var font: Font

func _draw() -> void:
	var gold := Color("d9b776")
	draw_rect(Rect2(237, 0, 10, 184), gold)
	draw_rect(Rect2(174, 175, 135, 20), Color("6b5733"))
	var tilt := -0.14 if tried_weight == int(data.lesson.false_weight_index) else 0.0
	draw_set_transform(Vector2(242, 13), tilt)
	draw_rect(Rect2(-202, -5, 404, 10), gold)
	for side in [-1, 1]:
		var x := float(side) * 196.0
		draw_line(Vector2(x, 0), Vector2(x, 69), gold, 3, true)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 47, 67), Vector2(x + 47, 67), Vector2(x + 27, 94), Vector2(x - 27, 94)]), Color("c5a265"))
		if side < 0 or tried_weight >= 0:
			draw_rect(Rect2(x - 24, 37, 48, 30), Color("6b5733") if side < 0 else Color("8b6b39"))
			var text: String = data.ui.lesson.checked_label if side < 0 else str(data.ui.lesson.weight_label).format({"n": tried_weight + 1})
			var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 23).x
			draw_string(font, Vector2(x - width / 2.0, 27), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("f5e8cd"))
	draw_set_transform(Vector2.ZERO)
