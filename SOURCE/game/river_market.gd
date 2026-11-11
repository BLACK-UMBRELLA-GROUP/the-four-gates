extends Node3D
## River Market arrival, prayer, movement, tasks and chapter progression.

const Foundations = preload("res://game/foundations.gd")
const MarketWorld = preload("res://game/market_world.gd")
const MarketPlayer = preload("res://game/market_player.gd")
const MarketUI = preload("res://game/market_ui.gd")
const TaskProgress = preload("res://game/task_progress.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")
const HijriCalendar = preload("res://game/hijri_calendar.gd")
const Ramadan = preload("res://game/ramadan.gd")
const EidAlFitr = preload("res://game/eid_al_fitr.gd")
const EidAlAdha = preload("res://game/eid_al_adha.gd")
const Zakat = preload("res://game/zakat.gd")
const Pilgrims = preload("res://game/pilgrims.gd")
const QuransSchool = preload("res://game/qurans_school.gd")
const NamesOfAllah = preload("res://game/names_of_allah.gd")
const OpenPurse = preload("res://game/open_purse.gd")
const BreadGrab = preload("res://game/bread_grab.gd")
const MarketStall = preload("res://game/market_stall.gd")
const Talking = preload("res://game/talking.gd")
const MarketDay = preload("res://game/market_day.gd")
const Feeding = preload("res://game/feeding.gd")
const IftarGiving = preload("res://game/iftar_giving.gd")
const SealedPurse = preload("res://game/sealed_purse.gd")
const DiceHouse = preload("res://game/dice_house.gd")
const QasimsJars = preload("res://game/qasims_jars.gd")
const JabirsGoats = preload("res://game/jabirs_goats.gd")
const IdrisRecovery = preload("res://game/idris_recovery.gd")
const DryFountain = preload("res://game/dry_fountain.gd")
const RashidsLoan = preload("res://game/rashids_loan.gd")
const Partnership = preload("res://game/partnership.gd")
const HarmInTheRoad = preload("res://game/harm_in_the_road.gd")

const MarketSave = preload("res://game/market_save.gd")
const RealPrayerTimes = preload("res://game/real_prayer_times.gd")
const PAUSE_SCREENS := ["pause", "settings"]
const REMINDER_EXCLUDED_SCREENS := ["title", "all_prayers_title", "settings"]
const SAVE_FILENAME := "market.save"
const SETTINGS_FILENAME := "settings.cfg"

var storage_directory := "user://"
var menus: Dictionary
var reminder: Dictionary
var reminder_time_source := Callable(Time, "get_unix_time_from_system")
var _settings_return := "title"
var _pause_return := "market_map"
var _large_text := false
var _fast_walk := false
var _reminder_on := false
var _reminder_city := 0
var _reminder_hanafi := false
var _reminder_seen: Dictionary = {}
var _reminder_next_check := 0
var _reminder_date := ""
var _reminder_events: Array[int] = []
var _reminder_previous_date := ""
var _reminder_previous_events: Array[int] = []
var data: Dictionary
var identity: Dictionary
var chapter: Dictionary
var open_purse := OpenPurse.new()
var bread_grab := BreadGrab.new()
var market_stall := MarketStall.new()
var talking := Talking.new()
var feeding := Feeding.new()
var iftar_giving: IftarGiving
var sealed_purse := SealedPurse.new()
var dice_house := DiceHouse.new()
var qasims_jars := QasimsJars.new()
var jabirs_goats := JabirsGoats.new()
var idris_recovery := IdrisRecovery.new()
var dry_fountain := DryFountain.new()
var rashids_loan := RashidsLoan.new()
var partnership := Partnership.new()
var harm_in_the_road := HarmInTheRoad.new()
var world: Node3D
var player: CharacterBody3D
var ui: CanvasLayer
var clock: PrayerClock
var ramadan: Ramadan
var eid_al_fitr: EidAlFitr
var eid_al_adha: EidAlAdha
var zakat: Zakat
var pilgrims: Pilgrims
var qurans_school: QuransSchool
var names_of_allah: NamesOfAllah
var market_day: MarketDay
var night: bool:
	get: return clock.night
var current_place := ""
var destination := ""
var route: Array[Vector3] = []
var capture_runner: RefCounted
var progress := TaskProgress.new()
var arrival_beat := 0
var arrival_reply := ""
var arrival_fair = null
var idris_beat := 0
var known_words: Dictionary = {}
var idris_met := false
var paid_nights := 0
var day: int:
	get: return clock.day
var minute_of_day: int:
	get: return clock.minute_of_day
var _daily_job_day := 0
var _arrival_sunset := false
var _idris_reply := ""
var _idris_new_word := ""
var _record_return_screen := "game"
var _calendar_return_screen := "market_map"
var _prayer_adhan: Variant = null

