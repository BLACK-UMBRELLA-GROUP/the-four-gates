extends RefCounted
## LOCK 11: the invitation, the dice and River Market's response to repeated visits.

const PrayerClock = preload("res://game/prayer_clock.gd")
const TaskProgress = preload("res://game/task_progress.gd")

var data: Dictionary
var invited := false
var nights := 0
var last_result := ""
var _clock: PrayerClock
var _progress: TaskProgress
var _last_visit_night := -1


func setup(source: Dictionary, progress: TaskProgress, clock: PrayerClock) -> void:
	data = source
	_progress = progress
	_clock = clock


func reset() -> void:
	invited = false
	nights = 0
	last_result = ""
	_last_visit_night = -1


func is_open() -> bool:
	return _clock.in_overnight_window(int(data.numbers.open_from), int(data.numbers.open_until))


func inn_caption() -> String:
	if not is_open():
		return ""
	return data.inn_button if invited else data.inn_invite


func enter() -> bool:
	if not is_open():
		return false
	var visit_night := _clock.evening_day(int(data.numbers.open_until))
	if visit_night != _last_visit_night:
		_last_visit_night = visit_night
		nights += 1
		if nights == int(data.numbers.seen_from_visits):
			_progress.apply_trust(int(data.numbers.seen_trust))
		elif nights == int(data.numbers.gambler_from_visits):
			_progress.apply_trust(int(data.numbers.gambler_trust))
	return true


func can_afford(bet: int) -> bool:
	return _progress.coins >= bet


func bet_coins(bet: int, roll_percent: int = -1) -> bool:
	if not data.bets.has(float(bet)) or not can_afford(bet):
		return false
	var roll := randi_range(0, 99) if roll_percent < 0 else roll_percent
	var won := roll < int(data.numbers.win_chance_percent)
	_progress.coins += bet if won else -bet
	last_result = str(data.house.won if won else data.house.lost).format({"n": bet})
	return true


func reputation_line() -> Variant:
	if nights >= int(data.numbers.gambler_from_visits):
		return data.say.gambler
	if nights >= int(data.numbers.seen_from_visits):
		return data.say.seen
	if nights >= int(data.numbers.talk_from_visits):
		return data.say.talk
	return null
