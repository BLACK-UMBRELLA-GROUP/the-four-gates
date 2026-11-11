extends "res://tests/capture_identity.gd"
## DOC-TFG-0095: native talk-panel evidence for LOCK 28 V1.

const Fixture = preload("res://tests/regulars_remember_fixture.gd")
const OUTPUT := "res://../GAME/APPROVED/REGULARS_REMEMBER/BUILT/V1/"
const LOCKED_DATA := "res://../GAME/APPROVED/REGULARS_REMEMBER/RECORD/regulars_remember_data_V1.json"
const MASTER_STEMS := [
	"rm01_rashid__thirty_six_for_thirty",
	"rm02_rashid__still_owe_mansur",
	"rm03_rashid__dice_before_kindness",
	"rm04_rashid__ten_coins_let_go",
	"rm05_rashid__you_waited",
	"rm06_salma__the_jars",
	"rm07_salma__your_fountain",
	"rm08_salma__your_bread",
	"rm09_layla__faris_slate",
	"rm10_layla__the_fountain",
	"rm11_jamal__qasims_boat",
	"rm12_jamal__because_of_you",
	"rm13_jamal__allah_knows_who",
	"rm14_musa__then_the_kaaba",
	"rm15_musa__someone_paid",
	"rm16_musa__al_hasib",
	"rm17_layla__no_memory_yet",
]
const STATES := [
	["spice", "loan_riba"],
	["spice", "loan_demand"],
	["spice", "dice_seen", "loan_forgive"],
	["spice", "loan_forgive"],
	["spice", "loan_wait"],
	["board", "jars_seen", "fountain_named"],
	["board", "fountain_named", "feeds"],
	["board", "feeds"],
	["weaver", "school", "fountain_named"],
	["weaver", "fountain_named"],
	["quay", "jars_seen"],
	["quay", "umrah_jamal"],
	["quay", "umrah_jamal_secret"],
	["scales", "umrah_musa", "name_hasib"],
	["scales", "umrah_musa_secret", "name_hasib"],
	["scales", "name_hasib"],
	["weaver", ""],
]
const THURSDAY := 36
const TRUST := 45
const COINS := 198

var memories: Dictionary


static func evidence_folder() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--regulars-remember-output="):
			return argument.trim_prefix("--regulars-remember-output=")
	return OUTPUT