func _ready() -> void:
	var capture_args := OS.get_cmdline_user_args()
	if "--capture-menus" in capture_args and not _set_capture_storage("--menus-user-dir="):
		return
	if "--capture-prayer-reminder" in capture_args and not _set_capture_storage("--reminder-user-dir="):
		return
	if "--capture-partnership" in capture_args and not _set_capture_storage("--partnership-user-dir="):
		return
	menus = Foundations.load_menus()
	reminder = Foundations.load_prayer_reminder()
	data = Foundations.load_data()
	identity = Foundations.load_identity()
	chapter = Foundations.load_chapter1()
	var calendar := HijriCalendar.new(Foundations.load_calendar(), int(identity.arrival.inn_night))
	clock = PrayerClock.new(identity.clock, calendar)
	ramadan = Ramadan.new(Foundations.load_ramadan(), clock)
	eid_al_fitr = EidAlFitr.new(Foundations.load_eid_al_fitr(), clock)
	market_day = MarketDay.new(Foundations.load_market_day(), clock, Foundations.load_regulars_at_prayer())
	Foundations.configure_input(data)
	progress.setup(data)
	zakat = Zakat.new(Foundations.load_zakat(), clock, progress)
	pilgrims = Pilgrims.new(Foundations.load_pilgrims(), clock, progress)
	idris_recovery.setup(Foundations.load_idris_recovery(), progress)
	qurans_school = QuransSchool.new(Foundations.load_qurans_school(), clock, progress)
	names_of_allah = NamesOfAllah.new(Foundations.load_names_of_allah())
	open_purse.setup(chapter, progress, clock)
	bread_grab.setup(chapter, progress, clock)
	market_stall.setup(Foundations.load_market_stall(), Foundations.load_clothes(), progress, clock)
	talking.setup(Foundations.load_talking(), progress, bread_grab, market_stall, Foundations.load_regulars_remember().memories)
	feeding.setup(Foundations.load_feeding(), progress, clock)
	iftar_giving = IftarGiving.new(ramadan)
	iftar_giving.setup(Foundations.load_iftar_giving(), progress, clock, feeding.meal_counter)
	# LOCK 10's hours match the clock data's 06:30 start and 18:10 Maghrib.
	var karim_opens := _minutes(str(identity.clock.start).get_slice(" ", 0))
	var maghrib: Array = identity.clock.prayers.filter(func(prayer): return prayer.name == "Maghrib")
	var karim_closes := _minutes(maghrib[0].begins)
	sealed_purse.setup(Foundations.load_sealed_purse(), progress, market_day, karim_opens, karim_closes)
	dice_house.setup(Foundations.load_dice_house(), progress, clock)
	qasims_jars.setup(Foundations.load_qasims_jars(), progress, clock)
	jabirs_goats.setup(Foundations.load_jabirs_goats(), progress, clock)
	eid_al_adha = EidAlAdha.new(Foundations.load_eid_al_adha(), clock, progress, jabirs_goats, feeding.meal_counter)
	dry_fountain.setup(Foundations.load_dry_fountain(), progress, clock)
	rashids_loan.setup(Foundations.load_rashids_loan(), progress, clock, market_day)
	partnership.setup(Foundations.load_partnership(), progress, clock, market_day)
	harm_in_the_road.setup(Foundations.load_harm_in_the_road(), clock)
	world = MarketWorld.new()
	add_child(world)
	world.setup(data)
	world.setup_chapter_people(chapter, talking.data.people)
	world.setup_sealed_purse_people(
		str(sealed_purse.data.offer.title).get_slice(" ", 0),
		str(sealed_purse.data.deliver.title).get_slice(" ", 0))
	player = MarketPlayer.new()
	add_child(player)
	player.setup(data)
	player.position = world.point(data.start_place)
	ui = MarketUI.new()
	add_child(ui)
	ui.menus = menus
	ui.reminder = reminder
	ui.partnership = partnership
	ui.setup(data, progress, identity, clock, chapter, open_purse, bread_grab, market_stall, talking, market_day, Foundations.load_prayer_record(), feeding, sealed_purse, dice_house, qasims_jars, jabirs_goats, idris_recovery, dry_fountain, rashids_loan, harm_in_the_road, ramadan, iftar_giving, eid_al_fitr, zakat, eid_al_adha, pilgrims, qurans_school, names_of_allah)
	ui.known_words = known_words
	ui.begin_requested.connect(begin_game)
	ui.continue_requested.connect(continue_game)
	ui.settings_requested.connect(open_settings)
	ui.settings_closed.connect(close_settings)
	ui.menu_setting_changed.connect(change_menu_setting)
	ui.reminder_city_changed.connect(change_reminder_city)
	ui.reminder_answered.connect(_answer_reminder)
	ui.resume_requested.connect(_resume_game)
	ui.save_requested.connect(save_game)
	_load_settings()
	ui.arrival_choice_requested.connect(choose_arrival)
	ui.arrival_continue_requested.connect(continue_arrival)
	ui.arrival_walk_requested.connect(walk_from_arrival)
	ui.arrival_meet_requested.connect(meet_idris_from_arrival)
	ui.idris_choice_requested.connect(choose_idris)
	ui.idris_continue_requested.connect(continue_idris)
	ui.idris_leave_requested.connect(leave_idris)
	ui.idris_replay_requested.connect(replay_idris)
	ui.screen_requested.connect(show_screen)
	ui.wait_requested.connect(wait_until_next_prayer)
	ui.pray_requested.connect(pray_here)
	ui.make_up_requested.connect(make_up_prayer)
	ui.record_requested.connect(show_prayer_record)
	ui.record_closed.connect(close_prayer_record)
	ui.calendar_requested.connect(_show_calendar)
	ui.calendar_closed.connect(_close_calendar)
	ui.calendar_rest_requested.connect(_rest_for_days)
	ui.ramadan_requested.connect(_do_ramadan_action)
	ui.night_prayer_requested.connect(_stand_at_night)
	ui.fitr_requested.connect(_show_fitr)
	ui.fitr_paid.connect(_pay_fitr)
	ui.eid_prayer_requested.connect(_pray_eid)
	ui.adha_requested.connect(_do_adha_action)
	ui.adha_sheep_bought.connect(_buy_adha_sheep)
	ui.adha_sacrifice_chosen.connect(_sacrifice_adha_sheep)
	ui.zakat_requested.connect(_show_zakat)
	ui.zakat_paid.connect(_pay_zakat)
	ui.pilgrims_requested.connect(_show_pilgrims)
	ui.pilgrim_sent.connect(_send_pilgrim)
	ui.qurans_school_requested.connect(_show_qurans_school)
	ui.qurans_school_paid.connect(_pay_qurans_school)
	ui.calligraphy_requested.connect(_read_calligraphy)
	clock.adhan_started.connect(_show_adhan)
	ui.use_requested.connect(use_place)
	ui.goal_requested.connect(show_goal)
	ui.destination_requested.connect(walk_to_place)
	ui.task_requested.connect(open_task)
	ui.choice_requested.connect(choose_task)
	ui.amend_requested.connect(amend_task)
	ui.daily_job_requested.connect(do_daily_job)
	ui.weight_requested.connect(try_weight)
	ui.answer_requested.connect(answer_weight)
	ui.purse_requested.connect(show_open_purse)
	ui.salma_requested.connect(ask_salma)
	ui.page_requested.connect(read_page_one)
	ui.page_closed.connect(return_to_purse)
	ui.gift_requested.connect(give_from_purse)
	ui.end_purse_day_requested.connect(end_purse_day)
	ui.bread_grab_requested.connect(show_bread_grab)
	ui.bread_grab_left.connect(leave_bread_grab)
	ui.bread_grab_ask_requested.connect(ask_about_bread)
	ui.bread_grab_answered.connect(answer_bread_grab)
	ui.bag_requested.connect(show_bag)
	ui.purchase_requested.connect(buy_stall_item)
	ui.change_answered.connect(resolve_stall_change)
	ui.loom_purchase_requested.connect(buy_loom_item)
	ui.wear_requested.connect(wear_clothes)
	ui.bread_given.connect(give_bread_to_faris)
	ui.talk_requested.connect(show_talking)
	ui.greeting_requested.connect(greet_regular)
	ui.tip_requested.connect(ask_regular)
	ui.feeding_requested.connect(show_feeding)
	ui.feeding_paid.connect(pay_for_feeding)
	ui.iftar_giving_requested.connect(show_iftar_giving)
	ui.iftar_giving_paid.connect(pay_for_iftar)
	ui.dry_fountain_requested.connect(show_dry_fountain)
	ui.dry_fountain_paid.connect(pay_for_dry_fountain)
	ui.loan_requested.connect(show_rashids_loan)
	ui.loan_answered.connect(answer_rashids_loan)
	ui.partnership_requested.connect(show_partnership)
	ui.partnership_answered.connect(answer_partnership)
	ui.road_harm_requested.connect(move_road_harm)
	ui.sealed_purse_offered.connect(show_sealed_purse_offer)
	ui.sealed_purse_accepted.connect(accept_sealed_purse)
	ui.sealed_purse_coin_chosen.connect(choose_sealed_purse_coin)
	ui.sealed_purse_delivered.connect(deliver_sealed_purse)
	ui.dice_door_opened.connect(open_dice_house)
	ui.dice_invitation_answered.connect(answer_dice_invitation)
	ui.dice_bet_placed.connect(bet_at_dice_house)
	ui.dice_house_left.connect(leave_dice_house)
	ui.qasims_offer_opened.connect(show_qasims_offer)
	ui.qasims_offer_answered.connect(answer_qasims_offer)
	ui.qasims_done_left.connect(leave_qasims_done)
	ui.jabirs_offer_opened.connect(show_jabirs_offer)
	ui.jabirs_offer_answered.connect(answer_jabirs_offer)
	ui.jabirs_result_left.connect(leave_jabirs_result)
	show_screen("title")
	update_state()
	if "--capture-foundations" in OS.get_cmdline_user_args():
		capture_runner = preload("res://tests/capture_foundations.gd").new()
		capture_runner.run(self)
	elif "--capture-tasks" in OS.get_cmdline_user_args():
		capture_runner = preload("res://tests/capture_tasks.gd").new()
		capture_runner.run(self)
	elif "--capture-gate" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_gate.gd").new()
		capture_runner.run(self)
	elif "--capture-identity" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_identity.gd").new()
		capture_runner.run(self)
	elif "--capture-arrival" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_arrival.gd").new()
		capture_runner.run(self)
	elif "--capture-clock" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_clock.gd").new()
		capture_runner.run(self)
	elif "--capture-idris" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_idris.gd").new()
		capture_runner.run(self)
	elif "--capture-open-purse" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_open_purse.gd").new()
		capture_runner.run(self)
	elif "--capture-bread-grab" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_bread_grab.gd").new()
		capture_runner.run(self)
	elif "--capture-market-stall" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_market_stall.gd").new()
		capture_runner.run(self)
	elif "--capture-clothes" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_clothes.gd").new()
		capture_runner.run(self)
	elif "--capture-talking" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_talking.gd").new()
		capture_runner.run(self)
	elif "--capture-market-day" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_market_day.gd").new()
		capture_runner.run(self)
	elif "--capture-prayer-record" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_prayer_record.gd").new()
		capture_runner.run(self)
	elif "--capture-feeding" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_feeding.gd").new()
		capture_runner.run(self)
	elif "--capture-sealed-purse" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_sealed_purse.gd").new()
		capture_runner.run(self)
	elif "--capture-dice-house" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_dice_house.gd").new()
		capture_runner.run(self)
	elif "--capture-qasims-jars" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_qasims_jars.gd").new()
		capture_runner.run(self)
	elif "--capture-jabirs-goats" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_jabirs_goats.gd").new()
		capture_runner.run(self)
	elif "--capture-idris-recovery" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_idris_recovery.gd").new()
		capture_runner.run(self)
	elif "--capture-dry-fountain" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_dry_fountain.gd").new()
		capture_runner.run(self)
	elif "--capture-rashids-loan" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_rashids_loan.gd").new()
		capture_runner.run(self)
	elif "--capture-partnership" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_partnership.gd").new()
		capture_runner.run(self)
	elif "--capture-harm-in-the-road" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_harm_in_the_road.gd").new()
		capture_runner.run(self)
	elif "--capture-calendar" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_calendar.gd").new()
		capture_runner.run(self)
	elif "--capture-ramadan" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_ramadan.gd").new()
		capture_runner.run(self)
	elif "--capture-iftar-giving" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_iftar_giving.gd").new()
		capture_runner.run(self)
	elif "--capture-eid-al-fitr" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_eid_al_fitr.gd").new()
		capture_runner.run(self)
	elif "--capture-zakat" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_zakat.gd").new()
		capture_runner.run(self)
	elif "--capture-eid-al-adha" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_eid_al_adha.gd").new()
		capture_runner.run(self)
	elif "--capture-pilgrims" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_pilgrims.gd").new()
		capture_runner.run(self)

	elif "--capture-qurans-school" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_qurans_school.gd").new()
		capture_runner.run(self)
	elif "--capture-names-of-allah" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_names_of_allah.gd").new()
		capture_runner.run(self)
	elif "--capture-regulars-at-prayer" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_regulars_at_prayer.gd").new()
		capture_runner.run(self)
	elif "--capture-regulars-remember" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_regulars_remember.gd").new()
		capture_runner.run(self)
	elif "--capture-menus" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_menus.gd").new()
		capture_runner.run(self)
	elif "--capture-prayer-reminder" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_prayer_reminder.gd").new()
		capture_runner.run(self)


