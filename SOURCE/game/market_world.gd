extends Node3D
## Deterministic greybox generated from the approved metre-space plan.

var data: Dictionary
var places := {}
var lanterns: Array[OmniLight3D] = []
var night := false
var gate_body: StaticBody3D
var gate_hinge: Node3D
var gate_open := false
var gate_tween: Tween
var sun: DirectionalLight3D
var environment: Environment
var house_count := 0
var _segments: Array = []
var _inn_people: Node3D
var salma: Node3D
var faris_at_oven: Node3D
var faris_at_quay: MeshInstance3D
var rashid: MeshInstance3D
var layla: MeshInstance3D
var talking_people: Dictionary = {}
# Hide named street figures from the static title and settings backdrop.
const STREET_FIGURES_LAYER := 2

var title_camera: Camera3D
var oven_camera: Camera3D
var iftar_giving_camera: Camera3D
var dice_house_camera: Camera3D
var qasims_offer_camera: Camera3D
var gate_opening_camera: Camera3D
var jisra_camera: Camera3D
var qasims_done_camera: Camera3D
var jabirs_goats_camera: Camera3D
var sealed_purse_offer_camera: Camera3D
var sealed_purse_coin_camera: Camera3D
var sealed_purse_delivery_camera: Camera3D
var spice_row_camera: Camera3D
var weaver_lane_camera: Camera3D
var weaver_reputation_camera: Camera3D
var _faris_start: Vector3
var _faris_run: Tween


func setup(source: Dictionary) -> void:
	data = source
	for street in data.streets:
		_segments.append([_point2(street[0]), _point2(street[1])])
	var area: Dictionary = data.world.area
	var quay: Dictionary = data.world.quay
	var wall: Dictionary = data.world.wall
	var depth := float(data.player.max_step) / 2.0
	_box(Vector3(area.width_x / 2.0, -depth / 2.0, quay.z_to / 2.0), Vector3(area.width_x, depth, quay.z_to), Color("b48b56"))
	_box(Vector3(area.width_x / 2.0, depth / 4.0, (quay.z_from + quay.z_to) / 2.0), Vector3(area.width_x, depth / 2.0, quay.z_to - quay.z_from), Color("cabc97"), false)
	var water: Dictionary = data.world.canal
	_box(Vector3(area.width_x / 2.0, water.water_y, (water.z_from + water.z_to) / 2.0), Vector3(area.width_x, depth, water.z_to - water.z_from), Color("315b73"), false)
	for segment in _segments:
		_path(segment[0], segment[1], data.street_width, depth)
	var square := MeshInstance3D.new()
	var circle := CylinderMesh.new()
	circle.top_radius = data.square.radius
	circle.bottom_radius = data.square.radius
	circle.height = depth / 2.0
	square.mesh = circle
	square.position = point(data.square.centre) + Vector3.UP * depth / 4.0
	square.material_override = _material(Color("e7d5a9"))
	add_child(square)
	_build_houses()
	_build_gate()
	# Containment surfaces stop players leaving this approved slice or entering water.
	var height := float(wall.height)
	_box(Vector3(0.0, height / 2.0, quay.z_to / 2.0), Vector3(depth, height, quay.z_to), Color("8b7050"))
	_box(Vector3(area.width_x, height / 2.0, quay.z_to / 2.0), Vector3(depth, height, quay.z_to), Color("8b7050"))
	var barrier := _box(Vector3(area.width_x / 2.0, height / 2.0, quay.z_to), Vector3(area.width_x, height, depth), Color.TRANSPARENT)
	barrier.get_child(0).hide()
	var west := point(data.world.west_exit.at)
	_box(west + Vector3(0.0, height / 2.0, 0.0), Vector3(depth, height, data.street_width), Color("675441"))
	for id in data.places:
		var trigger := Area3D.new()
		trigger.name = id
		trigger.position = point(id)
		trigger.collision_layer = 0
		trigger.collision_mask = 1
		var shape := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = data.player.use_radius
		shape.shape = sphere
		trigger.add_child(shape)
		add_child(trigger)
		places[id] = trigger
	for segment in _segments:
		var middle: Vector2 = (segment[0] + segment[1]) / 2.0
		var light := OmniLight3D.new()
		light.position = Vector3(middle.x, data.player.capsule_height * 2.0, middle.y)
		light.light_color = Color("ffd184")
		light.light_energy = 2.0
		light.omni_range = data.street_width * 2.0
		light.shadow_enabled = false
		add_child(light)
		lanterns.append(light)
		_box(light.position, Vector3.ONE * depth, Color("ffd184"), false)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45.0, -25.0, 0.0)
	sun.shadow_enabled = true
	add_child(sun)
	var world_environment := WorldEnvironment.new()
	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world_environment.environment = environment
	add_child(world_environment)
	set_night(false)

	var height_at_eye := Vector3.UP * float(data.camera.height_above_feet)
	var title_at := point(data.start_place) + height_at_eye + Vector3.BACK * float(data.camera.distance_behind)
	title_camera = _story_camera(title_at, title_at + Vector3.FORWARD)
	title_camera.set_cull_mask_value(STREET_FIGURES_LAYER, false)
	var pier := point("pier")
	var quay_view := point("quay").lerp(pier, 0.25) + height_at_eye
	quay_view.z = (float(quay.z_from) + float(quay.z_to)) / 2.0
	var quay_target := Vector3(pier.x, quay_view.y, quay_view.z)
	qasims_offer_camera = _story_camera(quay_view, quay_target)
	jisra_camera = _story_camera(quay_view, quay_target)
	jisra_camera.set_cull_mask_value(STREET_FIGURES_LAYER, false)
	var gate := point("gate") + height_at_eye
	var gate_approach := (point("gate") - point("a1")).normalized()
	gate_opening_camera = _story_camera(gate - gate_approach * float(data.camera.distance_behind), gate)
	gate_opening_camera.set_cull_mask_value(STREET_FIGURES_LAYER, false)
	var lane_view := point("a2") + height_at_eye
	qasims_done_camera = _story_camera(lane_view, point("board") + height_at_eye)
	var gate_lane := point("a1") + height_at_eye
	jabirs_goats_camera = _story_camera(gate_lane, point(data.square.centre) + height_at_eye)
	var masjid_view := point("masjid") + height_at_eye
	iftar_giving_camera = _story_camera(masjid_view, point("board") + height_at_eye)


