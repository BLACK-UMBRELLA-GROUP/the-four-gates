extends RefCounted
## DOC-TFG-0111: ordered LOCK content, scene effects and independent town state.

const SealedPurse = preload("res://game/sealed_purse.gd")
const CONTENT_INDEX := "res://data/content_index.json"
const RIVER_MARKET := "river_market"
const JISRA := "jisra"

var data: Dictionary
var missions: Dictionary
var towns: Dictionary
var people: Dictionary
var _flags: Dictionary = {}
var _done: Dictionary = {}
var _counters: Dictionary = {}
var _trust: Dictionary = {}
var _work_days: Dictionary = {}
var _sayings: Dictionary = {}


func _init(content: Dictionary) -> void:
	data = content
	missions = data.get("missions", {})
	towns = data.get("towns", {})
	people = data.get("people", {})


static func load_content(index_path: String = CONTENT_INDEX) -> Dictionary:
	var files: Array = _read_document(index_path).get("files", [])
	var content := {"missions": {}, "towns": {}, "people": {}, "chapters": []}
	var chapters_by_number := {}
	for file: String in files:
		var document := _read_document(index_path.get_base_dir().path_join(file))
		for key: String in document:
			match key:
				"chapters":
					for chapter: Dictionary in document.chapters:
						chapters_by_number[int(chapter.n)] = chapter
				"missions", "towns", "people":
					_merge_records(content[key], document[key])
				_:
					var earlier: Variant = content.get(key)
					var later: Variant = document[key]
					if earlier is Dictionary and later is Dictionary:
						_merge_fields(earlier, later)
					else:
						content[key] = later
	var numbers: Array = chapters_by_number.keys()
	numbers.sort()
	for number: int in numbers:
		content.chapters.append(chapters_by_number[number])
	return content


static func _read_document(path: String) -> Dictionary:
	var source := FileAccess.open(path, FileAccess.READ)
	if source == null:
		push_error("Could not open indexed scene content: " + path)
		return {}
	var parser := JSON.new()
	if parser.parse(source.get_as_text()) != OK or not parser.data is Dictionary:
		push_error("Invalid indexed scene content: " + path)
		return {}
	return parser.data


static func _merge_records(target: Dictionary, source: Variant) -> void:
	if source is Array:
		for record: Dictionary in source:
			target[str(record.id)] = record
	elif source is Dictionary:
		for id: String in source:
			var record: Dictionary = source[id]
			record["id"] = id
			target[id] = record


static func _merge_fields(target: Dictionary, source: Dictionary) -> void:
	for key: String in source:
		if target.get(key) is Dictionary and source[key] is Dictionary:
			_merge_fields(target[key], source[key])
		else:
			target[key] = source[key]


func state() -> Dictionary:
	return {
		"flags": _flags, "done": _done, "counters": _counters,
		"trust": _trust, "work_days": _work_days, "sayings": _sayings,
	}.duplicate(true)


func restore(saved: Dictionary) -> void:
	var source := saved.duplicate(true)
	_flags = source.get("flags", {})
	_done = source.get("done", {})
	_counters = source.get("counters", {})
	_trust = source.get("trust", {})
	_work_days = source.get("work_days", {})
	_sayings = source.get("sayings", {})


func reset() -> void:
	restore({})


func observe_builtin_flags(app) -> void:
	if app.progress.gate_open and not _flags.has("gate_opened"):
		_flags["gate_opened"] = app.day
	var toll: String = app.gate_of_trust.toll_choice
	if not toll.is_empty() and not _flags.has("toll:" + toll):
		_flags["toll:" + toll] = app.day


func has_flag(app, id: String) -> bool:
	if id == "gate_opened":
		return app.progress.gate_open
	if id.begins_with("toll:"):
		return id == "toll:" + app.gate_of_trust.toll_choice and not app.gate_of_trust.toll_choice.is_empty()
	return _flags.has(id)


func mission_done(app, id: String) -> bool:
	match id:
		"purse": return app.open_purse.done
		"grab": return not app.bread_grab.answer_id.is_empty()
		"sealed_purse":
			return app.sealed_purse.state in [SealedPurse.State.DELIVERED_WHOLE, SealedPurse.State.DELIVERED_SHORT]
		"gate_opens": return app.progress.gate_open
	return missions.has(id) and _done.has(id)


func available_missions(app, town: String, place: String) -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	var here := _town_id(town)
	if here != RIVER_MARKET and not towns.has(here):
		return available
	for mission: Dictionary in missions.values():
		var location := _town_id(str(mission.get("town", "")))
		if location != here or (here == RIVER_MARKET and mission.get("place", "") != place):
			continue
		if _mission_available(app, mission, here):
			available.append(mission)
	return available


