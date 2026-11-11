extends SceneTree
## Plain, dependency-free checks against the real scene and physics world.

const PrayerClock = preload("res://game/prayer_clock.gd")
const Ramadan = preload("res://game/ramadan.gd")
const OpenPurse = preload("res://game/open_purse.gd")
const TaskProgress = preload("res://game/task_progress.gd")
const MarketStall = preload("res://game/market_stall.gd")
const MarketDay = preload("res://game/market_day.gd")

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
	check_calendar_dates()
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
	await check_dice_house_runtime()
	await check_qasims_jars_runtime()
	await check_jabirs_goats_runtime()
	await check_idris_recovery()
	await check_dry_fountain_runtime()
	await check_rashids_loan_runtime()
	await check_harm_in_the_road_runtime()
	await check_calendar_runtime()
	await check_ramadan_runtime()
	await check_iftar_giving_runtime()
	await check_eid_al_fitr_runtime()
	await check_zakat_runtime()
	await check_eid_al_adha_runtime()
	await check_pilgrims_runtime()
	await check_qurans_school_runtime()
	await check_names_of_allah_runtime()
	check_regulars_at_prayer_runtime()
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
	return find_visible_label(node, expected) != null


func find_visible_label(node: Node, expected: String) -> Label:
	if node is Control and not node.is_visible_in_tree():
		return null
	if node is Label and node.text == expected:
		return node
	for child in node.get_children():
		var label := find_visible_label(child, expected)
		if label != null:
			return label
	return null


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
	var clock := PrayerClock.new(source, app.clock.calendar)
	check(clock.day == 1 and clock.minute_of_day == 390 and not clock.night, "clock starts on Thursday at 06:30 in daylight")
	check(clock.hud().time == "Thursday 1 Sha'ban · 06:30", "HUD uses the locked weekday, Hijri date and time format")
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
		clock = PrayerClock.new(source, app.clock.calendar)
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

	clock = PrayerClock.new(source, app.clock.calendar)
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
	var clock := PrayerClock.new(identity.clock, app.clock.calendar)
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
	var clock := PrayerClock.new(identity.clock, app.clock.calendar)
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


func reset_at_market_place(place: String, coins: int, on_day: int = 3) -> void:
	app.begin_game()
	app.clock.advance_to(on_day, 10 * 60, false)
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
				var at_dhuhr: bool = day == 3 and minute == 725 and regular.id in app.market_day.prayer_data.goers
				check_market_place_hours(regular, friday_closed or at_dhuhr, friday_closed, market_day, at_dhuhr)
	app.set_process(true)


func set_market_day_time(day: int, minute: int) -> void:
	app.clock.reset()
	app.clock.skip_to(day, minute)
	app.update_state()


func check_market_place_hours(regular: Dictionary, away: bool, friday_closed: bool, market_day: Dictionary, at_prayer: bool = false) -> void:
	var caption: String = app.talking.data.talk_button.format({"name": regular.name})
	var context := "%s on day %d at minute %d" % [regular.name, app.day, app.minute_of_day]
	check((find_button(app.ui, caption) == null) == away, "talk action at " + context)
	var copy: Dictionary = market_day.text
	var night_notice: String = copy.closed_night.format({"name": regular.name})
	var friday_notice: String = copy.closed_friday.format({"name": regular.name})
	check(has_visible_label(app.ui, night_notice) == (away and not friday_closed and not at_prayer), "hours notice at " + context)
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
			check(has_visible_label(app.ui, hours_notice) == (away and not friday_closed and not at_prayer), "shop hours notice at " + context)
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
	check(feed != null and grab != null and feed.position.y == grab.position.y and feed.position.x < grab.position.x, "feeding precedes the bread grab on the same row")
	check(grab != null and talk != null and (grab.position.y < talk.position.y or (grab.position.y == talk.position.y and grab.position.x < talk.position.x)), "Salma's talk button comes after the bread grab in reading order")
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


func check_dice_house_runtime() -> void:
	var locked := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/DICE_HOUSE/RECORD/dice_house_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/dice_house.json")
	var dice: Dictionary = app.dice_house.data
	check(not locked.is_empty() and runtime == locked, "dice house copies LOCK 11 byte for byte")
	check(dice == JSON.parse_string(runtime.get_string_from_utf8()), "dice house uses the locked runtime data")
	app.set_process(false)
	reset_at_market_place("inn", 17)
	app.progress.apply_trust(45 - app.progress.trust)
	for slot: Array in [[3, 1169, false], [3, 1170, true], [3, 1439, true], [4, 0, true], [4, 284, true], [4, 285, false]]:
		set_market_day_time(slot[0], slot[1])
		check((find_button(app.ui, dice.inn_invite) != null) == slot[2], "Mansur's whisper at day %d, minute %d" % [slot[0], slot[1]])
		check(find_button(app.ui, dice.inn_button) == null, "the blue-cloth door is hidden until invited")
		if not slot[2]:
			app.open_dice_house()
			check(app.ui.screen == "market_map", "a direct request cannot open the dice house during the day")
	set_market_day_time(3, 1200)
	move_market_fixture("quay")
	check(find_button(app.ui, dice.inn_invite) == null, "Mansur's whisper only appears at the Inn")
	app.open_dice_house()
	check(app.ui.screen == "market_map", "a direct request away from the Inn cannot open the invitation")
	move_market_fixture("inn")
	await press_button(dice.inn_invite, "the Inn opens Mansur's invitation")
	check(app.ui.screen == "dice_invite" and visible_text().contains(dice.invite.text), "the invitation shows Mansur's locked words")
	await press_button(dice.invite.no, "Go to bed is a real button")
	check(app.ui.screen == "market_map" and app.current_place == "inn" and app.day == 3 and app.minute_of_day == 1200, "Go to bed returns to the Inn without moving the clock")
	check(app.dice_house.invited and app.dice_house.nights == 0 and app.ui.reputation_lines().is_empty(), "Go to bed grants the door without counting a visit or creating talk")
	check_wallet(45, 17, "Go to bed changes neither trust nor coins")
	check(find_button(app.ui, dice.inn_invite) == null, "the whisper is replaced by the door")
	set_market_day_time(3, 1169)
	check(find_button(app.ui, dice.inn_button) == null, "the blue-cloth door is also hidden before opening")
	set_market_day_time(3, 1200)
	await press_button(dice.inn_button, "the blue-cloth door opens directly after Go to bed")
	check(app.ui.screen == "dice_house" and visible_text().contains(dice.house.text), "first entry shows the locked dice house description")
	check(has_visible_label(app.ui, str(dice.house.visits).format({"n": 1}).to_upper()), "the house displays the first night's count")
	check(app.ui.reputation_lines().is_empty(), "one night stays secret")
	check_wallet(45, 17, "the first night changes neither trust nor coins")

	var win := int(dice.numbers.win_chance_percent) - 1
	var loss := int(dice.numbers.win_chance_percent)
	var five: String = str(dice.house.bet).format({"n": 5})
	var ten: String = str(dice.house.bet).format({"n": 10})
	var twenty: String = str(dice.house.bet).format({"n": 20})
	check(find_button(app.ui, five) != null and find_button(app.ui, ten) != null and find_button(app.ui, twenty) == null, "the player can only select affordable locked bets")
	check(has_visible_label(app.ui, dice.house.not_enough), "an unaffordable bet is replaced by the locked notice")
	app.bet_at_dice_house(20, win)
	app.bet_at_dice_house(1, win)
	check_wallet(45, 17, "direct calls reject unaffordable and unlisted stakes")
	app.bet_at_dice_house(10, win)
	check_wallet(45, 27, "a roll below the locked 50% threshold adds exactly the stake with no trust change")
	check(visible_text().contains(str(dice.house.won).format({"n": 10})), "win shows the locked result")
	check(find_button(app.ui, twenty) != null, "the win can make another bet affordable")
	app.bet_at_dice_house(20, loss)
	check_wallet(45, 7, "a roll at the locked 50% threshold subtracts exactly the stake with no trust change")
	check(visible_text().contains(str(dice.house.lost).format({"n": 20})), "loss shows the locked result")
	var texts: Array[String] = []
	collect_text(app.ui, texts)
	check(texts.count(dice.house.not_enough) == 2, "each of the two unaffordable stakes has its own notice")
	app.progress.coins = 5
	app.update_state()
	app.bet_at_dice_house(5, loss)
	app.bet_at_dice_house(5, loss)
	check_wallet(45, 0, "a stake equal to the wallet may lose once, and coins never go below zero")
	app.progress.coins = 5
	app.update_state()
	await press_button(five, "the real bet button rolls without a test override")
	check(app.progress.coins in [0, 10] and app.progress.trust == 45, "the real roll settles exactly one stake without affecting trust")
	await press_button(dice.house.leave, "the house has a usable Leave button")
	check(app.ui.screen == "market_map" and app.current_place == "inn", "Leave returns to the market map at the Inn")
	await press_button(dice.inn_button, "the door stays available on the same night")
	check(app.dice_house.nights == 1, "same-evening reentry does not count twice")
	app.leave_dice_house()
	set_market_day_time(4, 284)
	app.open_dice_house()
	check(app.dice_house.nights == 1, "04:44 reentry belongs to the previous evening")
	app.leave_dice_house()
	set_market_day_time(4, 285)
	check(find_button(app.ui, dice.inn_button) == null, "the blue-cloth door closes at 04:45")
	await check_dice_house_talk(dice)

	reset_at_market_place("inn", 30)
	check(not app.dice_house.invited and app.dice_house.nights == 0 and app.dice_house.last_result.is_empty() and app.ui.reputation_lines().is_empty(), "a new playthrough clears dice invitation, visits, result and talk")
	set_market_day_time(3, 1200)
	await press_button(dice.inn_invite, "the new playthrough starts with Mansur's whisper")
	await press_button(dice.invite.go, "Follow him enters on the first visit")
	check(app.ui.screen == "dice_house" and app.dice_house.invited and app.dice_house.nights == 1, "following Mansur marks the invitation and counts one visit")
	app.leave_dice_house()
	app.progress.apply_trust(3 - app.progress.trust)
	for day in range(4, 7):
		set_market_day_time(day, 1200)
		app.open_dice_house()
		app.leave_dice_house()
	check(app.dice_house.nights == 4 and app.progress.trust == 0, "the fourth-night penalty clamps trust to zero")
	check(app.idris_recovery.cool_point == -2, "the fourth-night hit counts in full for Idris even at the display floor")
	app.set_process(true)


func check_dice_house_talk(dice: Dictionary) -> void:
	var expected_trust := 45
	var expected_line: Array = []
	var visit_wallet: int = app.progress.coins
	for visit in range(2, 12):
		# Skip day 4 completely; an early-morning visit counts for day 5.
		var day := visit + 3
		set_market_day_time(day + 1 if visit == 2 else day, 60 if visit == 2 else 1200)
		app.open_dice_house()
		match visit:
			2:
				expected_line = dice.say.talk
			4:
				expected_line = dice.say.seen
				expected_trust += int(dice.numbers.seen_trust)
			10:
				expected_line = dice.say.gambler
				expected_trust += int(dice.numbers.gambler_trust)
		check(app.dice_house.nights == visit and app.progress.trust == expected_trust and app.progress.coins == visit_wallet, "night %d counts a visit and applies the threshold penalty once" % visit)
		app.leave_dice_house()
		app.open_dice_house()
		check(app.dice_house.nights == visit and app.progress.trust == expected_trust, "reentry on night %d cannot repeat a penalty" % visit)
		app.leave_dice_house()
		var lines := [expected_line]
		if visit >= int(dice.numbers.seen_from_visits):
			lines.append(app.idris_recovery.data.say.cool)
		check(app.ui.reputation_lines() == lines, "night %d contributes the highest locked dice line, then Idris when cool" % visit)
		if visit in [2, 4, 10]:
			await press_button(app.chapter.purse.morning.to_rep, "open What people say after %d nights" % visit)
			check(app.ui.screen == "reputation" and has_visible_label(app.ui, "“%s”" % expected_line[0]) and has_visible_label(app.ui, str(expected_line[1]).to_upper()) and has_visible_label(app.ui, app.chapter.rep.tone[str(int(expected_line[2]))]), "night %d renders the locked quote, source and tone" % visit)
			await press_button(app.chapter.rep.to_map, "return to the Inn to count another night")
	set_market_day_time(15, 600)
	app.progress.apply_trust(int(app.sealed_purse.data.numbers.offer_from_trust) - app.progress.trust)
	check(app.sealed_purse.accept() and app.sealed_purse.choose_coin(false) and app.sealed_purse.deliver(), "fixture adds the locked sealed-purse outcome")
	app.market_stall.fed_faris = true
	check(app.ui.reputation_lines() == [app.market_stall.data.say.fed, dice.say.gambler, app.idris_recovery.data.say.warm, app.sealed_purse.data.say.honest], "dice talk and Idris follow the market stall and precedes the sealed purse")


func check_qasims_jars_runtime() -> void:
	var locked := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/QASIMS_JARS/RECORD/qasims_jars_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/qasims_jars.json")
	var jars: Dictionary = app.qasims_jars.data
	check(not locked.is_empty() and locked == runtime, "Qasim's jars copy LOCK 12 byte for byte")
	check(jars == JSON.parse_string(runtime.get_string_from_utf8()), "the jars use the locked runtime data")
	app.set_process(false)
	reset_at_market_place("quay", 198)
	app.progress.apply_trust(45 - app.progress.trust)
	for slot: Array in [[3, 1169, false], [3, 1170, true], [3, 1439, true], [4, 0, true], [4, 284, true], [4, 285, false]]:
		set_market_day_time(slot[0], slot[1])
		check((find_button(app.ui, jars.quay_button) != null) == slot[2], "Qasim's boatman at day %d, minute %d" % [slot[0], slot[1]])
		if not slot[2]:
			app.show_qasims_offer()
			check(app.ui.screen == "market_map", "a direct request cannot open the offer during the day")

	set_market_day_time(3, 1170)
	move_market_fixture("inn")
	check(find_button(app.ui, jars.quay_button) == null, "the boatman button appears only at the Quay")
	app.show_qasims_offer()
	check(app.ui.screen == "market_map", "a direct request away from the Quay cannot open the offer")
	move_market_fixture("quay")
	app.show_screen("game")
	await press_button(jars.quay_button, "the Quay street bar opens the offer")
	check(app.ui.screen == "qasims_offer" and visible_text().contains(jars.offer.text), "Qasim's offer tells the player it is wine in the locked words")
	check(has_visible_label(app.ui, jars.offer.title) and has_visible_label(app.ui, str(jars.offer.kicker).to_upper()), "the offer uses the locked title and kicker")
	await press_button(jars.offer.no, "Walk away is a real button")
	check(app.ui.screen == "market_map" and app.current_place == "quay" and app.day == 3 and app.minute_of_day == 1170, "walking away returns to the Quay map without advancing time")
	check(app.qasims_jars.runs == 0 and app.ui.reputation_lines().is_empty(), "walking away adds no run or talk")
	check_wallet(45, 198, "walking away changes neither trust nor coins")
	await press_button(jars.quay_button, "walking away leaves the offer available that night")
	await press_button(jars.offer.carry, "Carry the jars is a real button")
	check(app.ui.screen == "qasims_done" and visible_text().contains(jars.done.text), "carrying opens the locked result story")
	check(has_visible_label(app.ui, jars.done.title) and has_visible_label(app.ui, str(jars.done.kicker).to_upper()), "the result uses the locked title and kicker")
	check(has_visible_label(app.ui, str(jars.done.runs).format({"n": 1}).to_upper()), "the result displays the first night's count")
	check(app.day == 3 and app.minute_of_day == 1170 and app.qasims_jars.runs == 1, "carrying marks one run without advancing the clock")
	check_wallet(45, 218, "the first run pays twenty coins and leaves trust unchanged")
	check(app.ui.reputation_lines().is_empty(), "one run creates no What people say line")
	app.answer_qasims_offer(true)
	await press_button(jars.done.to_map, "the result has a usable map button")
	check(app.ui.screen == "market_map" and app.current_place == "quay", "the result returns to the market map at the Quay")
	for slot: Array in [[3, 1439], [4, 0], [4, 284], [4, 285]]:
		set_market_day_time(slot[0], slot[1])
		check(find_button(app.ui, jars.quay_button) == null, "a run prevents another offer on the same evening or after midnight: %s" % [slot])
		app.show_qasims_offer()
		app.answer_qasims_offer(true)
		check(app.ui.screen == "market_map" and app.qasims_jars.runs == 1, "the finished run cannot be repeated by a direct action")
		check_wallet(45, 218, "rejected runs change neither trust nor coins")
	set_market_day_time(4, 1170)
	check(find_button(app.ui, jars.quay_button) != null, "the offer returns when the next night opens")
	await check_qasims_jars_talk(jars)
	reset_at_market_place("quay", 198)
	check(app.qasims_jars.runs == 0 and app.ui.reputation_lines().is_empty(), "a new playthrough clears the jar runs and talk")
	app.progress.apply_trust(3 - app.progress.trust)
	for day in range(3, 7):
		set_market_day_time(day, 1170)
		app.show_qasims_offer()
		app.answer_qasims_offer(true)
		app.leave_qasims_done()
	check(app.qasims_jars.runs == 4 and app.progress.trust == 0, "the fourth jar run clamps trust to zero")
	app.set_process(true)


