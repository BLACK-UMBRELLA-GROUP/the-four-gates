extends RefCounted
## LOCK 36 V2 and LOCK 103: the roads from Ilmara and journey gate thresholds.

const TENTHS_PER_GOAL := 10
const MINUTES_PER_HOUR := 60

var data: Dictionary
var _unlocked_gates: Dictionary = {}


func _init(content: Dictionary) -> void:
	data = content


static func load_data() -> Dictionary:
	const PATH := "res://data/road_map.json"
	if not FileAccess.file_exists(PATH):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not parsed is Dictionary:
		push_error("Invalid road map data: " + PATH)
		return {}
	return parsed


func journey_percent(app) -> int:
	var runner = app.scene_runner
	var mission_ids: Dictionary = runner.data.get("chapter_builtin", {}).duplicate()
	for id: String in runner.missions:
		mission_ids[id] = true
	var total := mission_ids.size()
	var done := 0
	for id: String in mission_ids:
		done += int(runner.mission_done(app, id))

	# Salma hands over page one before Idris translates it.
	if app.chapter.has("page"):
		total += 1
		done += int(app.open_purse.salma_asked or app.open_purse.page_read)

	var names: Array = app.names_of_allah.data.get("names", [])
	total += names.size()
	for record: Dictionary in names:
		done += int(record.id in app.names_of_allah.learned)

	var masjids := _loaded_masjids(app)
	total += masjids.size()
	for id: String in masjids:
		done += int(app.jisra_masjid.prayed_in.has(id))

	for goal: Dictionary in runner.data.get("goals", []):
		var target := int(goal.m)
		var progress := clampi(runner._goal_count(app, str(goal.id)), 0, target)
		total += TENTHS_PER_GOAL
		if target > 0:
			done += floori(float(TENTHS_PER_GOAL * progress) / target)

	return floori(100.0 * done / total) if total > 0 else 0


func _loaded_masjids(app) -> Dictionary:
	var runner = app.scene_runner
	var masjids: Dictionary = app.jisra_masjid.data.get("masjids", {}).duplicate()
	var separate: Variant = runner.data.get("masjids", {})
	if separate is Dictionary:
		masjids.merge(separate)
	elif separate is Array:
		for record: Dictionary in separate:
			masjids[str(record.id)] = true
	for town: Dictionary in runner.towns.values():
		for record: Variant in town.get("masjids", []):
			if record is Dictionary:
				masjids[str(record.id)] = true
	return masjids


func update_gate_unlocks(app) -> int:
	var percent := journey_percent(app)
	for gate: Dictionary in data.get("gates", []):
		if gate.has("opens_at") and percent >= int(gate.opens_at):
			_unlocked_gates[gate.id] = true
	return percent

func gate_is_open(app, gate: Dictionary) -> bool:
	if gate.has("opens_at"):
		return _unlocked_gates.has(gate.id)
	return app.scene_runner.has_flag(app, str(gate.opens))


func state() -> Dictionary:
	return _unlocked_gates.duplicate()


func restore(saved: Dictionary) -> void:
	_unlocked_gates.clear()
	for gate: Dictionary in data.get("gates", []):
		if gate.has("opens_at") and saved.get(gate.id, false) == true:
			_unlocked_gates[gate.id] = true


func road_to(town: String) -> Dictionary:
	for road: Dictionary in data.roads:
		if road.town == town:
			return road
	return {}


func roads_for_gate(gate_id: String) -> Array[Dictionary]:
	var roads: Array[Dictionary] = []
	for road: Dictionary in data.roads:
		if road.gate == gate_id:
			roads.append(road)
	return roads


func town_is_open(app, road: Dictionary) -> bool:
	if road.is_empty() or not app.scene_runner.towns.has(road.town):
		return false
	var flag := str(road.get("opens", ""))
	if not flag.is_empty() and not app.scene_runner.has_flag(app, flag):
		return false
	for gate: Dictionary in data.gates:
		if gate.id == road.gate:
			return gate_is_open(app, gate)
	return false


func _inside_walk_minutes(app, origin: String, destination: String) -> int:
	if origin.is_empty() == destination.is_empty():
		return -1
	var district := destination if origin.is_empty() else origin
	var runner = app.scene_runner
	return int(runner.towns[district].walk) if runner.is_ilmara_district(district) else -1


func route_is_shut(app, origin: String, destination: String, minute: int) -> bool:
	return roads_are_shut(minute) and _inside_walk_minutes(app, origin, destination) < 0


func travel_minutes(app, origin: String, destination: String) -> int:
	if app.scene_runner.is_ilmara_district(origin) or app.scene_runner.is_ilmara_district(destination):
		return _inside_walk_minutes(app, origin, destination)
	var from := road_to(origin)
	var to := road_to(destination)
	if (not origin.is_empty() and from.is_empty()) or (not destination.is_empty() and to.is_empty()):
		return -1
	var from_minutes := int(from.get("minutes", 0))
	var to_minutes := int(to.get("minutes", 0))
	var minutes := absi(from_minutes - to_minutes) if from.get("gate") == to.get("gate") else from_minutes + to_minutes
	return adjust_travel_minutes(app, minutes)


func adjust_travel_minutes(app, minutes: int) -> int:
	var runner = app.scene_runner
	var numbers: Dictionary = runner.data.get("numbers", {})
	var factor := 1.0
	for animal: String in ["donkey", "camel", "horse"]:
		if runner.has_flag(app, "own_" + animal):
			factor = minf(factor, float(numbers.get(animal + "_factor", 1.0)))
	return roundi(minutes * factor)


func roads_are_shut(minute: int) -> bool:
	return minute >= int(data.numbers.gates_close) or minute < int(data.numbers.gates_open)


func night_message() -> String:
	return str(data.words.night).format({
		"a": _format_time(int(data.numbers.gates_close)),
		"b": _format_time(int(data.numbers.gates_open)),
	})


func _format_time(minutes: int) -> String:
	return "%02d:%02d" % [floori(float(minutes) / MINUTES_PER_HOUR), minutes % MINUTES_PER_HOUR]