func _set_capture_storage(prefix: String) -> bool:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			storage_directory = argument.trim_prefix(prefix)
	if (storage_directory.is_absolute_path() and not storage_directory.begins_with("user://")
			and not FileAccess.file_exists(storage_directory.path_join(SAVE_FILENAME))
			and not FileAccess.file_exists(storage_directory.path_join(SETTINGS_FILENAME))):
		return true
	push_error("Pass a fresh absolute fixture directory using " + prefix)
	set_process(false)
	set_physics_process(false)
	get_tree().quit(1)
	return false

func _process(delta: float) -> void:
	if _reminder_on and Time.get_ticks_msec() >= _reminder_next_check:
		_reminder_next_check = Time.get_ticks_msec() + int(reminder.numbers.check_seconds) * 1000
		_poll_reminder(int(reminder_time_source.call()))
	if ui.screen in PAUSE_SCREENS:
		return
	if ui.screen not in ["title", "arrival", "all_prayers_title"]:
		clock.advance_seconds(delta)
	update_state()

func _physics_process(_delta: float) -> void:
	if ui.screen in PAUSE_SCREENS:
		return
	if ui.screen not in ["game", "market_map"]:
		player.test_move_axis = Vector2.ZERO
		return
	if route.is_empty():
		return
	var offset := route[0] - player.position
	offset.y = 0
	var arrival: float = data.player.use_radius if route.size() == 1 else data.player.capsule_radius
	if offset.length() < arrival:
		route.pop_front()
		if route.is_empty():
			player.test_move_axis = Vector2.ZERO
		return
	var local := offset.rotated(Vector3.UP, -player.yaw).normalized()
	player.test_move_axis = Vector2(local.x, local.z)

func update_state() -> void:
	if not is_instance_valid(player) or not is_instance_valid(ui):
		return
	current_place = ""
	var nearest: float = data.player.use_radius
	for id in data.places:
		var point: Vector3 = world.point(id)
		var distance := Vector2(player.position.x, player.position.z).distance_to(Vector2(point.x, point.z))
		if distance <= nearest:
			nearest = distance
			current_place = id
	if day != _daily_job_day:
		_daily_job_day = day
		progress.morning()
	var world_night: bool = night or ui.screen in ["title", "settings", "all_prayers", "all_prayers_title", "calendar", "iftar", "iftar_giving", "fitr"] or (ui.screen == "arrival" and _arrival_sunset)
	if world.night != world_night:
		world.set_night(world_night)
	zakat.assess_years()
	pilgrims.resolve_returns()
	ui.refresh(player.position, current_place, night, _salma_available())

func _load_settings() -> void:
	var settings := ConfigFile.new()
	if settings.load(storage_directory.path_join(SETTINGS_FILENAME)) == OK:
		_large_text = settings.get_value("settings", "large_text", false) == true
		_fast_walk = settings.get_value("settings", "fast_walk", false) == true
		_reminder_on = settings.get_value("prayer_reminder", "enabled", false) == true
		var saved_city: Variant = settings.get_value("prayer_reminder", "city", "")
		for index in reminder.cities.size():
			if reminder.cities[index][0] == saved_city:
				_reminder_city = index
				break
		_reminder_hanafi = settings.get_value("prayer_reminder", "hanafi", false) == true
		var seen: Variant = settings.get_value("prayer_reminder", "shown", {})
		if seen is Dictionary:
			_reminder_seen = seen
	_apply_settings()


func _apply_settings() -> void:
	ui.large_text = _large_text
	ui.fast_walk = _fast_walk
	ui.reminder_on = _reminder_on
	ui.reminder_city = _reminder_city
	ui.reminder_hanafi = _reminder_hanafi
	var text_multiplier: float = float(menus.numbers.large_text_percent) / 100.0 if _large_text else 1.0
	ui.text_multiplier = text_multiplier
	world.set_text_multiplier(text_multiplier)
	player.walk_multiplier = float(menus.numbers.walk_fast) / float(menus.numbers.walk_normal) if _fast_walk else 1.0


func open_settings() -> void:
	if ui.screen not in ["pause", "title"]:
		return
	_settings_return = ui.screen
	_update_reminder_today(int(reminder_time_source.call()))
	show_screen("settings")


func close_settings() -> void:
	if ui.screen == "settings":
		show_screen(_settings_return)


func change_menu_setting(setting: String, enabled: bool) -> void:
	if ui.screen != "settings":
		return
	match setting:
		"large_text":
			if not _write_setting("settings", setting, enabled):
				return
			_large_text = enabled
		"fast_walk":
			if not _write_setting("settings", setting, enabled):
				return
			_fast_walk = enabled
		"reminder_enabled":
			if not _write_setting("prayer_reminder", "enabled", enabled):
				return
			_reminder_on = enabled
		"reminder_hanafi":
			if not _reminder_on or not _write_setting("prayer_reminder", "hanafi", enabled):
				return
			_reminder_hanafi = enabled
		_:
			return
	_refresh_settings()


func change_reminder_city(index: int) -> void:
	if ui.screen != "settings" or not _reminder_on or index < 0 or index >= reminder.cities.size():
		return
	if _write_setting("prayer_reminder", "city", reminder.cities[index][0]):
		_reminder_city = index
	_refresh_settings()


