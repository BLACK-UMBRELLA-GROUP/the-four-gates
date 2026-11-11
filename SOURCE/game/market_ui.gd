extends CanvasLayer
## Interface from approved masters. Only placement, colour and drawing measurements
## live here; all displayed content is read from the approved data dictionary.

signal begin_requested
signal arrival_choice_requested(index: int)
signal arrival_continue_requested
signal arrival_walk_requested
signal screen_requested(screen: String)
signal wait_requested
signal pray_requested
signal make_up_requested
signal record_requested
signal record_closed
signal use_requested
signal goal_requested
signal destination_requested(place_id: String)
signal task_requested(task_id: String)
signal choice_requested(task_id: String, choice: String)
signal amend_requested(task_id: String)
signal daily_job_requested
signal weight_requested(index: int)
signal answer_requested

const MapCanvas = preload("res://game/map_canvas.gd")
const LessonCanvas = preload("res://game/lesson_canvas.gd")
const PAPER := Color("f5e8cd")
const GOLD := Color("f8ae36")
const INK := Color("30200e")
var data: Dictionary = {}
var identity: Dictionary = {}
var screen := "title"
var player_position := Vector3.ZERO
var place_id := ""
var night := false
var root: Control
var map: Control
var content: Control
var toast_panel: Panel
var toast_label: Label
var _toast_seconds := 0.0
var _following_toast := ""
var font := SystemFont.new()
var bold_font := SystemFont.new()
var title_font := SystemFont.new()
var progress: RefCounted
var clock: RefCounted
var clock_panel: Panel
var _clock_time: Label
var _clock_prayer: Label
var _clock_hit: Button
var _record_kicker: Label
var _record_names: Array[Label] = []
var _record_values: Array[Label] = []
var _clock_day := -1
var _clock_minute := -1
var _prayer_label := ""
var _make_up_label := ""
var _masjid_line := ""
var task_id := ""
var result: Dictionary = {}
var arrival_beat := 0
var arrival_reply := ""
var arrival_fair := false
var _last_coins := -1
var _last_trust := -1
var _last_daily_count := -1
var _last_lesson := false
var _last_gate := false

func setup(source: Dictionary, progress_value: RefCounted, identity_value: Dictionary, clock_value: RefCounted) -> void:
	data = source
	identity = identity_value
	progress = progress_value
	clock = clock_value
	font.font_names = PackedStringArray(["Arial", "Helvetica", "sans-serif"])
	bold_font.font_names = font.font_names
	bold_font.font_weight = 700
	title_font.font_names = PackedStringArray(["Times New Roman", "Times", "serif"])
	title_font.font_weight = 700
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	map = MapCanvas.new()
	map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map.configure(data, identity)
	map.destination_requested.connect(func(id: String): destination_requested.emit(id))
	map.city_gate_requested.connect(func(index: int): show_city_gate(index))
	map.city_part_requested.connect(func(part: String): show_toast(identity.city.parts[part].name + ": " + identity.city.parts[part].line))
	map.town_requested.connect(func(index: int): show_toast(identity.world.town_toast.format({"town": identity.world.towns_placeholder[index].name})))
	map.city_requested.connect(func(): screen_requested.emit("city_map"))
	map.market_requested.connect(func(): screen_requested.emit("market_map"))
	root.add_child(map)
	content = Control.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(content)
	toast_panel = Panel.new()
	toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_panel.add_theme_stylebox_override("panel", _style(Color("191812"), Color("a87a30")))
	toast_panel.position = Vector2(460, 844)
	toast_panel.size = Vector2(1000, 68)
	root.add_child(toast_panel)
	toast_label = _label(toast_panel, "", Vector2(20, 10), Vector2(960, 48), 25, PAPER)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_panel.hide()
	show_screen(screen)

func show_screen(value: String) -> void:
	screen = value
	if not is_instance_valid(content):
		return
	# A message belongs to its current view; it must not obscure another panel.
	if is_instance_valid(toast_panel):
		toast_panel.hide()
		_toast_seconds = 0.0
		_following_toast = ""
	_rebuild_screen()

