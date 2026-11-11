extends RefCounted
## LOCK 14: Idris responds to the full trust changes, including beyond the HUD limits.

const TaskProgress = preload("res://game/task_progress.gd")

var data: Dictionary
var cool := false
var cool_point := 0
var _trust_tally := 0
var _has_cooled := false


func setup(source: Dictionary, progress: TaskProgress) -> void:
	data = source
	reset(progress.trust)
	progress.trust_changed.connect(_on_trust_changed)
	progress.temptation_taken.connect(_on_temptation_taken)


func reset(start_trust: int) -> void:
	cool = false
	cool_point = 0
	_trust_tally = start_trust
	_has_cooled = false


func _on_trust_changed(amount: int) -> void:
	_trust_tally += amount
	if cool and _trust_tally >= cool_point + int(data.numbers.warm_gain):
		cool = false


func _on_temptation_taken(trust_hit: bool) -> void:
	if trust_hit or cool:
		cool = true
		cool_point = _trust_tally
		_has_cooled = true


func reputation_line() -> Variant:
	if _has_cooled:
		return data.say.cool if cool else data.say.warm
	return null
