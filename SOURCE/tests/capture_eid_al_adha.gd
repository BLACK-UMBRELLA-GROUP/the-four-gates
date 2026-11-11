extends "res://tests/capture_identity.gd"
## DOC-TFG-0080: native viewport evidence for LOCK 23.

const OUTPUT := "res://../GAME/APPROVED/EID_AL_ADHA/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/EID_AL_ADHA/RECORD/eid_al_adha_data_V1.json"
const MASTER_STEMS := [
	"a01_gate__saeed_brings_sheep",
	"a02_sheep__offer",
	"a03_sheep__bought",
	"a04_sheep__saeed_remembers",
	"a05_sheep__not_enough_coins",
	"a06_inn__intend_arafah_fast",
	"a07_spice__arafah_fasting_line",
	"a08_gate__eid_no_sacrifice_before_prayer",
	"a09_masjid__eid_al_adha_prayer",
	"a10_adha__the_prayer",
	"a11_gate__sacrifice_your_sheep",
	"a12_sacrifice__choose",
	"a13_sacrifice__thirds",
	"a14_sacrifice__all_to_the_poor_day_11",
	"a15_gate__tashreeq_line",
	"a16_prayers__dhu_al_hijjah_record",
	"a17_gate__13th_after_maghrib_no_sacrifice",
	"a18_gate__14th_nothing",
]
const FIRST_DHU_AL_HIJJAH := 119
const STARTING_COINS := 198
const STARTING_TRUST := 45

var copy: Dictionary
var buy_caption: String


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--adha-output="):
			return argument.trim_prefix("--adha-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Eid al-Adha capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Eid al-Adha evidence directory")
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
	helper.report.method = "Native Godot viewport with production buttons for fair arrival, telling Saeed, buying a sheep, intending the fast, Eid prayer, both distributions and opening the private prayer record."
	helper.report.fixture = "Passive ticks are paused. After fair arrival, skip_to stages real calendar times and leaves skipped prayers unplayed. The player is placed at the named place marker. For a16, the player looks down the lane from a1 toward the square. Wallet and trust begin at 198 and 45, with a 20-coin shortage in a05 and trust set back to 45 after telling Saeed in a04. Purchases, prayer, intention, distribution and record outcomes are produced by the game."
	app.set_process(false)
	var runtime := FileAccess.get_file_as_bytes("res://data/eid_al_adha.json")
	if not helper.check(not runtime.is_empty() and FileAccess.get_file_as_bytes(LOCKED_DATA) == runtime, "runtime Eid al-Adha data matches the locked bytes"):
		finish(app)
		return
	copy = app.eid_al_adha.data
	buy_caption = str(copy.sheep.buy).format({"n": int(copy.numbers.sheep_cost)})

	await arrive(app)
	await capture_sheep(app)
	await capture_arafah_and_eid(app)
	await capture_thirds_and_record(app)
	await capture_all_and_cutoff(app)
	await capture_sheep_variants(app)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all eighteen locked masters have native captures")
	finish(app)


func capture_sheep(app: Node3D) -> void:
	stage(app, 1, 600, "gate")
	check_button(app, copy.gate_button)
	await capture_state(app, 1)
	await click(app, copy.gate_button)
	check_panel(app, "adha_sheep", copy.sheep)
	expect_label(app, copy.sheep.remembers, false)
	check_button(app, buy_caption)
	check_button(app, copy.sheep.no)
	await capture_state(app, 2)
	await buy_sheep(app)
	await capture_state(app, 3)
	await click(app, copy.sheep.no)
	check_button(app, copy.gate_button, false)


func capture_arafah_and_eid(app: Node3D) -> void:
	stage(app, 9, 240, "inn")
	check_button(app, copy.arafah_button)
	await capture_state(app, 6)
	var before := accounts(app)
	await click(app, copy.arafah_button)
	helper.check(app.ui.screen == "market_map" and app.eid_al_adha.record().arafah == copy.record.yes_fast, "the Inn action records the Arafah intention")
	helper.check(app.ui.toast_panel.is_visible_in_tree() and app.ui.toast_label.text == copy.arafah_toast, "Arafah shows the exact locked toast")
	helper.check(app.get_viewport().get_visible_rect().encloses(app.ui.toast_panel.get_global_rect()), "the Arafah toast fits the viewport")
	check_button(app, copy.arafah_button, false)
	helper.check(accounts(app) == before, "intention leaves coins, trust, meals and public reputation unchanged")
	await helper.settle_toast(app)
	stage(app, 9, 600, "spice")
	expect_label(app, str(copy.arafah_line).format({"t": "18:10"}))
	await capture_state(app, 7)

	stage(app, 10, 400, "gate")
	expect_label(app, copy.eid_line)
	check_button(app, copy.sacrifice_button, false)
	await capture_state(app, 8)
	stage(app, 10, 400, "masjid")
	expect_label(app, copy.eid_line)
	check_button(app, copy.eid_button)
	await capture_state(app, 9)
	await click(app, copy.eid_button)
	check_panel(app, "adha_eid", copy.eid)
	check_button(app, copy.eid.to_map)
	helper.check(app.minute_of_day == 400 and app.eid_al_adha.record().eid == copy.record.yes_eid, "the Eid prayer is recorded without advancing the clock")
	helper.check(accounts(app) == before, "Eid prayer leaves coins, trust, meals and public reputation unchanged")
	await capture_state(app, 10)
	await click(app, copy.eid.to_map)
	check_button(app, copy.eid_button, false)


