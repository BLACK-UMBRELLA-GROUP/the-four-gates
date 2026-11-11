extends "res://tests/capture_identity.gd"
## DOC-TFG-0104: LOCK 31 states captured from the native Godot viewport.

const OUTPUT := "res://../GAME/APPROVED/PARTNERSHIP/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/PARTNERSHIP/RECORD/partnership_data_V1.json"
const MASTER_STEMS := [
	"ps01_weaver__second_loom",
	"ps02_partner__the_offer",
	"ps03_partner__whatever_happens_refused",
	"ps04_people_say__wanted_a_sure_profit",
	"ps05_partner__partners",
	"ps06_weaver__next_share_in_7_days",
	"ps07_weaver__layla_has_your_share",
	"ps08_share__week_1_five_coins",
	"ps09_share__week_3_bad_week",
	"ps10_people_say__fair_share",
	"ps11_weaver__trust_too_low",
	"ps12_partner__not_enough_coins",
]
const THURSDAY := 8
const MORNING := 600
const STARTING_COINS := 198
const STARTING_TRUST := 45
const LOW_TRUST := 35
const LOW_COINS := 20

var copy: Dictionary
var partner_choice: String
var fixed_choice: String


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--partnership-output="):
			return argument.trim_prefix("--partnership-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Partnership capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the partnership evidence directory")
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
	helper.report.method = "Native Godot viewport. Clicks drive fair arrivals, the physical walk to Weaver's lane, the offer, the weekly collections and What people say."
	helper.report.fixture = "The passive clock is paused. Fair arrival supplies 198 coins. Trust is set to 45, except for the trust checks including ps11 at 35. The wallet is temporarily set to 20 for ps12. The game starts at the Inn and walks to Layla. The offer opens on Thursday day 8 at 10:00. The clock advances without passive ticks to test Layla's hours and each due date. The fixed-return and partnership branches each start from a fresh arrival."
	app.set_process(false)
	if not helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/partnership.json"), "runtime partnership data matches the locked bytes"):
		finish(app)
		return
	copy = app.partnership.data
	partner_choice = str(copy.ask.partner).format({"n": int(copy.numbers.capital)})
	fixed_choice = str(copy.ask.fixed).format({"n": int(copy.numbers.capital), "m": int(copy.numbers.fixed_ask)})
	if not await arrive_at_weaver(app):
		return
	await capture_offer_and_refusal(app)
	if not await arrive_at_weaver(app):
		return
	await capture_partnership(app)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all 12 locked states were captured")
	finish(app)


func arrive_at_weaver(app: Node3D) -> bool:
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	if not helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival opens the market map at the Inn"):
		finish(app)
		return false
	helper.check(app.progress.coins == STARTING_COINS, "fair arrival supplies 198 coins")
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	stage_time(app, THURSDAY, MORNING)
	expect_button(app, copy.ask_button, false)
	return await travel(app, "weaver")


func capture_offer_and_refusal(app: Node3D) -> void:
	app.progress.apply_trust(LOW_TRUST - app.progress.trust)
	app.update_state()
	expect_bar(app, "")
	await capture_state(app, 10)
	var threshold := int(copy.numbers.min_trust)
	app.progress.apply_trust(threshold - 1 - app.progress.trust)
	app.update_state()
	expect_bar(app, "")
	app.progress.apply_trust(1)
	app.update_state()
	expect_bar(app, copy.ask_button)
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	app.update_state()
	await capture_state(app, 0)

	app.progress.coins = LOW_COINS
	app.update_state()
	await click(app, copy.ask_button)
	expect_story(app, "partnership_ask", copy.ask, copy.ask.text)
	expect_button(app, partner_choice, false)
	expect_button(app, fixed_choice, false)
	expect_label(app, copy.ask.not_enough)
	await capture_state(app, 11)
	await click(app, copy.ask.no)
	expect_bar(app, copy.ask_button)
	expect_totals(app, LOW_COINS, STARTING_TRUST, "Not now leaves the offer available")

	app.progress.coins = STARTING_COINS
	app.update_state()
	await click(app, copy.ask_button)
	expect_story(app, "partnership_ask", copy.ask, copy.ask.text)
	expect_stacked_choices(app)
	await capture_state(app, 1)
	await click(app, fixed_choice)
	expect_story(app, "partnership_riba", copy.riba, copy.riba.text)
	expect_totals(app, STARTING_COINS, STARTING_TRUST + int(copy.numbers.riba_trust), "fixed return refused")
	await capture_state(app, 2)
	await click(app, copy.riba.to_map)
	expect_bar(app, "")
	await capture_reputation(app, "riba", 3)
	stage_time(app, THURSDAY + int(copy.numbers.week_days), MORNING)
	expect_bar(app, "")


