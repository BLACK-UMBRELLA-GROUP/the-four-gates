extends SceneTree
## Plain, dependency-free checks against the real scene and physics world.

var checks := 0
var failures := 0
var app
var data: Dictionary
var identity: Dictionary
var runtime_baseline: PackedByteArray


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)


func frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func _run() -> void:
	var runtime := FileAccess.get_file_as_bytes("res://data/foundations.json")
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/FOUNDATIONS/RECORD/foundations_data_V2.json")
	runtime_baseline = runtime
	var identity_bytes := FileAccess.get_file_as_bytes("res://data/identity.json")
	var locked_identity := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/IDENTITY/RECORD/identity_data_V3.json")
	check(not identity_bytes.is_empty() and identity_bytes == locked_identity, "identity runtime is the byte-identical LOCK 2 V3 file")
	identity = JSON.parse_string(identity_bytes.get_string_from_utf8())
	var expected: Dictionary = renamed_foundations(JSON.parse_string(approved.get_string_from_utf8()))
	expected.goal.gates = JSON.parse_string(identity.renames_in_foundations_data[5][1])
	expected.erase("city_map")
	check(not runtime.is_empty() and JSON.parse_string(runtime.get_string_from_utf8()) == expected, "foundations contains exactly the line-5 transformations and no later-line changes")
	check_retired_content()
	var parsed = JSON.parse_string(runtime.get_string_from_utf8())
	if not parsed is Dictionary:
		check(false, "approved data parses as a dictionary")
		finish()
		return
	data = parsed
	var scene = load("res://game/river_market.tscn")
	if not scene is PackedScene:
		check(false, "main gameplay scene loads")
		finish()
		return
	app = scene.instantiate()
	root.add_child(app)
	await frames(3)
	data = app.data
	check(app.ui.screen == "title", "launch opens the title")
	check(visible_text().replace("\n", "").contains(data.title_screen.title), "title uses approved title text")
	check(visible_text().contains(data.title_screen.line), "title uses approved subtitle")
	check(visible_text().contains(identity.city.name), "title uses the locked city name")
	check(visible_text().contains(data.ui.buttons.begin), "title has Begin")
	check(visible_text().contains(data.ui.buttons.settings), "title has Settings")
	var settings_button: Button = find_button(app.ui, data.ui.buttons.settings)
	if settings_button != null:
		settings_button.pressed.emit()
		await frames(1)
	check(visible_text().contains(data.title_screen.settings_toast), "Settings button shows its approved temporary toast")
	var begin_button: Button = find_button(app.ui, data.ui.buttons.begin)
	check(begin_button != null, "Begin is a real button")
	if begin_button != null:
		begin_button.pressed.emit()
	else:
		app.begin_game()
	await frames(4)
	var spawn: Vector3 = app.world.point(data.start_place)
	check(app.ui.screen == "market_map", "Begin opens the market map until arrival is built")
	check(horizontal_distance(app.player.global_position, spawn) < 0.02, "Begin spawns at the quay")
	check(is_zero_approx(app.player.yaw), "spawn faces north")
	check(app.world.places.size() == data.places.size(), "one trigger exists for every approved place")
	for id: String in data.places:
		check(app.world.places.has(id) and app.world.places[id] is Area3D, "place has a real Area3D: " + id)
		var trigger: Area3D = app.world.places[id]
		check(horizontal_distance(trigger.global_position, app.world.point(id)) < 0.02, "place trigger is at its approved point: " + id)
		check(is_equal_approx(trigger.get_child(0).shape.radius, float(data.player.use_radius)), "place trigger has the approved use radius: " + id)
	check(app.world.lanterns.size() == data.streets.size() * int(data.world.lanterns.per_street), "one lantern exists per street")
	check(app.world.gate_body is StaticBody3D and app.world.gate_body.collision_layer != 0, "gate starts closed with physical collision")
	check(app.current_place == data.start_place, "quay use bar is active at spawn")
	check(is_equal_approx(app.player.get_child(0).shape.height, float(data.player.capsule_height)), "player capsule has approved height")
	check(is_equal_approx(app.player.get_child(0).shape.radius, float(data.player.capsule_radius)), "player capsule has approved radius")
	check(is_equal_approx(app.player.camera_pivot.position.y, float(data.camera.height_above_feet)), "camera pivot has approved height above feet")
	check(has_visible_label(app.ui, data.ui.hud.coins.format({"n": int(data.numbers.start_coins)})), "HUD shows the exact approved integer coins label")
	check(visible_text().contains(data.ui.hud.trust_label), "HUD shows the approved trust label")
	check(has_visible_label(app.ui, data.ui.hud.trust_value.format({"n": int(data.numbers.start_trust)})), "HUD shows the exact approved integer trust value")
	if "--steps-only" in OS.get_cmdline_user_args():
		await check_step_and_camera_collision()
		finish()
		return
	await check_data_driven_bindings()
	await check_input_and_camera()
	await check_route_and_boundaries()
	await check_production_map_route()
	await check_step_and_camera_collision()
	await check_ui_states()
	await check_task_economics()
	await check_lesson_and_gate()
	await check_identity_maps_and_places()
	finish()


func horizontal_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func visible_text() -> String:
	var result: Array[String] = []
	collect_text(app.ui, result)
	return "\n".join(result)


func collect_text(node: Node, result: Array[String]) -> void:
	if node is Control and not node.is_visible_in_tree():
		return
	if node is Label or node is Button or node is RichTextLabel:
		result.append(node.text)
	for child in node.get_children():
		collect_text(child, result)


func find_button(node: Node, label: String) -> Button:
	if node is Button and node.text == label:
		return node
	for child in node.get_children():
		var found := find_button(child, label)
		if found != null:
			return found
	return null


func has_visible_label(node: Node, expected: String) -> bool:
	if node is Control and not node.is_visible_in_tree():
		return false
	if node is Label and node.text == expected:
		return true
	for child in node.get_children():
		if has_visible_label(child, expected):
			return true
	return false


func key_event(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)


