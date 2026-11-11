extends RefCounted
## DOC-TFG-0087: LOCK 26 V1 Names learned in River Market.

var data: Dictionary
var learned: Array[String] = []
var current_name: Dictionary = {}


func _init(source: Dictionary) -> void:
	data = source


func reset() -> void:
	learned.clear()
	current_name = {}


func unread_at(place: String, idris_met: bool) -> Dictionary:
	if idris_met:
		for entry: Dictionary in data.names:
			if entry.place == place and entry.id not in learned:
				return entry
	return {}


func learn_at(place: String, idris_met: bool) -> bool:
	var entry := unread_at(place, idris_met)
	if entry.is_empty():
		return false
	learned.append(entry.id)
	current_name = entry
	return true


func count_text() -> String:
	return str(data.panel.count).format({"n": learned.size(), "m": int(data.numbers.goal)})
