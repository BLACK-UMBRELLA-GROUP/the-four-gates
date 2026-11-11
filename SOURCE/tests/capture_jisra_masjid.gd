extends "res://tests/capture_identity.gd"
## DOC-TFG-0110: capture LOCK 33's eight approved states from native Godot.

const OUTPUT := "res://../GAME/APPROVED/JISRA_MASJID/BUILT/V1/"
const MASTER_STEMS := [
	"jm01_jisra__go_to_the_masjid",
	"jm02_masjid__pray_with_the_congregation",
	"jm03_masjid__no_stranger_here",
	"jm04_prayers__masjids_2_of_50",
	"jm05_masjid__after_the_iqamah",
	"jm06_masjid__first_masjid_1_of_50",
	"jm07_masjid__no_prayer_time",
	"jm08_prayers__bridge_not_counted",
]
const THURSDAY := 8
const NO_PRAYER := 600
const CONGREGATION := 735
const SOLO := 770

var copy: Dictionary
var gate: Dictionary
var prayer: Dictionary
var record: Dictionary


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Jisra masjid evidence requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Jisra masjid evidence directory")
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
	helper.report.method = "Native 1920x1080 Godot viewport. Click through arrival, gate, travel, Jisra, both masjids, bridge prayer and the prayer record with production controls."
	helper.report.fixture = ("Fair arrival gives 198 coins. Passive ticks are paused. Set the player location and gate prerequisites; "
		+ "skip intervening prayer windows with the game clock to Thursday day 8. The real road then advances 90 minutes. "
		+ "A real River Market prayer precedes the Jisra congregation, so jm04 records two on-time prayers and congregations. "
		+ "The solo and bridge paths start fresh.")
	helper.report.resolution = [1920, 1080]
	app.set_process(false)
	copy = app.jisra_masjid.data
	gate = app.gate_of_trust.data
	prayer = app.identity.clock
	record = app.ui.prayer_record

	await fresh_arrival(app)
	var dhuhr: String = str(prayer.pray_here).format({"prayer": prayer.prayers[1].name})
	app.player.position = app.world.point("masjid")
	app.player.velocity = Vector3.ZERO
	app.update_state()
	await click(app, prayer.pray_congregation)
	helper.check(app.jisra_masjid.prayed_in == {"river_market": true} and app.clock.totals().jamaah == 1,
		"the first masjid comes from a real River Market congregation")
	await travel_to_jisra(app, CONGREGATION)
	var watch := expect_button(app, gate.jisra.watch)
	var enter := expect_button(app, copy.jisra_button)
	var bridge_pray := expect_button(app, dhuhr)
	var return_to_market := expect_button(app, gate.jisra.back)
	if watch != null and enter != null and bridge_pray != null and return_to_market != null:
		helper.check(watch.position.x < enter.position.x and enter.position.x < bridge_pray.position.x
			and bridge_pray.position.x < return_to_market.position.x, "bridge action order matches jm01")
	await capture_state(app, 0)

	var wallet := wallet_state(app)
	var reputation: Array = app.ui.reputation_lines().duplicate(true)
	await click(app, copy.jisra_button)
	expect_masjid(app, copy.masjid.text, 1)
	expect_button(app, prayer.pray_congregation)
	await capture_state(app, 1)

	await click(app, prayer.pray_congregation)
	expect_masjid(app, copy.masjid.first, 2)
	expect_button(app, prayer.pray_congregation, false)
	helper.check(app.clock.totals().jamaah == 2 and app.jisra_masjid.prayed_in == {"river_market": true, "jisra": true},
		"Jisra congregation completes a second distinct masjid")
	helper.check(wallet_state(app) == wallet and app.ui.reputation_lines() == reputation,
		"masjid prayer leaves both towns' trust, coins and reputation unchanged")
	await capture_state(app, 2)

	await click(app, copy.masjid.back)
	helper.check(app.ui.screen == "jisra", "Back to the bridge returns to Jisra")
	await open_all_prayers(app)
	expect_count(app, 2, false)
	await capture_state(app, 3)

	await fresh_arrival(app)
	await travel_to_jisra(app, SOLO)
	await click(app, copy.jisra_button)
	expect_masjid(app, copy.masjid.text, 0)
	expect_button(app, dhuhr)
	expect_button(app, prayer.pray_congregation, false)
	await capture_state(app, 4)

	await click(app, dhuhr)
	expect_masjid(app, copy.masjid.first, 1)
	expect_button(app, dhuhr, false)
	helper.check(app.clock.totals().alone_masjid == 1 and app.jisra_masjid.prayed_in == {"jisra": true},
		"after iqamah the solo prayer is recorded at the masjid")
	await capture_state(app, 5)

	await fresh_arrival(app)
	await travel_to_jisra(app, NO_PRAYER)
	await click(app, copy.jisra_button)
	expect_masjid(app, copy.masjid.text, 0)
	expect_button(app, prayer.pray_congregation, false)
	expect_button(app, dhuhr, false)
	helper.check(app.clock.prayer_label(true).is_empty(), "no prayer window is open at 10:00")
	await capture_state(app, 6)

	await click(app, copy.masjid.back)
	app.clock.skip_to(THURSDAY, CONGREGATION)
	app.update_state()
	await click(app, dhuhr)
	helper.check(app.clock.totals().alone_elsewhere == 1 and app.jisra_masjid.prayed_in.is_empty(),
		"the bridge prayer is alone elsewhere and adds no masjid")
	await open_all_prayers(app)
	expect_count(app, 0, false)
	await capture_state(app, 7)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all eight approved states captured")
	finish(app)


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--jisra-masjid-output="):
			return argument.trim_prefix("--jisra-masjid-output=")
	return OUTPUT


