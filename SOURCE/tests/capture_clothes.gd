extends "res://tests/capture_identity.gd"
## DOC-TFG-0026: native viewport evidence for LOCK 5 V1.

const OUTPUT := "res://../GAME/APPROVED/CLOTHES/BUILT/V1/"
const MASTER_STEMS := [
	"w01_market_map__weaver_loom",
	"w02_loom__start",
	"w03_loom__bought_work_and_best",
	"w04_loom__bag_full",
	"w05_loom__leather_bag_bought",
	"w06_bag__wardrobe_pouch",
	"w07_bag__wearing_work",
	"w08_bag__full",
	"w09_bag__leather_bag",
	"w10_stall__bag_full",
	"w11_people_say__work_clothes",
	"w12_people_say__best_on_friday",
	"w13_people_say__scholar_cloak",
	"w14_people_say__merchant_coat",
	"w15_people_say__silk",
]
const THURSDAY := 8
const FRIDAY := 9
const NEXT_THURSDAY := 15
const FIXTURE_TIME := 600

var clothes: Dictionary
var market: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--clothes-output="):
			return argument.trim_prefix("--clothes-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the clothes evidence directory")
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
	helper.report.method = "Native Godot viewport. Production GUI clicks buy and equip the items. The harness pauses passive clock ticks and stages player positions and camera direction. Street use opens the loom through the input action."
	helper.report.fixture = "Fair arrival in three independent sequences, with prayer history reset before staging Thursday day 8, Friday day 9 and Thursday day 15 at 10:00. Wallet is set to 161 after filling the pouch with four loaves, and to 186 after buying work clothes, two loaves and dates for w06–w07. A clean loom-only reputation sequence funds the five outfits in advance, leaving the fair arrival wallet (198) after the purchases."
	app.set_process(false)
	clothes = app.market_stall.clothes_data
	market = app.market_stall.data
	await click(app, app.data.ui.buttons.begin)
	await complete_arrival(app)
	await capture_loom_and_full_bag(app)
	await capture_wardrobe(app)
	await capture_reputation(app)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size() + 1, "all 15 masters and the Layla street view were captured")
	finish(app)


func capture_loom_and_full_bag(app: Node3D) -> void:
	stage_place(app, "weaver", "sq")
	helper.check(helper.find_button(app.ui, app.data.ui.place_actions.weaver) == null, "weaver's lane replaces Look around")
	await master_shot(app, 1)
	await open_loom(app)
	helper.check(app.market_stall.worn_clothes == "traveller" and app.market_stall.carried() == 0, "the starting clothes are worn and take no space")
	helper.check(has_label(app.ui, clothes.loom.not_enough) and helper.find_button(app.ui, loom_buy_caption(outfit("silk"))) == null, "the 198-coin wallet cannot buy silk")
	await master_shot(app, 2)
	await buy_outfit(app, "work")
	await buy_outfit(app, "best")
	helper.check(has_label(app.ui, clothes.loom.owned), "bought outfits display their owned status")
	await master_shot(app, 3)
	await click(app, clothes.loom.back)

	await buy_food(app, 4, 0)
	helper.check(app.market_stall.is_full() and app.market_stall.carried() == int(clothes.numbers.pouch), "four loaves and two unworn outfits fill the pouch")
	app.progress.coins = 161
	app.update_state()
	helper.check(has_label(app.ui, clothes.loom.full) and helper.find_button(app.ui, stall_buy_caption(market.items[0])) == null, "the full pouch blocks a further stall purchase")
	await master_shot(app, 10)
	await click(app, market.stall.back)
	stage_place(app, "weaver", "sq")
	await open_bag(app)
	helper.check(has_label(app.ui, clothes.bag.full_note), "the full pouch shows the locked note")
	await master_shot(app, 8)
	await click(app, market.bag.back)
	await open_loom(app)
	helper.check(has_label(app.ui, clothes.loom.full) and has_label(app.ui, clothes.loom.not_enough), "the loom distinguishes a full bag from unaffordable silk")
	helper.check(helper.find_button(app.ui, loom_buy_caption(outfit("scholar"))) == null, "the full bag blocks an affordable outfit")
	await master_shot(app, 4)
	var before_bag: int = app.progress.coins
	await click(app, loom_buy_caption(clothes.leather_bag))
	helper.check(app.progress.coins == before_bag - int(clothes.leather_bag.price), "the leather bag charges its locked price even at pouch capacity")
	helper.check(app.market_stall.capacity() == int(clothes.numbers.leather_bag) and not app.market_stall.is_full(), "the leather bag expands capacity without changing the contents")
	await master_shot(app, 5)
	await click(app, clothes.loom.back)
	await open_bag(app)
	helper.check(has_label(app.ui, carrying_caption(app)) and not has_label(app.ui, clothes.bag.full_note), "the leather bag shows the expanded capacity and clears the full note")
	await master_shot(app, 9)
	await click(app, market.bag.back)
	await capture_layla(app)


