extends RefCounted
## DOC-TFG-0081: LOCK 24 V2 pilgrim bookings and returns.

const PrayerClock = preload("res://game/prayer_clock.gd")
const TaskProgress = preload("res://game/task_progress.gd")
const Foundations = preload("res://game/foundations.gd")

enum Status { SEND, NOT_ENOUGH, HAJJ_CLOSED, AWAY, HOME }

var data: Dictionary
var secret_selected := false
var umrah_paid := 0
var hajj_paid := 0
var _clock: PrayerClock
var _progress: TaskProgress
var _numbers: Dictionary
var _trips: Dictionary = {}


func _init(source: Dictionary, clock: PrayerClock, progress: TaskProgress) -> void:
	data = source
	_numbers = data.numbers
	_clock = clock
	_progress = progress


func reset() -> void:
	secret_selected = false
	umrah_paid = 0
	hajj_paid = 0
	_trips.clear()


func available_at(place: String) -> bool:
	return place == "gate" and _clock.minute_of_day >= int(_numbers.from) and _clock.minute_of_day < int(_numbers.until)


func status(pilgrim: Dictionary) -> Status:
	if _trips.has(pilgrim.id):
		return Status.HOME if _trips[pilgrim.id].home else Status.AWAY
	if pilgrim.kind == "hajj" and not _hajj_open():
		return Status.HAJJ_CLOSED
	return Status.SEND if _progress.coins >= cost(pilgrim) else Status.NOT_ENOUGH


func cost(pilgrim: Dictionary) -> int:
	return int(_numbers.hajj_cost) if pilgrim.kind == "hajj" else int(_numbers.umrah_cost)


func days_until_home(id: String) -> int:
	return maxi(0, int(_trips[id].home_day) - _clock.day)


func send(id: String, page_read: bool) -> bool:
	for pilgrim: Dictionary in data.pilgrims:
		if pilgrim.id != id:
			continue
		if status(pilgrim) != Status.SEND:
			return false
		var days := int(_numbers.umrah_days)
		if pilgrim.kind == "hajj":
			days = _clock.calendar.days_until_date(
				_clock.day - 1, int(_numbers.hajj_back_month), int(_numbers.hajj_back_day))
			hajj_paid += 1
		else:
			umrah_paid += 1
		_progress.coins -= cost(pilgrim)
		_trips[id] = {"home_day": _clock.day + days, "secret": secret_selected and page_read, "home": false}
		return true
	return false


func resolve_returns() -> void:
	for trip: Dictionary in _trips.values():
		if not trip.home and _clock.day >= int(trip.home_day):
			trip.home = true
			if not trip.secret:
				_progress.apply_trust(int(_numbers.return_trust))


func home_from_trip(id: String, secret: bool) -> bool:
	var trip: Dictionary = _trips.get(id, {})
	return not trip.is_empty() and trip.home and trip.secret == secret


func reputation_lines() -> Array:
	var lines := []
	for pilgrim: Dictionary in data.pilgrims:
		if home_from_trip(pilgrim.id, false):
			lines.append(pilgrim.say)
	return lines


func counters() -> String:
	var umrah := str(data.panel.counter).format({
		"n": Foundations.format_count(umrah_paid), "m": Foundations.format_count(int(_numbers.goal_umrah)),
	})
	var hajj := str(data.panel.counter_hajj).format({
		"n": Foundations.format_count(hajj_paid), "m": Foundations.format_count(int(_numbers.goal_hajj)),
	})
	return "%s · %s" % [umrah, hajj]


func _hajj_open() -> bool:
	var calendar := _clock.calendar
	var today := _clock.day - 1
	var month := calendar.month_index(today)
	var last_month := int(_numbers.hajj_book_until_month)
	return (month >= int(_numbers.hajj_book_from_month) and month <= last_month
		and (month < last_month or int(calendar.date(today).d) <= int(_numbers.hajj_book_until_day)))