func check_qasims_jars_talk(jars: Dictionary) -> void:
	var expected_trust := 45
	var expected_line: Array = []
	for run in range(2, 12):
		# Take run two just before dawn on day 5, then run three that evening.
		var day := run + 2
		var minute := 284 if run == 2 else 1200
		if run == 2:
			day += 1
		set_market_day_time(day, minute)
		app.show_qasims_offer()
		app.answer_qasims_offer(true)
		match run:
			2:
				expected_line = jars.say.talk
			4:
				expected_line = jars.say.seen
				expected_trust += int(jars.numbers.seen_trust)
			10:
				expected_line = jars.say.smuggler
				expected_trust += int(jars.numbers.smuggler_trust)
		check(app.ui.screen == "qasims_done" and app.qasims_jars.runs == run and app.dice_house.nights == 0, "jar run %d counts once and does not count toward dice" % run)
		check(app.day == day and app.minute_of_day == minute, "jar run %d leaves the clock unchanged" % run)
		check_wallet(expected_trust, 198 + int(jars.numbers.pay) * run, "jar run %d pays once and applies only its threshold penalty" % run)
		app.leave_qasims_done()
		var lines := [expected_line]
		if run >= int(jars.numbers.seen_from_runs):
			lines.append(app.idris_recovery.data.say.cool)
		check(find_button(app.ui, jars.quay_button) == null and app.ui.reputation_lines() == lines, "run %d removes the button and contributes the highest jars line, then Idris when cool" % run)
		if run in [2, 4, 10]:
			await press_button(app.chapter.purse.morning.to_rep, "open What people say after %d jar runs" % run)
			check(app.ui.screen == "reputation" and has_visible_label(app.ui, "“%s”" % expected_line[0]) and has_visible_label(app.ui, str(expected_line[1]).to_upper()) and has_visible_label(app.ui, app.chapter.rep.tone[str(int(expected_line[2]))]), "run %d renders the locked quote, source and tone" % run)
			await press_button(app.chapter.rep.to_map, "return to the Quay after checking the jars line")

	move_market_fixture("inn")
	var dice: Dictionary = app.dice_house.data
	await press_button(dice.inn_invite, "the dice invitation still works after jar runs")
	await press_button(dice.invite.go, "the invitation opens the dice house")
	app.leave_dice_house()
	set_market_day_time(14, 1200)
	await press_button(dice.inn_button, "a later night still opens the dice house")
	app.leave_dice_house()
	check(app.dice_house.nights == 2 and app.qasims_jars.runs == 11, "dice visits leave the jar run count unchanged")
	check_wallet(expected_trust, 198 + int(jars.numbers.pay) * 11, "the first two dice visits after jar runs leave trust and coins unchanged")
	set_market_day_time(15, 600)
	app.progress.apply_trust(int(app.sealed_purse.data.numbers.offer_from_trust) - app.progress.trust)
	check(app.sealed_purse.accept() and app.sealed_purse.choose_coin(false) and app.sealed_purse.deliver(), "fixture adds the sealed-purse reputation line")
	check(app.ui.reputation_lines() == [dice.say.talk, jars.say.smuggler, app.idris_recovery.data.say.warm, app.sealed_purse.data.say.honest], "the single jars line follows dice and precedes Idris and the sealed purse")


func check_jabirs_goats_runtime() -> void:
	var locked := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/JABIRS_GOATS/RECORD/jabirs_goats_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/jabirs_goats.json")
	var goats: Dictionary = app.jabirs_goats.data
	check(not locked.is_empty() and locked == runtime, "Jabir's goats copy LOCK 13 byte for byte")
	check(goats == JSON.parse_string(runtime.get_string_from_utf8()), "the goats use the locked runtime data")
	app.set_process(false)
	reset_at_market_place("gate", 198)
	app.progress.apply_trust(45 - app.progress.trust)
	for slot: Array in [[899, false], [900, true], [1079, true], [1080, false]]:
		set_market_day_time(3, slot[0])
		check((find_button(app.ui, goats.gate_button) != null) == slot[1], "Jabir's gate action at minute %d" % slot[0])
		if not slot[1]:
			app.show_jabirs_offer()
			check(app.ui.screen == "market_map", "the offer cannot open outside the afternoon window")
	set_market_day_time(3, 960)
	move_market_fixture("quay")
	check(find_button(app.ui, goats.gate_button) == null, "Jabir appears only at the Gate of Trust")
	app.show_jabirs_offer()
	check(app.ui.screen == "market_map", "the offer cannot open at the Quay")
	move_market_fixture("gate")
	app.show_screen("game")
	await press_button(goats.gate_button, "the Gate of Trust street bar opens the offer")
	check_jabirs_panel("jabirs_offer", goats.offer)
	var price := int(goats.numbers.price)
	var buy_caption := str(goats.offer.buy).format({"n": price})
	var buy_button: Button = find_button(app.ui, buy_caption)
	var tell_button: Button = find_button(app.ui, goats.offer.tell)
	var walk_button: Button = find_button(app.ui, goats.offer.no)
	if buy_button != null and tell_button != null and walk_button != null:
		check(buy_button.position.x < tell_button.position.x and tell_button.position.x < walk_button.position.x, "the offer lays out Buy, Tell Saeed and Walk away in locked order")
	else:
		check(false, "the affordable offer contains all three choices")
	await press_button(goats.offer.no, "Walk away is a real button")
	check(app.ui.screen == "market_map" and app.current_place == "gate" and app.day == 3 and app.minute_of_day == 960, "walking away returns to the Gate of Trust map without advancing time")
	check(app.jabirs_goats.deals == 0 and not app.jabirs_goats.told and app.ui.reputation_lines().is_empty(), "walking away adds no deal, report or talk")
	check_wallet(45, 198, "walking away changes neither trust nor coins")

	app.progress.coins = price - 1
	app.update_state()
	await press_button(goats.gate_button, "the offer remains available with too few coins")
	check(find_button(app.ui, buy_caption) == null and has_visible_label(app.ui, goats.offer.not_enough), "too few coins show the locked notice in place of Buy")
	check(find_button(app.ui, goats.offer.tell) != null and find_button(app.ui, goats.offer.no) != null, "Tell Saeed and Walk away stay available with too few coins")
	app.answer_jabirs_offer("buy")
	check_wallet(45, price - 1, "a direct buy request below the locked price cannot change the wallet or trust")
	check(app.jabirs_goats.deals == 0 and not app.jabirs_goats.told, "an unaffordable buy does not count or remove the offer")
	app.show_screen("market_map")
	app.progress.coins = 198
	app.update_state()
	await press_button(goats.gate_button, "walking away or being unable to buy leaves the offer available that day")
	await press_button(buy_caption, "Buy them for ten coins is a real button")
	check_jabirs_panel("jabirs_bought", goats.bought)
	check(has_visible_label(app.ui, str(goats.bought.deals).format({"n": 1}).to_upper()), "the result shows the first deal's count")
	check(app.jabirs_goats.deals == 1 and app.day == 3 and app.minute_of_day == 960, "buying counts one deal without advancing the calendar or clock")
	check_wallet(45, 218, "the first deal adds net twenty coins and leaves trust unchanged")
	check(app.ui.reputation_lines().is_empty(), "one deal adds no What people say line")
	await press_button(goats.bought.to_map, "the buy result has a usable map button")
	check(app.ui.screen == "market_map" and app.current_place == "gate", "the buy result returns to the gate map")
	set_market_day_time(3, 1079)
	check(find_button(app.ui, goats.gate_button) == null, "the action remains hidden for the rest of the calendar day")
	app.show_jabirs_offer()
	app.answer_jabirs_offer("buy")
	check(app.ui.screen == "market_map" and app.jabirs_goats.deals == 1, "a direct action cannot repeat a deal that day")
	check_wallet(45, 218, "a repeated deal request changes neither trust nor coins")
	await check_jabirs_goats_talk(goats)

	reset_at_market_place("gate", price)
	check(app.jabirs_goats.deals == 0 and not app.jabirs_goats.told and app.ui.reputation_lines().is_empty(), "a new playthrough clears deals, the report and the talk")
	app.progress.apply_trust(3 - app.progress.trust)
	for day in range(3, 7):
		set_market_day_time(day, 900)
		app.show_jabirs_offer()
		app.answer_jabirs_offer("buy")
		app.leave_jabirs_result(false)
	check(app.jabirs_goats.deals == 4 and app.progress.coins == price + 80 and app.progress.trust == 0, "the exact price can buy, and the fourth deal clamps trust to zero")
	app.progress.apply_trust(99 - app.progress.trust)
	set_market_day_time(7, 900)
	app.show_jabirs_offer()
	app.answer_jabirs_offer("tell")
	check(app.progress.trust == 100, "telling Saeed clamps trust to one hundred")
	await press_button(goats.told.to_map, "the Tell Saeed result has a usable direct map button")
	check(app.ui.screen == "market_map" and app.current_place == "gate", "the told result can return directly to the gate map")
	app.set_process(true)


func check_jabirs_panel(screen: String, copy: Dictionary) -> void:
	check(app.ui.screen == screen and visible_text().contains(copy.text), "the locked story appears in " + screen)
	check(has_visible_label(app.ui, copy.title) and has_visible_label(app.ui, str(copy.kicker).to_upper()), "the locked title and kicker appear in " + screen)


func check_jabirs_goats_talk(goats: Dictionary) -> void:
	var expected_trust := 45
	var expected_line: Array = []
	for deal in range(2, 12):
		var day := deal + 2
		set_market_day_time(day, 900)
		check(find_button(app.ui, goats.gate_button) != null, "Jabir returns on the next calendar day: %d" % day)
		app.show_jabirs_offer()
		app.answer_jabirs_offer("buy")
		match deal:
			2:
				expected_line = goats.say.talk
			4:
				expected_line = goats.say.seen
				expected_trust += int(goats.numbers.seen_trust)
			10:
				expected_line = goats.say.fence
				expected_trust += int(goats.numbers.fence_trust)
		check(app.ui.screen == "jabirs_bought" and app.jabirs_goats.deals == deal, "deal %d is counted once" % deal)
		check(app.dice_house.nights == 0 and app.qasims_jars.runs == 0, "deal %d does not count as a dice visit or a jar run" % deal)
		check_wallet(expected_trust, 198 + 20 * deal, "deal %d pays once and applies only its threshold penalty" % deal)
		app.leave_jabirs_result(false)
		var lines := [expected_line]
		if deal >= int(goats.numbers.seen_from_deals):
			lines.append(app.idris_recovery.data.say.cool)
		check(app.ui.reputation_lines() == lines, "deal %d shows the highest goat line, then Idris when cool" % deal)
		if deal in [2, 4, 10]:
			await press_button(app.chapter.purse.morning.to_rep, "open What people say after %d goat deals" % deal)
			check_reputation_row(expected_line)
			await press_button(app.chapter.rep.to_map, "return to the gate after checking the goats line")

	var dice: Dictionary = app.dice_house.data
	var jars: Dictionary = app.qasims_jars.data
	for day in [14, 15]:
		set_market_day_time(day, 1200)
		check(app.dice_house.enter() and app.qasims_jars.carry(), "dice and jars still count an evening after goat deals")
	app.update_state()
	check(app.dice_house.nights == 2 and app.qasims_jars.runs == 2 and app.jabirs_goats.deals == 11, "the two evening activities leave the goat deal count unchanged")
	check_wallet(expected_trust, 418 + 2 * int(jars.numbers.pay), "night activities preserve goat trust thresholds and pay only the two jar fees")
	set_market_day_time(16, 960)
	await press_button(goats.gate_button, "Jabir returns before Saeed has been told")
	await press_button(goats.offer.tell, "Tell Saeed is a real button")
	check_jabirs_panel("jabirs_told", goats.told)
	check(app.jabirs_goats.told and app.jabirs_goats.deals == 11, "telling Saeed keeps prior deals and ends future offers")
	var told_trust := expected_trust + int(goats.numbers.tell_trust)
	var told_coins := 418 + 2 * int(jars.numbers.pay)
	check_wallet(told_trust, told_coins, "telling Saeed adds three trust without changing coins")
	app.answer_jabirs_offer("tell")
	await press_button(goats.told.to_rep, "the Tell Saeed result opens What people say")
	check_reputation_row(goats.say.fence)
	check_reputation_row(goats.say.told)
	check(app.ui.reputation_lines() == [dice.say.talk, jars.say.talk, goats.say.fence, goats.say.told, app.idris_recovery.data.say.cool], "both goat lines follow jars and precede Idris, with the deal before the report")
	await press_button(app.chapter.rep.to_map, "return to the gate after telling Saeed")
	for day in [16, 17, 30]:
		set_market_day_time(day, 960)
		check(find_button(app.ui, goats.gate_button) == null, "the gate action remains gone after reporting: day %d" % day)
		app.show_jabirs_offer()
		app.answer_jabirs_offer("tell")
		check(app.ui.screen == "market_map" and app.jabirs_goats.deals == 11, "the reported offer cannot be reopened on day %d" % day)
		check_wallet(told_trust, told_coins, "the report's trust reward cannot be collected again")
	app.progress.apply_trust(int(app.sealed_purse.data.numbers.offer_from_trust) - app.progress.trust)
	check(app.sealed_purse.accept() and app.sealed_purse.choose_coin(false) and app.sealed_purse.deliver(), "fixture adds the following sealed-purse line")
	check(app.ui.reputation_lines() == [dice.say.talk, jars.say.talk, goats.say.fence, goats.say.told, app.idris_recovery.data.say.warm, app.sealed_purse.data.say.honest], "the goat lines precede Idris and the sealed-purse outcome in What people say")


func check_reputation_row(line: Array) -> void:
	check(app.ui.screen == "reputation" and has_visible_label(app.ui, "“%s”" % line[0]) and has_visible_label(app.ui, str(line[1]).to_upper()) and has_visible_label(app.ui, app.chapter.rep.tone[str(int(line[2]))]), "What people say renders the locked quote, source and tone: " + str(line[0]))


func check_idris_recovery() -> void:
	var runtime := FileAccess.get_file_as_bytes("res://data/idris_has_heard.json")
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/IDRIS_HAS_HEARD/RECORD/idris_has_heard_data_V1.json")
	check(not runtime.is_empty() and runtime == approved, "Idris runtime is the byte-identical LOCK 14 V1 file")
	app.set_process(false)
	check_idris_hits("dice night", app.dice_house.enter, 1200)
	check_idris_hits("jar run", app.qasims_jars.carry, 1200)
	check_idris_hits("goat deal", app.jabirs_goats.buy, 900)
	check_idris_cap()
	await check_idris_refusal_and_prayer()
	app.begin_game()
	check(not app.idris_recovery.cool and app.idris_recovery.reputation_line() == null, "starting over clears Idris's cool point and reputation")
	app.set_process(true)


func check_idris_hits(activity: String, take_temptation: Callable, minute: int) -> void:
	app.begin_game()
	app.progress.coins = 198
	var recovery = app.idris_recovery
	var copy: Dictionary = recovery.data
	check(recovery.reputation_line() == null, "Idris has no reputation line before " + activity)
	for count in range(1, 11):
		set_market_day_time(count + 2, minute)
		check(take_temptation.call(), "%s %d is a valid temptation" % [activity, count])
		if count in [4, 10]:
			var post_hit: int = app.progress.trust
			check(recovery.cool and recovery.cool_point == post_hit, "%s %d cools at its post-hit trust" % [activity, count])
			check(recovery.reputation_line() == copy.say.cool, "%s %d sets the cool reputation line" % [activity, count])
			app.progress.apply_trust(int(copy.numbers.warm_gain) - 1)
			take_temptation.call()
			check(recovery.cool and recovery.cool_point == post_hit and app.progress.trust == post_hit + 9, "%s %d cannot hit or reset twice on the same day" % [activity, count])
			app.progress.apply_trust(1)
			check(not recovery.cool and recovery.reputation_line() == copy.say.warm, "%s %d warms at exactly ten net trust" % [activity, count])
		else:
			check(not recovery.cool, "%s %d without a hit cannot make a warm Idris cool" % [activity, count])


func cool_idris_with_dice(start_trust: int) -> void:
	reset_at_market_place("inn", 198)
	app.progress.apply_trust(start_trust - app.progress.trust)
	for day in range(3, 7):
		set_market_day_time(day, 1200)
		check(app.dice_house.enter(), "fixture visits the dice house on day %d" % day)


func check_idris_cap() -> void:
	cool_idris_with_dice(100)
	var recovery = app.idris_recovery
	check(recovery.cool and app.progress.trust == 95 and recovery.cool_point == 95, "the hit takes 100 to 95 and cools at 95")
	set_market_day_time(7, 600)
	check(app.progress.do_daily_job() and app.progress.trust == 100 and recovery.cool, "the first real +5 reaches displayed 100 and leaves Idris cool")
	set_market_day_time(8, 600)
	check(app.progress.do_daily_job() and app.progress.trust == 100 and not recovery.cool, "the second real +5 warms Idris while the display stays at 100")
	app.update_state()
	check(has_visible_label(app.ui, data.ui.hud.trust_value.format({"n": 100})), "the HUD displays capped trust after Idris warms")

	cool_idris_with_dice(100)
	app.progress.apply_trust(7)
	check(app.progress.trust == 100 and recovery.cool, "overflow is private and a gain of seven is short of warming")
	set_market_day_time(7, 1200)
	check(app.qasims_jars.carry() and recovery.cool_point == 102, "a new temptation at the cap resets the cool point to the full tally")
	app.progress.apply_trust(5)
	check(app.progress.trust == 100 and recovery.cool, "five fresh points at the reset cap leave Idris cool")
	app.progress.apply_trust(-3)
	app.progress.apply_trust(7)
	check(recovery.cool and recovery.cool_point == 102, "losses count in full and nine fresh net points leave Idris cool")
	app.progress.apply_trust(1)
	check(app.progress.trust == 100 and not recovery.cool, "the reset at 100 takes exactly ten fresh net points")


func check_idris_refusal_and_prayer() -> void:
	cool_idris_with_dice(45)
	set_market_day_time(7, 600)
	var copy: Dictionary = app.idris_recovery.data
	var chapter: Dictionary = app.chapter
	var take_page: String = str(chapter.purse.take_page).format({"teacher": chapter.teacher})
	await press_button(chapter.places.inn, "the open purse remains available while Idris is cool")
	await press_button(chapter.purse.ask_baker, "Salma still shows the page while Idris is cool")
	await press_button(take_page, "Salma's page route reaches the cool Idris")
	check(app.ui.screen == "purse_refused" and visible_text().contains(copy.page_refused.text), "the refusal uses the locked copy")
	check(not app.open_purse.page_read and not app.known_words.has("sirr") and not app.open_purse.give("father", true), "refusal gives no page, no word and no secret giving")
	await press_button(copy.page_refused.to_map, "refusal returns to the market map")
	check(app.ui.screen == "market_map" and app.current_place == "inn" and not app.open_purse.done, "the refusal leaves the purse at the Inn")
	await press_button(chapter.places.inn, "the player can revisit the open purse")
	check(find_button(app.ui, chapter.purse.give_secret) == null, "no secret buttons appear after refusal")
	await press_button(take_page, "the door list also checks whether Idris is cool")
	check(app.ui.screen == "purse_refused", "the door list refuses the unread page while Idris is cool")
	await press_button(copy.page_refused.to_map, "the second refusal also returns to the map")

	await check_cool_prayers(copy.masjid_line)
	app.progress.apply_trust(int(copy.numbers.warm_gain))
	app.update_state()
	check(not app.idris_recovery.cool and not has_visible_label(app.ui, copy.masjid_line), "warming removes the cool line from the Masjid bar")
	move_market_fixture("inn")
	await press_button(chapter.places.inn, "the player returns to the waiting purse")
	await press_button(take_page, "the previously refused page opens after warming")
	check(app.ui.screen == "purse_page" and app.open_purse.page_read and app.known_words.has("sirr"), "warming restores reading and learning the word")
	await press_button(chapter.page.back, "the player returns from the read page")
	check(find_button(app.ui, chapter.purse.give_secret) != null, "reading after warming unlocks secret giving")
	for day in range(11, 17):
		set_market_day_time(day, 1200)
		app.dice_house.enter()
	check(app.idris_recovery.cool and app.open_purse.page_read and app.known_words.has("sirr"), "a new hit cools again while preserving the page and word already learned")
	check(app.open_purse.give("father", true), "cooling again preserves secret giving already unlocked")


