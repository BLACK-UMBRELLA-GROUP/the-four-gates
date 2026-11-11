extends "res://tests/capture_identity.gd"
## DOC-TFG-0023: native viewport evidence for LOCK 4 V1.

const OUTPUT := "res://../GAME/APPROVED/MARKET_STALL/BUILT/V1/"
const MASTER_STEMS := [
	"s01_market_map__spice_row_stall",
	"s02_stall__start",
	"s03_stall__extra_change",
	"s04_stall__gave_it_back",
	"s05_stall__kept_it",
	"s06_stall__next_day_found_out",
	"s07_stall__clothes_bought",
	"s08_stall__not_enough_coins",
	"s09_bag__empty",
	"s10_bag__items",
	"s11_bag__wearing",
	"s12_market_map__quay_give_bread",
	"s13_market_map__bread_given",
	"s14_people_say__stall_lines",
	"s15_people_say__kept_change",
]
const THURSDAY := 8
const FRIDAY := 9
const NEXT_THURSDAY := 15
const FIXTURE_TIME := 600

var market: Dictionary
var wallet: int
var trust: int


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--market-stall-output="):
			return argument.trim_prefix("--market-stall-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the market stall evidence directory")
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
	helper.report.method = "Native Godot viewport with mouse clicks on production GUI. The harness pauses passive clock ticks."
	helper.report.fixture = "Fair arrival. Thursday day 8 and Friday day 9 at 10:00, then Thursday day 15 for the discovered-change reputation. Prayer history is reset for the fixture jump. The unavailable purchase fixture sets the wallet to the price of one loaf."
	app.set_process(false)
	market = app.market_stall.data
	await click(app, app.data.ui.buttons.begin)
	await complete_arrival(app)
	wallet = app.progress.coins
	trust = app.progress.trust
	helper.check(app.current_place == "inn" and app.ui.screen == "market_map", "fair arrival opens the Inn market map")
	app.clock.reset()
	app.clock.skip_to(THURSDAY, FIXTURE_TIME)
	app.update_state()
	await capture_return_path(app)
	await capture_keep_path(app)
	await capture_short_wallet(app)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size() + 2, "all 15 masters and both street capsule views captured")
	finish(app)


