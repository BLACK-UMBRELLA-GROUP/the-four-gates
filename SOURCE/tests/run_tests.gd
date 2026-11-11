extends SceneTree
## Plain, dependency-free checks against the real scene and physics world.

const PrayerClock = preload("res://game/prayer_clock.gd")
const OpenPurse = preload("res://game/open_purse.gd")
const TaskProgress = preload("res://game/task_progress.gd")
const MarketStall = preload("res://game/market_stall.gd")

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
	var prayer_record_bytes := FileAccess.get_file_as_bytes("res://data/prayer_record.json")
	var locked_prayer_record := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/PRAYER_RECORD/RECORD/prayer_record_data_V1.json")
	check(not prayer_record_bytes.is_empty() and prayer_record_bytes == locked_prayer_record, "prayer record runtime is the byte-identical LOCK 8 V1 file")
	identity = JSON.parse_string(identity_bytes.get_string_from_utf8())
	var expected: Dictionary = renamed_foundations(JSON.parse_string(approved.get_string_from_utf8()))
	expected.goal.gates = JSON.parse_string(identity.renames_in_foundations_data[5][1])
	expected.erase("city_map")
	expected.keys.wait_prayer = expected.keys.wait_day_night
	expected.keys.erase("wait_day_night")
	expected.keys.pray = identity.clock.keys.pray
	expected.ui.buttons.wait_prayer = identity.ui.wait_prayer
	expected.ui.buttons.erase("wait_night")
	expected.ui.buttons.erase("wait_day")
	check(not runtime.is_empty() and JSON.parse_string(runtime.get_string_from_utf8()) == expected, "foundations contains exactly the approved runtime transformations")
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
	var prayer_record: Dictionary = app.ui.prayer_record
	await press_button(prayer_record.title_button, "title offers a usable Your prayers button")
	check(app.ui.screen == "all_prayers_title" and has_visible_label(app.ui, prayer_record.panel.empty), "title opens the totals with the exact empty copy before any prayer status")
	check(not has_visible_label(app.ui, prayer_record.rows.on_time), "empty totals hide the count rows")
	await press_button(prayer_record.panel.back_title, "empty totals offer a usable Title button")
	check(app.ui.screen == "title", "title totals return to the title")
	await press_button(data.ui.buttons.begin, "Begin is a real button")
	check(app.ui.screen == "arrival", "Begin opens the locked arrival")
	check(horizontal_distance(app.player.global_position, app.world.point(data.start_place)) < 0.02, "arrival starts at the quay")
	await place_at_quay()
	var spawn: Vector3 = app.world.point(data.start_place)
	check(app.ui.screen == "market_map", "market fixture opens the market map")
	check(horizontal_distance(app.player.global_position, spawn) < 0.02, "market fixture starts at the quay")
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
	check_prayer_clock()
	check_prayer_totals()
	if "--clock-only" in OS.get_cmdline_user_args():
		await check_prayer_runtime()
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
	await check_arrival_and_inn()
	await check_prayer_runtime()
	await check_idris()
	check_open_purse_rules()
	await check_open_purse_runtime()
	await check_bread_grab_runtime()
	await check_market_stall_runtime()
	await check_clothes_runtime()
	await check_talking_runtime()
	check_market_day_runtime()
	await check_feeding_runtime()
	await check_sealed_purse_runtime()
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
	if node is RichTextLabel:
		result.append(node.get_parsed_text())
	elif node is Label or node is Button:
		result.append(node.text)
	for child in node.get_children():
		collect_text(child, result)


func find_button(node: Node, label: String, skip: Node = null) -> Button:
	if node == skip:
		return null
	if node is Button and node.text == label:
		return node
	for child in node.get_children():
		var found := find_button(child, label, skip)
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
		"wait_prayer": source.keys.wait_prayer, "pray": source.keys.pray, "close": source.keys.close,
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
	await place_at_quay()
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
	await place_at_quay()


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
	check(visible_text().contains(data.ui.buttons.wait_prayer), "day map has Wait until next prayer")
	check(visible_text().contains(data.places.quay.line), "quay bar shows the approved line")
	check(visible_text().contains(data.ui.place_actions.quay), "quay bar shows Look around")
	app.clock.reset()
	app.clock.advance_to(1, 18 * 60 + 10, false)
	app.update_state()
	key_event(KEY_T, true)
	key_event(KEY_T, false)
	await frames(2)
	check(app.minute_of_day == 19 * 60 + 30 and app.night and app.world.night, "T jumps to Isha and updates world lighting")
	for lantern: OmniLight3D in app.world.lanterns:
		check(lantern.visible, "night turns each actual lantern on")
	check(visible_text().contains(identity.clock.adhan_toast.format({"prayer": "Isha"})), "waiting to Isha shows the approved adhan")
	await press_button(data.ui.buttons.wait_prayer, "night map offers a real wait button")
	check(app.day == 2 and app.minute_of_day == 4 * 60 + 45 and app.night, "waiting through midnight reaches Fajr in the dark")
	await press_button(data.ui.buttons.wait_prayer, "night wait button still works during Fajr")
	check(app.minute_of_day == 12 * 60 + 5 and not app.night and not app.world.night, "map wait button reaches Friday noon in daylight")
	for lantern: OmniLight3D in app.world.lanterns:
		check(not lantern.visible, "day turns each actual lantern off")
	check(visible_text().contains(identity.clock.adhan_toast.format({"prayer": identity.clock.friday.name})), "Friday noon announces Friday prayer")
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
	app.player.global_position = app.world.point("quay")
	app.player.velocity = Vector3.ZERO
	app.update_state()
	app.ui.show_toast("")
	app.use_place()
	check(app.current_place == "quay" and app.ui.screen == "game" and not visible_text().contains(data.ui.not_built), "Look around keeps the player at the quay without a new action")
	app.player.global_position = app.world.point("sq")
	app.player.velocity = Vector3.ZERO
	app.update_state()
	check(app.current_place.is_empty(), "outside every use radius no place is selected")
	check(app.world.gate_body.collision_layer != 0, "temporary actions never open the gate")


func press_button(label: String, description: String) -> bool:
	return await press_control(find_button(app.ui, label), description)


func press_control(button: Button, description: String) -> bool:
	check(button != null and button.is_visible_in_tree() and not button.disabled, description)
	if button == null or button.disabled or not button.is_visible_in_tree():
		return false
	button.pressed.emit()
	await frames(2)
	return true


func place_at_quay() -> void:
	# Keep the earlier route and wallet fixtures isolated from arrival rewards.
	app.player.position = app.world.point(data.start_place)
	app.player.velocity = Vector3.ZERO
	app.player.yaw = 0.0
	app.player.pitch = 0.0
	app.player.update_camera()
	app.route.clear()
	app.player.test_move_axis = Vector2.ZERO
	app.show_screen("market_map")
	await frames(3)


func reset_tasks() -> void:
	app.progress.setup(data)
	app.clock.reset()
	app.update_state()
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
	# The clock and trust HUDs have independent hit targets.
	app.ui.show_toast("")
	var trust_hit := find_button(app.ui, "", app.ui.clock_panel)
	check(trust_hit != null and trust_hit.is_visible_in_tree() and not trust_hit.disabled, "trust HUD has a usable goal hit target")
	if trust_hit != null:
		trust_hit.pressed.emit()
		await frames(2)
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
	app.clock.advance_to(1, 18 * 60 + 10, false)
	app.update_state()
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
	check(app.day == 2 and app.night and app.progress.daily_count == 0, "the new day resets the daily allowance even before daylight")
	await press_button(data.ui.buttons.do_job.format({"n": int(data.daily_job.coins)}), "the new day restores the real Do it button")
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
	check(app.progress.coins == 0 and app.progress.trust == 20, "map fixture starts with the LOCK 1 baseline wallet")
	check(data.keys.wait_prayer == "T", "T is now bound to Wait until next prayer")
	app.clock.reset()
	app.update_state()
	await place_at_quay()
	check(visible_text().contains(identity.clock.wait_button), "the market map has the clock wait control")
	check(visible_text().contains(identity.clock.weekdays_from_day1[0]), "the clock HUD shows the first weekday")
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
		if id == "inn":
			check(find_button(app.ui, identity.inn.action) != null, "the Inn now offers its approved rest action")
		if id == "masjid":
			app.clock.advance_to(1, 10 * 60, false)
			app.update_state()
			var sit: String = identity.clock.masjid_actions.none_yet
			check(find_button(app.ui, sit) != null, "the Masjid offers Sit a while between prayers")
			var wallet := Vector2i(app.progress.coins, app.progress.trust)
			await press_button(sit, "Sit a while is a real Masjid button")
			check(app.ui.screen == "idris" and app.day == 1 and app.minute_of_day == 10 * 60, "Sit a while opens immediately using the daytime clock")
			check(visible_text().contains(app.clock.hud(true).time) and visible_text().contains(str(identity.teacher.when).to_upper()), "the meeting shows the live clock and fixed After Maghrib caption together")
			check(Vector2i(app.progress.coins, app.progress.trust) == wallet, "the Masjid entry leaves coins and trust intact")
			await press_button(identity.teacher.buttons.leave, "the daytime meeting has a usable Leave button")
			check(app.ui.screen == "market_map" and app.current_place == "masjid", "Leave returns to the Masjid map")
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


func check_arrival_and_inn() -> void:
	var arrival: Dictionary = identity.arrival
	await press_button(data.ui.buttons.begin, "title starts a new arrival after a market session")
	check_arrival_start()
	check(app.progress.tasks.is_empty() and not app.progress.lesson_done and not app.progress.gate_open, "Begin clears the previous market progress")
	check(not app.world.gate_open and app.world.gate_body.collision_layer != 0, "Begin closes the previous session's physical gate")
	for key: Key in [KEY_M, KEY_G, KEY_T, KEY_P, KEY_E, KEY_ESCAPE]:
		key_event(key, true)
		key_event(key, false)
	await frames(2)
	check(app.ui.screen == "arrival" and app.arrival_beat == 0 and app.minute_of_day == 390 and not app.night, "market shortcuts cannot leave or change the opening arrival beat")
	await play_arrival(1, 0)
	await press_button(arrival.buttons[2], "Arrive again restarts the arrival from its end screen")
	check_arrival_start()
	await play_arrival(0, 1)
	await walk_from_arrival(198)
	await check_inn_rest()
	await check_arrival_lesson(false)

	app.show_screen("title")
	await press_button(data.ui.buttons.begin, "Begin can start a new arrival after the lesson")
	check_arrival_start()
	await play_arrival(1, 0)
	await walk_from_arrival(118)
	await check_arrival_lesson(true)


func check_arrival_start() -> void:
	check(app.ui.screen == "arrival" and app.arrival_beat == 0 and app.arrival_reply.is_empty(), "arrival starts at the first beat before its reply")
	check(app.progress.coins == 0 and app.arrival_fair == null and app.paid_nights == 0, "arrival resets the wallet, changer and prepaid nights")
	check_wallet(int(data.numbers.start_trust), 0, "arrival shows the initial wallet and trust")
	check(app.day == 1 and app.minute_of_day == 390, "arrival resets to day 1 at 06:30")
	check(not app.player.enabled, "arrival pauses the player controller")


func play_arrival(changer: int, quay_choice: int) -> void:
	var arrival: Dictionary = identity.arrival
	var fair := changer == 0
	var changed_coins := 200 if fair else 120
	var end_coins := 198 if fair else 118
	var selections := [quay_choice, changer, 0, 0]
	for index in range(arrival.beats.size()):
		var beat: Dictionary = arrival.beats[index]
		var choice: Dictionary = beat.choices[selections[index]]
		check(app.ui.screen == "arrival" and app.arrival_beat == index, "arrival opens beat %d in order" % index)
		check(visible_text().contains(beat.text), "beat %d displays the complete locked text" % index)
		for option: Dictionary in beat.choices:
			var button := find_button(app.ui, option.label)
			check(button != null and button.is_visible_in_tree() and not button.disabled, "arrival choice is visible and usable: " + str(option.label))
		if index == 3:
			check(app.minute_of_day == 390 and visible_text().contains("06:30") and app.world.night, "the sunset backdrop appears before Follow them jumps the clock")
		await press_button(choice.label, "the player can select the locked arrival choice")
		check(visible_text().contains(choice.reply), "the choice displays its complete locked reply")
		check(app.arrival_beat == index, "the reply stays on its beat until Continue")
		match index:
			0:
				check(app.progress.coins == 0 and app.arrival_fair == null, "the quay choice grants no coins and sets no changer")
			1:
				check(app.progress.coins == changed_coins and app.arrival_fair == fair, "changer sets %d coins and records its fairness" % changed_coins)
				check_wallet(int(data.numbers.start_trust), changed_coins, "changer reply shows the new balance")
			2:
				check(app.progress.coins == end_coins and app.paid_nights == 1, "inn choice leaves %d coins and credits one night" % end_coins)
			3:
				check(app.day == 1 and app.minute_of_day == 1095 and visible_text().contains("18:15"), "Follow them jumps the clock HUD to 18:15 on day 1")
		await press_button(arrival.continue, "each arrival reply offers Continue")
	check(app.arrival_beat == arrival.beats.size(), "continuing from the sunset reply opens the ending")
	var ending: String = arrival.end_fair if fair else arrival.end_cheated
	check(visible_text().contains(ending), "arrival ending matches the chosen changer")
	var ending_coins: String = str(arrival.coins_line).format({"n": end_coins}).to_upper()
	check(has_visible_label(app.ui, ending_coins), "arrival ending shows the exact balance")
	for label: String in arrival.buttons:
		var button := find_button(app.ui, label)
		check(button != null and button.is_visible_in_tree() and not button.disabled, "arrival ending shows its usable button: " + label)


