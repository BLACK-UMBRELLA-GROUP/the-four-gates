extends RefCounted
## LOCK 6 dialogue, LOCK 28 memories and LOCK 98 scheduled stops.

const TaskProgress = preload("res://game/task_progress.gd")
const BreadGrab = preload("res://game/bread_grab.gd")
const MarketStall = preload("res://game/market_stall.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")
const SceneRunner = preload("res://game/scene_runner.gd")

var data: Dictionary
var person: Dictionary = {}
var place := ""
var greeted: Dictionary = {}
var reply := ""
var _progress: TaskProgress
var _bread_grab: BreadGrab
var _stall: MarketStall
var _by_place: Dictionary = {}
var _memories: Dictionary
var _runner: SceneRunner
var _clock: PrayerClock


func setup(source: Dictionary, progress: TaskProgress, bread_grab: BreadGrab, stall: MarketStall,
		memories: Dictionary, runner: SceneRunner, clock: PrayerClock) -> void:
	data = source
	_runner = runner
	_clock = clock
	_memories = memories
	_progress = progress
	_bread_grab = bread_grab
	_stall = stall
	_by_place.clear()
	for regular: Dictionary in data.people:
		_by_place[regular.place] = regular
	reset()


func reset() -> void:
	person = {}
	place = ""
	greeted.clear()
	reply = ""


func regular_at(place_id: String) -> Dictionary:
	return _by_place.get(place_id, {})


func scheduled_place(regular: Dictionary) -> String:
	return _runner.regular_place(regular, _clock.minute_of_day)


func regulars_at(place_id: String) -> Array[Dictionary]:
	var regulars: Array[Dictionary] = []
	for regular: Dictionary in data.people:
		if scheduled_place(regular) == place_id:
			regulars.append(regular)
	return regulars


func button_at(place_id: String) -> String:
	var regular := regular_at(place_id)
	return "" if regular.is_empty() else button_for(regular)


func button_for(regular: Dictionary) -> String:
	return str(data.talk_button).format({"name": regular.name})


func open(regular: Dictionary, place_id: String) -> void:
	person = regular
	place = place_id
	reply = ""


func tier_line() -> String:
	if _progress.trust < int(data.numbers.wary_below):
		return person.tier.wary
	if _progress.trust >= int(data.numbers.warm_from):
		return person.tier.warm
	return person.tier.friendly


func fact_line() -> String:
	var fact := ""
	match person.id:
		"salma":
			fact = "grab_" + _bread_grab.answer_id
		"rashid":
			if _stall.change_state == MarketStall.Change.RETURNED:
				fact = "returned"
			elif _stall.change_state == MarketStall.Change.FOUND:
				fact = "kept"
		"layla":
			if _stall.worn_clothes == "traveller":
				fact = "traveller"
			else:
				for outfit in _stall.loom_items:
					if outfit.id == _stall.worn_clothes:
						fact = "own_cloth"
						break
		"jamal":
			if _stall.fed_faris:
				fact = "fed"
			elif _progress.boat_job_done:
				fact = "boat"
		"musa":
			fact = "learned" if _progress.lesson_done else "not_learned"
	return person.facts.get(fact, "")


func memory_line(active_keys: Dictionary) -> String:
	for entry: Array in _memories.get(person.get("id", ""), []):
		if active_keys.get(entry[0], false):
			return entry[1]
	return ""


func greet() -> bool:
	if person.is_empty() or greeted.has(person.id):
		return false
	greeted[person.id] = true
	reply = data.panel.reply
	if greeted.size() == int(data.numbers.greet_count):
		_progress.apply_trust(int(data.numbers.greet_trust))
	return true


func ask() -> void:
	reply = person.tip


func reputation_line() -> Variant:
	if greeted.size() >= int(data.numbers.greet_count):
		return data.say.greets
	return null
