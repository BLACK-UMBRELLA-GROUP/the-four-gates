extends RefCounted
## DOC-TFG-0057: Rashid's loan and its calendar-day repayments.

const TaskProgress = preload("res://game/task_progress.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")
const MarketDay = preload("res://game/market_day.gd")

enum State { UNASKED, LENT, WAITING, REFUSED, REPAID }
enum Offer { HIDDEN, ASK, OWED, DUE, LAST }

var data: Dictionary
var outcome := ""
var _state := State.UNASKED
var _since_day := 0
var _progress: TaskProgress
var _clock: PrayerClock
var _market_day: MarketDay


func setup(source: Dictionary, progress: TaskProgress, clock: PrayerClock, market_day: MarketDay) -> void:
	data = source
	_progress = progress
	_clock = clock
	_market_day = market_day


func reset() -> void:
	_state = State.UNASKED
	_since_day = 0
	outcome = ""


func offer() -> Offer:
	if _market_day.status("rashid") != MarketDay.Status.OPEN:
		return Offer.HIDDEN
	match _state:
		State.UNASKED:
			if _progress.trust >= int(data.numbers.min_trust):
				return Offer.ASK
		State.LENT:
			return Offer.DUE if _clock.day - _since_day >= int(data.numbers.due_days) else Offer.OWED
		State.WAITING:
			return Offer.LAST if _clock.day - _since_day >= int(data.numbers.more_days) else Offer.OWED
	return Offer.HIDDEN


func can_afford() -> bool:
	return _progress.coins >= int(data.numbers.loan)


func amount_owed() -> int:
	return int(data.numbers.loan) - int(data.numbers.first_pay) if _state == State.WAITING else int(data.numbers.loan)


func answer_ask(choice: String) -> bool:
	if _state != State.UNASKED or _progress.trust < int(data.numbers.min_trust) or not can_afford():
		return false
	match choice:
		"lend":
			_state = State.LENT
			_since_day = _clock.day
			_progress.coins -= int(data.numbers.loan)
		"lend_more":
			_state = State.REFUSED
			outcome = "riba"
			_progress.apply_trust(int(data.numbers.riba_trust))
		_:
			return false
	return true


func answer_due(choice: String) -> bool:
	if _state != State.LENT or _clock.day - _since_day < int(data.numbers.due_days):
		return false
	if choice not in ["wait", "forgive", "demand"]:
		return false
	outcome = choice
	_state = State.WAITING if choice == "wait" else State.REPAID
	_since_day = _clock.day
	_progress.coins += int(data.numbers.loan if choice == "demand" else data.numbers.first_pay)
	_progress.apply_trust(int(data.numbers[choice + "_trust"]))
	return true


func collect_last_payment() -> bool:
	if offer() != Offer.LAST:
		return false
	_progress.coins += amount_owed()
	_state = State.REPAID
	return true


func reputation_line() -> Variant:
	return data.say.get(outcome)