func _rebuild_screen() -> void:
	clock_panel = null
	_clock_hit = null
	_record_names.clear()
	_record_values.clear()
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	map.visible = screen in ["market_map", "city_map", "world_map"]
	map.mode = screen
	map.night = night
	map.player_position = player_position
	map.selected_place = place_id
	map.gate_open = progress.gate_open
	map.queue_redraw()
	match screen:
		"title":
			_build_title()
		"arrival":
			_build_hud()
			_build_arrival()
		"game", "market_map":
			_build_hud()
			var place_x := 491.0 if screen == "market_map" else 203.0
			_build_place_bar(_build_prayer_buttons(place_x))
			if screen == "market_map":
				_button(data.ui.buttons.city_map, Vector2(42, 974), Vector2(138, 55), func(): screen_requested.emit("city_map"))
				_button(data.ui.buttons.wait_prayer, Vector2(203, 974), Vector2(265, 55), func(): wait_requested.emit())
			else:
				_button(data.ui.buttons.map, Vector2(42, 974), Vector2(138, 55), func(): screen_requested.emit("market_map"))
		"city_map":
			_button(identity.ui.world_map, Vector2(42, 983), Vector2(158, 55), func(): screen_requested.emit("world_map"))
			_button(identity.ui.river_market, Vector2(223, 983), Vector2(176, 55), func(): screen_requested.emit("market_map"))
			_button(identity.ui.goal, Vector2(422, 983), Vector2(93, 55), func(): goal_requested.emit())
		"world_map":
			_button(identity.ui.title_back, Vector2(42, 983), Vector2(105, 55), func(): screen_requested.emit("title"))
			_button(identity.ui.city_map, Vector2(170, 983), Vector2(138, 55), func(): screen_requested.emit("city_map"))
			_button(identity.ui.river_market, Vector2(331, 983), Vector2(176, 55), func(): screen_requested.emit("market_map"))
		"prayer_record":
			_build_hud()
			_build_prayer_record()
		"board":
			_build_hud()
			_build_board()
		"task":
			_build_hud()
			_build_task()
		"result":
			_build_hud()
			_build_result()
		"lesson":
			_build_hud()
			_build_lesson()
		"goal":
			_build_hud()
			_build_goal()
	_last_coins = progress.coins
	_last_trust = progress.trust
	_last_daily_count = progress.daily_count
	_last_lesson = progress.lesson_done
	_last_gate = progress.gate_open

func refresh(position_value: Vector3, place_value: String, night_value: bool) -> void:
	player_position = position_value
	var place_changed := place_id != place_value
	var clock_changed: bool = _clock_day != clock.day or _clock_minute != clock.minute_of_day
	var rebuild: bool = place_changed or _last_coins != progress.coins or _last_trust != progress.trust or _last_daily_count != progress.daily_count or _last_lesson != progress.lesson_done or _last_gate != progress.gate_open
	place_id = place_value
	night = night_value
	if clock_changed or place_changed:
		_clock_day = clock.day
		_clock_minute = clock.minute_of_day
		var at_masjid := place_id == "masjid"
		var prayer: String = clock.prayer_label(at_masjid)
		var make_up: String = clock.make_up_label()
		var masjid_line: String = clock.masjid_line() if at_masjid else ""
		if screen in ["game", "market_map"]:
			rebuild = rebuild or prayer != _prayer_label or make_up != _make_up_label or masjid_line != _masjid_line
		_prayer_label = prayer
		_make_up_label = make_up
		_masjid_line = masjid_line
	if not is_instance_valid(root):
		return
	map.player_position = player_position
	map.selected_place = place_id
	map.night = night
	if map.visible:
		map.queue_redraw()
	if rebuild and screen != "title":
		_rebuild_screen()
	elif clock_changed:
		_update_clock_hud()
		if screen == "prayer_record":
			_update_prayer_record()

