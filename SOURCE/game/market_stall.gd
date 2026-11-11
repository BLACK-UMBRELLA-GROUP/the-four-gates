extends RefCounted
## LOCK 4 purchases, bag contents and reputation.

const TaskProgress = preload("res://game/task_progress.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")

enum Change { NONE, PENDING, RETURNED, KEPT, FOUND }

var data: Dictionary
var change_state := Change.NONE
var stall_notice := ""
var wearing_clothes := false
var _kept_day := 0
var _fed_faris := false
var _bag: Dictionary = {}
var _progress: TaskProgress
var _clock: PrayerClock


func setup(source: Dictionary, progress: TaskProgress, clock: PrayerClock) -> void:
	data = source
	_progress = progress
	_clock = clock


func reset() -> void:
	change_state = Change.NONE
	stall_notice = ""
	wearing_clothes = false
	_kept_day = 0
	_fed_faris = false
	_bag.clear()


func count(id: String) -> int:
	return _bag.get(id, 0)


func purchase_status(item: Dictionary) -> String:
	if item.get("once", false) and count(item.id) > 0:
		return data.stall.owned
	if _progress.coins < int(item.price):
		return data.stall.not_enough
	return ""


func buy(id: String) -> bool:
	if change_state == Change.PENDING:
		return false
	for item: Dictionary in data.items:
		if item.id != id:
			continue
		if not purchase_status(item).is_empty():
			return false
		_progress.coins -= int(item.price)
		_bag[id] = count(id) + 1
		stall_notice = ""
		if change_state == Change.NONE:
			_progress.coins += int(data.numbers.change_extra)
			change_state = Change.PENDING
		return true
	return false


func resolve_change(give_back: bool) -> bool:
	if change_state != Change.PENDING:
		return false
	if give_back:
		_progress.coins -= int(data.numbers.change_extra)
		_progress.apply_trust(int(data.numbers.change_return_trust))
		change_state = Change.RETURNED
		stall_notice = data.stall.change.returned
	else:
		_kept_day = _clock.day
		change_state = Change.KEPT
		stall_notice = data.stall.change.kept
	return true


func visit() -> void:
	stall_notice = ""
	if change_state == Change.KEPT and _clock.day > _kept_day:
		_progress.apply_trust(int(data.numbers.change_kept_trust))
		change_state = Change.FOUND
		stall_notice = data.stall.change.found


func toggle_clothes() -> bool:
	if count("clothes") == 0:
		return false
	wearing_clothes = not wearing_clothes
	return true


func give_bread() -> bool:
	if count("bread") == 0:
		return false
	_bag["bread"] -= 1
	if not _fed_faris:
		_fed_faris = true
		_progress.apply_trust(int(data.numbers.feed_trust))
	return true


func reputation_lines() -> Array:
	var lines: Array = []
	if change_state == Change.RETURNED:
		lines.append(data.say.returned)
	elif change_state == Change.FOUND:
		lines.append(data.say.kept)
	if _fed_faris:
		lines.append(data.say.fed)
	if wearing_clothes:
		lines.append(data.say.clothes)
	return lines
