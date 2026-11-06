extends Control
## LOCK 1 map projection. Drawing measurements reproduce the approved masters;
## place coordinates, street widths, words and gameplay values come from data.

signal destination_requested(place_id: String)
signal city_gate_requested(index: int)
signal market_requested

var data: Dictionary = {}
var mode := "market_map"
var night := false
var player_position := Vector3.ZERO
var selected_place := ""
var font: Font = SystemFont.new()
var bold_font: Font = SystemFont.new()
var _place_hits: Dictionary = {}
var _gate_hits: Array[Rect2] = []
const PAPER := Color("f5e8cd")
const INK := Color("30200e")
const GOLD := Color("f8ae36")
const MAP_ORIGIN := Vector2(114, 124)
const MAP_SCALE := 10.5666666667

func _init() -> void:
	font.font_names = PackedStringArray(["Arial", "Helvetica", "sans-serif"])
	bold_font.font_names = font.font_names
	bold_font.font_weight = 700
	mouse_filter = Control.MOUSE_FILTER_STOP

func configure(source: Dictionary) -> void:
	data = source
	queue_redraw()

func project_point(value: Dictionary) -> Vector2:
	return MAP_ORIGIN + Vector2(float(value.x), float(value.z)) * MAP_SCALE

func _draw() -> void:
	if data.is_empty():
		return
	if mode == "city_map":
		_draw_city()
	else:
		_draw_market()

func _rounded(rect: Rect2, color: Color, radius: float = 5.0, border: Color = Color.TRANSPARENT, width: int = 0) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = int(radius)
	style.corner_radius_top_right = int(radius)
	style.corner_radius_bottom_left = int(radius)
	style.corner_radius_bottom_right = int(radius)
	style.border_color = border
	style.set_border_width_all(width)
	draw_style_box(style, rect)

