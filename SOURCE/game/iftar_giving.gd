extends "res://game/feeding.gd"
## DOC-TFG-0069: LOCK 20 iftar payments use the LOCK 9 meal counter.

const Ramadan = preload("res://game/ramadan.gd")

var _ramadan: Ramadan


func _init(ramadan: Ramadan) -> void:
	_ramadan = ramadan


func available_at(place: String) -> bool:
	return (place == "masjid" and _ramadan.is_ramadan_day(_clock.day)
		and _clock.minute_of_day >= int(data.numbers.from)
		and _clock.minute_of_day < int(data.numbers.until))
