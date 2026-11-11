extends RefCounted
## DOC-TFG-0078: LOCK 23's Dhu al-Hijjah activities and private record.

const PrayerClock = preload("res://game/prayer_clock.gd")
const TaskProgress = preload("res://game/task_progress.gd")
const JabirsGoats = preload("res://game/jabirs_goats.gd")
const Feeding = preload("res://game/feeding.gd")
const RECORD_DAYS := 30 # DOC-TFG-0078 §7; no field in the locked data.

enum Action { NONE, SHEEP, ARAFAH, PRAYER, SACRIFICE }

var data: Dictionary
var _numbers: Dictionary
var _clock: PrayerClock
var _progress: TaskProgress
var _goats: JabirsGoats
var _meals: Feeding.MealCounter
var _owns_sheep := false
var _arafah_day := 0
var _eid_prayer_day := 0
var _sacrifice_day := 0


func _init(source: Dictionary, clock: PrayerClock, progress: TaskProgress, goats: JabirsGoats, meals: Feeding.MealCounter) -> void:
	data = source
	_numbers = source.numbers
	_clock = clock
	_progress = progress
	_goats = goats
	_meals = meals


func reset() -> void:
	_owns_sheep = false
	_arafah_day = 0
	_eid_prayer_day = 0
	_sacrifice_day = 0


func action_at(place: String) -> Action:
	match place:
		"gate":
			if sheep_available_at(place):
				return Action.SHEEP
			if sacrifice_available_at(place):
				return Action.SACRIFICE
		"inn":
			if arafah_available_at(place):
				return Action.ARAFAH
		"masjid":
			if eid_prayer_available_at(place):
				return Action.PRAYER
	return Action.NONE


func sheep_available_at(place: String) -> bool:
	var date := _dhu_day(_clock.day)
	return (place == "gate" and not _owns_sheep and date > 0 and date <= int(_numbers.sell_until_day)
		and _in_window(_numbers.sell_from, _numbers.sell_until))


func can_afford_sheep() -> bool:
	return _progress.coins >= int(_numbers.sheep_cost)


func owns_sheep() -> bool:
	return _owns_sheep


func saeed_remembers() -> bool:
	return _goats.told


func buy_sheep(place: String) -> bool:
	if not sheep_available_at(place) or not can_afford_sheep():
		return false
	_progress.coins -= int(_numbers.sheep_cost)
	_owns_sheep = true
	return true


func arafah_available_at(place: String) -> bool:
	return (place == "inn" and _dhu_day(_clock.day) == int(_numbers.arafah_day) and _arafah_day != _clock.day
		and _in_window(_numbers.suhoor_from, _numbers.fast_from))


func intend_arafah(place: String) -> bool:
	if not arafah_available_at(place):
		return false
	_arafah_day = _clock.day
	return true


func eid_prayer_available_at(place: String) -> bool:
	return (place == "masjid" and _dhu_day(_clock.day) == int(_numbers.eid_day) and _eid_prayer_day != _clock.day
		and _in_window(_numbers.eid_from, _numbers.eid_until))


func pray_eid(place: String) -> bool:
	if not eid_prayer_available_at(place):
		return false
	_eid_prayer_day = _clock.day
	return true


func sacrifice_available_at(place: String) -> bool:
	if place != "gate" or not _owns_sheep:
		return false
	var date := _dhu_day(_clock.day)
	var eid_day := int(_numbers.eid_day)
	var last_day := int(_numbers.tashreeq_last)
	if date == eid_day:
		return _eid_prayer_day == _clock.day or _clock.minute_of_day >= int(_numbers.eid_until)
	return date > eid_day and (date < last_day or (date == last_day and _clock.minute_of_day < int(_numbers.iftar_from)))


func sacrifice(place: String, give_all: bool) -> bool:
	if not sacrifice_available_at(place):
		return false
	_meals.total += int(_numbers.all_meals if give_all else _numbers.thirds_meals)
	_owns_sheep = false
	_sacrifice_day = _clock.day
	return true


func bar_line() -> String:
	var date := _dhu_day(_clock.day)
	if date == int(_numbers.arafah_day) and _in_window(_numbers.fast_from, _numbers.iftar_from):
		var iftar := int(_numbers.iftar_from)
		var time := "%02d:%02d" % [floori(float(iftar) / PrayerClock.MINUTES_PER_HOUR), iftar % PrayerClock.MINUTES_PER_HOUR]
		return str(data.arafah_line).format({"t": time})
	if date == int(_numbers.eid_day):
		return data.eid_line
	if date > int(_numbers.eid_day) and date <= int(_numbers.tashreeq_last):
		return data.tashreeq_line
	return ""


func has_prayed_at_masjid() -> bool:
	return _eid_prayer_day > 0


func record() -> Dictionary:
	var first := maxi(1, _clock.day - RECORD_DAYS + 1)
	for day in range(_clock.day, first - 1, -1):
		var date := _dhu_day(day)
		if date > 0:
			var season_start := day - date + 1
			var copy: Dictionary = data.record
			return {
				"arafah": copy.yes_fast if _arafah_day >= season_start else copy.no,
				"eid": copy.yes_eid if _eid_prayer_day >= season_start else copy.no,
				"sacrifice": copy.yes_sac if _sacrifice_day >= season_start else copy.no,
			}
	return {}


func _dhu_day(day: int) -> int:
	var offset := day - 1
	if _clock.calendar.month_index(offset) == int(_numbers.month):
		return int(_clock.calendar.date(offset).d)
	return 0


func _in_window(from: int, until: int) -> bool:
	return _clock.minute_of_day >= from and _clock.minute_of_day < until
