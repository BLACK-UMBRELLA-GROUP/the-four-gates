extends RefCounted
## DOC-TFG-0030 and DOC-TFG-0090: market hours, Friday closures and prayer attendance.

const PrayerClock = preload("res://game/prayer_clock.gd")

enum Status { OPEN, OUTSIDE_HOURS, FRIDAY_PRAYER, AWAY_AT_PRAYER }

var data: Dictionary
var prayer_data: Dictionary
var _clock: PrayerClock


func _init(source: Dictionary, clock: PrayerClock, prayer_source: Dictionary) -> void:
	data = source
	_clock = clock
	prayer_data = prayer_source


func status(regular_id: String) -> Status:
	var hours: Dictionary = data.hours.get(regular_id, {})
	if hours.is_empty():
		return Status.OPEN
	var availability := status_during(int(hours.open), int(hours.close))
	if availability == Status.OPEN and regular_id in prayer_data.goers and not prayer_attendance().is_empty():
		return Status.AWAY_AT_PRAYER
	return availability


func status_during(opens: int, closes: int) -> Status:
	if _clock.is_friday_prayer_window(int(data.friday.closed_until_minutes_after_iqamah)):
		return Status.FRIDAY_PRAYER
	if _clock.minute_of_day < opens or _clock.minute_of_day >= closes:
		return Status.OUTSIDE_HOURS
	return Status.OPEN


func talk_notice(regular_id: String, availability: Status) -> String:
	var name: String = data.hours[regular_id].name
	if availability == Status.AWAY_AT_PRAYER:
		return str(prayer_data.text.person).format({"name": name, "prayer": prayer_attendance()})
	var copy: String = data.text.closed_friday if availability == Status.FRIDAY_PRAYER else data.text.closed_night
	return copy.format({"name": name})


func prayer_attendance() -> String:
	return _clock.prayer_name_during_iqamah_window(prayer_data.prayers, int(prayer_data.numbers.minutes_after_iqamah))


func masjid_attendance_notice(prayer: String) -> String:
	var names := PackedStringArray()
	for regular_id: String in prayer_data.goers:
		names.append(data.hours[regular_id].name)
	return str(prayer_data.text.masjid).format({"prayer": prayer, "names": ", ".join(names)})
