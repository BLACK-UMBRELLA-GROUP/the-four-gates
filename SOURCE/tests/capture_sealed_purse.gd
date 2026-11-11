extends "res://tests/capture_identity.gd"
## DOC-TFG-0041: native viewport evidence for all ten LOCK 10 V1 masters.

const OUTPUT := "res://../GAME/APPROVED/SEALED_PURSE/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/SEALED_PURSE/RECORD/sealed_purse_data_V1.json"
const MASTER_STEMS := [
	"h01_quay__karim_has_a_job",
	"h02_sealed__offer",
	"h03_sealed__coin_on_the_stones",
	"h04_square__carrying",
	"h05_gate__give_the_purse",
	"h06_sealed__delivered_whole",
	"h07_people_say__honest",
	"h08_sealed__one_short",
	"h09_people_say__one_short",
	"h10_quay__trust_too_low",
]
const SATURDAY := 3
const MORNING := 600

var purse: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--sealed-purse-output="):
			return argument.trim_prefix("--sealed-purse-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Sealed purse capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the sealed purse evidence directory")
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
	helper.report.method = "Real native Godot viewport. Viewport clicks exercise the fair arrival, offer, refusal, coin choices, delivery, and reputation."
	helper.report.fixture = "Passive clock ticks are paused. Fair arrival provides the wallet. Trust is set to 45 or 30 through TaskProgress. The harness places the player at the quay on Saturday day 3 at 10:00 and at the gate for delivery. The coin choice moves the player to the Task board through gameplay."
	app.set_process(false)
	purse = app.sealed_purse.data
	helper.check(FileAccess.get_file_as_bytes(LOCKED_DATA) == FileAccess.get_file_as_bytes("res://data/sealed_purse.json"), "runtime sealed purse data matches the locked bytes")

	await start_at_quay(app, 45)
	if not helper.check(app.ui.screen == "market_map" and app.current_place == "quay" and app.day == SATURDAY and app.minute_of_day == MORNING and not app.clock.is_friday(), "eligible fixture opens the quay map at 10:00 on a later non-Friday"):
		finish(app)
		return
	check_capsule(app, "Karim", "quay")
	check_capsule(app, "Abbas", "gate")
	await offer(app, true)
	await deliver_whole(app)
	await start_at_quay(app, 45, true)
	await offer(app, false)
	await deliver_short(app)
	await start_at_quay(app, 30, true)
	expect_button(app, purse.quay_button, false)
	expect_label(app, purse.carrying, false)
	helper.check(app.current_place == "quay" and app.progress.trust == 30, "h10 returns to the same quay with trust below the offer threshold")
	await capture_state(app, 9)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all ten master states were captured")
	finish(app)


func start_at_quay(app: Node3D, trust: int, restart: bool = false) -> void:
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
	app.progress.apply_trust(trust - app.progress.trust)
	app.clock.skip_to(SATURDAY, MORNING)
	place_player(app, "quay")


func place_player(app: Node3D, place: String) -> void:
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	app.player.update_camera()
	app.update_state()


func offer(app: Node3D, capture_offer: bool) -> void:
	var copy: Dictionary = purse.offer
	var coin: Dictionary = purse.coin
	var starting_coins: int = app.progress.coins
	expect_button(app, purse.quay_button, true)
	expect_label(app, purse.carrying, false)
	if capture_offer:
		await capture_state(app, 0)
	await click(app, purse.quay_button)
	expect_story(app, "sealed_purse_offer", copy, copy.text, copy.accept, copy.refuse)
	if capture_offer:
		await capture_state(app, 1)
		await click(app, copy.refuse)
		helper.check(app.ui.screen == "market_map" and app.current_place == "quay" and app.progress.coins == starting_coins, "refusal returns to the same quay without changing the wallet")
		expect_button(app, purse.quay_button, true)
		await click(app, purse.quay_button)
	await click(app, copy.accept)
	expect_story(app, "sealed_purse_coin", coin, coin.text, coin.back_in, coin.keep)
	helper.check(app.progress.coins == starting_coins and app.ui.reputation_lines().is_empty(), "accepting alone changes neither the wallet nor reputation")
	if capture_offer:
		await capture_state(app, 2)


