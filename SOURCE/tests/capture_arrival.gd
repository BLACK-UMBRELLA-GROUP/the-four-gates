extends "res://tests/capture_identity.gd"
## Line 6 native viewport evidence using the identity runner's real GUI hits.

const OUTPUT := "res://../GAME/APPROVED/IDENTITY/BUILT/V1/ARRIVAL/"
const MASTER_STEMS := {
	"g02": "g02_arrival__dawn_quay",
	"g03": "g03_arrival__quay_reply",
	"g04": "g04_arrival__money_changers",
	"g05": "g05_arrival__fair_changer",
	"g06": "g06_arrival__smiling_changer",
	"g07": "g07_arrival__inn",
	"g08": "g08_arrival__sunset_adhan",
	"g09": "g09_arrival__end_fair",
	"g10": "g10_arrival__end_cheated",
	"g16": "g16_market_map__at_inn_night",
	"g17": "g17_market_map__morning_after_rest",
	"g18": "g18_market_map__rest_cannot_pay",
	"g30": "g30_after_lesson__cheat_found",
}

func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	output = OUTPUT
	helper.output = output
	var directory_result := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	if directory_result != OK:
		push_error("Could not create the Arrival evidence directory: " + error_string(directory_result))
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
	var masters_only := "--masters-only" in OS.get_cmdline_user_args()
	helper.report.method = "Native Godot viewport. Local mouse clicks dispatch through the production hit regions and buttons, and the player walks the normal street route from the Inn to the scales."
	helper.report.fixture = "Only g18 seeds the wallet to zero, after the actual prepaid and paid rests. All choices, rests and the lesson use the real controls. g17 is the first no-credit rest, on day 3 after the preceding prepaid rest; line 6 has no clock UI."
	if masters_only:
		helper.report.method = "Native Godot viewport. Local mouse clicks dispatch through the production hit regions and buttons."
		helper.report.fixture += " For g30 this shorter run places the player at the market scales, then uses the actual lesson buttons. The full native run previously verified the physical route."
	helper.report.runtime_source_sha256 = {}
	for path: String in [
		"project.godot", "data/foundations.json", "data/identity.json",
		"game/foundations.gd", "game/map_canvas.gd", "game/market_ui.gd",
		"game/river_market.gd", "game/market_world.gd", "game/market_player.gd",
		"game/task_progress.gd", "game/lesson_canvas.gd", "game/river_market.tscn",
		"tests/capture_arrival.gd", "tests/capture_identity.gd", "tests/capture_tasks.gd",
		"tests/create_comparisons.gd", "tests/run_tests.gd",
	]:
		helper.report.runtime_source_sha256["SOURCE/" + path] = FileAccess.get_sha256("res://" + path)

	var arrival: Dictionary = app.identity.arrival
	var beats: Array = arrival.beats
	var inn: Dictionary = app.identity.inn
	await click(app, app.data.ui.buttons.begin)
	helper.check(app.ui.screen == "arrival" and app.arrival_beat == 0 and app.arrival_reply.is_empty() and app.progress.coins == 0, "Begin starts the quay beat with an empty wallet")
	await capture_master_state(app, "g02")
	await click(app, beats[0].choices[0].label)
	helper.check(app.arrival_reply == beats[0].choices[0].reply, "quay choice displays its exact reply")
	await capture_master_state(app, "g03")
	await click(app, arrival.continue)
	helper.check(app.arrival_beat == 1 and app.arrival_reply.is_empty(), "Continue opens the money-changer choices")
	await capture_master_state(app, "g04")
	await click(app, beats[1].choices[0].label)
	helper.check(app.progress.coins == 200 and app.arrival_fair == true and app.arrival_reply == beats[1].choices[0].reply, "open-scale changer pays 200 coins and displays its exact reply")
	await capture_master_state(app, "g05")
	await click(app, arrival.continue)
	helper.check(app.arrival_beat == 2 and app.paid_nights == 0, "Continue opens the Inn beat before paying")
	await capture_master_state(app, "g07")
	await complete_arrival(app, true)
	await capture_master_state(app, "g09")
	await click(app, arrival.buttons[0])
	helper.check(app.ui.screen == "arrival" and app.arrival_beat == beats.size() and app.ui.toast_panel.visible and app.ui.toast_label.text == app.data.ui.not_built, "meeting action shows the approved interim toast and keeps the end view")
	await click(app, arrival.buttons[1])
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn" and app.progress.coins == 198 and app.night, "Walk opens the night map at the Inn with the fair purse")
	await capture_master_state(app, "g16")

	var starting_day: int = app.day
	await click(app, inn.action)
	helper.check(app.paid_nights == 0 and app.progress.coins == 198 and app.day == starting_day + 1 and app.minute_of_day == 280 and app.ui.toast_panel.visible and app.ui.toast_label.text == str(inn.paid).format({"n": 0}), "prepaid rest consumes credit, keeps the wallet and wakes at 04:40 the next day")
	await click(app, inn.action)
	helper.check(app.paid_nights == 0 and app.progress.coins == 196 and app.day == starting_day + 2 and app.minute_of_day == 280 and app.night and app.ui.toast_panel.visible and app.ui.toast_label.text == str(inn.coins).format({"n": 2}), "no-credit rest pays two coins and wakes at 04:40 with the matching toast")
	await capture_master_state(app, "g17")

	app.progress.coins = 0
	app.update_state()
	await app.get_tree().process_frame
	await click(app, inn.action)
	helper.check(app.paid_nights == 0 and app.progress.coins == 0 and app.day == starting_day + 3 and app.minute_of_day == 280 and app.night and app.ui.toast_panel.visible and app.ui.toast_label.text == inn.broom, "empty wallet and no credit use the stable with no debit")
	await capture_master_state(app, "g18")

	await click(app, app.data.ui.buttons.city_map)
	await click(app, app.identity.ui.world_map)
	await click(app, app.identity.ui.title_back)
	await click(app, app.data.ui.buttons.begin)
	helper.check(app.ui.screen == "arrival" and app.arrival_beat == 0 and app.progress.coins == 0 and app.paid_nights == 0 and app.day == 1 and app.minute_of_day == 390 and not app.night, "a second Begin resets the Arrival and wallet")
	await click(app, beats[0].choices[1].label)
	helper.check(app.arrival_reply == beats[0].choices[1].reply, "waiting at the quay displays the alternate reply")
	await click(app, arrival.continue)
	await click(app, beats[1].choices[1].label)
	helper.check(app.progress.coins == 120 and app.arrival_fair == false and app.arrival_reply == beats[1].choices[1].reply, "smiling changer pays 120 coins and displays its exact reply")
	await capture_master_state(app, "g06")
	await click(app, arrival.continue)
	await complete_arrival(app, false)
	await capture_master_state(app, "g10")
	await click(app, arrival.buttons[1])
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn" and app.progress.coins == 118, "Walk keeps the cheated purse at the Inn")
	await helper.action(app, "wait_day_night")
	if masters_only:
		app.player.position = app.world.point("scales")
		app.player.velocity = Vector3.ZERO
		app.update_state()
		helper.check(app.current_place == "scales", "g30 fixture places the player at the market scales")
	elif not await travel(app, "scales"):
		return
	await click(app, app.data.ui.place_actions.scales)
	var false_index := int(app.data.lesson.false_weight_index)
	await click(app, app.data.lesson.options[false_index])
	await click(app, str(app.data.lesson.answer_button).format({"n": false_index + 1}))
	helper.check(app.ui.screen == "game" and app.current_place == "scales" and app.progress.lesson_done and app.progress.trust == 45 and app.progress.coins == 118 and app.ui.toast_panel.visible and app.ui.toast_label.text == arrival.cheat_found_after_lesson, "scales success replaces its toast and returns to the street at the scales")
	await capture_master_state(app, "g30")
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all 13 required screenshots were captured")
	finish(app)