func _mission_available(app, mission: Dictionary, town: String) -> bool:
	var id: String = mission.id
	if _done.has(id) and (mission.get("repeat") != "daily" or int(_done[id]) >= app.day):
		return false
	if not _within_hours(int(app.minute_of_day), mission.get("hours", [])):
		return false
	if town_trust(app, town) < int(mission.get("min_trust", 0)):
		return false
	if not _flags_match(app, mission.get("after", []), true) or not _flags_match(app, mission.get("not", []), false):
		return false
	var after_days: Dictionary = mission.get("after_days", {})
	for flag: String in after_days:
		if not has_flag(app, flag) or app.day - int(_flags.get(flag, app.day)) < int(after_days[flag]):
			return false
	return true


func choices(app, mission: Dictionary, scene: Dictionary) -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for choice: Dictionary in scene.get("choices", []):
		if choice_available(app, mission, choice):
			visible.append(choice)
	return visible


func choice_available(app, mission: Dictionary, choice: Dictionary) -> bool:
	return (app.progress.coins >= int(choice.get("need_coins", 0))
		and town_trust(app, str(mission.get("town", ""))) >= int(choice.get("min_trust", 0))
		and _flags_match(app, choice.get("if", []), true)
		and _flags_match(app, choice.get("unless", []), false))


func apply_choice(app, mission: Dictionary, choice: Dictionary) -> String:
	if not choice_available(app, mission, choice):
		return ""
	var effects: Variant = choice.get("fx", {})
	if effects is Dictionary:
		_apply_effects(app, mission, effects)
	elif effects is Array:
		for effect: Dictionary in effects:
			_apply_effects(app, mission, effect)
	return str(choice.get("go", ""))


func leave_scene(app, mission: Dictionary, scene: Dictionary) -> void:
	if scene.get("end", false):
		_done[mission.id] = app.day


func _apply_effects(app, mission: Dictionary, effects: Dictionary) -> void:
	var town := str(mission.get("town", ""))
	if effects.has("coins"):
		app.progress.coins = maxi(0, app.progress.coins + int(effects.coins))
	if effects.has("trust"):
		_add_trust(app, town, int(effects.trust))
	if effects.has("trust_rm"):
		_add_trust(app, RIVER_MARKET, int(effects.trust_rm))
	for flag: String in _flag_list(effects.get("flag", [])):
		if not flag.begins_with("toll:") and flag != "gate_opened" and not _flags.has(flag):
			_flags[flag] = app.day
	for flag: String in _flag_list(effects.get("unflag", [])):
		if not flag.begins_with("toll:") and flag != "gate_opened":
			_flags.erase(flag)
	if effects.has("say"):
		_add_saying(town, mission, effects.say)
	if effects.has("count"):
		_apply_count(app, effects.count)
	if effects.has("minutes"):
		app.clock.advance_to(app.day, app.minute_of_day + int(effects.minutes))
	if effects.get("done", false):
		_done[mission.id] = app.day


func _flag_list(value: Variant) -> Array:
	if value is String and not value.is_empty():
		return [value]
	return value if value is Array else []


func _flags_match(app, value: Variant, required: bool) -> bool:
	for flag: String in _flag_list(value):
		if has_flag(app, flag) != required:
			return false
	return true


func _apply_count(app, value: Variant) -> void:
	if value is Dictionary:
		for id: String in value:
			_add_count(app, id, int(value[id]))
	elif value is Array and value.size() == 2:
		_add_count(app, str(value[0]), int(value[1]))
	elif value is String:
		_add_count(app, value, 1)


func _add_count(app, id: String, amount: int) -> void:
	match id:
		"meals": app.feeding.meal_counter.total = maxi(0, app.feeding.meal_counter.total + amount)
		"qurans": app.qurans_school.qurans_given = maxi(0, app.qurans_school.qurans_given + amount)
		"children": app.qurans_school.children_in_school = maxi(0, app.qurans_school.children_in_school + amount)
		_: _counters[id] = maxi(0, int(_counters.get(id, 0)) + amount)


func _goal_count(app, id: String) -> int:
	match id:
		"meals": return app.feeding.meal_counter.total
		"qurans": return app.qurans_school.qurans_given
		"children": return app.qurans_school.children_in_school
		"masjids": return app.jisra_masjid.prayed_in.size()
		"names": return app.names_of_allah.learned.size()
	return int(_counters.get(id, 0))


func _town_id(town: String) -> String:
	return RIVER_MARKET if town.is_empty() else town


func town_trust(app, town: String) -> int:
	match _town_id(town):
		RIVER_MARKET: return app.progress.trust
		JISRA: return app.gate_of_trust.jisra_trust
	var town_data: Dictionary = towns.get(town, {})
	return int(_trust.get(town, town_data.get("start_trust", 0)))


func _add_trust(app, town: String, amount: int) -> void:
	var id := _town_id(town)
	if id == RIVER_MARKET:
		app.progress.apply_trust(amount)
		return
	var limits: Dictionary = app.progress.data.numbers
	var trust := clampi(town_trust(app, id) + amount, int(limits.trust_min), int(limits.trust_max))
	if id == JISRA:
		app.gate_of_trust.jisra_trust = trust
	else:
		_trust[id] = trust


