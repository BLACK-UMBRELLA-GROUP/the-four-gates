extends "res://tests/capture_identity.gd"
## DOC-TFG-0050: native viewport evidence for LOCK 13 V1.

const OUTPUT := "res://../GAME/APPROVED/JABIRS_GOATS/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/JABIRS_GOATS/RECORD/jabirs_goats_data_V1.json"
const MASTER_STEMS := [
	"j01_gate__morning_no_drover",
	"j02_gate__drover_with_goats",
	"j03_goats__jabirs_offer",
	"j04_goats__thirty_coins",
	"j05_gate__no_drover_same_day",
	"j06_goats__not_enough_coins",
	"j07_goats__told_saeed",
	"j08_people_say__brought_back",
	"j09_gate__jabir_gone_for_good",
	"j10_people_say__talk_2_deals",
	"j11_people_say__seen_4_deals",
	"j12_people_say__fence_10_deals",
]
const SATURDAY := 3
const MORNING := 600
const AFTERNOON := 960
const STARTING_TRUST := 45
const STARTING_COINS := 198
const LOW_COINS := 6

var goats: Dictionary
var buy_caption: String


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--jabirs-goats-output="):
			return argument.trim_prefix("--jabirs-goats-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Jabir's goats capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Jabir's goats evidence directory")
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
	helper.report.method = "Real native Godot viewport. Viewport-local clicks exercise fair arrival, the route to the Gate of Trust, the offer choices, the return to the gate map and What people say."
	helper.report.fixture = "Passive clock ticks are paused. Fair arrival supplies 198 coins; the harness seeds starting trust at 45 and skips to a later non-Friday morning (j01), then 16:00 (j02–j05). Later deals occur through the production offer on distinct calendar days (j10–j12). A second fair arrival starts the separate branch with six coins temporarily set for j06. The fair wallet is restored for the report to Saeed and the following afternoon (j07–j09)."
	app.set_process(false)
	goats = app.jabirs_goats.data
	buy_caption = str(goats.offer.buy).format({"n": int(goats.numbers.price)})
	var locked := FileAccess.get_file_as_bytes(LOCKED_DATA)
	helper.check(not locked.is_empty() and locked == FileAccess.get_file_as_bytes("res://data/jabirs_goats.json"), "runtime goats data matches the locked bytes")

	if not await arrive_at_gate(app):
		return
	expect_gate_action(app, false)
	helper.check(app.day == SATURDAY and app.minute_of_day == MORNING, "the gate morning uses Saturday at 10:00")
	await capture_state(app, 0)
	set_time(app, SATURDAY, AFTERNOON)
	expect_gate_action(app, true)
	await capture_state(app, 1)

	await click(app, goats.gate_button)
	expect_panel(app, "jabirs_offer", goats.offer)
	expect_offer_choices(app, true)
	await capture_state(app, 2)
	await click(app, goats.offer.no)
	expect_gate_action(app, true)
	helper.check(app.day == SATURDAY and app.minute_of_day == AFTERNOON and app.jabirs_goats.deals == 0 and not app.jabirs_goats.told, "Walk away changes no time, deal or report")
	helper.check(app.progress.coins == STARTING_COINS and app.progress.trust == STARTING_TRUST and app.ui.reputation_lines().is_empty(), "Walk away changes no coins, trust or talk")

	await click(app, goats.gate_button)
	await click(app, buy_caption)
	expect_panel(app, "jabirs_bought", goats.bought)
	expect_label(app, str(goats.bought.deals).format({"n": 1}).to_upper())
	expect_button(app, goats.bought.to_map, true)
	helper.check(app.day == SATURDAY and app.minute_of_day == AFTERNOON and app.jabirs_goats.deals == 1, "the first purchase marks the calendar day and keeps the clock")
	helper.check(app.progress.coins == STARTING_COINS + 20 and app.progress.trust == STARTING_TRUST and app.ui.reputation_lines().is_empty(), "the first purchase adds twenty coins with no trust or talk effect")
	await capture_state(app, 3)
	await click(app, goats.bought.to_map)
	expect_gate_action(app, false)
	await capture_state(app, 4)
	await capture_deal_thresholds(app)

	app.show_screen("title")
	if not await arrive_at_gate(app):
		return
	helper.check(app.jabirs_goats.deals == 0 and not app.jabirs_goats.told, "the second arrival starts a fresh goat story")
	set_time(app, SATURDAY, AFTERNOON)
	app.progress.coins = LOW_COINS
	app.update_state()
	await click(app, goats.gate_button)
	expect_panel(app, "jabirs_offer", goats.offer)
	expect_offer_choices(app, false)
	helper.check(app.progress.coins == LOW_COINS, "the low-funds capture uses six coins")
	await capture_state(app, 5)
	await click(app, goats.offer.no)
	app.progress.coins = STARTING_COINS
	app.update_state()
	await click(app, goats.gate_button)
	await click(app, goats.offer.tell)
	expect_panel(app, "jabirs_told", goats.told)
	expect_button(app, goats.told.to_rep, true)
	expect_button(app, goats.told.to_map, true)
	helper.check(app.jabirs_goats.told and app.jabirs_goats.deals == 0 and app.progress.coins == STARTING_COINS, "telling Saeed marks the report without buying or paying")
	helper.check(app.progress.trust == STARTING_TRUST + int(goats.numbers.tell_trust), "telling Saeed adds the locked three trust")
	await capture_state(app, 6)
	await click(app, goats.told.to_rep)
	expect_reputation(app, goats.say.told, STARTING_TRUST + int(goats.numbers.tell_trust))
	await capture_state(app, 7)
	await click(app, app.chapter.rep.to_map)
	set_time(app, SATURDAY + 1, AFTERNOON)
	expect_gate_action(app, false)
	helper.check(app.jabirs_goats.told and app.day == SATURDAY + 1 and app.minute_of_day == AFTERNOON, "Jabir stays away the following afternoon")
	await capture_state(app, 8)

	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all twelve master states were captured")
	finish(app)