func point(id: String) -> Vector3:
	var source: Dictionary = data.street_points[id] if data.street_points.has(id) else data.places[id]
	return Vector3(source.x, 0.0, source.z)


func setup_chapter_people(chapter: Dictionary, regulars: Array) -> void:
	_inn_people = Node3D.new()
	_inn_people.name = "InnPeople"
	_inn_people.position = point("inn")
	add_child(_inn_people)
	var down_street := (point(data.places.inn.street) - point("inn")).normalized()
	var toward_edge := Vector3.UP.cross(down_street) * (float(data.street_width) / 3.0)
	var index := 0
	var faris_name := ""
	for person: Dictionary in chapter.purse.people:
		if person.hidden:
			continue
		var offset := toward_edge + down_street * (index + 1) * float(data.player.capsule_height)
		var display_name := str(person.name).get_slice(",", 0)
		_add_chapter_person(_inn_people, display_name, offset)
		if person.id == "boy":
			faris_name = display_name
		index += 1

	var spacing := float(data.player.capsule_height)
	var along_spice_row := (point("sp1") - point("spice")).normalized()
	var along_weaver_lane := (point(data.square.centre) - point("weaver")).normalized()
	var along_square := (point(data.square.centre) - point("board")).normalized()
	var oven_at := point("board") + along_square * spacing
	var oven_size := Vector3(1.0, 0.9, 0.85) * spacing
	_box(oven_at + Vector3.UP * oven_size.y / 2.0, oven_size, Color("8b5c41"), false)
	var beside_oven := along_square.cross(Vector3.UP) * spacing
	var positions := {
		"board": oven_at + beside_oven,
		"spice": point("spice") + along_spice_row.cross(Vector3.UP) * spacing,
		"weaver": point("weaver") + along_weaver_lane.cross(Vector3.UP) * spacing,
		"quay": point("quay") - Vector3.RIGHT * spacing,
		"scales": point("scales") + Vector3.RIGHT * spacing,
	}
	for regular: Dictionary in regulars:
		talking_people[regular.id] = _add_chapter_person(self, regular.name, positions[regular.place])
	salma = talking_people.salma
	rashid = talking_people.rashid
	layla = talking_people.layla
	faris_at_quay = _add_chapter_person(self, faris_name, point("quay") + Vector3.RIGHT * spacing)
	faris_at_oven = _add_chapter_person(self, faris_name, oven_at - beside_oven)
	_faris_start = faris_at_oven.position
	faris_at_oven.hide()
	# Frame the oven from inside the square with room above the story panel for Faris.
	oven_camera = Camera3D.new()
	add_child(oven_camera)
	var distance := float(data.camera.distance_behind)
	var lane_height := Vector3.UP * float(data.camera.height_above_feet)
	var weaver_view := point("weaver") - along_weaver_lane * distance + lane_height
	var lane_target := point(data.square.centre) + lane_height
	weaver_lane_camera = _story_camera(weaver_view, lane_target)
	weaver_lane_camera.set_cull_mask_value(STREET_FIGURES_LAYER, false)
	# LOCK 31 frames What people say at an angle down the same lane.
	var lane_side := along_weaver_lane.cross(Vector3.UP) * (float(data.street_width) / 2.0)
	weaver_reputation_camera = _story_camera(weaver_view, lane_target + lane_side)
	weaver_reputation_camera.set_cull_mask_value(STREET_FIGURES_LAYER, false)
	var height := float(data.camera.height_above_feet) + float(data.player.capsule_height)
	oven_camera.position = oven_at + along_square * distance + beside_oven * 2.0 + Vector3.UP * height
	oven_camera.look_at(oven_at + along_square * float(data.player.capsule_height))

	# Frame the night scene from beyond the group waiting outside the inn.
	var inn_view := point("inn") + down_street * (index + 1) * spacing + Vector3.UP * float(data.camera.height_above_feet)
	dice_house_camera = _story_camera(inn_view, inn_view + down_street * distance)