func check_cool_prayers(cool_line: String) -> void:
	move_market_fixture("masjid")
	var prayer_data: Dictionary = identity.clock
	var wallet := Vector2i(app.progress.coins, app.progress.trust)
	check(has_visible_label(app.ui, cool_line), "the Masjid bar shows the locked cool line")
	set_market_day_time(7, 13 * 60 + 5)
	await press_button(prayer_data.pray_here.format({"prayer": "Dhuhr"}), "Dhuhr alone at the Masjid remains available while cool")
	check(app.clock.record().rows[1].status == "alone", "solo Dhuhr is recorded as before")
	for index in range(prayer_data.prayers.size()):
		var prayer: Dictionary = prayer_data.prayers[index]
		var time: PackedStringArray = str(prayer.begins).split(":")
		set_market_day_time(8, int(time[0]) * 60 + int(time[1]))
		await press_button(prayer_data.pray_congregation, "%s congregation stays available while cool" % prayer.name)
		check(app.clock.record().rows[index].status == "jamaah", "%s congregation is recorded while cool" % prayer.name)
	app.clock.reset()
	app.clock.skip_to(9, 4 * 60 + 45)
	app.clock.advance_to(9, 12 * 60 + 8, false)
	app.update_state()
	await press_button(prayer_data.pray_friday, "Friday prayer stays available while cool")
	check(app.clock.record().rows[1].status == "jamaah" and app.clock.totals().friday == 1, "Friday prayer is recorded as before")
	await press_button(prayer_data.make_up.format({"prayer": "Fajr"}), "the Masjid bar keeps the make-up button while cool")
	check(app.clock.record().rows[0].status == "madeup", "make-up is recorded as before")
	move_market_fixture("inn")
	set_market_day_time(10, 13 * 60 + 5)
	check(not has_visible_label(app.ui, cool_line), "the cool line only appears at the Masjid")
	await press_button(prayer_data.pray_here.format({"prayer": "Dhuhr"}), "prayer away from the Masjid stays available while cool")
	check(app.clock.record().rows[1].status == "alone", "Dhuhr away from the Masjid is recorded as before")
	move_market_fixture("masjid")
	check(app.idris_recovery.cool and Vector2i(app.progress.coins, app.progress.trust) == wallet, "prayers preserve Idris's state and the wallet")


func check_dry_fountain_runtime() -> void:
	var locked := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/DRY_FOUNTAIN/RECORD/dry_fountain_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/dry_fountain.json")
	var fountain: Dictionary = app.dry_fountain.data
	check(not locked.is_empty() and locked == runtime, "the dry fountain copies LOCK 15 byte for byte")
	check(fountain == JSON.parse_string(runtime.get_string_from_utf8()), "the dry fountain uses the locked runtime data")
	app.set_process(false)
	await check_named_fountain(fountain)
	await check_secret_fountain(fountain)
	reset_at_market_place("board", 198)
	check(app.dry_fountain.paid == 0 and not app.dry_fountain.is_running() and app.ui.reputation_lines().is_empty(), "a new playthrough resets the fountain and its reputation")
	app.set_process(true)


func check_named_fountain(fountain: Dictionary) -> void:
	var panel: Dictionary = fountain.panel
	var done: Dictionary = fountain.done
	var part := int(fountain.numbers.part)
	var cost := int(fountain.numbers.cost)
	var public_trust := int(fountain.numbers.public_trust)
	var pay_named := str(panel.give_named).format({"n": part})
	var pay_secret := str(panel.give_secret).format({"n": part})
	var pay_more := str(panel.give).format({"n": part})
	reset_at_market_place("board", 198)
	app.progress.apply_trust(45 - app.progress.trust)
	app.update_state()
	var repair := find_button(app.ui, fountain.board_button)
	var feed := find_button(app.ui, app.feeding.data.place_button)
	check(repair != null and feed != null and repair.global_position.x < feed.global_position.x, "the square bar places the fountain before feeding")
	await press_button(fountain.board_button, "the square opens the dry fountain panel")
	check(app.ui.screen == "dry_fountain" and visible_text().contains(panel.text), "the dry fountain opens with the locked introduction")
	check(has_visible_label(app.ui, panel.title) and visible_text().to_lower().contains(str(panel.kicker).to_lower()), "the dry fountain shows the locked title and kicker")
	check(visible_text().to_lower().contains(str(panel.paid).format({"n": 0}).to_lower()), "the first panel displays zero paid")
	check(find_button(app.ui, pay_secret) != null and find_button(app.ui, pay_more) == null, "the first payment offers both name choices")
	check(not app.dry_fountain.pay(""), "a first payment must choose name or no name")
	await press_button(pay_named, "the named payment is a usable button")
	check_wallet(45, 198 - part, "the first payment costs one part and leaves trust unchanged")
	check(app.dry_fountain.paid == part and app.dry_fountain.named and not app.dry_fountain.is_running(), "the first payment fixes the name choice without completing the fountain")
	check(visible_text().to_lower().contains(str(panel.paid).format({"n": part}).to_lower()), "the panel displays the first payment total")
	check(find_button(app.ui, pay_named) == null and find_button(app.ui, pay_secret) == null, "the first payment removes both name choices")
	check(not app.dry_fountain.pay("secret") and app.dry_fountain.paid == part and app.dry_fountain.named, "a later payment cannot switch to no name")
	await press_button(panel.not_now, "Not now returns to the square map")
	check(app.ui.screen == "market_map" and app.current_place == "board", "leaving the panel keeps the square selected")
	set_market_day_time(4, 1200)
	await press_button(fountain.board_button, "the fountain is available at night with the earlier payment saved")
	await press_button(pay_more, "the second payment uses the single continuation button")
	check_wallet(45, 198 - part * 2, "the second payment costs one part and leaves trust unchanged")
	check(app.dry_fountain.paid == part * 2 and app.dry_fountain.reputation_line() == null, "a partial payment has no reputation reward")
	set_market_day_time(5, 600)
	await press_button(pay_more, "the third payment completes the fountain")
	check_wallet(45 + public_trust, 198 - cost, "named completion charges the final part and awards trust once")
	check(app.ui.screen == "fountain_done" and app.dry_fountain.paid == cost and app.dry_fountain.is_running(), "the fountain starts at the full cost")
	check(app.dry_fountain.finished_day == 5 and app.dry_fountain.days_running() == 0, "the running count starts at zero on the finishing day")
	check(visible_text().contains(done.text) and visible_text().contains(done.named) and not visible_text().contains(done.secret), "the completion panel displays the story and the named outcome")
	check(visible_text().to_lower().contains(str(done.count).format({"n": 1}).to_lower()), "the completion panel counts one repaired fountain")
	check(not app.dry_fountain.pay("") and not app.dry_fountain.pay("named"), "the repaired fountain refuses further payments")
	check_wallet(45 + public_trust, 198 - cost, "repeat attempts change neither coins nor trust")
	await press_button(done.to_rep, "the named completion opens What people say")
	check_reputation_row(fountain.say.named)
	check(app.ui.reputation_lines() == [fountain.say.named], "named completion adds exactly one fountain line")
	await press_button(app.chapter.rep.to_map, "What people say returns to the market map")
	check(has_visible_label(app.ui, str(fountain.running).format({"n": 0})), "the square displays zero days on completion day")
	set_market_day_time(8, 600)
	check(has_visible_label(app.ui, str(fountain.running).format({"n": 3})), "the square counts three days from completion")
	check(find_button(app.ui, fountain.board_button) == null, "the payment button stays gone on later days")
	app.show_screen("game")
	check(find_button(app.ui, fountain.board_button) == null and has_visible_label(app.ui, str(fountain.running).format({"n": 3})), "the street bar also shows the running status in place of the button")
	move_market_fixture("gate")
	for day in range(8, 12):
		set_market_day_time(day, 960)
		check(app.jabirs_goats.buy(), "fixture adds a goat deal on day %d" % day)
	set_market_day_time(12, 960)
	check(app.jabirs_goats.tell_saeed(), "fixture adds the goat report")
	check(app.ui.reputation_lines() == [app.jabirs_goats.data.say.seen, app.jabirs_goats.data.say.told, fountain.say.named, app.idris_recovery.data.say.cool], "the fountain line follows both goat lines and precedes Idris")


func check_secret_fountain(fountain: Dictionary) -> void:
	var panel: Dictionary = fountain.panel
	var done: Dictionary = fountain.done
	var part := int(fountain.numbers.part)
	var cost := int(fountain.numbers.cost)
	var pay_named := str(panel.give_named).format({"n": part})
	var pay_secret := str(panel.give_secret).format({"n": part})
	var pay_more := str(panel.give).format({"n": part})
	reset_at_market_place("board", part - 1)
	var trust: int = app.progress.trust
	await press_button(fountain.board_button, "the fountain panel opens with an insufficient balance")
	check(has_visible_label(app.ui, panel.not_enough) and find_button(app.ui, pay_named) == null and find_button(app.ui, pay_secret) == null, "an unaffordable first payment replaces both choices with the locked status")
	check(not app.dry_fountain.pay("named") and not app.dry_fountain.pay("secret") and app.dry_fountain.paid == 0, "an unaffordable attempt neither pays nor fixes the name choice")
	check_wallet(trust, part - 1, "an insufficient first payment preserves the wallet")
	app.progress.coins = cost
	app.update_state()
	await press_button(pay_secret, "no name is a usable first-payment button")
	check_wallet(trust, cost - part, "the first secret payment charges one part")
	check(not app.dry_fountain.pay("named") and not app.dry_fountain.named and app.dry_fountain.paid == part, "the unnamed choice cannot switch to named")
	app.progress.coins = part - 1
	app.update_state()
	check(has_visible_label(app.ui, panel.not_enough) and find_button(app.ui, pay_more) == null, "the partially paid panel also blocks an unaffordable payment")
	check(not app.dry_fountain.pay("") and app.dry_fountain.paid == part, "an unaffordable continuation keeps the earlier payment")
	check_wallet(trust, part - 1, "an insufficient continuation preserves the wallet")
	app.progress.coins = cost - part
	app.update_state()
	await press_button(pay_more, "continue a secret repair with the same payment control")
	check_wallet(trust, part, "the second secret payment charges one part")
	await press_button(pay_more, "the exact remaining balance completes the repair")
	check_wallet(trust, 0, "secret completion charges the final part without awarding trust")
	check(app.ui.screen == "fountain_done" and app.dry_fountain.is_running() and app.dry_fountain.paid == cost, "secret completion repairs the fountain at the full cost")
	check(visible_text().contains(done.secret) and not visible_text().contains(done.named), "the completion panel uses the secret outcome")
	await press_button(done.to_rep, "the secret completion also opens What people say")
	check(app.ui.screen == "reputation" and app.ui.reputation_lines().is_empty() and visible_text().contains(app.chapter.rep.empty), "secret completion leaves the empty reputation panel")


func check_rashids_loan_runtime() -> void:
	var locked := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/RASHIDS_LOAN/RECORD/rashids_loan_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/rashids_loan.json")
	var loan: Dictionary = app.rashids_loan.data
	check(not locked.is_empty() and locked == runtime, "the loan copies LOCK 16 byte for byte")
	check(loan == JSON.parse_string(runtime.get_string_from_utf8()), "the loan reads the approved runtime data")

	await check_loan_offer_and_refusal(loan)
	for choice in ["wait", "forgive", "demand"]:
		await check_loan_repayment(loan, choice)
	app.begin_game()
	check(app.rashids_loan.reputation_line() == null, "starting over clears the loan outcome")


func check_loan_offer_and_refusal(loan: Dictionary) -> void:
	var amounts := {"n": int(loan.numbers.loan), "m": int(loan.numbers.ask_back)}
	var lend := str(loan.ask.lend).format(amounts)
	var interest := str(loan.ask.lend_more).format(amounts)
	reset_at_market_place("spice", amounts.n - 1)
	var trust := int(loan.numbers.min_trust)
	app.progress.apply_trust(trust - 1 - app.progress.trust)
	app.update_state()
	check(find_button(app.ui, loan.ask_button) == null, "Rashid does not ask below the trust threshold")
	app.show_rashids_loan()
	check(app.ui.screen == "market_map", "the low-trust loan cannot be opened directly")
	app.progress.apply_trust(1)
	for time in [[8, 1200], [9, 725], [9, 759]]:
		set_market_day_time(time[0], time[1])
		check(find_button(app.ui, loan.ask_button) == null, "Rashid does not ask when his stall is closed: %s" % [time])
		app.show_rashids_loan()
		check(app.ui.screen == "market_map", "the closed-stall loan cannot be opened directly")
	set_market_day_time(9, 760)
	check(find_button(app.ui, loan.ask_button) != null, "Rashid asks at exactly the trust threshold after Friday prayer")
	move_market_fixture("board")
	app.show_rashids_loan()
	check(app.ui.screen == "market_map" and find_button(app.ui, loan.ask_button) == null, "the loan is specific to the spice row")
	move_market_fixture("spice")
	var shop := find_button(app.ui, app.market_stall.data.place.spice_button)
	var ask := find_button(app.ui, loan.ask_button)
	var talk := find_button(app.ui, app.talking.button_at("spice"))
	check(shop != null and ask != null and talk != null and shop.get_global_rect().end.x <= ask.global_position.x and ask.get_global_rect().end.x <= talk.global_position.x, "the ask fits between shopping and talking")
	await press_button(loan.ask_button, "the spice row opens the loan ask")
	check(app.ui.screen == "loan_ask" and visible_text().contains(loan.ask.text), "the ask shows the approved wording")
	check(has_visible_label(app.ui, loan.ask.not_enough), "a wallet below 30 shows the locked message")
	check(find_button(app.ui, lend) == null and find_button(app.ui, interest) == null, "both loan amounts are unavailable when unaffordable")
	app.answer_rashids_loan("lend")
	app.answer_rashids_loan("lend_more")
	check_wallet(trust, amounts.n - 1, "unaffordable attempts cannot move coins or trust")
	await press_button(loan.ask.no, "declining the ask returns to the map")
	check(app.ui.screen == "market_map" and find_button(app.ui, loan.ask_button) != null, "declining leaves the ask open")

	app.progress.coins = amounts.n
	app.update_state()
	await press_button(loan.ask_button, "the ask can be reopened")
	check(find_button(app.ui, lend) != null, "the exact loan amount is sufficient")
	await press_button(interest, "asking 36 for 30 opens the refusal")
	check(app.ui.screen == "loan_riba" and visible_text().contains(loan.riba.text), "the refusal shows the locked reply")
	check_wallet(trust + int(loan.numbers.riba_trust), amounts.n, "riba changes trust by −5 and moves no coins")
	check(not app.idris_recovery.cool, "the refusal does not add a LOCK 14 temptation trigger")
	await press_button(loan.riba.to_rep, "the refusal links to What people say")
	check_reputation_row(loan.say.riba)
	check(app.ui.reputation_lines() == [loan.say.riba], "the refusal adds one reputation line")
	await press_button(app.chapter.rep.to_map, "return to the spice row after the refusal")
	app.progress.apply_trust(45 - app.progress.trust)
	set_market_day_time(15, 600)
	check(find_button(app.ui, loan.ask_button) == null and find_button(app.ui, loan.pay_button) == null, "refusal ends the loan even after trust recovers")


