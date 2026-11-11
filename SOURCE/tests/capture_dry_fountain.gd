extends "res://tests/capture_identity.gd"
## DOC-TFG-0056: native viewport evidence for LOCK 15 V1.

const OUTPUT := "res://../GAME/APPROVED/DRY_FOUNTAIN/BUILT/V1/"
const MASTER_STEMS := [
	"o01_square__the_dry_fountain",
	"o02_fountain__name_or_no_name",
	"o03_fountain__paid_20",
	"o04_fountain__not_enough_coins",
	"o05_fountain__water_again_named",
	"o06_people_say__paid_for_the_fountain",
	"o07_square__runs_3_days",
	"o08_fountain__water_again_no_name",
	"o09_people_say__no_name_no_line",
]
const THURSDAY := 8
const MORNING := 600
const STARTING_COINS := 198
const STARTING_TRUST := 45
const LOW_COINS := 15

var fountain: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--dry-fountain-output="):
			return argument.trim_prefix("--dry-fountain-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Dry fountain capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the dry fountain evidence directory")
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
	helper.report.method = "Real native Godot viewport. Viewport clicks drive both arrivals, the walk to the Task board, both payment branches and the return to the map."
	helper.report.fixture = "Passive clock ticks are paused. Fair arrival supplies 198 coins. Trust is seeded to 45 and the clock skips to Thursday day 8 at 10:00. The harness sets 15 coins for o04 and restores the 178-coin balance after Not now. The running fountain is captured Sunday day 11 at 10:00. A fresh arrival supplies the unnamed branch."
	app.set_process(false)
	fountain = app.dry_fountain.data
	var panel: Dictionary = fountain.panel
	var done: Dictionary = fountain.done
	var part := int(fountain.numbers.part)
	var cost := int(fountain.numbers.cost)
	var named := caption(panel.give_named, part)
	var secret := caption(panel.give_secret, part)
	var give := caption(panel.give, part)

	if not await arrive_at_board(app):
		return
	expect_square(app, false, 0)
	await capture_state(app, 0)
	await click(app, fountain.board_button)
	expect_story(app, "dry_fountain", panel)
	expect_label(app, caption(panel.paid, 0).to_upper())
	expect_button(app, named, true)
	expect_button(app, secret, true)
	expect_button(app, give, false)
	expect_button(app, panel.not_now, true)
	await capture_state(app, 1)

	await click(app, named)
	expect_story(app, "dry_fountain", panel)
	expect_label(app, caption(panel.paid, part).to_upper())
	expect_button(app, named, false)
	expect_button(app, secret, false)
	expect_button(app, give, true)
	check_payment(app, part, true, STARTING_TRUST)
	await capture_state(app, 2)

	app.progress.coins = LOW_COINS
	app.update_state()
	expect_button(app, give, false)
	expect_label(app, panel.not_enough)
	expect_button(app, panel.not_now, true)
	helper.check(app.dry_fountain.paid == part and app.progress.coins == LOW_COINS, "the low wallet fixture keeps the first payment")
	await capture_state(app, 3)
	await click(app, panel.not_now)
	expect_square(app, false, 0)
	app.progress.coins = STARTING_COINS - part
	app.update_state()
	await click(app, fountain.board_button)
	await click(app, give)
	check_payment(app, part * 2, true, STARTING_TRUST)
	await click(app, give)
	expect_completion(app, true, cost)
	await capture_state(app, 4)

	await click(app, done.to_rep)
	expect_reputation(app, true)
	await capture_state(app, 5)
	await click(app, app.chapter.rep.to_map)
	expect_square(app, true, 0)
	app.clock.skip_to(THURSDAY + 3, MORNING)
	app.update_state()
	expect_square(app, true, 3)
	await capture_state(app, 6)

	app.show_screen("title")
	if not await arrive_at_board(app):
		return
	expect_square(app, false, 0)
	await click(app, fountain.board_button)
	await click(app, secret)
	check_payment(app, part, false, STARTING_TRUST)
	await click(app, give)
	check_payment(app, part * 2, false, STARTING_TRUST)
	await click(app, give)
	expect_completion(app, false, cost)
	await capture_state(app, 7)
	await click(app, done.to_rep)
	expect_reputation(app, false)
	await capture_state(app, 8)
	await click(app, app.chapter.rep.to_map)
	expect_square(app, true, 0)

	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all nine master states were captured")
	finish(app)


