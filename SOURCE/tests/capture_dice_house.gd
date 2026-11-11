extends "res://tests/capture_identity.gd"
## DOC-TFG-0044: real native viewport states for LOCK 11 V1.

const OUTPUT := "res://../GAME/APPROVED/DICE_HOUSE/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/DICE_HOUSE/RECORD/dice_house_data_V1.json"
const MASTER_STEMS := [
	"x01_inn__daytime_no_door",
	"x02_inn__after_isha_whisper",
	"x03_dice__mansur_invites",
	"x04_dice__first_night",
	"x05_dice__won_10",
	"x06_dice__lost_20",
	"x07_dice__not_enough_coins",
	"x08_inn__door_with_blue_cloth",
	"x09_people_say__talk_2_nights",
	"x10_people_say__seen_4_nights",
	"x11_people_say__gambler_10_nights",
	"x12_inn__after_go_to_bed",
]
const SATURDAY := 3
const MORNING := 600
const EVENING := 1200

var dice: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--dice-house-output="):
			return argument.trim_prefix("--dice-house-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Dice House capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the Dice House evidence directory")
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
	helper.report.method = "Real native Godot viewport. Viewport-local clicks exercise arrival, Inn invitation, both choices, the door, Leave and What people say. The betting action uses forced boundary rolls for repeatable win and loss evidence."
	helper.report.fixture = "Passive clock ticks are paused. The harness places the player at the Inn on Saturday day 3, advances the real clock for later visits and sets starting trust to 45. The fair-arrival wallet is used through x06 and restored for x09-x11. For x07 the wallet is set to 27 before a real 20-coin loss leaves 7. For x09-x11 the fixture opens What people say from the lane towards the square at 10:00 the next day, after earning each threshold at night."
	app.set_process(false)
	dice = app.dice_house.data
	helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/dice_house.json"), "runtime dice data matches the locked bytes")

	await start_at_inn(app)
	var starting_coins: int = app.progress.coins
	if not helper.check(app.ui.screen == "market_map" and app.current_place == "inn" and app.day == SATURDAY and app.minute_of_day == MORNING, "daytime fixture starts at the Inn on a later non-Friday"):
		finish(app)
		return
	expect_inn_actions(app, false, false)
	await capture_state(app, 0)
	set_time(app, SATURDAY, EVENING)
	expect_inn_actions(app, true, false)
	await capture_state(app, 1)
	await click(app, dice.inn_invite)
	expect_invitation(app)
	await capture_state(app, 2)
	await click(app, dice.invite.go)
	expect_house(app, dice.house.text, 1)
	check_bet_buttons(app)
	helper.check(app.ui.reputation_lines().is_empty(), "one visit creates no talk")
	await capture_state(app, 3)

	var win := int(dice.numbers.win_chance_percent) - 1
	var loss := int(dice.numbers.win_chance_percent)
	app.bet_at_dice_house(10, win)
	expect_house(app, str(dice.house.won).format({"n": 10}), 1)
	helper.check(app.progress.coins == starting_coins + 10 and app.progress.trust == 45, "forced win adds ten coins and changes no trust")
	await capture_state(app, 4)
	app.bet_at_dice_house(20, loss)
	var lost: String = str(dice.house.lost).format({"n": 20})
	expect_house(app, lost, 1)
	helper.check(app.progress.coins == starting_coins - 10 and app.progress.trust == 45, "forced loss takes twenty coins and changes no trust")
	await capture_state(app, 5)
	app.progress.coins = 27
	app.bet_at_dice_house(20, loss)
	expect_house(app, lost, 1)
	check_bet_buttons(app)
	helper.check(app.progress.coins == 7 and count_labels(app.ui, dice.house.not_enough) == 2, "the 7-coin wallet replaces each unaffordable bet with the locked notice")
	await capture_state(app, 6)
	await click(app, dice.house.leave)
	expect_inn_actions(app, false, true)
	await capture_state(app, 7)

	app.progress.coins = starting_coins
	for visit in range(2, 11):
		set_time(app, SATURDAY + visit - 1, EVENING)
		await click(app, dice.inn_button)
		helper.check(app.ui.screen == "dice_house" and app.dice_house.nights == visit, "each later night counts once: %d" % visit)
		await click(app, dice.house.leave)
		match visit:
			2:
				await capture_talk(app, 8, dice.say.talk, 45)
			4:
				await capture_talk(app, 9, dice.say.seen, 45 + int(dice.numbers.seen_trust))
			10:
				await capture_talk(app, 10, dice.say.gambler, 45 + int(dice.numbers.seen_trust) + int(dice.numbers.gambler_trust))

	await start_at_inn(app, true)
	set_time(app, SATURDAY, EVENING)
	await click(app, dice.inn_invite)
	expect_invitation(app)
	await click(app, dice.invite.no)
	expect_inn_actions(app, false, true)
	helper.check(app.day == SATURDAY and app.minute_of_day == EVENING and app.dice_house.nights == 0, "Go to bed keeps the clock and adds no visit")
	helper.check(app.progress.coins == starting_coins and app.progress.trust == 45 and app.ui.reputation_lines().is_empty(), "Go to bed changes no wallet, trust or talk")
	await capture_state(app, 11)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all twelve master states were captured")
	finish(app)


