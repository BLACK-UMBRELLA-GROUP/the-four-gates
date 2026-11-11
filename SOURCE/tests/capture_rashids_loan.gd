extends "res://tests/capture_identity.gd"
## DOC-TFG-0059: native viewport evidence for LOCK 16 V1.

const OUTPUT := "res://../GAME/APPROVED/RASHIDS_LOAN/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/RASHIDS_LOAN/RECORD/rashids_loan_data_V1.json"
const MASTER_STEMS := [
	"l01_spice__rashid_needs_a_loan",
	"l02_loan__the_ask",
	"l03_loan__that_is_riba",
	"l04_people_say__asked_for_interest",
	"l05_loan__lent",
	"l06_spice__rashid_owes_30",
	"l07_spice__rashid_has_your_money",
	"l08_loan__twenty_coins",
	"l09_loan__gave_time",
	"l10_spice__rashid_owes_10",
	"l11_loan__the_last_ten",
	"l12_people_say__gave_time",
	"l13_loan__let_the_ten_go",
	"l14_people_say__let_off_ten",
	"l15_loan__demanded_all",
	"l16_people_say__hounded",
	"l17_spice__trust_too_low",
	"l18_loan__not_enough_coins",
]
const THURSDAY := 8
const MORNING := 600
const STARTING_COINS := 198
const STARTING_TRUST := 45
const LOW_TRUST := 25
const LOW_COINS := 20

var copy: Dictionary
var loan: int
var first_pay: int
var due_day: int
var last_day: int
var lend_button: String
var interest_button: String


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--rashids-loan-output="):
			return argument.trim_prefix("--rashids-loan-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Rashid's loan capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create Rashid's loan evidence directory")
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
	helper.report.method = "Real native Godot viewport. Viewport clicks drive fair arrivals, physical walks to Spice row, the loan choices, and the return to the market map."
	helper.report.fixture = "Passive clock ticks are paused. Fair arrival supplies 198 coins. Trust is seeded to 45 except for the threshold checks (25 for l17). The wallet is set to 20 for l18 and restored after declining. Offer frames use Thursday day 8 at 10:00, due frames Sunday day 11 at 10:00, and final repayment frames Sunday day 18 at 10:00. Friday prayer and night closures are checked between those fixtures. A fresh arrival starts each branch."
	app.set_process(false)
	if not helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/rashids_loan.json"), "runtime loan data matches the locked bytes"):
		finish(app)
		return
	copy = app.rashids_loan.data
	loan = int(copy.numbers.loan)
	first_pay = int(copy.numbers.first_pay)
	due_day = THURSDAY + int(copy.numbers.due_days)
	last_day = due_day + int(copy.numbers.more_days)
	lend_button = str(copy.ask.lend).format({"n": loan})
	interest_button = str(copy.ask.lend_more).format({"n": loan, "m": int(copy.numbers.ask_back)})

	if not await arrive_at_spice(app):
		return
	await capture_offer_and_refusal(app)

	if not await arrive_at_spice(app):
		return
	await capture_wait(app)

	for choice: String in ["forgive", "demand"]:
		if not await arrive_at_spice(app):
			return
		await capture_settlement(app, choice)

	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all 18 locked master states were captured")
	finish(app)


func arrive_at_spice(app: Node3D) -> bool:
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
	helper.check(app.progress.coins == STARTING_COINS, "fair arrival supplies the 198-coin fixture")
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	stage_time(app, THURSDAY, MORNING)
	expect_button(app, copy.ask_button, false)
	return await travel(app, "spice")