func _refresh_settings() -> void:
	_reminder_date = ""
	_reminder_next_check = 0
	_apply_settings()
	_update_reminder_today(int(reminder_time_source.call()))
	ui.show_screen("settings")


func _write_setting(section: String, key: String, value: Variant) -> bool:
	var filename := storage_directory.path_join(SETTINGS_FILENAME)
	var settings := ConfigFile.new()
	if FileAccess.file_exists(filename) and settings.load(filename) != OK:
		settings.clear()
	settings.set_value(section, key, value)
	var pending := "%s.pending-%d" % [filename, OS.get_process_id()]
	var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(storage_directory))
	if error == OK:
		error = settings.save(pending)
	if error == OK:
		error = DirAccess.rename_absolute(pending, filename)
	if error != OK:
		push_error("Could not write game settings: " + error_string(error))
	return error == OK


func _update_reminder_today(now: int) -> Dictionary:
	if not _reminder_on:
		return {}
	var city: Array = reminder.cities[_reminder_city]
	var date := RealPrayerTimes.local_date(now, city[3])
	if date.is_empty():
		return {}
	var key := _reminder_date_key(date)
	if key != _reminder_date:
		_reminder_events = RealPrayerTimes.times(date, city, reminder.numbers, _reminder_hanafi)
		var previous_day := Time.get_unix_time_from_datetime_dict(date) - 86400
		var previous_date := Time.get_date_dict_from_unix_time(previous_day)
		_reminder_previous_date = _reminder_date_key(previous_date)
		_reminder_previous_events = RealPrayerTimes.times(previous_date, city, reminder.numbers, _reminder_hanafi)
		var values := PackedStringArray()
		for index in _reminder_events.size():
			values.append("%s %s" % [reminder.prayers[index], RealPrayerTimes.local_time(_reminder_events[index], city[3])])
		_reminder_date = key
		ui.set_reminder_today(str(reminder.settings.today).format({"city": city[0], "times": " · ".join(values)}))
	return date


func _poll_reminder(now: int) -> void:
	if not _reminder_on or ui.screen in ["title", "all_prayers_title"]:
		return
	var date := _update_reminder_today(now)
	if date.is_empty() or ui.screen == "settings":
		return
	var window := int(reminder.numbers.late_minutes) * 60
	if not _show_due_reminder(now, window, _reminder_date, _reminder_events):
		# The previous prayer day's Isha can be at or after local midnight.
		_show_due_reminder(now, window, _reminder_previous_date, _reminder_previous_events)


func _show_due_reminder(now: int, window: int, date: String, events: Array[int]) -> bool:
	var seen: Array = _reminder_seen.get(date, [])
	for index in events.size():
		var elapsed := now - events[index]
		if elapsed < 0 or elapsed > window or index in seen:
			continue
		seen.append(index)
		_reminder_seen[date] = seen
		# Retain the two neighbouring dates for midnight and city changes.
		var day_start := Time.get_unix_time_from_datetime_string(date)
		for old_date in _reminder_seen.keys():
			if absi(Time.get_unix_time_from_datetime_string(old_date) - day_start) > 86400:
				_reminder_seen.erase(old_date)
		_write_setting("prayer_reminder", "shown", _reminder_seen)
		ui.show_reminder_banner(reminder.prayers[index], reminder.cities[_reminder_city][0])
		_update_mouse_mode()
		return true
	return false


func _reminder_date_key(date: Dictionary) -> String:
	return "%04d-%02d-%02d" % [date.year, date.month, date.day]


func _answer_reminder(pause_for_prayer: bool) -> void:
	ui.hide_reminder_banner()
	if pause_for_prayer and ui.screen != "pause":
		_pause_return = ui.screen
		show_screen("pause")
	else:
		_update_mouse_mode()


func _resume_game() -> void:
	var destination_screen := _pause_return
	_pause_return = "market_map"
	show_screen(destination_screen)


func _update_mouse_mode() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if ui.screen == "game" and not ui.has_reminder_banner() else Input.MOUSE_MODE_VISIBLE


func save_game(quit_to_title: bool) -> void:
	if ui.screen != "pause":
		return
	var error := MarketSave.save_slot(self, storage_directory.path_join(SAVE_FILENAME))
	if error != OK:
		push_error("Could not save the game: " + error_string(error))
		return
	if quit_to_title:
		show_screen("title")
	else:
		ui.saved_date = clock.time_label(day, minute_of_day)
		ui.show_screen("pause")


func continue_game() -> void:
	if ui.screen != "title":
		return
	var saved := MarketSave.read_slot(storage_directory.path_join(SAVE_FILENAME))
	if saved.is_empty():
		show_screen("title")
		return
	MarketSave.restore(self, saved)
	show_screen("market_map")


func begin_game() -> void:
	progress.setup(data)
	idris_recovery.reset(progress.trust)
	open_purse.reset()
	bread_grab.reset()
	market_stall.reset()
	talking.reset()
	feeding.reset()
	iftar_giving.reset()
	sealed_purse.reset()
	dice_house.reset()
	qasims_jars.reset()
	jabirs_goats.reset()
	dry_fountain.reset()
	rashids_loan.reset()
	partnership.reset()
	harm_in_the_road.reset()
	world.stop_faris_run()
	world.set_inn_people_waiting(true)
	world.reset_gate()
	arrival_beat = 0
	arrival_reply = ""
	arrival_fair = null
	idris_beat = 0
	_idris_reply = ""
	_idris_new_word = ""
	_daily_job_day = 0
	idris_met = false
	ui.idris_met = false
	known_words.clear()
	paid_nights = 0
	clock.reset()
	ramadan.reset()
	eid_al_fitr.reset()
	eid_al_adha.reset()
	zakat.reset()
	pilgrims.reset()
	qurans_school.reset()
	names_of_allah.reset()
	_arrival_sunset = false
	player.position = world.point(data.start_place)
	player.velocity = Vector3.ZERO
	player.yaw = 0
	player.pitch = 0
	player.update_camera()
	route.clear()
	destination = ""
	player.test_move_axis = Vector2.ZERO
	_show_arrival()

func choose_arrival(index: int) -> void:
	var beats: Array = identity.arrival.beats
	if ui.screen != "arrival" or arrival_beat >= beats.size() or not arrival_reply.is_empty():
		return
	var choices: Array = beats[arrival_beat].choices
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	var effect: Dictionary = choice.effect
	var coin_change := int(effect.get("coins", 0))
	progress.coins += coin_change
	if coin_change < 0:
		paid_nights += 1
	if effect.has("fair"):
		arrival_fair = effect.fair
	if effect.has("time"):
		clock.advance_to(day, int(effect.time), false)
	arrival_reply = choice.reply
	_show_arrival()

func continue_arrival() -> void:
	if ui.screen != "arrival" or arrival_reply.is_empty():
		return
	arrival_beat += 1
	arrival_reply = ""
	var beats: Array = identity.arrival.beats
	if arrival_beat < beats.size():
		# The sunset backdrop begins with the prompt. Its choice applies the time jump.
		for choice: Dictionary in beats[arrival_beat].choices:
			if choice.effect.has("time"):
				_arrival_sunset = true
				break
	_show_arrival()

func walk_from_arrival() -> void:
	if ui.screen != "arrival" or arrival_beat != identity.arrival.beats.size():
		return
	player.position = world.point("inn")
	player.velocity = Vector3.ZERO
	show_screen("market_map")

func _show_arrival() -> void:
	ui.arrival_beat = arrival_beat
	ui.arrival_reply = arrival_reply
	ui.arrival_fair = arrival_fair is bool and arrival_fair
	show_screen("arrival")

func meet_idris_from_arrival() -> void:
	if ui.screen == "arrival" and arrival_beat == identity.arrival.beats.size():
		_start_idris()