func walk_from_arrival(expected_coins: int) -> void:
	await press_button(identity.arrival.buttons[1], "Walk River Market opens the playable map")
	check(app.ui.screen == "market_map" and app.player.enabled and app.current_place == "inn", "Walk River Market begins the market session at the Inn")
	check(horizontal_distance(app.player.global_position, app.world.point("inn")) < 0.02, "the real player spawns at the Inn")
	check_wallet(int(data.numbers.start_trust), expected_coins, "walking retains the arrival balance")
	check(app.paid_nights == 1 and app.minute_of_day == 1095, "walking carries the paid night and arrival time into the market")
	check(visible_text().contains(identity.clock.wait_button) and visible_text().contains("18:15"), "market exposes the clock HUD and wait control at the arrival time")
	check(not app.night and not app.world.night, "the playable market is in daylight at 18:15")


func check_inn_rest() -> void:
	var inn: Dictionary = identity.inn
	var cost: int = identity.arrival.inn_night
	var balance: int = app.progress.coins
	app.progress.daily_count = int(data.daily_job.per_day)
	await press_button(inn.action, "Inn rest action is a real market-map button")
	check(app.progress.coins == balance and app.paid_nights == 0, "the prepaid night is used before charging an affordable balance")
	check(visible_text().contains(inn.paid.format({"n": 0})), "prepaid rest shows the locked room toast")
	check(app.day == 2 and app.minute_of_day == 280 and app.night and app.world.night, "prepaid rest wakes before dawn at 04:40 on day 2")
	check(app.progress.daily_count == 0, "rest renews the daily boat job on the next day")
	key_event(KEY_E, true)
	key_event(KEY_E, false)
	await frames(2)
	check(app.progress.coins == balance - cost and app.paid_nights == 0, "without a credit E at the Inn charges exactly one night")
	check(visible_text().contains(inn.coins.format({"n": cost})), "paid rest shows the locked charge toast")
	check(app.day == 3 and app.minute_of_day == 280, "paid rest wakes at 04:40 on day 3")
	app.progress.coins = 0
	await frames(2)
	await press_button(inn.action, "the Inn still offers rest with an empty wallet")
	check(app.progress.coins == 0 and app.paid_nights == 0, "stable rest keeps an empty wallet at zero")
	check(visible_text().contains(inn.broom), "stable rest shows the locked broom toast")
	check(app.day == 4 and app.minute_of_day == 280, "stable rest wakes at 04:40 on day 4")
	check(app.ui.screen == "market_map" and app.current_place == "inn", "rest keeps the player at the Inn")


func check_arrival_lesson(cheated: bool) -> void:
	app.player.position = app.world.point("scales")
	app.player.velocity = Vector3.ZERO
	app.show_screen("market_map")
	await press_button(data.ui.place_actions.scales, "scales place action opens the lesson after arrival")
	var before := Vector2i(app.progress.trust, app.progress.coins)
	var false_index: int = data.lesson.false_weight_index
	var true_index: int = (false_index + 1) % data.lesson.options.size()
	await press_button(data.lesson.options[true_index], "a true weight can be tried after arrival")
	await press_button(data.lesson.answer_button.format({"n": true_index + 1}), "a true weight can be submitted after arrival")
	check(visible_text().contains(data.lesson.wrong) and not visible_text().contains(identity.arrival.cheat_found_after_lesson), "a wrong answer never reveals the cheat")
	check(app.ui.screen == "lesson" and not app.progress.lesson_done and Vector2i(app.progress.trust, app.progress.coins) == before, "a wrong answer changes neither lesson completion nor wallet")
	await press_button(data.lesson.options[false_index], "the light weight can be tried after arrival")
	await press_button(data.lesson.answer_button.format({"n": false_index + 1}), "the light weight can be submitted after arrival")
	var expected: String = identity.arrival.cheat_found_after_lesson if cheated else data.lesson.win
	var other: String = data.lesson.win if cheated else identity.arrival.cheat_found_after_lesson
	check(visible_text().contains(expected) and not visible_text().contains(other), "only the smiling changer replaces the lesson's normal win toast")
	check(app.ui.screen == "game" and app.current_place == "scales", "passing the lesson returns to the street at the scales")
	check(app.progress.lesson_done and app.progress.trust == before.x + int(data.lesson.trust) and app.progress.coins == before.y, "the lesson still awards only its locked trust")
	await press_button(data.ui.place_actions.scales_after_lesson, "returning to the completed scales uses the check action")
	check(visible_text().contains(data.other_text.scales_after_lesson) and not visible_text().contains(identity.arrival.cheat_found_after_lesson), "checking the scales never repeats the cheat toast")


func check_prayer_clock() -> void:
	var source: Dictionary = identity.clock
	var clock := PrayerClock.new(source)
	check(clock.day == 1 and clock.minute_of_day == 390 and not clock.night, "clock starts on Thursday at 06:30 in daylight")
	check(clock.hud().time == "Thursday · 06:30", "HUD uses the locked weekday and time format")
	check(clock.record().kicker == "Thursday · day 1", "record identifies the current day")
	check(clock.record().rows[0].text == "04:45 · not counted" and clock.make_up_label().is_empty(), "day 1 Fajr ended before play and cannot be made up")
	clock.advance_to(1, 600)
	check(clock.hud().prayer == "Dhuhr in 2 h 5 min", "long next-prayer countdown matches the master")
	clock.advance_to(1, 720)
	check(clock.hud().prayer == "Dhuhr in 5 min", "short countdown uses minutes alone")
	clock.reset()
	clock.advance_seconds(0.75)
	clock.advance_seconds(1.25)
	check(clock.minute_of_day == 391, "the clock retains sub-minute progress between frames")
	clock.advance_seconds(48 * 60)
	check(clock.day == 2 and clock.minute_of_day == 391, "48 real minutes advance exactly one game day")
	clock.advance_to(2, 18 * 60 + 39)
	check(not clock.night, "18:39 is daylight")
	clock.advance_to(2, 18 * 60 + 40)
	check(clock.night, "night begins at 18:40")
	clock.advance_to(3, 5 * 60 + 29)
	check(clock.night, "05:29 is night")
	clock.advance_to(3, 5 * 60 + 30)
	check(not clock.night, "daylight returns at 05:30")

	var schedule := [
		["Fajr", 285, 365, 20],
		["Dhuhr", 725, 930, 15],
		["Asr", 930, 1090, 15],
		["Maghrib", 1090, 1170, 5],
		["Isha", 1170, 1440 + 285, 15],
	]
	check(source.prayers.size() == schedule.size(), "the clock uses the five locked prayer slots")
	for index in schedule.size():
		var name: String = schedule[index][0]
		var begins: int = schedule[index][1]
		var ends: int = schedule[index][2]
		var iqamah: int = schedule[index][3]
		var adhan: Array[String] = []
		clock = PrayerClock.new(source)
		clock.adhan_started.connect(func(message: String): adhan.append(message))
		clock.advance_to(3, begins - 1, false)
		clock.wait_until_next_prayer()
		check(clock.day == 3 and clock.minute_of_day == begins, "Wait reaches the exact adhan minute: " + name)
		check(adhan == [source.adhan_toast.format({"prayer": name})], "exactly one approved adhan is emitted at the prayer start: " + name)
		var solo: String = source.pray_here.format({"prayer": name})
		check(clock.prayer_label(true) == source.pray_congregation and clock.prayer_label(false) == solo, "only the Masjid offers congregation at the adhan: " + name)
		clock.advance_to(3, begins + iqamah + 5)
		check(clock.prayer_label(true) == source.pray_congregation, "congregation includes the fifth minute after iqamah: " + name)
		clock.advance_to(3, begins + iqamah + 6)
		check(clock.prayer_label(true) == solo, "after congregation, the Masjid offers prayer alone: " + name)
		clock.advance_to(3, ends - 1)
		check(clock.prayer_label(false) == solo, "the final minute before the prayer ends is playable: " + name)
		clock.advance_to(3, ends)
		check(clock.prayer_label(false) != solo, "the prayer cannot be started at its end: " + name)
		if index < schedule.size() - 1:
			check(clock.record().rows[index].status == "missed", "a skipped slot is missed at its end: " + name)

	clock = PrayerClock.new(source)
	clock.advance_to(2, 6 * 60 + 5)
	check(clock.record().rows[0].status == "missed", "day 2 Fajr is missed as soon as its window ends")
	check(clock.make_up_label() == "Make up Fajr", "Friday Fajr is offered for make-up")
	check(clock.make_up() == "You made up Fajr." and clock.minute_of_day == 6 * 60 + 15, "make-up uses the locked toast and takes ten game minutes")
	check(clock.record().rows[0].text == "04:45 · made up", "making up Fajr updates Friday's private record")
	check(clock.make_up_label() != "Make up Fajr", "the completed Fajr make-up cannot repeat")
	clock.advance_to(2, 12 * 60 + 40)
	check(clock.hud(true).prayer.begins_with("Friday prayer now") and clock.hud(false).prayer.begins_with("Dhuhr now"), "Friday congregational time uses the correct HUD prayer for the place")
	check(clock.prayer_label(true) == source.pray_friday and clock.prayer_label(false) == source.pray_here_friday, "Friday prayer is only offered in congregation at the Masjid")
	check(clock.pray(true) == "You prayed Friday prayer in congregation.", "praying Friday in the Masjid uses the locked congregation toast")
	check(clock.minute_of_day == 12 * 60 + 50 and clock.record().rows[1].status == "jamaah", "Friday congregation takes ten minutes and updates its record")
	check(clock.hud().prayer == "Friday prayer · prayed in congregation" and clock.prayer_label(true).is_empty(), "completed prayer shows the done line and cannot repeat")

	clock.reset()
	clock.advance_to(2, 12 * 60 + 8)
	check(clock.pray(false) == source.toast_alone_friday, "Friday prayer away from the Masjid is Dhuhr")
	check(clock.record().rows[1].text == "12:05 · missed Friday prayer · prayed Dhuhr", "praying Friday Dhuhr alone shows the locked distinct status")
	clock.reset()
	clock.advance_to(2, 12 * 60 + 41)
	check(clock.prayer_label(true) == source.pray_here_friday, "the Masjid also offers Dhuhr once the Friday congregation window closes")
	clock.reset()
	clock.advance_to(1, 19 * 60 + 30)
	clock.wait_until_next_prayer()
	check(clock.day == 2 and clock.minute_of_day == 285, "Wait at the start of Isha jumps strictly forward to Friday Fajr")
	clock.make_up()
	check(clock.make_up_label() == "Make up Asr", "making up a prior-day prayer advances to the next outstanding slot")


