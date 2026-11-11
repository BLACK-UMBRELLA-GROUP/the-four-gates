extends "res://tests/capture_identity.gd"
## DOC-TFG-0074: native viewport evidence for LOCK 21.

const OUTPUT := "res://../GAME/APPROVED/EID_AL_FITR/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/EID_AL_FITR/RECORD/eid_al_fitr_data_V1.json"
const MASTER_STEMS := [
	"y01_masjid__night_of_the_21st",
	"y02_masjid__after_standing_0010",
	"y03_masjid__20_ramadan_afternoon_none",
	"y04_masjid__night_of_the_11th_none",
	"y05_masjid__give_zakat_al_fitr_28_ramadan",
	"y06_fitr__panel",
	"y07_fitr__given",
	"y08_masjid__fitr_gone_after_giving",
	"y09_fitr__not_enough_coins",
	"y10_masjid__eid_morning",
	"y11_eid__the_prayer",
	"y12_spice__eid_mubarak_line",
	"y13_prayers__end_of_ramadan_record",
	"y14_masjid__2_shawwal_none",
]
const NIGHT_TOAST_STEM := "y02b_masjid__night_prayer_toast"
const FIRST_RAMADAN_DAY := 30
const EID_DAY := 60
const STARTING_COINS := 198
const STARTING_TRUST := 45

var copy: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--eid-al-fitr-output="):
			return argument.trim_prefix("--eid-al-fitr-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Eid al-Fitr capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Eid al-Fitr evidence directory")
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
	helper.report.method = "Native Godot viewport. Production buttons handle fair arrivals, night prayer, the zakat al-fitr and Eid panels, the payment, and opening the private record."
	helper.report.fixture = "Passive clock ticks are paused. Fair arrivals supply 198 coins, trust is set to 45, and y09 uses one coin. The player is placed at the actual place marker and the live clock skips unplayed prayer windows. y13 follows two real night-prayer clicks and one real Eid-prayer click, with no zakat al-fitr payment. Each state records the live date. y02 is the settled map and y02b shows the exact toast before it clears."
	app.set_process(false)
	var runtime := FileAccess.get_file_as_bytes("res://data/eid_al_fitr.json")
	if not helper.check(not runtime.is_empty() and FileAccess.get_file_as_bytes(LOCKED_DATA) == runtime, "runtime Eid al-Fitr data matches the locked bytes"):
		finish(app)
		return
	copy = app.eid_al_fitr.data

	await arrive(app)
	await capture_nights(app)
	await capture_eid(app)
	await capture_fitr(app)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size() + 1, "all fourteen master states and the additional toast have native captures")
	finish(app)


func capture_nights(app: Node3D) -> void:
	stage(app, FIRST_RAMADAN_DAY + 9, 1390, "masjid")
	check_button(app, copy.night_button, false)
	await capture_state(app, MASTER_STEMS[3])
	stage(app, FIRST_RAMADAN_DAY + 19, 1000, "masjid")
	check_button(app, copy.night_button, false)
	expect_label(app, app.ramadan.fasting_line())
	check_button(app, app.iftar_giving.data.masjid_button)
	await capture_state(app, MASTER_STEMS[2])
	stage(app, FIRST_RAMADAN_DAY + 19, 1390, "masjid")
	check_button(app, copy.night_button)
	check_button(app, app.clock.prayer_label(true))
	await capture_state(app, MASTER_STEMS[0])

	var before := accounts(app)
	await click(app, copy.night_button)
	helper.check(app.day == FIRST_RAMADAN_DAY + 20 and app.minute_of_day == 10, "standing advances the clock from 23:10 to 00:10")
	helper.check(app.ui.toast_panel.is_visible_in_tree() and app.ui.toast_label.text == copy.night_toast, "the native map displays the full locked night prayer toast")
	helper.check(app.get_viewport().get_visible_rect().encloses(app.ui.toast_panel.get_global_rect()), "the night prayer toast fits the viewport")
	check_button(app, copy.night_button, false)
	check_button(app, app.clock.prayer_label(true))
	helper.check(accounts(app) == before, "night prayer leaves coins, trust and public reputation unchanged")
	await capture_state(app, NIGHT_TOAST_STEM)
	await helper.settle_toast(app)
	helper.check(not app.ui.toast_panel.visible, "the ordinary toast timer settles before y02")
	await capture_state(app, MASTER_STEMS[1])

	stage(app, FIRST_RAMADAN_DAY + 20, 1390, "masjid")
	await click(app, copy.night_button)
	helper.check(app.day == FIRST_RAMADAN_DAY + 21 and app.minute_of_day == 10, "standing on another eligible night advances the clock normally")
	check_button(app, copy.night_button, false)
	await helper.settle_toast(app)