func _start_idris() -> void:
	player.position = world.point("masjid")
	player.velocity = Vector3.ZERO
	player.test_move_axis = Vector2.ZERO
	route.clear()
	destination = ""
	idris_beat = 0
	_idris_reply = ""
	_idris_new_word = ""
	_show_idris()

func choose_idris(index: int) -> void:
	var beats: Array = identity.teacher.beats
	if ui.screen != "idris" or idris_beat >= beats.size() or not _idris_reply.is_empty():
		return
	var choices: Array = beats[idris_beat].choices
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	if choice.learns != null and identity.language.words.has(choice.learns) and not known_words.has(choice.learns):
		known_words[choice.learns] = true
		_idris_new_word = choice.learns
	_idris_reply = choice.reply
	_show_idris()

func continue_idris() -> void:
	if ui.screen != "idris" or _idris_reply.is_empty():
		return
	idris_beat += 1
	_idris_reply = ""
	_idris_new_word = ""
	if idris_beat == identity.teacher.beats.size():
		idris_met = true
		ui.idris_met = true
	_show_idris()

func leave_idris() -> void:
	if ui.screen == "idris":
		show_screen("market_map")

func replay_idris() -> void:
	if ui.screen == "idris" and idris_beat == identity.teacher.beats.size():
		_start_idris()

func _show_idris() -> void:
	ui.idris_beat = idris_beat
	ui.idris_reply = _idris_reply
	ui.idris_new_word = _idris_new_word
	ui.known_words = known_words
	show_screen("idris")

func _minutes(time: String) -> int:
	return int(time.get_slice(":", 0)) * 60 + int(time.get_slice(":", 1))

func show_screen(screen: String) -> void:
	var previous: String = ui.screen
	if screen == "pause" and previous != "settings":
		ui.saved_date = ""
	if screen == "title":
		_pause_return = "market_map"
		var saved := MarketSave.read_slot(storage_directory.path_join(SAVE_FILENAME))
		ui.continue_date = "" if saved.is_empty() else clock.time_label(saved.day, saved.minute_of_day)
	ui.settings_has_hud = _settings_return == "pause"
	if ui.screen == "zakat" and screen != "zakat" and not (screen == "pause" and _pause_return == "zakat"):
		zakat.close_panel()
	if screen in REMINDER_EXCLUDED_SCREENS:
		ui.hide_reminder_banner()
	elif previous in REMINDER_EXCLUDED_SCREENS:
		_reminder_next_check = 0
	var loan_view: bool = screen in MarketUI.LOAN_SCREENS or (screen == "reputation" and ui.screen in MarketUI.LOAN_SCREENS)
	var partnership_view: bool = screen in MarketUI.PARTNERSHIP_SCREENS
	var partnership_reputation: bool = screen == "reputation" and current_place == "weaver" and partnership.reputation_line() != null
	if screen in ["title", "settings"]:
		world.title_camera.make_current()
	elif partnership_view:
		world.weaver_lane_camera.make_current()
	elif partnership_reputation:
		world.weaver_reputation_camera.make_current()
	elif screen == "pause":
		world.spice_row_camera.make_current()
	elif screen == "feeding" or screen in MarketUI.GRAB_SCREENS:
		world.oven_camera.make_current()
	elif screen in ["iftar_giving", "fitr", "eid", "zakat", "qurans_school", "names_of_allah"]:
		world.iftar_giving_camera.make_current()
	elif screen in MarketUI.DRY_FOUNTAIN_SCREENS or (screen == "reputation" and ui.screen == "fountain_done"):
		world.qasims_done_camera.make_current()
	elif screen in MarketUI.DICE_HOUSE_SCREENS:
		world.dice_house_camera.make_current()
	elif screen == "qasims_offer":
		world.qasims_offer_camera.make_current()
	elif screen == "qasims_done":
		world.qasims_done_camera.make_current()
	elif screen == "sealed_purse_offer":
		world.sealed_purse_offer_camera.make_current()
	elif screen == "sealed_purse_coin":
		world.sealed_purse_coin_camera.make_current()
	elif screen in ["sealed_purse_delivery", "pilgrims"]:
		world.sealed_purse_delivery_camera.make_current()
	elif loan_view or (screen == "reputation" and ui.screen == "sealed_purse_delivery"):
		world.spice_row_camera.make_current()
	elif screen == "harm_done":
		world.sealed_purse_coin_camera.make_current()
	elif screen in MarketUI.JABIRS_GOATS_SCREENS or screen in MarketUI.ADHA_SCREENS:
		world.jabirs_goats_camera.make_current()
	elif screen == "reputation" and (ui.screen == "jabirs_told" or (ui.screen in ["game", "market_map"] and current_place == "gate" and not jabirs_goats.reputation_lines().is_empty())):
		world.jabirs_goats_camera.make_current()
	elif screen != "reputation" or ui.screen != "grab_after":
		player.camera.make_current()
	player.visible = not loan_view and not partnership_view and not partnership_reputation and screen not in ["title", "settings", "pause", "harm_done", "eid", "zakat", "pilgrims", "qurans_school", "names_of_allah"] and screen not in MarketUI.ADHA_SCREENS
	var paused := screen in PAUSE_SCREENS or screen in ["title", "all_prayers_title"]
	player.set_physics_process(not paused)
	world.set_scene_motion_paused(paused)
	ui.show_screen(screen)
	player.enabled = screen == "game" or screen == "market_map"
	_update_mouse_mode()
	update_state()

func wait_until_next_prayer() -> void:
	clock.wait_until_next_prayer()
	update_state()

func _show_adhan(message: String) -> void:
	if _prayer_adhan == null:
		ui.show_toast(message, ui.screen in ["market_map", "all_prayers"])
	else:
		_prayer_adhan = message

func pray_here() -> void:
	update_state()
	_do_prayer(clock.pray.bind(current_place == "masjid"))

func make_up_prayer() -> void:
	_do_prayer(clock.make_up)

func _do_prayer(action: Callable, compact_receipt: bool = false) -> void:
	# An adhan crossed during the ten-minute advance is shown first.
	_prayer_adhan = ""
	var receipt: String = action.call()
	var adhan: String = _prayer_adhan
	_prayer_adhan = null
	update_state()
	var compact: bool = compact_receipt or ui.screen == "market_map"
	if not adhan.is_empty():
		ui.show_toast(adhan, compact, receipt)
	elif not receipt.is_empty():
		ui.show_toast(receipt, compact)

func show_prayer_record() -> void:
	if ui.screen not in ["title", "arrival", "prayer_record", "zakat"] and ui.screen not in MarketUI.ADHA_SCREENS:
		_record_return_screen = ui.screen
		show_screen("prayer_record")

func close_prayer_record() -> void:
	show_screen(_record_return_screen)

func _rest_at_inn() -> void:
	var cost := int(identity.arrival.inn_night)
	var message: String = identity.inn.broom
	if paid_nights > 0:
		paid_nights -= 1
		message = str(identity.inn.paid).format({"n": paid_nights})
	elif progress.coins >= cost:
		progress.coins -= cost
		message = str(identity.inn.coins).format({"n": cost})
	clock.advance_to(day + 1, _minutes(str(identity.inn.wakes_at).get_slice(" ", 0)), false)
	update_state()
	ui.show_toast(message, ui.screen == "market_map")

func _show_calendar() -> void:
	if current_place == "inn" and ui.screen in ["game", "market_map"]:
		_stop_travel()
		_calendar_return_screen = ui.screen
		show_screen("calendar")

func _close_calendar() -> void:
	show_screen(_calendar_return_screen)

func _rest_for_days(days: int) -> void:
	var calendar := clock.calendar
	if ui.screen != "calendar" or current_place != "inn" or not calendar.rest_days.has(days):
		return
	var cost := calendar.rest_cost(days)
	if progress.coins < cost:
		return
	progress.coins -= cost
	var wake_minute := int(calendar.data.numbers.wake_minute)
	ramadan.rest_until(day + days, wake_minute)
	clock.skip_to(day + days, wake_minute, true)
	_close_calendar()
	var fields := clock.date_fields(day)
	fields.n = days
	ui.show_toast(str(calendar.data.rested_toast).format(fields), ui.screen == "market_map")

