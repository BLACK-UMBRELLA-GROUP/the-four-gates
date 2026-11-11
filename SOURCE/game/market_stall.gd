extends RefCounted
## Market purchases, shared bag contents, wardrobe and reputation.

const TaskProgress = preload("res://game/task_progress.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")

enum Change { NONE, PENDING, RETURNED, KEPT, FOUND }

var data: Dictionary
var clothes_data: Dictionary
var loom_items: Array[Dictionary] = []
var change_state := Change.NONE
var stall_notice := ""
var worn_clothes := ""
var _kept_day := 0
var fed_faris := false
var _bag: Dictionary = {}
var _progress: TaskProgress
var _clock: PrayerClock


func setup(source: Dictionary, clothes_source: Dictionary, progress: TaskProgress, clock: PrayerClock) -> void:
	data = source
	clothes_data = clothes_source
	_progress = progress
	_clock = clock
	loom_items.assign([clothes_data.leather_bag])
	for outfit: Dictionary in clothes_data.clothes:
		if outfit.seller == "Layla":
			loom_items.append(outfit)
	reset()


func reset() -> void:
	change_state = Change.NONE
	stall_notice = ""
	worn_clothes = ""
	_kept_day = 0
	fed_faris = false
	_bag.clear()
	for outfit: Dictionary in clothes_data.clothes:
		if outfit.get("start", false):
			_bag[outfit.id] = 1
			worn_clothes = outfit.id


func count(id: String) -> int:
	return _bag.get(id, 0)


func capacity() -> int:
	return int(clothes_data.numbers.leather_bag if count(clothes_data.leather_bag.id) else clothes_data.numbers.pouch)


func carried() -> int:
	var total := count("bread") + count("dates")
	for outfit: Dictionary in clothes_data.clothes:
		if outfit.id != worn_clothes:
			total += count(outfit.id)
	return total


func is_full() -> bool:
	return carried() >= capacity()


func purchase_status(item: Dictionary) -> String:
	if item.get("once", false) and count(item.id) > 0:
		return data.stall.owned
	if _progress.coins < int(item.price):
		return data.stall.not_enough
	if is_full():
		return clothes_data.loom.full
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


func loom_status(item: Dictionary) -> String:
	if count(item.id) > 0:
		return clothes_data.loom.owned
	if _progress.coins < int(item.price):
		return clothes_data.loom.not_enough
	if item.id != clothes_data.leather_bag.id and is_full():
		return clothes_data.loom.full
	return ""


func buy_at_loom(id: String) -> bool:
	for item in loom_items:
		if item.id != id:
			continue
		if not loom_status(item).is_empty():
			return false
		_progress.coins -= int(item.price)
		_bag[id] = 1
		return true
	return false


func wear(id: String) -> bool:
	if id == worn_clothes or count(id) == 0:
		return false
	for outfit: Dictionary in clothes_data.clothes:
		if outfit.id == id:
			worn_clothes = id
			return true
	return false


func give_bread() -> bool:
	if count("bread") == 0:
		return false
	_bag["bread"] -= 1
	if not fed_faris:
		fed_faris = true
		_progress.apply_trust(int(data.numbers.feed_trust))
	return true


func trade_reputation_lines() -> Array:
	var lines: Array = []
	if change_state == Change.RETURNED:
		lines.append(data.say.returned)
	elif change_state == Change.FOUND:
		lines.append(data.say.kept)
	if fed_faris:
		lines.append(data.say.fed)
	return lines


func clothing_reputation_line() -> Variant:
	if worn_clothes == "clothes":
		return data.say.clothes
	if worn_clothes == "best":
		return clothes_data.say.best_friday if _clock.is_friday() else null
	return clothes_data.say.get(worn_clothes)