func capture_eid(app: Node3D) -> void:
	stage(app, EID_DAY, 400, "masjid")
	check_button(app, copy.fitr_button)
	var prayer := check_button(app, copy.eid_button)
	var greeting := expect_label(app, copy.eid_line)
	if prayer != null and greeting != null:
		var a := prayer.get_global_rect()
		var b := greeting.get_global_rect()
		helper.check(a.end.y <= b.position.y or (a.position.y < b.end.y and b.position.y < a.end.y and a.end.x <= b.position.x), "the greeting follows the Eid prayer button")
	await capture_state(app, MASTER_STEMS[9])

	var before := accounts(app)
	await click(app, copy.eid_button)
	check_panel(app, "eid", copy.eid)
	helper.check(app.day == EID_DAY and app.minute_of_day == 400, "Eid prayer leaves the clock at 06:40")
	helper.check(accounts(app) == before, "Eid prayer leaves coins, trust and public reputation unchanged")
	await capture_state(app, MASTER_STEMS[10])
	await click(app, copy.eid.to_map)
	helper.check(app.ui.screen == "market_map" and app.current_place == "masjid", "the Eid panel returns to the Masjid on the market map")
	check_button(app, copy.eid_button, false)
	expect_label(app, copy.eid_line)

	stage(app, EID_DAY, 600, "spice")
	expect_label(app, copy.eid_line)
	check_button(app, copy.eid_button, false)
	check_button(app, copy.fitr_button, false)
	await capture_state(app, MASTER_STEMS[11])
	stage(app, EID_DAY, 600, "masjid")
	await hit(app, app.ui.clock_panel.get_global_rect().get_center())
	helper.check(app.ui.screen == "prayer_record", "the native clock opens Today's prayers")
	await click(app, app.ui.prayer_record.record_button)
	helper.check(app.ui.screen == "all_prayers", "Today's prayers opens All your prayers")
	expect_label(app, app.ui.prayer_record.panel.empty)
	check_record_rows(app)
	await capture_state(app, MASTER_STEMS[12])
	await click(app, app.ui.prayer_record.panel.back_market)

	stage(app, EID_DAY + 1, 400, "masjid")
	check_button(app, copy.night_button, false)
	check_button(app, copy.fitr_button, false)
	check_button(app, copy.eid_button, false)
	expect_label(app, copy.eid_line, false)
	await capture_state(app, MASTER_STEMS[13])