func _within_hours(minute: int, hours: Array) -> bool:
	if hours.is_empty():
		return true
	var opens := int(hours[0])
	var closes := int(hours[1])
	if opens > closes:
		return minute >= opens or minute < closes
	return minute >= opens and minute < closes


func town_people(_app, town: String) -> Array[Dictionary]:
	var residents: Array[Dictionary] = []
	for person: Dictionary in people.values():
		if person.get("town", "") == town:
			residents.append(person)
	return residents


func person_available(app, person: Dictionary) -> bool:
	var friday: Dictionary = app.market_day.data.friday
	return (_within_hours(int(app.minute_of_day), person.get("hours", []))
		and (not person.get("prays", false) or not app.clock.is_friday_prayer_window(int(friday.closed_until_minutes_after_iqamah))))


func person_lines(app, town: String, person: Dictionary) -> Array[String]:
	var trust := town_trust(app, town)
	var band: String = data.bands[2]
	if trust < int(data.numbers.wary_below):
		band = data.bands[0]
	elif trust < int(data.numbers.warm_from):
		band = data.bands[1]
	var lines: Array[String] = []
	_append_paragraphs(lines, person.get("lines", {}).get(band, []))
	for memory: Dictionary in person.get("memory", []):
		if has_flag(app, str(memory.flag)):
			_append_paragraphs(lines, memory.text)
			break
	return lines


func _append_paragraphs(target: Array[String], value: Variant) -> void:
	if value is String:
		target.append(value)
	elif value is Array:
		for paragraph: String in value:
			target.append(paragraph)


func can_work(app, town: String) -> bool:
	var job := _town_work(town)
	return not job.is_empty() and _within_hours(int(app.minute_of_day), job.get("hours", []))


func _town_work(town: String) -> Dictionary:
	var town_data: Dictionary = towns.get(town, {})
	return town_data.get("work", {})


func work(app, town: String) -> String:
	var job := _town_work(town)
	if job.is_empty():
		return ""
	if not can_work(app, town):
		return str(data.words.work_closed).format({"name": job.get("name", towns[town].name)})
	var started: int = app.day
	if int(_work_days.get(town, 0)) != started:
		_add_trust(app, town, int(job.trust))
		_work_days[town] = started
	app.progress.coins += int(job.coins)
	app.clock.advance_to(started, app.minute_of_day + int(job.minutes))
	return str(data.words.work_done).format({"n": int(job.minutes), "c": int(job.coins)})


func inn_cost(town: String) -> int:
	var town_data: Dictionary = towns.get(town, {})
	return int(town_data.get("inn", -1))


func rest(app, town: String) -> String:
	var cost := inn_cost(town)
	if cost < 0:
		return ""
	var message: String = data.words.inn_poor
	if app.progress.coins >= cost:
		app.progress.coins -= cost
		message = str(data.words.inn_done).format({"n": cost})
	app.clock.advance_to(app.day + 1, int(data.numbers.wake), false)
	return message


func town_sayings(town: String) -> Array:
	var id := _town_id(town)
	var lines: Array = data.get("town_says", {}).get(id, []).duplicate(true)
	for line: Variant in _sayings.get(id, []):
		if line not in lines:
			lines.append(line)
	return lines


func _add_saying(town: String, mission: Dictionary, value: Variant) -> void:
	var authored: Variant = mission.get("say", {})
	var line: Variant = value
	if authored is Dictionary and authored.has(value):
		line = authored[value]
	elif authored is Array and (value is int or value is float):
		var index := int(value)
		if index >= 0 and index < authored.size():
			line = authored[index]
	if not line is String and not line is Array:
		return
	var id := _town_id(town)
	if not _sayings.has(id):
		_sayings[id] = []
	if line not in _sayings[id]:
		_sayings[id].append(line)


func journal(app) -> Dictionary:
	var chapters: Array[Dictionary] = []
	var titles: Dictionary = data.get("chapter_builtin", {})
	for chapter: Dictionary in data.get("chapters", []):
		var rows: Array[Dictionary] = []
		var completed := 0
		for id: String in chapter.missions:
			var mission: Dictionary = missions.get(id, {})
			var done := mission_done(app, id) and (titles.has(id) or not mission.is_empty())
			var title := str(titles.get(id, mission.get("title", ""))) if done else ""
			rows.append({"title": title, "done": done})
			completed += int(done)
		chapters.append({"n": int(chapter.n), "name": chapter.name, "rows": rows,
			"done": completed, "total": rows.size()})
	var side := {"done": 0, "total": 0}
	for mission: Dictionary in missions.values():
		if mission.get("side", false):
			side.total += 1
			side.done += int(mission_done(app, str(mission.id)))
	var goals: Array[Dictionary] = []
	for goal: Dictionary in data.get("goals", []):
		goals.append({"label": goal.label, "n": _goal_count(app, str(goal.id)), "m": int(goal.m)})
	return {"chapters": chapters, "side": side, "goals": goals}
