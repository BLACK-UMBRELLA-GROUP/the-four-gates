extends Control
## Market, city and world map projection. Drawing measurements follow the approved masters;
## place coordinates, street widths, words and gameplay values come from data.

signal destination_requested(place_id: String)
signal city_gate_requested(index: int)
signal city_part_requested(part: String)
signal town_requested(index: int)
signal city_requested
signal market_requested

var data: Dictionary = {}
var identity: Dictionary = {}
var mode := "market_map"
var night := false
var player_position := Vector3.ZERO
var selected_place := ""
var gate_open := false
var font: Font = SystemFont.new()
var bold_font: Font = SystemFont.new()
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

func configure(source: Dictionary, identity_value: Dictionary) -> void:
	data = source
	identity = identity_value
	queue_redraw()

func project_point(value: Dictionary) -> Vector2:
	return MAP_ORIGIN + Vector2(float(value.x), float(value.z)) * MAP_SCALE

func _draw() -> void:
	if data.is_empty():
		return
	if mode == "city_map":
		_draw_city()
	elif mode == "world_map":
		_draw_world()
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
	if gate_open:
		draw_circle(gate, float(data.world.gatehouse.arch_width) * MAP_SCALE / 2.0, Color("80b78a"))
		draw_rect(Rect2(gate.x - 34, gate.y, 68, 26), Color("80b78a"))
	if night:
		for edge in data.streets:
			var a := project_point(data.street_points[edge[0]])
			var b := project_point(data.street_points[edge[1]])
			var middle: Vector2 = (a + b) / 2.0
			for ring in range(10, 0, -1):
				draw_circle(middle, ring * 4.5, Color(1.0, 0.73, 0.28, 0.018 * (11 - ring)), true, -1, true)
			draw_circle(middle, 6.5, Color("ffd67f"), true, -1, true)
	var road_label: String = data.ui.market_map.road_east
	_text(road_label, Vector2(971, 219), 30, PAPER if not night else Color("7e7a7a"), false, true, false, INK)
	_text(str(data.ui.market_map.scale_bar), Vector2(148, 294), 30, PAPER, false, true, false, INK)
	draw_line(Vector2(148, 311), Vector2(360, 311), PAPER, 6)
	_text(str(data.ui.market_map.canal), Vector2(1498, 1029), 30, Color("adcee1") if not night else Color("64758a"))
	var offsets := {
		"gate": Vector2(0, 61), "board": Vector2(0, 61),
		"scales": Vector2(0, 61), "quay": Vector2(0, -35),
		"spice": Vector2(0, 61), "weaver": Vector2(0, 61),
		"centre": Vector2(189, -35), "inn": Vector2(0, -35),
		"masjid": Vector2(0, 61)
	}
	for id in data.places:
		var p := project_point(data.places[id])
		draw_circle(p, 23, PAPER, true, -1, true)
		draw_circle(p, 21, INK, true, -1, true)
		draw_circle(p, 17, Color("a52b39") if id == "gate" else GOLD, true, -1, true)
		_text(str(data.places[id].name), p + offsets[id], 34, INK, true, true, true)
	var marker := MAP_ORIGIN + Vector2(player_position.x, player_position.z) * MAP_SCALE
	draw_circle(marker, 29, Color(1.0, 0.94, 0.79, 0.32), true, -1, true)
	draw_circle(marker, 23, PAPER, true, -1, true)
	draw_circle(marker, 21, INK, true, -1, true)
	draw_circle(marker, 15, Color.WHITE, true, -1, true)

const CITY_CENTRE := Vector2(960, 547)
const CITY_RADIUS := 392.0
const PART_RADIUS := 126.0
const WORLD_CENTRE := Vector2(960, 538)
const WORLD_RADIUS := 232.0
const WORLD_GATE_OFFSET := 211.0

func _city_gate_positions() -> Array[Vector2]:
	return [Vector2(1354, 547), Vector2(960, 154), Vector2(960, 940), Vector2(566, 547)]

