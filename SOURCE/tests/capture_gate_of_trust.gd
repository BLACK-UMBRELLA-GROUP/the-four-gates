extends "res://tests/capture_identity.gd"
## DOC-TFG-0107: LOCK 32 states from the native Godot viewport.

const OUTPUT := "res://../GAME/APPROVED/GATE_OF_TRUST/BUILT/V1/"
const MASTER_STEMS := [
	"gj01_gate__gatekeepers_will_open",
	"gj02_gate__the_gate_opens",
	"gj03_jisra__bridge_of_boats",
	"gj04_toll__one_coin_and_three",
	"gj05_toll__said_something",
	"gj06_jisra__after_the_toll",
	"gj07_toll__paid_their_toll",
	"gj08_toll__said_nothing",
	"gj09_jisra__pray_dhuhr_here",
	"gj10_gate__back_road_east",
	"gj11_gate__trust_99_closed",
	"gj12_toll__not_enough_coins",
]
const THURSDAY := 8
const NINE_AM := 540
const DHUHR_FIXTURE := 740

var copy: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--gate-of-trust-output="):
			return argument.trim_prefix("--gate-of-trust-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Gate of Trust capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Gate of Trust evidence directory")
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
	helper.report.method = "Native 1920x1080 Godot viewport. Production buttons and clicks run the gate, road, toll, prayer and save flows."
	helper.report.fixture = "Fair arrival gives 198 coins. The passive clock is paused. Stage Thursday day 8 at 09:00, River Market trust at 99 or 100 and the scales lesson learned, except for the missing-lesson test. Independent fresh arrivals stage each toll branch. The low-wallet fixture holds two coins. The Jisra prayer fixture is 12:20."
	app.set_process(false)
	copy = app.gate_of_trust.data

	await start_at_gate(app)
	app.progress.lesson_done = false
	app.update_state()
	expect_button(app, copy.gate_open_button, false)
	app.progress.lesson_done = true
	app.progress.trust -= 1
	app.update_state()
	expect_button(app, copy.gate_open_button, false)
	expect_button(app, app.data.ui.place_actions.gate, true)
	await capture_state(app, 10)
	app.progress.trust += 1
	app.update_state()
	expect_button(app, copy.gate_open_button, true)
	expect_button(app, copy.road_button, false)
	await capture_state(app, 0)
	await click(app, copy.gate_open_button)
	expect_screen(app, "gate_opening")
	expect_copy(app, copy.opening)
	helper.check(app.progress.gate_open and app.world.gate_body.collision_layer == 0, "the gate opens and clears its collision")
	if app.world.gate_tween != null and app.world.gate_tween.is_running():
		await app.world.gate_tween.finished
	helper.check(is_equal_approx(app.world.gate_hinge.rotation.y, -PI / 2.0), "the gate finishes swinging before capture")
	await capture_state(app, 1)
	await click(app, copy.opening.no)
	expect_screen(app, "market_map")
	helper.check(app.current_place == "gate" and app.minute_of_day == NINE_AM, "Not yet stays at the gate and does not advance time")
	await click(app, copy.road_button)
	expect_jisra(app)
	await capture_state(app, 2)
	await click(app, copy.jisra.watch)
	expect_screen(app, "jisra_toll")
	expect_copy(app, copy.toll)
	expect_button(app, copy.toll.pay, true)
	await capture_state(app, 3)
	await choose_toll(app, "speak", 4, 198, 15)
	await capture_state(app, 5)
	await helper.action(app, "close")
	expect_screen(app, "pause")
	await click(app, app.menus.pause.quit)
	expect_screen(app, "title")
	await click(app, str(app.menus.title_continue).format({"d": app.ui.continue_date}))
	expect_screen(app, "jisra")
	expect_button(app, copy.jisra.watch, false)
	expect_meter(app, true, 15)

	await start_at_gate(app)
	await open_and_watch(app)
	await choose_toll(app, "pay", 6, 195, 13)

	await start_at_gate(app)
	await open_and_watch(app)
	await choose_toll(app, "quiet", 7, 198, 10)
	app.clock.advance_to(THURSDAY, DHUHR_FIXTURE, false)
	app.update_state()
	var prayer: String = app.clock.prayer_label(false)
	expect_button(app, prayer, true)
	await capture_state(app, 8)
	await click(app, copy.jisra.back)
	expect_screen(app, "market_map")
	helper.check(app.current_place == "gate" and app.minute_of_day == DHUHR_FIXTURE + int(copy.numbers.travel_minutes), "the westward walk advances 90 minutes and returns to the gate")
	expect_meter(app, false, 100)
	expect_button(app, copy.road_button, true)
	await capture_state(app, 9)
	await click(app, copy.road_button)
	expect_button(app, prayer, true)
	await click(app, prayer)
	expect_button(app, prayer, false)
	helper.check(not app.clock.has_prayed_in_congregation() and app.clock._completed.values().has("alone"), "Dhuhr in Jisra is recorded alone")

	await start_at_gate(app)
	app.progress.coins = 2
	await open_and_watch(app)
	expect_button(app, copy.toll.pay, false)
	expect_button(app, copy.toll.speak, true)
	expect_button(app, copy.toll.quiet, true)
	await capture_state(app, 11)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all 12 locked states captured")
	finish(app)