func arrive_at_board(app: Node3D) -> bool:
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	helper.check(app.progress.coins == STARTING_COINS, "fair arrival supplies the 198-coin fixture")
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	app.clock.skip_to(THURSDAY, MORNING)
	app.update_state()
	return await travel(app, "board")


func check_payment(app: Node3D, amount: int, named: bool, trust: int) -> void:
	helper.check(app.dry_fountain.paid == amount and app.progress.coins == STARTING_COINS - amount, "cumulative payment and wallet match: %d" % amount)
	helper.check(app.dry_fountain.named == named and app.progress.trust == trust, "attribution and trust match after paying %d" % amount)


func expect_square(app: Node3D, running: bool, days: int) -> void:
	helper.check(app.ui.screen == "market_map" and app.current_place == "board", "the Task board is active on the market map")
	var status: Control = expect_button(app, fountain.board_button, not running)
	if running:
		status = expect_label(app, caption(fountain.running, days))
	var feed := expect_button(app, app.feeding.data.place_button, true)
	helper.check(status != null and feed != null and status.get_global_rect().end.x <= feed.get_global_rect().position.x, "the fountain fits before feeding in the square bar")


func expect_story(app: Node3D, screen: String, copy: Dictionary) -> void:
	helper.check(app.ui.screen == screen, "the production panel is open: " + screen)
	expect_label(app, str(copy.kicker).to_upper())
	expect_label(app, copy.title)
	expect_label(app, copy.text)


func expect_completion(app: Node3D, named: bool, cost: int) -> void:
	var done: Dictionary = fountain.done
	expect_story(app, "fountain_done", done)
	expect_label(app, done.named if named else done.secret)
	expect_label(app, caption(done.count, 1).to_upper())
	expect_button(app, done.to_rep, true)
	expect_button(app, done.to_map, true)
	var trust := STARTING_TRUST + (int(fountain.numbers.public_trust) if named else 0)
	check_payment(app, cost, named, trust)
	helper.check(app.dry_fountain.is_running() and app.dry_fountain.finished_day == THURSDAY, "the last payment starts the fountain on the completion day")


func expect_reputation(app: Node3D, named: bool) -> void:
	var line: Array = fountain.say.named
	helper.check(app.ui.screen == "reputation", "What people say opened from Water again")
	helper.check(app.ui.reputation_lines() == ([line] if named else []), "What people say matches the locked attribution")
	if named:
		expect_label(app, "“%s”" % line[0])
		expect_label(app, str(line[1]).to_upper())
		expect_label(app, app.chapter.rep.tone[str(int(line[2]))])
	else:
		expect_label(app, app.chapter.rep.empty)


func caption(value: String, number: int) -> String:
	return value.format({"n": number})


func expect_button(app: Node3D, value: String, visible: bool) -> Button:
	var button := helper.find_button(app.ui, value)
	helper.check((button != null) == visible, "button %s: %s" % ["shown" if visible else "hidden", value])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits in viewport: " + value)
	return button


func expect_label(app: Node3D, value: String) -> Control:
	var label := find_label(app.ui, value)
	helper.check(label != null, "visible locked label: " + value)
	if label != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "label fits in viewport: " + value)
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


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.paid = app.dry_fountain.paid
	state.named = app.dry_fountain.named
	state.finished_day = app.dry_fountain.finished_day
	state.days_running = app.dry_fountain.days_running()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE22_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("DRY FOUNTAIN NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