func capture_fitr(app: Node3D) -> void:
	await arrive(app)
	var fitr_day := FIRST_RAMADAN_DAY + int(copy.numbers.fitr_from_day) - 1
	var cost := int(copy.numbers.fitr_cost)
	var pay := str(copy.fitr.pay).format({"n": cost})
	stage(app, fitr_day, 600, "masjid")
	check_button(app, copy.fitr_button)
	expect_label(app, app.ramadan.fasting_line())
	await capture_state(app, MASTER_STEMS[4])
	await click(app, copy.fitr_button)
	check_panel(app, "fitr", copy.fitr)
	check_button(app, pay)
	expect_label(app, copy.fitr.given, false)
	expect_label(app, copy.fitr.not_enough, false)
	await capture_state(app, MASTER_STEMS[5])

	var before := accounts(app)
	await click(app, pay)
	check_panel(app, "fitr", copy.fitr)
	check_button(app, pay, false)
	expect_label(app, copy.fitr.given)
	helper.check(accounts(app) == [before[0] - cost, before[1], before[2]], "the live payment only removes the locked coin cost")
	helper.check(app.day == fitr_day and app.minute_of_day == 600, "zakat al-fitr payment leaves the clock unchanged")
	await capture_state(app, MASTER_STEMS[6])
	await click(app, copy.fitr.to_map)
	helper.check(app.ui.screen == "market_map" and app.current_place == "masjid", "the zakat al-fitr panel returns to the Masjid on the market map")
	check_button(app, copy.fitr_button, false)
	await capture_state(app, MASTER_STEMS[7])

	await arrive(app)
	app.progress.coins = 1
	stage(app, fitr_day, 600, "masjid")
	await click(app, copy.fitr_button)
	check_panel(app, "fitr", copy.fitr)
	check_button(app, pay, false)
	expect_label(app, copy.fitr.not_enough)
	expect_label(app, copy.fitr.given, false)
	helper.check(accounts(app) == [1, STARTING_TRUST, []], "the unaffordable panel leaves coins, trust and public reputation unchanged")
	await capture_state(app, MASTER_STEMS[8])


func arrive(app: Node3D) -> void:
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	app.clock.reset()
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival opens the live Inn map")
	helper.check(accounts(app) == [STARTING_COINS, STARTING_TRUST, []], "the arrival wallet and trust match the locked setup")


func stage(app: Node3D, day: int, minute: int, place: String) -> void:
	app.clock.skip_to(day, minute)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == place, "live map at " + place)
	helper.check(app.day == day and app.minute_of_day == minute, "live clock at day %d minute %d" % [day, minute])


func accounts(app: Node3D) -> Array:
	return [app.progress.coins, app.progress.trust, app.ui.reputation_lines().duplicate(true)]


func check_panel(app: Node3D, screen: String, panel_copy: Dictionary) -> void:
	helper.check(app.ui.screen == screen, "the native " + screen + " panel is open")
	expect_label(app, str(panel_copy.kicker).to_upper())
	expect_label(app, panel_copy.title)
	expect_label(app, panel_copy.text)
	check_button(app, panel_copy.to_map)


func check_record_rows(app: Node3D) -> void:
	var record_copy: Dictionary = copy.record
	var ramadan_row := expect_label(app, app.ramadan.data.record.tarawih)
	var previous_y := ramadan_row.global_position.y if ramadan_row != null else 0.0
	var expected := {
		"nights": str(record_copy.count).format({"n": 2}),
		"fitr": record_copy.no,
		"eid": record_copy.yes_eid,
	}
	for key: String in expected:
		var row := expect_label(app, record_copy[key])
		if not helper.check(row != null and row.global_position.y > previous_y, "private row follows the previous row: " + str(record_copy[key])):
			continue
		previous_y = row.global_position.y
		var displayed := ""
		for child in row.get_parent().get_children():
			if child is Label and child.position.y == row.position.y and child.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
				displayed = child.text
		helper.check(displayed == expected[key], "rendered private row: %s = %s" % [record_copy[key], expected[key]])
	var note := expect_label(app, str(app.ui.prayer_record.panel.note).to_upper())
	helper.check(note != null and note.global_position.y > previous_y, "the privacy note follows the three new rows")


func check_button(app: Node3D, caption: String, expected: bool = true) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check(not caption.is_empty() and (button != null) == expected, "button %s: %s" % ["shown" if expected else "hidden", caption])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits the viewport: " + caption)
	return button


func expect_label(app: Node3D, value: String, expected: bool = true) -> Control:
	var label := find_label(app.ui.content, value)
	helper.check(not value.is_empty() and (label != null) == expected, "text %s: %s" % ["shown" if expected else "hidden", value])
	if label != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "text fits the viewport: " + value)
	return label


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


func capture_state(app: Node3D, stem: String) -> void:
	var filename := stem + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.date = app.clock.date_label(app.day)
	state.ramadan = app.ramadan.record()
	state.eid_al_fitr = app.eid_al_fitr.record()
	state.prayer_totals = app.clock.totals()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE28_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("EID AL-FITR NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
