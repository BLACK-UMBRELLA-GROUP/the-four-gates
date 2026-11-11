extends "res://tests/capture_identity.gd"
## DOC-TFG-0092: native viewport evidence for LOCK 27 V1.

const OUTPUT := "res://../GAME/APPROVED/REGULARS_AT_PRAYER/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/REGULARS_AT_PRAYER/RECORD/regulars_at_prayer_data_V1.json"
const MASTER_STEMS := [
	"ra01_spice__stall_shut_for_dhuhr",
	"ra02_quay__jamal_at_the_masjid",
	"ra03_scales__musa_at_the_masjid",
	"ra04_masjid__at_the_masjid_for_dhuhr",
	"ra05_board__salma_stays",
	"ra06_spice__open_again_1231",
	"ra07_quay__jamal_at_asr",
	"ra08_spice__friday_unchanged",
]
const FRIDAY := 2
const SATURDAY := 3
const THURSDAY := 8
const FRIDAY_NOON := 12 * 60 + 10
const DHUHR := 12 * 60 + 15
const AFTER_DHUHR := 12 * 60 + 31
const ASR := 15 * 60 + 40
const TRUST := 45
const COINS := 198

var copy: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--regulars-at-prayer-output="):
			return argument.trim_prefix("--regulars-at-prayer-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Regulars at prayer capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the regulars at prayer evidence directory")
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
	helper.report.method = "Native Godot viewport. Viewport-local clicks complete fair arrival and the Idris meeting before rendering the production market map and place bars."
	helper.report.fixture = "Passive clock ticks pause. The fair arrival supplies 198 coins, trust is set to 45 and the player is placed at the locked map markers. The clock advances through day 2 Friday, day 3 Saturday and day 8 Thursday (the first Thursday after arrival)."
	app.set_process(false)
	copy = app.market_day.prayer_data
	var runtime := FileAccess.get_file_as_bytes("res://data/regulars_at_prayer.json")
	helper.check(not runtime.is_empty() and runtime == FileAccess.get_file_as_bytes(LOCKED_DATA),
		"runtime data is byte-for-byte LOCK 27 V1")
	await arrive_and_meet_idris(app)

	var reputation: Array = app.ui.reputation_lines()
	stage(app, FRIDAY, FRIDAY_NOON, "spice")
	check_friday_closure(app)
	await capture_state(app, 7)
	check_friday_asr(app)

	stage(app, SATURDAY, ASR, "quay")
	check_person(app, "jamal", "Asr")
	await capture_state(app, 6)

	stage(app, THURSDAY, DHUHR, "spice")
	check_person(app, "rashid", "Dhuhr")
	check_closed_stall(app, copy.text.stall.format({"prayer": "Dhuhr"}))
	await capture_state(app, 0)
	stage(app, THURSDAY, DHUHR, "quay")
	check_person(app, "jamal", "Dhuhr")
	await capture_state(app, 1)
	stage(app, THURSDAY, DHUHR, "scales")
	check_person(app, "musa", "Dhuhr")
	await capture_state(app, 2)
	stage(app, THURSDAY, DHUHR, "masjid")
	check_masjid(app, "Dhuhr")
	await capture_state(app, 3)
	stage(app, THURSDAY, DHUHR, "board")
	check_button(app, talk_caption(app, "salma"), true)
	check_label(app, person_notice(app, "salma", "Dhuhr"), false)
	await capture_state(app, 4)
	stage(app, THURSDAY, DHUHR, "weaver")
	check_button(app, talk_caption(app, "layla"), true)
	check_label(app, person_notice(app, "layla", "Dhuhr"), false)

	stage(app, THURSDAY, DHUHR, "spice")
	app.clock.advance_to(THURSDAY, AFTER_DHUHR, false)
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == "spice"
		and app.minute_of_day == AFTER_DHUHR, "ra06 reopens in place as the live clock advances")
	check_button(app, app.market_stall.data.place.spice_button, true)
	check_button(app, app.rashids_loan.data.ask_button, true)
	check_button(app, talk_caption(app, "rashid"), true)
	check_label(app, copy.text.stall.format({"prayer": "Dhuhr"}), false)
	check_label(app, person_notice(app, "rashid", "Dhuhr"), false)
	await capture_state(app, 5)

	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all eight locked states have native captures")
	helper.check(app.progress.coins == COINS and app.progress.trust == TRUST
		and app.ui.reputation_lines() == reputation, "observing attendance leaves coins, trust and reputation unchanged")
	finish(app)