func set_inn_people_waiting(waiting: bool) -> void:
	_inn_people.visible = waiting


func setup_sealed_purse_people(karim_name: String, abbas_name: String) -> void:
	var spacing := float(data.player.capsule_height)
	var quay := point("quay")
	var toward_pier := (point("pier") - quay).normalized()
	var karim_at := quay + toward_pier * spacing * 2.0
	var karim := _add_chapter_person(self, karim_name, karim_at)
	karim.name = karim_name
	var gate := point("gate")
	var toward_gate := (gate - point("a1")).normalized()
	var abbas_at := gate - toward_gate * spacing * 2.0 + toward_gate.cross(Vector3.UP) * spacing
	var abbas := _add_chapter_person(self, abbas_name, abbas_at)
	abbas.name = abbas_name

	var height := Vector3.UP * float(data.camera.height_above_feet)
	var distance := float(data.camera.distance_behind)
	var quay_view := karim_at - toward_pier * distance / 2.0 + Vector3.BACK * spacing + height
	sealed_purse_offer_camera = _story_camera(quay_view, quay_view + toward_pier * distance)
	var on_the_way := point("a2")
	var toward_square := (point(data.square.centre) - on_the_way).normalized()
	sealed_purse_coin_camera = _story_camera(on_the_way + height, on_the_way + toward_square * distance + height)
	sealed_purse_delivery_camera = _story_camera(abbas_at - toward_gate * distance + height, gate + height)
	var market_view := point("spice") + height
	spice_row_camera = _story_camera(market_view, point("sp1") + height)


func _story_camera(at: Vector3, target: Vector3) -> Camera3D:
	var camera := Camera3D.new()
	add_child(camera)
	camera.position = at
	camera.look_at(target)
	return camera


