extends RefCounted
## LOCK 12: the Quay offer and River Market's response to carrying wine.

const PrayerClock = preload("res://game/prayer_clock.gd")
const TaskProgress = preload("res://game/task_progress.gd")

var data: Dictionary
var runs := 0
var _progress: TaskProgress
var _clock: PrayerClock
var _last_run_night := -1


func setup(source: Dictionary, progress: TaskProgress, clock: PrayerClock) -> void:
	data = source
	_progress = progress
	_clock = clock


func reset() -> void:
	runs = 0
	_last_run_night = -1


func can_carry() -> bool:
	var opens := int(data.numbers.open_from)
	var closes := int(data.numbers.open_until)
	return _clock.in_overnight_window(opens, closes) and _last_run_night != _clock.evening_day(closes)


func quay_caption() -> String:
	return data.quay_button if can_carry() else ""


func carry() -> bool:
	if not can_carry():
		return false
	_last_run_night = _clock.evening_day(int(data.numbers.open_until))
	runs += 1
	_progress.coins += int(data.numbers.pay)
	if runs == int(data.numbers.seen_from_runs):
		_progress.apply_trust(int(data.numbers.seen_trust))
	elif runs == int(data.numbers.smuggler_from_runs):
		_progress.apply_trust(int(data.numbers.smuggler_trust))
	return true


func reputation_line() -> Variant:
	if runs >= int(data.numbers.smuggler_from_runs):
		return data.say.smuggler
	if runs >= int(data.numbers.seen_from_runs):
		return data.say.seen
	if runs >= int(data.numbers.talk_from_runs):
		return data.say.talk
	return null
