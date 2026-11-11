extends "res://tests/capture_identity.gd"
## DOC-TFG-0019: native viewport evidence for the 16 LOCK 3 V2 part 1 masters.

const OUTPUT := "res://../GAME/APPROVED/CHAPTER_1/BUILT/V1/"
const MASTER_STEMS := [
	"c01_market_map__inn_people_waiting",
	"c02_purse__door_start",
	"c03_purse__gave_in_public",
	"c04_purse__salma",
	"c05_page_1__giving_in_secret",
	"c06_purse__secret_and_widow",
	"c07_purse__not_enough_coins",
	"c08_morning__public_and_liar",
	"c09_people_say__gives_and_fooled",
	"c10_morning__in_secret",
	"c11_people_say__secret_note",
	"c12_morning__widow_in_public",
	"c13_morning__gave_nothing",
	"c14_people_say__purse_shut",
	"c15_people_say__empty",
	"c16_people_say__lock1_lines",
]
var wallet: int

static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--open-purse-output="):
			return argument.trim_prefix("--open-purse-output=")
	return OUTPUT

func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the open-purse evidence directory")
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
	helper.report.method = "Native Godot viewport. Production GUI buttons receive viewport-local mouse clicks. Passive clock ticks are paused."
	helper.report.fixture = "Fair arrival sets the wallet. Later-day fixtures run on Saturday at 10:00 with no outstanding prayers. c07 sets five coins. c16 earns the LOCK 1/2 states with their live wallet and trust."
	app.set_process(false)

	var purse: Dictionary = app.chapter.purse
	var rep: Dictionary = app.chapter.rep
	var arrival: Dictionary = app.identity.arrival
	await click(app, app.data.ui.buttons.begin)
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	wallet = app.progress.coins
	helper.check(app.current_place == "inn" and wallet == 198, "fair arrival opens the Inn map with 198 coins")
	set_market_time(app)
	face_place(app, "quay")
	await master_shot(app, 1)
	await click(app, app.chapter.places.inn)
	await master_shot(app, 2)
	await gift(app, purse.people[0])
	await master_shot(app, 3)
	helper.check(app.progress.coins == wallet - 10 and app.progress.trust == 22, "public Yusuf gift spends 10 and adds two trust")
	await click(app, purse.ask_baker)
	await master_shot(app, 4)
	helper.check(app.open_purse.visible_people().size() == 4, "Salma reveals Umm Salim")
	await read_page(app)
	await master_shot(app, 5)
	helper.check(app.current_place == "masjid" and app.known_words.has("sirr"), "Idris reads at the Masjid and teaches sirr")
	await click(app, app.chapter.page.back)
	await master_shot(app, 6)
	helper.check(app.current_place == "inn", "page returns to the people at the Inn")
	await gift(app, purse.people[1])
	await gift(app, purse.people[2])
	await click(app, purse.end_day)
	await master_shot(app, 8)
	helper.check(app.day == 4 and app.minute_of_day == 420 and app.open_purse.morning_lines().size() == 4, "End the day shows next morning at 07:00 with the four public gift lines")
	helper.check(app.clock.make_up_label().is_empty(), "prayers ending during End the day are not counted")
	await click(app, purse.morning.to_rep)
	await master_shot(app, 9)
	helper.check(app.open_purse.reputation_lines() == [rep.gives, rep.fooled], "public Tariq triggers the two ordered reputation lines")
	await click(app, rep.to_map)
	helper.check(app.current_place == "inn" and helper.find_button(app.ui, app.chapter.places.inn) == null, "finished purse no longer opens from the Inn")

	reset_market(app)
	await click(app, app.chapter.places.inn)
	await click(app, purse.ask_baker)
	await read_page(app)
	await click(app, app.chapter.page.back)
	app.progress.coins = 5
	app.update_state()
	await master_shot(app, 7)
	helper.check(helper.find_button(app.ui, public_gift(purse, purse.people[2])) == null, "unaffordable public Tariq gift has no button")

	reset_market(app)
	await click(app, app.chapter.places.inn)
	await click(app, purse.ask_baker)
	await read_page(app)
	await click(app, app.chapter.page.back)
	await gift(app, purse.people[0], true)
	await gift(app, purse.people[3], true)
	await click(app, purse.end_day)
	await master_shot(app, 10)
	helper.check(app.progress.coins == 180 and app.progress.trust == 20, "two secret gifts deduct only the locked costs")
	await click(app, purse.morning.to_rep)
	await master_shot(app, 11)

	reset_market(app)
	await click(app, app.chapter.places.inn)
	await click(app, purse.ask_baker)
	await click(app, purse.baker.back)
	await gift(app, purse.people[3])
	await click(app, purse.end_day)
	await master_shot(app, 12)
	helper.check(app.open_purse.reputation_lines() == [rep.gives, rep.widow_public], "public Umm Salim triggers the ordered good and bad lines")

	reset_market(app)
	await click(app, purse.morning.to_rep)
	await master_shot(app, 15)
	await click(app, rep.to_map)
	await click(app, app.chapter.places.inn)
	await click(app, purse.not_now)
	helper.check(helper.find_button(app.ui, app.chapter.places.inn) != null, "Not now returns to the map with the door still open")
	await click(app, app.chapter.places.inn)
	await click(app, purse.end_day)
	await master_shot(app, 13)
	await click(app, purse.morning.to_rep)
	await master_shot(app, 14)

	reset_market(app)
	var tasks: Array = app.data.tasks
	app.progress.choose_task(tasks[0].id, "honest")
	app.progress.choose_task(tasks[1].id, "quick")
	app.progress.amend_task(tasks[1].id)
	app.progress.choose_task(tasks[2].id, "honest")
	app.progress.do_daily_job()
	app.progress.try_weight(int(app.data.lesson.false_weight_index))
	app.progress.answer_weight()
	app.clock.reset()
	app.clock.skip_to(3, 285)
	app.player.position = app.world.point("masjid")
	app.update_state()
	app.pray_here()
	app.clock.advance_to(3, 600, false)
	app.show_screen("market_map")
	await click(app, purse.morning.to_rep)
	await master_shot(app, 16)
	helper.check(app.open_purse.reputation_lines().size() == 6, "c16 has all six ordered foundation, boat, scales and congregation rows")
	await click(app, rep.to_goal)
	helper.check(app.ui.screen == "goal", "reputation opens the LOCK 1 goal panel")

	reset_market(app)
	await click(app, app.chapter.places.inn)
	await click(app, purse.ask_baker)
	await read_page(app)
	await click(app, app.chapter.page.back)
	await gift(app, purse.people[2], true)
	await click(app, purse.end_day)
	helper.check(app.progress.coins == 178 and app.progress.trust == 20, "secret Tariq costs 20 and leaves trust at 20")
	helper.check(app.open_purse.morning_lines() == [purse.morning.quiet] and app.open_purse.reputation_lines().is_empty() and app.open_purse.has_secret_gift(), "secret Tariq produces only the quiet morning and secret-note state")
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all 16 master captures were saved")
	reset_market(app)
	app.show_screen("game")
	await shot(app, "inn_door_people__build.png")
	app.player.position = app.world.point("board")
	face_place(app, app.data.square.centre)
	app.update_state()
	await shot(app, "salma_at_the_oven__build.png")
	finish(app)

