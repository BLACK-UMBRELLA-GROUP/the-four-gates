extends "res://tests/capture_identity.gd"
## DOC-TFG-0062: native viewport evidence for LOCK 17 V1.

const OUTPUT := "res://../GAME/APPROVED/HARM_IN_THE_ROAD/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/HARM_IN_THE_ROAD/RECORD/harm_in_the_road_data_V1.json"
const MASTER_STEMS := [
	"p01_weaver__thorn_branch_day0",
	"p02_harm__moved_the_thorns",
	"p03_weaver__gone_after_moving",
	"p04_spice__pot_shards_day1",
	"p05_quay__low_rope_day2",
	"p06_board__nothing_elsewhere",
	"p07_weaver__nothing_at_night",
	"p08_weaver__nothing_before_0630",
	"p09_harm__count_7",
]
const MORNING := 9 * 60
const STARTING_COINS := 198
const STARTING_TRUST := 45

var copy: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--harm-in-the-road-output="):
			return argument.trim_prefix("--harm-in-the-road-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Harm in the road capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the harm in the road evidence directory")
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
	helper.report.method = "Real native Godot viewport. Viewport clicks drive fair arrivals, physical routes to market places, the move buttons and the return to the map."
	helper.report.fixture = "Passive ticks are paused. Fair arrivals supply 198 coins, trust is set to 45, and the clock is advanced to the named capture minutes. p04/p05 use display days 2/3. p06 uses day 8 at the board while the harm is in Weaver's lane. p01/p02/p03 and p08 use day 22, a Thursday with the arrival day's rotation. p07 uses day 43, a fresh Thursday with the same rotation. p09 uses day 5 at the Gate of Trust with the count seeded to 6 as in the master."
	app.set_process(false)
	if not helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/harm_in_the_road.json"), "runtime harm data matches the locked bytes"):
		finish(app)
		return
	copy = app.harm_in_the_road.data

	await arrive(app)
	stage_time(app, 2, MORNING)
	if not await travel(app, "spice"):
		return
	expect_map_harm(app, "spice", 1)
	await capture_state(app, 3)

	await arrive(app)
	stage_time(app, 3, MORNING)
	if not await travel(app, "quay"):
		return
	expect_map_harm(app, "quay", 2)
	await capture_state(app, 4)

	stage_time(app, 8, MORNING)
	if not await travel(app, "board"):
		return
	helper.check(app.harm_in_the_road.available_at("weaver") == copy.harms[1], "the off-place capture has active harm elsewhere")
	expect_map_harm(app, "board")
	await capture_state(app, 5)

	stage_time(app, 22, 6 * 60)
	if not await travel(app, "weaver"):
		return
	expect_map_harm(app, "weaver")
	await capture_state(app, 7)

	stage_time(app, 22, MORNING)
	expect_map_harm(app, "weaver", 0)
	await capture_state(app, 0)
	await move_and_check(app, 0, 1)
	await capture_state(app, 1)
	await click(app, copy.panel.to_map)
	expect_map_harm(app, "weaver")
	await capture_state(app, 2)

	stage_time(app, 43, 20 * 60)
	helper.check(app.harm_in_the_road.done_day != app.day - 1, "the night capture is on an untouched harm day")
	expect_map_harm(app, "weaver")
	await capture_state(app, 6)

	await arrive(app)
	stage_time(app, 5, MORNING)
	if not await travel(app, "gate"):
		return
	app.harm_in_the_road.count = 6
	expect_map_harm(app, "gate", 1)
	await move_and_check(app, 1, 7)
	await capture_state(app, 8)
	await click(app, copy.panel.to_map)
	expect_map_harm(app, "gate")

	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all nine master states were captured")
	finish(app)


func arrive(app: Node3D) -> void:
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival opens the market map at the Inn")
	helper.check(app.progress.coins == STARTING_COINS and app.harm_in_the_road.count == 0, "fair arrival supplies the wallet and a fresh private count")
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)


func stage_time(app: Node3D, day: int, minute: int) -> void:
	app.clock.skip_to(day, minute)
	app.update_state()
	helper.check(app.day == day and app.minute_of_day == minute, "capture clock is at day %d minute %d" % [day, minute])


func expect_map_harm(app: Node3D, place: String, index: int = -1) -> void:
	helper.check(app.ui.screen == "market_map" and app.current_place == place, "market map is at " + place)
	for i: int in range(copy.harms.size()):
		var harm: Dictionary = copy.harms[i]
		var label := find_label(app.ui, harm.bar)
		var button: Button = helper.find_button(app.ui, harm.move)
		var shown := i == index
		helper.check((label != null) == shown, "harm words %s: %s" % ["shown" if shown else "hidden", harm.bar])
		helper.check((button != null) == shown, "move button %s: %s" % ["shown" if shown else "hidden", harm.move])
		if shown and label != null and button != null:
			var area := app.get_viewport().get_visible_rect()
			helper.check(area.encloses(label.get_global_rect()) and area.encloses(button.get_global_rect()), "locked harm words and move button fit in the viewport")
			helper.check(label.global_position.y < button.global_position.y or label.get_global_rect().end.x <= button.global_position.x, "the harm words precede the move button")
	helper.check(find_label(app.ui, count_text(app.harm_in_the_road.count)) == null, "the market map does not show the private count")


func move_and_check(app: Node3D, index: int, expected_count: int) -> void:
	var harm: Dictionary = copy.harms[index]
	var minute: int = app.minute_of_day
	var day: int = app.day
	var before: Array = app.ui.reputation_lines().duplicate(true)
	await click(app, harm.move)
	helper.check(app.ui.screen == "harm_done", "the real move button opens the result panel")
	helper.check(app.day == day and app.minute_of_day == minute + int(copy.numbers.minutes), "moving the harm advances five game minutes")
	helper.check(app.harm_in_the_road.done_day == day - 1 and app.harm_in_the_road.count == expected_count, "the zero-based day is marked done and the private count increases once")
	helper.check(app.progress.coins == STARTING_COINS and app.progress.trust == STARTING_TRUST, "moving the harm leaves coins and trust unchanged")
	helper.check(app.ui.reputation_lines() == before, "moving the harm leaves What people say unchanged")
	for value: String in [copy.panel.kicker.to_upper(), harm.move, harm.done, count_text(expected_count)]:
		var label := find_label(app.ui, value)
		helper.check(label != null and app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "visible result words fit: " + value)
	helper.check(helper.find_button(app.ui, copy.panel.to_map) != null, "result offers the locked return-to-map button")


func count_text(count: int) -> String:
	return str(copy.panel.count).format({"n": count}).to_upper()


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
	state.day_index = app.day - 1
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.private_count = app.harm_in_the_road.count
	state.moved_day_index = app.harm_in_the_road.done_day


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE24_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("HARM IN THE ROAD NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
