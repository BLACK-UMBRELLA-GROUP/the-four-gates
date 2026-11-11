extends RefCounted
## DOC-TFG-0113: test-only content for mission effects, conditions, town life and the Journal.

const SceneRunner = preload("res://game/scene_runner.gd")
const BreadGrab = preload("res://game/bread_grab.gd")
const Feeding = preload("res://game/feeding.gd")
const GateOfTrust = preload("res://game/gate_of_trust.gd")
const JisraMasjid = preload("res://game/jisra_masjid.gd")
const MarketDay = preload("res://game/market_day.gd")
const NamesOfAllah = preload("res://game/names_of_allah.gd")
const OpenPurse = preload("res://game/open_purse.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")
const QuransSchool = preload("res://game/qurans_school.gd")
const SealedPurse = preload("res://game/sealed_purse.gd")
const TaskProgress = preload("res://game/task_progress.gd")

const INDEX := "res://tests/fixtures/scene_runner/content_index.json"
const TOWN := "fixture_town"
const OTHER_TOWN := "fixture_other_town"


class Context:
	var progress := TaskProgress.new()
	var open_purse := OpenPurse.new()
	var bread_grab := BreadGrab.new()
	var sealed_purse := SealedPurse.new()
	var gate_of_trust := GateOfTrust.new()
	var feeding := Feeding.new()
	var clock: PrayerClock
	var market_day: MarketDay
	var qurans_school: QuransSchool
	var names_of_allah: NamesOfAllah
	var jisra_masjid: JisraMasjid
	var day: int:
		get: return clock.day
	var minute_of_day: int:
		get: return clock.minute_of_day

	func _init(game) -> void:
		progress.setup(game.data)
		clock = PrayerClock.new(game.identity.clock, game.clock.calendar)
		market_day = MarketDay.new(game.market_day.data, clock, game.market_day.prayer_data)
		open_purse.setup(game.chapter, progress, clock)
		bread_grab.setup(game.chapter, progress, clock)
		sealed_purse.setup(game.sealed_purse.data, progress, market_day, 390, 1090)
		gate_of_trust.setup(game.gate_of_trust.data, progress)
		feeding.setup(game.feeding.data, progress, clock)
		qurans_school = QuransSchool.new(game.qurans_school.data, clock, progress)
		names_of_allah = NamesOfAllah.new(game.names_of_allah.data)
		jisra_masjid = JisraMasjid.new(game.jisra_masjid.data)


static func make_runner() -> SceneRunner:
	return SceneRunner.new(SceneRunner.load_content(INDEX))


static func run(game, check: Callable) -> void:
	var app := Context.new(game)
	var runner := make_runner()
	_check_content(runner, app, check)
	_check_missions(runner, app, check)
	_check_town(runner, app, check)
	var saved := runner.state()
	var restored := make_runner()
	restored.restore(saved)
	check.call(restored.state() == saved and restored.town_sayings(TOWN).size() == 2
		and restored.mission_done(app, "fixture_main"), "runner restores flags, completions, counters, towns, work and sayings")
	restored.reset()
	check.call(restored.state() == make_runner().state()
		and restored.town_trust(app, TOWN) == 10, "new games and old saves start with fresh runner state")


static func _check_content(runner: SceneRunner, app: Context, check: Callable) -> void:
	var shipped := SceneRunner.new(SceneRunner.load_content())
	var locked := FileAccess.get_file_as_bytes("res://../GAME/APPROVED/SCENE_RUNNER/RECORD/scene_runner_data_V1.json")
	check.call(not locked.is_empty() and locked == FileAccess.get_file_as_bytes("res://data/scene_runner.json"),
		"runtime scene runner content matches the approved bytes")
	check.call(shipped.missions.is_empty() and shipped.towns.is_empty() and shipped.people.is_empty(),
		"production index exposes no fixture content")
	var live_journal := shipped.journal(app)
	var live_chapter: Dictionary = live_journal.chapters[0]
	check.call(live_journal.chapters.size() == 1 and live_chapter.n == 1 and live_chapter.done == 0
		and live_chapter.total == 7 and live_chapter.rows.all(func(row): return not row.done and row.title.is_empty()),
		"fresh live Journal has only Chapter 1 and seven undiscovered rows")
	check.call(live_journal.side == {"done": 0, "total": 0}
		and live_journal.goals.size() == 5 and live_journal.goals.all(func(goal): return goal.n == 0),
		"fresh live Journal has zero side missions and five zero lifetime goals")
	var journal := runner.journal(app)
	check.call(journal.chapters.map(func(chapter): return chapter.n) == [1, 2, 3]
		and journal.chapters[1].name == "Second fixture chapter" and journal.chapters[1].total == 1,
		"indexed chapters sort by number and the later chapter replaces the whole earlier chapter")
	check.call(journal.chapters[2].rows[0] == {"title": "", "done": false},
		"an unloaded mission ID stays undiscovered")


