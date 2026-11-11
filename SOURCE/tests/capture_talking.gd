extends "res://tests/capture_identity.gd"
## DOC-TFG-0029: native viewport evidence for LOCK 6 V1.

const OUTPUT := "res://../GAME/APPROVED/TALKING/BUILT/V1/"
const MASTER_STEMS := [
	"t01_market_map__square_talk_to_salma",
	"t02_talk__salma_wary",
	"t03_talk__salma_greeted",
	"t04_talk__salma_tip",
	"t05_talk__salma_friendly_truth",
	"t06_talk__salma_warm_paid",
	"t07_talk__rashid_returned",
	"t08_talk__rashid_kept",
	"t09_talk__layla_her_cloth",
	"t10_talk__layla_traveller",
	"t11_talk__jamal_fed",
	"t12_talk__jamal_boat",
	"t13_talk__musa_warm_learned",
	"t14_talk__musa_tip",
	"t15_people_say__greets_everyone",
]
const THURSDAY := 8
const TEN_AM := 600

var talking: Dictionary
var speaker: Dictionary
var fair_wallet: int


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--talking-output="):
			return argument.trim_prefix("--talking-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the talking evidence directory")
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
	helper.report.method = "Native Godot viewport. Real viewport clicks open each talk panel, greet, ask, say goodbye and open What people say. The harness pauses passive clock ticks and stages positions and camera direction at the live locations."
	helper.report.fixture = "Fair arrival, followed by Thursday day 8 at 10:00. Captures t01–t04 and t15 earn greetings in a clean session. A new fair arrival starts the memory cases. Earlier gameplay methods set up the histories independently; the wallet and trust are staged to the masters for those captures. Rashid's kept-change purchase is staged on the previous day and discovered on Thursday."
	app.set_process(false)
	talking = app.talking.data
	await click(app, app.data.ui.buttons.begin)
	await complete_arrival(app)
	fair_wallet = app.progress.coins
	check_capsules(app)
	await capture_greetings(app)
	app.begin_game()
	await complete_arrival(app)
	await capture_memories(app)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all 15 master states were captured")
	finish(app)


func complete_arrival(app: Node3D) -> void:
	var arrival: Dictionary = app.identity.arrival
	for beat: Dictionary in arrival.beats:
		await click(app, beat.choices[0].label)
		await click(app, arrival.continue)
	await click(app, arrival.buttons[1])
	helper.check(app.current_place == "inn" and app.ui.screen == "market_map", "fair arrival opens the Inn market map")
	app.clock.reset()
	app.clock.skip_to(THURSDAY, TEN_AM)
	app.update_state()


func check_capsules(app: Node3D) -> void:
	var capsules: Dictionary = app.world.talking_people
	var positions := {}
	for person: Dictionary in talking.people:
		var capsule := capsules.get(person.id) as MeshInstance3D
		if not helper.check(is_instance_valid(capsule) and capsule.is_visible_in_tree() and capsule.mesh is CapsuleMesh, "visible placeholder capsule for " + person.name):
			continue
		var named := false
		for child: Node in capsule.get_children():
			if child is Label3D and child.text == person.name:
				named = true
		var place: Vector3 = app.world.point(person.place)
		helper.check(named, "capsule bears the locked name " + person.name)
		helper.check(capsule.global_position.distance_to(place) <= float(app.data.player.use_radius) * 2.0, "capsule is at " + app.data.places[person.place].name)
		positions[person.id] = [capsule.global_position.x, capsule.global_position.y, capsule.global_position.z]
	helper.report.capsule_positions = positions


