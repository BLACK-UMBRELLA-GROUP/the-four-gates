extends RefCounted
## Single runtime content loader. The approved bytes remain unchanged.

static func load_data() -> Dictionary:
	var file := FileAccess.open("res://data/foundations.json", FileAccess.READ)
	assert(file != null, "Approved foundations data is required")
	var parsed = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary, "Approved foundations data must be an object")
	return parsed

static func configure_input(data: Dictionary) -> void:
	# The project declares the actions; the locked key names supply their events.
	var movement: PackedStringArray = str(data.keys.move).split(" ", false)
	assert(movement.size() == 4, "Approved movement binding needs four keys")
	var bindings: Dictionary = {
		"move_forward": movement[0], "move_left": movement[1],
		"move_back": movement[2], "move_right": movement[3],
	}
	for action in ["run", "use", "market_map", "goal", "wait_day_night", "close"]:
		bindings[action] = data.keys[action]
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		var event := InputEventKey.new()
		event.physical_keycode = KEY_ESCAPE if bindings[action] == "Esc" else OS.find_keycode_from_string(bindings[action])
		assert(event.physical_keycode != KEY_NONE, "Approved key name must resolve")
		InputMap.action_add_event(action, event)
