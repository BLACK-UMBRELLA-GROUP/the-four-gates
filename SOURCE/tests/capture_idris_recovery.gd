extends "res://tests/capture_identity.gd"
## DOC-TFG-0053: native viewport evidence for LOCK 14 V1.

const OUTPUT := "res://../GAME/APPROVED/IDRIS_HAS_HEARD/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/IDRIS_HAS_HEARD/RECORD/idris_has_heard_data_V1.json"
const MASTER_STEMS := [
	"i01_masjid__before_any_talk",
	"i02_masjid__idris_does_not_smile",
	"i03_purse__take_the_page",
	"i04_idris__page_refused",
	"i05_people_say__idris_has_heard",
	"i06_people_say__says_you_have_changed",
	"i07_page_1__read_after_warming",
	"i08_masjid__cool_but_can_pray",
]
const SATURDAY := 3
const COOL_DAY := SATURDAY + 4
const WARM_DAY := COOL_DAY + 1
const MORNING := 10 * 60
const DHUHR := 13 * 60 + 5
const EVENING := 20 * 60
const STARTING_TRUST := 45
const STARTING_COINS := 198


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--idris-recovery-output="):
			return argument.trim_prefix("--idris-recovery-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Idris recovery capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Idris recovery evidence directory")
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
	helper.report.method = "Real native Godot viewport. Viewport-local input exercises fair arrival, the first Idris meeting, market routes, the dice invitation and door, the open purse, What people say and Dhuhr."
	helper.report.fixture = "Passive clock ticks are paused. Fair arrival supplies 198 coins. Trust is seeded through the normal mutation path at 45, and four real dice nights reduce it to 40. The baseline is Saturday day 3 at 10:00, cool scenes are Wednesday day 7 at 10:00 or 13:05 for Dhuhr, and warm scenes are Thursday day 8 at 10:00. Ten fixture trust points are applied through the same mutation path to reproduce the master’s warm state without adding unrelated reputation lines."
	app.set_process(false)

	var locked := FileAccess.get_file_as_bytes(LOCKED_DATA)
	helper.check(not locked.is_empty() and locked == FileAccess.get_file_as_bytes("res://data/idris_has_heard.json"), "runtime recovery data matches the locked bytes")
	var copy: Dictionary = JSON.parse_string(locked.get_string_from_utf8())
	var refusal: Dictionary = copy.page_refused
	var chapter: Dictionary = app.chapter
	var purse: Dictionary = chapter.purse
	var dice: Dictionary = app.dice_house.data
	var take_page: String = str(purse.take_page).format({"teacher": chapter.teacher})
	var look_inside: String = app.identity.clock.masjid_actions.after_meeting

	await arrive_and_meet_idris(app)
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	set_time(app, SATURDAY, MORNING)
	helper.check(app.ui.screen == "market_map" and app.current_place == "masjid" and app.progress.coins == STARTING_COINS, "fair arrival and first meeting reach the Masjid with the live wallet")
	expect_button(app, look_inside)
	helper.check(find_label(app.ui, copy.masjid_line) == null and app.idris_recovery.reputation_line() == null, "the Masjid and reputation are neutral before the talk")
	await capture_state(app, 0)

	if not await travel(app, "inn"):
		return
	for night in range(1, int(dice.numbers.seen_from_visits) + 1):
		set_time(app, SATURDAY + night - 1, EVENING)
		if night == 1:
			await click(app, dice.inn_invite)
			await click(app, dice.invite.go)
		else:
			await click(app, dice.inn_button)
		helper.check(app.ui.screen == "dice_house" and app.dice_house.nights == night, "a distinct dice night counts once: %d" % night)
		await click(app, dice.house.leave)
	set_time(app, COOL_DAY, MORNING)
	if not await travel(app, "masjid"):
		return
	var cool_trust: int = STARTING_TRUST + int(dice.numbers.seen_trust)
	helper.check(app.progress.trust == cool_trust and app.idris_recovery.cool and app.idris_recovery.cool_point == cool_trust, "the dice hit cools Idris at the post-hit trust")
	expect_masjid_note_after_button(app, copy.masjid_line, look_inside)
	await capture_state(app, 1)

	if not await travel(app, "inn"):
		return
	face_place(app, "quay")
	await click(app, chapter.places.inn)
	await click(app, purse.ask_baker)
	await click(app, purse.baker.back)
	helper.check(app.ui.screen == "purse" and app.open_purse.salma_asked and app.open_purse.visible_people().size() == 4, "Salma’s visit leaves four people and the page action at the Inn")
	expect_button(app, take_page)
	helper.check(helper.find_button(app.ui, purse.give_secret) == null, "the unopened page still hides In secret")
	await capture_state(app, 2)

	await click(app, take_page)
	helper.check(app.ui.screen == "purse_refused", "the page action opens Idris’s refusal")
	expect_label(app, str(refusal.kicker).to_upper())
	expect_label(app, refusal.title)
	expect_label(app, refusal.text)
	expect_button(app, refusal.to_map)
	helper.check(not app.open_purse.page_read and not app.known_words.has("sirr") and not app.open_purse.has_secret_gift(), "refusal leaves the page unread, the word unknown and secret giving unavailable")
	await capture_state(app, 3)
	await click(app, refusal.to_map)
	helper.check(app.ui.screen == "market_map" and app.open_purse.salma_asked and not app.open_purse.done and app.open_purse.visible_people().size() == 4 and app.progress.coins == STARTING_COINS, "Back to the market map keeps the open purse and wallet intact")

	if app.current_place != "masjid" and not await travel(app, "masjid"):
		return
	face_place(app, app.data.square.centre)
	await click(app, purse.morning.to_rep)
	expect_reputation(app, [dice.say.seen, copy.say.cool])
	await capture_state(app, 4)
	await click(app, chapter.rep.to_map)

	await click(app, app.data.ui.buttons.wait_prayer)
	set_time(app, COOL_DAY, DHUHR)
	var dhuhr: String = app.clock.prayer_label(true)
	var prayer_copy: Dictionary = app.identity.clock
	helper.check(dhuhr == str(prayer_copy.pray_here).format({"prayer": prayer_copy.prayers[1].name}), "the later non-Friday 13:05 fixture offers ordinary Dhuhr")
	expect_masjid_note_after_button(app, copy.masjid_line, dhuhr)
	await capture_state(app, 7)
	await click(app, dhuhr)
	helper.check(app.clock.record().rows[1].status == "alone" and app.idris_recovery.cool, "the live Dhuhr button completes prayer while Idris remains cool")

	set_time(app, WARM_DAY, MORNING)
	app.progress.apply_trust(int(copy.numbers.warm_gain))
	app.update_state()
	helper.check(not app.idris_recovery.cool and app.progress.trust == cool_trust + int(copy.numbers.warm_gain), "the locked gain warms Idris")
	helper.check(find_label(app.ui, copy.masjid_line) == null, "the Masjid note disappears on warming")
	await click(app, purse.morning.to_rep)
	expect_reputation(app, [dice.say.seen, copy.say.warm])
	await capture_state(app, 5)
	await click(app, chapter.rep.to_map)

	if not await travel(app, "inn"):
		return
	face_place(app, "quay")
	await click(app, chapter.places.inn)
	await click(app, take_page)
	helper.check(app.ui.screen == "purse_page" and app.open_purse.page_read and app.known_words.has("sirr"), "the warmed Idris reads page one and teaches sirr")
	expect_label(app, chapter.page.title)
	expect_button(app, chapter.page.back)
	await capture_state(app, 6)
	await click(app, chapter.page.back)
	expect_button(app, purse.give_secret)

	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all eight LOCK 14 master states were captured")
	finish(app)