func _draw_city() -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), Color("3b3020"))
	var river := PackedVector2Array([Vector2(1584, 0), Vector2(1565, 100), Vector2(1568, 240), Vector2(1585, 400), Vector2(1592, 580), Vector2(1574, 750), Vector2(1548, 920), Vector2(1568, 1080)])
	draw_polyline(river, Color("3f7293"), 58, true)
	draw_circle(CITY_CENTRE, CITY_RADIUS + 29, Color("704d2b"), true, -1, true)
	draw_circle(CITY_CENTRE, CITY_RADIUS + 10, INK, true, -1, true)
	var parts := ["east", "south", "west", "north"]
	var colours := [Color("e8b966"), Color("cfa56c"), Color("d7ad74"), Color("d5b17c")]
	for index in range(parts.size()):
		var start: float = -PI / 4.0 + index * PI / 2.0
		var wedge := PackedVector2Array([CITY_CENTRE])
		for step in range(49):
			var angle: float = start + PI / 2.0 * step / 48.0
			wedge.append(CITY_CENTRE + Vector2(cos(angle), sin(angle)) * CITY_RADIUS)
		draw_colored_polygon(wedge, colours[index])
	for index in range(4):
		var angle: float = PI / 4.0 + index * PI / 2.0
		draw_line(CITY_CENTRE, CITY_CENTRE + Vector2(cos(angle), sin(angle)) * CITY_RADIUS, PAPER, 7, true)
	draw_arc(CITY_CENTRE, CITY_RADIUS, 0, TAU, 160, PAPER, 7, true)
	draw_circle(CITY_CENTRE, PART_RADIUS, Color("c79756"), true, -1, true)
	draw_arc(CITY_CENTRE, PART_RADIUS, 0, TAU, 96, PAPER, 7, true)
	var east: PackedStringArray = str(identity.city.parts.east.name).split(" · ")
	_text(east[0], Vector2(1219, 538), 44, INK, true, false, true)
	_text(east[1], Vector2(1219, 587), 34, INK, false, false, true)
	_text(identity.city.parts.north.name, Vector2(960, 288), 44, INK, true, false, true)
	_text(identity.city.parts.south.name, Vector2(960, 798), 44, INK, true, false, true)
	_text(identity.city.parts.west.name, Vector2(700, 538), 44, INK, true, false, true)
	_text(identity.city.parts.centre.name, Vector2(960, 562), 44, INK, true, false, true)
	var gate_keys := ["east", "north", "south", "west"]
	var positions := _city_gate_positions()
	var labels := [Vector2(1411, 562), Vector2(960, 97), Vector2(960, 998), Vector2(508, 562)]
	for index in range(4):
		var rect := Rect2(positions[index] - Vector2(29, 29), Vector2(58, 58))
		_rounded(rect, Color("80b78a") if index == 0 and gate_open else Color("a6303a"), 10, INK, 5)
		var label: String = identity.city.gates[gate_keys[index]]
		var at: Vector2 = labels[index]
		if index == 3:
			at.x -= bold_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 38).x
		_text(label, at, 38, PAPER, true, false, index in [1, 2])
	draw_circle(Vector2(1248, 652), 22, INK, true, -1, true)
	draw_circle(Vector2(1248, 652), 16, Color.WHITE, true, -1, true)
	_text(identity.city.inn_label, Vector2(1248, 715), 34, INK, true, true, true)
	_text(identity.city.name, Vector2(58, 86), 48, PAPER, true)
	_text(identity.city.map_title_line, Vector2(58, 140), 38, Color("d8b571"))