func capture_offer_and_refusal(app: Node3D) -> void:
	app.progress.apply_trust(LOW_TRUST - app.progress.trust)
	app.update_state()
	expect_bar(app, "")
	await capture_state(app, 16)

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
	expect_story(app, "loan_ask", copy.ask, copy.ask.text)
	expect_button(app, lend_button, false)
	expect_button(app, interest_button, false)
	expect_label(app, copy.ask.not_enough)
	expect_button(app, copy.ask.no, true)
	await capture_state(app, 17)
	await click(app, copy.ask.no)
	expect_bar(app, copy.ask_button)
	expect_totals(app, LOW_COINS, STARTING_TRUST, "declining the unaffordable offer")

	app.progress.coins = STARTING_COINS
	app.update_state()
	await click(app, copy.ask_button)
	expect_story(app, "loan_ask", copy.ask, copy.ask.text)
	expect_button(app, lend_button, true)
	expect_button(app, interest_button, true)
	expect_button(app, copy.ask.no, true)
	await capture_state(app, 1)

	await click(app, interest_button)
	expect_story(app, "loan_riba", copy.riba, copy.riba.text)
	expect_button(app, copy.riba.to_rep, true)
	expect_button(app, copy.riba.to_map, true)
	expect_totals(app, STARTING_COINS, STARTING_TRUST + int(copy.numbers.riba_trust), "refused interest")
	await capture_state(app, 2)
	await click(app, copy.riba.to_rep)
	expect_reputation(app, "riba")
	await capture_state(app, 3)
	await click(app, app.chapter.rep.to_map)
	expect_bar(app, "")
	stage_time(app, due_day, MORNING)
	expect_bar(app, "")


func capture_wait(app: Node3D) -> void:
	await lend_coins(app)
	expect_story(app, "loan_lent", copy.lent, copy.lent.text)
	expect_button(app, copy.lent.to_map, true)
	await capture_state(app, 4)
	await click(app, copy.lent.to_map)
	expect_bar(app, "", loan)
	await capture_state(app, 5)

	stage_time(app, THURSDAY, 1200)
	expect_bar(app, "", 0, false)
	expect_label(app, app.market_day.data.text.stall_closed_night)
	stage_time(app, THURSDAY + 1, 735)
	expect_bar(app, "", 0, false)
	expect_label(app, app.market_day.data.text.shop_closed_friday)
	stage_time(app, THURSDAY + 1, 765)
	expect_bar(app, "", loan)
	stage_time(app, due_day - 1, MORNING)
	expect_bar(app, "", loan)
	stage_time(app, due_day, MORNING)
	expect_bar(app, copy.pay_button)
	await capture_state(app, 6)
	await click(app, copy.pay_button)
	expect_due(app)
	await capture_state(app, 7)

	await choose_due(app, "wait", first_pay, int(copy.numbers.wait_trust))
	await capture_state(app, 8)
	await click(app, copy.after.to_map)
	expect_bar(app, "", loan - first_pay)
	await capture_state(app, 9)
	stage_time(app, last_day - 1, MORNING)
	expect_bar(app, "", loan - first_pay)
	stage_time(app, last_day, MORNING)
	expect_bar(app, copy.pay_button)
	await click(app, copy.pay_button)
	expect_story(app, "loan_last", copy.last, copy.last.text)
	expect_button(app, copy.last.to_rep, true)
	expect_button(app, copy.last.to_map, true)
	expect_totals(app, STARTING_COINS, STARTING_TRUST + int(copy.numbers.wait_trust), "final ten collected without an extra trust change")
	await capture_state(app, 10)
	await click(app, copy.last.to_rep)
	expect_reputation(app, "wait")
	await capture_state(app, 11)
	await click(app, app.chapter.rep.to_map)
	expect_bar(app, "")


func capture_settlement(app: Node3D, choice: String) -> void:
	await lend_coins(app)
	await click(app, copy.lent.to_map)
	stage_time(app, due_day, MORNING)
	await click(app, copy.pay_button)
	expect_due(app)
	var forgive := choice == "forgive"
	var payment := first_pay if forgive else loan
	await choose_due(app, choice, payment, int(copy.numbers[choice + "_trust"]))
	await capture_state(app, 12 if forgive else 14)
	await click(app, copy.after.to_rep)
	expect_reputation(app, choice)
	await capture_state(app, 13 if forgive else 15)
	await click(app, app.chapter.rep.to_map)
	expect_bar(app, "")
	stage_time(app, last_day, MORNING)
	expect_bar(app, "")