func capture_return_path(app: Node3D) -> void:
	await click(app, coin_button(app))
	helper.check(app.ui.screen == "bag" and has_label(app.ui, market.bag.empty), "coins HUD opens the empty bag")
	await master_shot(app, 9)
	await click(app, market.bag.back)
	helper.check(app.ui.screen == "market_map", "bag Back returns to the market map")

	stage_place(app, "spice")
	helper.check(helper.find_button(app.ui, app.data.ui.place_actions.spice) == null, "the spice row replaces Look around")
	await master_shot(app, 1)
	await click(app, market.place.spice_button)
	helper.check(app.ui.screen == "stall" and has_label(app.ui, market.stall.title), "spice row opens Rashid's stall")
	await master_shot(app, 2)

	var bread_price := int(market.items[0].price)
	var extra := int(market.numbers.change_extra)
	await click(app, buy_label(0))
	helper.check(app.ui.screen == "stall_change", "the first purchase opens Your change")
	helper.check(app.market_stall.count("bread") == 1 and app.progress.coins == wallet - bread_price + extra, "first purchase holds a loaf and pays the locked extra change")
	await master_shot(app, 3)
	await click(app, market.stall.change.give_back)
	helper.check(app.ui.screen == "stall" and has_label(app.ui, market.stall.change.returned), "returning the change shows Rashid's reply")
	helper.check(app.progress.coins == wallet - bread_price and app.progress.trust == trust + int(market.numbers.change_return_trust), "returning the change refunds it and adds the locked trust")
	await master_shot(app, 4)
	await click(app, market.stall.back)
	helper.check(app.ui.screen == "market_map", "stall Back returns to the market map")

	stage_place(app, "quay")
	helper.check(helper.find_button(app.ui, app.data.ui.place_actions.quay) != null, "Faris's action keeps the Quay's Look around button")
	await master_shot(app, 12)
	var before_feed: int = app.progress.trust
	await click(app, market.place.quay_feed)
	helper.check(app.market_stall.count("bread") == 0 and app.progress.trust == before_feed + int(market.numbers.feed_trust), "first gift spends the last loaf and adds the locked trust")
	helper.check(has_label(app.ui, market.feed), "the locked feed toast is visible")
	helper.check(helper.find_button(app.ui, market.place.quay_feed) == null, "the Quay no longer offers bread when the bag has none")
	await master_shot(app, 13)

	stage_place(app, "spice")
	await click(app, market.place.spice_button)
	var before_repeat: int = app.progress.coins
	await click(app, buy_label(0))
	helper.check(app.ui.screen == "stall" and app.progress.coins == before_repeat - bread_price, "repeat bread purchase pays the price without another change choice")
	await click(app, buy_label(0))
	await click(app, buy_label(1))
	await click(app, buy_label(2))
	helper.check(app.market_stall.count("bread") == 2 and app.market_stall.count("dates") == 1 and app.market_stall.count("clothes") == 1, "the bag holds two loaves, one serving of dates and the local clothes")
	helper.check(app.progress.coins == before_repeat - 2 * bread_price - int(market.items[1].price) - int(market.items[2].price), "all repeat purchases charge their locked prices")
	await click(app, market.stall.back)
	stage_place(app, "inn")
	await click(app, coin_button(app))
	helper.check(app.ui.screen == "bag" and has_label(app.ui, bag_item_label(0, 2)) and has_label(app.ui, bag_item_label(1, 1)), "bag shows both repeatable item counts")
	await master_shot(app, 10)
	await wear_outfit(app, "clothes")
	helper.check(app.market_stall.worn_clothes == "clothes" and has_label(app.ui, app.market_stall.clothes_data.bag.wearing), "wearing local clothes marks the wardrobe row")
	await master_shot(app, 11)
	await wear_outfit(app, "traveller")
	helper.check(app.market_stall.worn_clothes == "traveller", "the wardrobe switches back to the starting clothes")
	await wear_outfit(app, "clothes")
	await click(app, market.bag.back)
	await click(app, app.chapter.purse.morning.to_rep)
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [market.say.returned, market.say.fed, market.say.clothes], "returned change, bread and clothes appear in locked order")
	await master_shot(app, 14)
	await click(app, app.chapter.rep.to_map)
	stage_place(app, "quay")
	before_feed = app.progress.trust
	await click(app, market.place.quay_feed)
	helper.check(app.market_stall.count("bread") == 1 and app.progress.trust == before_feed, "a second gift spends a loaf and leaves trust alone")

	var faris_name := ""
	for person: Dictionary in app.chapter.purse.people:
		if person.id == "boy":
			faris_name = str(person.name).get_slice(",", 0)
	await capture_person(app, app.world.faris_at_quay, faris_name, "faris_at_quay__build.png", "quay", "pier")
	await capture_person(app, app.world.rashid, str(market.say.returned[1]).get_slice(" ", 0), "rashid_at_spice_row__build.png", "spice", "sp1")


func capture_keep_path(app: Node3D) -> void:
	await reset_market(app)
	stage_place(app, "spice")
	await click(app, market.place.spice_button)
	await click(app, buy_label(0))
	var before_keep: int = app.progress.coins
	await click(app, market.stall.change.keep)
	helper.check(app.ui.screen == "stall" and has_label(app.ui, market.stall.change.kept), "keeping the change shows the locked same-day reply")
	helper.check(app.progress.trust == trust and app.progress.coins == before_keep, "keeping the change leaves coins and trust alone that day")
	await master_shot(app, 5)
	await click(app, market.stall.back)
	await click(app, market.place.spice_button)
	helper.check(app.progress.trust == trust and not has_label(app.ui, market.stall.change.found), "a same-day return does not reveal the change")
	await click(app, market.stall.back)
	await click(app, app.chapter.purse.morning.to_rep)
	helper.check(app.ui.reputation_lines().is_empty(), "kept change has no reputation line before discovery")
	await click(app, app.chapter.rep.to_map)
	app.clock.skip_to(FRIDAY, FIXTURE_TIME)
	app.update_state()
	helper.check(app.progress.trust == trust, "a later day without a stall visit has no discovery penalty")
	await click(app, market.place.spice_button)
	var after_discovery := trust + int(market.numbers.change_kept_trust)
	helper.check(app.progress.trust == after_discovery and has_label(app.ui, market.stall.change.found), "the first later-day visit shows Rashid's discovery and deducts the locked trust")
	await master_shot(app, 6)
	await click(app, buy_label(2))
	helper.check(helper.find_button(app.ui, buy_label(2)) == null and has_label(app.ui, market.stall.owned), "local clothes can be bought only once and the row shows bought")
	helper.check(not has_label(app.ui, market.stall.change.found), "the ordinary purchase returns to the stall without the discovery line")
	await master_shot(app, 7)
	await click(app, market.stall.back)
	await click(app, market.place.spice_button)
	helper.check(app.progress.trust == after_discovery, "another stall visit leaves trust alone")
	await click(app, market.stall.back)
	app.clock.skip_to(NEXT_THURSDAY, FIXTURE_TIME)
	app.update_state()
	await click(app, app.chapter.purse.morning.to_rep)
	helper.check(app.ui.reputation_lines() == [market.say.kept], "the kept-change reputation line follows discovery")
	await master_shot(app, 15)


