extends RefCounted
## DOC-TFG-0084: LOCK 25 V1 Masjid donations and lifetime counters.

const Foundations = preload("res://game/foundations.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")
const TaskProgress = preload("res://game/task_progress.gd")

var data: Dictionary
var qurans_given := 0
var children_in_school := 0
var secret_selected := false
var message: String
var _progress: TaskProgress
var _clock: PrayerClock
var _last_public_day := -1
var _public_qurans := false
var _public_school := false


func _init(source: Dictionary, clock: PrayerClock, progress: TaskProgress) -> void:
	data = source
	_clock = clock
	_progress = progress
	open_panel()


func reset() -> void:
	qurans_given = 0
	children_in_school = 0
	_last_public_day = -1
	_public_qurans = false
	_public_school = false
	open_panel()


func available_at(place: String) -> bool:
	return place == "masjid" and _clock.minute_of_day >= int(data.numbers.from) and _clock.minute_of_day < int(data.numbers.until)


func open_panel() -> void:
	secret_selected = false
	message = data.panel.text


func cost(kind: String) -> int:
	return int(data.numbers.quran_cost) if kind == "quran" else int(data.numbers.school_cost)


func can_afford(kind: String) -> bool:
	return _progress.coins >= cost(kind)


func pay(kind: String, page_read: bool) -> bool:
	if kind not in ["quran", "school"] or not can_afford(kind):
		return false
	var secret := page_read and secret_selected
	_progress.coins -= cost(kind)
	if kind == "quran":
		qurans_given += 1
		_public_qurans = _public_qurans or not secret
		message = data.panel.quran_done
	else:
		children_in_school += 1
		_public_school = _public_school or not secret
		message = data.panel.first_child if children_in_school == 1 else data.panel.more_child
	if not secret and _last_public_day != _clock.day:
		_progress.apply_trust(int(data.numbers.trust_per_day))
		_last_public_day = _clock.day
	message += " " + (data.panel.secret if secret else data.panel.public)
	return true


func reputation_lines() -> Array:
	var lines := []
	if _public_qurans:
		lines.append(data.say.qurans)
	if _public_school:
		lines.append(data.say.school)
	return lines


func counters() -> String:
	var qurans := str(data.panel.counter).format({
		"n": Foundations.format_count(qurans_given),
		"m": Foundations.format_count(int(data.numbers.goal_qurans)),
	})
	var school := str(data.panel.counter_school).format({
		"n": Foundations.format_count(children_in_school),
		"m": Foundations.format_count(int(data.numbers.goal_children)),
	})
	return "%s · %s" % [qurans, school]
