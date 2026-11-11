extends "res://tests/capture_identity.gd"
## DOC-TFG-0016: viewport evidence for the first Idris meeting.

const OUTPUT := "res://../GAME/APPROVED/IDENTITY/BUILT/V1/IDRIS/"
const MASTER_STEMS := [
	"g19_market_map__masjid_sit_a_while",
	"g25_meet__start_unknown_word",
	"g26_meet__new_word",
	"g27_meet__word_to_learn",
	"g28_meet__learned_words_show_english",
	"g29_meet__end",
]

static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--idris-output="):
			return argument.trim_prefix("--idris-output=")
	return OUTPUT

func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Idris evidence directory")
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
	helper.report.method = "Native Godot viewport and real viewport clicks on the production buttons. Passive clock ticks are paused for repeatable captures."
	helper.report.fixture = "g19 seeds the Masjid and Thursday 10:00. The Arrival branch reaches 18:15 through its choices and is captured with the real wallet. The zero-coin fixture reproduces the g25–g29 HUD. The post-meeting Masjid check completes Maghrib through the clock model."
	app.set_process(false)

	var teacher: Dictionary = app.identity.teacher
	var beats: Array = teacher.beats
	var arrival: Dictionary = app.identity.arrival
	var actions: Dictionary = app.identity.clock.masjid_actions
	app.clock.advance_to(1, 600, false)
	app.player.position = app.world.point("masjid")
	app.show_screen("market_map")
	await capture_state(app, MASTER_STEMS[0])
	await click(app, actions.none_yet)
	helper.check(app.ui.screen == "idris" and app.minute_of_day == 600, "Sit a while opens Idris immediately at the live 10:00 clock")
	await capture_state(app, "masjid_live_clock")
	await click(app, teacher.buttons.leave)
	helper.check(app.ui.screen == "market_map" and app.current_place == "masjid" and not app.idris_met, "Leave returns to the Masjid before completing the meeting")

	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[0])
	var wallet: int = app.progress.coins
	helper.check(app.ui.screen == "idris" and app.current_place == "masjid" and app.minute_of_day == 1095 and wallet == 198 and app.paid_nights == 1, "Meet the old man preserves the Arrival clock, wallet and prepaid night")
	await capture_state(app, "arrival_18_15")

	app.progress.coins = 0
	app.update_state()
	helper.check(app.known_words.is_empty(), "the first beat starts with zero words known")
	await capture_state(app, MASTER_STEMS[1])
	await click(app, beats[0].choices[0].label)
	helper.check(app.known_words.size() == 1 and app.known_words.has(beats[0].choices[0].learns), "the first word is learned on the teaching choice")
	await capture_state(app, MASTER_STEMS[2])
	await click(app, teacher.buttons.continue)
	await click(app, beats[1].choices[0].label)
	helper.check(app.known_words.size() == 1, "the water reply leaves the count at one")
	await click(app, teacher.buttons.continue)
	await capture_state(app, MASTER_STEMS[3])
	await click(app, beats[2].choices[0].label)
	await click(app, teacher.buttons.continue)
	helper.check(app.known_words.size() == 2 and not app.known_words.has(beats[3].choices[0].learns), "beat four starts at two words and the last word is still unknown")
	await capture_state(app, MASTER_STEMS[4])
	await click(app, beats[3].choices[0].label)
	await click(app, teacher.buttons.continue)
	helper.check(app.known_words.size() == 3 and app.idris_met, "continuing the last reply completes the meeting with three words")
	await capture_state(app, MASTER_STEMS[5])

	await click(app, teacher.buttons.again)
	helper.check(app.ui.screen == "idris" and app.idris_beat == 0 and app.known_words.size() == 3, "Meet him again starts at beat one with all learned words")
	await click(app, beats[0].choices[0].label)
	helper.check(app.known_words.size() == 3 and app.ui.idris_new_word.is_empty(), "relearning a known word adds no notice or count")
	await click(app, teacher.buttons.continue)
	for index in range(1, beats.size()):
		await click(app, beats[index].choices[0].label)
		await click(app, teacher.buttons.continue)
	app.progress.coins = wallet
	await click(app, teacher.buttons.back)
	helper.check(app.ui.screen == "market_map" and app.current_place == "masjid" and app.progress.coins == wallet and app.paid_nights == 1, "Back to the market returns to the Masjid with wallet and credit intact")
	app.clock.pray(true)
	app.update_state()
	helper.check(helper.find_button(app.ui, actions.after_meeting) != null and helper.find_button(app.ui, actions.none_yet) == null, "the Masjid offers Look inside after the meeting when no prayer action is due")
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size() + 2, "six master states and both entry captures were saved")
	finish(app)

func capture_state(app: Node3D, stem: String) -> void:
	var filename := stem + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.idris_beat = app.idris_beat
	state.known_words = app.known_words.keys()
	state.idris_met = app.idris_met
	if app.ui.screen == "idris":
		state.caption = app.identity.teacher.when
		state.new_word = app.ui.idris_new_word

func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("IDRIS NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