func arrive_at_gate(app: Node3D) -> bool:
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	helper.check(app.progress.coins == STARTING_COINS, "fair arrival supplies the locked 198-coin fixture")
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	set_time(app, SATURDAY, MORNING)
	return await travel(app, "gate")


func capture_deal_thresholds(app: Node3D) -> void:
	for deal in range(2, 11):
		set_time(app, SATURDAY + deal - 1, AFTERNOON)
		await click(app, goats.gate_button)
		await click(app, buy_caption)
		helper.check(app.ui.screen == "jabirs_bought" and app.jabirs_goats.deals == deal, "the later calendar day counts one purchase: %d" % deal)
		helper.check(app.progress.coins == STARTING_COINS + 20 * deal, "the wallet gains exactly one profit for deal %d" % deal)
		helper.check(app.dice_house.nights == 0 and app.qasims_jars.runs == 0, "deal %d leaves both night activities unchanged" % deal)
		await click(app, goats.bought.to_map)
		match deal:
			2:
				await capture_talk(app, 9, goats.say.talk, STARTING_TRUST)
			4:
				await capture_talk(app, 10, goats.say.seen, STARTING_TRUST + int(goats.numbers.seen_trust))
			10:
				await capture_talk(app, 11, goats.say.fence, STARTING_TRUST + int(goats.numbers.seen_trust) + int(goats.numbers.fence_trust))


func set_time(app: Node3D, day: int, minute: int) -> void:
	app.clock.skip_to(day, minute)
	app.update_state()


func expect_gate_action(app: Node3D, available: bool) -> void:
	helper.check(app.ui.screen == "market_map" and app.current_place == "gate", "the Gate of Trust is active on the market map")
	expect_button(app, goats.gate_button, available)


func expect_panel(app: Node3D, screen: String, copy: Dictionary) -> void:
	helper.check(app.ui.screen == screen, "the production panel is open: " + screen)
	expect_label(app, str(copy.kicker).to_upper())
	expect_label(app, copy.title)
	expect_label(app, copy.text)


func expect_offer_choices(app: Node3D, affordable: bool) -> void:
	var first: Control = expect_button(app, buy_caption, affordable)
	if not affordable:
		first = expect_label(app, goats.offer.not_enough)
	var tell := expect_button(app, goats.offer.tell, true)
	var walk := expect_button(app, goats.offer.no, true)
	helper.check(first != null and tell != null and walk != null and first.get_global_rect().end.x <= tell.get_global_rect().position.x and tell.get_global_rect().end.x <= walk.get_global_rect().position.x, "the three offer choices fit in the locked left-to-right order")


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


func capture_talk(app: Node3D, index: int, line: Array, trust: int) -> void:
	await click(app, app.chapter.purse.morning.to_rep)
	expect_reputation(app, line, trust)
	await capture_state(app, index)
	await click(app, app.chapter.rep.to_map)


func expect_reputation(app: Node3D, line: Array, trust: int) -> void:
	var lines := [line]
	if app.jabirs_goats.deals >= int(app.jabirs_goats.data.numbers.seen_from_deals):
		lines.append(app.idris_recovery.data.say.cool)
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == lines, "What people say preserves the expected goats line and adds Idris after a trust hit")
	helper.check(app.progress.trust == trust, "the reputation view has the exact locked trust result")
	expect_label(app, "“%s”" % line[0])
	expect_label(app, str(line[1]).to_upper())
	expect_label(app, app.chapter.rep.tone[str(int(line[2]))])


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.deals = app.jabirs_goats.deals
	state.told = app.jabirs_goats.told
	state.dice_nights = app.dice_house.nights
	state.jar_runs = app.qasims_jars.runs


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE20_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("JABIR'S GOATS NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
