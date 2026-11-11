extends "res://tests/capture_identity.gd"
## DOC-TFG-0015: native captures from the real River Market viewport.

const OUTPUT := "res://../GAME/APPROVED/IDENTITY/BUILT/V1/CLOCK/"
const MASTER_STEMS := {
	"g15_market_map__day_inn_masjid_clock": "g15_market_map__day_inn_masjid_clock",
	"g19_market_map__masjid_sit_a_while": "g19_market_map__masjid_sit_a_while",
	"g20_market_map__asr_adhan_congregation": "g20_market_map__asr_adhan_congregation",
	"g21_market_map__pray_here": "g21_market_map__pray_here",
	"g22_record__day2_made_up": "g22_record__day",
	"g22b_record__day1_not_counted": "g22_record__day",
	"g23_market_map__day2_make_up": "g23_market_map__make_up",
	"g24_market_map__friday_prayer": "g24_market_map__friday_prayer",
}

static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--clock-output="):
			return argument.trim_prefix("--clock-output=")
	return OUTPUT

func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the clock evidence directory")
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
	helper.report.method = "Native Godot viewport. The capture freezes passive clock ticks for reproducible minutes. Arrival choices, T/P, the Wait button, prayers, and the record use production controls."
	helper.report.fixture = "Positions and selected clock minutes are seeded. The g15 wallet comes from the fair arrival; g19–g24 seed the masters' zero coins. g24 is a replay with previous prayers completed by the clock model before Friday's live congregation action."
	app.set_process(false)

	var arrival: Dictionary = app.identity.arrival
	await click(app, app.data.ui.buttons.begin)
	helper.check(app.day == 1 and app.minute_of_day == 390, "Begin starts Thursday at 06:30")
	for index in range(arrival.beats.size()):
		if index == 3:
			helper.check(app.minute_of_day == 390 and app.world.night, "arrival sunset backdrop begins before its time jump")
		await click(app, arrival.beats[index].choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	helper.check(app.current_place == "inn" and app.progress.coins == 198 and app.minute_of_day == 1095 and not app.world.night, "fair arrival reaches the Inn with 198 coins and clock-driven daylight at 18:15")

	app.clock.reset()
	app.clock.advance_to(1, 600, false)
	position_at(app, "quay")
	await capture_state(app, "g15_market_map__day_inn_masjid_clock")
	await key(app, KEY_M)
	helper.check(app.ui.screen == "game" and not app.world.night, "daylight in the actual street")
	await capture_state(app, "hud_day")
	await key(app, KEY_M)

	app.progress.coins = 0
	position_at(app, "masjid")
	await capture_state(app, "g19_market_map__masjid_sit_a_while")
	await click(app, app.identity.clock.masjid_actions.none_yet)
	helper.check(app.ui.screen == "market_map" and app.ui.toast_panel.visible and app.ui.toast_label.text == app.data.ui.not_built, "Sit a while shows the approved interim toast")
	await click(app, app.data.ui.buttons.wait_prayer)
	helper.check(app.minute_of_day == 725, "Wait button reaches the Dhuhr adhan")
	position_at(app, "board")
	await key(app, KEY_P)
	helper.check(app.minute_of_day == 735 and app.clock.record().rows[1].status == "alone", "P prays Dhuhr alone at the Task board")

	position_at(app, "masjid")
	await key(app, KEY_T)
	helper.check(app.minute_of_day == 930 and app.ui.toast_panel.visible and app.ui.toast_label.text == "Adhan: Asr has begun.", "T reaches the Asr adhan and shows its toast")
	app.clock.advance_to(1, 931, false)
	app.update_state()
	await capture_state(app, "g20_market_map__asr_adhan_congregation")

	position_at(app, "board")
	app.show_screen("market_map")
	await capture_state(app, "g21_market_map__pray_here")
	helper.check(helper.find_button(app.ui, "Pray Asr here") != null and helper.find_button(app.ui, app.identity.clock.pray_congregation) == null, "Task board offers solitary Asr only")
	position_at(app, "masjid")
	await click(app, app.identity.clock.pray_congregation)
	helper.check(app.clock.record().rows[2].status == "jamaah" and app.minute_of_day == 941, "Masjid congregation button records Asr and advances ten minutes")

	await key(app, KEY_T)
	app.clock.advance_to(1, 1100, false)
	await open_record(app)
	helper.check(app.clock.record().rows[0].text == "04:45 · not counted" and app.clock.make_up_label().is_empty(), "Thursday Fajr is not counted and cannot be made up")
	await capture_state(app, "g22b_record__day1_not_counted")
	await close_record(app)
	await key(app, KEY_P)
	await key(app, KEY_T)
	helper.check(app.minute_of_day == 1170 and app.night, "Isha starts at 19:30 and the clock drives night")
	position_at(app, "quay")
	await key(app, KEY_M)
	helper.check(app.ui.screen == "game" and app.world.night, "night lighting in the actual street")
	await capture_state(app, "hud_night")
	await key(app, KEY_M)
	await key(app, KEY_P)
	await key(app, KEY_T)
	helper.check(app.day == 2 and app.minute_of_day == 285, "waiting after Isha lands at Friday Fajr")

	await key(app, KEY_T)
	position_at(app, "board")
	helper.check(helper.find_button(app.ui, app.identity.clock.pray_here_friday) != null, "Friday away from the Masjid offers Dhuhr")
	await click(app, app.identity.clock.pray_here_friday)
	helper.check(app.clock.record().rows[1].status == "dhuhr_fri", "Friday Dhuhr records missed Friday prayer and prayed Dhuhr")
	position_at(app, "masjid")
	await key(app, KEY_T)
	await click(app, app.identity.clock.pray_congregation)
	position_at(app, "board")
	await key(app, KEY_T)
	app.clock.advance_to(2, 1100, false)
	app.show_screen("market_map")
	helper.check(app.clock.record().rows[0].text == "04:45 · missed", "Friday Fajr becomes missed")
	await capture_state(app, "g23_market_map__day2_make_up")
	await click(app, "Make up Fajr")
	helper.check(app.minute_of_day == 1110 and app.clock.record().rows[0].text == "04:45 · made up", "Friday Fajr make-up advances ten minutes and updates the record")
	await open_record(app)
	await capture_state(app, "g22_record__day2_made_up")
	await close_record(app)
	helper.check(app.progress.coins == 0 and app.progress.trust == 20, "congregation, solitary prayer and make-up leave coins and trust unchanged")

	app.clock.reset()
	for _index in range(app.identity.clock.prayers.size()):
		app.clock.wait_until_next_prayer()
		app.clock.pray(false)
	position_at(app, "masjid")
	await key(app, KEY_T)
	app.clock.advance_to(2, 728, false)
	app.show_screen("market_map")
	helper.check(app.clock.hud(true).prayer == "Friday prayer now · 3 h 22 min left", "Friday at the Masjid shows the congregational prayer")
	await capture_state(app, "g24_market_map__friday_prayer")
	await click(app, app.identity.clock.pray_friday)
	helper.check(app.clock.record().rows[1].status == "jamaah" and app.minute_of_day == 738 and app.progress.coins == 0 and app.progress.trust == 20, "Friday congregation records the prayer, advances ten minutes and leaves coins and trust unchanged")

	app.clock.advance_to(2, 1085, false)
	app.update_state()
	await key(app, KEY_P)
	helper.check(app.minute_of_day == 1095 and app.ui.toast_label.text == "Adhan: Maghrib has begun.", "an adhan crossed during prayer is shown immediately")
	app.ui._process(3.6)
	helper.check(app.ui.toast_label.text == "You prayed Asr on your own.", "the prayer receipt follows the crossed adhan")

	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size() + 2, "all eight master states and the day and night street HUDs were captured")
	finish(app)

func key(app: Node3D, code: Key) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.pressed = pressed
		app.get_viewport().push_input(event, true)
	await app.get_tree().process_frame

func position_at(app: Node3D, id: String) -> void:
	app.player.position = app.world.point(id)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()

func open_record(app: Node3D) -> void:
	await hit(app, app.ui.clock_panel.get_global_rect().get_center())
	helper.check(app.ui.screen == "prayer_record", "the clock opens the private record")

func close_record(app: Node3D) -> void:
	await click(app, app.identity.clock.record.back)
	helper.check(app.ui.screen == "market_map", "Back to the market returns to the original market view")

func capture_state(app: Node3D, stem: String) -> void:
	var filename := stem + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.clock = app.clock.hud(app.current_place == "masjid")
	state.toast = app.ui.toast_label.text if app.ui.toast_panel.visible else ""
	if app.ui.screen == "prayer_record":
		state.record = app.clock.record()

func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("CLOCK NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
