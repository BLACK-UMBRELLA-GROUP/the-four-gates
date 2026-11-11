extends "res://tests/capture_identity.gd"
## DOC-TFG-0083: native viewport evidence for LOCK 24 V2.

const OUTPUT := "res://../GAME/APPROVED/PILGRIMS/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/PILGRIMS/RECORD/pilgrims_data_V2.json"
const MASTER_STEMS := [
	"b01_gate__abbas_takes_pilgrims",
	"b02_pilgrim__shawwal_all_open",
	"b03_pilgrim__musa_on_the_road",
	"b04_pilgrim__idris_on_hajj",
	"b05_pilgrim__musa_came_home",
	"b06_people_say__sent_musa",
	"b07_pilgrim__secret_ticked",
	"b08_people_say__secret_no_line",
	"b09_pilgrim__ramadan_hajj_closed",
	"b10_pilgrim__not_enough_coins",
	"b11_gate__night_no_abbas",
]
const SECOND_RAMADAN := 31
const SECOND_SHAWWAL := 61
const THIRD_DHU_AL_QADAH := 91
const MORNING := 600
const STARTING_COINS := 300
const STARTING_TRUST := 45

var copy: Dictionary
var panel: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--pilgrims-output="):
			return argument.trim_prefix("--pilgrims-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Pilgrims capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Pilgrims evidence directory")
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
	helper.report.method = "Native Godot viewport. Real UI input drives arrival, Abbas, sending each trip, the first scholar page and What people say."
	helper.report.fixture = "Passive ticks paused. After fair arrival, skip_to sets the calendar and leaves skipped prayers unplayed. The player is placed at the named live place marker. The reputation fixtures face the square from a1 for the street backdrop. Coins and trust are staged at 300 and 45, with 30 coins for b10. Sending, the checkbox, trip returns, counters and reputation use production actions."
	app.set_process(false)
	var runtime := FileAccess.get_file_as_bytes("res://data/pilgrims.json")
	if not helper.check(not runtime.is_empty() and runtime == FileAccess.get_file_as_bytes(LOCKED_DATA), "runtime Pilgrims data matches the locked bytes"):
		finish(app)
		return
	copy = app.pilgrims.data
	panel = copy.panel

	await capture_public_trip(app)
	await capture_secret_trip(app)
	await capture_closed_and_shortage(app)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all eleven locked master states have native captures")
	finish(app)


func capture_public_trip(app: Node3D) -> void:
	await arrive(app)
	stage(app, SECOND_SHAWWAL, int(copy.numbers.from) - 1, "gate")
	check_button(app, copy.gate_button, false)
	stage(app, SECOND_SHAWWAL, int(copy.numbers.from), "gate")
	check_button(app, copy.gate_button)
	stage(app, SECOND_SHAWWAL, MORNING, "gate")
	await capture_state(app, 1)
	await click(app, copy.gate_button)
	check_panel(app, 0, 0)
	expect_text(app, panel.secret_locked)
	check_button(app, panel.secret_label, false)
	for pilgrim: Dictionary in copy.pilgrims:
		send_button(app, pilgrim)
	await capture_state(app, 2)

	var musa: Dictionary = copy.pilgrims[0]
	var idris: Dictionary = copy.pilgrims[3]
	await send(app, musa)
	check_panel(app, 1, 0)
	expect_text(app, panel.away.format({"n": int(copy.numbers.umrah_days)}))
	send_button(app, musa, false)
	await capture_state(app, 3)
	await send(app, idris)
	check_panel(app, 1, 1)
	expect_text(app, panel.away.format({"n": 82}))
	send_button(app, idris, false)
	helper.check(app.ui.reputation_lines().is_empty(), "a public trip creates no reputation before the return")
	await capture_state(app, 4)

	await click(app, panel.back)
	helper.check(app.ui.screen == "market_map", "the visible Back button returns to the map")
	stage(app, THIRD_DHU_AL_QADAH, MORNING, "gate")
	await click(app, copy.gate_button)
	check_panel(app, 1, 1)
	expect_text(app, panel.home)
	expect_text(app, panel.away.format({"n": 52}))
	send_button(app, musa, false)
	var return_trust := STARTING_TRUST + int(copy.numbers.return_trust)
	helper.check(app.progress.trust == return_trust, "Old Musa's public return awards the locked trust once")
	app.update_state()
	helper.check(app.progress.trust == return_trust, "refreshing the day does not repeat the return trust")
	await capture_state(app, 5)
	await click(app, panel.back)
	await open_reputation_from_lane(app)
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [musa.say], "the returned public trip is the sole reputation row")
	expect_text(app, "“%s”" % musa.say[0])
	expect_text(app, musa.say[1])
	expect_text(app, app.chapter.rep.tone[str(int(musa.say[2]))])
	await capture_state(app, 6)