func check_prayer_totals() -> void:
	var clock := PrayerClock.new(identity.clock)
	var empty := {
		"on_time": 0, "jamaah": 0, "alone_masjid": 0, "alone_elsewhere": 0,
		"friday": 0, "dhuhr_fri": 0, "madeup": 0, "missed": 0,
	}
	check(clock.totals() == empty, "totals exclude day 1 Fajr and upcoming prayers")
	clock.advance_to(1, 12 * 60 + 5, false)
	check(clock.totals() == empty, "a current prayer has no count until it is prayed or missed")
	clock.pray(true)
	clock.advance_to(1, 15 * 60 + 51, false)
	clock.pray(true)
	clock.advance_to(1, 18 * 60 + 10, false)
	clock.pray(false)
	check(clock.totals() == {
		"on_time": 3, "jamaah": 1, "alone_masjid": 1, "alone_elsewhere": 1,
		"friday": 0, "dhuhr_fri": 0, "madeup": 0, "missed": 0,
	}, "on-time totals distinguish congregation and both places of solo prayer")
	clock.advance_to(2, 6 * 60 + 5, false)
	check(clock.totals().missed == 2, "totals include expired prayers from today and the previous day")
	clock.make_up()
	var counts := clock.totals()
	check(counts.madeup == 1 and counts.missed == 1 and counts.on_time == 3, "make-up moves exactly one prayer from missed without increasing the on-time count")
	clock.advance_to(2, 12 * 60 + 5, false)
	clock.pray(true)
	var after_friday := clock.totals()
	check(after_friday.on_time == 4 and after_friday.jamaah == 2 and after_friday.friday == 1, "Friday congregation contributes to Friday, congregation, and on-time totals")
	clock.pray(true)
	check(clock.totals() == after_friday, "a repeat attempt leaves the prayer totals unchanged")
	clock.skip_to(9, 12 * 60 + 41)
	check(clock.totals() == after_friday, "totals exclude skipped windows and retain older records across weeks")
	clock.pray(true)
	counts = clock.totals()
	check(counts.on_time == 5 and counts.alone_masjid == 2 and counts.dhuhr_fri == 1, "Friday Dhuhr at the masjid counts as on-time solo prayer and Friday Dhuhr")
	clock.skip_to(16, 12 * 60 + 5)
	clock.pray(false)
	check(clock.totals() == {
		"on_time": 6, "jamaah": 2, "alone_masjid": 2, "alone_elsewhere": 2,
		"friday": 1, "dhuhr_fri": 2, "madeup": 1, "missed": 1,
	}, "Friday Dhuhr elsewhere counts in its place and Friday rows alongside prior prayers")
	clock.reset()
	check(clock.totals() == empty, "reset clears all prayer totals")
	clock.advance_to(1, 15 * 60 + 51, false)
	clock.pray(false)
	counts = clock.totals()
	check(counts.alone_masjid == 0 and counts.alone_elsewhere == 1, "reset clears the location of a prayer repeated in a new game")


func check_prayer_runtime() -> void:
	var source: Dictionary = identity.clock
	app.clock.reset()
	await place_at_quay()
	var clock_hit: Button = app.ui.clock_panel.get_child(-1)
	check(clock_hit != null and clock_hit.is_visible_in_tree() and not clock_hit.disabled, "HUD has a usable clock hit target")
	if clock_hit != null:
		clock_hit.pressed.emit()
		await frames(2)
	check(app.ui.screen == "prayer_record" and visible_text().contains(source.record.title), "clock opens the private prayer record")
	check(visible_text().contains("04:45 · not counted") and visible_text().to_lower().contains(str(source.record.note).to_lower()), "record shows the not-counted Fajr and exact privacy note")
	await press_button(source.record.back, "record offers a usable Back to the market button")
	check(app.ui.screen == "market_map", "record returns to the market map")

	app.clock.advance_to(2, 6 * 60 + 5, false)
	app.update_state()
	var wallet := Vector2i(app.progress.coins, app.progress.trust)
	await press_button(source.make_up.format({"prayer": "Fajr"}), "missed Friday Fajr has a real Make up Fajr button")
	check(app.clock.record().rows[0].status == "madeup" and visible_text().contains(source.toast_madeup.format({"prayer": "Fajr"})), "make-up button updates the record and shows its exact toast")
	check(Vector2i(app.progress.coins, app.progress.trust) == wallet, "making up a prayer leaves coins and trust untouched")
	app.clock.advance_to(2, 12 * 60 + 8, false)
	app.update_state()
	check(visible_text().contains(source.pray_here_friday), "away from the Masjid the market offers the locked Friday Dhuhr action")
	key_event(KEY_P, true)
	key_event(KEY_P, false)
	await frames(2)
	check(app.clock.record().rows[1].status == "dhuhr_fri" and visible_text().contains(source.toast_alone_friday), "P prays Dhuhr away from the Masjid on Friday")
	var counts: Dictionary = app.clock.totals()
	check(counts.alone_elsewhere == 1 and counts.dhuhr_fri == 1, "runtime prayer records Friday Dhuhr away from the masjid in both totals")
	check(Vector2i(app.progress.coins, app.progress.trust) == wallet, "praying alone leaves coins and trust untouched")
	app.player.position = app.world.point("masjid")
	app.clock.advance_to(2, 15 * 60 + 31, false)
	app.update_state()
	await press_button(source.pray_congregation, "the Masjid offers a real congregation button")
	check(app.clock.record().rows[2].status == "jamaah" and visible_text().contains(source.toast_congregation.format({"prayer": "Asr"})), "congregation button records Asr with the exact toast")
	counts = app.clock.totals()
	check(counts.jamaah == 1 and counts.friday == 0, "Asr congregation on a Friday is not counted as Friday prayer")
	check(Vector2i(app.progress.coins, app.progress.trust) == wallet, "praying in congregation leaves coins and trust untouched")
	var prayer_record: Dictionary = app.ui.prayer_record
	await press_control(app.ui.clock_panel.get_child(-1), "clock remains usable after prayer")
	await press_button(prayer_record.record_button, "today’s record offers a usable All your prayers button")
	check(app.ui.screen == "all_prayers" and has_visible_label(app.ui, prayer_record.panel.title), "today’s record opens the populated totals")
	var panel_text := visible_text()
	var previous := -1
	for row: String in ["on_time", "jamaah", "alone_masjid", "alone_elsewhere", "friday", "dhuhr_fri", "madeup", "missed"]:
		var at := panel_text.find(prayer_record.rows[row])
		check(at > previous, "totals show the locked row in order: " + row)
		previous = at
	await press_button(prayer_record.panel.today, "market totals offer a usable Today’s prayers button")
	check(app.ui.screen == "prayer_record", "market totals return to today’s record")
	await press_button(prayer_record.record_button, "today’s record can reopen the totals")
	await press_button(prayer_record.panel.back_market, "market totals offer a usable Back to the market button")
	check(app.ui.screen == "market_map", "market totals return to the originating market view")
	check(Vector2i(app.progress.coins, app.progress.trust) == wallet, "viewing prayer totals leaves coins and trust untouched")


func check_idris_count(expected: int) -> void:
	var teacher: Dictionary = identity.teacher
	var kicker: String = teacher.kicker.format({"when": teacher.when, "n": expected})
	check(visible_text().to_lower().contains(kicker.to_lower()), "meeting kicker shows %d known words" % expected)
	check(app.known_words.size() == expected, "the word store contains %d known words" % expected)


func check_idris() -> void:
	var teacher: Dictionary = identity.teacher
	var words: Dictionary = identity.language.words
	var sit: String = identity.clock.masjid_actions.none_yet
	var look: String = identity.clock.masjid_actions.after_meeting
	var arrival: Dictionary = identity.arrival
	app.show_screen("title")
	await press_button(data.ui.buttons.begin, "Begin starts a clean session for the Idris meeting")
	for _beat: Dictionary in arrival.beats:
		app.choose_arrival(0)
		app.continue_arrival()
	var arrival_minute: int = arrival.beats.back().choices[0].effect.time
	var wallet := Vector2i(app.progress.coins, app.progress.trust)
	var paid_nights: int = app.paid_nights
	await press_button(arrival.buttons[0], "the end of Arrival has a usable Meet the old man button")
	check(app.ui.screen == "idris" and app.current_place == "masjid" and app.day == 1 and app.minute_of_day == arrival_minute, "Arrival opens the meeting at the Masjid at its locked time")
	check(Vector2i(app.progress.coins, app.progress.trust) == wallet and app.paid_nights == paid_nights, "meeting retains the Arrival wallet, trust and prepaid night")
	check(not app.player.enabled and visible_text().contains(teacher.title_before), "the first meeting shows the old-man title and pauses movement")
	check_idris_count(0)

	var first: Dictionary = teacher.beats[0]
	var first_word: Dictionary = words[first.choices[0].learns]
	var decline: Dictionary = first.choices[1]
	await press_button(decline.label, "the first beat offers the choice without a taught word")
	check(visible_text().contains(decline.reply) and visible_text().contains(first_word.ar) and not visible_text().contains(first_word.en), "the non-teaching reply leaves the word unknown")
	check_idris_count(0)
	key_event(KEY_ESCAPE, true)
	key_event(KEY_ESCAPE, false)
	await frames(2)
	check(app.ui.screen == "market_map" and app.current_place == "masjid" and not app.idris_met, "Escape leaves an unfinished meeting at the Masjid")
	app.clock.reset()
	app.clock.advance_to(1, 10 * 60, false)
	app.update_state()
	await press_button(sit, "an unfinished meeting can be opened again at the Masjid")

	var learned := 0
	for index in range(teacher.beats.size()):
		var choice: Dictionary = teacher.beats[index].choices[0]
		check(app.ui.screen == "idris" and app.idris_beat == index, "Idris opens beat %d in order" % (index + 1))
		check_idris_count(learned)
		await press_button(teacher.buttons.leave, "the player can leave beat %d" % (index + 1))
		check(app.ui.screen == "market_map" and app.current_place == "masjid" and not app.idris_met, "leaving beat %d returns to the Masjid before completion" % (index + 1))
		await press_button(sit, "Sit a while stays available before completion")
		check_idris_count(learned)
		for _previous in range(index):
			app.choose_idris(0)
			app.continue_idris()
		var word: Dictionary = words.get(choice.learns, {}) if choice.learns != null else {}
		if not word.is_empty():
			check(visible_text().contains(word.ar) and not visible_text().contains(word.en), "the town word stays unknown until its choice is picked: " + str(word.ar))
		await press_button(choice.label, "the player can pick the locked choice")
		check(visible_text().contains(choice.reply), "the selected choice shows the locked reply")
		if not word.is_empty():
			learned += 1
			var known_form := "%s (%s)" % [word.en, word.ar]
			var notice: String = teacher.new_word.format(word)
			check(visible_text().to_lower().contains(known_form.to_lower()), "the chosen word immediately shows English with the town word in brackets")
			check(visible_text().to_lower().contains(notice.to_lower()), "the reply shows the approved New word notice")
		check_idris_count(learned)
		await press_button(teacher.buttons.continue, "the player can continue from the reply")
	check(app.idris_met and visible_text().contains(teacher.name) and visible_text().contains(teacher.end), "completing the last reply reveals Idris and his invitation")
	var ending_count: String = teacher.words_you_know.format({"n": learned})
	check(has_visible_label(app.ui, ending_count.to_upper()), "the ending displays the words-you-know total")
	check(learned == words.size(), "learning every word reaches the full locked vocabulary")

	await press_button(teacher.buttons.again, "the ending offers a usable Meet him again button")
	for beat: Dictionary in teacher.beats:
		check_idris_count(learned)
		var choice: Dictionary = beat.choices[0]
		if choice.learns != null:
			var word: Dictionary = words[choice.learns]
			var known_form := "%s (%s)" % [word.en, word.ar]
			check(visible_text().to_lower().contains(known_form.to_lower()), "replay retains the learned form for " + str(word.ar))
		await press_button(choice.label, "a replay choice is usable")
		if choice.learns != null:
			var notice: String = teacher.new_word.format(words[choice.learns])
			check(not visible_text().to_lower().contains(notice.to_lower()), "repeating a learned choice does not announce a new word")
		await press_button(teacher.buttons.continue, "the replay can continue from its reply")
	check_idris_count(learned)
	await press_button(teacher.buttons.back, "the ending offers a usable Back to the market button")
	check(app.ui.screen == "market_map" and app.current_place == "masjid", "Back to the market returns to the Masjid point")
	check(find_button(app.ui, look) != null and find_button(app.ui, sit) == null, "Look inside replaces Sit a while after completion")
	check(Vector2i(app.progress.coins, app.progress.trust) == wallet and app.paid_nights == paid_nights, "the full meeting and replay leave wallet, trust and prepaid night intact")
	app.show_screen("title")
	await press_button(data.ui.buttons.begin, "Begin starts another session after meeting Idris")
	check(app.known_words.is_empty() and not app.idris_met, "a new game clears the word store and meeting completion")


