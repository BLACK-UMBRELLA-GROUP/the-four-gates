extends "res://tests/capture_identity.gd"
## DOC-TFG-0068: LOCK 19 evidence through the native Godot viewport.

const OUTPUT := "res://../GAME/APPROVED/RAMADAN/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/RAMADAN/RECORD/ramadan_data_V1.json"
const MASTER_STEMS := [
	"n01_inn__eat_suhoor_1_ramadan",
	"n02_inn__after_suhoor",
	"n03_spice__fasting_line",
	"n04_masjid__break_your_fast",
	"n05_iftar__with_the_people",
	"n06_masjid__pray_tarawih",
	"n07_masjid__after_tarawih_2100",
	"n08_prayers__ramadan_record",
	"n09_spice__29_shaban_no_fast",
	"n10_inn__no_suhoor_before_ramadan",
	"n11_spice__after_maghrib_no_line",
]
const FIRST_RAMADAN_DAY := 30
const FASTING_LINE := "Fasting · iftar at 18:10"

var copy: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--ramadan-output="):
			return argument.trim_prefix("--ramadan-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Ramadan capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Ramadan evidence directory")
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
	helper.report.method = "Native Godot viewport. Real viewport clicks drive fair arrivals, Ramadan actions, the Iftar panel and both prayer record views."
	helper.report.fixture = "Passive clock ticks are paused. Fair arrivals supply 198 coins and trust is set to 45. After each arrival, the clock resets to remove the arrival-only prayer misses. The real player is placed at the named market marker and the real clock is set to the named state with unplayed prayer windows excluded. For n08, a fresh arrival leaves Suhoor at zero; the actual tarawih button adds one night. A clock skip excludes the earlier Isha at 04:45 on 2 Ramadan, then normal time passes to 21:00 on 3 Ramadan to accrue nine misses. No rendered words or Ramadan/prayer counts are seeded."
	helper.report.settled_toasts = "The visible action toasts are checked against locked data immediately, then n02 and n07 capture the map after the ordinary toast timer expires."
	app.set_process(false)
	if not helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/ramadan.json"), "runtime Ramadan data matches the locked bytes"):
		finish(app)
		return
	copy = app.ramadan.data

	await arrive(app)
	stage(app, FIRST_RAMADAN_DAY, 240, "inn")
	check_button(app, copy.suhoor_button, true)
	check_fasting(app, false)
	await capture_state(app, 0)
	var before := visible_accounts(app)
	await click(app, copy.suhoor_button)
	check_toast(app, copy.suhoor_toast)
	check_button(app, copy.suhoor_button, false)
	helper.check(app.minute_of_day == 240, "suhoor leaves the clock at 04:00")
	helper.check(app.ramadan.record().suhoor == 1, "suhoor updates the private count once")
	helper.check(visible_accounts(app) == before, "suhoor leaves coins, trust and What people say unchanged")
	await helper.settle_toast(app)
	helper.check(not app.ui.toast_panel.visible, "the suhoor toast settles before n02")
	await capture_state(app, 1)

	stage(app, FIRST_RAMADAN_DAY, 600, "spice")
	var fasting := check_fasting(app, true)
	var harm: Dictionary = app.harm_in_the_road.available_at("spice")
	var move := helper.find_button(app.ui, harm.get("move", ""))
	if helper.check(move != null and fasting != null, "the fasting line and the locked rope action both render"):
		var move_rect := move.get_global_rect()
		var fast_rect := fasting.get_global_rect()
		helper.check(move_rect.end.y <= fast_rect.position.y or move_rect.end.x <= fast_rect.position.x, "the fasting line follows the rope action")
	await capture_state(app, 2)

	await arrive(app)
	stage(app, FIRST_RAMADAN_DAY - 1, 240, "inn")
	check_button(app, copy.suhoor_button, false)
	check_fasting(app, false)
	await capture_state(app, 9)
	stage(app, FIRST_RAMADAN_DAY - 1, 600, "spice")
	check_fasting(app, false)
	await capture_state(app, 8)
	await open_totals(app)
	helper.check(find_label(app.ui.content, str(copy.record.title).to_upper()) == null, "the prayer totals omit Ramadan before it begins")
	await click(app, app.ui.prayer_record.panel.back_market)

	stage(app, FIRST_RAMADAN_DAY, 1095, "spice")
	check_fasting(app, false)
	check_button(app, copy.iftar_button, false)
	await capture_state(app, 10)
	stage(app, FIRST_RAMADAN_DAY, 1095, "masjid")
	check_fasting(app, false)
	var maghrib: String = app.clock.prayer_label(true)
	check_button(app, maghrib, true)
	check_button(app, copy.iftar_button, true)
	await capture_state(app, 3)
	before = visible_accounts(app)
	await click(app, copy.iftar_button)
	helper.check(app.ui.screen == "iftar", "the live iftar action opens the iftar panel")
	for value: String in [str(copy.iftar.kicker).to_upper(), copy.iftar.title, copy.iftar.text]:
		var label := find_label(app.ui.content, value)
		helper.check(label != null and app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "visible iftar words fit: " + value)
	check_button(app, copy.iftar.to_map, true)
	helper.check(app.minute_of_day == 1095, "iftar leaves the clock at 18:15")
	helper.check(visible_accounts(app) == before, "iftar leaves coins, trust and What people say unchanged")
	await capture_state(app, 4)
	await click(app, copy.iftar.to_map)
	helper.check(app.ui.screen == "market_map" and app.current_place == "masjid", "the iftar panel returns to the Masjid on the market map")
	check_button(app, copy.iftar_button, false)
	check_button(app, maghrib, true)

	stage(app, FIRST_RAMADAN_DAY, 1200, "masjid")
	check_button(app, app.clock.prayer_label(true), true)
	check_button(app, copy.tarawih_button, true)
	var tarawih := helper.find_button(app.ui, copy.tarawih_button)
	var wait_for_prayer := helper.find_button(app.ui, app.data.ui.buttons.wait_prayer)
	helper.check(tarawih != null and wait_for_prayer != null and absf(tarawih.global_position.y - wait_for_prayer.global_position.y) <= 2.0, "n06 tarawih is inline with the market navigation")
	await capture_state(app, 5)
	before = visible_accounts(app)
	await click(app, copy.tarawih_button)
	check_toast(app, copy.tarawih_toast)
	check_button(app, copy.tarawih_button, false)
	check_button(app, app.clock.prayer_label(true), true)
	helper.check(app.day == FIRST_RAMADAN_DAY and app.minute_of_day == 1260, "tarawih advances 20:00 to 21:00")
	helper.check(visible_accounts(app) == before, "tarawih leaves coins, trust and What people say unchanged")
	await helper.settle_toast(app)
	helper.check(not app.ui.toast_panel.visible, "the tarawih toast settles before n07")
	await capture_state(app, 6)

	app.clock.skip_to(FIRST_RAMADAN_DAY + 1, 285)
	app.clock.advance_to(FIRST_RAMADAN_DAY + 2, 1260, false)
	app.update_state()
	await open_totals(app)
	check_ramadan_rows(app)
	helper.check(app.clock.totals().missed == 9, "the prior prayer rows come from nine real expired prayer windows")
	await capture_state(app, 7)

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
	app.clock.reset()
	app.progress.apply_trust(45 - app.progress.trust)
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival opens the live Inn map")
	helper.check(app.progress.coins == 198 and app.progress.trust == 45, "capture wallet and trust match the locked setup")