func check_loan_repayment(loan: Dictionary, choice: String) -> void:
	const START_COINS := 198
	const START_TRUST := 45
	const LENDING_DAY := 8
	var principal := int(loan.numbers.loan)
	var first_pay := int(loan.numbers.first_pay)
	var due_day := LENDING_DAY + int(loan.numbers.due_days)
	var due_visit := due_day + 1
	var trust := START_TRUST + int(loan.numbers[choice + "_trust"])
	var lent_coins := START_COINS - principal
	var coins := lent_coins + (principal if choice == "demand" else first_pay)
	var owed_full := str(loan.owed).format({"n": principal})
	var owed_rest := str(loan.owed).format({"n": principal - first_pay})
	reset_at_market_place("spice", START_COINS)
	app.progress.apply_trust(START_TRUST - app.progress.trust)
	set_market_day_time(LENDING_DAY, 600)
	await press_button(loan.ask_button, "open a fresh ask for " + choice)
	await press_button(str(loan.ask.lend).format({"n": principal}), "lend 30 without increase")
	check(app.ui.screen == "loan_lent" and visible_text().contains(loan.lent.text), "the loan uses the locked acceptance")
	check_wallet(START_TRUST, lent_coins, "lending costs exactly 30 and leaves trust unchanged")
	check(app.ui.reputation_lines().is_empty(), "lending alone adds no reputation line")
	await press_button(loan.lent.to_map, "return to the spice row after lending")
	check(has_visible_label(app.ui, owed_full), "the spice row shows a 30-coin balance")
	set_market_day_time(LENDING_DAY + 1, 725)
	check(not has_visible_label(app.ui, owed_full), "Rashid shows no balance while away at Friday prayer")
	set_market_day_time(due_day - 1, 1000)
	check(has_visible_label(app.ui, owed_full) and find_button(app.ui, loan.pay_button) == null, "the balance stays due later on calendar day two")
	app.show_rashids_loan()
	check(app.ui.screen == "market_map", "the balance cannot be collected early")
	set_market_day_time(due_day, 480)
	check(find_button(app.ui, loan.pay_button) != null, "day three unlocks collection even before the lending time of day")
	set_market_day_time(due_visit, 600)
	await press_button(loan.pay_button, "open the repayment panel a day after it became due")
	check(app.ui.screen == "loan_due" and visible_text().contains(loan.due.text), "the due panel shows the locked offer")
	check(find_button(app.ui, loan.due.wait) != null and find_button(app.ui, loan.due.forgive) != null and find_button(app.ui, loan.due.demand) != null, "the three repayment options are offered together")
	await press_button(loan.due[choice], "choose " + choice)
	check(app.ui.screen == "loan_after" and has_visible_label(app.ui, loan.due.title) and visible_text().contains(loan.after[choice]), "the choice keeps the due title and shows its locked result")
	check_wallet(trust, coins, "the repayment applies the locked coin and trust changes")
	app.answer_rashids_loan(choice)
	check_wallet(trust, coins, "the repayment cannot be applied twice")
	await press_button(loan.after.to_rep, "the result opens What people say")
	check_reputation_row(loan.say[choice])
	check(app.ui.reputation_lines() == [loan.say[choice]], "there is one reputation line for " + choice)
	await press_button(app.chapter.rep.to_map, "return to the spice row from reputation")
	if choice == "wait":
		check(has_visible_label(app.ui, owed_rest), "the spice row now shows a 10-coin balance")
		var last_day := due_visit + int(loan.numbers.more_days)
		set_market_day_time(last_day - 1, 600)
		check(has_visible_label(app.ui, owed_rest) and find_button(app.ui, loan.pay_button) == null, "six days after the actual due visit is still too early")
		set_market_day_time(last_day, 600)
		await press_button(loan.pay_button, "collect the last ten after seven days from the due visit")
		check(app.ui.screen == "loan_last" and visible_text().contains(loan.last.text), "the last payment shows the locked story")
		coins = START_COINS
		check_wallet(trust, coins, "the final ten restore principal without another trust change")
		await press_button(loan.last.to_rep, "the last payment links to reputation")
		check(app.ui.reputation_lines() == [loan.say.wait], "collecting the last ten keeps the original line")
		await press_button(app.chapter.rep.to_map, "return to the map after collecting the final ten")
	check(find_button(app.ui, loan.ask_button) == null and find_button(app.ui, loan.pay_button) == null and not has_visible_label(app.ui, owed_rest), "repaid loans leave no bar action or balance")
	app.show_rashids_loan()
	check_wallet(trust, coins, "a closed loan cannot be collected again")
	if choice == "demand":
		for payment in ["named", "", ""]:
			check(app.dry_fountain.pay(payment), "fixture adds the earlier named fountain line")
		for night in range(20, 24):
			set_market_day_time(night, 1200)
			check(app.dice_house.enter(), "fixture adds the later Idris line")
		var lines: Array = app.ui.reputation_lines()
		check(lines.count(loan.say.demand) == 1 and lines.find(app.dry_fountain.data.say.named) + 1 == lines.find(loan.say.demand) and lines.find(loan.say.demand) + 1 == lines.find(app.idris_recovery.data.say.cool), "the loan line appears directly between the fountain and Idris")


func check_harm_in_the_road_runtime() -> void:
	var locked := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/HARM_IN_THE_ROAD/RECORD/harm_in_the_road_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/harm_in_the_road.json")
	var road: Dictionary = app.harm_in_the_road.data
	check(not locked.is_empty() and runtime == locked, "runtime harm data copies LOCK 17 byte for byte")
	check(road == JSON.parse_string(runtime.get_string_from_utf8()), "the road harm reads the approved runtime data")
	app.set_process(false)
	app.begin_game()
	var opens := int(road.numbers.from)
	var closes := int(road.numbers.until)
	for day_index in range(road.places.size() * road.harms.size() + 1):
		var place: String = road.places[day_index % road.places.size()]
		var harm: Dictionary = road.harms[day_index % road.harms.size()]
		app.clock.advance_to(day_index + 1, opens, false)
		move_market_fixture(place)
		check(has_visible_label(app.ui, harm.bar) and find_button(app.ui, harm.move) != null, "day index %d has the exact locked harm and action at its rotated place" % day_index)
		move_market_fixture(road.places[(day_index + 1) % road.places.size()])
		check(not visible_text().contains(harm.bar) and find_button(app.ui, harm.move) == null, "day index %d does not show the harm at another place" % day_index)
		app.move_road_harm()
		check(app.ui.screen == "market_map" and app.harm_in_the_road.count == 0 and app.minute_of_day == opens, "walking past or invoking the action elsewhere has no effect")

	var day: int = app.day + 1
	var place: String = road.places[(day - 1) % road.places.size()]
	var harm: Dictionary = road.harms[(day - 1) % road.harms.size()]
	set_market_day_time(day, opens - 1)
	move_market_fixture(place)
	check(not visible_text().contains(harm.bar) and find_button(app.ui, harm.move) == null, "harm is absent just before the daily opening")
	app.move_road_harm()
	check(app.harm_in_the_road.count == 0, "moving the harm before opening is rejected")
	app.clock.advance_to(day, opens, false)
	app.update_state()
	check(has_visible_label(app.ui, harm.bar) and find_button(app.ui, harm.move) != null, "the bar updates as the same place reaches opening")
	app.clock.advance_to(day, closes, false)
	app.update_state()
	check(not visible_text().contains(harm.bar) and find_button(app.ui, harm.move) == null, "the bar clears at the exclusive closing minute")
	app.move_road_harm()
	check(app.harm_in_the_road.count == 0, "moving the harm at closing is rejected")

	set_market_day_time(day, closes - 1)
	check(app.clock.record().rows[3].status == "now", "Maghrib is still available just before the late harm move")
	check(has_visible_label(app.ui, harm.bar) and find_button(app.ui, harm.move) != null, "the harm is visible at the final minute")
	app.show_screen("game")
	check(has_visible_label(app.ui, harm.bar) and find_button(app.ui, harm.move) != null, "the walking view also has the locked harm words and move button")
	var coins: int = app.progress.coins
	var trust: int = app.progress.trust
	var reputation: Array = app.ui.reputation_lines().duplicate(true)
	await press_button(harm.move, "moving harm uses the real place-bar button")
	check(app.ui.screen == "harm_done" and has_visible_label(app.ui, harm.move) and visible_text().contains(harm.done), "the result gives the locked harm title and story")
	var count_line: String = road.panel.count.format({"n": 1}).to_upper()
	check(has_visible_label(app.ui, road.panel.kicker.to_upper()) and has_visible_label(app.ui, count_line), "the result gives the locked kicker and private count")
	check(app.day == day and app.minute_of_day == closes - 1 + int(road.numbers.minutes) and app.harm_in_the_road.count == 1, "moving harm takes five minutes and adds exactly one to the count")
	check(app.clock.record().rows[3].status == "missed", "the normal advance marks the ended unprayed Maghrib as missed")
	check(app.progress.coins == coins and app.progress.trust == trust and app.ui.reputation_lines() == reputation, "moving harm has no reward or reputation effect")
	await press_button(road.panel.to_map, "the locked result button returns to the market map")
	check(app.ui.screen == "market_map" and not visible_text().contains(count_line), "the count is private to the result panel")
	set_market_day_time(day, closes - 2)
	app.move_road_harm()
	check(app.harm_in_the_road.count == 1 and find_button(app.ui, harm.move) == null and not visible_text().contains(harm.bar), "the harm stays gone at its place for the same day")

	app.clock.advance_to(day + 1, opens, false)
	move_market_fixture(road.places[day % road.places.size()])
	var next_harm: Dictionary = road.harms[day % road.harms.size()]
	await press_button(next_harm.move, "the next day has a fresh move button at its own place")
	check(app.harm_in_the_road.count == 2, "the private count accumulates across market days")
	app.begin_game()
	check(app.harm_in_the_road.count == 0 and app.harm_in_the_road.done_day == -1, "starting a new playthrough clears the private harm record")
	app.set_process(true)


func check_calendar_dates() -> void:
	var locked := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/CALENDAR/RECORD/calendar_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/calendar.json")
	check(not locked.is_empty() and locked == runtime, "the calendar copies LOCK 18 byte for byte")
	var calendar: RefCounted = app.clock.calendar
	check(calendar.data == JSON.parse_string(runtime.get_string_from_utf8()), "the calendar reads the locked runtime data")
	var expected := {
		-1: "Wednesday 30 Rajab", 0: "Thursday 1 Sha'ban", 28: "Thursday 29 Sha'ban",
		29: "Friday 1 Ramadan", 59: "Sunday 1 Shawwal", 127: "Friday 10 Dhu al-Hijjah",
		147: "Thursday 1 Muharram", 354: "Monday 1 Sha'ban",
	}
	for index: int in expected:
		check(app.clock.date_label(index + 1) == expected[index], "the calendar formats day %d" % index)

	var row_labels := ["Ramadan begins", "Eid al-Fitr", "The Day of Arafah", "Eid al-Adha", "Your zakat year ends"]
	var date_values := {
		0: ["1 Ramadan · in 29 days", "1 Shawwal · in 59 days", "9 Dhu al-Hijjah · in 126 days", "10 Dhu al-Hijjah · in 127 days", "1 Sha'ban · in 354 days"],
		29: ["today", "1 Shawwal · in 30 days", "9 Dhu al-Hijjah · in 97 days", "10 Dhu al-Hijjah · in 98 days", "1 Sha'ban · in 325 days"],
		127: ["1 Ramadan · in 256 days", "1 Shawwal · in 286 days", "9 Dhu al-Hijjah · in 353 days", "today", "1 Sha'ban · in 227 days"],
		354: ["1 Ramadan · in 29 days", "1 Shawwal · in 59 days", "9 Dhu al-Hijjah · in 126 days", "10 Dhu al-Hijjah · in 127 days", "today"],
	}
	for index: int in date_values:
		var rows: Array[Dictionary] = calendar.coming_dates(index)
		check(rows.map(func(row): return row.label) == row_labels, "coming dates keep the locked row order on day %d" % index)
		check(rows.map(func(row): return row.value) == date_values[index], "coming dates give the exact countdowns on day %d" % index)
	check(calendar.coming_dates(355)[4].value == "1 Sha'ban · in 353 days", "the zakat year starts counting again after its anniversary")
	check(calendar.coming_dates(708)[4].value == "today", "the second zakat anniversary also shows today")


func check_calendar_runtime() -> void:
	app.set_process(false)
	var copy: Dictionary = app.clock.calendar.data
	var panel: Dictionary = copy.panel
	var three := str(panel.rest).format({"n": 3, "c": 6})
	var seven := str(panel.rest).format({"n": 7, "c": 14})
	reset_at_market_place("quay", 198)
	check(find_button(app.ui, copy.inn_button) == null, "multi-day rest is offered only at the Inn")
	reset_at_market_place("inn", 198, 1)
	var before: Dictionary = app.clock.totals()
	var prepaid: int = app.paid_nights
	await press_button(copy.inn_button, "the Inn offers the locked rest-for-days button")
	check(app.ui.screen == "calendar" and has_visible_label(app.ui, panel.today.format({"w": "Thursday", "d": 1, "m": "Sha'ban"})), "the panel opens at the current Hijri date")
	check(has_visible_label(app.ui, "1 Sha'ban · in 354 days"), "the arrival panel shows a full year until zakat")
	await press_button(panel.not_now, "Not now closes the calendar")
	check(app.ui.screen == "market_map" and app.progress.coins == 198 and app.day == 1, "closing the panel leaves the player, coins and time at the Inn")
	await press_button(copy.inn_button, "the calendar can reopen")
	await press_button(three, "three days is a working six-coin option")
	check(app.day == 4 and app.minute_of_day == 280 and app.progress.coins == 192, "three days cost six coins and wake on day index 3 at 04:40")
	check(app.current_place == "inn" and app.ui.screen == "market_map" and app.paid_nights == prepaid, "rest returns to the Inn without consuming prepaid nights")
	check(has_visible_label(app.ui, "You rest for 3 days. You wake before Fajr on Sunday 4 Sha'ban."), "rest shows the locked dated toast")
	check(app.clock.totals() == before and app.clock.make_up_label().is_empty(), "rested prayers add no totals or make-up opportunities")
	check(app.clock.hud().prayer == "Isha now · 5 min left", "the Isha window ending after waking is still active")
	app.clock.advance_to(4, 285, false)
	check(app.clock.totals().missed == 1, "the Isha window is missed if it ends after waking without prayer")

	reset_at_market_place("inn", 10, 1)
	await press_button(copy.inn_button, "the calendar opens with a short purse")
	check(find_button(app.ui, three) != null and find_button(app.ui, seven) == null, "ten coins offer three days and block seven")
	check(has_visible_label(app.ui, panel.not_enough.format({"n": 7})), "the shortage uses locked copy")
	app.ui.calendar_rest_requested.emit(7)
	check(app.ui.screen == "calendar" and app.progress.coins == 10 and app.day == 1, "an unaffordable rest cannot charge coins or jump the clock")
	app.progress.coins = 5
	app.update_state()
	check(find_button(app.ui, three) == null and find_button(app.ui, seven) == null, "both options are blocked below six coins")
	check(has_visible_label(app.ui, panel.not_enough.format({"n": 3})), "three days also has its own shortage label")

	reset_at_market_place("inn", 198, 1)
	app.clock.advance_to(1, 12 * 60 + 5, false)
	app.clock.pray(false)
	app.clock.advance_to(1, 18 * 60 + 10, false)
	app.update_state()
	before = app.clock.totals()
	var make_up: String = app.clock.make_up_label()
	await press_button(copy.inn_button, "the calendar opens after earlier prayer activity")
	await press_button(seven, "seven days is a working fourteen-coin option")
	check(app.day == 8 and app.minute_of_day == 280 and app.progress.coins == 184, "seven days cost fourteen coins and wake on day index 7 at 04:40")
	check(before.on_time == 1 and before.missed == 1 and app.clock.totals() == before, "rest preserves completed or missed prayer windows already ended at its start")
	check(app.clock.make_up_label() == make_up and make_up == "Make up Asr", "rest preserves the earlier Asr make-up at the exact end of its window")

	var clock := PrayerClock.new(identity.clock, app.clock.calendar)
	clock.advance_to(1, 12 * 60 + 5, false)
	clock.pray(true)
	clock.skip_to(2, 6 * 60 + 5, true)
	check(clock.totals().on_time == 0 and clock.has_prayed_in_congregation(), "a completed window ending during the rest is excluded from totals while its prior congregation still counts for reputation")
	check(clock.record().rows[0].text == "04:45 · rested · not counted", "a window ending exactly at wake time shows the locked rested status in Today's prayers")
	check(clock.totals().missed == 0 and clock.make_up_label().is_empty(), "the exact wake boundary is excluded from totals and make-up")
	app.set_process(true)