func check_open_purse_rules() -> void:
	var chapter: Dictionary = app.chapter
	var runtime := FileAccess.get_file_as_bytes("res://data/chapter1.json")
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/CHAPTER_1/RECORD/chapter1_data_V2.json")
	check(not runtime.is_empty() and runtime == approved, "chapter 1 runtime is the byte-identical LOCK 3 V2 file")
	var purse := OpenPurse.new()
	var progress := TaskProgress.new()
	var clock := PrayerClock.new(identity.clock)
	progress.setup(data)
	progress.coins = 100
	purse.setup(chapter, progress, clock)
	check(purse.visible_people().size() == 3 and not purse.give("widow", false), "Umm Salim cannot receive a gift before Salma")
	check(not purse.give("fire", true) and progress.coins == 100, "secret Tariq gift is blocked before reading")
	purse.salma_asked = true
	check(purse.visible_people().size() == 4, "Salma adds Umm Salim to the list")
	purse.page_read = true
	progress.coins = 5
	check(not purse.give("fire", false) and not purse.give("fire", true) and progress.coins == 5, "unaffordable Tariq gifts are blocked in both modes")
	progress.coins = int(chapter.purse.people[2].cost)
	progress.trust = int(data.numbers.trust_max) - 1
	check(purse.give("fire", false) and progress.coins == 0 and progress.trust == int(data.numbers.trust_max), "an exact-price public gift clamps trust at the existing maximum")
	check(not purse.give("fire", true) and not purse.give("fire", false), "a given row rejects repeated gifts in both modes")

	var options := ["", "public", "secret"]
	for father: String in options:
		for boy: String in options:
			for fire: String in options:
				for widow: String in options:
					check_gift_combination(purse, progress, clock, {"father": father, "boy": boy, "fire": fire, "widow": widow})

	purse.reset()
	progress.setup(data)
	clock.reset()
	progress.coins = 100
	progress.choose_task("scales_help", "quick")
	progress.choose_task("purse", "quick")
	progress.amend_task("purse")
	progress.choose_task("spice", "honest")
	progress.do_daily_job()
	progress.morning()
	progress.try_weight(int(data.lesson.false_weight_index))
	progress.answer_weight()
	clock.advance_to(1, 12 * 60 + 5, false)
	clock.pray(true)
	clock.advance_to(1, 18 * 60 + 10, false)
	purse.salma_asked = true
	purse.give("fire", false)
	purse.give("widow", false)
	var rep: Dictionary = chapter.rep
	var expected: Array = [
		[rep.task_honest, data.tasks[0].place, 1],
		[rep.task_amended, data.tasks[1].place, 0],
		[rep.task_quick, data.tasks[2].place, -1],
		rep.boat, rep.learned, rep.masjid, rep.gives, rep.fooled, rep.widow_public,
	]
	check(purse.reputation_lines() == expected, "reputation preserves approved task, boat, lesson, congregation and public-gift order across days")
	var wallet := Vector2i(progress.coins, progress.trust)
	check(purse.end_day() and clock.day == 2 and clock.minute_of_day == int(chapter.numbers.next_morning_minute), "End the day jumps exactly to next day 07:00")
	check(clock.record().rows[0].status == "not_counted", "Fajr ending in the jump is not counted")
	check(Vector2i(progress.coins, progress.trust) == wallet and purse.reputation_lines() == expected, "End the day preserves wallet and reputation, including a completed congregation")
	check(clock.make_up_label() == identity.clock.make_up.format({"prayer": "Asr"}), "a prayer already missed at the start of the jump remains eligible for make-up")
	clock.make_up()
	check(clock.make_up_label().is_empty(), "Maghrib, Isha and Fajr ending during the jump cannot be made up")
	check(not purse.end_day() and not purse.give("boy", false) and clock.day == 2, "a finished purse rejects more gifts and a repeated jump")
	purse.reset()
	progress.setup(data)
	clock.reset()
	check(purse.reputation_lines().is_empty(), "new game clears all prior reputation sources")
	clock.advance_to(1, 12 * 60 + 5, false)
	clock.pray(false)
	check(purse.reputation_lines().is_empty(), "praying alone does not create the congregation reputation line")


func check_gift_combination(purse: OpenPurse, progress: TaskProgress, clock: PrayerClock, gifts: Dictionary) -> void:
	purse.reset()
	progress.setup(data)
	clock.reset()
	purse.salma_asked = true
	purse.page_read = true
	var chapter: Dictionary = app.chapter
	var expected_coins := 100
	var public_count := 0
	var secret_count := 0
	var accepted := true
	progress.coins = expected_coins
	for person: Dictionary in chapter.purse.people:
		var mode: String = gifts[person.id]
		if mode.is_empty():
			continue
		accepted = purse.give(person.id, mode == "secret") and accepted
		expected_coins -= int(person.cost)
		if mode == "public":
			public_count += 1
		else:
			secret_count += 1
	var description := str(gifts.values())
	var expected_trust := int(data.numbers.start_trust) + public_count * int(chapter.numbers.gift_trust)
	check(accepted and progress.coins == expected_coins and progress.trust == expected_trust, "gift combinations charge only locked costs and reward only public gifts: " + description)
	check(purse.has_secret_gift() == (secret_count > 0), "secret note eligibility follows the actual gifts: " + description)

	purse.end_day()
	var morning: Dictionary = chapter.purse.morning
	var expected_morning: Array = []
	if public_count > 0:
		expected_morning.append(str(morning.crowd).format({"n": 4 + 4 * public_count}))
	else:
		expected_morning.append(morning.quiet if secret_count > 0 else morning.none)
	if gifts.father != "":
		expected_morning.append(morning.father_public if gifts.father == "public" else morning.father_secret)
	if gifts.boy != "":
		expected_morning.append(morning.boy)
	if gifts.fire == "public":
		expected_morning.append(morning.fire)
	if gifts.widow != "":
		expected_morning.append(morning.widow_public if gifts.widow == "public" else morning.widow_secret)
	check(purse.morning_lines() == expected_morning, "morning text stays in approved order, with public-only Tariq: " + description)

	var rep: Dictionary = chapter.rep
	var expected_rep: Array = []
	if public_count > 0:
		expected_rep.append(rep.gives)
	if gifts.fire == "public":
		expected_rep.append(rep.fooled)
	if gifts.widow == "public":
		expected_rep.append(rep.widow_public)
	if public_count + secret_count == 0:
		expected_rep.append(rep.shut)
	check(purse.reputation_lines() == expected_rep, "gift reputation stays in approved order, with public-only Tariq: " + description)


func check_open_purse_runtime() -> void:
	var chapter: Dictionary = app.chapter
	var purse: Dictionary = chapter.purse
	var page: Dictionary = chapter.page
	var rep: Dictionary = chapter.rep
	var take_page: String = str(purse.take_page).format({"teacher": chapter.teacher})
	for _beat: Dictionary in identity.arrival.beats:
		app.choose_arrival(0)
		app.continue_arrival()
	await press_button(identity.arrival.buttons[1], "walk from Arrival into the market")
	app.clock.skip_to(3, 10 * 60)
	app.update_state()
	check(app.current_place == "inn", "arrival places the player at the inn")
	await press_button(purse.morning.to_rep, "the market map opens What people say")
	check(app.ui.screen == "reputation" and visible_text().contains(rep.empty), "untouched reputation opens with the locked empty copy")
	await press_button(rep.to_map, "the reputation panel returns to the map")
	await press_button(chapter.places.inn, "the inn bar opens the waiting people")
	check(app.ui.screen == "purse" and visible_text().to_lower().contains(str(purse.only_public).to_lower()), "the first door list explains that gifts are public")
	check(not visible_text().contains(purse.people[3].name) and find_button(app.ui, purse.give_secret) == null, "before Salma and the page, neither Umm Salim nor secret buttons appear")
	await press_button(purse.not_now, "Not now returns to the market map")
	await press_button(chapter.places.inn, "Not now leaves the inn action available")
	await press_button(purse.ask_baker, "the door list opens Salma")
	check(app.ui.screen == "purse_salma" and visible_text().contains(purse.baker.lines[2]), "Salma shows the approved page discovery")
	await press_button(purse.baker.back, "Salma can return to the door list")
	check(visible_text().contains(purse.people[3].name) and find_button(app.ui, purse.give_secret) == null, "Salma reveals Umm Salim and reading still gates secrecy")
	await press_button(take_page, "the discovered page opens with Idris")
	var word: Dictionary = chapter.words.sirr
	var learned_word := "%s (%s)" % [word.en, word.ar]
	var hadith: String = str(page.hadith).format({"teacher": chapter.teacher, "word": learned_word})
	check(app.ui.screen == "purse_page" and app.current_place == "masjid" and app.known_words.has("sirr"), "reading at the Masjid teaches sirr through the shared word store")
	check(visible_text().to_lower().contains(hadith.to_lower()) and visible_text().to_lower().contains(str(page.source).to_lower()), "the page renders the full locked hadith and its source")
	await press_button(page.back, "the page goes back to the inn door")
	check(app.current_place == "inn" and find_button(app.ui, purse.give_secret) != null, "returning from Idris unlocks secret gift buttons at the inn")
	var starting_coins: int = app.progress.coins
	var starting_trust: int = app.progress.trust
	app.progress.coins = 5
	app.update_state()
	var tariq_cost: int = int(purse.people[2].cost)
	var give_tariq: String = str(purse.give).format({"n": tariq_cost})
	check(visible_text().count(purse.not_enough) == 3 and find_button(app.ui, give_tariq) == null, "the poor door-list state shows three locked affordability messages")
	app.progress.coins = starting_coins
	app.update_state()
	var public_tariq := find_button(app.ui, give_tariq)
	var secret_tariq: Button = null
	if public_tariq != null:
		secret_tariq = find_button_in_row(app.ui, purse.give_secret, public_tariq.global_position.y)
	check(secret_tariq != null, "Tariq has an actual In secret button on his row")
	if secret_tariq != null:
		secret_tariq.pressed.emit()
		await frames(2)
	check_wallet(starting_trust, starting_coins - tariq_cost, "the secret Tariq button charges the locked cost and gives zero trust")
	check(visible_text().contains(purse.given_secret), "the door list shows the approved secret gift status")
	await press_button(purse.end_day, "the door list can End the day")
	check(app.ui.screen == "purse_morning" and app.day == 4 and app.minute_of_day == 7 * 60, "End the day shows the next morning at 07:00")
	check(visible_text().contains(purse.morning.quiet) and not visible_text().contains(purse.morning.fire), "a secret Tariq gift produces a quiet morning without Tariq's identifying line")
	await press_button(purse.morning.to_rep, "the morning panel opens What people say")
	var text := visible_text()
	check(text.contains(rep.empty) and text.to_lower().contains(str(rep.secret_note).to_lower()) and text.to_lower().contains(str(rep.towns_note).to_lower()) and not text.contains(rep.fooled[0]), "secret Tariq adds the private note and no identifying reputation line")
	await press_button(rep.to_map, "the finished purse returns to the inn market map")
	check(app.ui.screen == "market_map" and app.current_place == "inn" and find_button(app.ui, chapter.places.inn) == null, "the inn action disappears after the morning")
	await press_button(purse.morning.to_rep, "reputation remains available from the market map")
	await press_button(rep.to_goal, "reputation connects to the original goal panel")
	check(app.ui.screen == "goal", "reputation's Goal opens the original panel")
	app.begin_game()
	check(not app.open_purse.done and not app.open_purse.page_read and not app.open_purse.salma_asked and app.open_purse.gift_status("fire").is_empty(), "a fresh game clears the open purse and gifts")


