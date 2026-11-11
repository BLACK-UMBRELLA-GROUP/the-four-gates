extends "res://tests/capture_identity.gd"
## DOC-TFG-0071: native viewport evidence for LOCK 20.

const OUTPUT := "res://../GAME/APPROVED/IFTAR_GIVING/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/IFTAR_GIVING/RECORD/iftar_giving_data_V1.json"
const MASTER_STEMS := [
	"v01_masjid__pay_for_iftar_1640",
	"v02_ifeed__before_page_1",
	"v03_ifeed__public_dates",
	"v04_ifeed__soup_same_day",
	"v05_people_say__feeds_the_fasting",
	"v06_ifeed__secret_ticked",
	"v07_ifeed__secret_dates",
	"v08_ifeed__not_enough_coins",
	"v09_masjid__after_maghrib_no_button",
	"v10_masjid__shaban_no_button",
]
const FIRST_RAMADAN_DAY := 30
const MASTER_MINUTE := 1000
const STARTING_COINS := 198
const STARTING_TRUST := 45

var giving_data: Dictionary
var copy: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--iftar-giving-output="):
			return argument.trim_prefix("--iftar-giving-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Iftar giving capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the iftar giving evidence directory")
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
	helper.report.method = "Native Godot viewport. Real viewport clicks drive fair arrivals, panel entry, payments, the scholar's first page and What people say."
	helper.report.fixture = "Fair arrivals provide 198 coins. Trust is set to 45, and only v08 changes the wallet to three coins. Passive clock ticks are paused. The real player is staged at the named marker, and the clock skips to the fixture time with skipped prayer windows excluded. Day 29 is Thursday 29 Sha'ban and day 30 is Friday 1 Ramadan. Payments and the scholar page create the captured meal, trust and secrecy states through the live controls."
	app.set_process(false)
	if not helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/iftar_giving.json"), "runtime iftar giving data matches the locked bytes"):
		finish(app)
		return
	giving_data = app.iftar_giving.data
	copy = giving_data.panel
	var dates: Dictionary = giving_data.options[0]
	var soup: Dictionary = giving_data.options[1]
	var start: int = int(giving_data.numbers.from)
	var end: int = int(giving_data.numbers.until)

	await arrive(app)
	stage(app, FIRST_RAMADAN_DAY - 1, MASTER_MINUTE, "masjid")
	check_button(app, giving_data.masjid_button, false)
	check_button(app, app.clock.prayer_label(true))
	await capture_state(app, 9)
	stage(app, FIRST_RAMADAN_DAY, end, "masjid")
	check_button(app, giving_data.masjid_button, false)
	check_button(app, app.ramadan.data.iftar_button)
	stage(app, FIRST_RAMADAN_DAY, end + 10, "masjid")
	check_button(app, giving_data.masjid_button, false)
	check_button(app, app.clock.prayer_label(true))
	check_button(app, app.ramadan.data.iftar_button)
	await capture_state(app, 8)

	await arrive(app)
	stage(app, FIRST_RAMADAN_DAY, start - 1, "masjid")
	check_button(app, giving_data.masjid_button, false)
	stage(app, FIRST_RAMADAN_DAY, start, "board")
	check_button(app, giving_data.masjid_button, false)
	stage(app, FIRST_RAMADAN_DAY, start, "masjid")
	check_button(app, giving_data.masjid_button)
	stage(app, FIRST_RAMADAN_DAY, MASTER_MINUTE, "masjid")
	var prayer := check_button(app, app.clock.prayer_label(true))
	var give := check_button(app, giving_data.masjid_button)
	var fasting_text: String = app.ramadan.fasting_line()
	var fasting := expect_label(app, fasting_text)
	if prayer != null and give != null and fasting != null:
		helper.check(reads_before(prayer, give) and reads_before(give, fasting), "the Masjid prayer precedes Pay for iftar, which precedes the fasting line")
	await capture_state(app, 0)
	await click(app, giving_data.masjid_button)
	check_panel(app, copy.intro, 0)
	check_choice(app, false, false)
	await capture_state(app, 1)

	await click(app, pay_caption(dates))
	check_panel(app, copy.done_public, 20)
	check_accounts(app, 194, 46)
	await capture_state(app, 2)
	await click(app, pay_caption(soup))
	check_panel(app, copy.done_public, 70)
	check_accounts(app, 179, 46)
	await capture_state(app, 3)
	await click(app, copy.back)
	helper.check(app.ui.screen == "market_map" and app.current_place == "masjid", "Back returns to the Masjid on the market map")
	await click(app, app.chapter.purse.morning.to_rep)
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [giving_data.say.feeds], "two public payments show one locked iftar reputation line")
	var iftar_line: Array = giving_data.say.feeds
	expect_label(app, "“%s”" % iftar_line[0])
	expect_label(app, str(iftar_line[1]).to_upper())
	expect_label(app, app.chapter.rep.tone[str(int(iftar_line[2]))])
	await capture_state(app, 4)
	await click(app, app.chapter.rep.to_map)
	await click(app, giving_data.masjid_button)
	check_panel(app, copy.intro, 70)
	await click(app, copy.back)

	stage(app, FIRST_RAMADAN_DAY, MASTER_MINUTE, "board")
	await click(app, app.feeding.data.place_button)
	expect_label(app, "MEALS FOR THE POOR: 70 / 10,000")
	var bread: Dictionary = app.feeding.data.options[0]
	await click(app, str(app.feeding.data.panel.pay).format({"n": int(bread.cost)}))
	helper.check(app.iftar_giving.meals_given == 70 + int(bread.meals), "ordinary feeding updates the same live meal total")
	await click(app, app.feeding.data.panel.back)
	await click(app, app.chapter.purse.morning.to_rep)
	var ordinary_label := expect_label(app, "“%s”" % app.feeding.data.say.feeds[0])
	var iftar_label := expect_label(app, "“%s”" % iftar_line[0])
	var reputation: Array = app.ui.reputation_lines()
	var ordinary_index := reputation.find(app.feeding.data.say.feeds)
	helper.check(ordinary_index >= 0 and reputation.find(iftar_line) == ordinary_index + 1, "the two feeding reputation lines are consecutive in the approved order")
	if ordinary_label != null and iftar_label != null:
		helper.check(ordinary_label.global_position.y < iftar_label.global_position.y, "What people say renders the ordinary feeding line above the iftar line")
	await click(app, app.chapter.rep.to_map)
	stage(app, FIRST_RAMADAN_DAY, end - 1, "masjid")
	check_button(app, giving_data.masjid_button)
	await click(app, giving_data.masjid_button)
	check_panel(app, copy.intro, 70 + int(bread.meals))
	await click(app, copy.back)

	await arrive(app)
	stage(app, FIRST_RAMADAN_DAY, 600, "inn")
	await click(app, app.chapter.places.inn)
	await click(app, app.chapter.purse.ask_baker)
	await click(app, str(app.chapter.purse.take_page).format({"teacher": app.chapter.teacher}))
	helper.check(app.ui.screen == "purse_page" and app.known_words.has("sirr"), "the real first scholar page unlocks the secret option")
	await click(app, app.chapter.page.back)
	await click(app, app.chapter.purse.not_now)
	stage(app, FIRST_RAMADAN_DAY, MASTER_MINUTE, "masjid")
	await click(app, giving_data.masjid_button)
	check_panel(app, copy.intro, 0)
	check_choice(app, true, false)
	await click(app, copy.secret_label)
	check_choice(app, true, true)
	await capture_state(app, 5)
	await click(app, pay_caption(dates))
	check_panel(app, copy.done_secret, 20)
	check_choice(app, true, true)
	check_accounts(app, 194, 45)
	helper.check(app.ui.reputation_lines().is_empty(), "the secret payment adds no public line")
	await capture_state(app, 6)
	await click(app, copy.back)

	await arrive(app)
	app.progress.coins = 3
	stage(app, FIRST_RAMADAN_DAY, MASTER_MINUTE, "masjid")
	await click(app, giving_data.masjid_button)
	check_panel(app, copy.intro, 0)
	check_choice(app, false, false)
	var warnings := visible_labels(app.ui.content, copy.not_enough)
	if helper.check(warnings.size() == giving_data.options.size(), "both unavailable options show the locked insufficient-coins words"):
		for warning: Control in warnings:
			helper.check(app.get_viewport().get_visible_rect().encloses(warning.get_global_rect()), "insufficient-coins text fits the viewport")
			await hit(app, warning.get_global_rect().get_center())
	check_accounts(app, 3, 45)
	helper.check(app.iftar_giving.meals_given == 0 and app.ui.reputation_lines().is_empty(), "the unaffordable options leave meals and reputation unchanged")
	await capture_state(app, 7)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all ten master states have native captures")
	finish(app)


