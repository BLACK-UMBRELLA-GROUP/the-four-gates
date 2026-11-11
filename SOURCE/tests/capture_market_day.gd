extends "res://tests/capture_identity.gd"
## DOC-TFG-0032: native River Market opening-hours evidence for LOCK 7 V1.

const OUTPUT := "res://../GAME/APPROVED/MARKET_DAY/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/MARKET_DAY/RECORD/market_day_data_V1.json"
const MASTER_STEMS := [
	"d01_spice_row__day_open",
	"d02_spice_row__night_shut",
	"d03_square__night_salma_gone",
	"d04_square__before_sunrise_salma_baking",
	"d05_spice_row__before_opening",
	"d06_weaver__friday_prayer",
	"d07_quay__friday_prayer",
	"d08_spice_row__after_friday_prayer",
	"d09_scales__old_musa_gone",
	"d10_quay__jamal_early",
]
const FRIDAY := 2
const SATURDAY := 3
const FIXTURES := [
	{ "day": SATURDAY, "minute": 600, "place": "spice", "regular": "rashid", "closed": "" },
	{ "day": SATURDAY, "minute": 1200, "place": "spice", "regular": "rashid", "closed": "night" },
	{ "day": SATURDAY, "minute": 1200, "place": "board", "regular": "salma", "closed": "night" },
	{ "day": SATURDAY, "minute": 300, "place": "board", "regular": "salma", "closed": "" },
	{ "day": SATURDAY, "minute": 300, "place": "spice", "regular": "rashid", "closed": "night" },
	{ "day": FRIDAY, "minute": 735, "place": "weaver", "regular": "layla", "closed": "friday" },
	{ "day": FRIDAY, "minute": 735, "place": "quay", "regular": "jamal", "closed": "friday" },
	{ "day": FRIDAY, "minute": 765, "place": "spice", "regular": "rashid", "closed": "" },
	{ "day": SATURDAY, "minute": 1060, "place": "scales", "regular": "musa", "closed": "night" },
	{ "day": SATURDAY, "minute": 370, "place": "quay", "regular": "jamal", "closed": "" },
]

var market_day: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--market-day-output="):
			return argument.trim_prefix("--market-day-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Market day capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the market day evidence directory")
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
	helper.report.method = "Native Godot viewport. Viewport clicks complete the arrival and exercise the place buttons. The use input checks closed shops; the production talk entry point checks closed conversations."
	helper.report.fixture = "The harness pauses passive clock ticks and stages the player at the live map positions on Friday day 2 or Saturday day 3. The fair arrival supplies coins and trust. d08 advances the clock at Spice row from 12:15 to 12:45 without changing the screen or player position."
	app.set_process(false)
	var approved: Variant = JSON.parse_string(FileAccess.get_file_as_string(LOCKED_DATA))
	if not helper.check(approved is Dictionary, "the locked market day data is readable"):
		finish(app)
		return
	market_day = approved
	helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/market_day.json"), "runtime market day data matches the locked bytes")

	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	if not helper.check(app.current_place == "inn" and app.ui.screen == "market_map", "fair arrival opens the Inn market map"):
		finish(app)
		return

	for index in FIXTURES.size():
		var fixture: Dictionary = FIXTURES[index]
		var stem: String = MASTER_STEMS[index]
		if index == 7:
			stage(app, FRIDAY, FIXTURES[5].minute, fixture.place)
			check_place_bar(app, { "place": fixture.place, "regular": fixture.regular, "closed": "friday" }, "d08 before reopening")
			app.clock.advance_to(fixture.day, fixture.minute, false)
			app.update_state()
		else:
			stage(app, fixture.day, fixture.minute, fixture.place)
		helper.check(app.ui.screen == "market_map" and app.current_place == fixture.place and app.day == fixture.day and app.minute_of_day == fixture.minute, stem + " is at the locked map place and time")
		check_place_bar(app, fixture, stem)
		await capture_state(app, stem)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all ten locked master states were captured")

	await check_live_actions(app)
	finish(app)


func stage(app: Node3D, day: int, minute: int, place: String) -> void:
	app.clock.reset()
	app.clock.skip_to(day, minute)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()


