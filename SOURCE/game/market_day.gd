extends RefCounted
## DOC-TFG-0030: LOCK 7 opening hours and Friday closures.

const PrayerClock = preload("res://game/prayer_clock.gd")

enum Status { OPEN, OUTSIDE_HOURS, FRIDAY_PRAYER }

var data: Dictionary
var _clock: PrayerClock


func _init(source: Dictionary, clock: PrayerClock) -> void:
	data = source
	_clock = clock


func status(regular_id: String) -> Status:
	var hours: Dictionary = data.hours.get(regular_id, {})
	if hours.is_empty():
		return Status.OPEN
	return status_during(int(hours.open), int(hours.close))


func status_during(opens: int, closes: int) -> Status:
	if _clock.is_friday_prayer_window(int(data.friday.closed_until_minutes_after_iqamah)):
		return Status.FRIDAY_PRAYER
	if _clock.minute_of_day < opens or _clock.minute_of_day >= closes:
		return Status.OUTSIDE_HOURS
	return Status.OPEN


func talk_notice(regular_id: String, availability: Status) -> String:
	var copy: String = data.text.closed_friday if availability == Status.FRIDAY_PRAYER else data.text.closed_night
	return copy.format({"name": data.hours[regular_id].name})
