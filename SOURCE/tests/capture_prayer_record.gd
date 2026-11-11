extends "res://tests/capture_identity.gd"
## DOC-TFG-0035: LOCK 8 native evidence from the real prayer and navigation controls.

const OUTPUT := "res://../GAME/APPROVED/PRAYER_RECORD/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/PRAYER_RECORD/RECORD/prayer_record_data_V1.json"
const MASTER_STEMS := [
	"r01_title__your_prayers_button",
	"r02_all_prayers__empty_from_title",
	"r03_all_prayers__from_title",
	"r04_today__all_prayers_button",
	"r05_all_prayers__from_market",
	"r06_all_prayers__fridays",
]
const ORDINARY := [4, 2, 1, 1, 0, 0, 1, 1]
const FRIDAYS := [6, 3, 1, 2, 1, 1, 1, 1]


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--prayer-record-output="):
			return argument.trim_prefix("--prayer-record-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Prayer record capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create prayer record evidence directory")
		app.get_tree().quit(1)
		return
	app.get_tree().auto_accept_quit = false
	app.get_tree().root.close_requested.connect(func():
		helper.check(false, "capture window stayed open through the native run")
		finish(app)
	)
	helper.report.erase("fps")
	helper.report.engine = Engine.get_version_info().string
	helper.report.timestamp_utc = Time.get_datetime_string_from_system(true) + "Z"
	helper.report.renderer = RenderingServer.get_current_rendering_method()
	helper.report.driver = RenderingServer.get_current_rendering_driver_name()
	helper.report.gpu = RenderingServer.get_video_adapter_name()
	helper.report.resolution = [1920, 1080]
	helper.report.method = "Real Godot viewport with native game rendering. Viewport clicks exercise the arrival, market maps, clock, prayers and record controls."
	helper.report.fixture = "Passive ticks are paused. The harness stages times and locations and excludes intervening prayer windows via skip_to; no totals or UI values are injected. The ordinary history ends Saturday day 3 at 10:00 with Fajr made up. Friday histories use days 9 and 16, displayed Saturday day 17 at 10:00."
	app.set_process(false)
	var data: Dictionary = app.ui.prayer_record
	var copy: Dictionary = data.panel
	helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/prayer_record.json"), "runtime and locked prayer record bytes match")

	check_title_buttons(app, data)
	await capture_state(app, 0)
	await click(app, data.title_button)
	helper.check(app.ui.screen == "all_prayers_title" and app.ui.clock_panel == null, "title opens private totals with no HUD")
	helper.check(find_label(app.ui.content, copy.empty) != null, "title shows the locked empty message")
	check_panel_buttons(app, copy, true)
	await capture_state(app, 1)
	await click(app, copy.back_title)
	helper.check(app.ui.screen == "title", "empty totals return to title")
	await click(app, data.title_button)
	await helper.action(app, "close")
	helper.check(app.ui.screen == "title", "Escape from title totals returns to title")

	await click(app, app.data.ui.buttons.begin)
	for beat: Dictionary in app.identity.arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, app.identity.arrival.continue)
	await click(app, app.identity.arrival.buttons[1])
	if not helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival opens the market map"):
		finish(app)
		return
	var coins: int = app.progress.coins
	var trust: int = app.progress.trust

	app.clock.reset()
	await pray_at(app, 1, 1095, "masjid", app.identity.clock.pray_congregation)
	await pray_at(app, 1, 1200, "masjid", str(app.identity.clock.pray_here).format({"prayer": "Isha"}))
	await pray_at(app, 2, 285, "masjid", app.identity.clock.pray_congregation)
	await pray_at(app, 2, 930, "inn", str(app.identity.clock.pray_here).format({"prayer": "Asr"}))
	app.clock.skip_to(2, 1170)
	app.clock.advance_to(3, 590, false)
	app.update_state()
	await click(app, app.clock.make_up_label())
	helper.check(app.day == 3 and app.minute_of_day == 600 and not app.clock.is_friday(), "ordinary history reaches the later non-Friday at 10:00")

	await click(app, app.data.ui.buttons.city_map)
	await click(app, app.identity.ui.world_map)
	await click(app, app.identity.ui.title_back)
	await click(app, data.title_button)
	check_rows(app, data, ORDINARY)
	check_panel_buttons(app, copy, true)
	await capture_state(app, 2)
	await click(app, copy.back_title)
	await helper.action(app, "market_map")
	# The title ignores the market shortcut. Resume the existing session through
	# the same market screen visited before going to the title.
	helper.check(app.ui.screen == "title", "title shortcut does not change the session")
	app.show_screen("market_map")
	await helper.action(app, "market_map")
	helper.check(app.ui.screen == "game", "street view opens from the market map")
	await open_today(app)
	helper.check(find_label(app.ui.content, "04:45 · " + str(app.identity.clock.status.madeup)) != null, "today shows the made-up Fajr")
	await capture_state(app, 3)
	await click(app, data.record_button)
	helper.check(app.ui.screen == "all_prayers" and is_instance_valid(app.ui.clock_panel), "today opens private totals with HUD")
	check_rows(app, data, ORDINARY)
	check_panel_buttons(app, copy, false)
	await capture_state(app, 4)
	helper.check(app.world.night and not app.clock.night, "totals use the night backdrop while the live clock stays at 10:00")
	await click(app, copy.today)
	helper.check(not app.world.night, "today’s record restores the live daytime lighting")
	helper.check(app.ui.screen == "prayer_record", "Today’s prayers returns to the current day")
	await click(app, data.record_button)
	await click(app, copy.back_market)
	helper.check(app.ui.screen == "game", "Back to the market returns to the street")

	app.show_screen("market_map")
	await pray_at(app, 9, 725, "masjid", app.identity.clock.pray_friday)
	await pray_at(app, 16, 725, "inn", app.identity.clock.pray_here_friday)
	app.clock.skip_to(17, 600)
	app.update_state()
	await open_today(app)
	await click(app, data.record_button)
	check_rows(app, data, FRIDAYS)
	check_panel_buttons(app, copy, false)
	await capture_state(app, 5)
	await helper.action(app, "close")
	helper.check(app.ui.screen == "prayer_record", "Escape from market totals returns to today")
	await click(app, data.record_button)
	await click(app, copy.back_market)
	helper.check(app.ui.screen == "market_map", "Back to the market also returns to the map")
	helper.check(app.progress.coins == coins and app.progress.trust == trust, "prayers, making up Fajr and viewing totals never award coins or trust")
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all six locked states captured")
	finish(app)