func start_at_inn(app: Node3D, restart: bool = false) -> void:
	if restart:
		await click(app, app.data.ui.buttons.city_map)
		await click(app, app.identity.ui.world_map)
		await click(app, app.identity.ui.title_back)
	await click(app, app.data.ui.buttons.begin)
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	app.progress.apply_trust(45 - app.progress.trust)
	app.player.position = app.world.point("inn")
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.clock.skip_to(SATURDAY, MORNING)
	app.update_state()


func set_time(app: Node3D, day: int, minute: int) -> void:
	app.clock.skip_to(day, minute)
	app.update_state()


func expect_inn_actions(app: Node3D, invite: bool, door: bool) -> void:
	helper.check(app.ui.screen == "market_map" and app.current_place == "inn", "Inn actions appear on its market-map bar")
	expect_button(app, dice.inn_invite, invite)
	expect_button(app, dice.inn_button, door)


func expect_invitation(app: Node3D) -> void:
	helper.check(app.ui.screen == "dice_invite", "the Inn whisper opens Mansur's invitation")
	expect_label(app, dice.invite.kicker.to_upper())
	expect_label(app, dice.invite.title)
	expect_label(app, dice.invite.text)
	expect_button(app, dice.invite.go, true)
	expect_button(app, dice.invite.no, true)


func expect_house(app: Node3D, story: String, visits: int) -> void:
	helper.check(app.ui.screen == "dice_house", "the dice house is open")
	expect_label(app, dice.house.kicker.to_upper())
	expect_label(app, dice.house.title)
	expect_label(app, story)
	expect_label(app, str(dice.house.visits).format({"n": visits}).to_upper())
	expect_button(app, dice.house.leave, true)


func check_bet_buttons(app: Node3D) -> void:
	for value: float in dice.bets:
		var stake := int(value)
		expect_button(app, str(dice.house.bet).format({"n": stake}), app.progress.coins >= stake)


func capture_talk(app: Node3D, index: int, line: Array, trust: int) -> void:
	set_time(app, app.day + 1, MORNING)
	var original_yaw: float = app.player.yaw
	var lane: Vector3 = app.world.point("a2")
	var toward_square: Vector3 = app.world.point(app.data.square.centre) - lane
	app.player.position = lane
	app.player.velocity = Vector3.ZERO
	app.player.yaw = atan2(-toward_square.x, -toward_square.z)
	app.player.update_camera()
	app.update_state()
	await click(app, app.chapter.purse.morning.to_rep)
	await app.get_tree().physics_frame
	helper.check(not app.night and app.minute_of_day == MORNING, "the reputation view uses the next morning's daylight")
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [line], "What people say has only the highest reached dice line")
	helper.check(app.progress.trust == trust, "the rumor threshold has the exact trust result")
	expect_label(app, "“%s”" % line[0])
	expect_label(app, str(line[1]).to_upper())
	expect_label(app, app.chapter.rep.tone[str(int(line[2]))])
	await capture_state(app, index)
	await click(app, app.chapter.rep.to_map)
	app.player.position = app.world.point("inn")
	app.player.velocity = Vector3.ZERO
	app.player.yaw = original_yaw
	app.player.update_camera()
	app.update_state()


func expect_button(app: Node3D, value: String, visible: bool) -> void:
	var button := helper.find_button(app.ui, value)
	helper.check((button != null) == visible, "button %s: %s" % ["shown" if visible else "hidden", value])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits in viewport: " + value)


func expect_label(app: Node3D, value: String) -> void:
	helper.check(count_labels(app.ui, value) == 1, "one visible label: " + value)


func count_labels(node: Node, value: String) -> int:
	if node is Control and not node.is_visible_in_tree():
		return 0
	var count := 0
	if (node is Label and node.text == value) or (node is RichTextLabel and node.get_parsed_text() == value):
		count += 1
	for child in node.get_children():
		count += count_labels(child, value)
	return count


func capture_state(app: Node3D, index: int) -> void:
	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.nights = app.dice_house.nights
	state.invited = app.dice_house.invited


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE18_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("DICE HOUSE NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