func check_place_bar(app: Node3D, fixture: Dictionary, context: String) -> void:
	var name_value: String = market_day.hours[fixture.regular].name
	var talk := talk_caption(app, name_value)
	var closed: String = fixture.closed
	expect_button(app, talk, closed.is_empty(), context)
	for kind: String in ["night", "friday"]:
		var message := str(market_day.text["closed_" + kind]).format({"name": name_value})
		expect_label(app, message, closed == kind, context)

	match fixture.place:
		"spice", "weaver":
			var is_stall: bool = fixture.place == "spice"
			var shop_button: String = app.market_stall.data.place.spice_button if is_stall else app.market_stall.clothes_data.place.weaver_button
			var night_text: String = market_day.text.stall_closed_night if is_stall else market_day.text.loom_closed_night
			expect_button(app, shop_button, closed.is_empty(), context)
			expect_label(app, night_text, closed == "night", context)
			expect_label(app, market_day.text.shop_closed_friday, closed == "friday", context)
		"board":
			expect_button(app, app.data.ui.place_actions.board, true, context)
			expect_button(app, app.chapter.places.board, closed.is_empty(), context)
		"quay", "scales":
			expect_button(app, app.data.ui.place_actions[fixture.place], true, context)


func check_live_actions(app: Node3D) -> void:
	stage(app, SATURDAY, 1200, "spice")
	await helper.action(app, "use")
	helper.check(app.ui.screen == "market_map", "use input cannot open Rashid's closed stall")
	app.show_talking()
	helper.check(app.ui.screen == "market_map", "Rashid refuses talk while away")

	stage(app, FRIDAY, 735, "weaver")
	await helper.action(app, "use")
	helper.check(app.ui.screen == "market_map", "use input cannot open Layla's loom during Friday prayer")
	app.show_talking()
	helper.check(app.ui.screen == "market_map", "Layla refuses talk during Friday prayer")

	stage(app, FRIDAY, 765, "spice")
	await click(app, app.market_stall.data.place.spice_button)
	helper.check(app.ui.screen == "stall", "the reopened stall can be used after Friday prayer")
	await click(app, app.market_stall.data.stall.back)

	stage(app, SATURDAY, 1060, "scales")
	await click(app, app.data.ui.place_actions.scales)
	helper.check(app.ui.screen == "lesson", "the scales lesson opens while Old Musa is away")
	app.show_screen("market_map")

	stage(app, SATURDAY, 370, "quay")
	await click(app, talk_caption(app, market_day.hours.jamal.name))
	helper.check(app.ui.screen == "talk" and app.talking.person.id == "jamal", "Jamal can be talked to after opening")
	await click(app, app.talking.data.panel.bye)

	stage(app, SATURDAY, 300, "board")
	await click(app, app.chapter.places.board)
	helper.check(app.ui.screen == "grab_see", "the board starts the bread grab while Salma is baking")


func talk_caption(app: Node3D, name_value: String) -> String:
	return str(app.talking.data.talk_button).format({"name": name_value})


func expect_button(app: Node3D, caption: String, visible: bool, context: String) -> void:
	var button: Button = helper.find_button(app.ui, caption)
	helper.check((button != null) == visible, "%s: %s button %s" % [context, caption, "shown" if visible else "hidden"])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "%s: %s button fits in the viewport" % [context, caption])


func expect_label(app: Node3D, value: String, visible: bool, context: String) -> void:
	var label := find_label(app.ui, value)
	helper.check((label != null) == visible, "%s: %s %s" % [context, value, "shown" if visible else "hidden"])
	if label != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "%s: %s fits in the viewport" % [context, value])


func find_label(node: Node, value: String) -> Control:
	if node is Control and not node.is_visible_in_tree():
		return null
	if node is Label and value in node.text:
		return node
	if node is RichTextLabel and value in node.get_parsed_text():
		return node
	for child in node.get_children():
		var label := find_label(child, value)
		if label != null:
			return label
	return null


func capture_state(app: Node3D, stem: String) -> void:
	var filename := stem + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.friday = app.clock.is_friday()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE14_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("MARKET DAY NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
