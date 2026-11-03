extends RefCounted
## Saves the actual rendered viewport; no image generation or postprocessing.

const OUTPUT: String = "res://../GAME/APPROVED/LOOK_TEST/BUILT/"
const CAPTURES: Array = [
	["01_street_day.png", "Street", "day"],
	["02_street_night.png", "Street", "night"],
	["03_gate_night.png", "Gate", "night"],
	["04_river_night.png", "River", "night"],
	["05_market_day.png", "Market", "day"],
	["06_overview_dusk.png", "Overview", "dusk"],
]

func run(scene: Node3D, args: PackedStringArray) -> void:
	var tree: SceneTree = scene.get_tree()
	await tree.process_frame
	if "--check-controls" in args:
		await check_controls(scene)
		tree.quit(0)
		return
	var folder: String = ProjectSettings.globalize_path(OUTPUT)
	DirAccess.make_dir_recursive_absolute(folder)
	var report: Dictionary = {
		"engine": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(),
		"driver": RenderingServer.get_current_rendering_driver_name(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"timestamp_utc": Time.get_datetime_string_from_system(true) + "Z",
		"resolution": [1920, 1080],
		"settings": "Forward+, Metal, 2x MSAA + TAA, SSAO, SSIL, glow, soft shadows, light fog; vsync off; no export",
		"method": "Street fixed shot; 3 s warm-up then frames / elapsed wall time over 10 s; rendered viewport 1920x1080",
		"fps": {},
		"screenshots": [],
	}
	for mode: String in ["day", "night"]:
		scene.set_shot("Street")
		scene.set_time_of_day(mode)
		await tree.create_timer(3.0).timeout
		var count: int = 0
		var elapsed: float = 0.0
		var frame_ms: Array[float] = []
		var start: int = Time.get_ticks_usec()
		var previous: int = start
		while elapsed < 10.0:
			await RenderingServer.frame_post_draw
			var now: int = Time.get_ticks_usec()
			frame_ms.append(float(now - previous) / 1000.0)
			previous = now
			elapsed = float(now - start) / 1000000.0
			count += 1
		frame_ms.sort()
		var measurement: Dictionary = {
			"frames": count, "seconds": elapsed, "average": float(count) / elapsed,
			"p99_frame_ms": frame_ms[int(frame_ms.size() * 0.99)],
		}
		report.fps[mode] = measurement
		print("MEASURE ", mode, " ", JSON.stringify(measurement))
	if "--capture" in args:
		for item: Array in CAPTURES:
			scene.set_shot(item[1])
			scene.set_time_of_day(item[2])
			await tree.create_timer(2.0).timeout
			await RenderingServer.frame_post_draw
			var rendered: Image = scene.get_viewport().get_texture().get_image()
			assert(rendered.get_size() == Vector2i(1920, 1080), "Capture must be native 1920x1080")
			var result: Error = rendered.save_png(folder.path_join(item[0]))
			assert(result == OK, "Could not save actual viewport")
			report.screenshots.append({"file": item[0], "width": rendered.get_width(), "height": rendered.get_height()})
			print("CAPTURE ", item[0], " ", rendered.get_size())
	var record: FileAccess = FileAccess.open(folder.path_join("MEASUREMENTS.json"), FileAccess.WRITE)
	record.store_string(JSON.stringify(report, "\t") + "\n")
	record.close()
	tree.quit(0)

func check_controls(scene: Node3D) -> void:
	# Exercise real input dispatch, including physical key polling for flight.
	var tree: SceneTree = scene.get_tree()
	scene.capturing = false
	for index: int in range(4):
		var key: InputEventKey = InputEventKey.new()
		key.keycode = KEY_F1 + index
		key.pressed = true
		Input.parse_input_event(key)
		await tree.process_frame
		assert(scene.camera.global_position.is_equal_approx(scene.get_node("Shots/" + scene.SHOTS[index]).global_position))
	var start: Vector3 = scene.camera.global_position
	var move: InputEventKey = InputEventKey.new()
	move.keycode = KEY_W
	move.physical_keycode = KEY_W
	move.pressed = true
	Input.parse_input_event(move)
	await tree.create_timer(0.2).timeout
	move.pressed = false
	Input.parse_input_event(move)
	await tree.process_frame
	assert(scene.camera.global_position.distance_to(start) > 0.1, "W must move free-look camera")
	var mouse: InputEventMouseButton = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_RIGHT
	mouse.pressed = true
	Input.parse_input_event(mouse)
	await tree.process_frame
	assert(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)
	var before: Vector3 = scene.camera.rotation
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(60, 15)
	Input.parse_input_event(motion)
	await tree.process_frame
	assert(not scene.camera.rotation.is_equal_approx(before), "Mouse must turn camera")
	mouse.pressed = false
	Input.parse_input_event(mouse)
	await tree.process_frame
	assert(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)
	for item: Array in [[KEY_F5, "day"], [KEY_F6, "night"], [KEY_F7, "dusk"]]:
		var key: InputEventKey = InputEventKey.new()
		key.keycode = item[0]
		key.pressed = true
		Input.parse_input_event(key)
		await tree.process_frame
		assert(scene.time_of_day == item[1])
	print("CONTROLS PASS: four fixed shots; WASD flight input; mouse look/capture/release; day/night/dusk")