func check_bread_grab_runtime() -> void:
	# Keep the simulated clock at the exact minute until each transition is checked.
	app.set_process(false)
	var chapter: Dictionary = app.chapter
	var grab: Dictionary = chapter.grab
	var asks_at := int(chapter.numbers.grab_ask_minute)
	reset_at_bread_grab()
	app.world.salma.hide()
	app.update_state()
	check(find_button(app.ui, chapter.places.board) == null, "the oven action requires Salma to be present")
	app.show_bread_grab()
	check(app.ui.screen == "market_map", "an absent Salma blocks opening the oven scene")
	app.world.salma.show()
	app.update_state()
	await press_button(chapter.places.board, "the Task board has the locked oven action")
	check(app.ui.screen == "grab_see" and visible_text().contains(grab.see.text), "the oven panel shows the locked scene")
	check(app.day == 3 and app.minute_of_day == 10 * 60, "opening the oven scene leaves the clock at 10:00")
	await press_button(grab.see.next, "Walk on returns to the market map")
	check(app.ui.screen == "market_map" and app.current_place == "board", "Walk on returns to the Task board")
	check(app.day == 3 and app.minute_of_day == 10 * 60, "Walk on does not jump the clock")
	check(find_button(app.ui, chapter.places.board) == null, "the start action disappears once the grab has been seen")
	for expected_day in [3, 4]:
		app.clock.advance_to(expected_day, asks_at - 1, false)
		app.update_state()
		check(visible_text().contains(grab.wait_line), "the board shows the locked waiting line at 16:09 on day %d" % expected_day)
		check(find_button(app.ui, grab.ask_button) == null, "Salma's question is unavailable at 16:09 on day %d" % expected_day)
		app.ask_about_bread()
		check(app.ui.screen == "market_map", "the early question cannot be opened on day %d" % expected_day)
		app.clock.advance_to(expected_day, asks_at, false)
		app.update_state()
		check(find_button(app.ui, grab.ask_button) != null, "Salma's question becomes available at 16:10 on day %d" % expected_day)
		check(not visible_text().contains(grab.wait_line), "the question replaces the waiting line at 16:10 on day %d" % expected_day)
	app.world.salma.hide()
	app.update_state()
	check(find_button(app.ui, grab.ask_button) == null, "Salma's question disappears when she is away")
	app.ask_about_bread()
	check(app.ui.screen == "market_map", "an absent Salma blocks opening the question after 16:10")
	app.world.salma.show()
	app.player.position = app.world.point("inn")
	app.update_state()
	check(find_button(app.ui, grab.ask_button) == null, "Salma's question is only available at the Task board")
	app.ask_about_bread()
	check(app.ui.screen == "market_map", "the question cannot be opened away from the board")
	app.player.position = app.world.point("board")
	app.update_state()
	await press_button(grab.ask_button, "Salma can ask the next day at 16:10")
	check(app.ui.screen == "grab_ask" and visible_text().contains(grab.ask.text), "Salma asks the exact locked question")
	check(app.day == 4 and app.minute_of_day == asks_at, "opening the question does not jump the clock")
	var previous_y := -1.0
	for answer: Dictionary in grab.answers.values():
		var button := find_button(app.ui, answer.button)
		check(button != null and button.global_position.y > previous_y, "answer buttons follow the locked data order: " + answer.button)
		if button != null:
			previous_y = button.global_position.y

	for id: String in grab.answers:
		await check_bread_grab_answer(id, 20, 198, id == "lie")
	await check_bread_grab_answer("truth", int(data.numbers.trust_max) - 1, 198)
	await check_bread_grab_answer("lie", 1, 198)
	await check_bread_grab_answer("pay", 20, 0)
	reset_at_bread_grab()
	check(find_button(app.ui, chapter.places.board) != null, "a fresh game makes the oven action available again")
	app.show_screen("reputation")
	check(visible_text().contains(chapter.rep.empty), "a fresh game clears the bread grab reputation")
	app.set_process(true)


func reset_at_bread_grab() -> void:
	app.begin_game()
	app.clock.advance_to(3, 10 * 60, false)
	app.player.position = app.world.point("board")
	app.show_screen("market_map")


func check_bread_grab_answer(id: String, trust: int, coins: int, seed_reputation: bool = false) -> void:
	reset_at_bread_grab()
	var chapter: Dictionary = app.chapter
	var grab: Dictionary = chapter.grab
	var answer: Dictionary = grab.answers[id]
	app.progress.trust = trust
	app.progress.coins = coins
	if seed_reputation:
		check(app.open_purse.give("fire", false), "a prior public gift adds earlier reputation")
	var starting_trust: int = app.progress.trust
	var starting_coins: int = app.progress.coins
	var asks_at := int(chapter.numbers.grab_ask_minute)
	await press_button(chapter.places.board, "the oven scene is available: " + id)
	await press_button(grab.see.next, "Walk on leaves Salma's question pending: " + id)
	app.clock.advance_to(3, asks_at, false)
	app.update_state()
	await press_button(grab.ask_button, "Salma can ask on the same day at 16:10: " + id)
	app.answer_bread_grab("unknown")
	check(app.ui.screen == "grab_ask", "an unknown answer leaves the question open: " + id)
	await press_button(answer.button, "the locked answer can be selected: " + id)
	check(app.ui.screen == "grab_after" and visible_text().contains(answer.out), "the locked outcome appears after: " + id)
	check(visible_text().to_lower().contains(str(grab.after.note).to_lower()) == (id == "lie"), "only the lie shows the locked note: " + id)
	var expected_trust := clampi(starting_trust + int(answer.trust), 0, int(data.numbers.trust_max))
	var expected_coins := maxi(starting_coins + int(answer.coins), 0)
	check_wallet(expected_trust, expected_coins, "the answer applies its locked trust and coin changes: " + id)
	app.answer_bread_grab("lie")
	check_wallet(expected_trust, expected_coins, "a second answer cannot change the wallet: " + id)
	check(app.day == 3 and app.minute_of_day == asks_at, "answering does not jump the clock: " + id)
	if id == "quiet":
		await press_button(grab.after.to_map, "the outcome can return directly to the market map")
		check(app.ui.screen == "market_map" and app.current_place == "board", "the direct map action returns to the board")
		await press_button(chapter.purse.morning.to_rep, "What people say is available from the board after the outcome")
	else:
		await press_button(grab.after.to_rep, "the outcome opens What people say: " + id)
	var reputation := visible_text()
	check(app.ui.screen == "reputation", "the outcome opens the reputation screen: " + id)
	for other_id: String in grab.answers:
		var say = grab.answers[other_id].say
		if say != null:
			check(reputation.contains("“%s”" % say[0]) == (other_id == id), "only the chosen answer may add its reputation line: %s / %s" % [id, other_id])
	if answer.say == null:
		check(reputation.contains(chapter.rep.empty), "saying nothing leaves otherwise empty reputation empty")
	else:
		check(has_visible_label(app.ui, str(answer.say[1]).to_upper()), "the answer names its locked speaker: " + id)
		check(has_visible_label(app.ui, chapter.rep.tone[str(int(answer.say[2]))]), "the answer shows its locked reputation tone: " + id)
	if seed_reputation:
		var gives := reputation.find("“%s”" % chapter.rep.gives[0])
		var fooled := reputation.find("“%s”" % chapter.rep.fooled[0])
		var bread := reputation.find("“%s”" % answer.say[0])
		check(gives >= 0 and gives < fooled and fooled < bread, "bread grab reputation follows the prior purse lines")
	await press_button(chapter.rep.to_map, "reputation returns to the market map: " + id)
	check(app.current_place == "board" and find_button(app.ui, chapter.places.board) == null and find_button(app.ui, grab.ask_button) == null and not visible_text().contains(grab.wait_line), "the finished board has no bread grab action or waiting line: " + id)


func find_button_in_row(node: Node, caption: String, y: float) -> Button:
	if node is Button and node.text == caption and is_equal_approx(node.global_position.y, y):
		return node
	for child in node.get_children():
		var found := find_button_in_row(child, caption, y)
		if found != null:
			return found
	return null


func finish() -> void:
	print("FOUNDATIONS TESTS: ", checks - failures, "/", checks, " passed; failures=", failures)
	if app != null:
		app.queue_free()
	quit(0 if failures == 0 else 1)


func check_market_stall_runtime() -> void:
	var locked := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/MARKET_STALL/RECORD/market_stall_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/market_stall.json")
	var market: Dictionary = app.market_stall.data
	check(not locked.is_empty() and locked == runtime, "market stall runtime copies the locked data byte for byte")
	check(market == JSON.parse_string(runtime.get_string_from_utf8()), "market stall rules and interface use the locked runtime data")
	await check_market_stall_return(market)
	await check_market_stall_keep(market)
	await check_market_stall_bag_and_feed(market)


func reset_at_market_place(place: String, coins: int) -> void:
	app.begin_game()
	app.clock.advance_to(3, 10 * 60, false)
	app.progress.coins = coins
	move_market_fixture(place)


func move_market_fixture(place: String) -> void:
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.show_screen("market_map")


func market_buy_caption(market: Dictionary, price: int) -> String:
	return str(market.stall.buy_one if price == 1 else market.stall.buy).format({"n": price})


func market_coins_caption() -> String:
	return str(data.ui.hud.coins).format({"n": app.progress.coins})


func check_market_stall_return(market: Dictionary) -> void:
	var bread := int(market.items[0].price)
	var dates := int(market.items[1].price)
	var clothes := int(market.items[2].price)
	var extra := int(market.numbers.change_extra)
	reset_at_market_place("spice", bread)
	app.show_screen("game")
	check(find_button(app.ui, market.place.spice_button) != null, "spice row offers the locked stall action")
	key_event(KEY_E, true)
	key_event(KEY_E, false)
	await frames(2)
	check(app.ui.screen == "stall", "E at spice row opens Rashid's stall")
	check(visible_text().contains(market.stall.not_enough), "unaffordable items show the locked status")
	check(find_button(app.ui, market_buy_caption(market, dates)) == null, "unaffordable dates have no Buy button")
	app.buy_stall_item("dates")
	app.buy_stall_item("unknown")
	check(app.progress.coins == bread and app.market_stall.count("dates") == 0, "invalid and unaffordable purchases have no effect")
	await press_button(market_buy_caption(market, bread), "the exact wallet price buys bread")
	check(app.ui.screen == "stall_change" and visible_text().contains(market.stall.change.text.format({"n": extra})), "first purchase opens the locked change panel")
	check(app.progress.coins == extra and app.market_stall.count("bread") == 1, "first purchase pays the price, adds bread and gives extra coins")
	check(find_button(app.ui, market_coins_caption()) == null, "bag cannot bypass the unresolved change decision")
	key_event(KEY_ESCAPE, true)
	key_event(KEY_ESCAPE, false)
	await frames(2)
	check(app.ui.screen == "stall_change", "Esc keeps the change decision open")
	var trust: int = app.progress.trust
	await press_button(market.stall.change.give_back, "give the extra change back")
	trust += int(market.numbers.change_return_trust)
	check_wallet(trust, 0, "returning the change spends the extra coins and grants trust")
	check(app.ui.screen == "stall" and visible_text().contains(market.stall.change.returned), "stall shows Rashid's response")
	app.resolve_stall_change(true)
	check_wallet(trust, 0, "the returned change cannot be returned again")
	app.progress.coins = dates + clothes
	app.update_state()
	await press_button(market_buy_caption(market, dates), "buy dates after resolving the first purchase")
	check_wallet(trust, clothes, "second purchase charges only the price")
	check(app.market_stall.count("dates") == 1 and app.ui.screen == "stall", "second purchase adds dates without a change panel")
	await press_button(market_buy_caption(market, clothes), "buy the local clothes")
	check_wallet(trust, 0, "local clothes cost exactly their locked price")
	check(find_button(app.ui, market_buy_caption(market, clothes)) == null and visible_text().contains(market.stall.owned), "already-owned clothes show bought instead of Buy")
	app.progress.coins = clothes
	app.buy_stall_item("clothes")
	check(app.progress.coins == clothes and app.market_stall.count("clothes") == 1, "buying local clothes again is rejected even when affordable")
	check(app.ui.reputation_lines() == [market.say.returned], "returning change adds only the returned reputation line")


func check_market_stall_keep(market: Dictionary) -> void:
	var bread := int(market.items[0].price)
	reset_at_market_place("spice", bread)
	await press_button(market.place.spice_button, "market-map spice row button opens the stall")
	await press_button(market_buy_caption(market, bread), "buy bread for the keep-change branch")
	var coins: int = app.progress.coins
	var trust: int = app.progress.trust
	await press_button(market.stall.change.keep, "keep the extra change")
	check_wallet(trust, coins, "keeping the change leaves the wallet and trust intact that day")
	check(visible_text().contains(market.stall.change.kept), "stall shows the locked keep response")
	check(app.ui.reputation_lines().is_empty(), "kept change has no reputation before discovery")
	await press_button(market.stall.back, "stall Back returns to the market map")
	await press_button(market.place.spice_button, "reopen the stall on the same day")
	check_wallet(trust, coins, "a same-day return does not cost trust")
	check(not visible_text().contains(market.stall.change.found), "same-day return shows no discovery")
	await press_button(market.stall.back, "leave before the next day")
	app.clock.advance_to(app.day + 2, 10 * 60, false)
	app.update_state()
	check_wallet(trust, coins, "passing days alone does not cost trust")
	await press_button(market.place.spice_button, "reopen the stall after skipping a day")
	trust += int(market.numbers.change_kept_trust)
	check_wallet(trust, coins, "the first later visit deducts trust once without changing coins")
	check(visible_text().contains(market.stall.change.found), "Rashid explains his discovery when it occurs")
	check(app.ui.reputation_lines() == [market.say.kept], "the discovered choice adds only the kept reputation line")
	await press_button(market.stall.back, "leave after discovery")
	await press_button(market.place.spice_button, "reopen after discovery")
	check_wallet(trust, coins, "the discovery cannot deduct trust again")
	check(not visible_text().contains(market.stall.change.found), "the discovery response is shown only when it occurs")


