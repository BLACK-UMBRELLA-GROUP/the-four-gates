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


func point(id: String) -> Vector3:
	var source: Dictionary = data.street_points[id] if data.street_points.has(id) else data.places[id]
	return Vector3(source.x, 0.0, source.z)


func _point2(id: String) -> Vector2:
	var p := point(id)
	return Vector2(p.x, p.z)


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


func open_gate() -> void:
	if gate_open:
		return
	gate_open = true
	gate_body.collision_layer = 0
	gate_body.collision_mask = 0
	gate_tween = create_tween()
	gate_tween.tween_property(gate_hinge, "rotation:y", -PI / 2.0, 0.8)


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
