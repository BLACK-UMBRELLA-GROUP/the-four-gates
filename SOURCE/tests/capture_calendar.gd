extends "res://tests/capture_identity.gd"
## DOC-TFG-0065: LOCK 18 native evidence through the live Inn and prayer controls.

const OUTPUT := "res://../GAME/APPROVED/CALENDAR/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/CALENDAR/RECORD/calendar_data_V1.json"
const MASTER_STEMS := [
	"k01_inn__date_on_clock_rest_button",
	"k02_calendar__coming_up_day0",
	"k03_inn__woke_sunday_4_shaban",
	"k04_calendar__after_3_days",
	"k05_inn__29_shaban",
	"k06_calendar__ramadan_today",
	"k07_inn__1_shawwal",
	"k08_calendar__eid_al_adha_today",
	"k09_calendar__zakat_year_ends_today",
	"k10_calendar__not_enough_for_7",
	"k11_prayers__rested_days_not_counted",
]
const ARRIVAL_DAY := ["1 Ramadan · in 29 days", "1 Shawwal · in 59 days", "9 Dhu al-Hijjah · in 126 days", "10 Dhu al-Hijjah · in 127 days", "1 Sha'ban · in 354 days"]
const AFTER_REST := ["1 Ramadan · in 26 days", "1 Shawwal · in 56 days", "9 Dhu al-Hijjah · in 123 days", "10 Dhu al-Hijjah · in 124 days", "1 Sha'ban · in 351 days"]
const RAMADAN_DAY := ["today", "1 Shawwal · in 30 days", "9 Dhu al-Hijjah · in 97 days", "10 Dhu al-Hijjah · in 98 days", "1 Sha'ban · in 325 days"]
const EID_DAY := ["1 Ramadan · in 256 days", "1 Shawwal · in 286 days", "9 Dhu al-Hijjah · in 353 days", "today", "1 Sha'ban · in 227 days"]
const ZAKAT_DAY := ["1 Ramadan · in 29 days", "1 Shawwal · in 59 days", "9 Dhu al-Hijjah · in 126 days", "10 Dhu al-Hijjah · in 127 days", "today"]

var copy: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--calendar-output="):
			return argument.trim_prefix("--calendar-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Calendar capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the calendar evidence directory")
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
	helper.report.method = "Native Godot viewport. Viewport clicks drive the fair arrival, the Inn calendar, both rest durations and the private prayer totals."
	helper.report.fixture = "Passive ticks are paused. Fair arrivals supply 198 coins and trust is set to 45. k01/k02/k10 use the live arrival at 18:15 on day index 0 to preserve the exact Hijri date and countdowns. k05/k06/k07/k08/k09 stage the exact day at 10:00 from a reset clock with no prior misses. k10 sets the wallet to 10. k11 resets the clock after a fresh arrival and stages day index 0 at 10:00 so there are no prior misses. Resting is performed via the live buttons. No prayer totals or displayed text are seeded."
	app.set_process(false)
	if not helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/calendar.json"), "runtime calendar data matches locked bytes"):
		finish(app)
		return
	copy = app.clock.calendar.data

	await arrive(app)
	expect_clock(app, "Thursday 1 Sha'ban · 18:15")
	check_inn_order(app)
	await capture_state(app, 0)
	await open_calendar(app, "Thursday 1 Sha'ban", ARRIVAL_DAY)
	await capture_state(app, 1)
	var before_rest: Dictionary = app.clock.totals()
	await click(app, rest_label(app, 3))
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "three-day rest returns to the Inn map")
	helper.check(app.progress.coins == 192 and app.day == 4 and app.minute_of_day == 280, "three-day rest spends six coins and wakes on day index 3 at 04:40")
	helper.check(app.clock.totals() == before_rest, "three-day rest preserves the prior prayer totals")
	helper.check(app.ui.toast_panel.visible and app.ui.toast_label.text == "You rest for 3 days. You wake before Fajr on Sunday 4 Sha'ban.", "three-day wake toast is visible and uses the locked words")
	expect_clock(app, "Sunday 4 Sha'ban · 04:40")
	check_inn_order(app)
	await capture_state(app, 2)
	await open_calendar(app, "Sunday 4 Sha'ban", AFTER_REST)
	await capture_state(app, 3)
	await dismiss(app)

	await arrive(app)
	app.clock.reset()
	stage_time(app, 28)
	expect_clock(app, "Thursday 29 Sha'ban · 10:00")
	await capture_state(app, 4)

	stage_time(app, 29)
	expect_clock(app, "Friday 1 Ramadan · 10:00")
	await open_calendar(app, "Friday 1 Ramadan", RAMADAN_DAY)
	await capture_state(app, 5)
	await dismiss(app)

	stage_time(app, 59)
	expect_clock(app, "Sunday 1 Shawwal · 10:00")
	await capture_state(app, 6)

	stage_time(app, 127)
	expect_clock(app, "Friday 10 Dhu al-Hijjah · 10:00")
	await open_calendar(app, "Friday 10 Dhu al-Hijjah", EID_DAY)
	await capture_state(app, 7)
	await dismiss(app)

	stage_time(app, 354)
	expect_clock(app, "Monday 1 Sha'ban · 10:00")
	await open_calendar(app, "Monday 1 Sha'ban", ZAKAT_DAY)
	await capture_state(app, 8)
	await dismiss(app)

	await arrive(app)
	app.progress.coins = 10
	app.update_state()
	await open_calendar(app, "Thursday 1 Sha'ban", ARRIVAL_DAY)
	var shortage := find_label(app.ui.content, "not enough coins for 7 days")
	helper.check(shortage != null and helper.find_button(app.ui, rest_label(app, 7)) == null, "seven-day option is unavailable at ten coins")
	if shortage != null:
		await hit(app, shortage.get_global_rect().get_center())
	helper.check(app.progress.coins == 10 and app.day == 1 and app.minute_of_day == 1095 and app.ui.screen == "calendar", "clicking the shortage leaves the wallet, time and screen intact")
	await capture_state(app, 9)
	await dismiss(app)

	await arrive(app)
	app.clock.reset()
	stage_time(app, 0)
	before_rest = app.clock.totals()
	helper.check(not before_rest.values().any(func(count: int) -> bool: return count != 0), "seven-day evidence starts with no prior counted prayer")
	await open_calendar(app, "Thursday 1 Sha'ban", ARRIVAL_DAY)
	await click(app, rest_label(app, 7))
	helper.check(app.progress.coins == 184 and app.day == 8 and app.minute_of_day == 280, "seven-day rest spends fourteen coins and wakes on day index 7 at 04:40")
	helper.check(app.clock.totals() == before_rest and app.clock.make_up_label().is_empty(), "seven-day rest adds no totals or make-up targets")
	expect_clock(app, "Thursday 8 Sha'ban · 04:40")
	await hit(app, app.ui.clock_panel.get_global_rect().get_center())
	helper.check(app.ui.screen == "prayer_record", "the live clock opens Today's prayers after resting")
	await click(app, app.ui.prayer_record.record_button)
	helper.check(app.ui.screen == "all_prayers", "Today's prayers opens All your prayers")
	helper.check(find_label(app.ui.content, app.ui.prayer_record.panel.empty) != null, "All your prayers shows the locked empty state")
	await capture_state(app, 10)

	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all eleven masters have native captures")
	finish(app)


