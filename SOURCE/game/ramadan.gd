extends RefCounted
## LOCK 19: Ramadan windows and the private record for this playthrough.

const PrayerClock = preload("res://game/prayer_clock.gd")

enum Action { NONE, SUHOOR, IFTAR, TARAWIH }

var data: Dictionary
var _clock: PrayerClock
var _numbers: Dictionary
var _taken := {Action.SUHOOR: {}, Action.IFTAR: {}, Action.TARAWIH: {}}
var _rested := {}


func _init(source: Dictionary, clock: PrayerClock) -> void:
	data = source
	_numbers = data.numbers
	_clock = clock


func reset() -> void:
	for days: Dictionary in _taken.values():
		days.clear()
	_rested.clear()


func fasting_line() -> String:
	if not is_ramadan_day(_clock.day) or _rested.has(_clock.day):
		return ""
	if _clock.minute_of_day < int(_numbers.fast_from) or _clock.minute_of_day >= int(_numbers.iftar_from):
		return ""
	var iftar := int(_numbers.iftar_from)
	var time := "%02d:%02d" % [floori(float(iftar) / PrayerClock.MINUTES_PER_HOUR), iftar % PrayerClock.MINUTES_PER_HOUR]
	return str(data.fasting_line).format({"t": time})


func action_at(place: String) -> Action:
	if not is_ramadan_day(_clock.day):
		return Action.NONE
	if place == "inn" and _available(Action.SUHOOR, _numbers.suhoor_from, _numbers.fast_from):
		return Action.SUHOOR
	if place == "masjid":
		if _available(Action.IFTAR, _numbers.iftar_from, _numbers.iftar_until):
			return Action.IFTAR
		if _available(Action.TARAWIH, _numbers.tarawih_from, _numbers.tarawih_until):
			return Action.TARAWIH
	return Action.NONE


func take(action: Action, place: String) -> bool:
	if action == Action.NONE or action_at(place) != action:
		return false
	_taken[action][_clock.day] = true
	return true


func rest_until(wake_day: int, wake_minute: int) -> void:
	var iftar := int(_numbers.iftar_from)
	# A multi-day rest excludes the fasts whose Maghrib begins during the jump.
	var first := _clock.day + int(_clock.minute_of_day >= iftar)
	var last := wake_day - int(wake_minute < iftar)
	for day in range(first, last + 1):
		if is_ramadan_day(day):
			_rested[day] = true


func has_prayed_at_masjid() -> bool:
	return not _taken[Action.TARAWIH].is_empty()


func record() -> Dictionary:
	var reached := false
	var fasted := 0
	var latest_fast := _clock.day - int(_clock.minute_of_day < int(_numbers.iftar_from))
	for day in range(1, _clock.day + 1):
		if is_ramadan_day(day):
			reached = true
			if day <= latest_fast and not _rested.has(day):
				fasted += 1
	if not reached:
		return {}
	return {"fasted": fasted, "suhoor": _taken[Action.SUHOOR].size(), "tarawih": _taken[Action.TARAWIH].size()}


func is_ramadan_day(day: int) -> bool:
	return _clock.calendar.month_index(day - 1) == int(_numbers.month)


func _available(action: Action, start: int, end: int) -> bool:
	return _clock.minute_of_day >= start and _clock.minute_of_day < end and not _taken[action].has(_clock.day)
