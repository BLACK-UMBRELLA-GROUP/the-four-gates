extends RefCounted
## Native LOCK 1 part-2 evidence, driven through real buttons and input actions.

var output := "res://../GAME/APPROVED/FOUNDATIONS/BUILT/V1/"
var report := {"screenshots": [], "fps": {}, "checks": [], "states": {}}
var failures := 0


func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	report.engine = Engine.get_version_info().string
	report.timestamp_utc = Time.get_datetime_string_from_system(true) + "Z"
	report.renderer = RenderingServer.get_current_rendering_method()
	report.driver = RenderingServer.get_current_rendering_driver_name()
	report.gpu = RenderingServer.get_video_adapter_name()
	report.resolution = [1920, 1080]
	report.runtime_source_sha256 = {}
	for path: String in ["project.godot", "data/foundations.json", "game/foundations.gd", "game/map_canvas.gd", "game/market_player.gd", "game/market_world.gd", "game/market_ui.gd", "game/river_market.gd", "game/river_market.tscn", "game/task_progress.gd", "tests/capture_tasks.gd"]:
		report.runtime_source_sha256["SOURCE/" + path] = FileAccess.get_sha256("res://" + path)
	report.method = "Actual 1920x1080 Godot viewport. E opens the board; real task/choice/result/amends/job buttons are pressed. T dispatches day/night. Native fps: vsync off, 3s warm-up and frames / 10 wall seconds per lighting mode at the quay."
	report.fixture = "Progress setup resets between independent sequences; board-place positioning is a capture fixture. Rewards always use real buttons. The supplemental insufficient-funds capture sets the wallet to zero after the real quick spice choice solely to render that approved state; this is disclosed in its state record. No approved data changes."
	report.master_difference = "f11 shows the job done with the earlier 31 coins / 0 trust HUD. The explicit V2 job reward produces 33 coins / 5 trust; the native capture records that live result."
	await reset_board(app)
	await capture(app, "f06_task_board__start__build.png")
	var spice: Dictionary = app.data.tasks[0]
	await take_task(app, spice, true)
	if not check(app.ui.screen == "task", "viewport-local mouse hit opens the task choice screen without a signal fallback"):
		finish(app)
		return
	await capture(app, "f07_task__choice__build.png")
	await click(app, spice.honest.choice)
	check(app.progress.coins == 4 and app.progress.trust == 35, "honest spice result is 4 coins / 35 trust")
	await capture(app, "f08_result__honest__build.png")
	await click(app, app.data.ui.buttons.see_goal)
	check(app.ui.screen == "goal", "result goal button opens the goal screen")
	await capture(app, "part2_result_goal__build.png")
	await click(app, app.data.ui.buttons.back_to_market)
	app.show_board()
	for index in range(1, app.data.tasks.size()):
		var task: Dictionary = app.data.tasks[index]
		await take_task(app, task)
		await capture(app, "part2_task_%s__build.png" % task.id)
		await click(app, task.honest.choice)
		await capture(app, "part2_result_%s_honest__build.png" % task.id)
		await click(app, app.data.ui.buttons.back_to_board)
	check(app.progress.coins == 12 and app.progress.trust == 75, "all honest yields 12 coins / 75 trust")
	await capture(app, "part2_all_honest__build.png")

	await reset_board(app)
	for task: Dictionary in app.data.tasks:
		await take_task(app, task)
		await click(app, task.quick.choice)
		if task.id == spice.id:
			check(app.progress.coins == 6 and app.progress.trust == 10, "quick spice result is 6 coins / 10 trust")
			await capture(app, "f09_result__quick__build.png")
		else:
			await capture(app, "part2_result_%s_quick__build.png" % task.id)
		await click(app, app.data.ui.buttons.back_to_board)
	check(app.progress.coins == 31 and app.progress.trust == 0, "all quick yields 31 coins / 0 trust")
	await capture(app, "f10_task_board__amends_and_daily_job__build.png")
	await click(app, str(app.data.ui.buttons.do_job).format({"n": int(app.data.daily_job.coins)}))
	check(app.progress.coins == 33 and app.progress.trust == 5 and app.progress.daily_count == 1, "daily boat job applies 2 coins and 5 trust once")
	check(find_button(app.ui, str(app.data.ui.buttons.do_job).format({"n": int(app.data.daily_job.coins)})) == null, "used daily job has no repeat reward button")
	await settle_toast(app)
	await capture(app, "f11_task_board__daily_job_done__build.png")
	await action(app, "wait_day_night")
	check(app.night and app.progress.daily_count == 1, "day to night preserves the used daily job")
	await settle_toast(app)
	await capture(app, "part2_daily_job_still_used_at_night__build.png")
	await action(app, "wait_day_night")
	check(not app.night and app.progress.daily_count == 0, "night to day restores the daily job")
	await settle_toast(app)
	await capture(app, "part2_daily_job_next_morning__build.png")
	await click(app, str(app.data.ui.buttons.do_job).format({"n": int(app.data.daily_job.coins)}))
	check(app.progress.coins == 35 and app.progress.trust == 10, "the restored job pays once the next morning")

	await reset_board(app)
	for task: Dictionary in app.data.tasks:
		await take_task(app, task)
		await click(app, task.quick.choice)
		await click(app, app.data.ui.buttons.back_to_board)
	for task: Dictionary in app.data.tasks:
		await click(app, app.data.ui.buttons.put_right)
		check(app.progress.tasks.has(task.id) and app.progress.tasks[task.id].amended, "real amends button repairs " + str(task.id))
	check(app.progress.coins == 0 and app.progress.trust == 75, "all quick followed by all amends yields 0 coins / 75 trust")
	await settle_toast(app)
	await capture(app, "part2_all_amends__build.png")
	await reset_board(app)
	await take_task(app, spice)
	await click(app, spice.quick.choice)
	await click(app, app.data.ui.buttons.back_to_board)
	app.progress.coins = 0
	app.update_state()
	await app.get_tree().process_frame
	check(find_button(app.ui, app.data.ui.buttons.put_right) == null, "insufficient wallet fixture has no affordable-amends button")
	await capture(app, "part2_insufficient_fixture__build.png")
	report.states["part2_insufficient_fixture__build.png"].fixture = "wallet set to zero after a real quick spice choice; approved need-coins rendering check"

	app.player.position = app.world.point(app.data.start_place)
	app.player.velocity = Vector3.ZERO
	app.player.yaw = 0.0
	app.player.pitch = 0.0
	app.player.update_camera()
	app.show_screen("game")
	await measure(app, false)
	await measure(app, true)
	finish(app)


