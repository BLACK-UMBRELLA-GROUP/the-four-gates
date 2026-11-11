extends "res://tests/capture_identity.gd"
## DOC-TFG-0113: native Journal captures for the reissued LOCK 34 V1 targets.

const OUTPUT := "res://../GAME/APPROVED/SCENE_RUNNER/BUILT/V1/"
const MASTER_STEMS := ["sr01_journal__empty", "sr02_journal__progress"]
const THURSDAY := 8
const MASTER_MINUTE := 600


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Journal evidence requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Journal evidence directory")
		app.get_tree().quit(1)
		return
	app.get_tree().auto_accept_quit = false
	app.get_tree().root.close_requested.connect(func():
		helper.check(false, "the native capture stayed open")
		finish(app)
	)
	helper.report.erase("fps")
	helper.report.engine = Engine.get_version_info().string
	helper.report.timestamp_utc = Time.get_datetime_string_from_system(true) + "Z"
	helper.report.renderer = RenderingServer.get_current_rendering_method()
	helper.report.driver = RenderingServer.get_current_rendering_driver_name()
	helper.report.gpu = RenderingServer.get_video_adapter_name()
	helper.report.resolution = [1920, 1080]
	helper.report.method = "Real native viewport. Mouse clicks use the production arrival, Journal, open purse, bread grab, honest board task and sealed-purse controls."
	helper.report.fixture = "Fair arrival. Passive game ticks paused. Only location, facing and time are set for the capture. The completions, trust, coins, and counters all come from gameplay. The Journal is captured at 10:00 on Thursday 8 and 15 Sha'ban."
	app.set_process(false)

	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	helper.check(app.ui.screen == "market_map" and app.progress.coins == 198, "fresh fair arrival opens River Market")
	app.clock.skip_to(THURSDAY, MASTER_MINUTE)
	place_player(app, "inn")
	await capture_journal(app, 0, [])

	var purse: Dictionary = app.chapter.purse
	await click(app, app.chapter.places.inn)
	await click(app, str(purse.give).format({"n": int(purse.people[0].cost)}))
	await click(app, purse.end_day)
	await click(app, purse.morning.to_map)
	helper.check(app.open_purse.done, "the open purse is completed through End the day")

	var grab: Dictionary = app.chapter.grab
	app.clock.skip_to(THURSDAY + 2, MASTER_MINUTE)
	place_player(app, "board")
	await click(app, app.chapter.places.board)
	await click(app, grab.see.next)
	app.clock.advance_to(app.day, int(app.chapter.numbers.grab_ask_minute), false)
	app.update_state()
	await click(app, grab.ask_button)
	await click(app, grab.answers.truth.button)
	await click(app, grab.after.to_map)
	helper.check(app.bread_grab.answer_id == "truth", "the bread grab is completed by telling Salma")

	await click(app, app.data.ui.place_actions.board)
	var task: Dictionary = app.data.tasks[0]
	await click(app, str(app.data.ui.buttons.take_task).format({"n": int(task.pay_shown)}))
	await click(app, task.honest.choice)
	await click(app, app.data.ui.buttons.back_to_board)
	await click(app, app.data.ui.buttons.back_to_market_map)

	var sealed: Dictionary = app.sealed_purse.data
	app.clock.skip_to(THURSDAY + 7, MASTER_MINUTE)
	place_player(app, "quay")
	await click(app, sealed.quay_button)
	await click(app, sealed.offer.accept)
	await click(app, sealed.coin.back_in)
	place_player(app, "gate")
	await click(app, sealed.gate_button)
	await click(app, sealed.deliver.to_map)
	helper.check(app.scene_runner.mission_done(app, "sealed_purse"), "the real whole sealed-purse delivery is complete")
	helper.check(not app.progress.gate_open, "the Gate of Trust is still closed")
	place_player(app, "inn")
	var titles: Dictionary = app.scene_runner.data.chapter_builtin
	await capture_journal(app, 1, [titles.purse, titles.grab, titles.sealed_purse])
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "both approved line 41 targets captured")
	finish(app)


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--scene-runner-output="):
			return argument.trim_prefix("--scene-runner-output=")
	return OUTPUT


func place_player(app: Node3D, place: String) -> void:
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	var toward: Vector3 = app.world.point("gate") - app.player.position
	if toward.length_squared() > 0.0:
		app.player.yaw = atan2(-toward.x, -toward.z)
	app.player.update_camera()
	app.update_state()


func capture_journal(app: Node3D, target: int, expected_titles: Array) -> void:
	var copy: Dictionary = app.scene_runner.data.words.journal
	await click(app, app.scene_runner.data.words.journal_button)
	if not helper.check(app.ui.screen == "journal", "Journal opens from the live River Market bar"):
		return
	var snapshot: Dictionary = app.scene_runner.journal(app)
	var actual_titles: Array = []
	for row: Dictionary in snapshot.chapters[0].rows:
		if row.done:
			actual_titles.append(row.title)
	helper.check(snapshot.chapters.size() == 1 and snapshot.chapters[0].n == 1, "only Chapter 1 is loaded")
	helper.check(snapshot.chapters[0].total == 7 and actual_titles == expected_titles, "the built completions agree with the approved target")
	helper.check(snapshot.side == {"done": 0, "total": 0}, "there are no loaded side missions")
	var chapter_name := str(copy.chapter).format({"n": 1, "name": snapshot.chapters[0].name})
	var chapter_count := str(copy.count).format({"n": expected_titles.size(), "m": 7})
	for label: String in [str(copy.kicker).to_upper(), copy.title, str(copy.main).to_upper(),
			chapter_name, chapter_count, copy.side, "0 / 0", str(copy.goals).to_upper()]:
		helper.check(visible_label_count(app.ui, label) == 1, "visible locked Journal label: " + label)
	for title: String in expected_titles:
		helper.check(visible_label_count(app.ui, title) == 1, "completed title visible: " + title)
	var hidden := 7 - expected_titles.size()
	helper.check(visible_label_count(app.ui, "…") == hidden and visible_label_count(app.ui, copy.not_yet) == hidden,
		"every undiscovered mission has one ellipsis and one locked status")
	helper.check(visible_label_count(app.ui, copy.done) == expected_titles.size(), "the correct number of completed statuses are visible")
	for goal: Dictionary in snapshot.goals:
		helper.check(goal.n == 0 and visible_label_count(app.ui, goal.label) == 1
			and visible_label_count(app.ui, str(copy.count).format(goal)) == 1, "visible goal from real game state: " + goal.label)
	var filename: String = MASTER_STEMS[target] + "__build.png"
	await shot(app, filename)
	helper.report.states[filename].journal = snapshot
	helper.report.states[filename].day = app.day
	helper.report.states[filename].minute = app.minute_of_day
	await click(app, copy.back)
	helper.check(app.ui.screen == "market_map", "Back returns to the River Market map")


func visible_label_count(node: Node, value: String) -> int:
	if node is Control and not node.is_visible_in_tree():
		return 0
	var count := int(node is Label and node.text == value)
	for child: Node in node.get_children():
		count += visible_label_count(child, value)
	return count


func finish(app: Node3D) -> void:
	helper.report.failures = helper.failures
	var file := FileAccess.open(output.path_join("LINE41_CHECKS.json"), FileAccess.WRITE)
	if file == null:
		app.get_tree().quit(1)
		return
	file.store_string(JSON.stringify(helper.report, "\t") + "\n")
	file.close()
	print("SCENE RUNNER NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