func check_ramadan_runtime() -> void:
	app.set_process(false)
	var locked := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/RAMADAN/RECORD/ramadan_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/ramadan.json")
	var copy: Dictionary = app.ramadan.data
	check(not locked.is_empty() and runtime == locked, "runtime Ramadan data is byte-identical to LOCK 19")
	check(copy == JSON.parse_string(runtime.get_string_from_utf8()), "Ramadan reads the approved data")
	var fasting := "Fasting · iftar at 18:10"

	reset_at_market_place("inn", 198, 28)
	var prior_reputation: Array = app.ui.reputation_lines()
	stage_ramadan(29, 240, "inn")
	check(find_button(app.ui, copy.suhoor_button) == null, "suhoor is absent in Sha'ban")
	stage_ramadan(29, 600, "spice")
	check(not has_visible_label(app.ui, fasting), "fasting line is absent in Sha'ban")
	stage_ramadan(29, 1095, "masjid")
	check(find_button(app.ui, copy.iftar_button) == null, "iftar is absent in Sha'ban")
	stage_ramadan(29, 1200, "masjid")
	check(find_button(app.ui, copy.tarawih_button) == null, "tarawih is absent in Sha'ban")
	app.show_screen("all_prayers")
	check(not has_visible_label(app.ui, "RAMADAN") and app.ramadan.record().is_empty(), "private Ramadan section is absent before the month")

	stage_ramadan(30, 209, "inn")
	check(find_button(app.ui, copy.suhoor_button) == null, "suhoor is absent at 03:29")
	stage_ramadan(30, 210, "quay")
	check(find_button(app.ui, copy.suhoor_button) == null, "suhoor is absent away from the Inn at 03:30")
	move_market_fixture("inn")
	var coins: int = app.progress.coins
	var trust: int = app.progress.trust
	await press_button(copy.suhoor_button, "Eat suhoor is usable at 03:30 at the Inn")
	check(has_visible_label(app.ui, copy.suhoor_toast), "suhoor shows the exact locked toast")
	app.ui.ramadan_requested.emit(Ramadan.Action.SUHOOR)
	check(find_button(app.ui, copy.suhoor_button) == null and app.minute_of_day == 210, "suhoor disappears after one use without advancing the clock")
	check(app.ramadan.record() == {"fasted": 0, "suhoor": 1, "tarawih": 0}, "only one suhoor is counted before the first Fajr")
	stage_ramadan(30, 284, "inn")
	check(not has_visible_label(app.ui, fasting), "fasting line is absent at 04:44")
	app.clock.advance_to(30, 285, false)
	app.update_state()
	check(has_visible_label(app.ui, fasting) and find_button(app.ui, copy.suhoor_button) == null, "exact fasting line replaces the suhoor window at 04:45")
	for place: String in data.places:
		move_market_fixture(place)
		check(has_visible_label(app.ui, fasting), "fasting line shows on the map at " + place)
	app.show_screen("game")
	check(has_visible_label(app.ui, fasting), "fasting line shows in the walking view")
	stage_ramadan(30, 1089, "masjid")
	check(has_visible_label(app.ui, fasting) and find_button(app.ui, copy.iftar_button) == null, "the fast is active through 18:09 and iftar has not opened")
	stage_ramadan(30, 1090, "spice")
	check(not has_visible_label(app.ui, fasting) and find_button(app.ui, copy.iftar_button) == null, "fasting line ends at 18:10 and iftar stays at the Masjid")
	move_market_fixture("masjid")
	var prayer_caption: String = app.clock.prayer_label(true)
	var prayer_totals: Dictionary = app.clock.totals()
	check(find_button(app.ui, prayer_caption) != null, "Maghrib prayer is still offered alongside iftar")
	await press_button(copy.iftar_button, "Break your fast with the people is usable at the Masjid at 18:10")
	check(app.ui.screen == "iftar" and has_visible_label(app.ui, str(copy.iftar.kicker).to_upper())
		and has_visible_label(app.ui, copy.iftar.title) and visible_text().contains(copy.iftar.text), "iftar renders the exact locked kicker, title and story")
	await press_button(copy.iftar.to_map, "iftar offers the locked map return")
	check(app.ui.screen == "market_map" and app.current_place == "masjid" and app.minute_of_day == 1090, "iftar returns to the same place and minute")
	app.ui.ramadan_requested.emit(Ramadan.Action.IFTAR)
	check(app.ui.screen == "market_map" and find_button(app.ui, copy.iftar_button) == null, "iftar stays used for the day")
	check(app.clock.totals() == prayer_totals and find_button(app.ui, prayer_caption) != null, "iftar preserves prayer and its record")
	stage_ramadan(30, 1184, "masjid")
	check(find_button(app.ui, copy.tarawih_button) == null, "tarawih is absent at 19:44")
	stage_ramadan(30, 1185, "inn")
	check(find_button(app.ui, copy.tarawih_button) == null, "tarawih is absent away from the Masjid")
	stage_ramadan(30, 1200, "masjid")
	check(find_button(app.ui, app.clock.prayer_label(true)) != null, "Isha prayer stays available alongside tarawih")
	await press_button(copy.tarawih_button, "Pray tarawih is usable at 20:00 at the Masjid")
	check(app.day == 30 and app.minute_of_day == 1260 and has_visible_label(app.ui, copy.tarawih_toast), "tarawih advances normal time by 60 minutes and shows the locked toast")
	app.ui.ramadan_requested.emit(Ramadan.Action.TARAWIH)
	check(find_button(app.ui, copy.tarawih_button) == null and app.minute_of_day == 1260, "tarawih can only advance time once each night")
	check(app.progress.coins == coins and app.progress.trust == trust, "Ramadan grants no coins or trust")
	check(app.ui.reputation_lines() == prior_reputation, "Ramadan contributes no What people say line")
	app.show_screen("all_prayers")
	var rows := "RAMADAN\nDays fasted\n1\nSuhoor\n1\nNights of tarawih\n1"
	check(visible_text().contains(rows) and visible_text().find(rows) < visible_text().find(str(app.ui.prayer_record.panel.note).to_upper()), "All your prayers shows the exact private rows and counts before its note")

	stage_ramadan(31, 284, "inn")
	check(find_button(app.ui, copy.suhoor_button) != null, "a new day permits suhoor through 04:44")
	stage_ramadan(31, 285, "inn")
	check(find_button(app.ui, copy.suhoor_button) == null, "unspent suhoor also closes at 04:45")
	stage_ramadan(31, 1169, "masjid")
	check(find_button(app.ui, copy.iftar_button) != null, "a new day permits iftar through 19:29")
	stage_ramadan(31, 1170, "masjid")
	check(find_button(app.ui, copy.iftar_button) == null, "unspent iftar closes at 19:30")
	stage_ramadan(31, 1185, "masjid")
	check(find_button(app.ui, copy.tarawih_button) != null, "a new night permits tarawih from 19:45")
	stage_ramadan(31, 1379, "masjid")
	check(find_button(app.ui, copy.tarawih_button) != null, "tarawih is offered through 22:59")
	app.clock.advance_to(31, 1380, false)
	app.update_state()
	check(find_button(app.ui, copy.tarawih_button) == null, "unspent tarawih closes at 23:00")
	stage_ramadan(59, 1089, "masjid")
	check(has_visible_label(app.ui, fasting), "fasting line is still present on the last Ramadan day")
	stage_ramadan(60, 600, "masjid")
	check(not has_visible_label(app.ui, fasting) and app.ramadan.record().fasted == 30, "the fasting line ends in Shawwal and the private record keeps all thirty fasts")
	stage_ramadan(60, 1200, "masjid")
	check(find_button(app.ui, copy.tarawih_button) == null, "tarawih is absent in Shawwal")

	reset_at_market_place("inn", 198, 30)
	var calendar: Dictionary = app.clock.calendar.data
	var rest: String = str(calendar.panel.rest).format({"n": 3, "c": 6})
	await press_button(calendar.inn_button, "rest is still available on a fasting day")
	await press_button(rest, "three-day rest uses the existing calendar action")
	check(app.day == 33 and app.minute_of_day == 280 and app.ramadan.record() == {"fasted": 0, "suhoor": 0, "tarawih": 0}, "three skipped Ramadan days add no fasts and restarting cleared the earlier actions")
	stage_ramadan(33, 285, "inn")
	check(has_visible_label(app.ui, fasting), "the wake day is not a rested day")
	stage_ramadan(33, 1090, "inn")
	check(app.ramadan.record().fasted == 1, "the wake day counts at Maghrib without taking iftar")
	await press_button(calendar.inn_button, "rest is available after Maghrib")
	await press_button(rest, "the next three-day rest uses the existing calendar action")
	check(app.ramadan.record().fasted == 1, "rest begun after Maghrib preserves the fast already completed")
	app.set_process(true)


func stage_ramadan(day: int, minute: int, place: String) -> void:
	app.clock.advance_to(day, minute, false)
	move_market_fixture(place)



func check_iftar_giving_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/IFTAR_GIVING/RECORD/iftar_giving_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/iftar_giving.json")
	var giving: Dictionary = app.iftar_giving.data
	var copy: Dictionary = giving.panel
	var dates: Dictionary = giving.options[0]
	var soup: Dictionary = giving.options[1]
	var pay_dates: String = str(copy.pay).format({"n": int(dates.cost)})
	var pay_soup: String = str(copy.pay).format({"n": int(soup.cost)})
	check(not approved.is_empty() and approved == runtime, "iftar giving data copies LOCK 20 byte for byte")
	check(giving == JSON.parse_string(runtime.get_string_from_utf8()), "iftar giving uses the approved runtime data")
	app.set_process(false)

	reset_at_market_place("masjid", 198)
	var trust: int = app.progress.trust
	for fixture: Vector2i in [Vector2i(29, 1000), Vector2i(30, 959)]:
		stage_ramadan(fixture.x, fixture.y, "masjid")
		check(find_button(app.ui, giving.masjid_button) == null, "iftar giving is absent before Ramadan or 16:00")
		app.show_iftar_giving()
		check(app.ui.screen == "market_map", "an unavailable iftar panel cannot be opened directly")
	app.clock.advance_to(30, 960, false)
	app.update_state()
	check(find_button(app.ui, giving.masjid_button) != null, "iftar giving appears at 16:00 without reopening the map")
	stage_ramadan(30, 1000, "board")
	check(find_button(app.ui, giving.masjid_button) == null, "iftar giving is exclusive to the Masjid")
	stage_ramadan(30, 1000, "masjid")
	var button := find_button(app.ui, giving.masjid_button)
	var fasting := find_visible_label(app.ui, app.ramadan.fasting_line())
	check(button != null and fasting != null and button.global_position.x < fasting.global_position.x, "Pay for iftar precedes the fasting line")
	await press_button(giving.masjid_button, "the Masjid opens the iftar giving panel")
	check(app.ui.screen == "iftar_giving" and visible_text().contains(copy.intro), "the iftar panel uses the locked introduction")
	check(has_visible_label(app.ui, str(copy.kicker).to_upper()) and has_visible_label(app.ui, copy.title), "the iftar panel shows the locked kicker and title")
	for option: Dictionary in giving.options:
		check(has_visible_label(app.ui, option.name) and has_visible_label(app.ui, option.line), "each iftar option shows its locked name and description")
	check(find_button(app.ui, copy.secret_label) == null and has_visible_label(app.ui, str(copy.secret_locked).to_upper()), "iftar giving is public before reading the first page")
	check(has_visible_label(app.ui, "MEALS FOR THE POOR: 0 / 10,000"), "iftar opens with the shared meal goal")

	await press_button(pay_dates, "the dates and water can be paid for")
	check_wallet(trust + 1, 194, "first public dates add one trust and cost four coins")
	check(app.feeding.meals_given == 20 and has_visible_label(app.ui, "MEALS FOR THE POOR: 20 / 10,000"), "dates add twenty to the same meal counter as LOCK 9")
	check(visible_text().contains(copy.done_public), "the first public payment shows Idris's locked reply")
	await press_button(pay_soup, "the soup and bread can be paid for")
	check_wallet(trust + 1, 179, "same-day soup costs fifteen coins and adds no more trust")
	check(app.feeding.meals_given == 70 and has_visible_label(app.ui, "MEALS FOR THE POOR: 70 / 10,000"), "soup adds fifty more to the shared counter")
	check(app.ui.reputation_lines() == [giving.say.feeds], "public iftar adds the locked line once")
	await press_button(copy.back, "iftar giving returns to the market map")
	stage_ramadan(31, 600, "board")
	var feeding_option: Dictionary = app.feeding.data.options[0]
	await press_button(app.feeding.data.place_button, "ordinary feeding remains available")
	check(has_visible_label(app.ui, "MEALS FOR THE POOR: 70 / 10,000"), "Salma displays the meals paid for at the Masjid")
	await press_button(str(app.feeding.data.panel.pay).format({"n": int(feeding_option.cost)}), "ordinary feeding also adds to the shared counter")
	stage_ramadan(31, 1089, "masjid")
	await press_button(giving.masjid_button, "iftar giving is still available at 18:09")
	check(visible_text().contains(copy.intro) and has_visible_label(app.ui, "MEALS FOR THE POOR: 80 / 10,000"), "reopening clears the last iftar result and displays Salma's contribution")
	await press_button(pay_dates, "a new day allows its own public iftar trust award")
	check_wallet(trust + 3, 170, "iftar and ordinary feeding use separate daily trust awards")
	app.talking.greeted = {"salma": true, "rashid": true, "layla": true}
	check(app.ui.reputation_lines() == [app.feeding.data.say.feeds, giving.say.feeds, app.talking.data.say.greets], "the iftar reputation line follows LOCK 9 and precedes greetings")
	app.clock.advance_to(31, 1090, false)
	app.update_state()
	app.pay_for_iftar(dates.id)
	check_wallet(trust + 3, 170, "an already open panel cannot take payment at Maghrib")
	await press_button(copy.back, "back returns to the Masjid after the iftar giving window ends")
	check(find_button(app.ui, giving.masjid_button) == null and find_button(app.ui, app.ramadan.data.iftar_button) != null, "at 18:10 giving closes and the existing Ramadan iftar opens")
	stage_ramadan(60, 1000, "masjid")
	check(find_button(app.ui, giving.masjid_button) == null, "iftar giving ends with Ramadan")

	reset_at_market_place("masjid", 3)
	stage_ramadan(30, 1000, "masjid")
	await press_button(giving.masjid_button, "the panel opens even with insufficient coins")
	check(visible_text().count(copy.not_enough) == 2 and find_button(app.ui, pay_dates) == null and find_button(app.ui, pay_soup) == null, "unaffordable rows show the locked notice and offer no payment")
	app.pay_for_iftar(dates.id)
	check_wallet(trust, 3, "an unaffordable payment leaves the wallet and trust intact")
	check(app.iftar_giving.meals_given == 0 and app.ui.reputation_lines().is_empty(), "an unaffordable payment adds no meals or reputation")

	reset_at_market_place("inn", 198)
	await press_button(app.chapter.places.inn, "enter the open purse to learn about secret giving")
	await press_button(app.chapter.purse.ask_baker, "ask Salma about the waiting people")
	await press_button(app.chapter.purse.baker.back, "return to the purse")
	await press_button(str(app.chapter.purse.take_page).format({"teacher": app.chapter.teacher}), "reading page one unlocks secret giving")
	await press_button(app.chapter.page.back, "return from the first scholar page")
	await press_button(app.chapter.purse.not_now, "leave without a gift")
	stage_ramadan(30, 1000, "masjid")
	app.show_screen("game")
	await press_button(giving.masjid_button, "iftar giving also opens from the street")
	var checkbox := find_button(app.ui, copy.secret_label) as CheckBox
	check(checkbox != null and not checkbox.button_pressed, "Idris's secret choice starts unchecked after page one")
	if checkbox != null:
		checkbox.button_pressed = true
	check(has_visible_label(app.ui, str(copy.secret_on).to_upper()), "ticking the checkbox shows the locked secret hint")
	await press_button(pay_dates, "secret dates use the ordinary payment control")
	check_wallet(trust, 194, "secret dates cost four coins and grant no trust")
	check(app.feeding.meals_given == 20 and visible_text().contains(copy.done_secret), "secret dates add meals and show Idris's secret reply")
	check(app.ui.reputation_lines().is_empty(), "a secret iftar leaves no public reputation line")
	reset_at_market_place("masjid", 198)
	check(app.iftar_giving.meals_given == 0 and app.iftar_giving.reputation_line() == null, "restarting resets the shared meal counter and iftar reputation")
	app.set_process(true)


func check_eid_al_fitr_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/EID_AL_FITR/RECORD/eid_al_fitr_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/eid_al_fitr.json")
	var copy: Dictionary = app.eid_al_fitr.data
	check(not approved.is_empty() and approved == runtime, "Eid al-Fitr data copies LOCK 21 byte for byte")
	check(copy == JSON.parse_string(runtime.get_string_from_utf8()), "Eid al-Fitr reads the locked runtime data")
	app.set_process(false)
	await check_last_ten_nights(copy)
	await check_zakat_al_fitr(copy)
	await check_eid_prayer_and_record(copy)
	app.set_process(true)


func check_last_ten_nights(copy: Dictionary) -> void:
	reset_at_market_place("masjid", 198)
	var trust: int = app.progress.trust
	var prior_reputation: Array = app.ui.reputation_lines()
	app.show_screen("all_prayers")
	check(not has_visible_label(app.ui, copy.record.nights), "the private rows are absent before Ramadan")
	for fixture: Vector2i in [Vector2i(48, 1380), Vector2i(49, 1379)]:
		stage_ramadan(fixture.x, fixture.y, "masjid")
		check(find_button(app.ui, copy.night_button) == null, "night prayer is absent before the night of 21 Ramadan")
		app.ui.night_prayer_requested.emit()
		check(app.eid_al_fitr.record().nights == "0", "direct night request outside its window records nothing")
	stage_ramadan(49, 1380, "spice")
	check(find_button(app.ui, copy.night_button) == null, "night prayer is Masjid-only at 23:00")
	move_market_fixture("masjid")
	await press_button(copy.night_button, "night prayer begins at 23:00 on the eve of 21 Ramadan")
	check(app.day == 50 and app.minute_of_day == 0, "standing advances normal time by 60 minutes across midnight")
	check(has_visible_label(app.ui, copy.night_toast), "standing shows the exact locked toast without identifying a night")
	check(find_button(app.ui, copy.night_button) == null, "night prayer disappears after standing before midnight")
	app.ui.night_prayer_requested.emit()
	check(app.minute_of_day == 0 and app.eid_al_fitr.record().nights == "1", "the same night cannot be repeated after midnight")
	stage_ramadan(51, 284, "masjid")
	await press_button(copy.night_button, "an unstood night remains available at 04:44")
	check(app.minute_of_day == 344 and app.eid_al_fitr.record().nights == "2", "standing at 04:44 advances across Fajr and counts once")
	var adhan := str(app.identity.clock.adhan_toast).format({"prayer": app.identity.clock.prayers[0].name})
	check(has_visible_label(app.ui, adhan), "the normal Fajr adhan takes priority when crossed")
	app.ui._process(4.0)
	check(has_visible_label(app.ui, copy.night_toast), "the locked night toast follows the Fajr adhan")
	stage_ramadan(52, 285, "masjid")
	check(find_button(app.ui, copy.night_button) == null, "night prayer closes at 04:45")
	stage_ramadan(59, 0, "masjid")
	check(find_button(app.ui, copy.night_button) != null, "the night of 30 Ramadan is eligible")
	stage_ramadan(59, 1380, "masjid")
	check(find_button(app.ui, copy.night_button) == null, "23:00 on 30 Ramadan belongs to Shawwal")
	check_wallet(trust, 198, "night prayer gives no coins or trust")
	check(app.ui.reputation_lines() == prior_reputation, "night prayer leaves no public reputation")


func check_zakat_al_fitr(copy: Dictionary) -> void:
	reset_at_market_place("masjid", 1)
	var trust: int = app.progress.trust
	var pay := str(copy.fitr.pay).format({"n": 2})
	stage_ramadan(56, 1439, "masjid")
	check(find_button(app.ui, copy.fitr_button) == null, "zakat al-fitr is absent before 28 Ramadan")
	stage_ramadan(57, 0, "spice")
	check(find_button(app.ui, copy.fitr_button) == null, "zakat al-fitr is Masjid-only")
	move_market_fixture("masjid")
	await press_button(copy.fitr_button, "zakat al-fitr opens on 28 Ramadan at midnight")
	check(app.ui.screen == "fitr" and has_visible_label(app.ui, copy.fitr.title)
		and visible_text().contains(copy.fitr.text), "zakat al-fitr displays its locked title and story")
	check(find_button(app.ui, pay) == null and has_visible_label(app.ui, copy.fitr.not_enough), "one coin shows only the locked affordability message")
	app.ui.fitr_paid.emit()
	check_wallet(trust, 1, "a rejected payment costs nothing")
	check(app.eid_al_fitr.record().fitr == copy.record.no, "a rejected payment does not mark the year")
	await press_button(copy.fitr.to_map, "unaffordable panel can return to the map")
	app.progress.coins = 2
	stage_ramadan(60, 539, "masjid")
	await press_button(copy.fitr_button, "zakat al-fitr is available on Eid at 08:59")
	await press_button(pay, "zakat al-fitr costs exactly two coins")
	check(has_visible_label(app.ui, copy.fitr.given) and find_button(app.ui, pay) == null, "payment shows the locked confirmation and removes the pay button")
	app.ui.fitr_paid.emit()
	check_wallet(trust, 0, "duplicate payment costs nothing and changes no trust")
	check(app.eid_al_fitr.record().fitr == copy.record.yes_fitr, "the current year is marked as given")
	check(app.feeding.meals_given == 0 and app.ui.reputation_lines().is_empty(), "zakat al-fitr adds no meals or public reputation")
	await press_button(copy.fitr.to_map, "confirmation can return to the market map")
	check(find_button(app.ui, copy.fitr_button) == null, "paid year removes the place-bar action")
	stage_ramadan(411, 600, "masjid")
	check(find_button(app.ui, copy.fitr_button) != null and app.eid_al_fitr.record().fitr == copy.record.no, "the next 354-day year can give its own zakat al-fitr")
	reset_at_market_place("masjid", 198)
	stage_ramadan(60, 539, "masjid")
	await press_button(copy.fitr_button, "the unpaid panel can open a minute before the deadline")
	app.clock.advance_to(60, 540, false)
	app.update_state()
	app.ui.fitr_paid.emit()
	check(find_button(app.ui, pay) == null and app.progress.coins == 198, "an open panel cannot take a payment at or after 09:00")
	await press_button(copy.fitr.to_map, "an expired panel can return to the market")
	check(find_button(app.ui, copy.fitr_button) == null, "the place-bar action closes at 09:00")