func capture_secret_trip(app: Node3D) -> void:
	await arrive(app)
	stage(app, SECOND_SHAWWAL, MORNING, "inn")
	await click(app, app.chapter.places.inn)
	await click(app, app.chapter.purse.ask_baker)
	await click(app, str(app.chapter.purse.take_page).format({"teacher": app.chapter.teacher}))
	helper.check(app.ui.screen == "purse_page" and app.open_purse.page_read, "the native scholar page unlocks secret giving")
	await click(app, app.chapter.page.back)
	await click(app, app.chapter.purse.not_now)
	stage(app, SECOND_SHAWWAL, MORNING, "gate")
	await click(app, copy.gate_button)
	check_panel(app, 0, 0)
	expect_text(app, panel.secret_locked, false)
	check_secret_box(app, false)
	await click(app, panel.secret_label)
	check_secret_box(app, true)
	await capture_state(app, 7)

	var yunus: Dictionary = copy.pilgrims[1]
	await send(app, yunus)
	check_panel(app, 1, 0)
	await click(app, panel.back)
	stage(app, THIRD_DHU_AL_QADAH, MORNING, "gate")
	await click(app, copy.gate_button)
	expect_text(app, panel.home)
	send_button(app, yunus, false)
	await click(app, panel.back)
	await open_reputation_from_lane(app)
	helper.check(app.progress.trust == STARTING_TRUST, "the secret return leaves trust at 45")
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines().is_empty(), "V2 leaves no reputation row after the secret return")
	expect_text(app, app.chapter.rep.empty)
	await capture_state(app, 8)


func open_reputation_from_lane(app: Node3D) -> void:
	app.player.position = app.world.point("a1")
	var toward_square: Vector3 = app.world.point(app.data.square.centre) - app.player.position
	app.player.yaw = atan2(-toward_square.x, -toward_square.z)
	app.player.update_camera()
	app.update_state()
	await click(app, app.chapter.purse.morning.to_rep)


func capture_closed_and_shortage(app: Node3D) -> void:
	await arrive(app)
	stage(app, SECOND_RAMADAN, MORNING, "gate")
	await click(app, copy.gate_button)
	check_panel(app, 0, 0)
	expect_text(app, panel.hajj_closed)
	for pilgrim: Dictionary in copy.pilgrims:
		send_button(app, pilgrim, pilgrim.kind == "umrah")
	await capture_state(app, 9)
	await click(app, panel.back)

	app.progress.coins = 30
	stage(app, SECOND_SHAWWAL, MORNING, "gate")
	await click(app, copy.gate_button)
	check_panel(app, 0, 0)
	expect_text(app, panel.not_enough, true, 4)
	for pilgrim: Dictionary in copy.pilgrims:
		send_button(app, pilgrim, false)
	await capture_state(app, 10)
	await click(app, panel.back)

	app.progress.coins = STARTING_COINS
	stage(app, SECOND_SHAWWAL, int(copy.numbers.until) - 1, "gate")
	check_button(app, copy.gate_button)
	stage(app, SECOND_SHAWWAL, int(copy.numbers.until), "gate")
	check_button(app, copy.gate_button, false)
	stage(app, SECOND_SHAWWAL, 1200, "gate")
	check_button(app, copy.gate_button, false)
	await capture_state(app, 11)


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
	helper.check(app.pilgrims.umrah_paid == 0 and app.pilgrims.hajj_paid == 0 and app.ui.reputation_lines().is_empty(), "new arrival starts with no trips or reputation")