func arrive_and_meet_idris(app: Node3D) -> void:
	var arrival: Dictionary = app.identity.arrival
	var teacher: Dictionary = app.identity.teacher
	await click(app, app.data.ui.buttons.begin)
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[0])
	for beat: Dictionary in teacher.beats:
		await click(app, beat.choices[0].label)
		await click(app, teacher.buttons.continue)
	await click(app, teacher.buttons.back)


func set_time(app: Node3D, day: int, minute: int) -> void:
	app.clock.skip_to(day, minute)
	app.update_state()


func face_place(app: Node3D, place: String) -> void:
	var toward: Vector3 = app.world.point(place) - app.player.position
	app.player.yaw = atan2(-toward.x, -toward.z)
	app.player.update_camera()


func expect_button(app: Node3D, caption: String) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check(button != null and app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "visible button fits in the viewport: " + caption)
	return button


func expect_label(app: Node3D, value: String) -> Control:
	var label := find_label(app.ui, value)
	helper.check(label != null and app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "visible locked label fits in the viewport: " + value)
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


func expect_masjid_note_after_button(app: Node3D, text: String, caption: String) -> void:
	var button := expect_button(app, caption)
	var label := expect_label(app, text)
	helper.check(button != null and label != null and button.get_global_rect().end.x <= label.get_global_rect().position.x, "the cool note follows the Masjid button")


func expect_reputation(app: Node3D, lines: Array) -> void:
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == lines, "What people say shows the dice line followed by exactly the correct Idris line")
	for line: Array in lines:
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
	state.dice_nights = app.dice_house.nights
	state.cool = app.idris_recovery.cool
	state.cool_point = app.idris_recovery.cool_point
	state.page_read = app.open_purse.page_read
	state.knows_sirr = app.known_words.has("sirr")
	state.prayer = app.clock.prayer_label(app.current_place == "masjid")
	state.toast = app.ui.toast_label.text if app.ui.toast_panel.visible else ""
	if app.ui.screen == "reputation":
		state.lines = app.ui.reputation_lines()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE21_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("IDRIS RECOVERY NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