func check_eid_prayer_and_record(copy: Dictionary) -> void:
	reset_at_market_place("masjid", 198)
	var trust: int = app.progress.trust
	stage_ramadan(49, 1390, "masjid")
	await press_button(copy.night_button, "the record fixture stands one night")
	stage_ramadan(60, 0, "spice")
	check(has_visible_label(app.ui, copy.eid_line) and find_button(app.ui, copy.eid_button) == null, "Eid line starts at midnight away from the Masjid")
	for place: String in data.places:
		move_market_fixture(place)
		check(has_visible_label(app.ui, copy.eid_line), "Eid line appears at %s" % place)
	stage_ramadan(60, 389, "masjid")
	check(find_button(app.ui, copy.eid_button) == null, "Eid prayer is absent at 06:29")
	stage_ramadan(60, 390, "spice")
	check(find_button(app.ui, copy.eid_button) == null, "Eid prayer is Masjid-only at 06:30")
	move_market_fixture("masjid")
	await press_button(copy.eid_button, "Eid prayer is available at 06:30")
	check(app.ui.screen == "eid" and has_visible_label(app.ui, copy.eid.title)
		and visible_text().contains(copy.eid.text), "Eid displays the locked title and story")
	check(app.minute_of_day == 390, "opening Eid keeps the live clock time")
	await press_button(copy.eid.to_map, "Eid returns to the market map")
	check(find_button(app.ui, copy.eid_button) == null and has_visible_label(app.ui, copy.eid_line), "the prayer is used once while the Eid line stays")
	app.ui.eid_prayer_requested.emit()
	check(app.ui.screen == "market_map", "a direct repeat cannot open the Eid prayer")
	check_wallet(trust, 198, "Eid prayer gives no coins or trust")
	check(app.ui.reputation_lines().is_empty(), "Eid prayer has no reputation line")
	stage_ramadan(60, 1439, "spice")
	check(has_visible_label(app.ui, copy.eid_line), "Eid line lasts through 23:59")
	stage_ramadan(61, 0, "masjid")
	check(not has_visible_label(app.ui, copy.eid_line) and find_button(app.ui, copy.eid_button) == null
		and find_button(app.ui, copy.fitr_button) == null and find_button(app.ui, copy.night_button) == null, "2 Shawwal has no LOCK 21 place-bar content")
	app.show_screen("prayer_record")
	check(not has_visible_label(app.ui, copy.record.nights), "LOCK 21 rows are private and absent from Today's prayers")
	app.show_screen("all_prayers")
	var tarawih := find_visible_label(app.ui, app.ramadan.data.record.tarawih)
	var nights := find_visible_label(app.ui, copy.record.nights)
	var fitr := find_visible_label(app.ui, copy.record.fitr)
	var eid := find_visible_label(app.ui, copy.record.eid)
	check(tarawih != null and nights != null and fitr != null and eid != null
		and tarawih.position.y < nights.position.y and nights.position.y < fitr.position.y
		and fitr.position.y < eid.position.y, "the three private rows follow the earlier Ramadan rows in locked order")
	check(app.eid_al_fitr.record() == {"nights": "1", "fitr": copy.record.no, "eid": copy.record.yes_eid}, "private rows count nights, current-year fitr and any Eid prayed")
	stage_ramadan(414, 539, "masjid")
	check(find_button(app.ui, copy.eid_button) != null and app.eid_al_fitr.record().eid == copy.record.yes_eid, "another Eid is available at 08:59 and the private record retains earlier Eid")
	stage_ramadan(414, 540, "masjid")
	check(find_button(app.ui, copy.eid_button) == null and has_visible_label(app.ui, copy.eid_line), "Eid prayer closes at 09:00 while the line stays")
	reset_at_market_place("masjid", 198)
	check(app.eid_al_fitr.record() == {"nights": "0", "fitr": copy.record.no, "eid": copy.record.no}, "a fresh playthrough resets the LOCK 21 record")


func check_zakat_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/ZAKAT/RECORD/zakat_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/zakat.json")
	var copy: Dictionary = app.zakat.data
	check(not approved.is_empty() and approved == runtime, "Zakat data copies LOCK 22 byte for byte")
	check(copy == JSON.parse_string(runtime.get_string_from_utf8()), "Zakat reads the locked runtime data")
	app.set_process(false)
	await check_zakat_recipients(copy)
	await check_zakat_threshold_and_balance(copy)
	await check_zakat_after_inn_rest(copy)
	await check_zakat_overlapping_years(copy)
	app.set_process(true)


func check_zakat_recipients(copy: Dictionary) -> void:
	var due_text := str(copy.panel.due).format({"c": 238, "t": 100, "n": 6})
	for recipient: Dictionary in copy.options:
		reset_at_market_place("masjid", 238, 354)
		check(find_button(app.ui, copy.masjid_button) == null, "the Masjid has no Zakat action on day index 353")
		app.ui.zakat_requested.emit()
		check(app.ui.screen == "market_map", "the panel cannot open before the lunar year ends")
		app.show_screen("all_prayers")
		check(not has_visible_label(app.ui, copy.record.title), "the private Zakat row is absent before the first assessment")
		stage_ramadan(355, 600, "inn")
		check(find_button(app.ui, copy.masjid_button) == null, "the annual notice is Masjid-only")
		move_market_fixture("masjid")
		await press_button(copy.masjid_button, "the Masjid opens the first Zakat assessment on day index 354")
		var text := visible_text()
		check(app.ui.screen == "zakat" and text.contains(str(copy.panel.kicker).to_upper())
			and has_visible_label(app.ui, copy.panel.title) and text.contains(due_text), "the panel shows the locked heading and 238-coin assessment")
		var previous_y := 0.0
		for option: Dictionary in copy.options:
			var button := find_button(app.ui, option.label)
			check(button != null and button.position.y > previous_y, "Zakat recipients appear in locked order: " + option.id)
			if button != null:
				previous_y = button.position.y
		var trust: int = app.progress.trust
		var reputation: Array = app.ui.reputation_lines()
		app.ui.zakat_paid.emit("invalid")
		check(app.progress.coins == 238, "an invalid recipient cannot take coins")
		await press_button(recipient.label, "the locked Zakat recipient is selectable: " + recipient.id)
		text = visible_text()
		check(app.progress.coins == 232 and text.contains(due_text) and text.contains(recipient.out), "payment takes six and keeps the exact receipt: " + recipient.id)
		check(find_button(app.ui, recipient.label) == null, "payment choices disappear on the receipt")
		app.ui.zakat_paid.emit(recipient.id)
		check(app.progress.coins == 232 and app.progress.trust == trust and app.ui.reputation_lines() == reputation, "repeat payment has no effect and Zakat adds no trust or reputation")
		await press_button(copy.panel.to_map, "the locked return button exits the Zakat receipt")
		check(app.ui.screen == "market_map" and find_button(app.ui, copy.masjid_button) == null, "the Masjid action goes away after the last debt is paid")
		check_zakat_record(copy, "paid · 6 coins")


func check_zakat_threshold_and_balance(copy: Dictionary) -> void:
	reset_at_market_place("masjid", 99, 355)
	await press_button(copy.masjid_button, "below the threshold the notice appears on the recording day")
	check(visible_text().contains(str(copy.panel.none).format({"c": 99, "t": 100})), "99 coins uses the exact zero-due copy")
	app.progress.coins = 100
	app.update_state()
	app.ui.zakat_paid.emit(copy.options[0].id)
	check(app.progress.coins == 100 and find_button(app.ui, copy.options[0].label) == null, "a zero assessment stays fixed after an increase in coins")
	await press_button(copy.panel.to_map, "the zero-due notice can be closed")
	check(find_button(app.ui, copy.masjid_button) != null, "the zero notice can be reopened on the recording day")
	check_zakat_record(copy, "not due this year")
	stage_ramadan(356, 600, "masjid")
	check(find_button(app.ui, copy.masjid_button) == null, "the zero notice disappears the next day")

	reset_at_market_place("masjid", 100, 355)
	check_zakat_record(copy, "due · 3 coins")
	reset_at_market_place("masjid", 120, 355)
	check_zakat_record(copy, "due · 3 coins")
	reset_at_market_place("masjid", 300, 355)
	app.progress.coins = 3
	app.update_state()
	await press_button(copy.masjid_button, "an unaffordable assessment remains accessible")
	check(visible_text().contains(str(copy.panel.due).format({"c": 300, "t": 100, "n": 8})), "the panel keeps the assessed coin count after spending")
	check(visible_text().contains(str(copy.panel.not_enough).format({"n": 8})), "the unaffordable notice names the exact amount due")
	for option: Dictionary in copy.options:
		check(find_button(app.ui, option.label) == null, "unaffordable Zakat hides recipient " + option.id)
	app.ui.zakat_paid.emit(copy.options[0].id)
	check(app.progress.coins == 3, "unaffordable payment leaves the balance unchanged")
	stage_ramadan(361, 600, "masjid")
	check(find_button(app.ui, copy.masjid_button) != null, "the unpaid eight remains accessible six days later")
	check_zakat_record(copy, "due · 8 coins")


func check_zakat_after_inn_rest(copy: Dictionary) -> void:
	var rest_days := 3
	var coins: int = 60 + app.clock.calendar.rest_cost(rest_days)
	reset_at_market_place("inn", coins, 353)
	await press_button(app.clock.calendar.data.inn_button, "the Inn calendar is available before the Zakat year ends")
	app.ui.calendar_rest_requested.emit(rest_days)
	check(app.day == 356 and app.progress.coins == 60, "rest crosses the Zakat anniversary and deducts the Inn cost")
	move_market_fixture("masjid")
	await press_button(copy.masjid_button, "a zero-due assessment first observed after resting shows on the recording day")
	check(visible_text().contains(str(copy.panel.none).format({"c": 60, "t": 100})), "the delayed assessment uses the coins held after paying the Inn")
	stage_ramadan(357, 600, "masjid")
	check(find_button(app.ui, copy.masjid_button) == null, "the delayed zero notice expires the day after it is recorded")


func check_zakat_overlapping_years(copy: Dictionary) -> void:
	reset_at_market_place("masjid", 300, 355)
	app.progress.coins = 100
	stage_ramadan(709, 600, "masjid")
	check_zakat_record(copy, "due · 11 coins")
	move_market_fixture("masjid")
	app.progress.coins = 3
	app.update_state()
	await press_button(copy.masjid_button, "at day index 708 the panel still opens the older debt")
	check(visible_text().contains(str(copy.panel.not_enough).format({"n": 8})), "affordability checks the older eight even when the newer three is affordable")
	app.progress.coins = 100
	app.update_state()
	await press_button(copy.options[0].label, "pay the older eight once")
	check(app.progress.coins == 92 and visible_text().contains(copy.options[0].out)
		and visible_text().contains(str(copy.panel.due).format({"c": 300, "t": 100, "n": 8})), "the panel remains pinned to the older year and its receipt")
	app.ui.zakat_paid.emit(copy.options[1].id)
	check(app.progress.coins == 92, "the newer debt cannot be paid through the older receipt")
	check(app.ui.clock_panel.get_child_count() == 2, "the Zakat receipt keeps the clock display without a prayer-record button")
	app.ui.record_requested.emit()
	check(app.ui.screen == "zakat" and visible_text().contains(copy.options[0].out), "the prayer-record signal cannot displace the pinned receipt")
	await press_button(copy.panel.to_map, "leave the older receipt before paying again")
	check(find_button(app.ui, copy.masjid_button) != null, "the Masjid action remains for the newer debt")
	check_zakat_record(copy, "due · 3 coins")
	move_market_fixture("masjid")
	await press_button(copy.masjid_button, "reopening serves the newer year")
	check(visible_text().contains(str(copy.panel.due).format({"c": 100, "t": 100, "n": 3})), "the newer assessment uses the coins held on its own recording day")
	await press_button(copy.options[1].label, "pay the newer three")
	check(app.progress.coins == 89 and visible_text().contains(copy.options[1].out), "payment takes only the newer three and retains its receipt")
	await press_button(copy.panel.to_map, "leave the newer receipt")
	check(find_button(app.ui, copy.masjid_button) == null, "the action is removed after both debts are paid")
	check_zakat_record(copy, "paid · 3 coins")

	reset_at_market_place("masjid", 300, 355)
	app.progress.coins = 60
	stage_ramadan(709, 600, "masjid")
	check_zakat_record(copy, "due · 8 coins")
	move_market_fixture("masjid")
	await press_button(copy.masjid_button, "an older debt takes precedence over the same-day zero assessment")
	check(visible_text().contains(str(copy.panel.due).format({"c": 300, "t": 100, "n": 8})), "the zero assessment does not displace the older eight")
	await press_button(copy.options[3].label, "pay the older eight in the zero-due year")
	check(app.progress.coins == 52 and visible_text().contains(copy.options[3].out), "the older receipt remains pinned after payment")
	await press_button(copy.panel.to_map, "exit the old receipt in the zero-due year")
	check(find_button(app.ui, copy.masjid_button) != null, "the latest zero assessment retains its same-day notice")
	check_zakat_record(copy, "not due this year")
	move_market_fixture("masjid")
	await press_button(copy.masjid_button, "reopening serves the latest zero assessment")
	check(visible_text().contains(str(copy.panel.none).format({"c": 60, "t": 100})), "the zero notice uses the 60 held at assessment")
	stage_ramadan(710, 600, "masjid")
	check(find_button(app.ui, copy.masjid_button) == null, "the zero notice expires even when it followed older debt")
	reset_at_market_place("masjid", 300)
	check(app.zakat.record().is_empty() and find_button(app.ui, copy.masjid_button) == null, "a new playthrough clears assessments and receipts")


func check_zakat_record(copy: Dictionary, status: String) -> void:
	app.show_screen("all_prayers")
	var row := str(copy.record.title) + "\n" + status
	var text := visible_text()
	var at := text.find(row)
	check(at > text.find(app.eid_al_fitr.data.record.eid) and text.contains(row)
		and at < text.find(str(app.ui.prayer_record.panel.note).to_upper()), "the private Zakat row follows the Eid rows and reads " + status)


const FIRST_DHU_AL_HIJJAH := 119


func check_eid_al_adha_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/EID_AL_ADHA/RECORD/eid_al_adha_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/eid_al_adha.json")
	var copy: Dictionary = app.eid_al_adha.data
	check(not approved.is_empty() and approved == runtime, "Eid al-Adha copies LOCK 23 byte for byte")
	check(copy == JSON.parse_string(runtime.get_string_from_utf8()), "Eid al-Adha reads the locked runtime data")
	app.set_process(false)
	await check_adha_sheep(copy)
	await check_arafah_and_adha_prayer(copy)
	await check_adha_sacrifice(copy)
	check_adha_record(copy)
	app.set_process(true)


func check_adha_sheep(copy: Dictionary) -> void:
	var adha = app.eid_al_adha
	var buy := str(copy.sheep.buy).format({"n": int(copy.numbers.sheep_cost)})
	reset_at_market_place("gate", 20)
	stage_ramadan(FIRST_DHU_AL_HIJJAH - 1, 960, "gate")
	check(find_button(app.ui, copy.gate_button) == null and adha.record().is_empty(), "no Eid al-Adha offer or private rows before Dhu al-Hijjah")
	for slot: Array in [[1, 419, false], [1, 420, true], [1, 1079, true], [1, 1080, false],
			[9, 419, false], [9, 420, true], [9, 1079, true], [9, 1080, false], [10, 600, false]]:
		stage_adha(slot[0], slot[1], "gate")
		check((find_button(app.ui, copy.gate_button) != null) == slot[2], "sheep offer on Dhu al-Hijjah day %d at minute %d" % [slot[0], slot[1]])

	reset_at_market_place("gate", 20)
	stage_adha(1, 600, "quay")
	check(find_button(app.ui, copy.gate_button) == null and not adha.buy_sheep("quay"), "sheep purchase is Gate-only")
	move_market_fixture("gate")
	await press_button(copy.gate_button, "an unaffordable sheep offer still opens")
	check_adha_panel("adha_sheep", copy.sheep)
	check(has_visible_label(app.ui, copy.sheep.not_enough) and find_button(app.ui, buy) == null, "short balance shows the locked notice in place of Buy")
	check(not visible_text().contains(copy.sheep.remembers), "the extra line is absent before telling Saeed")
	check(not adha.buy_sheep("gate") and app.progress.coins == 20 and not adha.owns_sheep(), "insufficient funds preserve the wallet and ownership")
	await press_button(copy.sheep.no, "Not now returns to the market without a sale")

	stage_adha(1, 960, "gate")
	var goats: Dictionary = app.jabirs_goats.data
	await press_button(goats.gate_button, "Jabir remains available alongside the LOCK 23 offer")
	await press_button(goats.offer.tell, "Tell Saeed uses the earlier goats action")
	await press_button(goats.told.to_map, "return after telling Saeed")
	app.progress.coins = int(copy.numbers.sheep_cost)
	app.update_state()
	var before := adha_accounts()
	app.show_screen("game")
	await press_button(copy.gate_button, "the street place bar also opens the sheep offer")
	check_adha_panel("adha_sheep", copy.sheep)
	check(visible_text().contains(copy.sheep.remembers), "the sheep offer shows the exact extra line after telling Saeed")
	await press_button(buy, "exactly thirty coins buys the sheep")
	check_adha_panel("adha_sheep", copy.sheep)
	check(visible_text().contains(copy.sheep.bought) and find_button(app.ui, buy) == null, "the locked purchase receipt replaces Buy")
	check(adha.owns_sheep() and adha_accounts() == [0, before[1], before[2], before[3]], "the sheep costs thirty coins and adds no trust, meals or public reputation")
	await press_button(copy.sheep.no, "return to the Gate after purchase")
	app.progress.coins = 100
	app.update_state()
	check(find_button(app.ui, copy.gate_button) == null and not adha.buy_sheep("gate") and app.progress.coins == 100, "a second sheep cannot be bought")


