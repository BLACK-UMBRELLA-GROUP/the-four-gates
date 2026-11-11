extends "res://tests/capture_identity.gd"
## DOC-TFG-0038: native viewport evidence for the eight LOCK 9 V1 masters.

const OUTPUT := "res://../GAME/APPROVED/FEEDING/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/FEEDING/RECORD/feeding_data_V1.json"
const MASTER_STEMS := [
	"e01_square__feed_the_poor",
	"e02_feed__start",
	"e03_feed__public",
	"e04_feed__secret_choice",
	"e05_feed__secret",
	"e06_feed__not_enough_coins",
	"e07_people_say__feeds_the_poor",
	"e08_square__night_no_feeding",
]
const SATURDAY := 3
const MORNING := 600
const NIGHT := 1200

var feeding_data: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--feeding-output="):
			return argument.trim_prefix("--feeding-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Feeding capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the feeding evidence directory")
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
	helper.report.method = "Real native Godot viewport. Viewport clicks exercise arrival, feeding, the scholar's first page and the reputation panel."
	helper.report.fixture = "Passive clock ticks are paused. Three fair arrivals provide the starting wallet and trust. The harness places the player at the Inn or Task board on Saturday day 3, using 10:00 for the daytime cases and 20:00 for e08. Only e06 seeds a four-coin wallet."
	app.set_process(false)
	feeding_data = app.feeding.data
	helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/feeding.json"), "runtime feeding data matches the locked bytes")

	await complete_arrival(app)
	if not helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival opens the Inn market map"):
		finish(app)
		return
	var copy: Dictionary = feeding_data.panel
	var ten: Dictionary = feeding_data.options[0]
	var fifty: Dictionary = feeding_data.options[1]
	var starting_coins: int = app.progress.coins
	var starting_trust: int = app.progress.trust
	stage(app, MORNING, "board")
	helper.check(app.day == SATURDAY and app.minute_of_day == MORNING and not app.clock.is_friday() and app.current_place == "board", "daytime fixture reaches the Task board on a later non-Friday at 10:00")
	check_bar_order(app)
	await capture_state(app, 0)
	await click(app, feeding_data.place_button)
	check_panel(app, copy.intro, "0")
	check_secret_choice(app, false, false)
	expect_label(app, copy.secret_locked.to_upper(), true)
	await capture_state(app, 1)

	await click(app, pay_caption(ten))
	check_panel(app, copy.done_public, str(int(ten.meals)))
	helper.check(app.progress.coins == starting_coins - int(ten.cost), "public payment spends the locked ten-loaf price")
	helper.check(app.progress.trust == starting_trust + int(feeding_data.numbers.trust_per_day), "first public payment earns the locked daily trust amount")
	await capture_state(app, 2)
	await click(app, copy.back)
	await click(app, app.chapter.purse.morning.to_rep)
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [feeding_data.say.feeds], "public feeding shows only the locked Salma reputation row in this fixture")
	expect_label(app, "“%s”" % feeding_data.say.feeds[0], true)
	expect_label(app, str(feeding_data.say.feeds[1]).to_upper(), true)
	await capture_state(app, 6)
	await click(app, app.chapter.rep.to_map)

	await restart_from_title(app)
	helper.check(app.progress.coins == starting_coins and app.progress.trust == starting_trust and app.feeding.meals_given == 0, "a new game starts a fresh feeding record")
	stage(app, MORNING, "inn")
	await click(app, app.chapter.places.inn)
	await click(app, app.chapter.purse.ask_baker)
	await click(app, str(app.chapter.purse.take_page).format({"teacher": app.chapter.teacher}))
	helper.check(app.ui.screen == "purse_page" and app.known_words.has("sirr"), "the first scholar page teaches sirr through the live controls")
	await click(app, app.chapter.page.back)
	await click(app, app.chapter.purse.not_now)
	stage(app, MORNING, "board")
	await click(app, feeding_data.place_button)
	check_panel(app, copy.intro, "0")
	check_secret_choice(app, true, false)
	expect_label(app, copy.secret_locked.to_upper(), false)
	expect_label(app, copy.secret_on.to_upper(), false)
	await capture_state(app, 3)
	await click(app, copy.secret_label)
	check_secret_choice(app, true, true)
	expect_label(app, copy.secret_on.to_upper(), true)
	await click(app, pay_caption(fifty))
	check_panel(app, copy.done_secret, str(int(fifty.meals)))
	check_secret_choice(app, true, true)
	expect_label(app, copy.secret_on.to_upper(), true)
	helper.check(app.progress.coins == starting_coins - int(fifty.cost) and app.progress.trust == starting_trust, "secret payment spends the locked fifty-loaf price without adding trust")
	helper.check(app.ui.reputation_lines().is_empty(), "secret feeding leaves no reputation row")
	await capture_state(app, 4)
	await click(app, copy.back)

	await restart_from_title(app)
	stage(app, NIGHT, "board")
	helper.check(app.ui.screen == "market_map" and app.current_place == "board" and app.minute_of_day == NIGHT and app.night, "night fixture reaches the same Task board at 20:00")
	helper.check(helper.find_button(app.ui, feeding_data.place_button) == null, "feeding button is hidden while Salma is away")
	expect_label(app, app.market_day.talk_notice("salma", app.market_day.status("salma")), true)
	await capture_state(app, 7)

	stage(app, MORNING, "board")
	app.progress.coins = 4
	app.update_state()
	await click(app, feeding_data.place_button)
	check_panel(app, copy.intro, "0", false)
	expect_label(app, copy.not_enough, true)
	check_secret_choice(app, false, false)
	await capture_state(app, 5)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all eight master states were captured")
	finish(app)