func complete_arrival(app: Node3D, fair: bool) -> void:
	var arrival: Dictionary = app.identity.arrival
	var room: Dictionary = arrival.beats[2].choices[0]
	var sunset: Dictionary = arrival.beats[3].choices[0]
	var end_coins := 198 if fair else 118
	await click(app, room.label)
	helper.check(app.progress.coins == end_coins and app.paid_nights == 1 and app.arrival_reply == room.reply, "the Inn takes two coins once and credits one prepaid night")
	await click(app, arrival.continue)
	helper.check(app.arrival_beat == 3 and app.arrival_reply.is_empty() and app.day == 1 and app.minute_of_day == 390, "sunset beat displays before Follow them applies the time jump")
	if fair:
		await capture_master_state(app, "g08")
	await click(app, sunset.label)
	helper.check(app.minute_of_day == int(sunset.effect.time) and app.arrival_reply == sunset.reply, "Follow them applies the time jump and displays its exact reply")
	await click(app, arrival.continue)
	helper.check(app.arrival_beat == arrival.beats.size() and app.progress.coins == end_coins, "the end view retains the selected changer and post-Inn balance")

func capture_master_state(app: Node3D, id: String) -> void:
	var filename: String = MASTER_STEMS[id] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.arrival_beat = app.arrival_beat
	state.arrival_reply = app.arrival_reply
	state.arrival_fair = app.arrival_fair
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.paid_nights = app.paid_nights
	state.place = app.current_place
	state.toast = app.ui.toast_label.text if app.ui.toast_panel.visible else ""

func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("ARRIVAL NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
