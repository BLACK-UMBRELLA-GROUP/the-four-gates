extends RefCounted
## Native part-3 screenshots and a continuous playthrough using real GUI input.

const Helpers = preload("res://tests/capture_tasks.gd")
var helper := Helpers.new()
var output := "res://../GAME/APPROVED/FOUNDATIONS/BUILT/V1/"

func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	helper.report.engine = Engine.get_version_info().string
	helper.report.timestamp_utc = Time.get_datetime_string_from_system(true) + "Z"
	helper.report.method = "1920x1080 native viewport, actual viewport-local mouse hits and InputEventAction dispatch. Master fixtures reset progress/position; continuous six-shot playthrough uses Begin, physical map routes, board/choice buttons, scales buttons and E at gate, without progress/position edits."
	helper.report.fixtures = "f12-14 start lesson at scales. f15=100 trust/no lesson; f16=60 trust/no lesson; f17=100 trust/lesson done. f18=55 trust/12 coins and f19=100 trust/12 coins reproduce master HUD illustrations. Fixtures are independent of the continuous playthrough. Gate map captures use actual player at gate; prototype masters leave its marker at quay."
	helper.report.runtime_source_sha256 = {}
	for path: String in ["game/task_progress.gd", "game/river_market.gd", "game/market_ui.gd", "game/map_canvas.gd", "game/market_world.gd", "game/lesson_canvas.gd", "data/foundations.json", "tests/capture_gate.gd"]:
		helper.report.runtime_source_sha256["SOURCE/" + path] = FileAccess.get_sha256("res://" + path)
	app.progress.setup(app.data)
	app.player.position = app.world.point("scales")
	app.player.velocity = Vector3.ZERO
	app.show_screen("game")
	await helper.action(app, "use")
	await shot(app, "f12_learn__start__build.png")
	await click(app, app.data.lesson.options[0])
	await shot(app, "f13_learn__true_weight_level__build.png")
	var before := Vector2i(app.progress.trust, app.progress.coins)
	await click(app, app.data.lesson.answer_button.format({"n": 1}))
	helper.check(not app.progress.lesson_done and Vector2i(app.progress.trust, app.progress.coins) == before and app.ui.toast_label.text == app.data.lesson.wrong, "wrong answer changes nothing and shows retry toast")
	await shot(app, "part3_wrong_answer__build.png")
	app.ui.show_toast("")
	app.ui.toast_panel.hide()
	await click(app, app.data.lesson.options[int(app.data.lesson.false_weight_index)])
	await shot(app, "f14_learn__false_weight_found__build.png")
	app.progress.setup(app.data)
	app.progress.trust = int(app.data.numbers.gate_trust)
	app.player.position = app.world.point("gate")
	app.player.velocity = Vector3.ZERO
	app.show_screen("market_map")
	await helper.action(app, "use")
	helper.check(not app.progress.gate_open and app.world.gate_body.collision_layer != 0, "native gate closed at 100 trust without lesson")
	await shot(app, "f15_market_map__gate_needs_lesson__build.png")
	app.progress.trust = 60
	app.update_state()
	await helper.action(app, "use")
	await shot(app, "f16_market_map__gate_needs_trust__build.png")
	app.progress.trust = 55
	app.progress.coins = 12
	await helper.action(app, "goal")
	await shot(app, "f18_goal__in_progress__build.png")

	if "--masters-only" in OS.get_cmdline_user_args():
		helper.report.method = "Final master-state fixtures only, using actual native viewport mouse hits and E/G actions. The separately preserved PART3_MEASUREMENTS.json records the earlier uninterrupted six-shot playthrough; only toast clearing changed in runtime code afterward."
		app.progress.trust = int(app.data.numbers.gate_trust)
		app.progress.lesson_done = true
		app.progress.coins = 0
		app.show_screen("market_map")
		await helper.action(app, "use")
		await app.get_tree().create_timer(0.9).timeout
		helper.check(app.progress.gate_open and app.world.gate_body.collision_layer == 0, "final native fixture opens physical gate")
		await shot(app, "f17_market_map__gate_open__build.png")
		app.progress.coins = 12
		app.update_state()
		await helper.action(app, "goal")
		helper.check(not app.ui.toast_panel.visible, "final goal panel has no stale gate toast")
		await shot(app, "f19_goal__gate_open__build.png")
		await click(app, app.data.ui.buttons.map)
		await click(app, app.data.ui.buttons.city_map)
		await shot(app, "f20_city_map__gate_open__build.png")
		finish(app, "PART3_MASTERS_MEASUREMENTS.json")
		return

	# Begin a fresh, uninterrupted honest playthrough. Only the earlier fixtures
	# above set positions or wallet values; every transition below is production.
	app.progress.setup(app.data)
	app.ui.toast_panel.hide()
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	await shot(app, "playthrough_01_start__build.png")
	await travel(app, "board")
	await helper.action(app, "use")
	for index in range(app.data.tasks.size()):
		var task: Dictionary = app.data.tasks[index]
		await click(app, app.data.ui.buttons.take_task.format({"n": int(task.pay_shown)}))
		await click(app, task.honest.choice)
		await shot(app, "playthrough_0%d_honest_%s__build.png" % [index + 2, task.id])
		await click(app, app.data.ui.buttons.back_to_board)
	helper.check(app.progress.trust == 75 and app.progress.coins == 12, "native three honest tasks = 75 trust / 12 coins")
	await click(app, app.data.ui.buttons.back_to_market_map)
	await travel(app, "scales")
	await helper.action(app, "use")
	await click(app, app.data.lesson.options[int(app.data.lesson.false_weight_index)])
	await click(app, app.data.lesson.answer_button.format({"n": int(app.data.lesson.false_weight_index) + 1}))
	helper.check(app.progress.lesson_done and app.progress.trust == 100 and app.progress.coins == 12 and app.ui.screen == "game", "native honest playthrough plus lesson = 100 trust / 12 coins")
	await shot(app, "playthrough_05_lesson_done__build.png")
	await helper.action(app, "use")
	helper.check(app.progress.trust == 100 and app.ui.toast_label.text == app.data.other_text.scales_after_lesson, "completed scales action pays no second reward")
	await travel(app, "gate")
	await helper.action(app, "use")
	await app.get_tree().create_timer(0.9).timeout
	helper.check(app.progress.gate_open and app.world.gate_body.collision_layer == 0 and is_equal_approx(app.world.gate_hinge.rotation.y, -PI / 2), "native gate swings open and clears collision")
	await shot(app, "playthrough_06_gate_open__build.png")
	await helper.action(app, "market_map")
	await helper.action(app, "use")
	# f17 master illustrates 0 coins; preserve the real 12-coin playthrough above.
	app.progress.coins = 0
	app.update_state()
	await shot(app, "f17_market_map__gate_open__build.png")
	app.progress.coins = 12
	app.update_state()
	await helper.action(app, "goal")
	await shot(app, "f19_goal__gate_open__build.png")
	await click(app, app.data.ui.buttons.map)
	await click(app, app.data.ui.buttons.city_map)
	await shot(app, "f20_city_map__gate_open__build.png")
	app.ui.map.city_gate_requested.emit(0)
	helper.check(app.ui.toast_label.text == app.data.city_map.gate_open_message, "native open city gate uses its approved message")
	finish(app, "PART3_MEASUREMENTS.json")

