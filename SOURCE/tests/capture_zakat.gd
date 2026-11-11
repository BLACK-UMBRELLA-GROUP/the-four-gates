extends "res://tests/capture_identity.gd"
## DOC-TFG-0077: native viewport evidence for LOCK 22.

const OUTPUT := "res://../GAME/APPROVED/ZAKAT/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/ZAKAT/RECORD/zakat_data_V1.json"
const MASTER_STEMS := [
	"z01_masjid__30_rajab_nothing",
	"z02_masjid__zakat_year_ended",
	"z03_zakat__6_coins_due",
	"z04_zakat__paid_idris",
	"z05_zakat__paid_widow",
	"z06_zakat__paid_boy",
	"z07_zakat__paid_father",
	"z08_masjid__button_gone_after_paying",
	"z09_prayers__zakat_paid",
	"z10_zakat__not_due_60_coins",
	"z11_masjid__not_due_gone_next_day",
	"z12_zakat__due_8_have_3",
	"z13_masjid__still_due_6_days_later",
]
const MORNING := 600
const TRUST := 45

var copy: Dictionary
var year_days: int


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--zakat-output="):
			return argument.trim_prefix("--zakat-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Zakat capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Zakat evidence directory")
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
	helper.report.method = "Native Godot viewport with production arrival, Masjid, payment, back and private record controls."
	helper.report.fixture = "Passive clock ticks are paused. After fair arrival the prayer clock is reset to exclude arrival prayer history. The actual calendar advances to day indexes 353, 354, 355, 360 and 708 at 10:00; skipped prayer windows are unplayed. The wallet and trust are set for each master and the player is placed at the Masjid marker. The assessment, payment, receipt and private record are produced by the game."
	app.set_process(false)
	var runtime := FileAccess.get_file_as_bytes("res://data/zakat.json")
	if not helper.check(not runtime.is_empty() and FileAccess.get_file_as_bytes(LOCKED_DATA) == runtime, "runtime Zakat data matches the locked bytes"):
		finish(app)
		return
	copy = app.zakat.data
	year_days = app.clock.calendar.year_days
	await capture_recipients(app)
	await capture_zero_and_shortage(app)
	await check_overlapping_years(app)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all thirteen master states have native captures")
	finish(app)


func capture_recipients(app: Node3D) -> void:
	await arrive(app, 238)
	stage(app, year_days - 1)
	check_button(app, copy.masjid_button, false)
	await capture_state(app, MASTER_STEMS[0])
	for index in copy.options.size():
		if index > 0:
			await arrive(app, 238)
		stage(app, year_days)
		check_button(app, copy.masjid_button)
		if index == 0:
			await capture_state(app, MASTER_STEMS[1])
		await click(app, copy.masjid_button)
		check_panel(app, 238, 6)
		var previous_y := 0.0
		for option: Dictionary in copy.options:
			var button := check_button(app, option.label)
			if button != null:
				helper.check(button.position.y > previous_y, "recipient follows the approved order: " + str(option.id))
				previous_y = button.position.y
		if index == 0:
			await capture_state(app, MASTER_STEMS[2])
		await pay(app, copy.options[index], 238, 6)
		if index == 0:
			await hit(app, app.ui.clock_panel.get_global_rect().get_center())
			helper.check(app.ui.screen == "zakat", "the displayed clock does not leave the Zakat receipt")
			expect_label(app, copy.options[index].out)
		await capture_state(app, MASTER_STEMS[index + 3])
	await leave_panel(app)
	check_button(app, copy.masjid_button, false)
	await capture_state(app, MASTER_STEMS[7])
	await open_record(app, str(copy.record.paid).format({"n": 6}))
	await capture_state(app, MASTER_STEMS[8])


func capture_zero_and_shortage(app: Node3D) -> void:
	await arrive(app, 60)
	stage(app, year_days)
	await click(app, copy.masjid_button)
	check_panel(app, 60, 0)
	check_options_hidden(app)
	await capture_state(app, MASTER_STEMS[9])
	await leave_panel(app)
	stage(app, year_days + 1)
	check_button(app, copy.masjid_button, false)
	await capture_state(app, MASTER_STEMS[10])

	await arrive(app, 300)
	stage(app, year_days)
	app.progress.coins = 3
	app.update_state()
	await click(app, copy.masjid_button)
	check_panel(app, 300, 8)
	expect_label(app, str(copy.panel.not_enough).format({"n": 8}))
	check_options_hidden(app)
	await capture_state(app, MASTER_STEMS[11])
	await leave_panel(app)
	stage(app, year_days + 6)
	check_button(app, copy.masjid_button)
	await capture_state(app, MASTER_STEMS[12])