func capture_wardrobe(app: Node3D) -> void:
	await reset_market(app)
	stage_place(app, "weaver", "sq")
	await open_loom(app)
	await buy_outfit(app, "work")
	await click(app, clothes.loom.back)
	await buy_food(app, 2, 1)
	await click(app, market.stall.back)
	app.progress.coins = 186
	stage_place(app, "weaver", "sq")
	await open_bag(app)
	helper.check(has_label(app.ui, carrying_caption(app)) and has_label(app.ui, "%s × 2" % market.items[0].name) and has_label(app.ui, "%s × 1" % market.items[1].name), "the wardrobe and food show four carried things")
	await master_shot(app, 6)
	await wear_outfit(app, "work")
	helper.check(app.market_stall.carried() == 4, "swapping outfits does not change how much is carried")
	await master_shot(app, 7)


func capture_reputation(app: Node3D) -> void:
	await reset_market(app)
	var ids := ["work", "best", "scholar", "merchant", "silk"]
	for id: String in ids:
		app.progress.coins += int(outfit(id).price)
	stage_place(app, "weaver", "sq")
	await open_loom(app)
	for id: String in ids:
		await buy_outfit(app, id)
	await click(app, clothes.loom.back)
	stage_place(app, "spice", "sp1")
	var initial_trust: int = app.progress.trust
	for index in ids.size():
		var id: String = ids[index]
		await open_bag(app)
		await wear_outfit(app, id)
		await click(app, market.bag.back)
		if id == "best":
			helper.check(app.ui.reputation_lines().is_empty(), "best clothes add no line on Thursday")
			app.clock.skip_to(FRIDAY, FIXTURE_TIME)
		elif id == "scholar":
			app.clock.skip_to(NEXT_THURSDAY, FIXTURE_TIME)
		app.update_state()
		await click(app, app.chapter.purse.morning.to_rep)
		var say_key := "best_friday" if id == "best" else id
		var expected: Array = clothes.say[say_key]
		helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [expected], "the worn outfit adds only its locked line: " + id)
		helper.check(app.progress.trust == initial_trust, "the outfit leaves trust unchanged: " + id)
		await master_shot(app, 11 + index)
		await click(app, app.chapter.rep.to_map)


func capture_layla(app: Node3D) -> void:
	var person: MeshInstance3D = app.world.layla
	var name_text := str(clothes.loom.title).get_slice("'s", 0)
	if not helper.check(is_instance_valid(person) and person.is_visible_in_tree() and person.mesh is CapsuleMesh, "Layla is a visible placeholder capsule"):
		return
	var named := false
	for child: Node in person.get_children():
		if child is Label3D and child.text == name_text:
			named = true
	helper.check(named, "the capsule has Layla's name label")
	var place: Vector3 = app.world.point("weaver")
	var toward_street: Vector3 = (app.world.point("sq") - place).normalized()
	app.player.position = place + toward_street * float(app.data.camera.distance_behind)
	app.player.velocity = Vector3.ZERO
	face_towards(app, person.global_position)
	app.show_screen("game")
	const FILENAME := "layla_at_weavers_lane__build.png"
	await shot(app, FILENAME)
	helper.report.states[FILENAME].person = name_text
	helper.report.states[FILENAME].person_position = [person.position.x, person.position.y, person.position.z]

	stage_place(app, "weaver", "sq")
	app.show_screen("game")
	await helper.action(app, "use")
	helper.check(app.ui.screen == "loom", "street use at weaver's lane opens Layla's loom")


func complete_arrival(app: Node3D) -> void:
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	helper.check(app.current_place == "inn" and app.ui.screen == "market_map", "fair arrival opens the Inn market map")
	app.clock.reset()
	app.clock.skip_to(THURSDAY, FIXTURE_TIME)
	app.update_state()


