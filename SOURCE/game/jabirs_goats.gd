extends RefCounted
## LOCK 13: the gate offer and River Market's response to buying stolen goats.

const PrayerClock = preload("res://game/prayer_clock.gd")
const TaskProgress = preload("res://game/task_progress.gd")

var data: Dictionary
var deals := 0
var last_deal_day := -1
var told := false
var _progress: TaskProgress
var _clock: PrayerClock


func setup(source: Dictionary, progress: TaskProgress, clock: PrayerClock) -> void:
	data = source
	_progress = progress
	_clock = clock


func reset() -> void:
	deals = 0
	last_deal_day = -1
	told = false


func can_offer() -> bool:
	var minute := _clock.minute_of_day
	return not told and last_deal_day != _clock.day and minute >= int(data.numbers.open_from) and minute < int(data.numbers.open_until)


func gate_caption() -> String:
	return data.gate_button if can_offer() else ""


func can_afford() -> bool:
	return _progress.coins >= int(data.numbers.price)


func buy() -> bool:
	if not can_offer() or not can_afford():
		return false
	last_deal_day = _clock.day
	deals += 1
	_progress.coins += int(data.numbers.butcher_pays) - int(data.numbers.price)
	var trust_hit := 0
	if deals == int(data.numbers.seen_from_deals):
		trust_hit = int(data.numbers.seen_trust)
	elif deals == int(data.numbers.fence_from_deals):
		trust_hit = int(data.numbers.fence_trust)
	_progress.apply_temptation(trust_hit)
	return true


func tell_saeed() -> bool:
	if not can_offer():
		return false
	told = true
	_progress.apply_trust(int(data.numbers.tell_trust))
	return true


func reputation_lines() -> Array:
	var lines := []
	if deals >= int(data.numbers.fence_from_deals):
		lines.append(data.say.fence)
	elif deals >= int(data.numbers.seen_from_deals):
		lines.append(data.say.seen)
	elif deals >= int(data.numbers.talk_from_deals):
		lines.append(data.say.talk)
	if told:
		lines.append(data.say.told)
	return lines