func capture_thirds_and_record(app: Node3D) -> void:
	stage(app, 10, 420, "gate")
	expect_label(app, copy.eid_line)
	check_button(app, copy.sacrifice_button)
	await capture_state(app, 11)
	await click(app, copy.sacrifice_button)
	check_sacrifice_panel(app)
	await capture_state(app, 12)
	await distribute(app, false)
	await capture_state(app, 13)
	await click(app, copy.sacrifice.to_map)
	check_button(app, copy.sacrifice_button, false)

	stage(app, 11, 600, "gate")
	expect_label(app, copy.tashreeq_line)
	await capture_state(app, 15)
	# The record master shows a street behind the panel. Look down the existing
	# placeholder lane, clear of the Gate NPC whose marker fills the camera.
	app.player.position = app.world.point("a1")
	var toward_square: Vector3 = app.world.point(app.data.square.centre) - app.player.position
	app.player.yaw = atan2(-toward_square.x, -toward_square.z)
	app.player.update_camera()
	app.update_state()
	await hit(app, app.ui.clock_panel.get_global_rect().get_center())
	helper.check(app.ui.screen == "prayer_record", "the native clock opens Today's prayers")
	await click(app, app.ui.prayer_record.record_button)
	helper.check(app.ui.screen == "all_prayers", "Today's prayers opens All your prayers")
	check_record_rows(app)
	await capture_state(app, 16)


func capture_all_and_cutoff(app: Node3D) -> void:
	await arrive(app)
	stage(app, 1, 600, "gate")
	await click(app, copy.gate_button)
	await buy_sheep(app)
	await click(app, copy.sheep.no)
	stage(app, 11, 600, "gate")
	await click(app, copy.sacrifice_button)
	check_sacrifice_panel(app)
	await distribute(app, true)
	await capture_state(app, 14)

	await arrive(app)
	stage(app, 1, 600, "gate")
	await click(app, copy.gate_button)
	await buy_sheep(app)
	await click(app, copy.sheep.no)
	stage(app, 13, 1100, "gate")
	helper.check(app.eid_al_adha.owns_sheep(), "the late cutoff fixture still owns an unused sheep")
	check_button(app, copy.sacrifice_button, false)
	expect_label(app, copy.tashreeq_line)
	await capture_state(app, 17)
	stage(app, 14, 600, "gate")
	check_button(app, copy.gate_button, false)
	check_button(app, copy.sacrifice_button, false)
	expect_label(app, copy.tashreeq_line, false)
	expect_label(app, copy.eid_line, false)
	await capture_state(app, 18)


func capture_sheep_variants(app: Node3D) -> void:
	await arrive(app)
	stage(app, 0, 960, "gate")
	var goats: Dictionary = app.jabirs_goats.data
	await click(app, goats.gate_button)
	await click(app, goats.offer.tell)
	await click(app, goats.told.to_map)
	helper.check(app.jabirs_goats.told, "Saeed remembers after the native Tell Saeed action")
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	stage(app, 1, 600, "gate")
	await click(app, copy.gate_button)
	check_panel(app, "adha_sheep", copy.sheep)
	expect_label(app, copy.sheep.remembers)
	check_button(app, buy_caption)
	check_button(app, copy.sheep.no)
	await capture_state(app, 4)

	await arrive(app, 20)
	stage(app, 1, 600, "gate")
	await click(app, copy.gate_button)
	check_panel(app, "adha_sheep", copy.sheep)
	expect_label(app, copy.sheep.not_enough)
	expect_label(app, copy.sheep.remembers, false)
	check_button(app, buy_caption, false)
	check_button(app, copy.sheep.no)
	helper.check(not app.eid_al_adha.owns_sheep() and app.progress.coins == 20, "the shortage changes neither ownership nor the wallet")
	await capture_state(app, 5)


func arrive(app: Node3D, coins: int = STARTING_COINS) -> void:
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	app.clock.reset()
	app.progress.coins = coins
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival opens the live Inn map")
	helper.check(accounts(app) == [coins, STARTING_TRUST, 0, []], "arrival starts with the staged wallet and trust, no meals and no public reputation")