func capture_greetings(app: Node3D) -> void:
	var initial_trust: int = app.progress.trust
	var reward := int(talking.numbers.greet_trust)
	stage_person(app, "salma")
	var talk: Button = helper.find_button(app.ui, talk_caption())
	var board: Button = helper.find_button(app.ui, app.data.ui.place_actions.board)
	var oven: Button = helper.find_button(app.ui, app.chapter.places.board)
	if helper.check(talk != null and board != null and oven != null, "task board shows its previous actions and Talk to Salma"):
		helper.check(board.position.x < oven.position.x and oven.position.x < talk.position.x, "Talk to Salma follows the previous place actions")
	await master_shot(app, 1)
	await open_talk(app, "wary")
	await master_shot(app, 2)
	await greet(app, initial_trust)
	await master_shot(app, 3)
	await ask(app)
	helper.check(not has_label(app.ui, talking.panel.reply), "asking replaces Salma's greeting reply")
	await master_shot(app, 4)
	await goodbye(app)

	stage_person(app, "salma")
	await open_talk(app, "wary")
	helper.check(helper.find_button(app.ui, talking.panel.greet) == null and has_label(app.ui, talking.panel.greeted), "reopening Salma keeps her greeted status")
	await goodbye(app)

	stage_person(app, "rashid")
	await open_talk(app, "wary")
	await greet(app, initial_trust)
	await ask(app)
	await goodbye(app)
	helper.check(not app.ui.reputation_lines().has(talking.say.greets), "two different greetings add no reputation line")

	stage_person(app, "layla")
	await open_talk(app, "wary", "traveller")
	await greet(app, initial_trust + reward)
	await ask(app)
	await goodbye(app)

	stage_person(app, "salma")
	await click(app, app.chapter.purse.morning.to_rep)
	helper.check(app.ui.screen == "reputation" and app.ui.reputation_lines() == [talking.say.greets], "the third greeting adds only the locked reputation row in the clean session")
	helper.check(has_label(app.ui, "“%s”" % talking.say.greets[0]) and has_label(app.ui, talking.say.greets[1]), "the native reputation panel shows the greeting and its source")
	await master_shot(app, 15)
	await click(app, app.chapter.rep.to_map)

	stage_person(app, "jamal")
	await open_talk(app, "wary")
	await greet(app, initial_trust + reward)
	await ask(app)
	await goodbye(app)
	stage_person(app, "musa")
	await open_talk(app, "wary", "not_learned")
	await greet(app, initial_trust + reward)
	await ask(app)
	await goodbye(app)
	helper.check(app.talking.greeted.size() == talking.people.size(), "each regular has one greeting recorded")


func capture_memories(app: Node3D) -> void:
	helper.check(app.bread_grab.answer("truth"), "the truth answer sets up Salma's memory")
	await capture_memory(app, 5, "salma", 55, "friendly", "grab_truth")
	app.bread_grab.reset()
	helper.check(app.bread_grab.answer("pay"), "the payment answer sets up Salma's memory")
	await capture_memory(app, 6, "salma", 85, "warm", "grab_pay")
	app.bread_grab.reset()

	helper.check(app.market_stall.buy("bread") and app.market_stall.resolve_change(true), "returning extra change sets up Rashid's memory")
	await capture_memory(app, 7, "rashid", 55, "friendly", "returned")
	app.market_stall.reset()
	app.clock.reset()
	app.clock.skip_to(THURSDAY - 1, TEN_AM)
	helper.check(app.market_stall.buy("bread") and app.market_stall.resolve_change(false), "keeping the extra change sets up Rashid's discovery")
	app.clock.skip_to(THURSDAY, TEN_AM)
	app.market_stall.visit()
	await capture_memory(app, 8, "rashid", 17, "wary", "kept")
	app.market_stall.reset()

	helper.check(app.market_stall.buy_at_loom("work") and app.market_stall.wear("work"), "buying and wearing Layla's work clothes sets up her memory")
	await capture_memory(app, 9, "layla", 55, "friendly", "own_cloth")
	app.market_stall.reset()
	await capture_memory(app, 10, "layla", 20, "wary", "traveller")

	helper.check(app.progress.do_daily_job(), "completing the boat job sets up Jamal's memory")
	helper.check(app.market_stall.buy("bread") and app.market_stall.resolve_change(true) and app.market_stall.give_bread(), "giving Faris bread sets up Jamal's other memory")
	await capture_memory(app, 11, "jamal", 55, "friendly", "fed")
	app.market_stall.reset()
	await capture_memory(app, 12, "jamal", 55, "friendly", "boat")

	helper.check(app.progress.try_weight(int(app.data.lesson.false_weight_index)) and app.progress.answer_weight(), "passing the scales lesson sets up Old Musa's memory")
	await capture_memory(app, 13, "musa", 85, "warm", "learned")
	app.progress.setup(app.data)
	app.progress.coins = fair_wallet
	stage_person(app, "musa")
	await open_talk(app, "wary", "not_learned")
	await ask(app)
	helper.check(helper.find_button(app.ui, talking.panel.greet) != null and not has_label(app.ui, talking.panel.greeted), "asking before greeting leaves the greeting available")
	await master_shot(app, 14)
	await goodbye(app)