func stage(app: Node3D, day: int, minute: int, place: String) -> void:
	app.clock.skip_to(day, minute)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == place, "live map at " + place)
	helper.check(app.day == day and app.minute_of_day == minute, "capture clock is at day %d minute %d" % [day, minute])


func check_button(app: Node3D, caption: String, expected: bool) -> void:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == expected and not caption.is_empty(), "visible button %s: %s" % ["shown" if expected else "hidden", caption])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits the viewport: " + caption)


func check_fasting(app: Node3D, expected: bool) -> Control:
	var label := find_label(app.ui.content, FASTING_LINE)
	helper.check((label != null) == expected, "locked fasting line " + ("shown" if expected else "hidden"))
	if label != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "fasting line fits the viewport")
	return label


func check_toast(app: Node3D, value: String) -> void:
	helper.check(app.ui.toast_panel.is_visible_in_tree() and app.ui.toast_label.text == value, "visible locked action toast: " + value)
	helper.check(app.get_viewport().get_visible_rect().encloses(app.ui.toast_panel.get_global_rect()), "action toast fits the viewport")


func visible_accounts(app: Node3D) -> Array:
	return [app.progress.coins, app.progress.trust, app.ui.reputation_lines().duplicate(true)]


func open_totals(app: Node3D) -> void:
	await hit(app, app.ui.clock_panel.get_global_rect().get_center())
	helper.check(app.ui.screen == "prayer_record", "the native clock opens Today's prayers")
	await click(app, app.ui.prayer_record.record_button)
	helper.check(app.ui.screen == "all_prayers", "Today's prayers opens the private All your prayers panel")


func check_ramadan_rows(app: Node3D) -> void:
	var record_copy: Dictionary = copy.record
	var prayer_copy: Dictionary = app.ui.prayer_record
	var prior_row := find_label(app.ui.content, prayer_copy.rows.missed)
	var title := find_label(app.ui.content, str(record_copy.title).to_upper())
	if not helper.check(prior_row != null and title != null and title.global_position.y > prior_row.global_position.y, "the locked Ramadan title follows the prayer rows"):
		return
	var previous_y := title.global_position.y
	var expected := {"fasted": 3, "suhoor": 0, "tarawih": 1}
	for key: String in expected:
		var row := find_label(app.ui.content, record_copy[key])
		if not helper.check(row != null and row.global_position.y > previous_y, "locked Ramadan row in order: " + str(record_copy[key])):
			continue
		previous_y = row.global_position.y
		var wanted := str(record_copy.count).format({"n": expected[key]})
		var count_found := false
		for child in row.get_parent().get_children():
			if child is Label and child.position.y == row.position.y and child.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
				count_found = child.text == wanted
		helper.check(count_found, "rendered right-aligned Ramadan count: %s = %s" % [record_copy[key], wanted])
	var note := find_label(app.ui.content, str(prayer_copy.panel.note).to_upper())
	helper.check(note != null and note.global_position.y > previous_y, "the existing privacy note follows the Ramadan rows")


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
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.date = app.clock.date_label(app.day)
	state.ramadan = app.ramadan.record()
	state.prayer_totals = app.clock.totals()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE26_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("RAMADAN NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
