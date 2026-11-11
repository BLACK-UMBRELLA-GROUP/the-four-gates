extends RefCounted
## LOCK 15: payments and attribution for the first fountain in River Market.

const TaskProgress = preload("res://game/task_progress.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")

var data: Dictionary
var paid := 0
var named := false
var finished_day := -1
var _progress: TaskProgress
var _clock: PrayerClock


func setup(source: Dictionary, progress: TaskProgress, clock: PrayerClock) -> void:
	data = source
	_progress = progress
	_clock = clock


func reset() -> void:
	paid = 0
	named = false
	finished_day = -1


func is_running() -> bool:
	return finished_day >= 0


func days_running() -> int:
	return _clock.day - finished_day if is_running() else 0


func can_afford() -> bool:
	return _progress.coins >= int(data.numbers.part)


func pay(choice: String) -> bool:
	if is_running() or not can_afford():
		return false
	if paid == 0:
		if choice not in ["named", "secret"]:
			return false
		named = choice == "named"
	elif not choice.is_empty():
		return false
	var part := int(data.numbers.part)
	_progress.coins -= part
	paid += part
	if paid == int(data.numbers.cost):
		finished_day = _clock.day
		if named:
			_progress.apply_trust(int(data.numbers.public_trust))
	return true


func reputation_line() -> Variant:
	return data.say.named if is_running() and named else null
