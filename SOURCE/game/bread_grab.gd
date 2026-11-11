extends RefCounted
## LOCK 3 V2 part 2: the bread grab and its one answer.

enum Prompt { NONE, SEE, WAIT, ASK }

const TaskProgress = preload("res://game/task_progress.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")

var answer_id := ""
var _seen_day := 0
var _chapter: Dictionary
var _progress: TaskProgress
var _clock: PrayerClock


func setup(chapter: Dictionary, progress: TaskProgress, clock: PrayerClock) -> void:
	_chapter = chapter
	_progress = progress
	_clock = clock


func reset() -> void:
	_seen_day = 0
	answer_id = ""


func board_prompt(salma_present: bool) -> Prompt:
	if not answer_id.is_empty():
		return Prompt.NONE
	if _seen_day == 0:
		return Prompt.SEE if salma_present else Prompt.NONE
	if salma_present and _clock.day >= _seen_day and _clock.minute_of_day >= int(_chapter.numbers.grab_ask_minute):
		return Prompt.ASK
	return Prompt.WAIT


func see() -> void:
	_seen_day = _clock.day


func answer(id: String) -> bool:
	if not answer_id.is_empty() or not _chapter.grab.answers.has(id):
		return false
	var choice: Dictionary = _chapter.grab.answers[id]
	_progress.apply_trust(int(choice.trust))
	_progress.coins = maxi(0, _progress.coins + int(choice.coins))
	answer_id = id
	return true


func reputation_line() -> Variant:
	return null if answer_id.is_empty() else _chapter.grab.answers[answer_id].say