func lend_coins(app: Node3D) -> void:
	await click(app, copy.ask_button)
	await click(app, lend_button)
	expect_totals(app, STARTING_COINS - loan, STARTING_TRUST, "the 30-coin loan")


func expect_due(app: Node3D) -> void:
	expect_story(app, "loan_due", copy.due, copy.due.text)
	var previous: Button
	for choice: String in ["wait", "forgive", "demand"]:
		var button := expect_button(app, copy.due[choice], true)
		if button != null:
			var panel := button.get_parent() as Panel
			helper.check(panel != null and panel.get_global_rect().encloses(button.get_global_rect()), "repayment choice fits inside the panel: " + choice)
			helper.check(previous == null or previous.get_global_rect().end.x <= button.global_position.x, "repayment choice is in order: " + choice)
		previous = button


func choose_due(app: Node3D, choice: String, payment: int, trust_change: int) -> void:
	await click(app, copy.due[choice])
	expect_story(app, "loan_after", copy.due, copy.after[choice])
	expect_button(app, copy.after.to_rep, true)
	expect_button(app, copy.after.to_map, true)
	expect_totals(app, STARTING_COINS - loan + payment, STARTING_TRUST + trust_change, choice)


func stage_time(app: Node3D, day: int, minute: int) -> void:
	app.clock.skip_to(day, minute)
	app.update_state()


func expect_bar(app: Node3D, action: String, owed: int = 0, stall_open: bool = true) -> void:
	helper.check(app.ui.screen == "market_map" and app.current_place == "spice", "market map is at Spice row")
	var stall := expect_button(app, app.market_stall.data.place.spice_button, stall_open)
	var ask := expect_button(app, copy.ask_button, action == copy.ask_button)
	var pay := expect_button(app, copy.pay_button, action == copy.pay_button)
	var loan_control: Control = ask if action == copy.ask_button else pay
	for amount: int in [loan, loan - first_pay]:
		var caption := str(copy.owed).format({"n": amount})
		if amount == owed:
			loan_control = expect_label(app, caption)
		else:
			helper.check(find_label(app.ui, caption) == null, "hidden locked label: " + caption)
	if loan_control != null:
		var talk_caption := str(app.talking.data.talk_button).format({"name": app.market_day.data.hours.rashid.name})
		var talk: Button = helper.find_button(app.ui, talk_caption)
		helper.check(stall != null and talk != null and stall.get_global_rect().end.x <= loan_control.get_global_rect().position.x and loan_control.get_global_rect().end.x <= talk.get_global_rect().position.x, "the loan control fits between the stall and talk buttons")


func expect_story(app: Node3D, screen: String, panel: Dictionary, body: String) -> void:
	helper.check(app.ui.screen == screen, "the production panel is open: " + screen)
	expect_label(app, str(panel.kicker).to_upper())
	expect_label(app, panel.title)
	expect_label(app, body)


func expect_reputation(app: Node3D, choice: String) -> void:
	var line: Array = copy.say[choice]
	helper.check(app.ui.screen == "reputation", "What people say opened from the loan panel")
	helper.check(app.ui.reputation_lines() == [line], "the loan choice adds exactly one locked reputation line: " + choice)
	expect_label(app, "“%s”" % line[0])
	expect_label(app, str(line[1]).to_upper())
	expect_label(app, app.chapter.rep.tone[str(int(line[2]))])


func expect_totals(app: Node3D, coins: int, trust: int, context: String) -> void:
	helper.check(app.progress.coins == coins and app.progress.trust == trust, "%s: wallet %d and trust %d" % [context, coins, trust])


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


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE23_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("RASHID'S LOAN NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