func show_toast(value: String, compact: bool = false, follow_with: String = "") -> void:
	if not is_instance_valid(toast_label):
		return
	var use_compact := compact or screen in ["city_map", "world_map"]
	toast_label.clip_text = use_compact
	toast_label.text = value
	if use_compact:
		var width := minf(1800, font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 44)
		toast_panel.position = Vector2((1920 - width) / 2.0, 900)
		toast_panel.size = Vector2(width, 48)
		toast_label.position = Vector2(20, 0)
		toast_label.add_theme_font_size_override("font_size", 20)
		toast_label.size = Vector2(width - 40, 48)
	else:
		toast_panel.position = Vector2(460, 844)
		toast_panel.size = Vector2(1000, 68)
		toast_label.position = Vector2(20, 10)
		toast_label.add_theme_font_size_override("font_size", 25)
		toast_label.size = Vector2(960, 48)
	_toast_seconds = 3.5
	_following_toast = follow_with
	toast_panel.show()

func _process(delta: float) -> void:
	if _toast_seconds > 0:
		_toast_seconds -= delta
		if _toast_seconds <= 0:
			if _following_toast.is_empty():
				toast_panel.hide()
			else:
				show_toast(_following_toast, screen == "market_map")

func _build_title() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.24)
	shade.size = Vector2(1920, 1080)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(shade)
	# The title master's wide letter spacing is part of its placement.
	var title_value: String = data.title_screen.title
	var title_width := 0.0
	for glyph in title_value:
		title_width += title_font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, 112).x + 14
	var title_x: float = (1920 - title_width + 14) / 2.0
	for glyph in title_value:
		var glyph_width := title_font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, 112).x
		var letter := _label(content, glyph, Vector2(title_x, 360), Vector2(glyph_width + 2, 150), 112, Color("ffda87"), true)
		letter.add_theme_font_override("font", title_font)
		title_x += glyph_width + 14
	var city_name := _label(content, str(identity.city.name), Vector2(380, 534), Vector2(1160, 52), 28, PAPER)
	city_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var subtitle := _label(content, str(data.title_screen.line), Vector2(380, 594), Vector2(1160, 52), 28, PAPER)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(data.ui.buttons.begin, Vector2(830, 680), Vector2(107, 56), func(): begin_requested.emit(), true)
	_button(data.ui.buttons.settings, Vector2(960, 680), Vector2(130, 56), func(): show_toast(data.title_screen.settings_toast))

func _build_arrival() -> void:
	var arrival: Dictionary = identity.arrival
	var done: bool = arrival_beat == arrival.beats.size()
	var beat: Dictionary = {} if done else arrival.beats[arrival_beat]
	var line: String = (arrival.end_fair if arrival_fair else arrival.end_cheated) if done else beat.text
	var line_width := 1120.0
	var line_height := font.get_multiline_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, line_width, 23).y
	var reply_height := 0.0
	if not arrival_reply.is_empty():
		reply_height = bold_font.get_multiline_string_size(arrival_reply, HORIZONTAL_ALIGNMENT_LEFT, line_width, 23).y
	var buttons_height: float = 56.0 if done or not arrival_reply.is_empty() else 70.0 * beat.choices.size() - 14.0
	var extra_height := 44.0 if done else (reply_height + 16.0 if reply_height > 0.0 else 0.0)
	var height := 138.0 + line_height + extra_height + buttons_height
	var origin := Vector2(366, 583 - height / 2.0)
	var panel := _panel(origin, Vector2(1188, height), Color("1b130be8"))
	_heading(panel, arrival.kicker, arrival.title_done if done else arrival.title_running)
	var body := _label(panel, "", Vector2(34, 111), Vector2(line_width, line_height), 23, PAPER)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.text = line
	var y := 125.0 + line_height
	if done:
		var coins: String = str(arrival.coins_line).format({"n": progress.coins})
		_label(panel, coins.to_upper(), Vector2(34, y), Vector2(line_width, 28), 16, Color("e9bd70"))
		y += 38.0
		var x := origin.x + 34.0
		x += _arrival_button(arrival.buttons[0], Vector2(x, origin.y + y), func(): show_toast(data.ui.not_built), true) + 12.0
		x += _arrival_button(arrival.buttons[1], Vector2(x, origin.y + y), func(): arrival_walk_requested.emit()) + 12.0
		_arrival_button(arrival.buttons[2], Vector2(x, origin.y + y), func(): begin_requested.emit())
	elif not arrival_reply.is_empty():
		var reply := _label(panel, "", Vector2(34, y), Vector2(line_width, reply_height), 23, PAPER, true)
		reply.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		reply.text = arrival_reply
		_arrival_button(arrival.continue, origin + Vector2(34, y + reply_height + 16.0), func(): arrival_continue_requested.emit(), true)
	else:
		for index in range(beat.choices.size()):
			var choose := _button(beat.choices[index].label, origin + Vector2(34, y), Vector2(line_width, 56), func(): arrival_choice_requested.emit(index))
			choose.alignment = HORIZONTAL_ALIGNMENT_LEFT
			for state in ["normal", "hover", "pressed"]:
				choose.get_theme_stylebox(state).content_margin_left = 22.0
			y += 70.0

