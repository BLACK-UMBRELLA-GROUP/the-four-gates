extends "res://tests/capture_identity.gd"
## DOC-TFG-0020: native evidence for LOCK 3 V2 part 2.

const OUTPUT := "res://../GAME/APPROVED/CHAPTER_1/BUILT/V1/"
const MASTER_STEMS := [
	"c17_market_map__board_oven",
	"c18_grab__see",
	"c19_grab__asked",
	"c20_grab__after_truth",
	"c21_grab__after_lie",
	"c22_grab__after_quiet",
	"c23_grab__after_pay",
	"c24_market_map__after_grab",
	"c25_people_say__bends_the_truth",
	"c26_market_map__board_salma_later",
	"c27_market_map__board_salma_wants_a_word",
	"c28_market_map__next_day_salma_wants_a_word",
]
const AFTER_MASTERS := {"truth": 20, "lie": 21, "quiet": 22, "pay": 23}
var wallet: int

static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--bread-grab-output="):
			return argument.trim_prefix("--bread-grab-output=")
	return OUTPUT

func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the bread grab evidence directory")
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
	helper.report.method = "Native Godot viewport with local mouse clicks on production GUI. The harness holds the clock at the approved fixture times."
	helper.report.fixture = "Fair arrival sets 198 coins. Captures start at the Task board on Saturday at 10:00. The next-day question is on Sunday at 16:10."
	app.set_process(false)

	var chapter: Dictionary = app.chapter
	var grab: Dictionary = chapter.grab
	var asks_at := int(chapter.numbers.grab_ask_minute)
	var arrival: Dictionary = app.identity.arrival
	await click(app, app.data.ui.buttons.begin)
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	wallet = app.progress.coins
	helper.check(app.current_place == "inn" and wallet == 198, "fair arrival opens the map at the Inn with 198 coins")
	stage_board(app)
	await master_shot(app, 17)
	await click(app, chapter.places.board)
	var faris: Node3D = app.world.faris_at_oven
	var start := faris.position
	helper.check(app.ui.screen == "grab_see" and faris.is_visible_in_tree(), "the oven panel opens with Faris in the world")
	await master_shot(app, 18)
	await app.get_tree().create_timer(0.24).timeout
	helper.check(faris.is_visible_in_tree() and not faris.position.is_equal_approx(start), "Faris's capsule moves away from the oven")
	await capture_state(app, "faris_running_from_oven__build.png")
	await click(app, grab.see.next)
	helper.check(app.ui.screen == "market_map" and app.current_place == "board", "Walk on returns to the Task board map")
	helper.check(app.day == 3 and app.minute_of_day == 600, "seeing and walking on leave the clock at 10:00")
	await master_shot(app, 26)
	app.clock.advance_to(3, asks_at - 1, false)
	app.update_state()
	helper.check(helper.find_button(app.ui, grab.ask_button) == null, "there is no question at 16:09")
	app.clock.advance_to(3, asks_at, false)
	app.update_state()
	await master_shot(app, 27)
	await click(app, grab.ask_button)
	await master_shot(app, 19)
	await choose(app, "truth")

	for id in ["lie", "quiet", "pay"]:
		app.begin_game()
		app.progress.coins = wallet
		stage_board(app)
		await click(app, chapter.places.board)
		await click(app, grab.see.next)
		app.clock.advance_to(3, asks_at, false)
		app.update_state()
		await click(app, grab.ask_button)
		await choose(app, id)
		if id == "lie":
			await click(app, grab.after.to_rep)
			await master_shot(app, 25)
			helper.check(app.ui.reputation_lines() == [grab.answers.lie.say], "the lie's locked line is in What people say")
			await click(app, chapter.rep.to_map)
		else:
			await click(app, grab.after.to_map)
	await master_shot(app, 24)
	helper.check(app.ui.screen == "market_map" and helper.find_button(app.ui, chapter.places.board) == null and helper.find_button(app.ui, grab.ask_button) == null, "the finished board has no encounter buttons")
	app.begin_game()
	app.progress.coins = wallet
	stage_board(app)
	await click(app, chapter.places.board)
	await click(app, grab.see.next)
	app.clock.advance_to(4, asks_at, false)
	app.update_state()
	await master_shot(app, 28)
	await click(app, grab.ask_button)
	helper.check(app.ui.screen == "grab_ask" and app.day == 4 and app.minute_of_day == asks_at, "Salma asks the next day without moving the clock")
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size() + 1, "all masters and the extra Faris movement frame were captured")
	finish(app)

func stage_board(app: Node3D) -> void:
	app.player.position = app.world.point("board")
	app.clock.reset()
	app.clock.skip_to(3, 600)
	app.show_screen("market_map")

func choose(app: Node3D, id: String) -> void:
	var choice: Dictionary = app.chapter.grab.answers[id]
	var trust: int = app.progress.trust
	var coins: int = app.progress.coins
	await click(app, choice.button)
	helper.check(app.ui.screen == "grab_after" and app.bread_grab.answer_id == id, "native answer opens the correct outcome: " + id)
	helper.check(app.progress.trust == trust + int(choice.trust) and app.progress.coins == coins + int(choice.coins), "locked trust and coin change: " + id)
	await master_shot(app, AFTER_MASTERS[id])

func master_shot(app: Node3D, number: int) -> void:
	await capture_state(app, MASTER_STEMS[number - 17] + "__build.png")

func capture_state(app: Node3D, filename: String) -> void:
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.answer = app.bread_grab.answer_id
	if app.ui.screen == "reputation":
		state.lines = app.ui.reputation_lines()
	if app.ui.screen == "grab_see":
		var faris: Node3D = app.world.faris_at_oven
		state.faris_visible = faris.is_visible_in_tree()
		state.faris_position = [faris.position.x, faris.position.y, faris.position.z]

func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE10_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("BREAD GRAB NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