func reset_board(app: Node3D) -> void:
	app.progress.setup(app.data)
	if app.night:
		await action(app, "wait_day_night")
	app.player.position = app.world.point("board")
	app.player.velocity = Vector3.ZERO
	app.player.yaw = 0.0
	app.player.pitch = 0.0
	app.player.update_camera()
	app.route.clear()
	app.player.test_move_axis = Vector2.ZERO
	app.show_screen("game")
	await app.get_tree().process_frame
	await action(app, "use")
	check(app.ui.screen == "board", "E at the real board opens the task board")
	await settle_toast(app)


func take_task(app: Node3D, task: Dictionary, mouse: bool = false) -> void:
	await click(app, str(app.data.ui.buttons.take_task).format({"n": int(task.pay_shown)}), mouse)
	check(app.ui.task_id == task.id, "board opens the selected task " + str(task.id))


func click(app: Node3D, label: String, mouse: bool = false) -> void:
	var button := find_button(app.ui, label)
	if not check(button != null, "visible real button exists: " + label):
		return
	if mouse:
		var at := button.get_global_rect().get_center()
		var motion := InputEventMouseMotion.new()
		motion.position = at
		motion.global_position = at
		app.get_viewport().push_input(motion, true)
		await app.get_tree().process_frame
		for pressed: bool in [true, false]:
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = pressed
			event.position = at
			event.global_position = at
			app.get_viewport().push_input(event, true)
			await app.get_tree().process_frame
		report.mouse_button = {"label": label, "viewport_position": [at.x, at.y], "method": "Viewport.push_input(event, true) sends local InputEventMouseMotion and left InputEventMouseButton press/release through the real GUI hit region; no signal fallback"}
	else:
		button.pressed.emit()
	await app.get_tree().process_frame
	await app.get_tree().process_frame


func find_button(node: Node, label: String) -> Button:
	if node is Control and not node.is_visible_in_tree():
		return null
	if node is Button and node.text == label and not node.disabled:
		return node
	for child in node.get_children():
		var found := find_button(child, label)
		if found != null:
			return found
	return null


func check(condition: bool, description: String) -> bool:
	report.checks.append({"passed": condition, "description": description})
	if not condition:
		failures += 1
		push_error("NATIVE PART2 FAIL: " + description)
	return condition


func settle_toast(app: Node3D) -> void:
	if app.ui.toast_panel.visible:
		await app.get_tree().create_timer(3.6).timeout


func capture(app: Node3D, filename: String) -> void:
	await app.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var rendered: Image = app.get_viewport().get_texture().get_image()
	check(rendered.get_size() == Vector2i(1920, 1080), "native 1920x1080 image: " + filename)
	check(rendered.save_png(output.path_join(filename)) == OK, "PNG saved: " + filename)
	report.screenshots.append({"file": filename, "width": rendered.get_width(), "height": rendered.get_height()})
	report.states[filename] = {"coins": app.progress.coins, "trust": app.progress.trust, "daily_count": app.progress.daily_count, "night": app.night, "screen": app.ui.screen, "tasks": app.progress.tasks.duplicate(true)}
	print("PART2 CAPTURE ", filename)


func action(app: Node3D, name: String) -> void:
	var event := InputEventAction.new()
	event.action = name
	event.pressed = true
	Input.parse_input_event(event)
	await app.get_tree().process_frame
	event = InputEventAction.new()
	event.action = name
	event.pressed = false
	Input.parse_input_event(event)
	await app.get_tree().process_frame


func measure(app: Node3D, night_value: bool) -> void:
	if app.night != night_value:
		await action(app, "wait_day_night")
	await app.get_tree().create_timer(3.0).timeout
	var count := 0
	var elapsed := 0.0
	var frame_ms: Array[float] = []
	var start := Time.get_ticks_usec()
	var previous := start
	while elapsed < 10.0:
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		frame_ms.append(float(now - previous) / 1000.0)
		previous = now
		elapsed = float(now - start) / 1000000.0
		count += 1
	frame_ms.sort()
	var result := {"frames": count, "seconds": elapsed, "average": count / elapsed, "p99_frame_ms": frame_ms[int(frame_ms.size() * 0.99)]}
	report.fps["night" if night_value else "day"] = result
	print("PART2 MEASURE ", "night" if night_value else "day", " ", JSON.stringify(result))


func finish(app: Node3D) -> void:
	report.failures = failures
	var file := FileAccess.open(output.path_join("PART2_MEASUREMENTS.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("PART2 NATIVE ", "PASS" if failures == 0 else "FAIL", " ", report.checks.size(), " checks; ", report.screenshots.size(), " captures")
	app.get_tree().quit(0 if failures == 0 else 1)