func finish(app: Node3D, receipt: String) -> void:
	helper.report.failures = helper.failures
	var file := FileAccess.open(output.path_join(receipt), FileAccess.WRITE)
	file.store_string(JSON.stringify(helper.report, "\t") + "\n")
	print("PART3 NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)

func click(app: Node3D, label: String) -> void:
	await helper.click(app, label, true)

func shot(app: Node3D, filename: String) -> void:
	await helper.capture(app, filename)
	helper.report.states[filename].lesson_done = app.progress.lesson_done
	helper.report.states[filename].tried_weight = app.progress.tried_weight
	helper.report.states[filename].gate_open = app.progress.gate_open
	helper.report.states[filename].player = [app.player.position.x, app.player.position.y, app.player.position.z]

func travel(app: Node3D, place: String) -> void:
	if app.ui.screen != "market_map":
		await helper.action(app, "market_map")
	var at: Vector2 = app.ui.map.project_point(app.data.places[place])
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = at
		event.global_position = at
		event.pressed = pressed
		app.get_viewport().push_input(event, true)
		await app.get_tree().process_frame
	var deadline := Time.get_ticks_msec() + 90000
	while not app.route.is_empty() and Time.get_ticks_msec() < deadline:
		await app.get_tree().physics_frame
	app.update_state()
	helper.check(app.current_place == place and app.route.is_empty(), "physical map route arrives at " + place)
	if app.current_place != place:
		app.get_tree().quit(1)
