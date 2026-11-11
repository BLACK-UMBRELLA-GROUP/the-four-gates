extends "res://tests/capture_identity.gd"
## DOC-TFG-0089: native viewport evidence for LOCK 26 V1.

const OUTPUT := "res://../GAME/APPROVED/NAMES_OF_ALLAH/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/NAMES_OF_ALLAH/RECORD/names_of_allah_data_V1.json"
const MASTER_STEMS := [
	"m01_masjid__read_the_calligraphy",
	"m02_name__as_salam",
	"m03_masjid__button_gone_after_reading",
	"m04_board__read_the_calligraphy",
	"m05_name__ar_razzaq",
	"m06_name__al_hasib_3_of_99",
	"m07_spice__no_name_here",
	"m08_masjid__before_meeting_idris",
]
const MORNING := 600
const TRUST := 45
const COINS := 198

var copy: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--names-of-allah-output="):
			return argument.trim_prefix("--names-of-allah-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Names of Allah capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Names of Allah evidence directory")
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
	helper.report.method = "Native Godot viewport. Viewport-local mouse events drive fair arrival, the Idris meeting, the calligraphy buttons and Back to the market map."
	helper.report.fixture = "The fair arrival supplies 198 coins. Passive clock ticks pause, the clock is staged at Thursday 10:00, trust is set to 45 and the player is placed at each locked map marker. The panel uses the production camera."
	app.set_process(false)
	copy = app.names_of_allah.data
	var runtime := FileAccess.get_file_as_bytes("res://data/names_of_allah.json")
	helper.check(not runtime.is_empty() and runtime == FileAccess.get_file_as_bytes(LOCKED_DATA), "runtime data is byte-for-byte LOCK 26 V1")
	await arrive(app)

	var salam: Dictionary = copy.names[0]
	var razzaq: Dictionary = copy.names[1]
	var hasib: Dictionary = copy.names[2]
	var masjid_actions: Dictionary = app.identity.clock.masjid_actions
	var school_button: String = app.qurans_school.data.masjid_button
	stage(app, salam.place)
	check_button(app, copy.button, false)
	check_button(app, masjid_actions.none_yet)
	check_button(app, school_button)
	helper.check(not app.idris_met, "the before-meeting master has no meeting completion")
	await capture_state(app, 7)
	await meet_idris(app)

	check_button(app, masjid_actions.after_meeting)
	var school := check_button(app, school_button)
	var calligraphy := check_button(app, copy.button)
	if school != null and calligraphy != null:
		helper.check(school.get_global_rect().end.x <= calligraphy.get_global_rect().position.x,
			"calligraphy follows the school button on the Masjid bar")
	await capture_state(app, 0)
	await read_name(app, salam, 1, 1)
	await capture_state(app, 2)

	stage(app, razzaq.place)
	check_button(app, copy.button)
	await capture_state(app, 3)
	await read_name(app, razzaq, 2, 4)

	stage(app, hasib.place)
	await read_name(app, hasib, 3, 5)

	stage(app, "spice")
	check_button(app, copy.button, false)
	check_button(app, app.market_stall.data.place.spice_button)
	helper.check(app.names_of_allah.learned == [salam.id, razzaq.id, hasib.id], "exactly the three learned IDs remain in order")
	await capture_state(app, 6)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all eight locked states have native captures")
	finish(app)


func arrive(app: Node3D) -> void:
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	app.clock.reset()
	app.progress.apply_trust(TRUST - app.progress.trust)
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn" and app.progress.coins == COINS,
		"fair arrival opens the Inn map with 198 coins")
	helper.check(app.names_of_allah.learned.is_empty(), "the session starts with no learned Names")


func stage(app: Node3D, place: String) -> void:
	app.clock.skip_to(1, MORNING)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == place, "live market map at " + place)
	helper.check(app.day == 1 and app.minute_of_day == MORNING, "the live clock reads Thursday 10:00")


func meet_idris(app: Node3D) -> void:
	await click(app, app.identity.clock.masjid_actions.none_yet)
	var teacher: Dictionary = app.identity.teacher
	for beat: Dictionary in teacher.beats:
		await click(app, beat.choices[0].label)
		await click(app, teacher.buttons.continue)
	await click(app, teacher.buttons.leave)
	helper.check(app.idris_met and app.ui.screen == "market_map" and app.current_place == "masjid",
		"the Idris meeting completes and returns to the Masjid")


func read_name(app: Node3D, entry: Dictionary, count: int, screenshot: int) -> void:
	var reputation: Array = app.ui.reputation_lines()
	await click(app, copy.button)
	helper.check(app.ui.screen == "names_of_allah", "the calligraphy button opens the Names panel")
	helper.check(app.names_of_allah.learned.size() == count and app.names_of_allah.learned.has(entry.id),
		"learning %s gives private count %d" % [entry.tr, count])
	helper.check(app.progress.coins == COINS and app.progress.trust == TRUST and app.ui.reputation_lines() == reputation,
		"learning a Name leaves wallet, trust and reputation unchanged")
	var counter: String = copy.panel.count.format({"n": count, "m": int(copy.numbers.goal)})
	var captions: Array[String] = [
		copy.panel.kicker, entry.ar, entry.tr + " · " + entry.en, entry.where, entry.idris, entry.ref + " · " + counter,
	]
	for caption: String in captions:
		var label := find_caption(app.ui.content, caption)
		if helper.check(label != null, "visible locked caption: " + caption):
			helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "caption fits the viewport: " + caption)
	var arabic := find_caption(app.ui.content, entry.ar)
	if arabic is Label:
		helper.check(arabic.text == entry.ar and arabic.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT
			and arabic.text_direction == Control.TEXT_DIRECTION_RTL, "Arabic retains its exact marks and right-to-left alignment")
	else:
		helper.check(false, "the Arabic renders in a right-to-left label")
	check_button(app, copy.panel.to_map)
	await capture_state(app, screenshot)
	await click(app, copy.panel.to_map)
	helper.check(app.ui.screen == "market_map" and app.current_place == entry.place,
		"Back returns to the same market place: " + str(entry.place))
	check_button(app, copy.button, false)


func find_caption(node: Node, caption: String) -> Control:
	if node is Control and not node.is_visible_in_tree():
		return null
	if (node is Label and node.text.nocasecmp_to(caption) == 0) or (node is RichTextLabel and node.get_parsed_text().nocasecmp_to(caption) == 0):
		return node
	for child in node.get_children():
		var found := find_caption(child, caption)
		if found != null:
			return found
	return null


func check_button(app: Node3D, caption: String, shown: bool = true) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == shown, "button %s: %s" % ["shown" if shown else "hidden", caption])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits the viewport: " + caption)
	return button


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.idris_met = app.idris_met
	state.learned = app.names_of_allah.learned.duplicate()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE33_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("NAMES OF ALLAH NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