func look_event(relative: Vector2) -> void:
	if DisplayServer.get_name() == "headless":
		# The dummy display cannot capture a mouse. Exercise the same transform
		# called by real mouse dispatch; rendered QA verifies dispatch separately.
		app.player.apply_look(relative)
	else:
		var event := InputEventMouseMotion.new()
		event.relative = relative
		Input.parse_input_event(event)


func approved_bindings(source: Dictionary) -> Dictionary:
	var move: PackedStringArray = str(source.keys.move).split(" ", false)
	return {
		"move_forward": move[0], "move_left": move[1],
		"move_back": move[2], "move_right": move[3],
		"run": source.keys.run, "use": source.keys.use,
		"market_map": source.keys.market_map, "goal": source.keys.goal,
		"wait_day_night": source.keys.wait_day_night, "close": source.keys.close,
	}


func label_key(label: String) -> Key:
	return KEY_ESCAPE if label == "Esc" else OS.find_keycode_from_string(label)


func has_binding(action: StringName, key: Key) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == key:
			return true
	return false


func check_data_driven_bindings() -> void:
	var expected := approved_bindings(data)
	for action: String in expected:
		var key: Key = label_key(expected[action])
		check(key != KEY_NONE and InputMap.has_action(action) and has_binding(action, key), "runtime action uses its approved data key: " + action)
	# An in-memory alternate configuration proves the data drives bindings;
	# neither the approved dictionary nor its on-disk bytes are changed.
	var alternate: Dictionary = data.duplicate(true)
	alternate.keys.move = "I J K L"
	var foundations = load("res://game/foundations.gd")
	foundations.configure_input(alternate)
	var alternate_expected := approved_bindings(alternate)
	for action: String in ["move_forward", "move_left", "move_back", "move_right"]:
		check(has_binding(action, label_key(alternate_expected[action])), "alternate data changes the runtime movement binding: " + action)
	check(not has_binding("move_forward", label_key(expected.move_forward)), "reconfiguring removes the prior forward binding")
	app.player.global_position = app.world.point("sq")
	app.player.velocity = Vector3.ZERO
	app.player.yaw = 0.0
	app.show_screen("game")
	await frames(3)
	var before: Vector3 = app.player.global_position
	var forward: Key = label_key(alternate_expected.move_forward)
	key_event(forward, true)
	await frames(6)
	check(app.player.global_position.z < before.z and is_equal_approx(-app.player.velocity.z, float(data.player.walk_speed)), "alternate data key moves the actual player at the approved speed")
	key_event(forward, false)
	await frames(2)
	foundations.configure_input(data)
	for action: String in expected:
		check(has_binding(action, label_key(expected[action])), "approved binding is restored after the isolated alternate-data test: " + action)
	check(FileAccess.get_file_as_bytes("res://data/foundations.json") == runtime_baseline, "binding test preserves the approved transformed runtime bytes")


func check_input_and_camera() -> void:
	app.player.global_position = app.world.point("sq")
	app.player.yaw = 0.0
	app.show_screen("game")
	await frames(3)
	var start: Vector3 = app.player.global_position
	key_event(KEY_W, true)
	await frames(12)
	check(app.player.velocity.z < 0.0 and is_equal_approx(Vector2(app.player.velocity.x, app.player.velocity.z).length(), float(data.player.walk_speed)), "W walks north at the approved walk speed")
	check(app.player.global_position.z < start.z, "W changes the actual capsule position")
	key_event(KEY_SHIFT, true)
	await frames(3)
	check(is_equal_approx(Vector2(app.player.velocity.x, app.player.velocity.z).length(), float(data.player.run_speed)), "holding Shift uses the approved run speed")
	key_event(KEY_W, false)
	key_event(KEY_SHIFT, false)
	await frames(2)
	for item: Array in [[KEY_A, Vector2.LEFT], [KEY_S, Vector2.DOWN], [KEY_D, Vector2.RIGHT]]:
		key_event(item[0], true)
		await frames(3)
		var horizontal := Vector2(app.player.velocity.x, app.player.velocity.z)
		check(horizontal.dot(item[1]) > float(data.player.walk_speed) * 0.99, "movement key dispatches its approved direction: " + OS.get_keycode_string(item[0]))
		key_event(item[0], false)
		await frames(1)
	var before: float = app.player.yaw
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if DisplayServer.get_name() == "headless":
		print("HEADLESS LOOK: transform and clamp checks use the real mouse handler's apply_look method; captured mouse dispatch requires rendered QA.")
	look_event(Vector2(80.0, 0.0))
	await frames(1)
	check(not is_equal_approx(app.player.yaw, before), "look transform turns the real camera pivot")
	look_event(Vector2(0.0, 100000.0))
	await frames(1)
	check(is_equal_approx(app.player.pitch, deg_to_rad(data.camera.pitch_min_deg)), "camera tilt clamps to the approved minimum")
	look_event(Vector2(0.0, -100000.0))
	await frames(1)
	check(is_equal_approx(app.player.pitch, deg_to_rad(data.camera.pitch_max_deg)), "camera tilt clamps to the approved maximum")
	app.player.yaw = 0.0
	app.player.pitch = 0.0
	app.player.update_camera()


func walk_to(point_id: String) -> bool:
	var target: Vector3 = app.world.point(point_id)
	var arrival: float = data.player.use_radius if point_id == "gate" else data.player.capsule_radius
	var max_frames := int(ceil(horizontal_distance(app.player.global_position, target) / float(data.player.walk_speed) * float(Engine.physics_ticks_per_second))) + Engine.physics_ticks_per_second
	for index in range(max_frames):
		var delta: Vector3 = target - app.player.global_position
		if Vector2(delta.x, delta.z).length() < arrival:
			app.player.test_move_axis = Vector2.ZERO
			await frames(1)
			return true
		app.player.test_move_axis = Vector2(delta.x, delta.z).normalized()
		await frames(1)
	app.player.test_move_axis = Vector2.ZERO
	return false