func _do_ramadan_action(action: Ramadan.Action) -> void:
	if ui.screen not in ["game", "market_map"]:
		return
	update_state()
	if not ramadan.take(action, current_place):
		return
	match action:
		Ramadan.Action.SUHOOR:
			update_state()
			ui.show_toast(ramadan.data.suhoor_toast, ui.screen == "market_map")
		Ramadan.Action.IFTAR:
			_stop_travel()
			show_screen("iftar")
		Ramadan.Action.TARAWIH:
			_do_prayer(func() -> String:
				clock.advance_to(day, minute_of_day + int(ramadan.data.numbers.tarawih_minutes))
				return ramadan.data.tarawih_toast
			)


func _stand_at_night() -> void:
	if ui.screen not in ["game", "market_map"]:
		return
	update_state()
	if eid_al_fitr.stand_at_night(current_place):
		_do_prayer(func() -> String:
			clock.advance_to(day, minute_of_day + int(eid_al_fitr.data.numbers.night_minutes))
			return eid_al_fitr.data.night_toast, true
		)


func _show_fitr() -> void:
	if ui.screen not in ["game", "market_map"]:
		return
	update_state()
	if eid_al_fitr.fitr_available_at(current_place):
		_stop_travel()
		show_screen("fitr")


func _pay_fitr() -> void:
	if ui.screen == "fitr" and eid_al_fitr.give_fitr(current_place, progress):
		update_state()


func _pray_eid() -> void:
	if ui.screen not in ["game", "market_map"]:
		return
	update_state()
	if eid_al_fitr.pray_eid(current_place):
		_stop_travel()
		show_screen("eid")


func _do_adha_action(action: EidAlAdha.Action) -> void:
	if ui.screen not in ["game", "market_map"]:
		return
	update_state()
	if action != eid_al_adha.action_at(current_place):
		return
	match action:
		EidAlAdha.Action.SHEEP:
			_stop_travel()
			show_screen("adha_sheep")
		EidAlAdha.Action.ARAFAH:
			if eid_al_adha.intend_arafah(current_place):
				update_state()
				ui.show_toast(eid_al_adha.data.arafah_toast, ui.screen == "market_map")
		EidAlAdha.Action.PRAYER:
			if eid_al_adha.pray_eid(current_place):
				_stop_travel()
				show_screen("adha_eid")
		EidAlAdha.Action.SACRIFICE:
			ui.adha_sacrifice_receipt = ""
			_stop_travel()
			show_screen("adha_sacrifice")


func _buy_adha_sheep() -> void:
	if ui.screen == "adha_sheep" and eid_al_adha.buy_sheep(current_place):
		update_state()


func _sacrifice_adha_sheep(give_all: bool) -> void:
	if ui.screen == "adha_sacrifice" and eid_al_adha.sacrifice(current_place, give_all):
		var copy: Dictionary = eid_al_adha.data.sacrifice
		ui.adha_sacrifice_receipt = copy.out_all if give_all else copy.out_thirds
		show_screen("adha_sacrifice")


func _show_zakat() -> void:
	if ui.screen not in ["game", "market_map"]:
		return
	update_state()
	if zakat.open_panel(current_place):
		_stop_travel()
		show_screen("zakat")


func _pay_zakat(id: String) -> void:
	if ui.screen == "zakat" and current_place == "masjid" and zakat.pay(id):
		update_state()


func _show_pilgrims() -> void:
	if ui.screen not in ["game", "market_map"]:
		return
	update_state()
	if pilgrims.available_at(current_place):
		_stop_travel()
		pilgrims.secret_selected = false
		show_screen("pilgrims")


func _send_pilgrim(id: String) -> void:
	if ui.screen == "pilgrims" and current_place == "gate" and pilgrims.send(id, open_purse.page_read):
		update_state()


func _show_qurans_school() -> void:
	if ui.screen not in ["game", "market_map"]:
		return
	update_state()
	if qurans_school.available_at(current_place):
		_stop_travel()
		qurans_school.open_panel()
		show_screen("qurans_school")


func _pay_qurans_school(kind: String) -> void:
	if ui.screen == "qurans_school" and current_place == "masjid" and qurans_school.pay(kind, open_purse.page_read):
		show_screen("qurans_school")


func _read_calligraphy() -> void:
	if ui.screen not in ["game", "market_map"]:
		return
	update_state()
	if names_of_allah.learn_at(current_place, idris_met):
		_stop_travel()
		show_screen("names_of_allah")


func show_open_purse() -> void:
	if current_place == "inn" and ui.screen in ["game", "market_map"] and not open_purse.done:
		_stop_travel()
		show_screen("purse")

func ask_salma() -> void:
	if ui.screen == "purse" and not open_purse.salma_asked:
		open_purse.salma_asked = true
		show_screen("purse_salma")

func read_page_one() -> void:
	if ui.screen in ["purse", "purse_salma"] and open_purse.salma_asked and not open_purse.page_read:
		if idris_recovery.cool:
			show_screen("purse_refused")
			return
		open_purse.page_read = true
		known_words["sirr"] = true
		_set_purse_scene_place("masjid")
		show_screen("purse_page")

func return_to_purse() -> void:
	if ui.screen == "purse_page":
		_set_purse_scene_place("inn")
	if ui.screen in ["purse_salma", "purse_page"]:
		show_screen("purse")

func _set_purse_scene_place(place: String) -> void:
	player.position = world.point(place)
	_stop_travel()

func _stop_travel() -> void:
	player.velocity = Vector3.ZERO
	player.test_move_axis = Vector2.ZERO
	route.clear()
	destination = ""

func give_from_purse(id: String, secret: bool) -> void:
	if ui.screen == "purse" and open_purse.give(id, secret):
		show_screen("purse")

func end_purse_day() -> void:
	if ui.screen == "purse" and open_purse.end_day():
		world.set_inn_people_waiting(false)
		show_screen("purse_morning")

func show_bread_grab() -> void:
	if _bread_grab_prompt() != BreadGrab.Prompt.SEE:
		return
	_stop_travel()
	bread_grab.see()
	world.run_faris_from_oven()
	show_screen("grab_see")

func leave_bread_grab() -> void:
	if ui.screen == "grab_see":
		world.stop_faris_run()
		show_screen("market_map")

func ask_about_bread() -> void:
	if _bread_grab_prompt() != BreadGrab.Prompt.ASK:
		return
	_stop_travel()
	show_screen("grab_ask")

func answer_bread_grab(id: String) -> void:
	if ui.screen == "grab_ask" and bread_grab.answer(id):
		show_screen("grab_after")

func _bread_grab_prompt() -> BreadGrab.Prompt:
	if current_place == "board" and ui.screen in ["game", "market_map"]:
		return bread_grab.board_prompt(_salma_available())
	return BreadGrab.Prompt.NONE


func _salma_available() -> bool:
	return market_day.status("salma") == MarketDay.Status.OPEN and world.salma.is_visible_in_tree()


func show_feeding() -> void:
	if current_place != "board" or ui.screen not in ["game", "market_map"] or not _salma_available():
		return
	_stop_travel()
	feeding.open_panel()
	show_screen("feeding")


func pay_for_feeding(id: String) -> void:
	if ui.screen == "feeding" and feeding.pay(id, known_words.has("sirr")):
		show_screen("feeding")


func show_iftar_giving() -> void:
	if ui.screen not in ["game", "market_map"] or not iftar_giving.available_at(current_place):
		return
	_stop_travel()
	iftar_giving.open_panel()
	show_screen("iftar_giving")


