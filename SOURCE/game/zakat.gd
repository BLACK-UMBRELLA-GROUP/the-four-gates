extends RefCounted
## DOC-TFG-0075: annual coin assessments and the private Zakat record.

const PrayerClock = preload("res://game/prayer_clock.gd")
const TaskProgress = preload("res://game/task_progress.gd")

var data: Dictionary
var _clock: PrayerClock
var _progress: TaskProgress
var _assessments: Array[Dictionary] = []
var _served: Dictionary = {}


func _init(source: Dictionary, clock: PrayerClock, progress: TaskProgress) -> void:
	data = source
	_clock = clock
	_progress = progress


func reset() -> void:
	_assessments.clear()
	close_panel()


func assess_years() -> void:
	# The clock numbers arrival as day 1, but the calendar indexes it as day 0.
	var elapsed_day := _clock.day - 1
	@warning_ignore("integer_division")
	var years_ended: int = elapsed_day / _clock.calendar.year_days
	if _assessments.size() >= years_ended:
		return
	var coins := _progress.coins
	var share := int(data.numbers.share)
	@warning_ignore("integer_division")
	var due := coins / share + int(coins % share != 0) if coins >= int(data.numbers.threshold) else 0
	while _assessments.size() < years_ended:
		_assessments.append({"day": _clock.day, "coins": coins, "due": due, "receipt": ""})


func available_at(place: String) -> bool:
	if place != "masjid" or _assessments.is_empty():
		return false
	var latest: Dictionary = _assessments.back()
	return not _oldest_unpaid().is_empty() or (latest.due == 0 and latest.day == _clock.day)


func open_panel(place: String) -> bool:
	if not available_at(place):
		return false
	_served = _oldest_unpaid()
	if _served.is_empty():
		_served = _assessments.back()
	return true


func close_panel() -> void:
	_served = {}


func panel() -> Dictionary:
	var copy: Dictionary = data.panel
	var due: int = _served.due
	var fields := {"c": _served.coins, "t": int(data.numbers.threshold), "n": due}
	var notice: String = _served.receipt
	var can_pay := due > 0 and notice.is_empty()
	if can_pay and _progress.coins < due:
		notice = str(copy.not_enough).format(fields)
		can_pay = false
	return {
		"summary": str(copy.due if due > 0 else copy.none).format(fields),
		"notice": notice,
		"can_pay": can_pay,
	}


func pay(id: String) -> bool:
	if _served.is_empty() or _served.due == 0 or not _served.receipt.is_empty() or _progress.coins < _served.due:
		return false
	for option: Dictionary in data.options:
		if option.id == id:
			_progress.coins -= int(_served.due)
			_served.receipt = option.out
			return true
	return false


func record() -> String:
	if _assessments.is_empty():
		return ""
	var copy: Dictionary = data.record
	var total := 0
	for assessment in _assessments:
		if assessment.receipt.is_empty():
			total += int(assessment.due)
	if total > 0:
		return str(copy.due).format({"n": total})
	var latest: Dictionary = _assessments.back()
	return copy.none if latest.due == 0 else str(copy.paid).format({"n": latest.due})


func _oldest_unpaid() -> Dictionary:
	for assessment in _assessments:
		if assessment.due > 0 and assessment.receipt.is_empty():
			return assessment
	return {}