func start_at_gate(app: Node3D) -> void:
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn" and app.progress.coins == 198, "fair arrival reaches the Inn with 198 coins")
	app.clock.skip_to(THURSDAY, NINE_AM)
	app.player.position = app.world.point("gate")
	app.progress.trust = int(app.data.numbers.gate_trust)
	app.progress.lesson_done = true
	app.update_state()


func open_and_watch(app: Node3D) -> void:
	await click(app, copy.gate_open_button)
	await click(app, copy.opening.go)
	expect_jisra(app)
	await click(app, copy.jisra.watch)
	expect_screen(app, "jisra_toll")


func choose_toll(app: Node3D, choice: String, index: int, coins: int, trust: int) -> void:
	await click(app, copy.toll[choice])
	expect_screen(app, "jisra_toll")
	expect_copy(app, copy.toll)
	expect_label(app, copy.toll["out_" + choice])
	for option: String in ["speak", "pay", "quiet"]:
		expect_button(app, copy.toll[option], false)
	helper.check(app.progress.coins == coins and app.progress.trust == 100, "toll wallet and separate River Market trust: " + choice)
	expect_meter(app, true, trust)
	await capture_state(app, index)
	await click(app, copy.toll.to_town)
	expect_screen(app, "jisra")
	expect_button(app, copy.jisra.watch, false)


func expect_jisra(app: Node3D) -> void:
	expect_screen(app, "jisra")
	expect_copy(app, copy.jisra)
	expect_meter(app, true, int(copy.numbers.jisra_start))
	expect_button(app, copy.jisra.watch, true)
	helper.check(app.current_place == "jisra" and app.minute_of_day == NINE_AM + int(copy.numbers.travel_minutes), "the eastward walk advances 90 minutes to Jisra")


func expect_meter(app: Node3D, jisra: bool, trust: int) -> void:
	expect_label(app, copy.jisra.meter if jisra else app.data.ui.hud.trust_label)
	expect_label(app, str(app.data.ui.hud.trust_value).format({"n": trust}))


func expect_screen(app: Node3D, screen: String) -> void:
	helper.check(app.ui.screen == screen, "production screen: " + screen)


func expect_copy(app: Node3D, panel: Dictionary) -> void:
	expect_label(app, str(panel.kicker).to_upper())
	expect_label(app, panel.title)
	expect_label(app, panel.text)


func expect_button(app: Node3D, caption: String, visible: bool) -> void:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == visible, ("shown: " if visible else "hidden: ") + caption)
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits the viewport: " + caption)


func expect_label(app: Node3D, caption: String) -> void:
	helper.check(has_label(app.ui, caption), "visible locked label: " + caption)


func has_label(node: Node, caption: String) -> bool:
	if node is Control and not node.is_visible_in_tree():
		return false
	if (node is Label and node.text == caption) or (node is RichTextLabel and node.get_parsed_text() == caption):
		return true
	for child in node.get_children():
		if has_label(child, caption):
			return true
	return false


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.jisra_trust = app.gate_of_trust.jisra_trust
	state.toll_choice = app.gate_of_trust.toll_choice


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE39_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("GATE OF TRUST NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