func capture_memory(app: Node3D, number: int, id: String, trust: int, tier: String, memory: String) -> void:
	app.progress.trust = trust
	app.progress.coins = fair_wallet
	stage_person(app, id)
	await open_talk(app, tier, memory)
	helper.check(helper.find_button(app.ui, talking.panel.greet) != null, "the memory does not consume " + speaker.name + "'s greeting")
	await master_shot(app, number)
	await goodbye(app)


func stage_person(app: Node3D, id: String) -> void:
	for person: Dictionary in talking.people:
		if person.id == id:
			speaker = person
			break
	app.player.position = app.world.point(speaker.place)
	app.player.velocity = Vector3.ZERO
	var toward: Vector3 = app.world.point("sq") - app.player.position
	if speaker.place == "quay":
		toward = app.world.point("pier") - app.player.position
	app.player.yaw = atan2(-toward.x, -toward.z)
	app.player.pitch = 0.0
	app.player.update_camera()
	app.show_screen("market_map")
	helper.check(app.current_place == speaker.place, "fixture positions the player at " + app.data.places[speaker.place].name)


func talk_caption() -> String:
	return str(talking.talk_button).format({"name": speaker.name})


func open_talk(app: Node3D, tier: String, memory: String = "") -> void:
	var caption := talk_caption()
	var button: Button = helper.find_button(app.ui, caption)
	if helper.check(button != null, "visible place action: " + caption):
		helper.check(app.get_viewport().get_visible_rect().encloses(button.get_global_rect()), "place action fits the viewport: " + caption)
		await hit(app, button.get_global_rect().get_center())
	helper.check(app.ui.screen == "talk", caption + " opens the native talk panel")
	var kicker := str(talking.panel.kicker).format({"place": app.data.places[speaker.place].name})
	var title := "%s, %s" % [speaker.name, speaker.role]
	helper.check(has_label(app.ui, kicker) and has_label(app.ui, title), "the panel identifies " + speaker.name + " and their place")
	for key: String in speaker.tier:
		helper.check(has_label(app.ui, speaker.tier[key]) == (key == tier), speaker.name + " shows only the " + tier + " trust line: " + key)
	for key: String in speaker.facts:
		helper.check(has_label(app.ui, speaker.facts[key]) == (key == memory), speaker.name + " memory visibility: " + key)
	helper.check(not has_label(app.ui, talking.panel.reply) and not has_label(app.ui, speaker.tip), "new conversation starts without a reply or tip: " + speaker.name)


func greet(app: Node3D, trust: int) -> void:
	await click(app, talking.panel.greet)
	helper.check(has_label(app.ui, talking.panel.reply), speaker.name + " gives the locked greeting reply")
	helper.check(has_label(app.ui, talking.panel.greeted) and helper.find_button(app.ui, talking.panel.greet) == null, "the greeting becomes a label for " + speaker.name)
	helper.check(app.progress.trust == trust, "trust after greeting " + speaker.name + " is " + str(trust))


func ask(app: Node3D) -> void:
	await click(app, talking.panel.ask)
	helper.check(has_label(app.ui, speaker.tip), speaker.name + " gives their locked market tip")


func goodbye(app: Node3D) -> void:
	await click(app, talking.panel.bye)
	helper.check(app.ui.screen == "market_map" and app.current_place == speaker.place, "Goodbye returns to the same market map place")


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
	state.greeted = app.talking.greeted.keys()
	state.bread_grab_answer = app.bread_grab.answer_id
	state.change_state = app.market_stall.change_state
	state.worn = app.market_stall.worn_clothes
	state.boat_job_done = app.progress.boat_job_done
	if app.ui.screen == "talk":
		state.speaker = speaker.id
	if app.ui.screen == "reputation":
		state.lines = app.ui.reputation_lines()


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE13_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("TALKING NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