func capture_short_wallet(app: Node3D) -> void:
	await reset_market(app)
	app.progress.coins = int(market.items[0].price)
	stage_place(app, "spice")
	await click(app, market.place.spice_button)
	helper.check(helper.find_button(app.ui, buy_label(0)) != null, "the player can buy bread at the exact price")
	helper.check(helper.find_button(app.ui, buy_label(1)) == null and helper.find_button(app.ui, buy_label(2)) == null and has_label(app.ui, market.stall.not_enough), "unaffordable dates and clothes show not enough coins and offer no buy buttons")
	await master_shot(app, 8)


func complete_arrival(app: Node3D) -> void:
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])


func reset_market(app: Node3D) -> void:
	app.begin_game()
	await complete_arrival(app)
	helper.check(app.progress.coins == wallet and app.progress.trust == trust, "new fair arrival restores the baseline wallet and trust")
	app.clock.reset()
	app.clock.skip_to(THURSDAY, FIXTURE_TIME)
	app.update_state()


func stage_place(app: Node3D, id: String) -> void:
	app.player.position = app.world.point(id)
	app.player.velocity = Vector3.ZERO
	if id == "spice":
		face_towards(app, app.world.point("sp1"))
	elif id == "quay":
		face_towards(app, app.world.point("pier"))
	else:
		face_towards(app, app.world.point("quay"))
	app.show_screen("market_map")
	helper.check(app.current_place == id, "fixture positions the player at " + id)


func face_towards(app: Node3D, point: Vector3) -> void:
	var toward: Vector3 = point - app.player.position
	app.player.yaw = atan2(-toward.x, -toward.z)
	app.player.pitch = 0.0
	app.player.update_camera()


func capture_person(app: Node3D, person: MeshInstance3D, display_name: String, filename: String, place: String, approach: String) -> void:
	if not helper.check(is_instance_valid(person) and person.is_visible_in_tree() and person.mesh is CapsuleMesh, display_name + " is a visible placeholder capsule"):
		return
	var person_label: Label3D
	for child: Node in person.get_children():
		if child is Label3D:
			person_label = child
			break
	helper.check(person_label != null and person_label.text == display_name, display_name + " has the locked name label")
	var point: Vector3 = app.world.point(place)
	var toward_street: Vector3 = (app.world.point(approach) - point).normalized()
	app.player.position = point + toward_street * float(app.data.camera.distance_behind)
	app.player.velocity = Vector3.ZERO
	face_towards(app, person.global_position)
	app.show_screen("game")
	await shot(app, filename)
	helper.report.states[filename].person = display_name
	helper.report.states[filename].person_position = [person.position.x, person.position.y, person.position.z]


func buy_label(index: int) -> String:
	var price := int(market.items[index].price)
	return str(market.stall.buy_one if price == 1 else market.stall.buy).format({"n": price})


func coin_button(app: Node3D) -> String:
	return str(app.data.ui.hud.coins).format({"n": app.progress.coins})


func bag_item_label(index: int, count: int) -> String:
	return "%s × %d" % [market.items[index].name, count]


func wear_outfit(app: Node3D, id: String) -> void:
	var button := app.ui.find_child("Wear_" + id, true, false) as Button
	if helper.check(button != null and button.is_visible_in_tree(), "the wardrobe offers Wear for " + id):
		await hit(app, button.get_global_rect().get_center())


func has_label(node: Node, value: String) -> bool:
	if node is Control and not node.is_visible_in_tree():
		return false
	if node is Label and node.text == value:
		return true
	if node is RichTextLabel and node.get_parsed_text() == value:
		return true
	for child: Node in node.get_children():
		if has_label(child, value):
			return true
	return false


func master_shot(app: Node3D, number: int) -> void:
	var filename := str(MASTER_STEMS[number - 1]) + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = app.current_place
	state.change_state = app.market_stall.change_state
	state.bag = {"bread": app.market_stall.count("bread"), "dates": app.market_stall.count("dates"), "clothes": app.market_stall.count("clothes")}
	state.wearing_clothes = app.market_stall.worn_clothes == "clothes"
	if app.ui.screen == "reputation":
		state.lines = app.ui.reputation_lines()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE11_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("MARKET STALL NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
