extends RefCounted
## Line 5 native viewport evidence; real GUI hits and physical street routes.

const Helpers = preload("res://tests/capture_tasks.gd")
var helper := Helpers.new()
var output := "res://../GAME/APPROVED/IDENTITY/BUILT/V1/"

func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	app.get_tree().auto_accept_quit = false
	app.get_tree().root.close_requested.connect(func():
		helper.check(false, "capture window stayed open through the native run")
		finish(app)
	)
	helper.output = output
	helper.report.engine = Engine.get_version_info().string
	helper.report.timestamp_utc = Time.get_datetime_string_from_system(true) + "Z"
	helper.report.renderer = RenderingServer.get_current_rendering_method()
	helper.report.driver = RenderingServer.get_current_rendering_driver_name()
	helper.report.gpu = RenderingServer.get_video_adapter_name()
	helper.report.method = "Real native Godot viewport, 1920x1080. Viewport-local mouse motion/press/release dispatch through production hit regions and buttons, E/T input actions, physical walking on the approved street graph. No position/progress fixtures: title -> map -> Inn -> Masjid -> honest tasks -> scales -> gate."
	helper.report.resolution = [1920, 1080]
	helper.report.runtime_source_sha256 = {}
	for path: String in ["project.godot", "data/foundations.json", "data/identity.json", "game/foundations.gd", "game/map_canvas.gd", "game/market_ui.gd", "game/river_market.gd", "game/market_world.gd", "game/market_player.gd", "game/task_progress.gd", "game/lesson_canvas.gd", "game/river_market.tscn", "tests/capture_identity.gd", "tests/run_tests.gd"]:
		helper.report.runtime_source_sha256["SOURCE/" + path] = FileAccess.get_sha256("res://" + path)
	await shot(app, "g01_title__ilmara__build.png")
	await click(app, app.data.ui.buttons.begin)
	helper.check(app.ui.screen == "market_map" and app.progress.coins == 0 and app.progress.trust == 20, "Begin opens market map with LOCK 1 wallet/trust")
	await shot(app, "g15_market_map__day_inn_masjid_clock__build.png")
	await click(app, app.data.ui.buttons.city_map)
	await shot(app, "g12_city_map__build.png")
	await hit(app, Vector2(1219, 547))
	helper.check(app.ui.toast_label.text == app.identity.city.parts.east.name + ": " + app.identity.city.parts.east.line, "native East part shows its exact line")
	await shot(app, "g13_city_map__district_east__build.png")
	var parts := {"centre": Vector2(960, 547), "north": Vector2(960, 300), "west": Vector2(700, 547), "south": Vector2(960, 790)}
	for id: String in parts:
		await hit(app, parts[id])
		helper.check(app.ui.toast_label.text == app.identity.city.parts[id].name + ": " + app.identity.city.parts[id].line, "native part line: " + id)
	await click(app, app.identity.ui.world_map)
	if not helper.check(app.ui.screen == "world_map", "native World map button opens the world map"):
		finish(app)
		return
	await shot(app, "g11_world_map__build.png")
	for index in range(app.identity.world.towns_placeholder.size()):
		var town: Dictionary = app.identity.world.towns_placeholder[index]
		await hit(app, Vector2(town.x, town.y) * 4.8)
		helper.check(app.ui.toast_label.text == app.identity.world.town_toast.format({"town": town.name}), "native placeholder town: " + town.name)
	await click(app, app.identity.ui.title_back)
	helper.check(app.ui.screen == "title", "world Title button returns to title")
	await click(app, app.data.ui.buttons.begin)
	await click(app, app.data.ui.buttons.city_map)
	await click(app, app.identity.ui.world_map)
	await click(app, app.identity.ui.city_map)
	helper.check(app.ui.screen == "city_map", "world City map button opens city")
	await click(app, app.identity.ui.world_map)
	await hit(app, Vector2(960, 538))
	helper.check(app.ui.screen == "city_map", "world city symbol opens city")
	await hit(app, Vector2(1248, 652))
	helper.check(app.ui.screen == "market_map", "Your inn marker opens River Market")
	if "--masters-only" in OS.get_cmdline_user_args():
		await capture_gate_fixture(app)
		finish(app)
		return
	if not await travel(app, "inn"):
		return
	await helper.action(app, "use")
	helper.check(app.ui.toast_label.text == app.data.ui.not_built and app.progress.coins == 0, "Inn E action remains not built")
	await shot(app, "line5_inn__build.png")
	if not await travel(app, "masjid"):
		return
	await helper.action(app, "use")
	helper.check(app.ui.toast_label.text == app.data.ui.not_built and app.progress.trust == 20, "Masjid E action remains not built")
	await shot(app, "line5_masjid__build.png")
	await helper.action(app, "wait_day_night")
	helper.check(app.night, "T retains the LOCK 1 night switch")
	await shot(app, "line5_night__build.png")
	await helper.action(app, "wait_day_night")
	helper.check(not app.night, "T retains the LOCK 1 morning switch")
	if not await travel(app, "board"):
		return
	await helper.action(app, "use")
	for task: Dictionary in app.data.tasks:
		await click(app, app.data.ui.buttons.take_task.format({"n": int(task.pay_shown)}))
		await click(app, task.honest.choice)
		await click(app, app.data.ui.buttons.back_to_board)
	helper.check(app.progress.trust == 75 and app.progress.coins == 12, "native honest tasks retain LOCK 1 economy")
	await click(app, app.data.ui.buttons.back_to_market_map)
	if not await travel(app, "scales"):
		return
	await helper.action(app, "use")
	await click(app, app.data.lesson.options[int(app.data.lesson.false_weight_index)])
	await click(app, app.data.lesson.answer_button.format({"n": int(app.data.lesson.false_weight_index) + 1}))
	helper.check(app.progress.trust == 100 and app.progress.lesson_done, "native scales lesson supplies gate prerequisite")
	await helper.action(app, "market_map")
	if not await travel(app, "gate"):
		return
	await helper.action(app, "use")
	await app.get_tree().create_timer(0.9).timeout
	helper.check(app.progress.gate_open and app.world.gate_body.collision_layer == 0, "native gate opens with both prerequisites")
	await capture_open_gate(app)
	finish(app)

