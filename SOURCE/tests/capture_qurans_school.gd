extends "res://tests/capture_identity.gd"
## DOC-TFG-0086: native viewport evidence for LOCK 25 V1.

const Foundations = preload("res://game/foundations.gd")
const OUTPUT := "res://../GAME/APPROVED/QURANS_SCHOOL/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/QURANS_SCHOOL/RECORD/qurans_school_data_V1.json"
const MASTER_STEMS := [
	"u01_masjid__idris_school_button",
	"u02_school__panel_before_page_1",
	"u03_school__faris_first_child",
	"u04_school__another_child",
	"u05_school__quran_copied",
	"u06_people_say__qurans_and_school",
	"u07_school__secret_ticked",
	"u08_school__quran_in_secret",
	"u09_people_say__secret_no_line",
	"u10_school__not_enough_coins",
	"u11_masjid__after_1530_none",
]
const MORNING := 600
const STARTING_COINS := 200
const STARTING_TRUST := 45

var copy: Dictionary
var panel: Dictionary
var numbers: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--qurans-school-output="):
			return argument.trim_prefix("--qurans-school-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Qurans and school capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Qurans and school evidence directory")
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
	helper.report.method = "Native Godot viewport. Production controls drive the Idris meeting, first scholar page, payments, private giving checkbox and What people say."
	helper.report.fixture = "After fair arrival, passive clock ticks pause. The fixtures stage Thursday time, place, 200 coins and 45 trust, with 20 coins for u10. Reputation views face the square from a1. All payment results use the live game."
	app.set_process(false)
	var runtime := FileAccess.get_file_as_bytes("res://data/qurans_school.json")
	if not helper.check(not runtime.is_empty() and runtime == FileAccess.get_file_as_bytes(LOCKED_DATA), "runtime Qurans and school data matches the locked bytes"):
		finish(app)
		return
	copy = app.qurans_school.data
	panel = copy.panel
	numbers = copy.numbers

	await capture_public(app)
	await capture_secret(app)
	await capture_shortage_and_closing(app)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all eleven locked states have native captures")
	finish(app)


func capture_public(app: Node3D) -> void:
	await arrive(app)
	stage(app, int(numbers.from) - 1, "masjid")
	check_button(app, copy.masjid_button, false)
	stage(app, int(numbers.from), "masjid")
	check_button(app, copy.masjid_button)
	stage(app, MORNING, "masjid")
	var actions: Dictionary = app.identity.clock.masjid_actions
	await click(app, actions.none_yet)
	var teacher: Dictionary = app.identity.teacher
	for beat: Dictionary in teacher.beats:
		await click(app, beat.choices[0].label)
		await click(app, teacher.buttons.continue)
	await click(app, teacher.buttons.leave)
	helper.check(app.idris_met and app.ui.screen == "market_map" and app.current_place == "masjid", "Idris meeting completes and returns to the Masjid")
	check_button(app, actions.after_meeting)
	check_button(app, copy.masjid_button)
	await capture_state(app, 0)

	await click(app, copy.masjid_button)
	check_panel(app, panel.text, 0, 0)
	check_secret(app, false, false)
	await capture_state(app, 1)

	await click(app, pay_caption("school"))
	var public_trust := STARTING_TRUST + int(numbers.trust_per_day)
	var coins := STARTING_COINS - int(numbers.school_cost)
	check_wallet(app, coins, public_trust)
	check_panel(app, panel.first_child + " " + panel.public, 0, 1)
	await capture_state(app, 2)
	await click(app, pay_caption("school"))
	coins -= int(numbers.school_cost)
	check_wallet(app, coins, public_trust)
	check_panel(app, panel.more_child + " " + panel.public, 0, 2)
	await capture_state(app, 3)
	await click(app, pay_caption("quran"))
	check_wallet(app, coins - int(numbers.quran_cost), public_trust)
	check_panel(app, panel.quran_done + " " + panel.public, 1, 2)
	await capture_state(app, 4)

	await click(app, panel.back)
	helper.check(app.ui.screen == "market_map", "Back returns to the market map")
	await click(app, copy.masjid_button)
	check_panel(app, panel.text, 1, 2)
	await click(app, panel.back)
	await open_reputation(app)
	helper.check(app.ui.reputation_lines() == [copy.say.qurans, copy.say.school], "both public payment types add the locked Idris rows in order")
	for row: Array in [copy.say.qurans, copy.say.school]:
		expect_text(app, "“%s”" % row[0])
	expect_text(app, copy.say.qurans[1], 2)
	expect_text(app, app.chapter.rep.tone[str(int(copy.say.qurans[2]))], 2)
	await capture_state(app, 5)


func capture_secret(app: Node3D) -> void:
	await arrive(app)
	stage(app, MORNING, "inn")
	await click(app, app.chapter.places.inn)
	await click(app, app.chapter.purse.ask_baker)
	await click(app, str(app.chapter.purse.take_page).format({"teacher": app.chapter.teacher}))
	helper.check(app.ui.screen == "purse_page" and app.open_purse.page_read, "the first scholar page opens and unlocks secret giving")
	await click(app, app.chapter.page.back)
	await click(app, app.chapter.purse.not_now)
	stage(app, MORNING, "masjid")
	await click(app, copy.masjid_button)
	check_secret(app, true, false)
	await click(app, panel.secret_label)
	check_secret(app, true, true)
	check_panel(app, panel.text, 0, 0)
	await capture_state(app, 6)

	await click(app, pay_caption("quran"))
	check_wallet(app, STARTING_COINS - int(numbers.quran_cost), STARTING_TRUST)
	check_panel(app, panel.quran_done + " " + panel.secret, 1, 0)
	check_secret(app, true, true)
	await capture_state(app, 7)
	await click(app, panel.back)
	await open_reputation(app)
	helper.check(app.ui.reputation_lines().is_empty(), "the secret payment leaves reputation empty")
	expect_text(app, app.chapter.rep.empty)
	expect_text(app, app.chapter.rep.secret_note, 0)
	await capture_state(app, 8)


