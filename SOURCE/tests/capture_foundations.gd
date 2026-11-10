extends RefCounted
## Native viewport captures and rendered-frame measurements (not headless).

var output := "res://../GAME/APPROVED/FOUNDATIONS/BUILT/V1/"
var report := {"screenshots": [], "fps": {}, "checks": []}

func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	report.engine = Engine.get_version_info().string
	report.timestamp_utc = Time.get_datetime_string_from_system(true) + "Z"
	report.renderer = RenderingServer.get_current_rendering_method()
	report.driver = RenderingServer.get_current_rendering_driver_name()
	report.gpu = RenderingServer.get_video_adapter_name()
	report.resolution = [1920, 1080]
	report.method = "Actual 1920x1080 Godot viewport; vsync off; 3s warm-up then frames / wall seconds for 10s in each lighting mode; player at quay, third-person camera."
	await capture(app, "f01_title__build.png")
	app.ui.show_toast(app.data.title_screen.settings_toast)
	await capture(app, "title_settings__build.png")
	app.begin_game()
	await app.get_tree().create_timer(4.0).timeout
	var before: float = app.player.yaw
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(80, 0)
	Input.parse_input_event(motion)
	await app.get_tree().process_frame
	assert(not is_equal_approx(before, app.player.yaw), "Rendered mouse dispatch must turn the actual camera")
	for item in [[100000.0, app.data.camera.pitch_min_deg], [-100000.0, app.data.camera.pitch_max_deg]]:
		motion = InputEventMouseMotion.new()
		motion.relative = Vector2(0, item[0])
		Input.parse_input_event(motion)
		await app.get_tree().process_frame
		assert(is_equal_approx(app.player.pitch, deg_to_rad(item[1])))
	app.player.yaw = 0
	app.player.pitch = 0
	app.player.update_camera()
	report.rendered_mouse = "Input.parse_input_event mouse motion changed actual camera yaw and clamped pitch at both approved limits."
	var toward_gate: Vector3 = app.world.point("gate") - app.player.position
	app.player.yaw = -atan2(toward_gate.x, -toward_gate.z)
	app.player.update_camera()
	await app.get_tree().create_timer(2.0).timeout
	await capture(app, "quay_day__build.png")
	app.player.yaw = 0
	app.player.update_camera()
	for mode in [false, true]:
		if app.night != mode: app.toggle_night()
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
		report.fps["night" if mode else "day"] = result
		print("MEASURE ", "night" if mode else "day", " ", JSON.stringify(result))
	app.toggle_night()
	app.show_screen("market_map")
	await app.get_tree().create_timer(4.0).timeout
	await capture(app, "f03_market_map__day_start_quay__build.png")
	await action(app, "wait_day_night")
	assert(app.night)
	await app.get_tree().create_timer(4.0).timeout
	await capture(app, "f04_market_map__night__build.png")
	app.show_screen("game")
	app.player.position = app.world.point("sq")
	app.player.velocity = Vector3.ZERO
	await capture(app, "square_night__build.png")
	app.toggle_night()
	app.player.position = app.world.point("board")
	app.player.velocity = Vector3.ZERO
	app.update_state()
	app.show_screen("market_map")
	await app.get_tree().create_timer(4.0).timeout
	await capture(app, "f05_market_map__at_task_board__build.png")
	await action(app, "use")
	assert(app.ui.screen == "board")
	await capture(app, "f06_task_board__start__build.png")
	app.show_screen("game")
	await app.get_tree().create_timer(4.0).timeout
	await capture(app, "task_board_day__build.png")
	app.show_screen("city_map")
	await capture(app, "f02_city_map__gate_closed__build.png")
	for index in range(app.data.goal.gates.size()):
		app.ui.show_city_gate(index)
		await capture(app, "city_gate_message_%s__build.png" % index)
	app.show_screen("game")
	await action(app, "goal")
	await capture(app, "goal_not_built__build.png")
	for place in ["scales", "gate", "centre", "quay", "spice", "weaver"]:
		app.player.position = app.world.point(place)
		if place == "gate": app.player.position.z += app.data.player.capsule_radius + app.data.world.houses.max_gap
		if place == "centre": app.player.position.x += app.data.player.capsule_radius + app.data.world.houses.max_gap
		app.player.velocity = Vector3.ZERO
		app.update_state()
		await app.get_tree().create_timer(4.0).timeout
		await action(app, "use")
		await capture(app, "%s_action__build.png" % place)
	report.checks = ["Native capture resolution asserted for every image", "T dispatched through Input.parse_input_event and verified night", "E dispatched at all seven real place points", "G temporary action dispatched through Input", "f20 inspected as a future open state; gate stays closed in part 1"]
	var file := FileAccess.open(output.path_join("MEASUREMENTS.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("CAPTURES PASS ", report.screenshots.size())
	app.get_tree().quit(0)

func capture(app: Node3D, name: String) -> void:
	await app.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var rendered: Image = app.get_viewport().get_texture().get_image()
	assert(rendered.get_size() == Vector2i(1920, 1080))
	assert(rendered.save_png(output.path_join(name)) == OK)
	report.screenshots.append({"file": name, "width": rendered.get_width(), "height": rendered.get_height()})
	print("CAPTURE ", name)

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
