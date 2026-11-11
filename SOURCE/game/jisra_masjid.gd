extends RefCounted
## DOC-TFG-0108: the private set of masjids prayed in and Uthman's first greeting.

const RIVER_MARKET := "river_market"
const JISRA := "jisra"

var data: Dictionary
var prayed_in: Dictionary = {}
var show_first := false


func _init(source: Dictionary) -> void:
	data = source


func reset() -> void:
	prayed_in.clear()
	show_first = false


func restore_legacy(prayed_at_masjid: bool) -> void:
	reset()
	# Before Jisra's masjid opened, every masjid prayer was in River Market.
	if prayed_at_masjid:
		record_prayer(RIVER_MARKET)


func record_prayer(masjid_id: String, loaded_town_masjid := false) -> void:
	if not loaded_town_masjid and not data.masjids.has(masjid_id):
		return
	if masjid_id == JISRA:
		show_first = not prayed_in.has(JISRA)
	prayed_in[masjid_id] = true


func counter() -> String:
	if prayed_in.is_empty():
		return ""
	return str(data.counter).format({"n": prayed_in.size(), "m": int(data.numbers.goal_masjids)})
