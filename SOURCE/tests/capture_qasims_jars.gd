extends "res://tests/capture_identity.gd"
## DOC-TFG-0047: native viewport evidence for LOCK 12 V1.

const OUTPUT := "res://../GAME/APPROVED/QASIMS_JARS/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/QASIMS_JARS/RECORD/qasims_jars_data_V1.json"
const MASTER_STEMS := [
	"q01_quay__daytime_no_boat",
	"q02_quay__boatman_waves",
	"q03_jars__qasims_offer",
	"q04_jars__twenty_coins",
	"q05_quay__no_boat_same_night",
	"q06_quay__after_walk_away",
	"q07_people_say__talk_2_runs",
	"q08_people_say__seen_4_runs",
	"q09_people_say__smuggler_10_runs",
]
const SATURDAY := 3
const MORNING := 600
const EVENING := 1200
const STARTING_TRUST := 45
const STARTING_COINS := 198

var jars: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--qasims-jars-output="):
			return argument.trim_prefix("--qasims-jars-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Qasim's jars capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Qasim's jars evidence directory")
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
	helper.report.method = "Real native Godot viewport. Viewport-local clicks exercise arrival, the route to the Quay, both offer choices, return to the Quay map and What people say."
	helper.report.fixture = "Passive clock ticks are paused. The fair arrival supplies 198 coins and the harness sets starting trust to 45. q01 uses Saturday at 10:00. q02–q06 use the same evening at 20:00. The remaining runs are made on later nights using the live offer. q07–q09 show the accumulated wallet and the existing daylight lane towards the square the following morning. Position and camera fixtures frame that lane and return the player to the Quay for the next run."
	app.set_process(false)
	jars = app.qasims_jars.data
	var locked := FileAccess.get_file_as_bytes(LOCKED_DATA)
	helper.check(not locked.is_empty() and locked == FileAccess.get_file_as_bytes("res://data/qasims_jars.json"), "runtime jars data matches the locked bytes")

	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	set_time(app, SATURDAY, MORNING)
	if not await travel(app, "quay"):
		return
	expect_quay_action(app, false)
	helper.check(app.day == SATURDAY and app.minute_of_day == MORNING and app.progress.coins == STARTING_COINS, "daytime Quay fixture uses the fair wallet on a later non-Friday")
	await capture_state(app, 0)

	set_time(app, SATURDAY, EVENING)
	expect_quay_action(app, true)
	await capture_state(app, 1)
	await click(app, jars.quay_button)
	helper.check(app.ui.screen == "qasims_offer", "the boatman opens the locked offer")
	expect_copy(app, jars.offer)
	expect_button(app, jars.offer.carry, true)
	expect_button(app, jars.offer.no, true)
	await capture_state(app, 2)
	await click(app, jars.offer.no)
	expect_quay_action(app, true)
	helper.check(app.day == SATURDAY and app.minute_of_day == EVENING and app.qasims_jars.runs == 0, "Walk away keeps the clock and adds no run")
	helper.check(app.progress.coins == STARTING_COINS and app.progress.trust == STARTING_TRUST and app.ui.reputation_lines().is_empty(), "Walk away changes no wallet, trust or talk")
	await capture_state(app, 5)

	await click(app, jars.quay_button)
	await click(app, jars.offer.carry)
	helper.check(app.ui.screen == "qasims_done", "carrying opens the locked result")
	expect_copy(app, jars.done)
	expect_label(app, str(jars.done.runs).format({"n": 1}).to_upper())
	expect_button(app, jars.done.to_map, true)
	helper.check(app.day == SATURDAY and app.minute_of_day == EVENING and app.qasims_jars.runs == 1, "carrying marks the night and does not advance the clock")
	helper.check(app.progress.coins == STARTING_COINS + int(jars.numbers.pay) and app.progress.trust == STARTING_TRUST and app.ui.reputation_lines().is_empty(), "one run pays the locked fee and changes no trust or talk")
	await capture_state(app, 3)
	await click(app, jars.done.to_map)
	expect_quay_action(app, false)
	await capture_state(app, 4)

	for run_count in range(2, 11):
		set_time(app, SATURDAY + run_count - 1, EVENING)
		await click(app, jars.quay_button)
		await click(app, jars.offer.carry)
		helper.check(app.ui.screen == "qasims_done" and app.qasims_jars.runs == run_count, "the later night counts once: %d" % run_count)
		helper.check(app.progress.coins == STARTING_COINS + int(jars.numbers.pay) * run_count, "the wallet has one fee per run: %d" % run_count)
		await click(app, jars.done.to_map)
		match run_count:
			2:
				await capture_talk(app, 6, jars.say.talk, STARTING_TRUST)
			4:
				await capture_talk(app, 7, jars.say.seen, STARTING_TRUST + int(jars.numbers.seen_trust))
			10:
				await capture_talk(app, 8, jars.say.smuggler, STARTING_TRUST + int(jars.numbers.seen_trust) + int(jars.numbers.smuggler_trust))

	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all nine master states were captured")
	finish(app)


func set_time(app: Node3D, day: int, minute: int) -> void:
	app.clock.skip_to(day, minute)
	app.update_state()


func expect_quay_action(app: Node3D, available: bool) -> void:
	helper.check(app.ui.screen == "market_map" and app.current_place == "quay", "the Quay is active on the market map")
	expect_button(app, jars.quay_button, available)


func expect_copy(app: Node3D, copy: Dictionary) -> void:
	expect_label(app, str(copy.kicker).to_upper())
	expect_label(app, copy.title)
	expect_label(app, copy.text)


func expect_button(app: Node3D, value: String, visible: bool) -> void:
	var button := helper.find_button(app.ui, value)
	helper.check((button != null) == visible, "button %s: %s" % ["shown" if visible else "hidden", value])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits in viewport: " + value)


func expect_label(app: Node3D, value: String) -> void:
	var label := find_label(app.ui, value)
	helper.check(label != null, "visible locked label: " + value)
	if label != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "label fits in viewport: " + value)


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


func capture_talk(app: Node3D, index: int, line: Array, trust: int) -> void:
	set_time(app, app.day + 1, MORNING)
	var original_yaw: float = app.player.yaw
	var lane: Vector3 = app.world.point("a2")
	var toward_square: Vector3 = app.world.point(app.data.square.centre) - lane
	app.player.yaw = atan2(-toward_square.x, -toward_square.z)
	place_player(app, lane)
	await click(app, app.chapter.purse.morning.to_rep)
	await app.get_tree().physics_frame
	helper.check(not app.night and app.minute_of_day == MORNING, "the reputation view uses the next morning's daylight")
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [line], "What people say shows only the highest reached jars line")
	helper.check(app.progress.trust == trust, "the rumor threshold has the exact trust result")
	expect_label(app, "“%s”" % line[0])
	expect_label(app, str(line[1]).to_upper())
	expect_label(app, app.chapter.rep.tone[str(int(line[2]))])
	await capture_state(app, index)
	await click(app, app.chapter.rep.to_map)
	app.player.yaw = original_yaw
	place_player(app, app.world.point("quay"))


func place_player(app: Node3D, position: Vector3) -> void:
	app.player.position = position
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.runs = app.qasims_jars.runs
	state.dice_nights = app.dice_house.nights


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE19_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("QASIM'S JARS NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