func capture_gate_fixture(app: Node3D) -> void:
	helper.report.method = "Real native Godot viewport, 1920x1080. Viewport-local mouse clicks exercise production maps and buttons. The g14 fixture places the player at the gate and sets each prerequisite in turn. The real use action drives the rule and hinge."
	helper.report.fixture = "Only g14 uses seeded player position, trust and lesson state. Title and map states use normal navigation. The headless suite separately walks both new routes using the real capsule and collisions."
	app.player.position = app.world.point("gate")
	app.player.velocity = Vector3.ZERO
	app.progress.trust = int(app.data.numbers.gate_trust)
	await helper.action(app, "use")
	helper.check(not app.progress.gate_open and app.world.gate_body.collision_layer != 0, "native gate stays closed with trust only")
	app.progress.trust -= 1
	app.progress.lesson_done = true
	await helper.action(app, "use")
	helper.check(not app.progress.gate_open and app.world.gate_body.collision_layer != 0, "native gate stays closed with lesson only")
	app.progress.trust = int(app.data.numbers.gate_trust)
	await helper.action(app, "use")
	await app.get_tree().create_timer(0.9).timeout
	helper.check(app.progress.gate_open and app.world.gate_body.collision_layer == 0 and is_equal_approx(app.world.gate_hinge.rotation.y, -PI / 2), "native gate swings open and clears collision with both prerequisites")
	await capture_open_gate(app)

func capture_open_gate(app: Node3D) -> void:
	await click(app, app.data.ui.buttons.city_map)
	helper.check(app.ui.screen == "city_map" and app.ui.map.gate_open, "native city map displays the open East gate")
	await shot(app, "g14_city_map__gate_of_trust_open__build.png")
	await click(app, app.identity.ui.world_map)
	await click(app, app.identity.ui.river_market)
	helper.check(app.ui.screen == "market_map", "world River Market button returns to market")

func finish(app: Node3D) -> void:
	helper.report.failures = helper.failures
	var file := FileAccess.open(output.path_join("CHECKS.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(helper.report, "\t") + "\n")
	print("IDENTITY NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)

func click(app: Node3D, label: String) -> void:
	var button: Button = helper.find_button(app.ui, label)
	if helper.check(button != null, "visible real button exists: " + label):
		await hit(app, button.get_global_rect().get_center())

func hit(app: Node3D, at: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = at
	motion.global_position = at
	app.get_viewport().push_input(motion, true)
	# Dispatch one complete click before native pointer events can interrupt it.
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = at
		event.global_position = at
		event.pressed = pressed
		app.get_viewport().push_input(event, true)
	await app.get_tree().process_frame

func shot(app: Node3D, filename: String) -> void:
	await helper.capture(app, filename)
	helper.report.states[filename].player = [app.player.position.x, app.player.position.y, app.player.position.z]
	helper.report.states[filename].gate_open = app.progress.gate_open
	helper.report.states[filename].lesson_done = app.progress.lesson_done

func travel(app: Node3D, id: String) -> bool:
	await hit(app, app.ui.map.project_point(app.data.places[id]))
	if not helper.check(app.destination == id, "native map marker starts the route to " + id):
		print("ROUTE ", id, " hit failed; screen=", app.ui.screen, " destination=", app.destination)
		finish(app)
		return false
	print("ROUTE ", id, " from ", app.player.position, " via ", app.route)
	var deadline := Time.get_ticks_msec() + 90000
	while not app.route.is_empty() and Time.get_ticks_msec() < deadline:
		await app.get_tree().physics_frame
	app.update_state()
	if not helper.check(app.current_place == id and app.route.is_empty(), "native physical street route reaches " + id):
		print("ROUTE ", id, " position=", app.player.position, " current place=", app.current_place, " screen=", app.ui.screen, " waypoints remaining=", app.route)
		finish(app)
		return false
	return true
