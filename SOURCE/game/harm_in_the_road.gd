extends RefCounted
## DOC-TFG-0060: one private act per market day.

var data: Dictionary
var count := 0
var done_day := -1
var moved_harm: Dictionary = {}
var _clock: RefCounted


func setup(source: Dictionary, clock: RefCounted) -> void:
	data = source
	_clock = clock
	reset()


func reset() -> void:
	count = 0
	done_day = -1
	moved_harm = {}


func available_at(place: String) -> Dictionary:
	# The clock shows day 1 on arrival. The locked rotation starts at index 0.
	var day: int = _clock.day - 1
	var minute: int = _clock.minute_of_day
	if day == done_day or minute < int(data.numbers.from) or minute >= int(data.numbers.until):
		return {}
	if place != data.places[day % data.places.size()]:
		return {}
	return data.harms[day % data.harms.size()]


func move_at(place: String) -> bool:
	var harm := available_at(place)
	if harm.is_empty():
		return false
	moved_harm = harm
	done_day = _clock.day - 1
	count += 1
	_clock.advance_to(_clock.day, _clock.minute_of_day + int(data.numbers.minutes))
	return true