func arrive(app: Node3D) -> void:
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	app.progress.apply_trust(45 - app.progress.trust)
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival enters the live Inn map")
	helper.check(app.progress.coins == 198 and app.day == 1 and app.minute_of_day == 1095, "fair arrival sets 198 coins at 18:15 on day index 0")


func stage_time(app: Node3D, day_index: int) -> void:
	app.clock.skip_to(day_index + 1, 600)
	app.update_state()
	helper.check(app.day == day_index + 1 and app.minute_of_day == 600, "fixture reached 10:00 on day index %d" % day_index)


func expect_clock(app: Node3D, expected: String) -> void:
	helper.check(find_label(app.ui.clock_panel, expected) != null, "visible clock: " + expected)


func check_inn_order(app: Node3D) -> void:
	var single := helper.find_button(app.ui, app.identity.inn.action)
	var rest := helper.find_button(app.ui, copy.inn_button)
	var purse := helper.find_button(app.ui, app.chapter.places.inn)
	if helper.check(single != null and rest != null and purse != null, "both rests and the purse are available at the Inn"):
		helper.check(single.global_position.x < rest.global_position.x and rest.global_position.x < purse.global_position.x, "multi-day rest follows single-night rest and precedes the purse")
		var dice_caption: String = app.dice_house.inn_caption()
		if not dice_caption.is_empty():
			var dice := helper.find_button(app.ui, dice_caption)
			helper.check(dice != null and dice.global_position.x < rest.global_position.x, "multi-day rest follows the dice invitation")


func rest_label(app: Node3D, nights: int) -> String:
	return str(copy.panel.rest).format({"n": nights, "c": nights * int(app.identity.arrival.inn_night)})


func open_calendar(app: Node3D, date: String, values: Array) -> void:
	await click(app, copy.inn_button)
	helper.check(app.ui.screen == "calendar", "the Inn action opens the calendar")
	var today := find_label(app.ui.content, "Today is " + date + ".")
	helper.check(today != null, "calendar shows the date " + date)
	helper.check(find_label(app.ui.content, copy.panel.title) != null, "calendar shows the locked title")
	helper.check(find_label(app.ui.content, str(copy.panel.note).to_upper()) != null, "calendar shows the locked prayer record note")
	var labels: Array[String] = []
	for event: Array in copy.panel.events:
		labels.append(event[0])
	labels.append(copy.panel.zakat)
	var previous_y := 0.0
	for index in labels.size():
		var event := find_label(app.ui.content, labels[index])
		var value := find_label(app.ui.content, values[index])
		if helper.check(event != null and value != null, labels[index] + " — " + values[index]):
			helper.check(event.global_position.y > previous_y and absf(event.global_position.y - value.global_position.y) < 2.0, "ordered event and date share a row: " + labels[index])
			previous_y = event.global_position.y
	helper.check(helper.find_button(app.ui, rest_label(app, 3)) != null, "three-day rest is offered for six coins")
	if app.progress.coins >= 14:
		helper.check(helper.find_button(app.ui, rest_label(app, 7)) != null, "seven-day rest is offered for fourteen coins")


func dismiss(app: Node3D) -> void:
	var before: Array = [app.progress.coins, app.day, app.minute_of_day]
	await click(app, copy.panel.not_now)
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "Not now returns to the Inn map")
	helper.check(before == [app.progress.coins, app.day, app.minute_of_day], "dismissing the panel keeps the wallet and time")


func find_label(node: Node, value: String) -> Control:
	if node is Control and not node.is_visible_in_tree():
		return null
	if (node is Label and node.text == value) or (node is RichTextLabel and node.get_parsed_text() == value):
		return node
	for child in node.get_children():
		var found := find_label(child, value)
		if found != null:
			return found
	return null


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day_index = app.day - 1
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.date = app.clock.date_label(app.day)
	state.totals = app.clock.totals()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE25_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("CALENDAR NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