func check_arafah_and_adha_prayer(copy: Dictionary) -> void:
	var adha = app.eid_al_adha
	var fasting := str(copy.arafah_line).format({"t": "18:10"})
	reset_at_market_place("inn", 198)
	stage_adha(8, 240, "inn")
	check(find_button(app.ui, copy.arafah_button) == null, "the Arafah intention is absent on the eighth")
	stage_adha(9, 209, "inn")
	check(find_button(app.ui, copy.arafah_button) == null and not adha.intend_arafah("inn"), "Arafah cannot be intended before 03:30")
	stage_adha(9, 210, "quay")
	check(find_button(app.ui, copy.arafah_button) == null and not adha.intend_arafah("quay"), "the Arafah action is Inn-only")
	move_market_fixture("inn")
	check(find_button(app.ui, copy.arafah_button) != null, "the Arafah action opens at 03:30")
	stage_adha(9, 284, "inn")
	check(not has_visible_label(app.ui, fasting), "the fasting line has not started at 04:44")
	var before := adha_accounts()
	await press_button(copy.arafah_button, "the Arafah intention is still available at 04:44")
	check(app.ui.toast_label.text == copy.arafah_toast and app.ui.toast_panel.visible, "the exact Arafah toast is displayed")
	check(find_button(app.ui, copy.arafah_button) == null and not adha.intend_arafah("inn"), "Arafah cannot be intended twice")
	check(adha.record().arafah == copy.record.yes_fast and adha_accounts() == before, "the intention updates the private record with no economic or public effect")
	stage_adha(9, 285, "inn")
	check(has_visible_label(app.ui, fasting) and find_button(app.ui, copy.arafah_button) == null, "the fasting line starts at 04:45 when the intention window closes")
	for place: String in ["inn", "masjid", "spice", "gate", "quay", "board", "weaver", "scales"]:
		move_market_fixture(place)
		check(has_visible_label(app.ui, fasting), "the Arafah line appears on the map bar at " + place)
		app.show_screen("game")
		check(has_visible_label(app.ui, fasting), "the Arafah line appears on the street bar at " + place)
	stage_adha(9, 1089, "spice")
	check(has_visible_label(app.ui, fasting), "the Arafah line remains at 18:09")
	stage_adha(9, 1090, "spice")
	check(not has_visible_label(app.ui, fasting), "the Arafah line ends at 18:10")

	stage_adha(10, 389, "masjid")
	check(has_visible_label(app.ui, copy.eid_line) and find_button(app.ui, copy.eid_button) == null, "Eid greeting is up before the 06:30 prayer")
	stage_adha(10, 390, "gate")
	check(has_visible_label(app.ui, copy.eid_line) and not adha.pray_eid("gate"), "Eid greeting is also at the Gate while the prayer remains Masjid-only")
	move_market_fixture("masjid")
	check(find_button(app.ui, copy.eid_button) != null, "Eid prayer starts at 06:30")
	stage_adha(10, 539, "masjid")
	await press_button(copy.eid_button, "Eid prayer is still available at 08:59")
	check_adha_panel("adha_eid", copy.eid)
	check(adha.record().eid == copy.record.yes_eid and app.minute_of_day == 539 and adha_accounts() == before, "Eid prayer is privately recorded without advancing time or changing accounts")
	await press_button(copy.eid.to_map, "the Eid prayer panel returns to the map")
	check(find_button(app.ui, copy.eid_button) == null and not adha.pray_eid("masjid"), "Eid prayer is available only once")
	stage_adha(10, 1439, "spice")
	check(has_visible_label(app.ui, copy.eid_line), "the Eid greeting lasts to the end of the tenth")
	for day_of_month: int in [11, 12, 13]:
		stage_adha(day_of_month, 0, "quay")
		check(has_visible_label(app.ui, copy.tashreeq_line) and not has_visible_label(app.ui, copy.eid_line), "the Tashreeq line replaces the Eid line on day %d" % day_of_month)
	stage_adha(14, 0, "gate")
	check(adha.bar_line().is_empty() and not has_visible_label(app.ui, copy.tashreeq_line), "the fourteenth has no Eid al-Adha map notice")

	reset_at_market_place("masjid", 198)
	stage_adha(10, 540, "masjid")
	check(find_button(app.ui, copy.eid_button) == null and not adha.pray_eid("masjid"), "an unprayed Eid closes at 09:00")


func check_adha_sacrifice(copy: Dictionary) -> void:
	var adha = app.eid_al_adha
	reset_at_market_place("gate", 198)
	stage_adha(1, 600, "gate")
	check(adha.buy_sheep("gate"), "the time-boundary fixture buys a sheep through the live model")
	stage_adha(10, 539, "gate")
	check(find_button(app.ui, copy.sacrifice_button) == null and not adha.sacrifice("gate", true), "the sheep cannot be sacrificed before prayer or 09:00")
	stage_adha(10, 540, "gate")
	check(find_button(app.ui, copy.sacrifice_button) != null, "without a personal Eid prayer the sacrifice opens at 09:00")
	for slot: Array in [[11, 0, true], [11, 1439, true], [12, 0, true], [12, 1439, true],
			[13, 0, true], [13, 1089, true], [13, 1090, false], [14, 600, false]]:
		stage_adha(slot[0], slot[1], "gate")
		check((find_button(app.ui, copy.sacrifice_button) != null) == slot[2], "sacrifice offer on day %d at minute %d" % [slot[0], slot[1]])
	check(adha.owns_sheep() and app.feeding.meals_given == 0, "time-boundary checks leave the unused sheep and meals alone")

	for give_all: bool in [false, true]:
		reset_at_market_place("gate", 198)
		stage_adha(1, 600, "gate")
		check(adha.buy_sheep("gate"), "the distribution fixture owns a sheep")
		stage_adha(10, 400, "masjid")
		await press_button(copy.eid_button, "praying Eid unlocks the sacrifice before 09:00")
		await press_button(copy.eid.to_map, "return to the map after prayer")
		check(not adha.sacrifice("masjid", give_all), "sacrifice is Gate-only")
		move_market_fixture("gate")
		await press_button(copy.sacrifice_button, "the Gate offers sacrifice after the personal Eid prayer")
		check_adha_panel("adha_sacrifice", copy.sacrifice)
		check(find_button(app.ui, copy.sacrifice.thirds) != null and find_button(app.ui, copy.sacrifice.all) != null, "both locked distributions are offered")
		var before := adha_accounts()
		var option: String = copy.sacrifice.all if give_all else copy.sacrifice.thirds
		var receipt: String = copy.sacrifice.out_all if give_all else copy.sacrifice.out_thirds
		var meals := int(copy.numbers.all_meals if give_all else copy.numbers.thirds_meals)
		await press_button(option, "the live distribution accepts: " + option)
		check(visible_text().contains(receipt), "the distribution displays the exact locked receipt")
		check(not adha.owns_sheep() and adha.record().sacrifice == copy.record.yes_sac, "the sheep is consumed and sacrifice is privately recorded")
		check(adha_accounts() == [before[0], before[1], before[2] + meals, before[3]], "only %d meals are added to the shared counter" % meals)
		check(find_button(app.ui, copy.sacrifice.thirds) == null and find_button(app.ui, copy.sacrifice.all) == null, "the receipt removes both distribution choices")
		await press_button(copy.sacrifice.to_map, "the sacrifice panel returns to the Gate map")
		check(find_button(app.ui, copy.sacrifice_button) == null and not adha.sacrifice("gate", not give_all), "distribution cannot be repeated")
		check(app.feeding.meals_given == before[2] + meals, "the repeat attempt adds no more meals")


func check_adha_record(copy: Dictionary) -> void:
	var adha = app.eid_al_adha
	var year_days: int = app.clock.calendar.year_days
	var last_dhu_day := FIRST_DHU_AL_HIJJAH + int(app.clock.calendar.data.months[int(copy.numbers.month)][1]) - 1
	stage_ramadan(last_dhu_day + 29, 600, "masjid")
	check(not adha.record().is_empty(), "private rows remain while a Dhu al-Hijjah date is in the last thirty days")
	stage_ramadan(last_dhu_day + 30, 600, "masjid")
	app.show_screen("all_prayers")
	check(adha.record().is_empty() and not has_visible_label(app.ui, str(copy.record.title).to_upper()), "private rows expire when no Dhu al-Hijjah date remains in the last thirty days")

	stage_ramadan(FIRST_DHU_AL_HIJJAH + year_days, 600, "masjid")
	app.show_screen("all_prayers")
	var text := visible_text()
	var title := text.find(str(copy.record.title).to_upper())
	var arafah := text.find(str(copy.record.arafah) + "\n" + str(copy.record.no))
	var eid := text.find(str(copy.record.eid) + "\n" + str(copy.record.no))
	var sacrifice := text.find(str(copy.record.sacrifice) + "\n" + str(copy.record.no))
	var footer := text.find(str(app.ui.prayer_record.panel.note).to_upper())
	var zakat_row := text.find(str(app.zakat.data.record.title) + "\n" + str(app.zakat.record()))
	check(zakat_row >= 0 and zakat_row < title and title < arafah and arafah < eid and eid < sacrifice and sacrifice < footer, "the fresh Dhu al-Hijjah rows follow Zakat and precede the privacy note in locked order")
	check(adha.record() == {"arafah": copy.record.no, "eid": copy.record.no, "sacrifice": copy.record.no}, "a new lunar season begins with three not-yet rows")
	reset_at_market_place("inn", 198)
	check(adha.record().is_empty() and not adha.owns_sheep() and app.feeding.meals_given == 0, "a new playthrough clears the Eid al-Adha state and meals")


func stage_adha(day_of_month: int, minute: int, place: String) -> void:
	stage_ramadan(FIRST_DHU_AL_HIJJAH + day_of_month - 1, minute, place)


func adha_accounts() -> Array:
	return [app.progress.coins, app.progress.trust, app.feeding.meals_given, app.ui.reputation_lines().duplicate(true)]


func check_adha_panel(screen: String, copy: Dictionary) -> void:
	var text := visible_text()
	check(app.ui.screen == screen and text.contains(str(copy.kicker).to_upper())
		and has_visible_label(app.ui, copy.title) and text.contains(copy.text), "the " + screen + " panel shows its locked copy")


func check_pilgrims_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/PILGRIMS/RECORD/pilgrims_data_V2.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/pilgrims.json")
	var copy: Dictionary = app.pilgrims.data
	check(not approved.is_empty() and approved == runtime, "pilgrims use the exact LOCK 24 V2 data")
	check(copy == JSON.parse_string(runtime.get_string_from_utf8()), "the live pilgrim panel reads the locked runtime data")
	app.set_process(false)
	await check_pilgrim_booking(copy)
	await check_pilgrim_returns(copy)
	app.set_process(true)


func check_pilgrim_booking(copy: Dictionary) -> void:
	var panel: Dictionary = copy.panel
	app.begin_game()
	move_market_fixture("gate")
	for boundary: Array in [[419, false], [420, true], [1079, true], [1080, false]]:
		stage_ramadan(1, boundary[0], "gate")
		check((find_button(app.ui, copy.gate_button) != null) == boundary[1],
			"Abbas availability at Gate minute %d" % boundary[0])
	app.ui.pilgrims_requested.emit()
	check(app.ui.screen == "market_map", "a direct Abbas request after closing leaves the map open")

	reset_at_market_place("quay", 300, 59)
	check(find_button(app.ui, copy.gate_button) == null, "Abbas is Gate-only")
	app.ui.pilgrims_requested.emit()
	check(app.ui.screen == "market_map", "a direct Abbas request away from the Gate leaves the map open")
	move_market_fixture("gate")
	await press_button(copy.gate_button, "Abbas offers Umrah during Ramadan")
	check(app.ui.screen == "pilgrims" and has_visible_label(app.ui, panel.title)
		and visible_text().contains(panel.text) and has_visible_label(app.ui, str(panel.kicker).to_upper()),
		"the caravan panel uses the locked heading and story")
	check(has_visible_label(app.ui, panel.hajj_closed) and app.ui.find_child("SendPilgrim_idris", true, false) == null,
		"the last day of Ramadan displays the locked Hajj booking window")
	check(has_visible_label(app.ui, str(panel.secret_locked).to_upper()) and find_button(app.ui, panel.secret_label) == null,
		"secret sending unlocks only after the first page")
	check(has_visible_label(app.ui, "UMRAH TRIPS PAID: 0 / 1,000 · HAJJ TRIPS PAID: 0 / 100"), "the zero counters show the locked goals")
	app.ui.pilgrim_sent.emit("idris")
	check(app.progress.coins == 300 and app.pilgrims.hajj_paid == 0, "out-of-window Hajj requests do not charge")
	for boundary: Array in [[60, true], [113, true], [114, false]]:
		app.clock.advance_to(boundary[0], 600, false)
		app.update_state()
		check((app.ui.find_child("SendPilgrim_idris", true, false) != null) == boundary[1],
			"Hajj is bookable from 1 Shawwal through 25 Dhu al-Qa'dah inclusive")
	var back := find_button(app.ui, panel.back)
	var counters := find_visible_label(app.ui, "UMRAH TRIPS PAID: 0 / 1,000 · HAJJ TRIPS PAID: 0 / 100")
	check(back != null and counters != null and back.get_global_rect().encloses(
		Rect2(Vector2(back.global_position.x, counters.global_position.y), Vector2(1, 1))),
		"the counters and Back button share a visible footer row")
	await press_button(panel.back, "Back returns to the market map")
	check(app.ui.screen == "market_map", "Back closes Abbas")

	reset_at_market_place("gate", 30, 61)
	await press_button(copy.gate_button, "a short wallet can still view the pilgrim panel")
	var text := visible_text()
	check(text.count(panel.not_enough) == 4 and not text.contains("Send him ·"), "a 30-coin wallet shows four locked shortage notices")
	app.ui.pilgrim_sent.emit("musa")
	app.ui.pilgrim_sent.emit("idris")
	app.ui.pilgrim_sent.emit("unknown")
	check(app.progress.coins == 30 and app.pilgrims.umrah_paid == 0 and app.pilgrims.hajj_paid == 0,
		"short wallets and invalid requests cannot book trips")


func check_pilgrim_returns(copy: Dictionary) -> void:
	var panel: Dictionary = copy.panel
	reset_at_market_place("gate", 300, 61)
	app.progress.trust = 45
	app.open_purse.page_read = true
	await press_button(copy.gate_button, "open Abbas on 2 Shawwal")
	await press_control(app.ui.find_child("SendPilgrim_musa", true, false), "send Old Musa publicly for 40 coins")
	check(app.progress.coins == 260 and app.pilgrims.umrah_paid == 1 and app.progress.trust == 45
		and app.pilgrims.reputation_lines().is_empty(), "booking pays once and public trust waits for home")
	check(has_visible_label(app.ui, str(panel.away).format({"n": 30})), "Umrah starts 30 days from home")
	var secret := find_button(app.ui, panel.secret_label) as CheckBox
	check(secret != null and not secret.button_pressed, "after the first page a new panel starts with the secret box clear")
	if secret != null:
		secret.button_pressed = true
	await press_control(app.ui.find_child("SendPilgrim_yunus", true, false), "send Yunus with the secret option selected")
	secret = find_button(app.ui, panel.secret_label) as CheckBox
	check(secret != null and secret.button_pressed, "sending keeps the secret choice within the open panel")
	if secret != null:
		secret.button_pressed = false
	await press_control(app.ui.find_child("SendPilgrim_idris", true, false), "send Idris publicly for 120 coins")
	check(app.progress.coins == 100 and app.pilgrims.umrah_paid == 2 and app.pilgrims.hajj_paid == 1
		and has_visible_label(app.ui, str(panel.away).format({"n": 82})), "the counters and Hajj's 82-day return update immediately")
	app.ui.pilgrim_sent.emit("musa")
	app.ui.pilgrim_sent.emit("idris")
	check(app.progress.coins == 100, "a second request for an away pilgrim cannot charge")

	app.clock.advance_to(90, 600, false)
	app.update_state()
	check(app.progress.trust == 45 and app.pilgrims.reputation_lines().is_empty()
		and has_visible_label(app.ui, str(panel.away).format({"n": 1})), "the Umrah trips remain away after 29 days")
	app.clock.advance_to(91, 0, false)
	app.update_state()
	check(app.progress.trust == 47 and app.pilgrims.reputation_lines() == [copy.pilgrims[0].say]
		and visible_text().count(panel.home) == 2, "both Umrah pilgrims return at day 30 and only the public one adds trust and a line")
	app.ui.pilgrim_sent.emit("musa")
	app.update_state()
	check(app.progress.trust == 47 and app.progress.coins == 100, "repeat updates and requests after return have no effect")
	await press_button(panel.back, "return to the map with both Umrah trips home")
	await press_button(app.chapter.purse.morning.to_rep, "open What people say")
	check(has_visible_label(app.ui, "“%s”" % copy.pilgrims[0].say[0]) and not visible_text().contains(copy.pilgrims[1].say[0]),
		"the public Umrah wording is visible while the secret trip leaves no line")
	app.clock.advance_to(FIRST_DHU_AL_HIJJAH + 23, 600, false)
	app.update_state()
	check(app.progress.trust == 47 and app.pilgrims.reputation_lines().size() == 1, "Idris remains away through 24 Dhu al-Hijjah")
	app.clock.advance_to(FIRST_DHU_AL_HIJJAH + 24, 0, false)
	app.update_state()
	check(app.progress.trust == 49 and has_visible_label(app.ui, "“%s”" % copy.pilgrims[3].say[0])
		and app.pilgrims.reputation_lines() == [copy.pilgrims[0].say, copy.pilgrims[3].say],
		"Idris returns on 25 Dhu al-Hijjah and updates the open reputation panel")
	reset_at_market_place("gate", 300, 61)
	check(app.pilgrims.umrah_paid == 0 and app.pilgrims.hajj_paid == 0 and app.pilgrims.reputation_lines().is_empty(),
		"a fresh playthrough resets the pilgrim trips and counters")


func check_qurans_school_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/QURANS_SCHOOL/RECORD/qurans_school_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/qurans_school.json")
	var school: Dictionary = app.qurans_school.data
	check(not approved.is_empty() and approved == runtime, "Qurans and school uses the exact LOCK 25 V1 data")
	check(school == JSON.parse_string(runtime.get_string_from_utf8()), "the live school panel reads the locked runtime data")
	app.set_process(false)
	await check_school_access(school)
	await check_school_public(school)
	await check_school_secret(school)
	app.set_process(true)