func check_market_stall_bag_and_feed(market: Dictionary) -> void:
	var bread := int(market.items[0].price)
	var clothes := int(market.items[2].price)
	reset_at_market_place("quay", 2 * bread + clothes + 100)
	check(app.market_stall.change_state == MarketStall.Change.NONE, "beginning again clears the previous change decision")
	check(find_button(app.ui, market.place.quay_feed) == null, "Quay cannot offer bread with an empty bag")
	await press_button(market_coins_caption(), "clicking the coins box opens the bag")
	check(app.ui.screen == "bag" and visible_text().contains(market.bag.empty), "empty bag shows the locked empty state")
	await press_button(market.bag.back, "bag Back returns to the market map")
	move_market_fixture("spice")
	await press_button(market.place.spice_button, "open the stall to fill the bag")
	await press_button(market_buy_caption(market, bread), "buy the first of two loaves")
	await press_button(market.stall.change.give_back, "resolve the change before buying again")
	await press_button(market_buy_caption(market, bread), "buy the second loaf")
	await press_button(market_buy_caption(market, clothes), "buy clothes for the bag")
	await press_button(market.stall.back, "leave with the full bag")
	check(find_button(app.ui, market.place.quay_feed) == null, "bread action stays off the spice row")
	app.give_bread_to_faris()
	check(app.market_stall.count("bread") == 2, "giving bread is rejected away from the Quay")
	await press_button(market_coins_caption(), "open the bag with goods")
	check(visible_text().contains("%s × 2" % market.items[0].name), "bag shows the repeatable item's count")
	check(visible_text().contains(market.items[2].line), "the wardrobe shows the local clothes description")
	await press_wear("clothes")
	check(app.market_stall.worn_clothes == "clothes" and find_button(app.ui, market.bag.wear) == null, "local clothes are marked worn in the wardrobe with the old toggle gone")
	check(app.ui.reputation_lines() == [market.say.returned, market.say.clothes], "clothes reputation follows returned change")
	await press_wear("traveller")
	check(app.market_stall.worn_clothes == "traveller" and app.ui.reputation_lines() == [market.say.returned], "switching back to the traveller's clothes clears the local clothes line")
	await press_wear("clothes")
	await press_button(market.bag.back, "close bag before going to the Quay")
	move_market_fixture("quay")
	check(find_button(app.ui, data.ui.place_actions.quay) != null, "bread keeps the regular Quay action visible")
	var coins: int = app.progress.coins
	var trust: int = app.progress.trust
	await press_button(market.place.quay_feed, "Quay offers the first bread gift")
	trust += int(market.numbers.feed_trust)
	check_wallet(trust, coins, "the first gift adds trust and leaves coins alone")
	check(app.market_stall.count("bread") == 1 and visible_text().contains(market.feed), "first gift consumes one loaf and shows the locked toast")
	await press_button(market.place.quay_feed, "the remaining loaf can be given")
	check_wallet(trust, coins, "a repeat gift does not give more trust")
	check(app.market_stall.count("bread") == 0 and find_button(app.ui, market.place.quay_feed) == null, "using the last bread removes the action immediately")
	app.give_bread_to_faris()
	check_wallet(trust, coins, "giving without bread cannot affect the wallet")
	await check_market_stall_reputation_order(market)


func check_market_stall_reputation_order(market: Dictionary) -> void:
	var chapter: Dictionary = app.chapter
	for task: Dictionary in data.tasks:
		app.progress.choose_task(task.id, "honest")
	app.progress.do_daily_job()
	app.progress.try_weight(int(data.lesson.false_weight_index))
	app.progress.answer_weight()
	app.progress.coins += int(chapter.purse.people[2].cost)
	app.open_purse.give("fire", false)
	app.bread_grab.answer_id = "lie"
	await press_button(chapter.purse.morning.to_rep, "open What people say with earlier and new reputation lines")
	var lines: Array = app.ui.reputation_lines()
	check(lines.slice(-4) == [chapter.grab.answers.lie.say, market.say.returned, market.say.fed, market.say.clothes], "ordered stall lines follow the bread grab and earlier reputation")
	var scrolls: Array[Node] = app.ui.find_children("*", "ScrollContainer", true, false)
	var back := find_button(app.ui, chapter.rep.to_map)
	check(lines.size() > 9 and scrolls.size() == 1, "combined reputation lines are scrollable")
	check(back != null and back.get_global_rect().end.y < 1080, "the back button remains visible under the full reputation list")


func press_wear(id: String) -> void:
	var button := app.ui.find_child("Wear_" + id, true, false) as Button
	var bag: Dictionary = app.market_stall.clothes_data.bag
	check(button != null and button.text == bag.wear, "wardrobe offers the locked Wear caption for " + id)
	await press_control(button, "wear outfit from its wardrobe row: " + id)


func check_clothes_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/CLOTHES/RECORD/clothes_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/clothes.json")
	var shop: MarketStall = app.market_stall
	var clothes := shop.clothes_data
	check(not approved.is_empty() and approved == runtime, "clothes runtime copies the locked data byte for byte")
	check(clothes == JSON.parse_string(runtime.get_string_from_utf8()), "the loom and wardrobe read the runtime data")
	var loom: Dictionary = clothes.loom
	var market := shop.data
	var funds := int(clothes.leather_bag.price)
	for item in shop.loom_items:
		funds += int(item.price)
	reset_at_market_place("weaver", funds)
	var trust: int = app.progress.trust
	check(shop.count("traveller") == 1 and shop.worn_clothes == "traveller", "the traveller starts with their own clothes on")
	check(shop.capacity() == int(clothes.numbers.pouch) and shop.carried() == 0, "the starting pouch holds six and worn clothes take no space")
	check(app.world.layla.mesh is CapsuleMesh and app.world.layla.get_child(0).text == str(loom.title).get_slice("'s", 0), "Layla has the locked name above her capsule")
	check(app.ui.reputation_lines().is_empty(), "the traveller's clothes add no reputation")
	move_market_fixture("quay")
	app.show_loom()
	check(app.ui.screen == "market_map" and find_button(app.ui, clothes.place.weaver_button) == null, "the loom action belongs only at weaver's lane")
	move_market_fixture("weaver")
	app.show_screen("game")
	key_event(KEY_E, true)
	key_event(KEY_E, false)
	await frames(2)
	check(app.ui.screen == "loom", "E at weaver's lane opens Layla's loom")
	key_event(KEY_ESCAPE, true)
	key_event(KEY_ESCAPE, false)
	await frames(2)
	check(app.ui.screen == "market_map", "Esc from the loom returns to the map")
	await press_button(clothes.place.weaver_button, "the market map loom action replaces Look around")
	check(app.ui.screen == "loom" and visible_text().contains(loom.intro), "the loom uses its locked heading and intro")
	app.buy_loom_item("traveller")
	app.buy_loom_item("clothes")
	check_wallet(trust, funds, "the loom cannot sell the starting or stall outfits")
	await check_loom_purchases(shop, trust)
	await check_full_bag(shop, trust)
	await check_outfit_reputation(shop)


func check_loom_purchases(shop: MarketStall, trust: int) -> void:
	var clothes := shop.clothes_data
	var loom: Dictionary = clothes.loom
	var wallet: int = app.progress.coins
	for item in shop.loom_items:
		if item.id in [clothes.leather_bag.id, "silk"]:
			continue
		var price := int(item.price)
		var caption: String = loom.buy.format({"n": price})
		await press_button(caption, "buy " + str(item.name) + " from Layla")
		wallet -= price
		check_wallet(trust, wallet, "Layla charges the locked price once")
		check(shop.count(item.id) == 1 and shop.worn_clothes == "traveller", "the purchased outfit joins the wardrobe unworn")
		check(find_button(app.ui, caption) == null and shop.loom_status(item) == loom.owned, "the purchased outfit shows yours")
		app.buy_loom_item(item.id)
		check(shop.count(item.id) == 1 and app.progress.coins == wallet, "duplicate loom purchases cannot charge or duplicate an outfit")
	await press_button(loom.back, "the loom Back returns to the market map")
	check(shop.carried() == shop.loom_items.size() - 2, "the four unworn loom outfits use space")


func check_full_bag(shop: MarketStall, trust: int) -> void:
	var clothes := shop.clothes_data
	var market := shop.data
	var bag: Dictionary = clothes.leather_bag
	var bread: Dictionary = market.items[0]
	var dates: Dictionary = market.items[1]
	var local: Dictionary = market.items[2]
	var silk: Dictionary = shop.loom_items.back()
	app.progress.coins = int(bag.price) + 2 * int(bread.price) + int(dates.price) + int(local.price) + 2 * int(silk.price)
	move_market_fixture("spice")
	await press_button(market.place.spice_button, "open the stall with room in the pouch")
	await press_button(market_buy_caption(market, int(bread.price)), "buy the first loaf")
	await press_button(market.stall.change.keep, "resolve the first stall purchase")
	await press_button(market_buy_caption(market, int(bread.price)), "buy the sixth carried thing")
	var wallet: int = app.progress.coins
	check(shop.is_full() and shop.carried() == int(clothes.numbers.pouch), "unworn outfits and bread fill the pouch")
	for item: Dictionary in market.items:
		check(shop.purchase_status(item) == clothes.loom.full and find_button(app.ui, market_buy_caption(market, int(item.price))) == null, "a full bag hides the affordable stall purchase")
		app.buy_stall_item(item.id)
	check_wallet(trust, wallet, "full stall transactions cannot change the wallet or trust")
	await press_button(market_coins_caption(), "open a full wardrobe from the stall")
	check(visible_text().contains(str(clothes.bag.full_note).to_upper()), "a full wardrobe shows its locked note")
	await press_wear("work")
	check(shop.is_full() and shop.carried() == int(clothes.numbers.pouch), "wearing at capacity swaps one outfit for another without increasing carried count")
	await press_button(market.bag.back, "leave the full wardrobe")
	move_market_fixture("weaver")
	await press_button(clothes.place.weaver_button, "open the loom while the pouch is full")
	var silk_caption: String = clothes.loom.buy.format({"n": int(silk.price)})
	check(shop.loom_status(silk) == clothes.loom.full and find_button(app.ui, silk_caption) == null, "the full pouch blocks the affordable silk purchase")
	app.buy_loom_item(silk.id)
	check(shop.count(silk.id) == 0, "no outfit goes into a full pouch")
	check_wallet(trust, wallet, "full loom transactions cannot change the wallet or trust")
	var bag_caption: String = clothes.loom.buy.format({"n": int(bag.price)})
	await press_button(bag_caption, "the full bag does not block the leather bag")
	wallet -= int(bag.price)
	check_wallet(trust, wallet, "the leather bag costs its locked price")
	check(shop.count(bag.id) == 1 and shop.capacity() == int(clothes.numbers.leather_bag) and not shop.is_full(), "the leather bag expands capacity to twelve")
	app.buy_loom_item(bag.id)
	check_wallet(trust, wallet, "a duplicate leather bag purchase is rejected")
	await press_button(silk_caption, "buy silk in the new space")
	wallet -= int(silk.price)
	check(shop.count(silk.id) == 1 and shop.worn_clothes == "work", "the silk purchase adds exactly one unworn outfit")
	app.buy_loom_item(silk.id)
	check_wallet(trust, wallet, "the affordable duplicate silk purchase cannot charge again")
	await press_button(clothes.loom.back, "leave after the leather bag upgrade")
	move_market_fixture("spice")
	await press_button(market.place.spice_button, "reopen the stall after upgrading")
	await press_button(market_buy_caption(market, int(dates.price)), "buy dates in the new space")
	await press_button(market_buy_caption(market, int(local.price)), "buy the local outfit in the new space")
	check(shop.carried() == shop.count("bread") + shop.count("dates") + 6, "carried count includes food and six unworn outfits only")
	await press_button(market_coins_caption(), "open the wardrobe with all outfits and both things")
	var scroll := app.ui.find_child("WardrobeScroll", true, false) as ScrollContainer
	check(scroll != null and scroll.get_v_scroll_bar().max_value > scroll.size.y, "the long wardrobe can scroll")
	var back := find_button(app.ui, market.bag.back)
	check(back != null and back.get_global_rect().end.y < 1080, "the long wardrobe keeps Back in view")