func _text(value: String, at: Vector2, size: int, color: Color, bold: bool = false, outline: bool = false, centered: bool = false, stroke: Color = PAPER) -> void:
	var face: Font = bold_font if bold else font
	if centered:
		at.x -= face.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / 2.0
	if outline:
		draw_string_outline(face, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 10, stroke)
	draw_string(face, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw_market() -> void:
	_place_hits.clear()
	var base := Color("aa8048") if not night else Color("51453e")
	var roof := Color("c69d60") if not night else Color("5c5046")
	var street := Color("e6d3a7") if not night else Color("686764")
	draw_rect(Rect2(Vector2.ZERO, Vector2(1920, 1080)), base)
	# The repeated boxes are a plan symbol, as in f03/f04, not world collision.
	for row in range(12):
		for column in range(19):
			var tone := roof.darkened(0.09 if (row + column) % 2 else 0.0)
			_rounded(Rect2(5 + column * 105.6, 72 + row * 81.6, 91.2, 67.2), tone)
	var canal_y: float = MAP_ORIGIN.y + float(data.world.canal.z_from) * MAP_SCALE
	draw_rect(Rect2(0, canal_y, 1920, 1080 - canal_y), Color("305a77") if not night else Color("1b3450"))
	var quay_y: float = MAP_ORIGIN.y + float(data.world.quay.z_from) * MAP_SCALE
	draw_rect(Rect2(0, quay_y, 1920, canal_y - quay_y), Color("caba95") if not night else Color("5d5c5c"))
	var width: float = float(data.street_width) * MAP_SCALE
	for edge in data.streets:
		var a := project_point(data.street_points[edge[0]])
		var b := project_point(data.street_points[edge[1]])
		draw_line(a, b, street, width, true)
		draw_circle(a, width / 2.0, street, true, -1, true)
		draw_circle(b, width / 2.0, street, true, -1, true)
	var square := project_point(data.street_points[data.square.centre])
	draw_circle(square, float(data.square.radius) * MAP_SCALE, street, true, -1, true)
	var wall_y: float = MAP_ORIGIN.y + float(data.world.wall.z_from) * MAP_SCALE
	var wall_height: float = (float(data.world.wall.z_to) - float(data.world.wall.z_from)) * MAP_SCALE
	draw_rect(Rect2(0, wall_y, 1920, wall_height), Color("7f5030") if not night else Color("33292c"))
	for x in range(0, 1920, 42):
		draw_rect(Rect2(x, wall_y, 18, 18), Color("5e3a20") if not night else Color("2b242c"))
	var gate := project_point(data.places.gate)
	var gate_width: float = float(data.world.gatehouse.width) * MAP_SCALE
	draw_rect(Rect2(gate.x - gate_width / 2.0, 124, gate_width, 94), Color("8e5c35") if not night else Color("443334"))
	draw_rect(Rect2(gate.x - gate_width / 2.0, 124, gate_width, 94), INK, false, 4)
	draw_circle(gate, float(data.world.gatehouse.arch_width) * MAP_SCALE / 2.0, INK)
	draw_rect(Rect2(gate.x - 34, gate.y, 68, 26), INK)
	if night:
		for edge in data.streets:
			var a := project_point(data.street_points[edge[0]])
			var b := project_point(data.street_points[edge[1]])
			var middle: Vector2 = (a + b) / 2.0
			for ring in range(10, 0, -1):
				draw_circle(middle, ring * 4.5, Color(1.0, 0.73, 0.28, 0.018 * (11 - ring)), true, -1, true)
			draw_circle(middle, 6.5, Color("ffd67f"), true, -1, true)
	var road_label: String = data.ui.market_map.road_east
	_text(road_label, Vector2(971, 159), 30, PAPER if not night else Color("7e7a7a"), false, true, false, INK)
	_text(str(data.ui.market_map.scale_bar), Vector2(148, 294), 30, PAPER, false, true, false, INK)
	draw_line(Vector2(148, 311), Vector2(360, 311), PAPER, 6)
	_text(str(data.ui.market_map.canal), Vector2(1498, 1029), 30, Color("adcee1") if not night else Color("64758a"))
	var offsets := {
		"gate": Vector2(0, 61), "board": Vector2(0, 61),
		"scales": Vector2(0, 61), "quay": Vector2(0, -35),
		"spice": Vector2(0, 61), "weaver": Vector2(0, 61),
		"centre": Vector2(189, -35)
	}
	for id in data.places:
		var p := project_point(data.places[id])
		_place_hits[id] = Rect2(p - Vector2(28, 28), Vector2(56, 56))
		draw_circle(p, 23, PAPER, true, -1, true)
		draw_circle(p, 21, INK, true, -1, true)
		draw_circle(p, 17, Color("a52b39") if id == "gate" else GOLD, true, -1, true)
		_text(str(data.places[id].name), p + offsets[id], 34, INK, true, true, true)
	var marker := MAP_ORIGIN + Vector2(player_position.x, player_position.z) * MAP_SCALE
	draw_circle(marker, 29, Color(1.0, 0.94, 0.79, 0.32), true, -1, true)
	draw_circle(marker, 23, PAPER, true, -1, true)
	draw_circle(marker, 21, INK, true, -1, true)
	draw_circle(marker, 15, Color.WHITE, true, -1, true)

func _draw_city() -> void:
	_gate_hits.clear()
	draw_rect(Rect2(0, 0, 1920, 1080), Color("3b3020"))
	var river := PackedVector2Array([Vector2(1527, 0), Vector2(1920, 0), Vector2(1920, 1080), Vector2(1546, 1080), Vector2(1550, 1030), Vector2(1530, 955), Vector2(1500, 880), Vector2(1508, 790), Vector2(1530, 710), Vector2(1555, 620), Vector2(1560, 510), Vector2(1545, 410), Vector2(1520, 300), Vector2(1502, 215), Vector2(1506, 100)])
	draw_colored_polygon(river, Color("25435e"))
	var centre := Vector2(816, 538)
	draw_circle(centre, 410, Color("6a5734"), true, -1, true)
	draw_circle(centre, 395, Color("32291c"), true, -1, true)
	draw_circle(centre, 380, Color("ebd5a4"), true, -1, true)
	draw_circle(centre, 369, Color("c6a56b"), true, -1, true)
	var corners := [Vector2(1081, 273), Vector2(1081, 803), Vector2(551, 803), Vector2(551, 273)]
	for p in corners:
		draw_line(centre, p, Color("92733c"), 13, true)
	draw_circle(centre, 116, Color("b99158"), true, -1, true)
	draw_arc(centre, 116, 0, TAU, 100, Color("e8d1a0"), 5, true)
	draw_polyline(PackedVector2Array([Vector2(1115, 388), Vector2(1270, 421), Vector2(1395, 438), Vector2(1536, 441)]), Color("25435e"), 24, true)
	var market_polygon := PackedVector2Array()
	var market_centre := Vector2(1020, 373)
	for i in range(97):
		var theta: float = TAU * i / 96.0
		market_polygon.append(market_centre + Vector2(cos(theta) * 126, sin(theta) * 99))
	draw_colored_polygon(market_polygon, Color("efac3b"))
	draw_polyline(market_polygon, PAPER, 5, true)
	var city: Dictionary = data.city_map
	var gates: Array = data.goal.gates
	for i in range(corners.size()):
		var p: Vector2 = corners[i]
		var rect := Rect2(p - Vector2(34, 34), Vector2(68, 68))
		_gate_hits.append(rect.grow(14))
		_rounded(rect, GOLD, 10, INK, 5)
		var right: bool = i < 2
		var y: float = 204 if i == 0 or i == 3 else 869
		var x: float = 1162 if right else 469
		var name: String = gates[i][0]
		var face_width := bold_font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 44).x
		_text(name, Vector2(x if right else x - face_width, y), 44, PAPER, true)
		var tag: String = city.gate_tags[name]
		var tag_width := font.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 38).x
		_text(tag, Vector2(x if right else x - tag_width, y + 49), 38, Color("d8b571"))
	_text(str(city.title), Vector2(58, 86), 48, PAPER, true)
	_text(str(city.line), Vector2(58, 140), 38, Color("d8b571"))
	_text(str(data.ui.city_map.central_square), Vector2(816, 552), 38, Color("422a0d"), false, false, true)
	_text(str(data.ui.city_map.river_market), Vector2(1018, 374), 40, INK, true, false, true)
	_text(str(data.ui.city_map.start_here), Vector2(1018, 423), 34, INK, false, false, true)
	_text(str(data.ui.city_map.canal), Vector2(1306, 489), 32, Color("98c2dd"))
	draw_set_transform(Vector2(1764, 576), deg_to_rad(78))
	_text(str(data.ui.city_map.river), Vector2.ZERO, 38, Color("98c2dd"))
	draw_set_transform(Vector2.ZERO)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if mode == "city_map":
			for i in range(_gate_hits.size()):
				if _gate_hits[i].has_point(event.position):
					city_gate_requested.emit(i)
					accept_event()
					return
			if Rect2(890, 270, 260, 205).has_point(event.position):
				market_requested.emit()
				accept_event()
		else:
			for id in _place_hits:
				if _place_hits[id].has_point(event.position):
					destination_requested.emit(id)
					accept_event()
					return