func pay_for_iftar(id: String) -> void:
	if ui.screen == "iftar_giving" and iftar_giving.available_at(current_place) and iftar_giving.pay(id, known_words.has("sirr")):
		show_screen("iftar_giving")


func show_dry_fountain() -> void:
	if current_place == "board" and ui.screen in ["game", "market_map"] and not dry_fountain.is_running():
		_stop_travel()
		show_screen("dry_fountain")


func pay_for_dry_fountain(choice: String) -> void:
	if ui.screen == "dry_fountain" and dry_fountain.pay(choice):
		show_screen("fountain_done" if dry_fountain.is_running() else "dry_fountain")


func show_rashids_loan() -> void:
	if current_place != "spice" or ui.screen not in ["game", "market_map"]:
		return
	match rashids_loan.offer():
		RashidsLoan.Offer.ASK:
			_stop_travel()
			show_screen("loan_ask")
		RashidsLoan.Offer.DUE:
			_stop_travel()
			show_screen("loan_due")
		RashidsLoan.Offer.LAST:
			if rashids_loan.collect_last_payment():
				_stop_travel()
				show_screen("loan_last")


func answer_rashids_loan(choice: String) -> void:
	if ui.screen == "loan_ask" and rashids_loan.answer_ask(choice):
		show_screen("loan_lent" if choice == "lend" else "loan_riba")
	elif ui.screen == "loan_due" and rashids_loan.answer_due(choice):
		show_screen("loan_after")


func show_partnership() -> void:
	if current_place != "weaver" or ui.screen not in ["game", "market_map"]:
		return
	match partnership.offer():
		Partnership.Offer.ASK:
			_stop_travel()
			show_screen("partnership_ask")
		Partnership.Offer.DUE:
			if partnership.collect_share():
				_stop_travel()
				show_screen("partnership_week")


func answer_partnership(choice: String) -> void:
	if ui.screen == "partnership_ask" and partnership.answer(choice):
		show_screen("partnership_agreed" if choice == "partner" else "partnership_riba")


func move_road_harm() -> void:
	if ui.screen not in ["game", "market_map"]:
		return
	update_state()
	if harm_in_the_road.move_at(current_place):
		_stop_travel()
		show_screen("harm_done")


func show_sealed_purse_offer() -> void:
	if current_place == "quay" and ui.screen in ["game", "market_map"] and sealed_purse.offer_available():
		_stop_travel()
		show_screen("sealed_purse_offer")


func accept_sealed_purse() -> void:
	if ui.screen == "sealed_purse_offer":
		show_screen("sealed_purse_coin" if sealed_purse.accept() else "market_map")


func choose_sealed_purse_coin(keep: bool) -> void:
	if ui.screen == "sealed_purse_coin" and sealed_purse.choose_coin(keep):
		player.position = world.point("board")
		_stop_travel()
		show_screen("market_map")


func deliver_sealed_purse() -> void:
	if current_place == "gate" and ui.screen in ["game", "market_map"] and sealed_purse.deliver():
		_stop_travel()
		show_screen("sealed_purse_delivery")


func open_dice_house() -> void:
	if current_place != "inn" or ui.screen not in ["game", "market_map"] or not dice_house.is_open():
		return
	_stop_travel()
	if dice_house.invited:
		if dice_house.enter():
			show_screen("dice_house")
	else:
		dice_house.invited = true
		show_screen("dice_invite")


func answer_dice_invitation(follow: bool) -> void:
	if ui.screen == "dice_invite":
		show_screen("dice_house" if follow and dice_house.enter() else "market_map")


func bet_at_dice_house(bet: int, roll_percent: int = -1) -> void:
	if ui.screen == "dice_house" and dice_house.bet_coins(bet, roll_percent):
		show_screen("dice_house")


func leave_dice_house() -> void:
	if ui.screen == "dice_house":
		show_screen("market_map")


func show_qasims_offer() -> void:
	if current_place == "quay" and ui.screen in ["game", "market_map"] and qasims_jars.can_carry():
		_stop_travel()
		show_screen("qasims_offer")


func answer_qasims_offer(carry: bool) -> void:
	if ui.screen == "qasims_offer":
		show_screen("qasims_done" if carry and qasims_jars.carry() else "market_map")


func leave_qasims_done() -> void:
	if ui.screen == "qasims_done":
		show_screen("market_map")


func show_jabirs_offer() -> void:
	if current_place == "gate" and ui.screen in ["game", "market_map"] and jabirs_goats.can_offer():
		_stop_travel()
		show_screen("jabirs_offer")


func answer_jabirs_offer(action: String) -> void:
	if ui.screen != "jabirs_offer":
		return
	if action == "walk" or not jabirs_goats.can_offer():
		show_screen("market_map")
	elif action == "buy" and jabirs_goats.buy():
		show_screen("jabirs_bought")
	elif action == "tell" and jabirs_goats.tell_saeed():
		show_screen("jabirs_told")


func leave_jabirs_result(to_reputation: bool) -> void:
	if ui.screen == "jabirs_told" or (ui.screen == "jabirs_bought" and not to_reputation):
		show_screen("reputation" if to_reputation else "market_map")


func show_stall() -> void:
	if current_place != "spice" or ui.screen not in ["game", "market_map"]:
		return
	if market_day.status("rashid") != MarketDay.Status.OPEN:
		return
	_stop_travel()
	market_stall.visit()
	show_screen("stall")


func buy_stall_item(id: String) -> void:
	if ui.screen == "stall" and market_stall.buy(id):
		show_screen("stall_change" if market_stall.change_state == MarketStall.Change.PENDING else "stall")


func resolve_stall_change(give_back: bool) -> void:
	if ui.screen == "stall_change" and market_stall.resolve_change(give_back):
		show_screen("stall")


func show_loom() -> void:
	if current_place != "weaver" or ui.screen not in ["game", "market_map"]:
		return
	if market_day.status("layla") != MarketDay.Status.OPEN:
		return
	_stop_travel()
	show_screen("loom")


func buy_loom_item(id: String) -> void:
	if ui.screen == "loom" and market_stall.buy_at_loom(id):
		show_screen("loom")


func show_bag() -> void:
	if ui.screen in MarketUI.BAG_ENTRY_SCREENS:
		_stop_travel()
		show_screen("bag")


func wear_clothes(id: String) -> void:
	if ui.screen == "bag" and market_stall.wear(id):
		show_screen("bag")


func give_bread_to_faris() -> void:
	update_state()
	if current_place == "quay" and ui.screen in ["game", "market_map"] and market_stall.give_bread():
		update_state()
		ui.show_toast(market_stall.data.feed, ui.screen == "market_map")


func show_talking() -> void:
	update_state()
	var regular := talking.regular_at(current_place)
	if regular.is_empty() or market_day.status(regular.id) != MarketDay.Status.OPEN:
		return
	if ui.screen in ["game", "market_map"] and talking.open_at(current_place):
		_stop_travel()
		show_screen("talk")


func greet_regular() -> void:
	if ui.screen == "talk" and talking.greet():
		show_screen("talk")


func ask_regular() -> void:
	if ui.screen == "talk":
		talking.ask()
		show_screen("talk")


func use_place() -> void:
	update_state()
	match current_place:
		"board": show_board()
		"spice": show_stall()
		"weaver": show_loom()
		"scales":
			if progress.lesson_done:
				ui.show_toast(data.other_text.scales_after_lesson)
			else:
				progress.tried_weight = -1
				show_screen("lesson")
		"gate":
			var message := progress.ask_gate()
			if progress.gate_open:
				world.open_gate()
			update_state()
			ui.show_toast(message)
		"centre": ui.show_toast(data.other_text.centre_exit)
		"inn": _rest_at_inn()
		"masjid":
			if not clock.prayer_label(true).is_empty():
				pray_here()
			elif not idris_met:
				_start_idris()
			else:
				ui.show_toast(data.ui.not_built, ui.screen == "market_map")
		_: pass