func stage(app: Node3D, day: int, minute: int, place: String) -> void:
	app.clock.skip_to(day, minute)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == place, "live map at " + place)
	helper.check(app.day == day and app.minute_of_day == minute, "live clock at day %d minute %d" % [day, minute])


func check_panel(app: Node3D, umrah: int, hajj: int) -> void:
	helper.check(app.ui.screen == "pilgrims", "the native Pilgrims panel is open")
	expect_text(app, panel.kicker)
	expect_text(app, panel.title)
	expect_text(app, panel.text)
	for pilgrim: Dictionary in copy.pilgrims:
		expect_text(app, pilgrim.line)
	var counters: String = panel.counter.format({"n": umrah, "m": "1,000"}) + " · " + panel.counter_hajj.format({"n": hajj, "m": 100})
	var totals := expect_text(app, counters)
	var back := check_button(app, panel.back)
	if totals != null and back != null:
		var counter_rect := totals.get_global_rect()
		var back_rect := back.get_global_rect()
		helper.check(counter_rect.get_center().y >= back_rect.position.y and counter_rect.get_center().y <= back_rect.end.y, "the visible back button stays on the same row as the counters")
	helper.check(app.pilgrims.umrah_paid == umrah and app.pilgrims.hajj_paid == hajj, "live trip counters are %d Umrah and %d Hajj" % [umrah, hajj])


func check_secret_box(app: Node3D, selected: bool) -> void:
	var checkbox := check_button(app, panel.secret_label)
	helper.check(checkbox is CheckBox and checkbox.button_pressed == selected, "the live checkbox matches the secret selection")


func check_button(app: Node3D, caption: String, shown: bool = true) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == shown, "button %s: %s" % ["shown" if shown else "hidden", caption])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits the viewport: " + caption)
	return button


func send_button(app: Node3D, pilgrim: Dictionary, shown: bool = true) -> Button:
	var button := app.ui.content.find_child("SendPilgrim_" + pilgrim.id, true, false) as Button
	helper.check((button != null and button.is_visible_in_tree()) == shown, "send action for %s: %s" % [pilgrim.name, "shown" if shown else "hidden"])
	if button != null and shown:
		helper.check(button.text == panel.send.format({"n": trip_cost(pilgrim)}), "send action has locked wording and cost")
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "send action fits the viewport")
	return button


func trip_cost(pilgrim: Dictionary) -> int:
	return int(copy.numbers.hajj_cost if pilgrim.kind == "hajj" else copy.numbers.umrah_cost)


func send(app: Node3D, pilgrim: Dictionary) -> void:
	var button := send_button(app, pilgrim)
	if button == null:
		return
	var coins: int = app.progress.coins
	var trust: int = app.progress.trust
	await hit(app, button.get_global_rect().get_center())
	helper.check(app.progress.coins == coins - trip_cost(pilgrim) and app.progress.trust == trust, "sending %s spends the locked cost and leaves trust unchanged" % pilgrim.name)


func expect_text(app: Node3D, value: String, shown: bool = true, count: int = 1) -> Control:
	var controls: Array[Control] = []
	find_text(app.ui.content, value.to_lower(), controls)
	helper.check(controls.size() == (count if shown else 0), "text %s: %s" % ["shown" if shown else "hidden", value])
	for control in controls:
		helper.check(app.get_viewport().get_visible_rect().encloses(control.get_global_rect()), "text fits the viewport: " + value)
	return controls.front() if not controls.is_empty() else null


func find_text(node: Node, folded: String, controls: Array[Control]) -> void:
	if node is Control and not node.is_visible_in_tree():
		return
	if (node is Label and node.text.to_lower() == folded) or (node is RichTextLabel and node.get_parsed_text().to_lower() == folded):
		controls.append(node)
	for child in node.get_children():
		find_text(child, folded, controls)


func capture_state(app: Node3D, master: int) -> void:
	var filename: String = MASTER_STEMS[master - 1] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day_index = app.day - 1
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.date = app.clock.date_label(app.day)
	state.trips_paid = [app.pilgrims.umrah_paid, app.pilgrims.hajj_paid]
	state.secret_selected = app.pilgrims.secret_selected
	state.what_people_say = app.ui.reputation_lines()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE31_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("PILGRIMS NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