func capture_partnership(app: Node3D) -> void:
	await click(app, copy.ask_button)
	await click(app, partner_choice)
	var coins := STARTING_COINS - int(copy.numbers.capital)
	expect_story(app, "partnership_agreed", copy.agreed, copy.agreed.text)
	expect_totals(app, coins, STARTING_TRUST, "partnership starts with the capital paid")
	await capture_state(app, 4)
	await click(app, copy.agreed.to_map)
	var week_days := int(copy.numbers.week_days)
	expect_bar(app, str(copy.running).format({"n": week_days}))
	await capture_state(app, 5)
	stage_time(app, THURSDAY, 1200)
	expect_bar(app, "", false)
	stage_time(app, THURSDAY + 1, 735)
	expect_bar(app, "", false)

	var profits: Array = copy.numbers.profits
	for week: int in range(1, profits.size() + 2):
		var due_day := THURSDAY + week * week_days
		stage_time(app, due_day - 1, MORNING)
		expect_bar(app, str(copy.running).format({"n": 1}))
		stage_time(app, due_day, MORNING)
		expect_bar(app, copy.share_button)
		if week == 1:
			await capture_state(app, 6)
		await click(app, copy.share_button)
		var profit := int(profits[(week - 1) % profits.size()])
		var share := floori(profit * float(copy.numbers.share_percent) / 100.0)
		var panel := {"kicker": str(copy.week.kicker).format({"n": week}), "title": copy.week.title}
		var story: String = copy.week.none if profit == 0 else str(copy.week.good).format({"n": share, "m": profit})
		expect_story(app, "partnership_week", panel, story)
		coins += share
		expect_totals(app, coins, STARTING_TRUST, "week %d pays %d" % [week, share])
		if week == 1 or week == 3:
			await capture_state(app, 7 if week == 1 else 8)
		await click(app, copy.week.to_map)
		expect_bar(app, str(copy.running).format({"n": week_days}))
		if week == 3:
			await capture_reputation(app, "partner", 9)


func capture_reputation(app: Node3D, choice: String, index: int) -> void:
	await click(app, app.chapter.purse.morning.to_rep)
	var line: Array = copy.say[choice]
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [line], "What people say shows one locked line for " + choice)
	expect_label(app, "“%s”" % line[0])
	expect_label(app, str(line[1]).to_upper())
	expect_label(app, app.chapter.rep.tone[str(int(line[2]))])
	await capture_state(app, index)
	await click(app, app.chapter.rep.to_map)


func stage_time(app: Node3D, day: int, minute: int) -> void:
	app.clock.skip_to(day, minute)
	app.update_state()


func expect_bar(app: Node3D, caption: String, loom_open: bool = true) -> void:
	helper.check(app.ui.screen == "market_map" and app.current_place == "weaver", "market map is at Weaver's lane")
	var loom := expect_button(app, app.market_stall.clothes_data.place.weaver_button, loom_open)
	var ask := expect_button(app, copy.ask_button, caption == copy.ask_button)
	var share := expect_button(app, copy.share_button, caption == copy.share_button)
	var control: Control = ask if ask != null else share
	if caption.begins_with(str(copy.running).get_slice("{n}", 0)):
		control = expect_label(app, caption)
	if control != null and loom != null:
		var offset := control.get_global_rect().position - loom.get_global_rect().position
		helper.check(offset.y > 20.0 or (absf(offset.y) <= 20.0 and offset.x >= loom.size.x), "partnership item follows the loom button")


func expect_stacked_choices(app: Node3D) -> void:
	var previous: Button
	for caption: String in [partner_choice, fixed_choice, copy.ask.no]:
		var button := expect_button(app, caption, true)
		if button != null:
			var panel := button.get_parent() as Panel
			helper.check(panel != null and panel.get_global_rect().encloses(button.get_global_rect()), "offer choice fits in the panel")
			helper.check(previous == null or previous.get_global_rect().end.y <= button.global_position.y, "offer choice is stacked in locked order")
			previous = button


func expect_story(app: Node3D, screen: String, panel: Dictionary, body: String) -> void:
	helper.check(app.ui.screen == screen, "production panel opens: " + screen)
	expect_label(app, str(panel.kicker).to_upper())
	expect_label(app, panel.title)
	expect_label(app, body)


func expect_totals(app: Node3D, coins: int, trust: int, context: String) -> void:
	helper.check(app.progress.coins == coins and app.progress.trust == trust, "%s: wallet %d and trust %d" % [context, coins, trust])


func expect_button(app: Node3D, caption: String, visible: bool) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == visible, "button %s: %s" % ["shown" if visible else "hidden", caption])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits in viewport: " + caption)
	return button


func expect_label(app: Node3D, caption: String) -> Control:
	var label := find_label(app.ui, caption)
	helper.check(label != null, "visible locked label: " + caption)
	if label != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "label fits in viewport: " + caption)
	return label


func find_label(node: Node, caption: String) -> Control:
	if node is Control and not node.is_visible_in_tree():
		return null
	if (node is Label and node.text == caption) or (node is RichTextLabel and node.get_parsed_text() == caption):
		return node
	for child in node.get_children():
		var found := find_label(child, caption)
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


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE38_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("PARTNERSHIP NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
