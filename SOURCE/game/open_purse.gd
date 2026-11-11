extends RefCounted
## LOCK 3 V2 part 1: gift state and ordered morning and reputation lines.

const TaskProgress = preload("res://game/task_progress.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")

var salma_asked := false
var page_read := false
var done := false
var _chapter: Dictionary
var _progress: TaskProgress
var _clock: PrayerClock
var _gifts: Dictionary = {}


func setup(chapter: Dictionary, progress: TaskProgress, clock: PrayerClock) -> void:
	_chapter = chapter
	_progress = progress
	_clock = clock
	reset()


func reset() -> void:
	salma_asked = false
	page_read = false
	done = false
	_gifts.clear()


func visible_people() -> Array[Dictionary]:
	var people: Array[Dictionary] = []
	for person: Dictionary in _chapter.purse.people:
		if not person.hidden or salma_asked:
			people.append(person)
	return people


func gift_status(id: String) -> String:
	return _gifts.get(id, "")


func give(id: String, secret: bool) -> bool:
	if done or _gifts.has(id) or (secret and not page_read):
		return false
	for person: Dictionary in visible_people():
		if person.id != id:
			continue
		var cost := int(person.cost)
		if _progress.coins < cost:
			return false
		_progress.coins -= cost
		_gifts[id] = "secret" if secret else "public"
		if not secret:
			_progress.apply_trust(int(_chapter.numbers.gift_trust))
		return true
	return false


func has_secret_gift() -> bool:
	return _gifts.values().has("secret")


func end_day() -> bool:
	if done:
		return false
	done = true
	_clock.skip_to(_clock.day + 1, int(_chapter.numbers.next_morning_minute))
	return true


func morning_lines() -> Array[String]:
	var morning: Dictionary = _chapter.purse.morning
	var numbers: Dictionary = _chapter.numbers
	var public_count := _gifts.values().count("public")
	var lines: Array[String] = []
	if public_count > 0:
		var crowd := int(numbers.crowd_base) + int(numbers.crowd_per_gift) * public_count
		lines.append(str(morning.crowd).format({"n": crowd}))
	else:
		lines.append(morning.none if _gifts.is_empty() else morning.quiet)
	if _gifts.has("father"):
		lines.append(morning.father_public if gift_status("father") == "public" else morning.father_secret)
	if _gifts.has("boy"):
		lines.append(morning.boy)
	if gift_status("fire") == "public":
		lines.append(morning.fire)
	if _gifts.has("widow"):
		lines.append(morning.widow_public if gift_status("widow") == "public" else morning.widow_secret)
	return lines


func reputation_lines() -> Array:
	var rep: Dictionary = _chapter.rep
	var lines: Array = []
	for task: Dictionary in _progress.data.tasks:
		if not _progress.tasks.has(task.id):
			continue
		var state: Dictionary = _progress.tasks[task.id]
		if state.choice == "honest":
			lines.append([rep.task_honest, task.place, 1])
		elif state.amended:
			lines.append([rep.task_amended, task.place, 0])
		else:
			lines.append([rep.task_quick, task.place, -1])
	if _progress.boat_job_done:
		lines.append(rep.boat)
	if _progress.lesson_done:
		lines.append(rep.learned)
	if _clock.has_prayed_in_congregation():
		lines.append(rep.masjid)
	if _gifts.values().has("public"):
		lines.append(rep.gives)
	if gift_status("fire") == "public":
		lines.append(rep.fooled)
	if gift_status("widow") == "public":
		lines.append(rep.widow_public)
	if done and _gifts.is_empty():
		lines.append(rep.shut)
	return lines