func check_school_access(school: Dictionary) -> void:
	var copy: Dictionary = school.panel
	app.begin_game()
	app.progress.coins = 20
	for boundary: Array in [[419, false], [420, true], [929, true], [930, false]]:
		app.clock.skip_to(1, boundary[0])
		move_market_fixture("masjid")
		check((find_button(app.ui, school.masjid_button) != null) == boundary[1],
			"school button availability at the Masjid at minute %d" % boundary[0])
	app.ui.qurans_school_requested.emit()
	check(app.ui.screen == "market_map", "direct school request at closing leaves the map open")

	stage_ramadan(2, 600, "quay")
	check(find_button(app.ui, school.masjid_button) == null, "the school button is Masjid-only")
	app.ui.qurans_school_requested.emit()
	check(app.ui.screen == "market_map", "school cannot be opened away from the Masjid")
	move_market_fixture("masjid")
	app.show_screen("game")
	check(find_button(app.ui, school.masjid_button) != null, "the school can be opened from the Masjid place bar in the world")
	await press_button(school.masjid_button, "open the school with 20 coins")
	var text := visible_text()
	check(app.ui.screen == "qurans_school" and has_visible_label(app.ui, copy.title)
		and has_visible_label(app.ui, str(copy.kicker).to_upper()) and text.contains(copy.text),
		"the school displays the locked header and introduction")
	check(text.contains(copy.quran) and text.contains(copy.quran_line)
		and text.contains(copy.school) and text.contains(copy.school_line),
		"both locked donation descriptions are visible")
	check(text.count(copy.not_enough) == 2 and not text.contains(str(copy.pay).format({"n": 25}))
		and not text.contains(str(copy.pay).format({"n": 30})), "neither payment is offered with 20 coins")
	var trust: int = app.progress.trust
	for kind in ["quran", "school", "unknown"]:
		app.ui.qurans_school_paid.emit(kind)
	check_wallet(trust, 20, "short or invalid payments leave the wallet and trust alone")
	check(app.qurans_school.qurans_given == 0 and app.qurans_school.children_in_school == 0
		and app.qurans_school.reputation_lines().is_empty(), "short or invalid payments leave goals and reputation alone")
	check_school_footer(copy.back, "QURANS GIVEN: 0 / 1,000 · CHILDREN IN SCHOOL: 0 / 100")
	await press_button(copy.back, "Back stays reachable with a short wallet")
	check(app.ui.screen == "market_map", "the school Back button returns to the market map")


func check_school_public(school: Dictionary) -> void:
	var copy: Dictionary = school.panel
	var pay_quran := str(copy.pay).format({"n": 25})
	var pay_school := str(copy.pay).format({"n": 30})
	reset_at_market_place("masjid", 200, 1)
	app.progress.trust = 45
	await press_button(school.masjid_button, "open the school before the first page")
	check(has_visible_label(app.ui, str(copy.secret_locked).to_upper()) and find_button(app.ui, copy.secret_label) == null,
		"the secret giving checkbox is locked before the first page")
	check_school_footer(copy.back, "QURANS GIVEN: 0 / 1,000 · CHILDREN IN SCHOOL: 0 / 100")
	await press_button(pay_school, "pay 30 coins for Faris's year")
	check_wallet(46, 170, "the first public payment adds one trust")
	check(visible_text().contains("%s %s" % [copy.first_child, copy.public]),
		"the first child is Faris and Idris tells the room")
	await press_button(pay_school, "pay for a second child's year")
	check_wallet(46, 140, "a second public payment on the same day adds no trust")
	check(visible_text().contains("%s %s" % [copy.more_child, copy.public]) and not visible_text().contains(copy.first_child),
		"only the first school payment uses the Faris result")
	await press_button(pay_quran, "pay 25 coins for a Quran")
	check_wallet(46, 115, "the daily public trust cap is shared across the two school payments")
	check(visible_text().contains("%s %s" % [copy.quran_done, copy.public]), "the Quran result uses the locked public text")
	check_school_footer(copy.back, "QURANS GIVEN: 1 / 1,000 · CHILDREN IN SCHOOL: 2 / 100")
	await press_button(copy.back, "return to the map after the donations")
	app.pilgrims.send("musa", false)
	app.clock.advance_to(31, 600, false)
	app.update_state()
	var lines: Array = app.ui.reputation_lines()
	var pilgrim_line: Array = app.pilgrims.data.pilgrims[0].say
	check(lines.find(pilgrim_line) >= 0 and lines.find(pilgrim_line) + 1 == lines.find(school.say.qurans)
		and lines.find(school.say.qurans) + 1 == lines.find(school.say.school),
		"the two Idris reputation lines follow the LOCK 24 returns in locked order")
	await press_button(app.chapter.purse.morning.to_rep, "view public school reputation")
	check(has_visible_label(app.ui, "“%s”" % school.say.qurans[0]) and has_visible_label(app.ui, "“%s”" % school.say.school[0]),
		"both locked Idris lines appear after public giving")
	app.progress.coins = 25
	app.progress.trust = 46
	move_market_fixture("masjid")
	await press_button(school.masjid_button, "reopen the school on a later day")
	check(visible_text().contains(copy.text) and not visible_text().contains(copy.quran_done),
		"reopening clears the last result and keeps the counters")
	check_school_footer(copy.back, "QURANS GIVEN: 1 / 1,000 · CHILDREN IN SCHOOL: 2 / 100")
	await press_button(pay_quran, "pay exactly 25 coins on a later day")
	check_wallet(47, 0, "the next day's first public payment adds one trust")
	check(app.qurans_school.reputation_lines() == [school.say.qurans, school.say.school],
		"repeat payments leave one reputation line per kind")


func check_school_secret(school: Dictionary) -> void:
	var copy: Dictionary = school.panel
	reset_at_market_place("masjid", 80, 1)
	app.progress.trust = 45
	app.open_purse.page_read = true
	await press_button(school.masjid_button, "open the school after the first page")
	var checkbox := find_button(app.ui, copy.secret_label) as CheckBox
	check(checkbox != null and not checkbox.button_pressed, "reading page one unlocks the clear checkbox")
	if checkbox != null:
		checkbox.button_pressed = true
	await press_button(str(copy.pay).format({"n": 25}), "pay for a Quran in secret")
	check_wallet(45, 55, "secret Quran payment spends coins without adding trust")
	check(visible_text().contains("%s %s" % [copy.quran_done, copy.secret]), "the Quran result says Idris tells no one")
	checkbox = find_button(app.ui, copy.secret_label) as CheckBox
	check(checkbox != null and checkbox.button_pressed, "the secret choice persists for this visit")
	await press_button(str(copy.pay).format({"n": 30}), "pay for Faris's year in secret")
	check_wallet(45, 25, "secret school payment spends coins without adding trust")
	check(visible_text().contains("%s %s" % [copy.first_child, copy.secret]), "a secret first school payment still sponsors Faris")
	check_school_footer(copy.back, "QURANS GIVEN: 1 / 1,000 · CHILDREN IN SCHOOL: 1 / 100")
	await press_button(copy.back, "return after secret school payments")
	await press_button(app.chapter.purse.morning.to_rep, "view reputation after secret school payments")
	check(app.qurans_school.reputation_lines().is_empty() and visible_text().contains(app.chapter.rep.empty)
		and not visible_text().contains(school.say.qurans[0]) and not visible_text().contains(school.say.school[0]),
		"neither secret payment is visible in What people say")
	move_market_fixture("masjid")
	await press_button(school.masjid_button, "reopen the school after giving secretly")
	checkbox = find_button(app.ui, copy.secret_label) as CheckBox
	check(checkbox != null and not checkbox.button_pressed, "reopening clears the last visit's private selection")
	await press_button(str(copy.pay).format({"n": 25}), "make the day's first public payment after two secret gifts")
	check_wallet(46, 0, "secret payments do not consume the public trust award")
	check(app.qurans_school.reputation_lines() == [school.say.qurans], "a public Quran leaves only its own line")
	reset_at_market_place("masjid", 200, 1)
	check(app.qurans_school.qurans_given == 0 and app.qurans_school.children_in_school == 0
		and app.qurans_school.reputation_lines().is_empty(), "a new game clears both lifetime counters and public history")


func check_school_footer(back_copy: String, counter_copy: String) -> void:
	var back := find_button(app.ui, back_copy)
	var counters := find_visible_label(app.ui, counter_copy)
	check(back != null and counters != null and app.get_viewport().get_visible_rect().encloses(back.get_global_rect())
		and back.get_global_rect().has_point(Vector2(back.global_position.x, counters.global_position.y)),
		"the locked counters and Back button share a visible footer row")


func check_names_of_allah_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/NAMES_OF_ALLAH/RECORD/names_of_allah_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/names_of_allah.json")
	var copy: Dictionary = app.names_of_allah.data
	check(not approved.is_empty() and runtime == approved, "Names of Allah uses the exact LOCK 26 V1 data")
	check(copy == JSON.parse_string(runtime.get_string_from_utf8()), "the calligraphy uses the locked runtime data")

	app.set_process(false)
	app.begin_game()
	app.clock.skip_to(1, 600)
	for entry: Dictionary in copy.names:
		move_market_fixture(entry.place)
		check(find_button(app.ui, copy.button) == null, "calligraphy is hidden before Idris at " + str(entry.place))
		app.ui.calligraphy_requested.emit()
		check(app.ui.screen == "market_map" and app.names_of_allah.learned.is_empty(),
			"direct requests also require meeting Idris")

	move_market_fixture("masjid")
	await press_button(app.identity.clock.masjid_actions.none_yet, "Sit a while opens the Idris meeting")
	var teacher: Dictionary = app.identity.teacher
	await press_button(teacher.beats[0].choices[0].label, "the first Idris reply is available")
	await press_button(teacher.buttons.continue, "the first Idris reply continues")
	await press_button(teacher.buttons.leave, "an unfinished meeting can be left")
	check(not app.idris_met and find_button(app.ui, copy.button) == null, "an unfinished meeting keeps calligraphy hidden")
	await press_button(app.identity.clock.masjid_actions.none_yet, "Sit a while reopens the Idris meeting")
	for beat: Dictionary in teacher.beats:
		await press_button(beat.choices[0].label, "each Idris beat accepts the locked reply")
		await press_button(teacher.buttons.continue, "each Idris beat continues")
	await press_button(teacher.buttons.back, "the completed meeting returns to the map")
	check(app.idris_met, "finishing the meeting unlocks calligraphy")

	var named_places: Array = copy.names.map(func(entry): return entry.place)
	for place: String in data.places:
		move_market_fixture(place)
		check((find_button(app.ui, copy.button) != null) == (place in named_places),
			"after meeting Idris, calligraphy is offered only at locked places: " + place)
	move_market_fixture("spice")
	app.ui.calligraphy_requested.emit()
	check(app.ui.screen == "market_map" and app.names_of_allah.learned.is_empty(),
		"a direct request at Spice row changes nothing")

	var coins: int = app.progress.coins
	var trust: int = app.progress.trust
	var reputation: Array = app.ui.reputation_lines()
	var expected: Array[String] = []
	for entry: Dictionary in copy.names:
		move_market_fixture(entry.place)
		if expected.size() == 2:
			app.show_screen("game")
		await press_button(copy.button, "Read the calligraphy opens at " + str(entry.place))
		expected.append(entry.id)
		check(app.ui.screen == "names_of_allah" and app.names_of_allah.learned == expected,
			"reading learns exactly the Name at the current place")
		var arabic := find_visible_label(app.ui, entry.ar)
		check(arabic != null and arabic.text_direction == Control.TEXT_DIRECTION_RTL
			and arabic.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT, "the exact marked Arabic renders right to left")
		check(has_visible_label(app.ui, str(copy.panel.kicker).to_upper())
			and has_visible_label(app.ui, "%s · %s" % [entry.tr, entry.en])
			and visible_text().contains(entry.where) and visible_text().contains(entry.idris),
			"the kicker, translation, place and Idris explanation match the data")
		var count: String = copy.panel.count.format({"n": expected.size(), "m": int(copy.numbers.goal)})
		check(has_visible_label(app.ui, ("%s · %s" % [entry.ref, count]).to_upper()),
			"the locked reference and private count are shown")
		check_wallet(trust, coins, "learning a Name leaves coins and trust unchanged")
		check(app.ui.reputation_lines() == reputation, "learning a Name leaves reputation unchanged")
		await press_button(copy.panel.to_map, "the panel has a usable Back to the market map button")
		check(app.ui.screen == "market_map" and app.current_place == entry.place
			and find_button(app.ui, copy.button) == null and not visible_text().contains(count),
			"Back preserves the place and removes the learned Name and private count from the map")
		app.ui.calligraphy_requested.emit()
		check(app.ui.screen == "market_map" and app.names_of_allah.learned == expected,
			"a repeat request cannot learn the same Name twice")

	app.begin_game()
	check(not app.idris_met and app.names_of_allah.learned.is_empty(), "a new game clears this session's Names and Idris completion")
	app.set_process(true)


func check_regulars_at_prayer_runtime() -> void:
	var approved := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/REGULARS_AT_PRAYER/RECORD/regulars_at_prayer_data_V1.json")
	var runtime := FileAccess.get_file_as_bytes("res://data/regulars_at_prayer.json")
	var copy: Dictionary = app.market_day.prayer_data
	check(not approved.is_empty() and runtime == approved, "regulars at prayer uses the exact LOCK 27 V1 data")
	check(copy == JSON.parse_string(runtime.get_string_from_utf8()), "the prayer attendance uses the locked runtime data")
	app.set_process(false)
	reset_at_market_place("spice", 198)
	app.progress.apply_trust(45 - app.progress.trust)
	app.idris_met = true
	app.ui.idris_met = true
	var reputation: Array = app.ui.reputation_lines()
	var place_cases := [
		[3, 724, ""], [3, 725, "Dhuhr"], [3, 749, "Dhuhr"], [3, 750, ""],
		[3, 929, ""], [3, 930, "Asr"], [3, 940, "Asr"], [3, 954, "Asr"], [3, 955, ""],
		[2, 929, ""], [2, 930, "Asr"], [2, 940, "Asr"], [2, 954, "Asr"], [2, 955, ""],
	]
	for regular: Dictionary in app.talking.data.people:
		move_market_fixture(regular.place)
		for fixture: Array in place_cases:
			set_market_day_time(fixture[0], fixture[1])
			var prayer: String = fixture[2] if regular.id in copy.goers else ""
			check_regular_prayer_place(regular, prayer, copy)
	for fixture: Array in place_cases:
		move_market_fixture("masjid")
		set_market_day_time(fixture[0], fixture[1])
		check_masjid_prayer_attendance(fixture[2], copy)

	# Player prayer completion must not bring the regulars back early.
	set_market_day_time(2, 940)
	check(not app.clock.pray(true).is_empty(), "the player can still pray during the Friday Asr window")
	app.update_state()
	check_masjid_prayer_attendance("Asr", copy)

	move_market_fixture("spice")
	set_market_day_time(2, 730)
	var rashid: Dictionary = app.talking.regular_at("spice")
	check_market_place_hours(rashid, true, true, app.market_day.data)
	check(not has_visible_label(app.ui, str(copy.text.stall).format({"prayer": "Dhuhr"})),
		"Friday Dhuhr uses the prior Friday stall closure")
	check(find_button(app.ui, app.rashids_loan.data.ask_button) == null, "Friday Dhuhr still hides the loan")
	move_market_fixture("masjid")
	check_masjid_prayer_attendance("", copy)
	set_market_day_time(2, 760)
	check_masjid_prayer_attendance("", copy)

	check_wallet(45, 198, "regulars attending prayer leaves trust and coins unchanged")
	check(app.progress.daily_count == 0 and app.ui.reputation_lines() == reputation,
		"regulars attending prayer leaves score and reputation unchanged")
	app.set_process(true)


func check_regular_prayer_place(regular: Dictionary, prayer: String, copy: Dictionary) -> void:
	var context := "%s on day %d at minute %d" % [regular.name, app.day, app.minute_of_day]
	var away := not prayer.is_empty()
	var status := MarketDay.Status.AWAY_AT_PRAYER if away else MarketDay.Status.OPEN
	check(app.market_day.status(regular.id) == status, "prayer attendance for " + context)
	check((find_button(app.ui, app.talking.button_at(regular.place)) == null) == away, "prayer talk action for " + context)
	for name: String in ["Dhuhr", "Asr"]:
		var person: String = str(copy.text.person).format({"name": regular.name, "prayer": name})
		check(has_visible_label(app.ui, person) == (prayer == name), "exact %s place notice for %s" % [name, context])
	if away:
		app.show_talking()
		check(app.ui.screen == "market_map", "direct talk request is closed for " + context)
	if regular.id != "rashid":
		return
	var stall: String = app.market_stall.data.place.spice_button
	var loan: String = app.rashids_loan.data.ask_button
	check((find_button(app.ui, stall) == null) == away, "prayer stall action for " + context)
	check((find_button(app.ui, loan) == null) == away, "prayer loan bar for " + context)
	for name: String in ["Dhuhr", "Asr"]:
		var notice: String = str(copy.text.stall).format({"prayer": name})
		check(has_visible_label(app.ui, notice) == (prayer == name), "exact %s stall notice for %s" % [name, context])
	if away:
		app.show_stall()
		app.show_rashids_loan()
		check(app.ui.screen == "market_map", "direct stall and loan requests are closed for " + context)


func check_masjid_prayer_attendance(prayer: String, copy: Dictionary) -> void:
	var context := "day %d at minute %d" % [app.day, app.minute_of_day]
	var calligraphy := find_button(app.ui, app.names_of_allah.data.button)
	check(calligraphy != null, "the Masjid keeps the calligraphy action on " + context)
	for name: String in ["Dhuhr", "Asr"]:
		var notice: String = str(copy.text.masjid).format({"prayer": name, "names": "Rashid, Jamal, Old Musa"})
		var label := find_visible_label(app.ui, notice)
		check((label != null) == (prayer == name), "exact %s Masjid notice and names on %s" % [name, context])
		if label != null and calligraphy != null:
			check(label.position.x >= 0 and label.global_position.y >= calligraphy.get_global_rect().end.y
				and app.get_viewport().get_visible_rect().encloses(label.get_global_rect()),
				"the Masjid notice fits below the calligraphy action on " + context)