func reset_market(app: Node3D) -> void:
	app.begin_game()
	await complete_arrival(app)


func stage_place(app: Node3D, id: String, toward: String) -> void:
	app.player.position = app.world.point(id)
	app.player.velocity = Vector3.ZERO
	face_towards(app, app.world.point(toward))
	app.show_screen("market_map")
	helper.check(app.current_place == id, "fixture positions the player at " + id)


func face_towards(app: Node3D, point: Vector3) -> void:
	var toward: Vector3 = point - app.player.position
	app.player.yaw = atan2(-toward.x, -toward.z)
	app.player.pitch = 0.0
	app.player.update_camera()


func open_loom(app: Node3D) -> void:
	await click(app, clothes.place.weaver_button)
	helper.check(app.ui.screen == "loom" and has_label(app.ui, clothes.loom.title), "the map action opens Layla's loom")


func open_bag(app: Node3D) -> void:
	var coins := str(app.data.ui.hud.coins).format({"n": app.progress.coins})
	await click(app, coins)
	helper.check(app.ui.screen == "bag" and has_label(app.ui, market.bag.title), "the coins button opens the wardrobe")


func buy_food(app: Node3D, bread: int, dates: int) -> void:
	stage_place(app, "spice", "sp1")
	await click(app, market.place.spice_button)
	for index in bread:
		await click(app, stall_buy_caption(market.items[0]))
		if index == 0:
			helper.check(app.ui.screen == "stall_change", "the first stall purchase still opens the change decision")
			await click(app, market.stall.change.keep)
	for index in dates:
		await click(app, stall_buy_caption(market.items[1]))
	helper.check(app.market_stall.count("bread") == bread and app.market_stall.count("dates") == dates, "the stall supplies the requested food")


func buy_outfit(app: Node3D, id: String) -> void:
	var item := outfit(id)
	var before: int = app.progress.coins
	await click(app, loom_buy_caption(item))
	helper.check(app.market_stall.count(id) == 1 and app.progress.coins == before - int(item.price), "buying %s once charges its locked price" % id)
	helper.check(app.market_stall.worn_clothes == "traveller", "buying %s keeps the starting outfit worn" % id)


func wear_outfit(app: Node3D, id: String) -> void:
	var button := app.ui.find_child("Wear_" + id, true, false) as Button
	if helper.check(button != null and button.is_visible_in_tree() and button.text == clothes.bag.wear, "visible Wear button for " + id):
		await hit(app, button.get_global_rect().get_center())
	helper.check(app.market_stall.worn_clothes == id and has_label(app.ui, clothes.bag.wearing), "the wardrobe shows %s as worn" % id)


func outfit(id: String) -> Dictionary:
	for item: Dictionary in clothes.clothes:
		if item.id == id:
			return item
	return {}


func loom_buy_caption(item: Dictionary) -> String:
	return str(clothes.loom.buy).format({"n": int(item.price)})


func stall_buy_caption(item: Dictionary) -> String:
	var price := int(item.price)
	return str(market.stall.buy_one if price == 1 else market.stall.buy).format({"n": price})


func carrying_caption(app: Node3D) -> String:
	var coins := str(market.bag.coins).format({"n": app.progress.coins})
	var carrying := str(clothes.bag.carrying).format({"n": app.market_stall.carried(), "m": app.market_stall.capacity()})
	return coins + " · " + carrying


func has_label(node: Node, value: String) -> bool:
	if node is Control and not node.is_visible_in_tree():
		return false
	if node is Label and node.text.nocasecmp_to(value) == 0:
		return true
	if node is RichTextLabel and node.get_parsed_text().nocasecmp_to(value) == 0:
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
	state.bread = app.market_stall.count("bread")
	state.dates = app.market_stall.count("dates")
	state.carried = app.market_stall.carried()
	state.capacity = app.market_stall.capacity()
	state.worn = app.market_stall.worn_clothes
	state.owned = []
	for item: Dictionary in clothes.clothes:
		if app.market_stall.count(item.id) > 0:
			state.owned.append(item.id)
	if app.ui.screen == "reputation":
		state.lines = app.ui.reputation_lines()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE12_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("CLOTHES NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