func run(app: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Regulars remember capture requires the native viewport")
		app.get_tree().quit(1)
		return
	await app.get_tree().process_frame
	output = evidence_folder()
	helper.output = output
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Could not create the regulars remember evidence directory")
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
	helper.report.method = "Native Godot viewport. Production Talk buttons are clicked through viewport-local input. Earlier gameplay methods create each independent history."
	helper.report.fixture = "Fair arrival and the Idris meeting precede each case. Passive time is paused. The player is positioned at the speaker's live marker at 10:00 on Thursday day 36, after public or anonymous pilgrims can return. Wallet and trust are staged at 198 and 45 to match the masters."
	var approved := FileAccess.get_file_as_bytes(LOCKED_DATA)
	helper.check(not approved.is_empty() and approved == FileAccess.get_file_as_bytes("res://data/regulars_remember.json"),
		"runtime dialogue matches LOCK 28 V1 byte for byte")
	memories = JSON.parse_string(approved.get_string_from_utf8()).memories
	app.set_process(false)
	await click(app, app.data.ui.buttons.begin)
	for index in STATES.size():
		if index > 0:
			app.begin_game()
		complete_arrival(app)
		await capture_state(app, index)
	helper.check(helper.report.screenshots.size() == MASTER_STEMS.size(), "all 17 approved states have native captures")
	finish(app)


func complete_arrival(app: Node3D) -> void:
	for beat in app.identity.arrival.beats:
		app.choose_arrival(0)
		app.continue_arrival()
	app.meet_idris_from_arrival()
	for beat in app.identity.teacher.beats:
		app.choose_idris(0)
		app.continue_idris()
	app.leave_idris()
	app.clock.skip_to(3, Fixture.MORNING)
	app.progress.trust = TRUST
	helper.check(app.idris_met and app.ui.screen == "market_map" and app.progress.coins == COINS,
		"fair arrival and the Idris meeting give the gameplay fixture")


func capture_state(app: Node3D, index: int) -> void:
	var fixture: Array = STATES[index]
	var place: String = fixture[0]
	var key: String = fixture[1]
	if fixture.size() > 2:
		helper.check(Fixture.apply_event(app, fixture[2]), "earlier gameplay records " + fixture[2])
	helper.check(Fixture.apply_event(app, key), "earlier gameplay records " + key if not key.is_empty() else "no memory event is staged")
	app.clock.skip_to(THURSDAY, Fixture.MORNING)
	app.progress.trust = TRUST
	app.progress.coins = COINS
	app.player.position = app.world.point(place)
	app.player.velocity = Vector3.ZERO
	var towards: Vector3 = app.world.point("pier" if place == "quay" else "sq") - app.player.position
	app.player.yaw = atan2(-towards.x, -towards.z)
	app.player.pitch = 0.0
	app.player.update_camera()
	app.show_screen("market_map")
	helper.check(app.current_place == place and app.day == THURSDAY and app.minute_of_day == Fixture.MORNING,
		"live market at the witness's place on Thursday at 10:00: " + MASTER_STEMS[index])
	await click(app, app.talking.button_at(place))
	var regular: Dictionary = app.talking.regular_at(place)
	if not helper.check(app.ui.screen == "talk" and app.talking.person == regular, "the actual Talk button opens " + regular.name):
		return
	var expected: Array[String] = [regular.tier.friendly]
	match regular.id:
		"layla":
			expected.append(regular.facts.traveller)
		"musa":
			expected.append(regular.facts.not_learned)
	for entry: Array in memories[regular.id]:
		if entry[0] == key:
			expected.append(entry[1])
			break
	var labels := Fixture.story_lines(app.ui.content)
	var actual: Array[String] = []
	for label in labels:
		actual.append(label.get_parsed_text())
	helper.check(actual == expected, "exact tier, prior fact and at most one memory in order: " + MASTER_STEMS[index])
	for caption: String in [app.talking.data.panel.greet, app.talking.data.panel.ask, app.talking.data.panel.bye]:
		var button := helper.find_button(app.ui, caption)
		helper.check(button != null and not labels.is_empty()
			and button.get_global_rect().position.y >= labels[-1].get_global_rect().end.y
			and app.get_viewport().get_visible_rect().encloses(button.get_global_rect()),
			"existing button fits below the dialogue: " + caption)
	for label in labels:
		helper.check(app.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "visible dialogue fits: " + label.get_parsed_text())

	var filename: String = MASTER_STEMS[index] + "__build.png"
	await shot(app, filename)
	var state: Dictionary = helper.report.states[filename]
	state.speaker = regular.id
	state.day = app.day
	state.minute_of_day = app.minute_of_day
	state.place = place
	state.events = fixture.slice(1)
	state.story_lines = actual
	await click(app, app.talking.data.panel.bye)
	helper.check(app.ui.screen == "market_map" and app.current_place == place, "Goodbye returns to the witness's place")


func finish(app: Node3D) -> void:
	var file := FileAccess.open(output.path_join("LINE35_CHECKS.json"), FileAccess.WRITE)
	helper.check(file != null, "native checks receipt is writable")
	helper.report.failures = helper.failures
	if file != null:
		file.store_string(JSON.stringify(helper.report, "\t") + "\n")
		file.close()
	print("REGULARS REMEMBER NATIVE ", "PASS" if helper.failures == 0 else "FAIL", " ", helper.report.checks.size(), " checks; ", helper.report.screenshots.size(), " captures")
	app.get_tree().quit(0 if helper.failures == 0 else 1)