func set_market_time(app: Node3D) -> void:
	app.clock.reset()
	app.clock.skip_to(3, 600)
	app.update_state()

func reset_market(app: Node3D) -> void:
	app.begin_game()
	app.progress.coins = wallet
	app.player.position = app.world.point("inn")
	set_market_time(app)
	face_place(app, "quay")
	app.show_screen("market_map")

func face_place(app: Node3D, place: String) -> void:
	var toward: Vector3 = app.world.point(place) - app.player.position
	app.player.yaw = atan2(-toward.x, -toward.z)
	app.player.update_camera()

func read_page(app: Node3D) -> void:
	await click(app, str(app.chapter.purse.take_page).format({"teacher": app.chapter.teacher}))

func public_gift(purse: Dictionary, person: Dictionary) -> String:
	return str(purse.give).format({"n": int(person.cost)})

func gift(app: Node3D, person: Dictionary, secret: bool = false) -> void:
	var label := public_gift(app.chapter.purse, person)
	if not secret:
		await click(app, label)
		return
	var public_button := helper.find_button(app.ui, label)
	if not helper.check(public_button != null, "found public gift on the same row: " + label):
		return
	for button: Node in public_button.get_parent().get_children():
		if button is Button and button.text == app.chapter.purse.give_secret and button.position.y == public_button.position.y:
			await hit(app, button.get_global_rect().get_center())
			helper.check(app.open_purse.gift_status(person.id) == "secret", "native secret button gave to " + str(person.id))
			return
	helper.check(false, "secret gift button on the same row: " + label)

func master_shot(app: Node3D, number: int) -> void:
	var filename: String = MASTER_STEMS[number - 1] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.page_read = app.open_purse.page_read
	state.purse_done = app.open_purse.done
	if app.ui.screen == "purse_morning":
		state.lines = app.open_purse.morning_lines()
	elif app.ui.screen == "reputation":
		state.lines = app.open_purse.reputation_lines()
		state.secret_note = app.open_purse.has_secret_gift()

func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("OPEN PURSE NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