func _draw_world() -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), Color("cbbb90"))
	var gates := [Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.LEFT]
	for index in range(24):
		var position := Vector2(fmod(index * 227.0, 1920.0), fmod(index * 151.0, 1080.0))
		draw_circle(position, 45.0 + (index % 3) * 18, Color("c6b486"), true, -1, true)
	var river := PackedVector2Array([Vector2(1256, 0), Vector2(1236, 90), Vector2(1238, 240), Vector2(1246, 390), Vector2(1191, 570), Vector2(1199, 740), Vector2(1212, 910), Vector2(1192, 1080)])
	draw_polyline(river, Color("3f7293"), 44, true)
	for town: Dictionary in identity.world.towns_placeholder:
		var at := Vector2(town.x, town.y) * 4.8
		var offset := at - WORLD_CENTRE
		var direction := Vector2.ZERO
		if absf(offset.x) >= absf(offset.y):
			direction.x = signf(offset.x)
		else:
			direction.y = signf(offset.y)
		draw_dashed_line(WORLD_CENTRE + direction * WORLD_GATE_OFFSET, at, Color("b79a61"), 6, 15, true)
	draw_circle(WORLD_CENTRE, WORLD_RADIUS, Color("704d2b"), true, -1, true)
	draw_circle(WORLD_CENTRE, 219, PAPER, true, -1, true)
	draw_circle(WORLD_CENTRE, 212, Color("d5a76a"), true, -1, true)
	for direction: Vector2 in gates:
		var position := WORLD_CENTRE + direction * WORLD_GATE_OFFSET
		_rounded(Rect2(position - Vector2(24, 24), Vector2(48, 48)), Color("a6303a"), 10, INK, 5)
	_text(identity.city.name, Vector2(960, 490), 44, INK, true, false, true)
	_text(identity.world.city_label, Vector2(960, 543), 34, INK, false, false, true)
	draw_circle(Vector2(1133, 557), 18, INK, true, -1, true)
	draw_circle(Vector2(1133, 557), 12, Color.WHITE, true, -1, true)
	_text(identity.world.you_land, Vector2(1133, 614), 34, INK, true, true, true)
	for town: Dictionary in identity.world.towns_placeholder:
		var at := Vector2(town.x, town.y) * 4.8
		draw_circle(at, 23, Color("655031"), true, -1, true)
		draw_circle(at, 18, Color("e5d3aa"), true, -1, true)
		_text(town.name, at + Vector2(0, 61), 34, INK, false, true, true, Color("e5d3aa"))
	_text(identity.world.title, Vector2(48, 77), 48, INK, true)
	_text(identity.world.line.format({"n": identity.world.towns_placeholder.size()}), Vector2(48, 130), 36, Color("55401e"))

func _part_at(at: Vector2) -> String:
	var delta := at - CITY_CENTRE
	if delta.length() > CITY_RADIUS:
		return ""
	if delta.length() <= PART_RADIUS:
		return "centre"
	if absf(delta.x) >= absf(delta.y):
		return "east" if delta.x >= 0 else "west"
	return "south" if delta.y >= 0 else "north"

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	if mode == "city_map":
		var positions := _city_gate_positions()
		for index in range(positions.size()):
			if Rect2(positions[index] - Vector2(39, 39), Vector2(78, 78)).has_point(event.position):
				city_gate_requested.emit(index)
				accept_event()
				return
		if Rect2(1120, 625, 250, 110).has_point(event.position):
			market_requested.emit()
		else:
			var part := _part_at(event.position)
			if not part.is_empty():
				city_part_requested.emit(part)
		accept_event()
	elif mode == "world_map":
		if event.position.distance_to(WORLD_CENTRE) <= WORLD_RADIUS:
			city_requested.emit()
		else:
			for index in range(identity.world.towns_placeholder.size()):
				var town: Dictionary = identity.world.towns_placeholder[index]
				var at := Vector2(town.x, town.y) * 4.8
				if Rect2(at - Vector2(28, 28), Vector2(56, 100)).has_point(event.position):
					town_requested.emit(index)
					break
		accept_event()
	else:
		for id in data.places:
			var at := project_point(data.places[id])
			if Rect2(at - Vector2(28, 28), Vector2(56, 56)).has_point(event.position):
				destination_requested.emit(id)
				accept_event()
				return