func complete_arrival(app: Node3D) -> void:
	var arrival: Dictionary = app.identity.arrival
	await click(app, app.data.ui.buttons.begin)
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])


func restart_from_title(app: Node3D) -> void:
	await click(app, app.data.ui.buttons.city_map)
	await click(app, app.identity.ui.world_map)
	await click(app, app.identity.ui.title_back)
	await complete_arrival(app)


func stage(app: Node3D, minute: int, place: String) -> void:
	app.clock.reset()
	app.clock.skip_to(SATURDAY, minute)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()


func check_bar_order(app: Node3D) -> void:
	var feed := helper.find_button(app.ui, feeding_data.place_button)
	var grab := helper.find_button(app.ui, app.chapter.places.board)
	var talk := helper.find_button(app.ui, app.talking.button_at("board"))
	helper.check(feed != null and grab != null and talk != null, "daytime board shows feeding, bread grab and Salma's talk controls")
	if feed != null and grab != null and talk != null:
		var feed_rect := feed.get_global_rect()
		helper.check(feed_rect.position.x < grab.get_global_rect().position.x and feed_rect.position.x < talk.get_global_rect().position.x, "feeding sits before bread grab and Salma's talk")
		helper.check(app.get_viewport().get_visible_rect().encloses(feed_rect), "feeding button fits in the native viewport")


func check_panel(app: Node3D, intro: String, count: String, affordable: bool = true) -> void:
	var copy: Dictionary = feeding_data.panel
	helper.check(app.ui.screen == "feeding", "feeding panel is open")
	expect_label(app, copy.kicker.to_upper(), true)
	expect_label(app, copy.title, true)
	expect_label(app, intro, true)
	for option: Dictionary in feeding_data.options:
		expect_label(app, option.name, true)
		expect_label(app, option.line, true)
		helper.check((helper.find_button(app.ui, pay_caption(option)) != null) == affordable, "payment button availability matches the wallet for " + str(option.id))
	var counter := str(copy.counter).format({"n": count, "m": "10,000"})
	expect_label(app, counter.to_upper(), true)
	helper.check(app.feeding.meals_given == int(count), "feeding counter reflects the live meal total")
	helper.check(helper.find_button(app.ui, copy.back) != null, "feeding panel offers the locked Back button")


func check_secret_choice(app: Node3D, visible: bool, ticked: bool) -> void:
	var box: Button = helper.find_button(app.ui, feeding_data.panel.secret_label)
	helper.check((box is CheckBox) == visible and (box == null or box.button_pressed == ticked), "secret checkbox visibility and tick state match the page and choice")


func pay_caption(option: Dictionary) -> String:
	return str(feeding_data.panel.pay).format({"n": int(option.cost)})


func expect_label(app: Node3D, value: String, visible: bool) -> void:
	var label := find_label(app.ui, value)
	helper.check((label != null) == visible, "%s %s" % [value, "shown" if visible else "hidden"])
	if label != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "label fits in viewport: " + value)


func find_label(node: Node, value: String) -> Control:
	if node is Control and not node.is_visible_in_tree():
		return null
	if (node is Label and node.text == value) or (node is RichTextLabel and node.get_parsed_text() == value):
		return node
	for child in node.get_children():
		var label := find_label(child, value)
		if label != null:
			return label
	return null


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.meals_given = app.feeding.meals_given
	state.knows_sirr = app.known_words.has("sirr")


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE16_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("FEEDING NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