func check_outfit_reputation(shop: MarketStall) -> void:
	var clothes := shop.clothes_data
	var trust: int = app.progress.trust
	var wallet: int = app.progress.coins
	var carried := shop.carried()
	for id: String in ["scholar", "merchant", "silk", "work"]:
		await press_wear(id)
		check(app.ui.reputation_lines() == [clothes.say[id]], "the worn outfit supplies its exact reputation line and tone")
		check_wallet(trust, wallet, "wearing an outfit never changes coins or trust")
		check(shop.carried() == carried, "outfit switches preserve carried count")
	await press_wear("best")
	check(app.ui.reputation_lines().is_empty(), "best clothes add no line outside Friday")
	await press_button(shop.data.bag.back, "close the wardrobe before checking Friday")
	await press_button(app.chapter.purse.morning.to_rep, "open What people say while wearing best clothes")
	app.clock.advance_to(9, 10 * 60, false)
	app.update_state()
	check(app.ui.reputation_lines() == [clothes.say.best_friday] and visible_text().contains(clothes.say.best_friday[0]), "Friday adds the locked line to the open reputation panel")
	app.clock.advance_to(10, 10 * 60, false)
	app.update_state()
	check(app.ui.reputation_lines().is_empty() and not visible_text().contains(clothes.say.best_friday[0]), "the line leaves the panel when Friday ends")
	check_wallet(trust, wallet, "the Friday outfit leaves coins and trust alone")
	reset_at_market_place("weaver", 0)
	check(shop.worn_clothes == "traveller" and shop.carried() == 0 and shop.capacity() == int(clothes.numbers.pouch), "beginning again clears purchases and restores the starting wardrobe")
	await press_button(clothes.place.weaver_button, "open the loom with an empty wallet")
	check(visible_text().contains(clothes.loom.not_enough) and find_button(app.ui, clothes.loom.buy.format({"n": int(clothes.leather_bag.price)})) == null, "unaffordable clothes and bag show the locked status")
	app.buy_loom_item(clothes.leather_bag.id)
	check(app.progress.coins == 0 and shop.capacity() == int(clothes.numbers.pouch), "an unaffordable leather bag cannot change the wallet or capacity")


func check_talking_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/TALKING/RECORD/talking_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/talking.json")
	check(not approved.is_empty() and approved == runtime, "talking runtime is byte-identical to the LOCK")
	var talking: Dictionary = app.talking.data
	check(talking == JSON.parse_string(runtime.get_string_from_utf8()), "talking reads the locked runtime data")
	reset_at_market_place("inn", 100)
	for regular: Dictionary in talking.people:
		check(find_button(app.ui, str(talking.talk_button).format({"name": regular.name})) == null, "no talk action at the Inn: " + regular.id)
	check(app.world.talking_people.size() == talking.people.size(), "each regular has exactly one mapped capsule")
	var start_trust: int = app.progress.trust
	for index in talking.people.size():
		var regular: Dictionary = talking.people[index]
		var person: MeshInstance3D = app.world.talking_people[regular.id]
		check(person.mesh is CapsuleMesh and person.get_child(0).text == regular.name, "capsule has the approved name: " + regular.id)
		check(horizontal_distance(person.position, app.world.point(regular.place)) <= 2.0 * float(data.player.capsule_height), "capsule stands beside the locked place: " + regular.id)
		await open_talk_fixture(regular, talking)
		for trust: int in [39, 40, 79, 80]:
			app.progress.trust = trust
			await frames(1)
			var tier := "wary" if trust == 39 else ("warm" if trust == 80 else "friendly")
			for key: String in regular.tier:
				check(visible_text().contains(regular.tier[key]) == (key == tier), "only the correct tier line appears at %d: %s %s" % [trust, regular.id, key])
		app.progress.trust = start_trust + (int(talking.numbers.greet_trust) if index >= int(talking.numbers.greet_count) else 0)
		await frames(1)
		await press_button(talking.panel.ask, "ask " + regular.name + " for their tip")
		check(visible_text().contains(regular.tip) and not visible_text().contains(talking.panel.reply), "ask shows the person's tip")
		await press_button(talking.panel.greet, "greet " + regular.name)
		check(visible_text().contains(talking.panel.reply) and not visible_text().contains(regular.tip), "greeting replaces the tip with the reply")
		check(has_visible_label(app.ui, talking.panel.greeted) and find_button(app.ui, talking.panel.greet) == null, "greeted is a label instead of a repeat button")
		var qualified: bool = index + 1 >= int(talking.numbers.greet_count)
		var expected_trust := start_trust + (int(talking.numbers.greet_trust) if qualified else 0)
		check(app.progress.trust == expected_trust, "trust is awarded only at the third different greeting")
		check(app.ui.reputation_lines().has(talking.say.greets) == qualified, "greeting reputation appears at the third greeting")
		app.greet_regular()
		check(app.progress.trust == expected_trust and app.talking.greeted.size() == index + 1, "a duplicate greeting changes neither trust nor count")
		await press_button(talking.panel.bye, "say goodbye to " + regular.name)
		check(app.ui.screen == "market_map" and app.current_place == regular.place, "goodbye returns to the same place on the market map")
		await open_talk_fixture(regular, talking)
		check(has_visible_label(app.ui, talking.panel.greeted) and not visible_text().contains(talking.panel.reply), "reopening retains the greeting and clears the old reply")
		await press_button(talking.panel.bye, "leave the reopened conversation")
	check(app.progress.coins == 100, "dialogue actions leave the wallet alone")
	await press_button(app.chapter.purse.morning.to_rep, "open What people say after greetings")
	check(visible_text().contains(talking.say.greets[0]), "What people say shows the exact locked greeting line")
	await check_talking_memories(talking)
	reset_at_market_place("board", 100)
	check(app.talking.greeted.is_empty() and not app.ui.reputation_lines().has(talking.say.greets), "a new session resets greetings and reputation")


func open_talk_fixture(regular: Dictionary, talking: Dictionary) -> void:
	move_market_fixture(regular.place)
	var caption: String = str(talking.talk_button).format({"name": regular.name})
	await press_button(caption, "open the approved place-bar action for " + regular.name)
	check(app.ui.screen == "talk" and visible_text().contains("%s, %s" % [regular.name, regular.role]), "talk opens the correct named panel")


func check_market_day_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/MARKET_DAY/RECORD/market_day_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/market_day.json")
	var market_day: Dictionary = app.market_day.data
	check(not approved.is_empty() and runtime == approved, "market day data copies the locked file byte for byte")
	check(market_day == JSON.parse_string(runtime.get_string_from_utf8()), "the game uses the approved market day data")
	app.set_process(false)
	for regular: Dictionary in app.talking.data.people:
		var hours: Dictionary = market_day.hours[regular.id]
		var opened := int(hours.open)
		var closed := int(hours.close)
		reset_at_market_place(regular.place, 100)
		# Change time while standing in place so stale controls cannot pass.
		for minute: int in [opened - 1, opened, closed - 1, closed]:
			set_market_day_time(3, minute)
			var away := minute < opened or minute >= closed
			check_market_place_hours(regular, away, false, market_day)
		for day: int in [2, 3]:
			for minute: int in [724, 725, 759, 760]:
				set_market_day_time(day, minute)
				var friday_closed := day == 2 and minute >= 725 and minute < 760
				check_market_place_hours(regular, friday_closed, friday_closed, market_day)
	app.set_process(true)


func set_market_day_time(day: int, minute: int) -> void:
	app.clock.reset()
	app.clock.skip_to(day, minute)
	app.update_state()


func check_market_place_hours(regular: Dictionary, away: bool, friday_closed: bool, market_day: Dictionary) -> void:
	var caption: String = app.talking.data.talk_button.format({"name": regular.name})
	var context := "%s on day %d at minute %d" % [regular.name, app.day, app.minute_of_day]
	check((find_button(app.ui, caption) == null) == away, "talk action at " + context)
	var copy: Dictionary = market_day.text
	var night_notice: String = copy.closed_night.format({"name": regular.name})
	var friday_notice: String = copy.closed_friday.format({"name": regular.name})
	check(has_visible_label(app.ui, night_notice) == (away and not friday_closed), "hours notice at " + context)
	check(has_visible_label(app.ui, friday_notice) == friday_closed, "Friday notice at " + context)
	if away:
		app.show_talking()
		check(app.ui.screen == "market_map", "direct talk request refused at " + context)
	match regular.id:
		"salma":
			check((find_button(app.ui, app.chapter.places.board) == null) == away, "bread grab action at " + context)
			if away:
				app.show_bread_grab()
				check(app.ui.screen == "market_map", "bread grab request refused at " + context)
		"musa":
			check(find_button(app.ui, data.ui.place_actions.scales) != null, "scales lesson stays available at " + context)
		"rashid", "layla":
			var stall: bool = regular.id == "rashid"
			var shop_button: String = app.market_stall.data.place.spice_button if stall else app.market_stall.clothes_data.place.weaver_button
			var hours_notice: String = copy.stall_closed_night if stall else copy.loom_closed_night
			check((find_button(app.ui, shop_button) == null) == away, "shop action at " + context)
			check(has_visible_label(app.ui, hours_notice) == (away and not friday_closed), "shop hours notice at " + context)
			check(has_visible_label(app.ui, copy.shop_closed_friday) == friday_closed, "shop Friday notice at " + context)
			if away:
				app.use_place()
				check(app.ui.screen == "market_map", "shop request refused at " + context)


func check_talking_memories(talking: Dictionary) -> void:
	var salma: Dictionary = talking.people[0]
	await open_talk_fixture(salma, talking)
	for answer: String in ["", "quiet", "lie", "truth", "pay"]:
		app.bread_grab.answer_id = answer
		check_talking_memory(salma, "grab_" + answer)

	var rashid: Dictionary = talking.people[1]
	await open_talk_fixture(rashid, talking)
	var change_cases := {MarketStall.Change.NONE: "", MarketStall.Change.PENDING: "", MarketStall.Change.KEPT: "", MarketStall.Change.RETURNED: "returned", MarketStall.Change.FOUND: "kept"}
	for state: int in change_cases:
		app.market_stall.change_state = state
		check_talking_memory(rashid, change_cases[state])

	var layla: Dictionary = talking.people[2]
	await open_talk_fixture(layla, talking)
	for outfit: Dictionary in app.market_stall.clothes_data.clothes:
		app.market_stall.worn_clothes = outfit.id
		var fact := "own_cloth" if outfit.seller == layla.name else ("traveller" if outfit.id == "traveller" else "")
		check_talking_memory(layla, fact)

	var jamal: Dictionary = talking.people[3]
	await open_talk_fixture(jamal, talking)
	check_talking_memory(jamal, "")
	app.progress.boat_job_done = true
	check_talking_memory(jamal, "boat")
	app.market_stall.fed_faris = true
	check_talking_memory(jamal, "fed")
	app.progress.boat_job_done = false
	check_talking_memory(jamal, "fed")

	var musa: Dictionary = talking.people[4]
	await open_talk_fixture(musa, talking)
	check_talking_memory(musa, "not_learned")
	app.progress.lesson_done = true
	check_talking_memory(musa, "learned")
	app.market_stall.worn_clothes = "work"
	var lines: Array = app.ui.reputation_lines()
	var shop: Dictionary = app.market_stall.data
	check(lines.slice(-4) == [shop.say.kept, shop.say.fed, talking.say.greets, app.market_stall.clothes_data.say.work], "greetings follow trade and bread and come immediately before clothing")


func check_talking_memory(regular: Dictionary, fact: String) -> void:
	app.show_screen("talk")
	var copy := visible_text()
	for key: String in regular.facts:
		check(copy.contains(regular.facts[key]) == (key == fact), "only the applicable memory is visible: %s %s %s" % [regular.id, fact, key])