func run_faris_from_oven() -> void:
	stop_faris_run()
	faris_at_oven.position = _faris_start
	faris_at_oven.show()
	var end := point(data.square.centre)
	end.y = _faris_start.y
	var duration := _faris_start.distance_to(end) / float(data.player.run_speed)
	_faris_run = create_tween()
	_faris_run.tween_property(faris_at_oven, "position", end, duration)
	_faris_run.tween_callback(faris_at_oven.hide)


func stop_faris_run() -> void:
	if _faris_run != null:
		_faris_run.kill()
	faris_at_oven.hide()


func _add_chapter_person(parent: Node3D, display_name: String, at: Vector3) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.height = data.player.capsule_height
	mesh.radius = data.player.capsule_radius
	var person := MeshInstance3D.new()
	person.mesh = mesh
	person.layers = 1 << (STREET_FIGURES_LAYER - 1)
	person.material_override = _material(Color("9c664a"))
	person.position = at + Vector3.UP * mesh.height / 2.0
	parent.add_child(person)
	var label := Label3D.new()
	label.text = display_name
	label.layers = person.layers
	label.set_meta("normal_font_size", label.font_size)
	label.position.y = mesh.height / 2.0 + mesh.radius
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	person.add_child(label)
	return person


func _point2(id: String) -> Vector2:
	var p := point(id)
	return Vector2(p.x, p.z)


func set_scene_motion_paused(paused: bool) -> void:
	for tween in [gate_tween, _faris_run]:
		if tween != null and tween.is_valid():
			if paused:
				tween.pause()
			else:
				tween.play()


func set_text_multiplier(multiplier: float) -> void:
	for label in find_children("*", "Label3D", true, false):
		label.font_size = roundi(int(label.get_meta("normal_font_size")) * multiplier)


func set_night(value: bool) -> void:
	night = value
	if sun == null:
		return
	sun.visible = not night
	environment.background_color = Color("101b2b") if night else Color("9ab8ca")
	environment.ambient_light_color = Color("70829e") if night else Color("fff0d1")
	environment.ambient_light_energy = 0.35 if night else 0.65
	for light in lanterns:
		light.visible = night


func _path(a: Vector2, b: Vector2, width: float, thickness: float) -> void:
	var middle := (a + b) / 2.0
	var body := _box(Vector3(middle.x, thickness / 4.0, middle.y), Vector3(width, thickness / 2.0, a.distance_to(b)), Color("e7d5a9"), false)
	body.rotation.y = atan2(b.x - a.x, b.y - a.y)
	for p in [a, b]:
		var disk := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = width / 2.0
		mesh.bottom_radius = width / 2.0
		mesh.height = thickness / 2.0
		disk.mesh = mesh
		disk.material_override = _material(Color("e7d5a9"))
		disk.position = Vector3(p.x, thickness / 4.0, p.y)
		add_child(disk)


func _build_gate() -> void:
	var wall: Dictionary = data.world.wall
	var house: Dictionary = data.world.gatehouse
	var gate := point(house.at)
	var half_arch := float(house.arch_width) / 2.0
	var thickness := float(wall.z_to - wall.z_from)
	var left_end := gate.x - half_arch
	var right_start := gate.x + half_arch
	_box(Vector3(left_end / 2.0, wall.height / 2.0, (wall.z_from + wall.z_to) / 2.0), Vector3(left_end, wall.height, thickness), Color("957145"))
	_box(Vector3((right_start + data.world.area.width_x) / 2.0, wall.height / 2.0, (wall.z_from + wall.z_to) / 2.0), Vector3(data.world.area.width_x - right_start, wall.height, thickness), Color("957145"))
	var pillar := float(house.width - house.arch_width) / 2.0
	for side in [-1.0, 1.0]:
		_box(gate + Vector3(side * (half_arch + pillar / 2.0), wall.height / 2.0, 0.0), Vector3(pillar, wall.height, thickness), Color("8a6340"))
	var opening_height := float(data.player.capsule_height) * 2.0
	_box(gate + Vector3(0.0, opening_height + (wall.height - opening_height) / 2.0, 0.0), Vector3(house.arch_width, wall.height - opening_height, thickness), Color("8a6340"))
	gate_body = _box(gate + Vector3(0.0, opening_height / 2.0, 0.0), Vector3(house.arch_width, opening_height, data.world.houses.max_gap), Color("4f3e31"))
	gate_body.name = "ClosedGate"
	gate_hinge = Node3D.new()
	gate_hinge.position = gate + Vector3(-half_arch, 0.0, 0.0)
	add_child(gate_hinge)
	gate_body.reparent(gate_hinge, true)