func show_goal() -> void:
	show_screen("goal")

func try_weight(index: int) -> void:
	if ui.screen == "lesson" and progress.try_weight(index):
		ui.show_screen("lesson")

func answer_weight() -> void:
	if ui.screen != "lesson" or progress.tried_weight < 0:
		return
	if progress.answer_weight():
		show_screen("game")
		var cheated: bool = arrival_fair is bool and not arrival_fair
		ui.show_toast(identity.arrival.cheat_found_after_lesson if cheated else data.lesson.win, cheated)
	else:
		ui.show_toast(data.lesson.wrong)

func show_board() -> void:
	show_screen("board")

func open_task(id: String) -> void:
	if progress.tasks.has(id):
		return
	for task: Dictionary in data.tasks:
		if task.id == id:
			ui.task_id = id
			show_screen("task")
			return

func choose_task(id: String, choice: String) -> void:
	var result := progress.choose_task(id, choice)
	if result.is_empty():
		return
	ui.result = result
	show_screen("result")

func amend_task(id: String) -> void:
	if not progress.amend_task(id):
		return
	show_board()
	for task: Dictionary in data.tasks:
		if task.id == id:
			ui.show_toast(task.amends.result)
			return

func do_daily_job() -> void:
	if progress.do_daily_job():
		show_board()
		ui.show_toast(data.daily_job.toast)

func _unhandled_input(event: InputEvent) -> void:
	if ui.screen in PAUSE_SCREENS:
		if event.is_action_pressed("close"):
			if ui.screen == "settings":
				close_settings()
			else:
				_resume_game()
		return
	if ui.screen == "calendar":
		if event.is_action_pressed("close"):
			_close_calendar()
		return
	if ui.screen == "iftar":
		if event.is_action_pressed("close"):
			show_screen("market_map")
		return
	if ui.screen in ["all_prayers", "all_prayers_title"]:
		if event.is_action_pressed("close"):
			show_screen("title" if ui.screen == "all_prayers_title" else "prayer_record")
		return
	if ui.screen in ["arrival", "stall_change", "sealed_purse_coin"]:
		return
	if ui.screen == "idris":
		if event.is_action_pressed("close"):
			leave_idris()
		return
	if ui.screen == "purse_refused":
		if event.is_action_pressed("close"):
			show_screen("market_map")
		return
	if ui.screen in ["purse_salma", "purse_page"]:
		if event.is_action_pressed("close"):
			return_to_purse()
		return
	if ui.screen in MarketUI.GRAB_SCREENS:
		if event.is_action_pressed("close"):
			if ui.screen == "grab_see":
				leave_bread_grab()
			else:
				show_screen("market_map")
		return
	if ui.screen in MarketUI.DICE_HOUSE_SCREENS or ui.screen in MarketUI.QASIMS_JARS_SCREENS or ui.screen in MarketUI.JABIRS_GOATS_SCREENS or ui.screen in MarketUI.LOAN_SCREENS or ui.screen == "harm_done" or ui.screen in MarketUI.ADHA_SCREENS:
		if event.is_action_pressed("close"):
			show_screen("market_map")
		return
	if ui.screen in ["sealed_purse_offer", "sealed_purse_delivery"]:
		if event.is_action_pressed("close"):
			show_screen("market_map")
		return
	if event.is_action_pressed("close"):
		if ui.screen == "prayer_record": close_prayer_record()
		elif ui.screen == "city_map": show_screen("market_map")
		elif ui.screen == "world_map": show_screen("city_map")
		elif ui.screen == "market_map": show_screen("pause")
		elif ui.screen in ["purse", "purse_morning", "reputation", "stall", "loom", "bag", "talk", "feeding", "iftar_giving", "fitr", "eid", "zakat", "pilgrims", "qurans_school", "names_of_allah"] or ui.screen in MarketUI.DRY_FOUNTAIN_SCREENS: show_screen("market_map")
		elif ui.screen in ["board", "task", "result", "lesson", "goal"]: show_screen("game")
		else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("market_map") and ui.screen != "title":
		show_screen("game" if ui.screen == "market_map" else "market_map")
	elif event.is_action_pressed("goal") and ui.screen != "title": show_goal()
	elif event.is_action_pressed("wait_prayer") and ui.screen != "title": wait_until_next_prayer()
	elif event.is_action_pressed("pray") and ui.screen in ["game", "market_map"]: pray_here()
	elif event.is_action_pressed("use") and ui.screen in ["game", "market_map"]: use_place()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and ui.screen == "game":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventKey and event.pressed and not event.echo and (event.is_action("move_left") or event.is_action("move_right") or event.is_action("move_forward") or event.is_action("move_back")):
		route.clear()
		player.test_move_axis = Vector2.ZERO

func walk_to_place(id: String) -> void:
	# Follow the approved street graph with physical movement, never teleport.
	if not data.places.has(id):
		return
	var attachment := _street_attachment()
	var costs: Dictionary = attachment.costs
	var previous: Dictionary = {}
	var pending: Array = costs.keys()
	var visited := {}
	while not pending.is_empty():
		pending.sort_custom(func(a, b): return costs[a] < costs[b])
		var point_id: String = pending.pop_front()
		if visited.has(point_id): continue
		visited[point_id] = true
		if point_id == id: break
		for edge in data.streets:
			var next: String = edge[1] if edge[0] == point_id else (edge[0] if edge[1] == point_id else "")
			if next.is_empty(): continue
			var cost: float = costs[point_id] + world.point(point_id).distance_to(world.point(next))
			if not costs.has(next) or cost < costs[next]:
				costs[next] = cost
				previous[next] = point_id
				pending.append(next)
	if not costs.has(id):
		return
	var path: Array[String] = [id]
	while previous.has(path[0]):
		path.push_front(previous[path[0]])
	route.clear()
	for waypoint: Vector3 in attachment.waypoints:
		route.append(waypoint)
	for point_id in path: route.append(world.point(point_id))
	destination = id


func _street_attachment() -> Dictionary:
	var here := Vector2(player.position.x, player.position.z)
	var square: Vector3 = world.point(data.square.centre)
	var square_point := Vector2(square.x, square.z)
	if here.distance_to(square_point) <= float(data.square.radius):
		# The square is convex: moving directly to its centre stays in the square.
		return {"waypoints": [], "costs": {data.square.centre: here.distance_to(square_point)}}
	var best_distance := INF
	var best_projection := Vector2.ZERO
	var best_edge: Array = []
	var waypoints: Array[Vector3] = []
	var on_quay: bool = here.y >= float(data.world.quay.z_from) and here.y <= float(data.world.quay.z_to)
	for edge: Array in data.streets:
		var from: Vector3 = world.point(edge[0])
		var to: Vector3 = world.point(edge[1])
		if on_quay:
			# Attach to the quay's horizontal street through a right-angle leg
			# inside the walkable strip, rather than cutting across house blocks.
			if not data.start_place in edge or not is_equal_approx(from.z, to.z):
				continue
		var projection := Geometry2D.get_closest_point_to_segment(here, Vector2(from.x, from.z), Vector2(to.x, to.z))
		var distance := here.distance_to(projection)
		if on_quay:
			distance = absf(here.x - projection.x) + absf(here.y - projection.y)
		if distance < best_distance:
			best_distance = distance
			best_projection = projection
			best_edge = edge
	# Every valid street point attaches to a segment's centreline. Both segment
	# endpoints are graph candidates, weighted by their distance from that foot.
	if on_quay:
		waypoints.append(Vector3(best_projection.x, 0.0, here.y))
	waypoints.append(Vector3(best_projection.x, 0.0, best_projection.y))
	var costs := {}
	for point_id: String in best_edge:
		var endpoint: Vector3 = world.point(point_id)
		costs[point_id] = best_distance + best_projection.distance_to(Vector2(endpoint.x, endpoint.z))
	return {"waypoints": waypoints, "costs": costs}