static func _check_missions(runner: SceneRunner, app: Context, check: Callable) -> void:
	var market: Dictionary = runner.missions.fixture_market
	var story: Dictionary = runner.missions.fixture_main
	var guarded: Dictionary = runner.missions.fixture_conditions
	var daily: Dictionary = runner.missions.fixture_daily
	var story_opening: Dictionary = story.scenes[story.start]
	var guarded_opening: Dictionary = guarded.scenes[guarded.start]
	app.progress.trust = 28
	app.progress.coins = 1
	app.clock.skip_to(1, 590)
	check.call(runner.available_missions(app, "", "quay") == [market]
		and runner.available_missions(app, "", "board").is_empty(), "market mission buttons follow their place")
	check.call(runner.available_missions(app, TOWN, "") == [story, daily]
		and runner.available_missions(app, OTHER_TOWN, "").is_empty(), "town mission buttons stay in their own hub")
	check.call(runner.choices(app, story, story_opening).map(func(choice): return choice.label) == ["Leave the post"],
		"insufficient coins hide the paid choice")
	var denied_state := runner.state()
	runner.apply_choice(app, story, story_opening.choices[0])
	check.call(runner.state() == denied_state and app.progress.coins == 1, "unavailable choice cannot apply effects")
	runner.apply_choice(app, market, market.scenes.notice.choices[0])
	check.call(runner.has_flag(app, "fixture_banned") and app.progress.trust == 27
		and runner.town_sayings("river_market") == market.say,
		"market trust and witness go to River Market when the mission has no town")
	app.progress.coins = 8
	var next := runner.apply_choice(app, story, story_opening.choices[0])
	check.call(next == "ending" and app.minute_of_day == 605 and app.progress.coins == 6,
		"real choice applies its coin and time effects and advances to the named scene")
	check.call(runner.town_trust(app, TOWN) == 35 and runner.town_trust(app, OTHER_TOWN) == 18
		and app.progress.trust == 30, "town trust and explicit River Market trust change independently")
	check.call(runner.has_flag(app, "fixture_ready") and runner.has_flag(app, "fixture_second")
		and not runner.has_flag(app, "fixture_banned") and runner.state().flags.fixture_ready == 1,
		"flag and unflag effects remember the day a flag became set")
	check.call(app.feeding.meals_given == 3 and app.qurans_school.qurans_given == 2
		and app.qurans_school.children_in_school == 1 and runner.state().counters.fixture_markers == 4,
		"scene count effects reach the original lifetime counters and named counters")
	check.call(runner.journal(app).goals.map(func(goal): return goal.n) == [3, 2, 1, 0, 0],
		"the Journal shows the live lifetime counters")
	check.call(not runner.mission_done(app, story.id) and runner.choices(app, story, story.scenes[next]).is_empty(),
		"an end scene has no choices and stays incomplete until leaving")
	runner.leave_scene(app, story, story.scenes[next])
	var story_chapter: Dictionary = runner.journal(app).chapters[1]
	check.call(story_chapter.done == 1 and story_chapter.rows[0].title == story.title
		and story not in runner.available_missions(app, TOWN, ""),
		"leaving an end scene finishes the one-time mission and reveals its title in the Journal")
	runner.apply_choice(app, daily, daily.scenes.ask.choices[0])
	check.call(runner.journal(app).side == {"done": 1, "total": 2} and daily not in runner.available_missions(app, TOWN, ""),
		"done effect completes a side mission and hides the daily button for the rest of the day")

	check.call(guarded not in runner.available_missions(app, TOWN, ""),
		"missing gate and toll flags keep the guarded mission hidden")
	app.progress.gate_open = true
	app.gate_of_trust.in_jisra = true
	check.call(app.gate_of_trust.choose_toll("speak"), "fixture uses the original Jisra toll choice")
	runner.observe_builtin_flags(app)
	check.call(runner.has_flag(app, "gate_opened") and runner.has_flag(app, "toll:speak")
		and not runner.has_flag(app, "toll:pay") and not runner.has_flag(app, "toll:quiet")
		and runner.state().flags["toll:speak"] == 1, "LOCK 32 flags reflect the built gate and toll state")
	runner.work(app, TOWN)
	check.call(guarded not in runner.available_missions(app, TOWN, ""), "new flags do not satisfy a later-day condition")
	app.clock.skip_to(2, 570)
	check.call(daily in runner.available_missions(app, TOWN, "") and runner.mission_done(app, daily.id),
		"daily mission returns the next day without losing lifetime completion")
	check.call(guarded not in runner.available_missions(app, TOWN, ""), "guarded mission is hidden outside its hours")
	app.clock.advance_to(2, 600)
	check.call(guarded not in runner.available_missions(app, TOWN, ""), "town trust threshold gates the mission button")
	runner.work(app, TOWN)
	check.call(guarded in runner.available_missions(app, TOWN, ""), "all mission prerequisites reveal the guarded button")
	check.call(runner.choices(app, guarded, guarded_opening).map(func(choice): return choice.label) == ["Leave the offer"],
		"choice trust threshold hides its button even when the mission is available")
	app.progress.coins = 6
	var saved := runner.state()
	saved.trust[TOWN] = 60
	runner.restore(saved)
	check.call(not runner.choice_available(app, guarded, guarded_opening.choices[0]), "choice coin threshold is independent of trust")
	app.progress.coins = 7
	runner.apply_choice(app, market, market.scenes.notice.choices[0])
	check.call(guarded not in runner.available_missions(app, TOWN, "")
		and not runner.choice_available(app, guarded, guarded_opening.choices[0]), "not and unless conditions hide blocked actions")
	runner.apply_choice(app, market, market.scenes.notice.choices[1])
	var without_second := runner.state()
	without_second.flags.erase("fixture_second")
	runner.restore(without_second)
	check.call(not runner.choice_available(app, guarded, guarded_opening.choices[0]), "every required choice flag must be set")
	runner.restore(saved)
	check.call(runner.choice_available(app, guarded, guarded_opening.choices[0]), "choice becomes visible when all guards pass")
	runner.apply_choice(app, guarded, guarded_opening.choices[0])
	check.call(runner.journal(app).side == {"done": 2, "total": 2} and runner.town_trust(app, TOWN) == 100
		and runner.state().counters.fixture_markers == 6,
		"terminal choice applies grouped effects, caps trust and records its own side completion")
	check.call(runner.town_sayings(TOWN) == [runner.data.town_says[TOWN][0], story.say.first] and runner.town_sayings(OTHER_TOWN).is_empty()
		and runner.town_sayings("").size() == 1, "only local witnesses are added, and identical sayings appear once")