func deliver_whole(app: Node3D) -> void:
	var starting_coins: int = app.progress.coins
	var starting_trust: int = app.progress.trust
	await click(app, purse.coin.back_in)
	check_board_carrying(app)
	helper.check(app.progress.coins == starting_coins, "returning the coin leaves the wallet unchanged")
	await capture_state(app, 3)
	place_player(app, "gate")
	expect_button(app, purse.gate_button, true)
	expect_label(app, purse.carrying, true)
	await capture_state(app, 4)
	var delivery: Dictionary = purse.deliver
	await click(app, purse.gate_button)
	expect_story(app, "sealed_purse_delivery", delivery, delivery.honest, delivery.to_rep, delivery.to_map)
	helper.check(app.progress.coins == starting_coins + int(purse.numbers.fee) and app.progress.trust == starting_trust + int(purse.numbers.honest_trust), "whole delivery awards the locked fee and trust")
	await capture_state(app, 5)
	await click(app, delivery.to_rep)
	check_reputation(app, purse.say.honest)
	await capture_state(app, 6)
	await click(app, app.chapter.rep.to_map)
	check_job_done(app)
	place_player(app, "quay")
	expect_button(app, purse.quay_button, false)


func deliver_short(app: Node3D) -> void:
	var starting_coins: int = app.progress.coins
	var starting_trust: int = app.progress.trust
	await click(app, purse.coin.keep)
	check_board_carrying(app)
	helper.check(app.progress.coins == starting_coins + int(purse.numbers.kept_coin), "keeping the coin adds the locked amount")
	place_player(app, "gate")
	expect_label(app, purse.carrying, true)
	var delivery: Dictionary = purse.deliver
	await click(app, purse.gate_button)
	expect_story(app, "sealed_purse_delivery", delivery, delivery.kept, delivery.to_rep, delivery.to_map)
	helper.check(app.progress.coins == starting_coins + int(purse.numbers.kept_coin) and app.progress.trust == starting_trust + int(purse.numbers.kept_trust), "short delivery charges the locked trust loss and pays no fee")
	await capture_state(app, 7)
	await click(app, delivery.to_rep)
	check_reputation(app, purse.say.kept)
	await capture_state(app, 8)
	await click(app, app.chapter.rep.to_map)
	check_job_done(app)


func check_board_carrying(app: Node3D) -> void:
	helper.check(app.ui.screen == "market_map" and app.current_place == "board" and app.sealed_purse.is_carrying(), "coin choice returns to the Task board while carrying")
	expect_label(app, purse.carrying, true)
	expect_button(app, purse.gate_button, false)


func check_job_done(app: Node3D) -> void:
	helper.check(app.ui.screen == "market_map" and app.current_place == "gate" and not app.sealed_purse.is_carrying(), "delivery returns to the gate map with the purse handed over")
	expect_button(app, purse.gate_button, false)
	expect_label(app, purse.carrying, false)


func check_reputation(app: Node3D, line: Array) -> void:
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [line], "reputation has exactly the locked delivery outcome")
	expect_label(app, "“%s”" % line[0], true)
	expect_label(app, str(line[1]).to_upper(), true)
	expect_label(app, app.chapter.rep.tone[str(int(line[2]))], true)


func check_capsule(app: Node3D, person: String, place: String) -> void:
	var capsule := app.world.find_child(person, true, false) as MeshInstance3D
	var named := false
	if capsule != null:
		for child: Node in capsule.get_children():
			if child is Label3D and child.text == person and child.is_visible_in_tree():
				named = true
	helper.check(capsule != null and capsule.mesh is CapsuleMesh and capsule.is_visible_in_tree() and named, "%s stands as a visible named capsule" % person)
	if capsule != null:
		var point: Vector3 = app.world.point(place)
		var distance := Vector2(capsule.position.x - point.x, capsule.position.z - point.z).length()
		helper.check(distance <= float(app.data.street_width), "%s stands at %s" % [person, place])


func expect_story(app: Node3D, screen: String, copy: Dictionary, story: String, primary: String, secondary: String) -> void:
	helper.check(app.ui.screen == screen, screen + " is open")
	expect_label(app, copy.kicker.to_upper(), true)
	expect_label(app, copy.title, true)
	expect_label(app, story, true)
	var first := expect_button(app, primary, true)
	var second := expect_button(app, secondary, true)
	if first != null and second != null:
		helper.check(first.get_global_rect().position.x < second.get_global_rect().position.x, "primary story choice precedes the secondary choice")


func expect_button(app: Node3D, value: String, visible: bool) -> Button:
	var button := helper.find_button(app.ui, value)
	helper.check((button != null) == visible, "button %s: %s" % ["shown" if visible else "hidden", value])
	if button != null:
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "button fits in viewport: " + value)
	return button


func expect_label(app: Node3D, value: String, visible: bool) -> void:
	var label := find_label(app.ui, value)
	helper.check((label != null) == visible, "label %s: %s" % ["shown" if visible else "hidden", value])
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
	state.carrying = app.sealed_purse.is_carrying()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE17_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("SEALED PURSE NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