func open_gate(animated: bool = true) -> void:
	if gate_open and animated:
		return
	gate_open = true
	gate_body.collision_layer = 0
	gate_body.collision_mask = 0
	var open_angle := -PI / 2.0
	if not animated:
		if gate_tween != null:
			gate_tween.kill()
		gate_hinge.rotation.y = open_angle
		return
	gate_tween = create_tween()
	gate_tween.tween_property(gate_hinge, "rotation:y", open_angle, 0.8)


func reset_gate() -> void:
	if not gate_open:
		return
	if gate_tween != null:
		gate_tween.kill()
	gate_open = false
	gate_body.collision_layer = 1
	gate_body.collision_mask = 1
	gate_hinge.rotation.y = 0.0


func _build_houses() -> void:
	# Conservative cells never occupy any approved street or square. The fine cell
	# diagonal is below the allowed house gap; identical runs merge into plain boxes.
	var cell := float(data.world.houses.max_gap) / 2.0
	var x_count := ceili(float(data.world.area.width_x) / cell)
	var z_start := float(data.world.wall.z_to)
	var z_end := float(data.world.quay.z_from)
	var z_count := ceili((z_end - z_start) / cell)
	var active := {}
	for zi in range(z_count):
		var z0 := z_start + zi * cell
		var z1 := minf(z0 + cell, z_end)
		var runs := {}
		var begin := -1
		for xi in range(x_count + 1):
			var occupied := false
			if xi < x_count:
				var x0 := xi * cell
				var x1 := minf(x0 + cell, data.world.area.width_x)
				occupied = _house_cell(Vector2((x0 + x1) / 2.0, (z0 + z1) / 2.0), Vector2(x1 - x0, z1 - z0).length() / 2.0)
			if occupied and begin < 0:
				begin = xi
			elif not occupied and begin >= 0:
				var key := Vector2i(begin, xi)
				runs[key] = true
				if active.has(key):
					active[key].end = z1
				else:
					active[key] = {"start": z0, "end": z1}
				begin = -1
		for key in active.keys():
			if not runs.has(key):
				_house_run(key, active[key], cell)
				active.erase(key)
	for key in active:
		_house_run(key, active[key], cell)


func _house_cell(centre: Vector2, half_diagonal: float) -> bool:
	if centre.distance_to(_point2(data.square.centre)) <= float(data.square.radius) + half_diagonal:
		return false
	for segment in _segments:
		var nearest := Geometry2D.get_closest_point_to_segment(centre, segment[0], segment[1])
		if centre.distance_to(nearest) <= float(data.street_width) / 2.0 + half_diagonal:
			return false
	return true


func _house_run(span: Vector2i, interval: Dictionary, cell: float) -> void:
	var min_height := float(data.world.houses.height_min)
	var max_height := float(data.world.houses.height_max)
	var height := lerpf(min_height, max_height, float(house_count % 3) / 2.0)
	var x0 := span.x * cell
	var x1 := minf(span.y * cell, data.world.area.width_x)
	var colour := Color("b18a57") if house_count % 2 == 0 else Color("c59c63")
	_box(Vector3((x0 + x1) / 2.0, height / 2.0, (interval.start + interval.end) / 2.0), Vector3(x1 - x0, height, interval.end - interval.start), colour)
	house_count += 1


func _material(colour: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = 1.0
	return material


func _box(at: Vector3, size: Vector3, colour: Color, solid := true) -> Node3D:
	var body: Node3D = StaticBody3D.new() if solid else Node3D.new()
	body.position = at
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.material_override = _material(colour)
	body.add_child(visual)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
	add_child(body)
	return body