func capture_shortage_and_closing(app: Node3D) -> void:
	await arrive(app)
	app.progress.coins = 20
	stage(app, MORNING, "masjid")
	await click(app, copy.masjid_button)
	check_wallet(app, 20, STARTING_TRUST)
	check_panel(app, panel.text, 0, 0)
	check_secret(app, false, false)
	expect_text(app, panel.not_enough, 2)
	await capture_state(app, 9)
	await click(app, panel.back)

	app.progress.coins = STARTING_COINS
	stage(app, int(numbers.until) - 1, "masjid")
	check_button(app, copy.masjid_button)
	stage(app, int(numbers.until), "masjid")
	check_button(app, copy.masjid_button, false)
	stage(app, 960, "masjid")
	check_button(app, copy.masjid_button, false)
	check_button(app, app.clock.prayer_label(true))
	await capture_state(app, 10)


func arrive(app: Node3D) -> void:
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	app.clock.reset()
	app.progress.coins = STARTING_COINS
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival opens the live Inn map")
	helper.check(app.qurans_school.qurans_given == 0 and app.qurans_school.children_in_school == 0
		and app.ui.reputation_lines().is_empty() and not app.open_purse.page_read, "a fresh session resets the counters, reputation and secret unlock")


func stage(app: Node3D, minute: int, place: String) -> void:
	app.clock.skip_to(1, minute)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == place, "live market map at " + place)
	helper.check(app.day == 1 and app.minute_of_day == minute, "live Thursday clock at minute %d" % minute)


func open_reputation(app: Node3D) -> void:
	app.player.position = app.world.point("a1")
	var toward_square: Vector3 = app.world.point(app.data.square.centre) - app.player.position
	app.player.yaw = atan2(-toward_square.x, -toward_square.z)
	app.player.update_camera()
	app.update_state()
	await click(app, app.chapter.purse.morning.to_rep)
	helper.check(app.ui.screen == "reputation", "What people say opens through the market map control")


func check_wallet(app: Node3D, coins: int, trust: int) -> void:
	helper.check(app.progress.coins == coins and app.progress.trust == trust, "wallet %d and trust %d match the locked result" % [coins, trust])


func check_panel(app: Node3D, story: String, qurans: int, children: int) -> void:
	helper.check(app.ui.screen == "qurans_school", "the native Qurans and school panel is open")
	for value: String in [panel.kicker, panel.title, story, panel.quran, panel.quran_line, panel.school, panel.school_line]:
		expect_text(app, value)
	for kind: String in ["quran", "school"]:
		check_button(app, pay_caption(kind), app.progress.coins >= int(numbers[kind + "_cost"]))
	var counters: String = panel.counter.format({"n": qurans, "m": Foundations.format_count(int(numbers.goal_qurans))})
	counters += " · " + panel.counter_school.format({"n": children, "m": Foundations.format_count(int(numbers.goal_children))})
	var total := expect_text(app, counters)
	var back := check_button(app, panel.back)
	if total != null and back != null:
		var back_rect := back.get_global_rect()
		var total_y := total.get_global_rect().get_center().y
		helper.check(total_y >= back_rect.position.y and total_y <= back_rect.end.y, "the visible Back button shares the counter row")
	helper.check(app.qurans_school.qurans_given == qurans and app.qurans_school.children_in_school == children, "live counters read %d Qurans and %d children" % [qurans, children])


func check_secret(app: Node3D, unlocked: bool, selected: bool) -> void:
	var checkbox := check_button(app, panel.secret_label, unlocked)
	helper.check((checkbox is CheckBox) == unlocked and (checkbox == null or checkbox.button_pressed == selected),
		"the checkbox matches the first-page unlock and selection")
	expect_text(app, panel.secret_locked, 0 if unlocked else 1)
	helper.check(app.qurans_school.secret_selected == selected, "the live secret selection matches the panel")


func pay_caption(kind: String) -> String:
	return str(panel.pay).format({"n": int(numbers[kind + "_cost"])})


func check_button(app: Node3D, caption: String, shown: bool = true) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == shown and not caption.is_empty(), "button %s: %s" % ["shown" if shown else "hidden", caption])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits the viewport: " + caption)
	return button


func expect_text(app: Node3D, value: String, count: int = 1) -> Control:
	var controls: Array[Control] = []
	find_text(app.ui.content, value.to_lower(), controls)
	helper.check(controls.size() == count, "visible instances of locked text (%d): %s" % [count, value])
	for control in controls:
		helper.check(app.get_viewport().get_visible_rect().encloses(control.get_global_rect()), "text fits the viewport: " + value)
	return controls[0] if not controls.is_empty() else null


func find_text(node: Node, folded: String, controls: Array[Control]) -> void:
	if node is Control and not node.is_visible_in_tree():
		return
	if (node is Label and node.text.to_lower() == folded) or (node is RichTextLabel and node.get_parsed_text().to_lower() == folded):
		controls.append(node)
	for child in node.get_children():
		find_text(child, folded, controls)


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.qurans = app.qurans_school.qurans_given
	state.children = app.qurans_school.children_in_school
	state.first_page_read = app.open_purse.page_read
	state.secret_selected = app.qurans_school.secret_selected
	state.what_people_say = app.ui.reputation_lines()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE32_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("QURANS AND SCHOOL NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
