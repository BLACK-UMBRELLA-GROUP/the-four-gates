extends "res://tests/capture_identity.gd"
## DOC-TFG-0098: the nine LOCK 29 states from the native Godot viewport.

const OUTPUT := "res://../GAME/APPROVED/MENUS/BUILT/V1/"
const MASTER_STEMS := [
	"mn01_title__no_save",
	"mn02_settings__from_title",
	"mn03_settings__large_and_fast",
	"mn04_market__before_esc",
	"mn05_pause__esc",
	"mn06_pause__saved",
	"mn07_settings__from_pause",
	"mn08_title__continue",
	"mn09_market__continued",
]


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--menus-output="):
			return argument.trim_prefix("--menus-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Menu capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the menu evidence directory")
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
	helper.report.method = "Native Godot viewport, production buttons via viewport mouse input and physical Escape events."
	helper.report.fixture = "Fair arrival, then Inn at 10:00 on the following Thursday, day 8, with 198 coins and trust 45. Pause, settings, save, quit and Continue use the production UI and isolated on-disk files."
	var copy: Dictionary = app.menus
	var settings: Dictionary = copy.settings
	var pause: Dictionary = copy.pause
	helper.check(app.ui.screen == "title" and app.ui.continue_date.is_empty(), "fresh title offers no Continue")
	await take(app, 0)
	await click(app, app.data.ui.buttons.settings)
	helper.check(app.ui.screen == "settings" and not app.ui.settings_has_hud, "title settings have no gameplay HUD")
	await take(app, 1)
	await click(app, settings.large)
	await click(app, settings.fast)
	helper.check(app.ui.large_text and app.ui.fast_walk, "Large and Fast apply immediately")
	await take(app, 2)
	await click_option(app, "large_text_normal")
	await click_option(app, "fast_walk_normal")
	await escape(app)
	helper.check(app.ui.screen == "title", "Esc returns from settings to title")
	await click(app, app.data.ui.buttons.begin)
	for beat in app.identity.arrival.beats:
		app.choose_arrival(0)
		app.continue_arrival()
	app.walk_from_arrival()
	app.set_process(false)
	app.clock.skip_to(8, 600)
	app.player.position = app.world.point("inn")
	app.player.velocity = Vector3.ZERO
	app.progress.coins = 198
	app.progress.trust = 45
	app.show_screen("market_map")
	var date: String = app.clock.time_label(app.day, app.minute_of_day)
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn" and app.day == 8 and app.minute_of_day == 600, "later Thursday 10:00 fixture is at the Inn")
	await take(app, 3)
	await escape(app)
	helper.check(app.ui.screen == "pause" and not app.ui.map.visible and app.ui.saved_date.is_empty(), "Esc shows Paused with the 3D backdrop")
	await take(app, 4)
	await click(app, pause.save)
	helper.check(app.ui.screen == "pause" and app.ui.saved_date == date, "Save game keeps pause open with the in-game receipt date")
	await take(app, 5)
	await click(app, pause.settings)
	helper.check(app.ui.screen == "settings" and app.ui.settings_has_hud, "pause settings retain the gameplay HUD")
	await take(app, 6)
	await click(app, settings.back)
	helper.check(app.ui.screen == "pause" and app.ui.saved_date == date, "Back returns to pause with its receipt")
	await click(app, pause.quit)
	var continue_text: String = str(copy.title_continue).format({"d": date})
	helper.check(app.ui.screen == "title" and app.ui.continue_date == date, "Save and quit returns to title with the dated Continue")
	await take(app, 7)
	await click(app, continue_text)
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn" and app.clock.time_label(app.day, app.minute_of_day) == date, "Continue restores the saved market place and date")
	helper.check(app.progress.coins == 198 and app.progress.trust == 45, "Continue restores the wallet and trust")
	await take(app, 8)
	await escape(app)
	await click(app, pause.settings)
	await click(app, settings.large)
	await click(app, settings.fast)
	helper.check(app.ui.large_text and app.ui.fast_walk, "persist non-default settings for the process-restart check")
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all nine LOCK 29 states have native captures")
	finish(app)


func take(app: Node3D, index: int) -> void:
	var file: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, file)
	helper.report.states[file].date = app.clock.time_label(app.day, app.minute_of_day)
	helper.report.states[file].large_text = app.ui.large_text
	helper.report.states[file].fast_walk = app.ui.fast_walk


func click_option(app: Node3D, id: String) -> void:
	var button := app.ui.find_child(id, true, false) as Button
	if helper.check(button != null and button.is_visible_in_tree(), "visible real option exists: " + id):
		await hit(app, button.get_global_rect().get_center())


func escape(app: Node3D) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_ESCAPE
		event.physical_keycode = KEY_ESCAPE
		event.pressed = pressed
		app.get_viewport().push_input(event, true)
	await app.get_tree().process_frame


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE36_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("MENUS NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