func arrive_and_meet_idris(app: Node3D) -> void:
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[0])
	var teacher: Dictionary = app.identity.teacher
	for beat: Dictionary in teacher.beats:
		await click(app, beat.choices[0].label)
		await click(app, teacher.buttons.continue)
	await click(app, teacher.buttons.leave)
	app.progress.apply_trust(TRUST - app.progress.trust)
	app.update_state()
	helper.check(app.idris_met and app.ui.screen == "market_map" and app.current_place == "masjid"
		and app.progress.coins == COINS and app.progress.trust == TRUST,
		"fair arrival and the real Idris meeting produce the locked map fixture")


func stage(app: Node3D, day: int, minute: int, place: String) -> void:
	app.clock.skip_to(day, minute)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == place
		and app.day == day and app.minute_of_day == minute,
		"live market map at %s on day %d at %02d:%02d" % [place, day, minute / 60, minute % 60])


func check_friday_closure(app: Node3D) -> void:
	var hours_text: Dictionary = app.market_day.data.text
	check_closed_stall(app, hours_text.shop_closed_friday)
	check_button(app, talk_caption(app, "rashid"), false)
	check_label(app, hours_text.closed_friday.format({"name": regular_name(app, "rashid")}), true)
	check_label(app, person_notice(app, "rashid", "Dhuhr"), false)
	helper.check(app.market_day.prayer_attendance().is_empty(), "Friday Dhuhr uses the earlier Friday rule")


func check_friday_asr(app: Node3D) -> void:
	stage(app, FRIDAY, ASR, "spice")
	check_person(app, "rashid", "Asr")
	check_closed_stall(app, copy.text.stall.format({"prayer": "Asr"}))
	stage(app, FRIDAY, ASR, "quay")
	check_person(app, "jamal", "Asr")
	stage(app, FRIDAY, ASR, "scales")
	check_person(app, "musa", "Asr")
	stage(app, FRIDAY, ASR, "masjid")
	check_masjid(app, "Asr")


func check_closed_stall(app: Node3D, caption: String) -> void:
	check_button(app, app.market_stall.data.place.spice_button, false)
	check_button(app, app.rashids_loan.data.ask_button, false)
	check_button(app, app.rashids_loan.data.pay_button, false)
	check_label(app, caption, true)


func check_person(app: Node3D, regular_id: String, prayer: String) -> void:
	check_button(app, talk_caption(app, regular_id), false)
	check_label(app, person_notice(app, regular_id, prayer), true)


func check_masjid(app: Node3D, prayer: String) -> void:
	var names := PackedStringArray()
	for regular_id: String in copy.goers:
		names.append(regular_name(app, regular_id))
	var calligraphy := check_button(app, app.names_of_allah.data.button, true)
	var caption: String = copy.text.masjid.format({"prayer": prayer, "names": ", ".join(names)})
	var attendance := check_label(app, caption, true)
	if calligraphy != null and attendance != null:
		helper.check(attendance.get_global_rect().position.y >= calligraphy.get_global_rect().end.y,
			"attendance follows the calligraphy button on the second row")


func regular_name(app: Node3D, regular_id: String) -> String:
	return app.market_day.data.hours[regular_id].name


func talk_caption(app: Node3D, regular_id: String) -> String:
	return app.talking.data.talk_button.format({"name": regular_name(app, regular_id)})


func person_notice(app: Node3D, regular_id: String, prayer: String) -> String:
	return copy.text.person.format({"name": regular_name(app, regular_id), "prayer": prayer})


func check_button(app: Node3D, caption: String, shown: bool) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == shown, "%s: button %s" % [app.current_place, caption + (" shown" if shown else " hidden")])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits: " + caption)
	return button


func check_label(app: Node3D, caption: String, shown: bool) -> Label:
	var label := find_label(app.ui.content, caption)
	helper.check((label != null) == shown, "%s: label %s" % [app.current_place, caption + (" shown" if shown else " hidden")])
	if label != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "label fits: " + caption)
	return label


func find_label(node: Node, caption: String) -> Label:
	if node is Control and not node.is_visible_in_tree():
		return null
	if node is Label and node.text == caption:
		return node
	for child in node.get_children():
		var label := find_label(child, caption)
		if label != null:
			return label
	return null


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.attendance = app.market_day.prayer_attendance()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE34_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("REGULARS AT PRAYER NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
