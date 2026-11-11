extends RefCounted
## DOC-TFG-0102: Layla's second loom and its weekly profit shares.

const TaskProgress = preload("res://game/task_progress.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")
const MarketDay = preload("res://game/market_day.gd")

enum Offer { HIDDEN, ASK, RUNNING, DUE }

var data: Dictionary
var _partner_day := 0
var _weeks_collected := 0
var _refused := false
var _progress: TaskProgress
var _clock: PrayerClock
var _market_day: MarketDay


func setup(source: Dictionary, progress: TaskProgress, clock: PrayerClock, market_day: MarketDay) -> void:
	data = source
	_progress = progress
	_clock = clock
	_market_day = market_day


func reset() -> void:
	_partner_day = 0
	_weeks_collected = 0
	_refused = false


func offer() -> Offer:
	if _refused or _market_day.status("layla") != MarketDay.Status.OPEN:
		return Offer.HIDDEN
	if _partner_day > 0:
		return Offer.DUE if days_until_share() <= 0 else Offer.RUNNING
	return Offer.ASK if _progress.trust >= int(data.numbers.min_trust) else Offer.HIDDEN


func days_until_share() -> int:
	return _partner_day + (_weeks_collected + 1) * int(data.numbers.week_days) - _clock.day


func can_afford() -> bool:
	return _progress.coins >= int(data.numbers.capital)


func answer(choice: String) -> bool:
	if offer() != Offer.ASK or not can_afford():
		return false
	match choice:
		"partner":
			_progress.coins -= int(data.numbers.capital)
			_partner_day = _clock.day
		"fixed":
			_refused = true
			_progress.apply_trust(int(data.numbers.riba_trust))
		_:
			return false
	return true


func collect_share() -> bool:
	if offer() != Offer.DUE:
		return false
	_weeks_collected += 1
	_progress.coins += _share_of(_profit_for(_weeks_collected))
	return true


func week_kicker() -> String:
	return str(data.week.kicker).format({"n": _weeks_collected})


func week_story() -> String:
	var profit := _profit_for(_weeks_collected)
	if profit == 0:
		return data.week.none
	return str(data.week.good).format({"m": profit, "n": _share_of(profit)})


func reputation_line() -> Variant:
	if _refused:
		return data.say.riba
	if _partner_day > 0:
		return data.say.partner
	return null


func _profit_for(week: int) -> int:
	var profits: Array = data.numbers.profits
	return int(profits[posmod(week - 1, profits.size())])


func _share_of(profit: int) -> int:
	return floori(profit * float(data.numbers.share_percent) / 100.0)