func check_title_buttons(app: Node3D, data: Dictionary) -> void:
	var begin: Button = helper.find_button(app.ui, app.data.ui.buttons.begin)
	var prayers: Button = helper.find_button(app.ui, data.title_button)
	var settings: Button = helper.find_button(app.ui, app.data.ui.buttons.settings)
	helper.check(begin != null and prayers != null and settings != null and begin.position.x < prayers.position.x and prayers.position.x < settings.position.x, "Your prayers sits between Begin and Settings")


func check_panel_buttons(app: Node3D, copy: Dictionary, from_title: bool) -> void:
	helper.check((helper.find_button(app.ui, copy.back_title) != null) == from_title, "Title button visibility matches the entry point")
	helper.check((helper.find_button(app.ui, copy.today) != null) == not from_title, "Today button visibility matches the entry point")
	helper.check((helper.find_button(app.ui, copy.back_market) != null) == not from_title, "Market button visibility matches the entry point")
	helper.check(find_label(app.ui.content, str(copy.kicker).to_upper()) != null, "locked totals kicker is visible")
	helper.check(find_label(app.ui.content, copy.title) != null, "locked totals title is visible")
	helper.check(find_label(app.ui.content, str(copy.note).to_upper()) != null, "locked privacy note is visible")


func check_rows(app: Node3D, data: Dictionary, expected: Array) -> void:
	var order: Array = data.rows.keys()
	var previous_y := -1.0
	for index in order.size():
		var label := find_label(app.ui.content, data.rows[order[index]])
		if not helper.check(label != null and label.position.y > previous_y, "locked row in order: " + str(order[index])):
			continue
		previous_y = label.position.y
		var expected_count: String = str(data.count).format({"n": expected[index]})
		var found := false
		for item in label.get_parent().get_children():
			if item is Label and item.position.y == previous_y and item.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
				found = item.text == expected_count
		helper.check(found, "rendered right-aligned count: " + str(order[index]) + " = " + expected_count)
		helper.check(label.position.x == (64 if index in [1, 2, 3] else 34), "locked indent: " + str(order[index]))
	helper.check(find_label(app.ui.content, data.panel.empty) == null, "nonempty totals omit the empty message")


func find_label(node: Node, value: String) -> Label:
	if node is Label and node.is_visible_in_tree() and node.text == value:
		return node
	for child in node.get_children():
		var label := find_label(child, value)
		if label != null:
			return label
	return null


func pray_at(app: Node3D, day: int, minute: int, place: String, button: String) -> void:
	app.clock.skip_to(day, minute)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()
	await click(app, button)


func open_today(app: Node3D) -> void:
	await hit(app, app.ui.clock_panel.get_global_rect().get_center())
	helper.check(app.ui.screen == "prayer_record", "native clock opens today’s record")


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.totals = app.clock.totals()
	state.rendered_night = app.world.night


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE15_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("PRAYER RECORD NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