func check_feeding_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/FEEDING/RECORD/feeding_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/feeding.json")
	var feeding: Dictionary = app.feeding.data
	check(not approved.is_empty() and runtime == approved, "feeding data copies LOCK 9 byte for byte")
	check(feeding == JSON.parse_string(runtime.get_string_from_utf8()), "feeding uses the approved runtime data")
	var copy: Dictionary = feeding.panel
	var ten: Dictionary = feeding.options[0]
	var fifty: Dictionary = feeding.options[1]
	var pay_ten: String = str(copy.pay).format({"n": int(ten.cost)})
	var pay_fifty: String = str(copy.pay).format({"n": int(fifty.cost)})
	var daily_trust := int(feeding.numbers.trust_per_day)
	app.set_process(false)

	reset_at_market_place("board", 100)
	var trust: int = app.progress.trust
	var feed := find_button(app.ui, feeding.place_button)
	var grab := find_button(app.ui, app.chapter.places.board)
	var talk := find_button(app.ui, app.talking.button_at("board"))
	check(feed != null and grab != null and talk != null and feed.position.x < grab.position.x and grab.position.x < talk.position.x, "feeding precedes the bread grab and Salma's talk button")
	await press_button(feeding.place_button, "the square offers feeding while Salma is present")
	check(app.ui.screen == "feeding" and visible_text().contains(copy.intro), "feeding opens the locked oven introduction")
	check(find_button(app.ui, copy.secret_label) == null and has_visible_label(app.ui, str(copy.secret_locked).to_upper()), "secrecy is locked until the first scholar page")
	check(has_visible_label(app.ui, "MEALS FOR THE POOR: 0 / 10,000"), "empty counter shows the thousands comma")
	await press_button(pay_ten, "the ten-loaf row has a usable payment button")
	check_wallet(trust + daily_trust, 100 - int(ten.cost), "first public feeding charges the locked price and adds daily trust")
	check(app.feeding.meals_given == int(ten.meals) and visible_text().contains(copy.done_public), "public feeding adds the locked meals and shows Salma's public reply")
	await press_button(copy.back, "feeding returns to the market map")
	await press_button(feeding.place_button, "feeding can reopen the same day")
	await press_button(pay_fifty, "the fifty-loaf row has a usable payment button")
	check_wallet(trust + daily_trust, 100 - int(ten.cost) - int(fifty.cost), "another public payment the same day costs coins without another trust point")
	check(app.feeding.meals_given == int(ten.meals) + int(fifty.meals), "the second payment still counts the meals")
	check(app.ui.reputation_lines().count(feeding.say.feeds) == 1, "public feeding adds its reputation line exactly once")
	await press_button(copy.back, "leave feeding before advancing to the next day")
	set_market_day_time(4, 600)
	await press_button(feeding.place_button, "feeding reopens on the next game day")
	await press_button(pay_ten, "another day permits a public payment")
	check_wallet(trust + daily_trust * 2, 100 - int(ten.cost) * 2 - int(fifty.cost), "the next day awards its own single public trust point")
	app.market_stall.fed_faris = true
	app.talking.greeted = {"salma": true, "rashid": true, "layla": true}
	check(app.ui.reputation_lines() == [app.market_stall.data.say.fed, feeding.say.feeds, app.talking.data.say.greets], "feeding follows market trade and comes before greetings")

	reset_at_market_place("board", int(ten.cost) - 1)
	await press_button(feeding.place_button, "feeding opens with an insufficient balance")
	check(visible_text().count(copy.not_enough) == feeding.options.size(), "each unaffordable option shows the locked status")
	check(find_button(app.ui, pay_ten) == null and find_button(app.ui, pay_fifty) == null, "unaffordable options have no payment controls")
	app.pay_for_feeding(ten.id)
	check_wallet(trust, int(ten.cost) - 1, "an insufficient payment cannot change the wallet or trust")
	check(app.feeding.meals_given == 0 and app.ui.reputation_lines().is_empty(), "an insufficient payment cannot add meals or reputation")
	app.progress.coins = int(ten.cost)
	app.update_state()
	await press_button(pay_ten, "the exact price is affordable")
	check_wallet(trust + daily_trust, 0, "exact payment leaves zero coins")

	reset_at_market_place("inn", 400)
	await press_button(app.chapter.places.inn, "enter the open purse to discover the page")
	await press_button(app.chapter.purse.ask_baker, "ask Salma about the waiting people")
	await press_button(app.chapter.purse.baker.back, "return from Salma to take the page")
	var take_page: String = str(app.chapter.purse.take_page).format({"teacher": app.chapter.teacher})
	await press_button(take_page, "reading the first page teaches sirr")
	await press_button(app.chapter.page.back, "return from the first scholar page")
	await press_button(app.chapter.purse.not_now, "leave the purse without giving a gift")
	move_market_fixture("board")
	app.show_screen("game")
	await press_button(feeding.place_button, "feeding also opens from the street's place bar")
	var checkbox := find_button(app.ui, copy.secret_label) as CheckBox
	check(checkbox != null and not checkbox.button_pressed and not has_visible_label(app.ui, str(copy.secret_on).to_upper()), "the learned word unlocks an unchecked secret choice")
	if checkbox != null:
		checkbox.button_pressed = true
	check(has_visible_label(app.ui, str(copy.secret_on).to_upper()), "ticking secrecy shows the locked hint")
	await press_button(pay_fifty, "the secret choice uses the same payment button")
	check_wallet(trust, 400 - int(fifty.cost), "secret feeding charges the locked price with no trust change")
	check(app.feeding.meals_given == int(fifty.meals) and visible_text().contains(copy.done_secret), "secret feeding adds meals and shows Salma's secret reply")
	check(app.ui.reputation_lines().is_empty(), "secret feeding leaves no reputation line")
	for _payment in range(19):
		app.pay_for_feeding(fifty.id)
	check(has_visible_label(app.ui, "MEALS FOR THE POOR: 1,000 / 10,000"), "the running meal count also groups thousands")
	check_wallet(trust, 0, "repeat secret payments still leave trust untouched")
	await press_button(copy.back, "return from secret feeding to the square")
	check(app.ui.screen == "market_map", "the feeding back button returns to the market map")

	for fixture: Vector2i in [Vector2i(3, 1200), Vector2i(2, 725)]:
		set_market_day_time(fixture.x, fixture.y)
		check(find_button(app.ui, feeding.place_button) == null, "feeding is hidden when Salma is away at night or Friday prayer")
		app.show_feeding()
		check(app.ui.screen == "market_map", "a direct request cannot open feeding while Salma is away")
	set_market_day_time(3, 600)
	check(find_button(app.ui, feeding.place_button) != null, "feeding returns when Salma is available")
	move_market_fixture("spice")
	check(find_button(app.ui, feeding.place_button) == null, "feeding is offered only at the square")
	reset_at_market_place("board", 100)
	check(app.feeding.meals_given == 0 and app.ui.reputation_lines().is_empty(), "a new playthrough resets feeding and its reputation")
	app.set_process(true)


func check_sealed_purse_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/SEALED_PURSE/RECORD/sealed_purse_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/sealed_purse.json")
	var purse: Dictionary = app.sealed_purse.data
	check(not approved.is_empty() and runtime == approved, "sealed purse copies LOCK 10 byte for byte")
	check(purse == JSON.parse_string(runtime.get_string_from_utf8()), "sealed purse uses the locked runtime data")
	var threshold := int(purse.numbers.offer_from_trust)
	var wallet := 198
	app.set_process(false)
	reset_at_market_place("quay", wallet)
	app.progress.apply_trust(threshold - 1 - app.progress.trust)
	app.update_state()
	check(find_button(app.ui, purse.quay_button) == null, "Karim has no job at trust 39")
	app.show_sealed_purse_offer()
	check(app.ui.screen == "market_map", "a direct request cannot bypass the trust threshold")
	app.progress.apply_trust(1)
	app.update_state()
	check(find_button(app.ui, purse.quay_button) != null, "Karim offers the job at trust 40")

	var availability := [
		[3, 389, false], [3, 390, true], [3, 1089, true], [3, 1090, false],
		[2, 724, true], [2, 725, false], [2, 759, false], [2, 760, true], [3, 725, true],
	]
	for slot: Array in availability:
		set_market_day_time(slot[0], slot[1])
		var offered := find_button(app.ui, purse.quay_button) != null
		check(offered == slot[2], "Karim's hours and Friday closure at day %d, minute %d" % [slot[0], slot[1]])
		if not slot[2]:
			app.show_sealed_purse_offer()
			check(app.ui.screen == "market_map", "a direct request respects Karim's availability")
	set_market_day_time(3, 1089)
	await press_button(purse.quay_button, "Karim can offer just before closing")
	set_market_day_time(3, 1090)
	await press_button(purse.offer.accept, "a pending offer can be clicked after closing")
	check(app.ui.screen == "market_map" and not app.sealed_purse.is_carrying(), "acceptance checks the current time before taking the job")

	for keep: bool in [false, true]:
		reset_at_market_place("quay", wallet)
		app.progress.apply_trust(threshold - app.progress.trust)
		app.update_state()
		await press_button(purse.quay_button, "the quay opens Karim's job")
		check(app.ui.screen == "sealed_purse_offer" and visible_text().contains(purse.offer.text), "the offer uses the locked copy")
		await press_button(purse.offer.refuse, "refuse Karim's offer")
		check(app.ui.screen == "market_map" and app.current_place == "quay", "refusal returns to the quay map")
		check_wallet(threshold, wallet, "refusal changes neither coins nor trust")
		await press_button(purse.quay_button, "refusal leaves the offer available")
		await press_button(purse.offer.accept, "accept the sealed purse")
		check(app.ui.screen == "sealed_purse_coin" and visible_text().contains(purse.coin.text), "accepting immediately opens the locked coin choice")
		check(not app.sealed_purse.offer_available() and app.ui.reputation_lines().is_empty(), "acceptance consumes the offer without creating reputation")
		await press_button(purse.coin.keep if keep else purse.coin.back_in, "make the coin choice")
		check(app.ui.screen == "market_map" and app.current_place == "board", "both choices return to the map at the Task board")
		var carry_wallet := wallet + (int(purse.numbers.kept_coin) if keep else 0)
		check_wallet(threshold, carry_wallet, "only keeping the coin adds a coin")
		app.choose_sealed_purse_coin(true)
		check_wallet(threshold, carry_wallet, "the coin choice cannot be repeated")
		for place: String in data.places:
			move_market_fixture(place)
			check(visible_text().contains(purse.carrying), "the carrying line shows at " + place)
			check((find_button(app.ui, purse.gate_button) != null) == (place == "gate"), "delivery is available only at the gate")
		move_market_fixture("quay")
		check(find_button(app.ui, purse.quay_button) == null, "there is no second offer while carrying")
		app.deliver_sealed_purse()
		check_wallet(threshold, carry_wallet, "a direct request cannot deliver away from the gate")
		move_market_fixture("gate")
		app.show_screen("game")
		await press_button(purse.gate_button, "the gate can receive the purse from the street")
		var story: String = purse.deliver.kept if keep else purse.deliver.honest
		var outcome: Array = purse.say.kept if keep else purse.say.honest
		check(app.ui.screen == "sealed_purse_delivery" and visible_text().contains(story), "Abbas reports the locked outcome")
		var final_wallet := carry_wallet + (0 if keep else int(purse.numbers.fee))
		var final_trust := threshold + int(purse.numbers.kept_trust if keep else purse.numbers.honest_trust)
		check_wallet(final_trust, final_wallet, "whole and short deliveries apply their locked rewards")
		check(not app.sealed_purse.is_carrying() and not visible_text().contains(purse.carrying), "delivery clears the carrying line")
		if keep:
			await press_button(purse.deliver.to_map, "the short delivery can return directly to the gate map")
			check(app.ui.screen == "market_map" and app.current_place == "gate", "delivery's map button returns to the gate")
			await press_button(app.chapter.purse.morning.to_rep, "the market map opens the short delivery reputation")
		else:
			await press_button(purse.deliver.to_rep, "the delivery opens What people say")
		check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [outcome] and visible_text().contains(outcome[0]), "the reputation page shows one locked delivery line")
		await press_button(purse.deliver.to_map, "reputation returns to the market map")
		app.deliver_sealed_purse()
		check_wallet(final_trust, final_wallet, "delivery cannot pay twice")
		check(find_button(app.ui, purse.gate_button) == null, "there is no delivery button after handing the purse over")
		set_market_day_time(4, 600)
		move_market_fixture("quay")
		check(find_button(app.ui, purse.quay_button) == null, "the completed job stays done the following day")
		app.market_stall.fed_faris = true
		var option: Dictionary = app.feeding.data.options[0]
		check(app.feeding.pay(option.id, false), "fixture adds a public feeding line")
		check(app.ui.reputation_lines() == [app.market_stall.data.say.fed, outcome, app.feeding.data.say.feeds], "the sealed purse follows trade and precedes feeding")
	reset_at_market_place("quay", wallet)
	check(app.ui.reputation_lines().is_empty() and not app.sealed_purse.is_carrying(), "a new playthrough clears the sealed-purse outcome")
	app.set_process(true)