func check_overlapping_years(app: Node3D) -> void:
	for second_year_coins: int in [100, 60]:
		await arrive(app, 300)
		stage(app, year_days)
		app.progress.coins = second_year_coins
		stage(app, year_days * 2)
		var second_due := 3 if second_year_coins == 100 else 0
		await open_record(app, str(copy.record.due).format({"n": 8 + second_due}))
		await click(app, app.ui.prayer_record.panel.back_market)
		await click(app, copy.masjid_button)
		check_panel(app, 300, 8)
		await pay(app, copy.options[0], 300, 8)
		await leave_panel(app)
		check_button(app, copy.masjid_button)
		var first_status: String = str(copy.record.due).format({"n": second_due}) if second_due > 0 else copy.record.none
		await open_record(app, first_status)
		await click(app, app.ui.prayer_record.panel.back_market)
		await click(app, copy.masjid_button)
		check_panel(app, second_year_coins, second_due)
		if second_due > 0:
			await pay(app, copy.options[0], second_year_coins, second_due)
			await leave_panel(app)
			check_button(app, copy.masjid_button, false)
			await open_record(app, str(copy.record.paid).format({"n": second_due}))
			await click(app, app.ui.prayer_record.panel.back_market)
		else:
			check_options_hidden(app)
			await leave_panel(app)
			stage(app, year_days * 2 + 1)
			check_button(app, copy.masjid_button, false)


func arrive(app: Node3D, coins: int) -> void:
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival opens the live Inn map")
	app.clock.reset()
	app.progress.coins = coins
	app.progress.apply_trust(TRUST - app.progress.trust)
	app.update_state()


func stage(app: Node3D, day_index: int) -> void:
	app.clock.skip_to(day_index + 1, MORNING)
	app.player.position = app.world.point("masjid")
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == "masjid", "live market map at the Masjid")
	helper.check(app.day - 1 == day_index and app.minute_of_day == MORNING, "live clock at day index %d, 10:00" % day_index)


func check_panel(app: Node3D, assessed: int, due: int) -> void:
	helper.check(app.ui.screen == "zakat", "the native Zakat panel is open")
	expect_label(app, str(copy.panel.kicker).to_upper())
	expect_label(app, copy.panel.title)
	var paragraph: String = copy.panel.due if due > 0 else copy.panel.none
	expect_label(app, paragraph.format({"c": assessed, "t": int(copy.numbers.threshold), "n": due}))
	check_button(app, copy.panel.to_map)


func pay(app: Node3D, option: Dictionary, assessed: int, due: int) -> void:
	var before := [app.progress.coins, app.progress.trust, app.ui.reputation_lines().duplicate(true)]
	await click(app, option.label)
	check_panel(app, assessed, due)
	expect_label(app, option.out)
	check_options_hidden(app)
	helper.check(app.progress.coins == before[0] - due and app.progress.trust == before[1] and app.ui.reputation_lines() == before[2], "payment only removes that year's due of %d coins" % due)


func leave_panel(app: Node3D) -> void:
	await click(app, copy.panel.to_map)
	helper.check(app.ui.screen == "market_map" and app.current_place == "masjid", "the panel returns to the Masjid on the market map")


func open_record(app: Node3D, expected: String) -> void:
	await hit(app, app.ui.clock_panel.get_global_rect().get_center())
	helper.check(app.ui.screen == "prayer_record", "the native clock opens Today's prayers")
	await click(app, app.ui.prayer_record.record_button)
	helper.check(app.ui.screen == "all_prayers", "Today's prayers opens All your prayers")
	var title := expect_label(app, copy.record.title)
	var status := expect_label(app, expected)
	var previous := expect_label(app, app.eid_al_fitr.data.record.eid)
	var note := expect_label(app, str(app.ui.prayer_record.panel.note).to_upper())
	if title != null and status != null and previous != null and note != null:
		helper.check(title.position.y == status.position.y and previous.position.y < title.position.y and title.position.y < note.position.y,
			"the private Zakat value shares its row after Eid and before the privacy note")


func check_options_hidden(app: Node3D) -> void:
	for option: Dictionary in copy.options:
		check_button(app, option.label, false)


func check_button(app: Node3D, caption: String, expected: bool = true) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == expected, "button %s: %s" % ["shown" if expected else "hidden", caption])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits the viewport: " + caption)
	return button


func expect_label(app: Node3D, value: String) -> Control:
	var label := find_label(app.ui.content, value)
	helper.check(label != null, "text shown: " + value)
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
	state.day_index = app.day - 1
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.date = app.clock.date_label(app.day)


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE29_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("ZAKAT NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
