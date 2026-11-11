extends RefCounted
## LOCK 6 greetings and dialogue based on events the regulars know about.

const TaskProgress = preload("res://game/task_progress.gd")
const BreadGrab = preload("res://game/bread_grab.gd")
const MarketStall = preload("res://game/market_stall.gd")

var data: Dictionary
var person: Dictionary = {}
var greeted: Dictionary = {}
var reply := ""
var _progress: TaskProgress
var _bread_grab: BreadGrab
var _stall: MarketStall
var _by_place: Dictionary = {}


func setup(source: Dictionary, progress: TaskProgress, bread_grab: BreadGrab, stall: MarketStall) -> void:
	data = source
	_progress = progress
	_bread_grab = bread_grab
	_stall = stall
	_by_place.clear()
	for regular: Dictionary in data.people:
		_by_place[regular.place] = regular
	reset()


func reset() -> void:
	person = {}
	greeted.clear()
	reply = ""


func button_at(place: String) -> String:
	var regular: Dictionary = _by_place.get(place, {})
	if regular.is_empty():
		return ""
	return str(data.talk_button).format({"name": regular.name})


func open_at(place: String) -> bool:
	if not _by_place.has(place):
		return false
	person = _by_place[place]
	reply = ""
	return true


func tier_line() -> String:
	if _progress.trust < int(data.numbers.wary_below):
		return person.tier.wary
	if _progress.trust >= int(data.numbers.warm_from):
		return person.tier.warm
	return person.tier.friendly


func memory_line() -> String:
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