func stage(app: Node3D, day_of_month: int, minute: int, place: String) -> void:
	var day := FIRST_DHU_AL_HIJJAH + day_of_month - 1
	app.clock.skip_to(day, minute)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == place, "live map at " + place)
	helper.check(app.day == day and app.minute_of_day == minute, "live clock at day %d minute %d" % [day, minute])
	if day_of_month > 0:
		var calendar: Dictionary = app.clock.calendar.date(day - 1)
		helper.check(app.clock.calendar.month_index(day - 1) == int(copy.numbers.month)
			and int(calendar.d) == day_of_month, "the real calendar shows %d Dhu al-Hijjah" % day_of_month)


func accounts(app: Node3D) -> Array:
	return [app.progress.coins, app.progress.trust, app.feeding.meals_given, app.ui.reputation_lines().duplicate(true)]


func check_panel(app: Node3D, screen: String, panel_copy: Dictionary) -> void:
	helper.check(app.ui.screen == screen, "the native " + screen + " panel is open")
	expect_label(app, str(panel_copy.kicker).to_upper())
	expect_label(app, panel_copy.title)
	expect_label(app, panel_copy.text)


func buy_sheep(app: Node3D) -> void:
	var before := accounts(app)
	await click(app, buy_caption)
	check_panel(app, "adha_sheep", copy.sheep)
	expect_label(app, copy.sheep.bought)
	check_button(app, buy_caption, false)
	check_button(app, copy.sheep.no)
	helper.check(app.eid_al_adha.owns_sheep() and accounts(app) == [before[0] - int(copy.numbers.sheep_cost), before[1], before[2], before[3]], "the live purchase owns one sheep, costs thirty coins and preserves trust, meals and public reputation")


func check_sacrifice_panel(app: Node3D) -> void:
	check_panel(app, "adha_sacrifice", copy.sacrifice)
	var thirds := check_button(app, copy.sacrifice.thirds)
	var all := check_button(app, copy.sacrifice.all)
	var back := check_button(app, copy.sacrifice.to_map)
	if thirds != null and all != null and back != null:
		helper.check(thirds.position.y < all.position.y and all.position.y < back.position.y, "the choices are stacked in locked order before the map return")


func distribute(app: Node3D, give_all: bool) -> void:
	var before := accounts(app)
	var choice: String = copy.sacrifice.all if give_all else copy.sacrifice.thirds
	var receipt: String = copy.sacrifice.out_all if give_all else copy.sacrifice.out_thirds
	var meals := int(copy.numbers.all_meals if give_all else copy.numbers.thirds_meals)
	await click(app, choice)
	check_panel(app, "adha_sacrifice", copy.sacrifice)
	expect_label(app, receipt)
	check_button(app, copy.sacrifice.thirds, false)
	check_button(app, copy.sacrifice.all, false)
	check_button(app, copy.sacrifice.to_map)
	helper.check(not app.eid_al_adha.owns_sheep() and accounts(app) == [before[0], before[1], before[2] + meals, before[3]], "the live distribution uses the sheep and adds only %d meals" % meals)


func check_record_rows(app: Node3D) -> void:
	var record_copy: Dictionary = copy.record
	var title := expect_label(app, str(record_copy.title).to_upper())
	var previous_y := title.global_position.y if title != null else 0.0
	var expected := {"arafah": record_copy.yes_fast, "eid": record_copy.yes_eid, "sacrifice": record_copy.yes_sac}
	for key: String in expected:
		var row := expect_label(app, record_copy[key])
		if not helper.check(row != null and row.global_position.y > previous_y, "private row follows the previous row: " + str(record_copy[key])):
			continue
		previous_y = row.global_position.y
		var displayed := ""
		for child in row.get_parent().get_children():
			if child is Label and child.position.y == row.position.y and child.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
				displayed = child.text
		helper.check(displayed == expected[key], "rendered private row: %s = %s" % [record_copy[key], expected[key]])
	var note := expect_label(app, str(app.ui.prayer_record.panel.note).to_upper())
	helper.check(note != null and note.global_position.y > previous_y, "the privacy note follows the three new rows")


func check_button(app: Node3D, caption: String, expected: bool = true) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == expected, "button %s: %s" % ["shown" if expected else "hidden", caption])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits the viewport: " + caption)
	return button


func expect_label(app: Node3D, value: String, expected: bool = true) -> Control:
	var label := find_label(app.ui.content, value)
	helper.check((label != null) == expected, "text %s: %s" % ["shown" if expected else "hidden", value])
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


func capture_state(app: Node3D, master: int) -> void:
	var filename: String = MASTER_STEMS[master - 1] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day_index = app.day - 1
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.date = app.clock.date_label(app.day)
	state.owns_sheep = app.eid_al_adha.owns_sheep()
	state.meals = app.feeding.meals_given
	state.record = app.eid_al_adha.record()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE30_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("EID AL-ADHA NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
