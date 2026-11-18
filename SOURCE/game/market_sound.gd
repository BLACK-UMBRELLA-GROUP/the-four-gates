extends RefCounted
## LOCK 100: dispatches approved cues using silent placeholders.

signal cue_started(key: String)

var enabled := true
var adhan_enabled := true
var ambience := ""
var _keys: Dictionary = {}


func _init(data: Dictionary) -> void:
	for cue: Array in data.get("keys", []):
		_keys[cue[0]] = true


func play(key: String) -> void:
	if _can_play(key):
		cue_started.emit(key)


func set_ambience(key: String) -> void:
	var next := key if _can_play(key) else ""
	if ambience == next:
		return
	ambience = next
	if not ambience.is_empty():
		cue_started.emit(ambience)


func _can_play(key: String) -> bool:
	return enabled and (key != "adhan" or adhan_enabled) and _keys.has(key)