static func _check_town(runner: SceneRunner, app: Context, check: Callable) -> void:
	var person: Dictionary = runner.people.fixture_keeper
	var other: Dictionary = runner.people.fixture_other
	var wording: Dictionary = runner.data.words
	check.call(runner.town_people(app, TOWN) == [person] and runner.town_people(app, OTHER_TOWN) == [other],
		"the generic people list contains only residents of the selected town")
	check.call(runner.person_lines(app, TOWN, person) == ["The keeper welcomes you.", "You kept the first marker."],
		"warm speech uses the first matching memory and hides subsequent memory lines")
	var snapshot := runner.state()
	snapshot.trust[TOWN] = 30
	runner.restore(snapshot)
	check.call(runner.person_lines(app, TOWN, person) == ["The keeper nods.", "You kept the first marker."],
		"friendly speech starts at the locked wary threshold")
	snapshot.trust[TOWN] = 29
	runner.restore(snapshot)
	check.call(runner.person_lines(app, TOWN, person) == ["The keeper watches.", "You kept the first marker."],
		"wary speech stays below the locked threshold")
	check.call(runner.person_available(app, person), "the keeper is present during the day")
	var coins := app.progress.coins
	var minute := app.minute_of_day
	check.call(runner.work(app, TOWN) == str(wording.work_done).format({"n": 20, "c": 4})
		and app.progress.coins == coins + 4 and app.minute_of_day == minute + 20
		and runner.town_trust(app, TOWN) == 29, "repeat work earns coins and takes time without a second daily trust reward")
	app.clock.skip_to(3, 600)
	check.call(runner.work(app, TOWN) == "You work for 20 minutes and earn 4 coins."
		and runner.town_trust(app, TOWN) == 37 and runner.town_trust(app, OTHER_TOWN) == 18,
		"town work renews trust once per day in its own town")
	app.clock.advance_to(3, 1040)
	check.call(not runner.person_available(app, person) and not runner.can_work(app, TOWN)
		and runner.work(app, TOWN) == "Fixture keeper is not working now.",
		"the keeper and work are unavailable outside their own hours with locked copy")
	app.clock.skip_to(9, 730)
	check.call(app.clock.is_friday() and not runner.person_available(app, person) and runner.person_available(app, other),
		"only the person who prays is away during Friday prayer")
	app.progress.coins = 4
	check.call(runner.rest(app, TOWN) == "You pay 2 coins and sleep at the inn. Morning comes."
		and app.progress.coins == 2 and app.day == 10 and app.minute_of_day == 280,
		"the town inn charges its own price and wakes at 04:40")
	app.progress.coins = 1
	check.call(runner.rest(app, TOWN) == wording.inn_poor and app.progress.coins == 1
		and app.day == 11 and app.minute_of_day == 280,
		"without the inn price, sleeping outside is free and wakes at the same time")
	check.call(runner.inn_cost(OTHER_TOWN) == -1 and runner.rest(app, OTHER_TOWN).is_empty(),
		"towns with no inn data have no rest action")