func check_route_and_boundaries() -> void:
	app.player.global_position = app.world.point(data.start_place)
	app.player.velocity = Vector3.ZERO
	app.player.yaw = 0.0
	app.player.pitch = 0.0
	await frames(3)
	for id: String in ["a2", "sq", "a1", "gate"]:
		check(await walk_to(id), "real capsule can walk the approved quay-to-gate route through " + id)
	check(app.player.global_position.y > -float(data.player.max_step), "route remains on ground")
	var gate: Vector3 = app.world.point("gate")
	app.player.test_move_axis = Vector2(0.0, -1.0)
	await frames(60)
	app.player.test_move_axis = Vector2.ZERO
	check(app.player.global_position.z > float(data.world.wall.z_to) - float(data.player.capsule_radius), "closed gate prevents walking through the north wall")
	check(horizontal_distance(app.player.global_position, gate) < float(data.street_width), "gate collision stops the player near the approved gate")
	var space: PhysicsDirectSpaceState3D = app.world.get_world_3d().direct_space_state
	var north := PhysicsRayQueryParameters3D.create(Vector3(data.world.area.width_x / 2.0, 1.0, data.world.wall.z_to + data.street_width), Vector3(data.world.area.width_x / 2.0, 1.0, data.world.wall.z_from))
	north.exclude = [app.player.get_rid()]
	check(not space.intersect_ray(north).is_empty(), "north wall has collision")
	var house := PhysicsRayQueryParameters3D.create(Vector3(data.world.area.width_x / 2.0, data.world.houses.height_max + 1.0, data.world.wall.z_to + data.street_width), Vector3(data.world.area.width_x / 2.0, 1.0, data.world.wall.z_to + data.street_width))
	house.exclude = [app.player.get_rid()]
	check(not space.intersect_ray(house).is_empty(), "off-street house blocks have collision")
	app.player.global_position = Vector3(data.places.quay.x, 0.0, data.world.quay.z_to - data.player.capsule_radius)
	app.player.velocity = Vector3.ZERO
	app.player.test_move_axis = Vector2(0.0, 1.0)
	await frames(30)
	app.player.test_move_axis = Vector2.ZERO
	check(app.player.global_position.z < float(data.world.canal.z_from), "canal boundary is not walkable")
	app.player.global_position = app.world.point("centre")
	app.player.velocity = Vector3.ZERO
	app.player.test_move_axis = Vector2(-1.0, 0.0)
	await frames(60)
	app.player.test_move_axis = Vector2.ZERO
	check(app.player.global_position.x > 0.0, "west passage physically blocks the exit")


func check_production_map_route() -> void:
	# This street interior is closer to the board vertex across a house than
	# either endpoint of the street the player is actually standing on.
	app.begin_game()
	var start := Vector3(68.0, 0.0, data.street_points.weaver.z)
	app.player.global_position = start
	app.player.velocity = Vector3.ZERO
	app.show_screen("market_map")
	await frames(3)
	var before: Vector3 = app.player.global_position
	app.walk_to_place("board")
	check(app.player.global_position.is_equal_approx(before), "map-route planning does not teleport the capsule")
	var arrived := false
	var target: Vector3 = app.world.point("board")
	# Allow a generous bounded timeout, without assigning the movement test
	# input: production _physics_process must drive the real collision body.
	for index in range(Engine.physics_ticks_per_second * 30):
		await frames(1)
		if horizontal_distance(app.player.global_position, target) < float(data.player.use_radius):
			arrived = true
			break
	check(arrived, "production map route reaches the board from the middle of the sq-weaver street")
	if not arrived:
		print("ROUTE DIAGNOSTIC final=", app.player.global_position, " remaining=", app.route)
	await frames(3)
	check(app.route.is_empty(), "production map route completes when within the approved use radius")
	check(app.current_place == "board", "production map route activates the actual task-board bar")
	app.begin_game()