func arrive(app: Node3D) -> void:
	app.show_screen("title")
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	app.clock.reset()
	app.progress.apply_trust(STARTING_TRUST - app.progress.trust)
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "fair arrival opens the live Inn map")
	check_accounts(app, STARTING_COINS, STARTING_TRUST)
	helper.check(app.iftar_giving.meals_given == 0 and not app.known_words.has("sirr"), "a new arrival resets the shared meal count and the scholar page")


func stage(app: Node3D, day: int, minute: int, place: String) -> void:
	app.clock.skip_to(day, minute)
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()
	helper.check(app.ui.screen == "market_map" and app.current_place == place, "live market map at " + place)
	helper.check(app.day == day and app.minute_of_day == minute, "capture clock is at day %d minute %d" % [day, minute])


func check_accounts(app: Node3D, coins: int, trust: int) -> void:
	helper.check(app.progress.coins == coins and app.progress.trust == trust, "wallet %d and trust %d match the locked state" % [coins, trust])


func check_panel(app: Node3D, message: String, meals: int) -> void:
	helper.check(app.ui.screen == "iftar_giving", "the native iftar giving panel is open")
	expect_label(app, str(copy.kicker).to_upper())
	expect_label(app, copy.title)
	expect_label(app, message)
	for option: Dictionary in giving_data.options:
		expect_label(app, option.name)
		expect_label(app, option.line)
		check_button(app, pay_caption(option), app.progress.coins >= int(option.cost))
	expect_label(app, str(copy.counter).format({"n": meals, "m": "10,000"}).to_upper())
	helper.check(app.iftar_giving.meals_given == meals and app.feeding.meals_given == meals, "the live iftar and ordinary feeding counters both contain %d meals" % meals)
	check_button(app, copy.back)


