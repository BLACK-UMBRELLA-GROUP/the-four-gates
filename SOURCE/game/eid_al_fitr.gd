extends RefCounted
## DOC-TFG-0072: LOCK 21 worship windows and the private record.

const PrayerClock = preload("res://game/prayer_clock.gd")
const TaskProgress = preload("res://game/task_progress.gd")

var data: Dictionary
var _numbers: Dictionary
var _clock: PrayerClock
var _eid_day_of_month: int
var _stood_nights := {}
var _fitr_years := {}
var _eid_days := {}


func _init(source: Dictionary, clock: PrayerClock) -> void:
	data = source
	_numbers = data.numbers
	_clock = clock
	for event: Array in _clock.calendar.data.panel.events:
		if event[0] == data.eid.title and int(event[1]) == int(_numbers.shawwal):
			_eid_day_of_month = int(event[2])
			break
	assert(_eid_day_of_month > 0, "The approved calendar must include Eid al-Fitr in Shawwal")


func reset() -> void:
	_stood_nights.clear()
	_fitr_years.clear()
	_eid_days.clear()


func night_available_at(place: String) -> bool:
	if place != "masjid":
		return false
	var night_day := _clock.day
	if _clock.minute_of_day >= int(_numbers.night_from):
		night_day += 1
	elif _clock.minute_of_day >= int(_numbers.night_until):
		return false
	var calendar := _clock.calendar
	return (calendar.month_index(night_day - 1) == int(_numbers.ramadan)
		and int(calendar.date(night_day - 1).d) >= int(_numbers.last_ten_from)
		and not _stood_nights.has(night_day))


func stand_at_night(place: String) -> bool:
	if not night_available_at(place):
		return false
	var night_day := _clock.day + int(_clock.minute_of_day >= int(_numbers.night_from))
	_stood_nights[night_day] = true
	return true


func fitr_available_at(place: String) -> bool:
	if place != "masjid" or fitr_given_this_year():
		return false
	var calendar := _clock.calendar
	var offset := _clock.day - 1
	var late_ramadan := (calendar.month_index(offset) == int(_numbers.ramadan)
		and int(calendar.date(offset).d) >= int(_numbers.fitr_from_day))
	return late_ramadan or (is_eid_day() and _clock.minute_of_day < int(_numbers.eid_until))


func give_fitr(place: String, progress: TaskProgress) -> bool:
	var cost := int(_numbers.fitr_cost)
	if not fitr_available_at(place) or progress.coins < cost:
		return false
	progress.coins -= cost
	_fitr_years[_game_year()] = true
	return true


func fitr_given_this_year() -> bool:
	return _fitr_years.has(_game_year())


func is_eid_day() -> bool:
	var offset := _clock.day - 1
	var calendar := _clock.calendar
	return calendar.month_index(offset) == int(_numbers.shawwal) and int(calendar.date(offset).d) == _eid_day_of_month


func eid_prayer_available_at(place: String) -> bool:
	return (place == "masjid" and is_eid_day() and not _eid_days.has(_clock.day)
		and _clock.minute_of_day >= int(_numbers.eid_from) and _clock.minute_of_day < int(_numbers.eid_until))


func pray_eid(place: String) -> bool:
	if not eid_prayer_available_at(place):
		return false
	_eid_days[_clock.day] = true
	return true


func record() -> Dictionary:
	var copy: Dictionary = data.record
	return {
		"nights": str(copy.count).format({"n": _stood_nights.size()}),
		"fitr": copy.yes_fitr if fitr_given_this_year() else copy.no,
		"eid": copy.yes_eid if not _eid_days.is_empty() else copy.no,
	}


func _game_year() -> int:
	return floori(float(_clock.day) / _clock.calendar.year_days)