func fixture_box(size: Vector3, at: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	app.world.add_child(body)
	body.global_position = at
	return body


func check_step_and_camera_collision() -> void:
	var centre: Vector3 = app.world.point("sq")
	app.player.global_position = centre
	app.player.velocity = Vector3.ZERO
	app.player.yaw = 0.0
	app.player.pitch = 0.0
	var height: float = data.player.max_step
	var step := fixture_box(Vector3(data.street_width / 2.0, height, data.street_width / 2.0), centre + Vector3(data.street_width / 2.0, height / 2.0, 0.0))
	await frames(3)
	app.player.test_move_axis = Vector2.RIGHT
	var climbed := false
	var highest: float = app.player.global_position.y
	for index in range(45):
		await frames(1)
		climbed = climbed or app.player.global_position.y >= height - 0.02
		highest = maxf(highest, app.player.global_position.y)
	app.player.test_move_axis = Vector2.ZERO
	if not climbed:
		print("STEP DIAGNOSTIC highest_y=", highest, " final=", app.player.global_position, " expected_top=", height)
	check(climbed, "capsule climbs a physical step at the approved maximum height")
	step.queue_free()
	await frames(2)
	app.player.global_position = centre
	app.player.velocity = Vector3.ZERO
	var tall_height := height * 1.5
	var tall_step := fixture_box(Vector3(data.street_width / 2.0, tall_height, data.street_width / 2.0), centre + Vector3(data.street_width / 2.0, tall_height / 2.0, 0.0))
	await frames(3)
	app.player.test_move_axis = Vector2.RIGHT
	await frames(45)
	app.player.test_move_axis = Vector2.ZERO
	check(app.player.global_position.y < height and app.player.global_position.x < centre.x + data.street_width / 2.0, "capsule cannot climb a step above the approved maximum")
	tall_step.queue_free()
	await frames(2)
	app.player.global_position = centre
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	await frames(4)
	var full_distance: float = app.player.camera.global_position.distance_to(app.player.camera_pivot.global_position)
	check(absf(full_distance - float(data.camera.distance_behind)) < float(data.player.capsule_radius), "unobstructed camera sits at the approved distance")
	var blocker := fixture_box(Vector3(data.street_width, data.world.wall.height, data.player.capsule_radius), centre + Vector3(0.0, data.world.wall.height / 2.0, data.camera.distance_behind / 2.0))
	await frames(4)
	var blocked_distance: float = app.player.camera.global_position.distance_to(app.player.camera_pivot.global_position)
	check(blocked_distance < full_distance - float(data.player.capsule_radius), "camera pulls in at a real wall collider")
	blocker.queue_free()
	await frames(2)


func check_ui_states() -> void:
	app.show_screen("game")
	app.player.global_position = app.world.point(data.start_place)
	app.player.velocity = Vector3.ZERO
	app.update_state()
	key_event(KEY_M, true)
	key_event(KEY_M, false)
	await frames(2)
	check(app.ui.screen == "market_map", "M opens the market map")
	check(visible_text().contains(data.ui.buttons.city_map), "market map has City map")
	check(visible_text().contains(data.ui.buttons.wait_night), "day map has Wait until night")
	check(visible_text().contains(data.places.quay.line), "quay bar shows the approved line")
	check(visible_text().contains(data.ui.place_actions.quay), "quay bar shows Look around")
	key_event(KEY_T, true)
	key_event(KEY_T, false)
	await frames(2)
	check(app.night and app.world.night, "T switches both controller and world to night")
	for lantern: OmniLight3D in app.world.lanterns:
		check(lantern.visible, "night turns each actual lantern on")
	check(visible_text().contains(data.ui.buttons.wait_day), "night map has Wait until day")
	check(visible_text().contains(data.other_text.night), "night switch uses the approved toast")
	var wait_button: Button = find_button(app.ui, data.ui.buttons.wait_day)
	check(wait_button != null, "night map offers a real wait button")
	if wait_button != null:
		wait_button.pressed.emit()
	await frames(2)
	check(not app.night and not app.world.night, "map wait button switches back to day")
	for lantern: OmniLight3D in app.world.lanterns:
		check(not lantern.visible, "day turns each actual lantern off")
	check(visible_text().contains(data.other_text.day), "day switch uses the approved toast")
	var city_button: Button = find_button(app.ui, data.ui.buttons.city_map)
	check(city_button != null, "market map offers a real city-map button")
	if city_button != null:
		city_button.pressed.emit()
	else:
		app.show_screen("city_map")
	await frames(2)
	check(app.ui.screen == "city_map", "city map opens")
	check(app.ui.map.mode == "city_map" and app.ui.map.identity.city.name == identity.city.name, "city map drawing receives the approved title")
	check(app.ui.map.identity.city.map_title_line == identity.city.map_title_line, "city map drawing receives the approved line")
	for index in range(data.goal.gates.size()):
		app.ui.map.city_gate_requested.emit(index)
		await frames(1)
		var message: String = data.gate.needs_trust.format({"trust": app.progress.trust}) if index == 0 else data.ui.not_built
		check(visible_text().contains(message), "city gate tap is wired to its approved message: " + str(index))
	key_event(KEY_ESCAPE, true)
	key_event(KEY_ESCAPE, false)
	await frames(2)
	check(app.ui.screen == "market_map" or app.ui.screen == "game", "Esc closes the city panel")
	app.show_screen("game")
	for id: String in ["board", "scales", "gate"]:
		app.show_screen("game")
		app.player.global_position = app.world.point(id)
		app.player.velocity = Vector3.ZERO
		app.update_state()
		await frames(2)
		check(app.current_place == id, "use range selects the nearby place: " + id)
		check(visible_text().contains(data.places[id].line), "place bar uses the approved line: " + id)
		check(visible_text().contains(data.ui.place_actions[id]), "place bar uses the approved action: " + id)
		key_event(KEY_E, true)
		key_event(KEY_E, false)
		await frames(2)
		if id == "board":
			check(app.ui.screen == "board" and visible_text().contains(data.ui.board.title), "E at the board opens the actual task board")
		elif id == "scales":
			check(app.ui.screen == "lesson" and visible_text().contains(data.lesson.title), "E opens the scales lesson")
		else:
			check(visible_text().contains(data.gate.needs_trust.format({"trust": app.progress.trust})), "gate requires trust")
	app.player.global_position = app.world.point("centre")
	app.player.velocity = Vector3.ZERO
	app.update_state()
	app.use_place()
	await frames(2)
	check(visible_text().contains(data.other_text.centre_exit), "west exit uses the approved later-area toast")
	key_event(KEY_G, true)
	key_event(KEY_G, false)
	await frames(2)
	check(app.ui.screen == "goal" and visible_text().contains(data.goal.title), "G opens the approved goal panel")
	app.show_screen("game")
	for id: String in ["quay", "spice", "weaver"]:
		app.player.global_position = app.world.point(id)
		app.player.velocity = Vector3.ZERO
		app.update_state()
		app.ui.show_toast("")
		app.use_place()
		check(app.current_place == id and app.ui.screen == "game" and not visible_text().contains(data.ui.not_built), "Look around keeps the player in the world without a new action: " + id)
	app.player.global_position = app.world.point("sq")
	app.player.velocity = Vector3.ZERO
	app.update_state()
	check(app.current_place.is_empty(), "outside every use radius no place is selected")
	check(app.world.gate_body.collision_layer != 0, "temporary actions never open the gate")


func press_button(label: String, description: String) -> bool:
	var button: Button = find_button(app.ui, label)
	check(button != null and button.is_visible_in_tree() and not button.disabled, description)
	if button == null or button.disabled or not button.is_visible_in_tree():
		return false
	button.pressed.emit()
	await frames(2)
	return true


func reset_tasks() -> void:
	app.progress.setup(data)
	if app.night:
		app.toggle_night()
	app.player.global_position = app.world.point("board")
	app.player.velocity = Vector3.ZERO
	app.show_board()
	await frames(2)


func check_wallet(expected_trust: int, expected_coins: int, description: String) -> void:
	check(app.progress.trust == expected_trust and app.progress.coins == expected_coins, description)
	check(has_visible_label(app.ui, data.ui.hud.coins.format({"n": expected_coins})), description + ": live coins HUD")
	check(has_visible_label(app.ui, data.ui.hud.trust_value.format({"n": expected_trust})), description + ": live trust HUD")


func play_task(task: Dictionary, choice: String) -> void:
	await press_button(data.ui.buttons.take_task.format({"n": int(task.pay_shown)}), "task has a usable Take it button: " + task.id)
	check(app.ui.screen == "task", "taking the task opens its choice panel: " + task.id)
	check(visible_text().contains(task.story), "task shows the approved story: " + task.id)
	var text := visible_text()
	check(text.find(task.honest.choice) >= 0 and text.find(task.honest.choice) < text.find(task.quick.choice), "honest choice is first: " + task.id)
	var before_trust: int = app.progress.trust
	var before_coins: int = app.progress.coins
	await press_button(task[choice].choice, "choice is a real usable button: " + task.id + "/" + choice)
	check(app.ui.screen == "result", "choosing opens the result panel: " + task.id)
	check(visible_text().contains(task[choice].result), "result shows the approved consequence: " + task.id + "/" + choice)
	var label: String = data.ui.result.honest_label if choice == "honest" else data.ui.result.quick_label
	check(visible_text().to_lower().contains(label.to_lower()), "result shows its honest/quick label: " + task.id)
	var delta: int = app.progress.trust - before_trust
	var trust_text: String = data.ui.result.trust.format({"sign": "+" if delta >= 0 else "-", "n": absi(delta)})
	check(visible_text().contains(trust_text), "result shows actual applied trust, including the floor: " + task.id)
	check(visible_text().contains(data.ui.result.coins.format({"n": int(task[choice].coins)})), "result shows the approved coin reward: " + task.id)
	check(app.progress.coins == before_coins + int(task[choice].coins), "choice credits coins exactly once: " + task.id)
	check(app.progress.tasks[task.id].choice == choice, "choice is recorded for the task: " + task.id)
	if task.id == data.tasks[0].id:
		await press_button(data.ui.buttons.see_goal, "result offers a usable See your goal button")
		check(app.ui.screen == "goal" and visible_text().contains(data.goal.title), "result goal button opens the goal")
		app.show_screen("result")
	await press_button(data.ui.buttons.back_to_board, "result has a usable Back to the board button")
	check(app.ui.screen == "board", "result returns to the board")
	var status: String = data.ui.board.done_honest if choice == "honest" else data.ui.board.done_quick
	check(visible_text().contains(status), "board shows the completed choice: " + task.id)


func check_task_economics() -> void:
	await reset_tasks()
	var board_text := visible_text()
	check(board_text.find(data.tasks[0].title) < board_text.find(data.tasks[1].title) and board_text.find(data.tasks[1].title) < board_text.find(data.tasks[2].title) and board_text.find(data.tasks[2].title) < board_text.find(data.daily_job.title), "board lists all three tasks in approved order, then the daily job")
	check(not app.player.enabled, "task board pauses physical player input")
	await press_button(data.ui.buttons.back_to_market_map, "task board offers a real Back to the market map button")
	check(app.ui.screen == "market_map", "board back button returns to the market map")
	app.show_board()
	await frames(2)
	check(not board_text.contains(data.tasks[0].amends.title), "amends are hidden before a quick choice")
	await press_button(data.ui.buttons.take_task.format({"n": int(data.tasks[0].pay_shown)}), "first task can be opened")
	await press_button(data.ui.buttons.not_now, "task offers the approved Not now button")
	check(app.ui.screen == "board" and app.progress.tasks.is_empty(), "Not now returns without recording a choice or reward")
	for task: Dictionary in data.tasks:
		await play_task(task, "honest")
	check_wallet(75, 12, "all honest tasks finish at exactly 75 trust and 12 coins")
	check(not visible_text().contains(data.tasks[0].amends.title), "honest tasks do not offer amends")
	check(not app.progress.amend_task(data.tasks[0].id), "honest tasks cannot claim amends")
	var wallet := Vector2i(app.progress.trust, app.progress.coins)
	check(app.progress.choose_task(data.tasks[0].id, "quick").is_empty(), "a completed task rejects a second choice")
	check(Vector2i(app.progress.trust, app.progress.coins) == wallet, "rejected repeated choice leaves the wallet unchanged")
	# The blank hit button over the trust HUD is a real button, not a label.
	app.ui.show_toast("")
	await press_button("", "trust HUD has a usable goal hit target")
	check(app.ui.screen == "goal", "trust HUD opens the goal screen")
	await reset_tasks()
	for task: Dictionary in data.tasks:
		await play_task(task, "quick")
	check_wallet(0, 31, "all quick tasks finish at exactly 0 trust and 31 coins")
	for task: Dictionary in data.tasks:
		var reward: int = int(app.progress.tasks[task.id].lost_trust) + int(task.honest.trust)
		check(app.progress.amend_reward(task.id) == reward, "amends return actual loss plus honest reward: " + task.id)
		check(visible_text().to_lower().contains(data.ui.board.amend_line.format({"cost": int(task.amends.cost), "trust": reward}).to_lower()), "board shows the actual amends cost and trust: " + task.id)
		await press_button(data.ui.buttons.put_right, "quick task offers a usable Put it right button: " + task.id)
		check(app.progress.tasks[task.id].amended, "amends are recorded: " + task.id)
		check(has_visible_label(app.ui, data.ui.board.put_right_done), "board shows the approved put-right completion label")
	check_wallet(75, 0, "all quick then all three amends finish at exactly 75 trust and 0 coins")
	wallet = Vector2i(app.progress.trust, app.progress.coins)
	check(not app.progress.amend_task(data.tasks[0].id), "completed amends cannot pay a second reward")
	check(Vector2i(app.progress.trust, app.progress.coins) == wallet, "repeated amends leave the wallet unchanged")
	await reset_tasks()
	app.choose_task(data.tasks[0].id, "quick")
	app.progress.coins = 0
	app.show_board()
	await frames(2)
	var need: String = data.ui.board.need_coins.format({"n": int(data.tasks[0].amends.cost)})
	check(visible_text().contains(need), "unaffordable amends show the approved need-n-coins wording")
	wallet = Vector2i(app.progress.trust, app.progress.coins)
	app.amend_task(data.tasks[0].id)
	await frames(1)
	check(not app.progress.tasks[data.tasks[0].id].amended and Vector2i(app.progress.trust, app.progress.coins) == wallet, "unaffordable amends are blocked without charging or restoring trust")
	await reset_tasks()
	await press_button(data.ui.buttons.do_job.format({"n": int(data.daily_job.coins)}), "daily boat job has a usable Do it button")
	check_wallet(25, 2, "first daily boat job credits exactly its approved trust and coins")
	check(visible_text().contains(data.ui.board.job_done), "completed daily job shows come back tomorrow")
	check(visible_text().contains(data.daily_job.toast), "daily job shows its approved toast")
	wallet = Vector2i(app.progress.trust, app.progress.coins)
	app.do_daily_job()
	await frames(1)
	check(Vector2i(app.progress.trust, app.progress.coins) == wallet, "daily job cannot be collected twice on the same day")
	key_event(KEY_T, true)
	key_event(KEY_T, false)
	await frames(2)
	check(app.night and app.progress.daily_count == int(data.daily_job.per_day), "day-to-night preserves the used daily job")
	check(visible_text().contains(data.ui.board.job_done), "daily job stays unavailable at night")
	app.do_daily_job()
	await frames(1)
	check(Vector2i(app.progress.trust, app.progress.coins) == wallet, "nightfall cannot pay the boat job again")
	key_event(KEY_T, true)
	key_event(KEY_T, false)
	await frames(2)
	check(not app.night and app.progress.daily_count == 0, "only night-to-day resets the daily allowance")
	await press_button(data.ui.buttons.do_job.format({"n": int(data.daily_job.coins)}), "morning restores the real Do it button")
	check_wallet(30, 4, "new morning permits exactly one new daily boat reward")
	app.do_daily_job()
	await frames(1)
	check_wallet(30, 4, "second attempt in the new day still gives no duplicate reward")
	check_economy_permutations_and_bounds()
	app.show_screen("game")
	check(app.world.gate_body.collision_layer != 0, "task progress never opens the still-temporary gate")
	check(FileAccess.get_file_as_bytes("res://data/foundations.json") == runtime_baseline, "all task and daily tests preserve the approved transformed runtime bytes")


func check_economy_permutations_and_bounds() -> void:
	var orders: Array = [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
	for order: Array in orders:
		app.progress.setup(data)
		for index: int in order:
			app.progress.choose_task(data.tasks[index].id, "quick")
			check(app.progress.trust >= int(data.numbers.trust_min) and app.progress.trust <= int(data.numbers.trust_max), "quick-order trust remains in range: " + str(order))
		check(app.progress.coins == 31 and app.progress.trust == 0, "every quick task order reaches the same required wallet: " + str(order))
		var reverse_order: Array = order.duplicate()
		reverse_order.reverse()
		for index: int in reverse_order:
			check(app.progress.amend_task(data.tasks[index].id), "reverse-order amends are affordable: " + str(order) + "/" + str(index))
		check(app.progress.trust == 75 and app.progress.coins == 0, "actual-loss restoration reaches 75/0 in every quick order: " + str(order))
	app.progress.setup(data)
	app.progress.trust = int(data.numbers.trust_max) - 1
	app.progress.choose_task(data.tasks[0].id, "honest")
	check(app.progress.trust == int(data.numbers.trust_max), "honest reward clamps at the approved upper trust bound")
	app.progress.do_daily_job()
	check(app.progress.trust == int(data.numbers.trust_max), "daily reward cannot exceed the approved trust ceiling")
	app.progress.setup(data)
	app.progress.trust = 0
	app.progress.choose_task(data.tasks[0].id, "quick")
	check(app.progress.trust == 0 and app.progress.tasks[data.tasks[0].id].lost_trust == 0, "a quick choice at the floor records zero actual lost trust")
	check(app.progress.amend_reward(data.tasks[0].id) == int(data.tasks[0].honest.trust), "zero actual loss does not invent extra amends trust")
	app.progress.trust = int(data.numbers.trust_max) - 1
	check(app.progress.amend_task(data.tasks[0].id) and app.progress.trust == int(data.numbers.trust_max), "amends restoration also clamps at the upper trust bound")
	app.progress.setup(data)
	check(app.progress.choose_task("unknown-test-task", "honest").is_empty(), "unknown task IDs cannot claim a reward")
	check(app.progress.choose_task(data.tasks[0].id, "unknown-test-choice").is_empty(), "unknown choice IDs cannot claim a reward")
	check(not app.progress.amend_task("unknown-test-task"), "unknown task IDs cannot claim amends")
	check(app.progress.trust == int(data.numbers.start_trust) and app.progress.coins == int(data.numbers.start_coins) and app.progress.tasks.is_empty(), "invalid operations preserve initial state")


func check_lesson_and_gate() -> void:
	app.progress.setup(data)
	app.player.position = app.world.point("gate")
	app.player.velocity = Vector3.ZERO
	app.show_screen("market_map")
	app.progress.trust = int(data.numbers.gate_trust)
	app.use_place()
	await frames(2)
	check(not app.progress.gate_open and app.world.gate_body.collision_layer != 0, "100 trust without lesson leaves physical gate closed")
	check(visible_text().contains(data.gate.needs_lesson), "100 trust without lesson uses approved message")
	app.progress.trust = int(data.numbers.start_trust)
	app.use_place()
	check(visible_text().contains(data.gate.needs_trust.format({"trust": app.progress.trust})), "insufficient trust uses live trust number")
	app.player.position = app.world.point("scales")
	app.player.velocity = Vector3.ZERO
	app.show_screen("game")
	app.use_place()
	await frames(2)
	check(app.ui.screen == "lesson" and not app.player.enabled, "lesson opens and pauses player input")
	check(find_button(app.ui, data.lesson.answer_button.format({"n": 1})) == null, "lesson has no answer before trying a weight")
	var before := Vector2i(app.progress.trust, app.progress.coins)
	check(not app.progress.answer_weight() and Vector2i(app.progress.trust, app.progress.coins) == before, "answer before trying changes nothing")
	check(not app.progress.try_weight(-1) and not app.progress.try_weight(data.lesson.options.size()), "invalid weight indices rejected")
	for index in range(data.lesson.options.size()):
		await press_button(data.lesson.options[index], "each weight has a real try button")
		check(app.progress.tried_weight == index, "trying selects the requested weight")
		var feedback: String = data.lesson.tip_text if index == int(data.lesson.false_weight_index) else data.lesson.level_text
		check(visible_text().contains(feedback.format({"n": index + 1}).to_upper()), "scale feedback uses approved true/light wording")
		if index != int(data.lesson.false_weight_index):
			await press_button(data.lesson.answer_button.format({"n": index + 1}), "answer names the tried true weight")
			check(visible_text().contains(data.lesson.wrong), "wrong answer shows approved retry message")
			check(not app.progress.lesson_done and Vector2i(app.progress.trust, app.progress.coins) == before, "wrong answer changes no gameplay state")
	await press_button(data.lesson.options[int(data.lesson.false_weight_index)], "false weight can be tried again")
	await press_button(data.lesson.answer_button.format({"n": int(data.lesson.false_weight_index) + 1}), "false weight answer is usable")
	check(app.progress.lesson_done and app.progress.trust == before.x + int(data.lesson.trust), "correct answer awards lesson trust")
	check(app.ui.screen == "game" and visible_text().contains(data.lesson.win), "correct answer returns to world with win toast")
	check(visible_text().contains(data.ui.place_actions.scales_after_lesson), "completed lesson changes place action")
	before = Vector2i(app.progress.trust, app.progress.coins)
	app.use_place()
	check(visible_text().contains(data.other_text.scales_after_lesson), "check-scales action uses its approved line")
	check(not app.progress.answer_weight() and not app.progress.try_weight(0), "completed lesson cannot be repeated")
	check(Vector2i(app.progress.trust, app.progress.coins) == before, "lesson pays only once")
	app.show_goal()
	await frames(2)
	check(visible_text().contains(data.ui.goal.rule_done_suffix.to_upper()), "goal rule shows done after lesson")
	for gate: Array in data.goal.gates:
		check(visible_text().contains(gate[0]), "goal lists each gate in data order")
	await press_button(data.ui.buttons.map, "goal Map button works")
	check(app.ui.screen == "market_map", "goal Map returns to map")
	app.player.position = app.world.point("gate")
	app.player.velocity = Vector3.ZERO
	app.update_state()
	app.use_place()
	check(not app.progress.gate_open, "lesson alone cannot open gate below 100")
	app.progress.setup(data)
	for task: Dictionary in data.tasks:
		app.progress.choose_task(task.id, "honest")
	check(app.progress.trust == 75 and app.progress.coins == 12, "three honest tasks precede lesson at 75 trust / 12 coins")
	app.progress.try_weight(int(data.lesson.false_weight_index))
	app.progress.answer_weight()
	check(app.progress.trust == 100 and app.progress.coins == 12, "all honest plus lesson is exactly 100 trust and 12 coins")
	app.show_screen("market_map")
	app.use_place()
	await frames(60)
	check(app.progress.gate_open and app.world.gate_open and app.world.gate_body.collision_layer == 0, "both requirements open physical gate")
	check(is_equal_approx(app.world.gate_hinge.rotation.y, -PI / 2.0), "gate swings open at its hinge")
	check(app.ui.map.gate_open, "maps receive the persistent open gate state")
	app.show_screen("city_map")
	app.ui.map.city_gate_requested.emit(0)
	check(visible_text().contains(data.gate.open), "open city gate uses the approved open-gate message")
	app.show_goal()
	check(visible_text().contains(data.ui.goal.open), "goal shows first gate open")
	await press_button(data.ui.buttons.back_to_market, "goal Back to market button works")
	app.progress.trust = 0
	app.use_place()
	check(app.progress.gate_open and app.world.gate_body.collision_layer == 0, "opened gate stays open even if trust later falls")
	app.progress.setup(data)
	for task: Dictionary in data.tasks:
		app.progress.choose_task(task.id, "quick")
	for task: Dictionary in data.tasks:
		app.progress.amend_task(task.id)
	app.progress.try_weight(int(data.lesson.false_weight_index))
	app.progress.answer_weight()
	check(app.progress.trust == 100 and app.progress.coins == 0, "all quick plus amends plus lesson is 100 trust / 0 coins")


func renamed_foundations(value: Variant) -> Variant:
	# Only the five text rows belong to this line; later numeric/control rows do not.
	if value is String:
		var renamed: String = value
		for index in range(5):
			var row: Array = identity.renames_in_foundations_data[index]
			renamed = renamed.replace(row[0], row[1])
		return renamed
	if value is Array:
		var result: Array = []
		for item in value:
			result.append(renamed_foundations(item))
		return result
	if value is Dictionary:
		var result: Dictionary = {}
		for key in value:
			result[renamed_foundations(key)] = renamed_foundations(value[key])
		return result
	return value


func check_retired_content() -> void:
	# The only exemption is the historical rename list in the immutable identity.
	var retired: Array[String] = [str(identity.renames_in_foundations_data[0][0]).get_slice(" ", 0), str(identity.renames_in_foundations_data[1][0]).trim_prefix("The heart of the ").trim_suffix(".")]
	var live_identity := identity.duplicate(true)
	live_identity.erase("renames_in_foundations_data")
	check_no_retired(JSON.stringify(live_identity), retired, "identity outside its sole exempt historical list")
	check_no_retired(runtime_baseline.get_string_from_utf8(), retired, "transformed foundations")
	check_source_content("res://", retired)


func check_no_retired(value: String, retired: Array[String], context: String) -> void:
	for word in retired:
		check(not value.to_lower().replace("-", " ").contains(word.to_lower()), "retired content is absent from " + context)


func check_source_content(folder: String, retired: Array[String]) -> void:
	var directory := DirAccess.open(folder)
	check(directory != null, "source validation can open " + folder)
	if directory == null:
		return
	for filename in directory.get_files():
		if filename.get_extension() in ["gd", "tscn", "tres"]:
			check_no_retired(FileAccess.get_file_as_string(folder.path_join(filename)), retired, folder.path_join(filename))
	for child in directory.get_directories():
		if child.begins_with("."):
			continue
		check_source_content(folder.path_join(child), retired)


func tap_map(at: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = at
	app.ui.map._gui_input(event)
	await frames(2)


func check_identity_maps_and_places() -> void:
	app.progress.setup(data)
	check(app.identity == identity and app.ui.identity == identity, "runtime and UI share the complete approved identity data")
	check(app.progress.coins == 0 and app.progress.trust == 20, "line 5 preserves LOCK 1 starting coins and trust")
	check(data.keys.wait_day_night == "T", "line 5 retains the LOCK 1 T binding")
	if app.night:
		app.toggle_night()
	app.begin_game()
	await frames(2)
	check(not visible_text().contains(identity.clock.wait_button), "line 5 does not introduce the later clock wait control")
	check(not visible_text().contains(identity.clock.weekdays_from_day1[0]), "line 5 does not introduce the clock HUD")
	for id: String in identity.layout_additions:
		var addition: Dictionary = identity.layout_additions[id]
		check(data.places.has(id) and data.street_points.has(id), "runtime layout includes the new place and street point: " + id)
		check(data.streets.has([addition.street, id]) or data.streets.has([id, addition.street]), "new place joins its locked street: " + id)
		check(app.world.point(id).is_equal_approx(Vector3(addition.x, 0.0, addition.z)), "new place is at its exact locked position: " + id)
	# Drive the production routing and physical capsule in both new corridors.
	for id: String in ["inn", "masjid", "quay"]:
		var before: Vector3 = app.player.global_position
		app.walk_to_place(id)
		check(app.player.global_position.is_equal_approx(before), "new-place route never teleports: " + id)
		var arrived := false
		for index in range(Engine.physics_ticks_per_second * 60):
			await frames(1)
			if app.route.is_empty() and app.current_place == id:
				arrived = true
				break
		check(arrived, "production capsule reaches the place along the unobstructed streets: " + id)
		if not arrived:
			print("IDENTITY ROUTE DIAGNOSTIC ", id, " position=", app.player.global_position, " route=", app.route)
		if id != "quay":
			check(visible_text().contains(identity.layout_additions[id].name) and visible_text().contains(identity.layout_additions[id].line), "new-place bar uses its locked name and line: " + id)
			check(find_button(app.ui, data.ui.not_built) != null, "new-place action uses the approved not-built label: " + id)
			var wallet := Vector2i(app.progress.coins, app.progress.trust)
			await press_button(data.ui.not_built, "new-place placeholder action is a real button: " + id)
			check(app.ui.screen == "market_map" and visible_text().contains(data.ui.not_built) and Vector2i(app.progress.coins, app.progress.trust) == wallet, "new-place action stays deferred without side effects: " + id)
	app.show_screen("city_map")
	await frames(2)
	var parts: Dictionary = {"centre": Vector2(960, 547), "east": Vector2(1200, 547), "north": Vector2(960, 300), "west": Vector2(700, 547), "south": Vector2(960, 790)}
	for id: String in parts:
		await tap_map(parts[id])
		check(visible_text().contains(identity.city.parts[id].name) and visible_text().contains(identity.city.parts[id].line), "tapping city part shows its complete locked line: " + id)
		check_no_retired(visible_text(), [str(identity.renames_in_foundations_data[0][0]).get_slice(" ", 0), str(identity.renames_in_foundations_data[1][0]).trim_prefix("The heart of the ").trim_suffix(".")], "visible city text")
	await tap_map(Vector2(1248, 652))
	check(app.ui.screen == "market_map", "Your inn marker opens River Market")
	app.show_screen("city_map")
	await press_button(identity.ui.world_map, "city map has a usable World map button")
	check(app.ui.screen == "world_map", "city navigation opens world map")
	await frames(2)
	check(app.ui.map.identity.world.towns_placeholder.size() == 12, "world map receives all twelve locked placeholder towns")
	for town: Dictionary in identity.world.towns_placeholder:
		await tap_map(Vector2(town.x, town.y) * 4.8)
		check(visible_text().contains(identity.world.town_toast.format({"town": town.name})), "world town tap shows its exact locked placeholder toast: " + str(town.name))
	await tap_map(Vector2(960, 540))
	check(app.ui.screen == "city_map", "tapping the central world city opens the city map")
	await press_button(identity.ui.river_market, "city map has a usable River Market button")
	check(app.ui.screen == "market_map", "city River Market navigation works")
	app.show_screen("world_map")
	await press_button(identity.ui.city_map, "world map has a usable City map button")
	check(app.ui.screen == "city_map", "world City map navigation works")
	app.show_screen("world_map")
	await press_button(identity.ui.river_market, "world map has a usable River Market button")
	check(app.ui.screen == "market_map", "world River Market navigation works")
	app.show_screen("world_map")
	await press_button(identity.ui.title_back, "world map has a usable Title button")
	check(app.ui.screen == "title", "world Title navigation works")
	check(FileAccess.get_file_as_bytes("res://data/foundations.json") == runtime_baseline, "all identity tests preserve approved foundations bytes")
	check(FileAccess.get_file_as_bytes("res://data/identity.json") == FileAccess.get_file_as_bytes("res://../GAME/APPROVED/IDENTITY/RECORD/identity_data_V3.json"), "all identity tests preserve the immutable identity bytes")


func finish() -> void:
	print("FOUNDATIONS TESTS: ", checks - failures, "/", checks, " passed; failures=", failures)
	if app != null:
		app.queue_free()
	quit(0 if failures == 0 else 1)