func check_choice(app: Node3D, unlocked: bool, ticked: bool) -> void:
	var checkbox := check_button(app, copy.secret_label, unlocked)
	helper.check((checkbox is CheckBox) == unlocked and (checkbox == null or checkbox.button_pressed == ticked), "the secret checkbox matches the first-page unlock and tick state")
	expect_label(app, str(copy.secret_locked).to_upper(), not unlocked)
	expect_label(app, str(copy.secret_on).to_upper(), ticked)


func pay_caption(option: Dictionary) -> String:
	return str(copy.pay).format({"n": int(option.cost)})


func check_button(app: Node3D, caption: String, expected: bool = true) -> Button:
	var button := helper.find_button(app.ui, caption)
	helper.check((button != null) == expected and not caption.is_empty(), "button %s: %s" % ["shown" if expected else "hidden", caption])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits the viewport: " + caption)
	return button


func expect_label(app: Node3D, value: String, expected: bool = true) -> Control:
	var labels := visible_labels(app.ui.content, value)
	helper.check(labels.is_empty() != expected and not value.is_empty(), "locked text %s: %s" % ["shown" if expected else "hidden", value])
	if labels.is_empty():
		return null
	var label: Control = labels[0]
	helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "text fits the viewport: " + value)
	return label


func visible_labels(node: Node, value: String) -> Array[Control]:
	var labels: Array[Control] = []
	if node is Control and not node.is_visible_in_tree():
		return labels
	if (node is Label and node.text == value) or (node is RichTextLabel and node.get_parsed_text() == value):
		labels.append(node)
	for child in node.get_children():
		labels.append_array(visible_labels(child, value))
	return labels


func reads_before(first: Control, second: Control) -> bool:
	var a := first.get_global_rect()
	var b := second.get_global_rect()
	return a.end.y <= b.position.y or (a.position.y < b.end.y and b.position.y < a.end.y and a.end.x <= b.position.x)


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.date = app.clock.date_label(app.day)
	state.meals_given = app.iftar_giving.meals_given
	state.knows_sirr = app.known_words.has("sirr")
	state.secret_selected = app.iftar_giving.secret_selected
	state.what_people_say = app.ui.reputation_lines()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE27_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("IFTAR GIVING NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
