extends RefCounted
## Locked JSON content and the line-5 layout overlay.

static func load_data() -> Dictionary:
	var file := FileAccess.open("res://data/foundations.json", FileAccess.READ)
	assert(file != null, "Approved foundations data is required")
	var parsed = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary, "Approved foundations data must be an object")
	var identity := load_identity()
	for id: String in identity.layout_additions:
		var place: Dictionary = identity.layout_additions[id]
		parsed.places[id] = place.duplicate(true)
		parsed.street_points[id] = {"x": place.x, "z": place.z}
		parsed.streets.append([place.street, id])
	return parsed

static func load_identity() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/identity.json"))
	assert(parsed is Dictionary, "Approved identity data must be an object")
	return parsed

static func load_chapter1() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/chapter1.json"))
	assert(parsed is Dictionary, "Approved chapter 1 data must be an object")
	return parsed

static func load_market_stall() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/market_stall.json"))
	assert(parsed is Dictionary, "Approved market stall data must be an object")
	return parsed

static func load_talking() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/talking.json"))
	assert(parsed is Dictionary, "Approved talking data must be an object")
	return parsed

static func load_market_day() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/market_day.json"))
	assert(parsed is Dictionary, "Approved market day data must be an object")
	return parsed

static func load_prayer_record() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/prayer_record.json"))
	assert(parsed is Dictionary, "Approved prayer record data must be an object")
	return parsed

static func load_calendar() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/calendar.json"))
	assert(parsed is Dictionary, "Approved calendar data must be an object")
	return parsed

static func load_ramadan() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/ramadan.json"))
	assert(parsed is Dictionary, "Approved Ramadan data must be an object")
	return parsed

static func load_eid_al_fitr() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/eid_al_fitr.json"))
	assert(parsed is Dictionary, "Approved Eid al-Fitr data must be an object")
	return parsed

static func load_eid_al_adha() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/eid_al_adha.json"))
	assert(parsed is Dictionary, "Approved Eid al-Adha data must be an object")
	return parsed

static func load_zakat() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/zakat.json"))
	assert(parsed is Dictionary, "Approved Zakat data must be an object")
	return parsed


static func load_pilgrims() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/pilgrims.json"))
	assert(parsed is Dictionary, "Approved pilgrims data must be an object")
	return parsed


static func load_qurans_school() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/qurans_school.json"))
	assert(parsed is Dictionary, "Approved Qurans and school data must be an object")
	return parsed


static func format_count(number: int) -> String:
	var value := str(number)
	for index in range(value.length() - 3, 0, -3):
		value = value.insert(index, ",")
	return value


static func load_iftar_giving() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/iftar_giving.json"))
	assert(parsed is Dictionary, "Approved iftar giving data is required")
	return parsed


static func load_feeding() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/feeding.json"))
	assert(parsed is Dictionary, "Approved feeding data must be an object")
	return parsed

static func load_sealed_purse() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/sealed_purse.json"))
	assert(parsed is Dictionary, "Approved sealed purse data must be an object")
	return parsed

static func load_dice_house() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/dice_house.json"))
	assert(parsed is Dictionary, "Approved dice house data must be an object")
	return parsed

static func load_qasims_jars() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/qasims_jars.json"))
	assert(parsed is Dictionary, "Approved Qasim's jars data must be an object")
	return parsed

static func load_jabirs_goats() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/jabirs_goats.json"))
	assert(parsed is Dictionary, "Approved Jabir's goats data must be an object")
	return parsed

static func load_idris_recovery() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/idris_has_heard.json"))
	assert(parsed is Dictionary, "Approved Idris recovery data must be an object")
	return parsed

static func load_dry_fountain() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/dry_fountain.json"))
	assert(parsed is Dictionary, "Approved dry fountain data must be an object")
	return parsed

static func load_rashids_loan() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/rashids_loan.json"))
	assert(parsed is Dictionary, "Approved Rashid's loan data must be an object")
	return parsed

static func load_harm_in_the_road() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/harm_in_the_road.json"))
	assert(parsed is Dictionary, "Approved harm in the road data must be an object")
	return parsed

static func load_clothes() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/clothes.json"))
	assert(parsed is Dictionary, "Approved clothes data must be an object")
	return parsed

static func configure_input(data: Dictionary) -> void:
	# The project declares the actions; the locked key names supply their events.
	var movement: PackedStringArray = str(data.keys.move).split(" ", false)
	assert(movement.size() == 4, "Approved movement binding needs four keys")
	var bindings: Dictionary = {
		"move_forward": movement[0], "move_left": movement[1],
		"move_back": movement[2], "move_right": movement[3],
	}
	for action in ["run", "use", "market_map", "goal", "wait_prayer", "pray", "close"]:
		bindings[action] = data.keys[action]
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		var event := InputEventKey.new()
		event.physical_keycode = KEY_ESCAPE if bindings[action] == "Esc" else OS.find_keycode_from_string(bindings[action])
		assert(event.physical_keycode != KEY_NONE, "Approved key name must resolve")
		InputMap.action_add_event(action, event)