func _arrival_button(value: String, at: Vector2, callback: Callable, primary: bool = false) -> float:
	var face := bold_font if primary else font
	var width := face.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 44.0
	_button(value, at, Vector2(width, 56), callback, primary)
	return width

func _build_hud() -> void:
	_build_clock_hud()
	var coin_text: String = str(data.ui.hud.coins).format({"n": progress.coins})
	var coin_width := bold_font.get_string_size(coin_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	var coins := _panel(Vector2(42, 42), Vector2(coin_width + 36, 53), Color("302411"))
	_label(coins, coin_text, Vector2(18, 7), Vector2(coin_width + 2, 38), 24, Color("ffd27e"), true)
	var trust := _panel(Vector2(1525, 42), Vector2(352, 70), Color("302411"))
	_label(trust, str(data.ui.hud.trust_label), Vector2(18, 7), Vector2(225, 37), 24, PAPER)
	var value: String = str(data.ui.hud.trust_value).format({"n": progress.trust})
	var amount := _label(trust, value, Vector2(241, 7), Vector2(93, 37), 24, PAPER)
	amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var track := ColorRect.new()
	track.position = Vector2(18, 50)
	track.size = Vector2(315, 10)
	track.color = Color("514737")
	trust.add_child(track)
	var fill := ColorRect.new()
	fill.size = Vector2(315 * float(progress.trust) / float(data.numbers.trust_max), 10)
	fill.color = GOLD
	track.add_child(fill)
	if screen == "arrival":
		return
	var hit := Button.new()
	hit.flat = true
	hit.position = Vector2.ZERO
	hit.size = trust.size
	hit.modulate = Color(1, 1, 1, 0)
	hit.pressed.connect(func(): goal_requested.emit())
	trust.add_child(hit)

func _build_clock_hud() -> void:
	clock_panel = _panel(Vector2.ZERO, Vector2(285, 84), Color("302411"))
	_clock_time = _label(clock_panel, "", Vector2(14, 8), Vector2(257, 34), 24, PAPER)
	_clock_prayer = _label(clock_panel, "", Vector2(14, 40), Vector2(257, 34), 24, Color("ffd27e"), true)
	_clock_time.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_clock_prayer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if screen not in ["arrival", "prayer_record"]:
		_clock_hit = Button.new()
		_clock_hit.flat = true
		_clock_hit.modulate = Color(1, 1, 1, 0)
		_clock_hit.pressed.connect(func(): record_requested.emit())
		clock_panel.add_child(_clock_hit)
	_update_clock_hud()

func _update_clock_hud() -> void:
	if not is_instance_valid(clock_panel):
		return
	var values: Dictionary = clock.hud(place_id == "masjid")
	_clock_time.text = values.time
	_clock_prayer.text = values.prayer
	var width := maxf(285, bold_font.get_string_size(values.prayer, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 42)
	clock_panel.position = Vector2(850 - width / 2, 42)
	clock_panel.size.x = width
	_clock_time.size.x = width - 28
	_clock_prayer.size.x = width - 28
	if is_instance_valid(_clock_hit):
		_clock_hit.size = clock_panel.size

func _build_prayer_record() -> void:
	var record_copy: Dictionary = identity.clock.record
	var panel := _panel(Vector2(365, 322), Vector2(1190, 524), Color("1b130bf2"))
	_record_kicker = _label(panel, "", Vector2(34, 23), Vector2(1122, 28), 16, Color("e9bd70"))
	var title := _label(panel, record_copy.title, Vector2(34, 53), Vector2(1122, 47), 36, Color("ffd27e"), true)
	title.add_theme_font_override("font", title_font)
	for index in range(identity.clock.prayers.size()):
		var y := 112.0 + index * 57.0
		var line := ColorRect.new()
		line.position = Vector2(34, y)
		line.size = Vector2(1122, 1)
		line.color = Color("88612555")
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(line)
		_record_names.append(_label(panel, "", Vector2(34, y + 1), Vector2(450, 56), 24, PAPER, true))
		var value := _label(panel, "", Vector2(484, y + 1), Vector2(672, 56), 24, Color("ffd27e"))
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_record_values.append(value)
	_label(panel, str(record_copy.note).to_upper(), Vector2(34, 397), Vector2(1122, 28), 16, Color("e9bd70"))
	_button(record_copy.back, Vector2(399, 762), Vector2(247, 56), func(): record_closed.emit(), true)
	_update_prayer_record()

func _update_prayer_record() -> void:
	var record_values: Dictionary = clock.record()
	_record_kicker.text = str(record_values.kicker).to_upper()
	for index in _record_names.size():
		var row: Dictionary = record_values.rows[index]
		_record_names[index].text = row.name
		_record_values[index].text = row.text
		var inactive: bool = row.status not in ["now", "later"]
		_record_names[index].modulate.a = 0.55 if inactive else 1.0
		_record_values[index].modulate.a = 0.55 if inactive else 1.0

func _task() -> Dictionary:
	for task: Dictionary in data.tasks:
		if task.id == task_id:
			return task
	return {}

func _heading(panel: Panel, kicker: String, title_value: String) -> void:
	_label(panel, kicker.to_upper(), Vector2(34, 23), Vector2(1120, 28), 16, Color("e9bd70"))
	var title := _label(panel, title_value, Vector2(34, 53), Vector2(1120, 48), 36, Color("ffd27e"), true)
	title.add_theme_font_override("font", title_font)

func _build_board() -> void:
	var amends: Array[Dictionary] = []
	for task: Dictionary in data.tasks:
		if progress.tasks.has(task.id) and progress.tasks[task.id].choice == "quick":
			amends.append(task)
	var height := 533.0 + 81.0 * amends.size()
	var top := (1080.0 - height) / 2.0 + 44.0
	var panel := _panel(Vector2(365, top), Vector2(1190, height), Color("241a0df2"))
	_heading(panel, data.ui.board.kicker, data.ui.board.title)
	var row_y := top + 113.0
	for task: Dictionary in data.tasks:
		var done: bool = progress.tasks.has(task.id)
		_board_row(panel, row_y - top, task.title, task.place, done)
		if done:
			var label: String = data.ui.board.done_honest if progress.tasks[task.id].choice == "honest" else data.ui.board.done_quick
			_board_status(panel, row_y - top, label)
		else:
			var label: String = str(data.ui.buttons.take_task).format({"n": int(task.pay_shown)})
			_board_button(label, row_y, func(): task_requested.emit(task.id))
		row_y += 81.0
	for task: Dictionary in amends:
		var amended: bool = progress.tasks[task.id].amended
		var line: String = str(data.ui.board.amend_line).format({"cost": int(task.amends.cost), "trust": progress.amend_reward(task.id)})
		_board_row(panel, row_y - top, task.amends.title, line, amended)
		if amended:
			_board_status(panel, row_y - top, data.ui.board.put_right_done)
		elif progress.coins < int(task.amends.cost):
			_board_status(panel, row_y - top, str(data.ui.board.need_coins).format({"n": int(task.amends.cost)}))
		else:
			_board_button(data.ui.buttons.put_right, row_y, func(): amend_requested.emit(task.id))
		row_y += 81.0
	var daily_done: bool = progress.daily_count >= int(data.daily_job.per_day)
	_board_row(panel, row_y - top, data.daily_job.title, str(data.ui.board.job_line).format({"n": int(data.daily_job.trust)}), daily_done)
	if daily_done:
		_board_status(panel, row_y - top, data.ui.board.job_done)
	else:
		_board_button(str(data.ui.buttons.do_job).format({"n": int(data.daily_job.coins)}), row_y, func(): daily_job_requested.emit())
	_button(data.ui.buttons.back_to_market_map, Vector2(399, row_y + 95), Vector2(307, 55), func(): screen_requested.emit("market_map"))

func _board_row(panel: Panel, y: float, title_value: String, line: String, done: bool) -> void:
	var divider := ColorRect.new()
	divider.position = Vector2(34, y)
	divider.size = Vector2(1122, 1)
	divider.color = Color("62461d70")
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(divider)
	_label(panel, title_value, Vector2(34, y + 10), Vector2(855, 36), 24, Color("998f7c") if done else PAPER, true)
	_label(panel, line.to_upper(), Vector2(34, y + 43), Vector2(855, 28), 16, Color("a78a53") if done else Color("e9bd70"))

func _board_status(panel: Panel, y: float, value: String) -> void:
	var label := _label(panel, value, Vector2(875, y + 20), Vector2(281, 42), 24, Color("b59350"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _board_button(value: String, y: float, callback: Callable) -> void:
	var width := bold_font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 46
	_button(value, Vector2(1521 - width, y + 13), Vector2(width, 56), callback, true)

func _build_task() -> void:
	var task := _task()
	if task.is_empty():
		return
	var panel := _panel(Vector2(365, 392), Vector2(1190, 382), Color("241a0df2"))
	_heading(panel, task.place, task.title)
	_label(panel, task.story, Vector2(34, 108), Vector2(1122, 40), 24, PAPER)
	_choice_button(task.honest.choice, 552, func(): choice_requested.emit(task_id, "honest"))
	_choice_button(task.quick.choice, 621, func(): choice_requested.emit(task_id, "quick"))
	_choice_button(data.ui.buttons.not_now, 691, func(): screen_requested.emit("board"))

func _choice_button(value: String, y: float, callback: Callable) -> void:
	var button := _button(value, Vector2(399, y), Vector2(1122, 56), callback)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	for state in ["normal", "hover", "pressed"]:
		button.get_theme_stylebox(state).content_margin_left = 22

func _build_result() -> void:
	if result.is_empty():
		return
	var panel := _panel(Vector2(365, 438), Vector2(1190, 290), Color("241a0df2"))
	_heading(panel, result.label, result.title)
	_label(panel, result.line, Vector2(34, 106), Vector2(1122, 48), 24, PAPER)
	var coins_text: String = str(data.ui.result.coins).format({"n": int(result.coins)})
	var coin_width := bold_font.get_string_size(coins_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	_label(panel, coins_text, Vector2(34, 155), Vector2(coin_width + 3, 40), 24, Color("a5d7a0"), true)
	_label(panel, " · ", Vector2(34 + coin_width, 155), Vector2(24, 40), 24, PAPER)
	var trust_text: String = str(data.ui.result.trust).format({"sign": "+" if result.trust >= 0 else "-", "n": absi(int(result.trust))})
	_label(panel, trust_text, Vector2(56 + coin_width, 155), Vector2(220, 40), 24, Color("ff998d") if result.trust < 0 else Color("a5d7a0"), true)
	_button(data.ui.buttons.back_to_board, Vector2(399, 646), Vector2(234, 56), func(): screen_requested.emit("board"), true)
	_button(data.ui.buttons.see_goal, Vector2(646, 646), Vector2(189, 56), func(): goal_requested.emit())

func _build_lesson() -> void:
	var tried: bool = progress.tried_weight >= 0
	var top := 254.0 if tried else 303.0
	var height := 658.0 if tried else 560.0
	var panel := _panel(Vector2(365, top), Vector2(1190, height), Color("241a0df2"))
	_heading(panel, str(data.ui.lesson.kicker).format({"topic": data.lesson.topic}), data.lesson.title)
	_label(panel, data.lesson.story, Vector2(34, 103), Vector2(1122, 48), 24, PAPER)
	var scale := LessonCanvas.new()
	scale.position = Vector2(718, top + 193)
	scale.size = Vector2(484, 210)
	scale.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scale.data = data
	scale.tried_weight = progress.tried_weight
	scale.font = font
	content.add_child(scale)
	var x := 399.0
	for index in range(data.lesson.options.size()):
		var text: String = data.lesson.options[index]
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 46
		_button(text, Vector2(x, top + 409), Vector2(width, 56), func(): weight_requested.emit(index))
		x += width + 14
	var back_y := top + 478
	if tried:
		var feedback: String = data.lesson.tip_text if progress.tried_weight == int(data.lesson.false_weight_index) else data.lesson.level_text
		_label(panel, feedback.format({"n": progress.tried_weight + 1}).to_upper(), Vector2(34, 467), Vector2(1122, 28), 16, Color("e9bd70"))
		var answer: String = str(data.lesson.answer_button).format({"n": progress.tried_weight + 1})
		var width := bold_font.get_string_size(answer, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 46
		_button(answer, Vector2(399, top + 506), Vector2(width, 56), func(): answer_requested.emit(), true)
		back_y = top + 576
	_button(data.ui.buttons.back_to_market_map, Vector2(399, back_y), Vector2(307, 56), func(): screen_requested.emit("market_map"))

func _build_goal() -> void:
	var panel := _panel(Vector2(365, 279), Vector2(1190, 608), Color("241a0df2"))
	_heading(panel, data.ui.goal.kicker, data.goal.title)
	for index in range(data.goal.gates.size()):
		var row_y := 113.0 + 81.0 * index
		var gate: Array = data.goal.gates[index]
		_board_row(panel, row_y, gate[0], gate[1], false)
		var amount: int = progress.trust if index == 0 else 0
		var track := ColorRect.new()
		track.position = Vector2(455, row_y + 39)
		track.size = Vector2(448, 10)
		track.color = Color("514737")
		track.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(track)
		var fill := ColorRect.new()
		fill.size = Vector2(track.size.x * float(amount) / float(data.numbers.trust_max), track.size.y)
		fill.color = GOLD
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		track.add_child(fill)
		var value: String = data.ui.goal.open if index == 0 and progress.gate_open else str(data.ui.goal.gate_trust_value).format({"n": amount})
		var label := _label(panel, value, Vector2(955, row_y + 20), Vector2(201, 42), 24, Color("ffd27e"))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var rule: String = data.gate.goal_line
	if progress.lesson_done:
		rule += str(data.ui.goal.rule_done_suffix)
	_label(panel, rule.to_upper(), Vector2(34, 436), Vector2(1122, 36), 16, Color("e9bd70"))
	_label(panel, data.goal.line, Vector2(34, 470), Vector2(1122, 45), 24, PAPER)
	_button(data.ui.buttons.back_to_market, Vector2(399, 804), Vector2(247, 56), func(): screen_requested.emit("game"), true)
	_button(data.ui.buttons.map, Vector2(659, 804), Vector2(91, 56), func(): screen_requested.emit("market_map"))

func _build_prayer_buttons(x: float) -> float:
	if not _prayer_label.is_empty() and place_id != "masjid":
		x += _arrival_button(_prayer_label, Vector2(x, 973), func(): pray_requested.emit(), true) + 22
	if not _make_up_label.is_empty():
		x += _arrival_button(_make_up_label, Vector2(x, 973), func(): make_up_requested.emit()) + 22
	return x

func _build_place_bar(x: float) -> void:
	if place_id.is_empty() or not data.places.has(place_id):
		var idle: String = data.ui.place_bar.idle
		var idle_width: float = font.get_string_size(idle, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
		var idle_panel := _panel(Vector2(x, 965), Vector2(idle_width + 36, 73), Color("191c19"))
		_label(idle_panel, idle, Vector2(18, 15), Vector2(idle_width + 4, 42), 24, PAPER)
		return
	var place: Dictionary = data.places[place_id]
	var name_value: String = place.name
	var place_line: String = _masjid_line if place_id == "masjid" and not _masjid_line.is_empty() else place.line
	var line_value: String = str(data.ui.place_bar.format).format({"name": "", "line": place_line})
	var action: String = data.ui.place_actions.get(place_id, data.ui.not_built)
	if place_id == "inn":
		action = identity.inn.action
	elif place_id == "scales" and progress.lesson_done:
		action = data.ui.place_actions.scales_after_lesson
	elif place_id == "masjid":
		action = identity.clock.masjid_actions.none_yet if _prayer_label.is_empty() else _prayer_label
	var name_width := bold_font.get_string_size(name_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	var line_width := font.get_string_size(line_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	var button_width := bold_font.get_string_size(action, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 46
	var total_width := name_width + line_width + button_width + 55
	var panel := _panel(Vector2(x, 965), Vector2(total_width, 73), Color("191c19"))
	_label(panel, name_value, Vector2(18, 15), Vector2(name_width + 4, 42), 24, PAPER, true)
	_label(panel, line_value, Vector2(18 + name_width, 15), Vector2(line_width + 4, 42), 24, PAPER)
	_button(action, Vector2(x + total_width - button_width - 17, 973), Vector2(button_width, 56), func(): use_requested.emit(), true)

func _style(background: Color, border: Color = Color("886125")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	return style

func _panel(at: Vector2, extent: Vector2, background: Color) -> Panel:
	var panel := Panel.new()
	panel.position = at
	panel.size = extent
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(background))
	content.add_child(panel)
	return panel

func _label(parent: Node, value: String, at: Vector2, extent: Vector2, size_value: int, color: Color, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = value
	label.position = at
	label.size = extent
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", bold_font if bold else font)
	label.add_theme_font_size_override("font_size", size_value)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(value: String, at: Vector2, extent: Vector2, callback: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = value
	button.position = at
	button.size = extent
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_override("font", bold_font if primary else font)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", INK if primary else PAPER)
	button.add_theme_color_override("font_hover_color", INK if primary else PAPER)
	button.add_theme_color_override("font_pressed_color", INK if primary else PAPER)
	var task_panel := screen in ["arrival", "board", "task", "result", "lesson", "goal", "prayer_record"]
	var background := Color("1b130bf2") if task_panel else Color("191c19")
	button.add_theme_stylebox_override("normal", _style(GOLD if primary else background))
	button.add_theme_stylebox_override("hover", _style(GOLD.lightened(0.12) if primary else (background.lightened(0.1) if task_panel else Color("312b20"))))
	button.add_theme_stylebox_override("pressed", _style(GOLD.darkened(0.12) if primary else (background.darkened(0.12) if task_panel else Color("0d100f"))))
	button.pressed.connect(callback)
	content.add_child(button)
	return button

func show_city_gate(index: int) -> void:
	if index != 0:
		show_toast(data.ui.not_built)
	elif progress.gate_open:
		show_toast(data.gate.open)
	elif progress.trust < int(data.numbers.gate_trust):
		show_toast(data.gate.needs_trust.format({"trust": progress.trust}))
	else:
		show_toast(data.gate.needs_lesson)