func fresh_arrival(app: Node3D) -> void:
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn" and app.progress.coins == 198,
		"the real fair arrival opens the market with 198 coins")
	helper.check(app.jisra_masjid.prayed_in.is_empty(), "the arrival begins a fresh masjid history")


func travel_to_jisra(app: Node3D, arrival_minute: int) -> void:
	app.clock.skip_to(THURSDAY, arrival_minute - int(gate.numbers.travel_minutes))
	app.player.position = app.world.point("gate")
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.progress.trust = int(app.data.numbers.gate_trust)
	app.progress.lesson_done = true
	app.update_state()
	await click(app, gate.gate_open_button)
	await click(app, gate.opening.go)
	helper.check(app.ui.screen == "jisra" and app.day == THURSDAY and app.minute_of_day == arrival_minute,
		"the production road reaches Jisra at minute %d" % arrival_minute)
	helper.check(app.gate_of_trust.jisra_trust == int(gate.numbers.jisra_start), "Jisra starts with its own trust")


func open_all_prayers(app: Node3D) -> void:
	await hit(app, app.ui.clock_panel.get_global_rect().get_center())
	helper.check(app.ui.screen == "prayer_record", "the native clock opens today's prayer record")
	await click(app, record.record_button)
	helper.check(app.ui.screen == "all_prayers" and find_text(app.ui, record.panel.title) != null,
		"the native record opens All your prayers")


func expect_masjid(app: Node3D, body: String, count: int) -> void:
	helper.check(app.ui.screen == "jisra_masjid", "production boatmen's masjid panel")
	for caption: String in [str(copy.masjid.kicker).to_upper(), copy.masjid.title, body]:
		helper.check(find_text(app.ui, caption) != null, "locked masjid copy: " + caption)
	expect_count(app, count, true)
	expect_button(app, copy.masjid.back)


func expect_count(app: Node3D, count: int, uppercase: bool) -> void:
	var formatted := str(copy.counter).format({"n": count, "m": int(copy.numbers.goal_masjids)})
	var label := find_text(app.ui, formatted.to_upper() if uppercase else formatted)
	helper.check(app.jisra_masjid.prayed_in.size() == count, "the distinct masjid count is %d" % count)
	helper.check((label != null) == (count > 0), "counter visibility follows the count")
	if count == 0:
		helper.check(not has_counter_prefix(app.ui, str(copy.counter).get_slice("{", 0)),
			"zero has no counter in the panel")
	elif not uppercase and label != null:
		var missed := find_text(app.ui, record.rows.missed)
		var note := find_text(app.ui, str(record.panel.note).to_upper())
		helper.check(missed != null and note != null and missed.global_position.y < label.global_position.y
			and label.global_position.y < note.global_position.y, "the counter follows the prayer rows before the privacy note")


func expect_button(app: Node3D, caption: String, visible: bool = true) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == visible, ("shown: " if visible else "hidden: ") + caption)
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits the viewport: " + caption)
	return button


func find_text(node: Node, expected: String) -> Control:
	if node is Control and not node.is_visible_in_tree():
		return null
	if node is Label and node.text == expected:
		return node
	if node is RichTextLabel and node.get_parsed_text() == expected:
		return node
	for child in node.get_children():
		var result := find_text(child, expected)
		if result != null:
			return result
	return null


func has_counter_prefix(node: Node, prefix: String) -> bool:
	if node is Control and not node.is_visible_in_tree():
		return false
	if node is Label and node.text.to_lower().begins_with(prefix.to_lower()):
		return true
	for child in node.get_children():
		if has_counter_prefix(child, prefix):
			return true
	return false


func wallet_state(app: Node3D) -> Vector3i:
	return Vector3i(app.progress.coins, app.progress.trust, app.gate_of_trust.jisra_trust)


func capture_state(app: Node3D, index: int) -> void:
	await helper.settle_toast(app)
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.jisra_trust = app.gate_of_trust.jisra_trust
	state.prayed_in = app.jisra_masjid.prayed_in.keys()
	state.uthman_first_line = app.jisra_masjid.show_first
	state.prayer_totals = app.clock.totals()
	state.rendered_night = app.world.night


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE40_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("JISRA MASJID NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
