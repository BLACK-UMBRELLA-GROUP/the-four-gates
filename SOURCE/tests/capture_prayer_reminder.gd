extends "res://tests/capture_identity.gd"
## DOC-TFG-0101: LOCK 30 settings and reminder actions in the native viewport.

const RealPrayerTimes = preload("res://game/real_prayer_times.gd")
const OUTPUT := "res://../GAME/APPROVED/PRAYER_REMINDER/BUILT/V1/"
const MASTER_STEMS := [
	"pm01_settings__reminder_off",
	"pm02_settings__on_london",
	"pm03_settings__makkah",
	"pm04_settings__asr_hanafi",
	"pm05_market__banner_asr_london",
	"pm06_pause__after_pause_and_pray",
	"pm07_market__after_later",
]

var wall_time := Time.get_unix_time_from_datetime_string("2026-11-09T10:00:00")


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--reminder-output="):
			return argument.trim_prefix("--reminder-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Prayer reminder capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the prayer reminder evidence directory")
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
	helper.report.method = "Native Godot viewport. Buttons receive viewport mouse input. The city popup opens by click and receives its native selection signal. The wall clock and game setup are fixtures."
	helper.report.fixture = "Real settings date 9 Nov 2026. Separate in-game Thursday 10:00 on day 8 at the Inn. Later is exercised at real Asr on the next day so the reminder remains once per prayer day."
	app.set_process(false)
	app.reminder_time_source = func(): return wall_time
	var copy: Dictionary = app.reminder.settings
	var banner: Dictionary = app.reminder.banner
	await click(app, app.data.ui.buttons.settings)
	helper.check(not app.ui.reminder_on and app.ui.find_child("ReminderCity", true, false) == null, "off by default; city dropdown hidden")
	await take(app, 0)
	await click(app, copy.on)
	helper.check(app.ui.reminder_on and app.ui.reminder_city == 0 and not app.ui.reminder_hanafi, "On reveals London and Standard")
	await take(app, 1)
	await choose_city(app, "Makkah")
	await take(app, 2)
	await click(app, copy.asr_hanafi)
	helper.check(app.ui.reminder_hanafi, "Hanafi is selected by the production button")
	await take(app, 3)
	await click(app, copy.asr_standard)
	await choose_city(app, "London")
	await click(app, app.menus.settings.back)
	await click(app, app.data.ui.buttons.begin)
	for beat in app.identity.arrival.beats:
		app.choose_arrival(0)
		app.continue_arrival()
	app.walk_from_arrival()
	app.clock.skip_to(8, 600)
	app.player.position = app.world.point("inn")
	app.player.velocity = Vector3.ZERO
	app.progress.coins = 198
	app.progress.trust = 45
	app.show_screen("market_map")
	helper.check(app.current_place == "inn" and app.day == 8 and app.minute_of_day == 600, "later Thursday 10:00 fixture at the Inn")
	set_asr(app, 9)
	app._process(0.0)
	helper.check(app.ui.has_reminder_banner(), "a real-time poll shows the London Asr banner over the map")
	await take(app, 4)
	await click(app, banner.pray)
	helper.check(app.ui.screen == "pause" and not app.ui.has_reminder_banner() and not app.ui.map.visible, "Pause and pray opens the existing pause screen")
	helper.check(app.minute_of_day == 600 and app.day == 8, "real prayer does not move the game clock")
	await take(app, 5)
	await click(app, app.menus.pause.resume)
	helper.check(app.ui.screen == "market_map", "Resume returns to the market map")
	set_asr(app, 10)
	app._reminder_next_check = 0
	app._process(0.0)
	helper.check(app.ui.has_reminder_banner(), "the next day's Asr is eligible")
	await click(app, banner.later)
	helper.check(app.ui.screen == "market_map" and not app.ui.has_reminder_banner(), "Later dismisses without leaving the map")
	app._poll_reminder(wall_time)
	helper.check(not app.ui.has_reminder_banner(), "the dismissed prayer cannot repeat")
	await take(app, 6)
	app.show_screen("game")
	set_asr(app, 11)
	app._poll_reminder(wall_time)
	helper.check(app.ui.has_reminder_banner() and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "banner buttons are clickable in the 3D view")
	await click(app, banner.later)
	helper.check(not app.ui.has_reminder_banner() and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "Later restores mouse look")
	app.show_screen("pause")
	await click(app, app.menus.pause.settings)
	await choose_city(app, "Makkah")
	await click(app, copy.asr_hanafi)
	await click(app, app.menus.settings.fast)
	helper.check(app.ui.reminder_city == 9 and app.ui.reminder_hanafi and app.ui.fast_walk, "leave non-default reminder and legacy settings for the fresh process")
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all seven locked states have native captures")
	finish(app)


func set_asr(app: Node3D, day: int) -> void:
	var city: Array = app.reminder.cities[0]
	var events := RealPrayerTimes.times({"year": 2026, "month": 11, "day": day}, city, app.reminder.numbers, false)
	wall_time = events[2]


func choose_city(app: Node3D, city: String) -> void:
	var picker := app.ui.find_child("ReminderCity", true, false) as OptionButton
	if not helper.check(picker != null and picker.is_visible_in_tree(), "visible city selector"):
		return
	var index := -1
	for item in picker.item_count:
		if picker.get_item_text(item) == city:
			index = item
			break
	if not helper.check(index >= 0, city + " is in the locked city list"):
		return
	await hit(app, picker.get_global_rect().get_center())
	var popup := picker.get_popup()
	if not helper.check(popup.visible, "click opens the real city dropdown"):
		return
	popup.hide()
	popup.index_pressed.emit(index)
	await app.get_tree().process_frame
	helper.check(app.ui.reminder_city == index, city + " is selected")


func take(app: Node3D, index: int) -> void:
	var file: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, file)
	helper.report.states[file].game_date = app.clock.time_label(app.day, app.minute_of_day)
	helper.report.states[file].wall_time_utc = Time.get_datetime_string_from_unix_time(wall_time) + "Z"
	helper.report.states[file].reminder_on = app.ui.reminder_on
	helper.report.states[file].city = app.reminder.cities[app.ui.reminder_city][0]
	helper.report.states[file].hanafi = app.ui.reminder_hanafi
	helper.report.states[file].banner = app.ui.has_reminder_banner()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE37_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("PRAYER REMINDER NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
