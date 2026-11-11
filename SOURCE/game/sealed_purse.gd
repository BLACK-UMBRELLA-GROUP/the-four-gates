extends RefCounted
## DOC-TFG-0039: Karim's sealed-purse job and Abbas's count.

const MarketDay = preload("res://game/market_day.gd")
const TaskProgress = preload("res://game/task_progress.gd")

enum State { OFFER, COIN, WHOLE, SHORT, DELIVERED_WHOLE, DELIVERED_SHORT }

var data: Dictionary
var state := State.OFFER
var _progress: TaskProgress
var _market_day: MarketDay
var _opens: int
var _closes: int


func setup(source: Dictionary, progress: TaskProgress, market_day: MarketDay, opens: int, closes: int) -> void:
	data = source
	_progress = progress
	_market_day = market_day
	_opens = opens
	_closes = closes


func reset() -> void:
	state = State.OFFER


func offer_available() -> bool:
	return state == State.OFFER and _progress.trust >= int(data.numbers.offer_from_trust) \
		and _market_day.status_during(_opens, _closes) == MarketDay.Status.OPEN


func accept() -> bool:
	if not offer_available():
		return false
	state = State.COIN
	return true


func choose_coin(keep: bool) -> bool:
	if state != State.COIN:
		return false
	state = State.SHORT if keep else State.WHOLE
	if keep:
		_progress.coins += int(data.numbers.kept_coin)
	return true


func is_carrying() -> bool:
	return state == State.WHOLE or state == State.SHORT


func deliver() -> bool:
	if not is_carrying():
		return false
	if state == State.WHOLE:
		state = State.DELIVERED_WHOLE
		_progress.apply_trust(int(data.numbers.honest_trust))
		_progress.coins += int(data.numbers.fee)
	else:
		state = State.DELIVERED_SHORT
		_progress.apply_trust(int(data.numbers.kept_trust))
	return true


func reputation_line() -> Variant:
	match state:
		State.DELIVERED_WHOLE: return data.say.honest
		State.DELIVERED_SHORT: return data.say.kept
	return null
