extends CanvasLayer
## Interface from approved masters. Only placement, colour and drawing measurements
## live here; all displayed content is read from the approved data dictionary.

signal begin_requested
signal arrival_choice_requested(index: int)
signal arrival_continue_requested
signal arrival_walk_requested
signal arrival_meet_requested
signal idris_choice_requested(index: int)
signal idris_continue_requested
signal idris_leave_requested
signal idris_replay_requested
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
signal purse_requested
signal salma_requested
signal page_requested
signal page_closed
signal gift_requested(id: String, secret: bool)
signal end_purse_day_requested
signal bread_grab_requested
signal bread_grab_left
signal bread_grab_ask_requested
signal bread_grab_answered(id: String)

const MapCanvas = preload("res://game/map_canvas.gd")
const LessonCanvas = preload("res://game/lesson_canvas.gd")
const BreadGrab = preload("res://game/bread_grab.gd")
const PAPER := Color("f5e8cd")
const GOLD := Color("f8ae36")
const INK := Color("30200e")
const GRAB_SCREENS := ["grab_see", "grab_ask", "grab_after"]
const CHAPTER_SCREENS := ["purse", "purse_salma", "purse_page", "purse_morning", "reputation"] + GRAB_SCREENS
var data: Dictionary = {}
var identity: Dictionary = {}
var chapter: Dictionary
var open_purse: RefCounted
var bread_grab: BreadGrab
var _board_prompt := BreadGrab.Prompt.NONE
var language_words: Dictionary
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
var idris_beat := 0
var idris_reply := ""
var idris_new_word := ""
var idris_met := false
var known_words: Dictionary = {}
var _word_marker := RegEx.create_from_string("\\{([^{}]+)\\}")
var _last_coins := -1
var _last_trust := -1
var _last_daily_count := -1
var _last_lesson := false
var _last_gate := false

func setup(source: Dictionary, progress_value: RefCounted, identity_value: Dictionary, clock_value: RefCounted, chapter_value: Dictionary, purse_value: RefCounted, grab_value: BreadGrab) -> void:
	data = source
	identity = identity_value
	chapter = chapter_value
	open_purse = purse_value
	bread_grab = grab_value
	language_words = identity.language.words.duplicate()
	language_words.merge(chapter.words)
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
		"idris":
			_build_hud()
			_build_idris()
		"game", "market_map":
			_build_hud()
			var place_x := 203.0
			var has_board_prompt := _board_prompt != BreadGrab.Prompt.NONE
			var nav_y := 974.0
			if has_board_prompt:
				nav_y = 814.0 if _board_prompt == BreadGrab.Prompt.WAIT else 890.0
			if screen == "market_map":
				_button(data.ui.buttons.city_map, Vector2(42, nav_y), Vector2(138, 55), func(): screen_requested.emit("city_map"))
				_button(data.ui.buttons.wait_prayer, Vector2(203, nav_y), Vector2(265, 55), func(): wait_requested.emit())
				_button(chapter.purse.morning.to_rep, Vector2(491, nav_y), Vector2(219, 55), func(): screen_requested.emit("reputation"))
				place_x = 732.0
			else:
				_button(data.ui.buttons.map, Vector2(42, nav_y), Vector2(138, 55), func(): screen_requested.emit("market_map"))
			if has_board_prompt:
				_build_prayer_buttons(place_x, 0.0, nav_y)
				place_x = 42.0
			_build_place_bar(place_x)
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
		"purse":
			_build_hud()
			_build_purse()
		"purse_salma":
			_build_hud()
			_build_salma()
		"purse_page":
			_build_hud()
			_build_page_one()
		"purse_morning":
			_build_hud()
			_build_purse_morning()
		"grab_see", "grab_ask", "grab_after":
			_build_hud()
			_build_bread_grab()
		"reputation":
			_build_hud()
			_build_reputation()
	_last_coins = progress.coins
	_last_trust = progress.trust
	_last_daily_count = progress.daily_count
	_last_lesson = progress.lesson_done
	_last_gate = progress.gate_open

func refresh(position_value: Vector3, place_value: String, night_value: bool, salma_present: bool) -> void:
	player_position = position_value
	var place_changed := place_id != place_value
	var clock_changed: bool = _clock_day != clock.day or _clock_minute != clock.minute_of_day
	var rebuild: bool = place_changed or _last_coins != progress.coins or _last_trust != progress.trust or _last_daily_count != progress.daily_count or _last_lesson != progress.lesson_done or _last_gate != progress.gate_open
	var prompt := bread_grab.board_prompt(salma_present) if place_value == "board" else BreadGrab.Prompt.NONE
	if prompt != _board_prompt:
		_board_prompt = prompt
		rebuild = rebuild or screen in ["game", "market_map"]
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
		x += _arrival_button(arrival.buttons[0], Vector2(x, origin.y + y), func(): arrival_meet_requested.emit(), true) + 12.0
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
	var width := _button_width(value, primary)
	_button(value, at, Vector2(width, 56), callback, primary)
	return width

func _button_width(value: String, primary: bool = false) -> float:
	var face := bold_font if primary else font
	return face.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 44.0

func _build_idris() -> void:
	var teacher: Dictionary = identity.teacher
	var done: bool = idris_beat == teacher.beats.size()
	var beat: Dictionary = {} if done else teacher.beats[idris_beat]
	var count := known_words.size()
	var kicker: String = teacher.kicker.format({"when": teacher.when, "n": count})
	var panel := _panel(Vector2.ZERO, Vector2(1188, 0), Color("1b130be8"))
	_heading(panel, kicker, teacher.name if done else teacher.title_before)
	var line: String = teacher.end if done else beat.text
	var y := 111.0 + _story_text(panel, line, 111.0) + 14.0
	if done:
		var count_line: String = teacher.words_you_know.format({"n": count})
		_label(panel, count_line.to_upper(), Vector2(34, y), Vector2(1120, 28), 16, Color("e9bd70"))
		y += 36.0
	elif not idris_reply.is_empty():
		y += _story_text(panel, idris_reply, y, true) + 12.0
		if not idris_new_word.is_empty():
			var word: Dictionary = identity.language.words[idris_new_word]
			var notice: String = teacher.new_word.format(word)
			_label(panel, notice.to_upper(), Vector2(34, y), Vector2(1120, 28), 16, Color("e9bd70"))
			y += 36.0

	var buttons_height := 68.0
	if not done and idris_reply.is_empty():
		buttons_height *= beat.choices.size()
	panel.size.y = y + buttons_height + 82.0
	panel.position = Vector2(366, 583 - panel.size.y / 2.0)
	var at := panel.position + Vector2(34, y)
	if done:
		var back_width := _arrival_button(teacher.buttons.back, at, func(): idris_leave_requested.emit(), true)
		_arrival_button(teacher.buttons.again, at + Vector2(back_width + 12.0, 0), func(): idris_replay_requested.emit())
	elif not idris_reply.is_empty():
		_arrival_button(teacher.buttons.continue, at, func(): idris_continue_requested.emit(), true)
	else:
		for index in range(beat.choices.size()):
			var choose := _button(beat.choices[index].label, at + Vector2(0, 68 * index), Vector2(1120, 56), func(): idris_choice_requested.emit(index))
			choose.alignment = HORIZONTAL_ALIGNMENT_LEFT
			for state in ["normal", "hover", "pressed"]:
				choose.get_theme_stylebox(state).content_margin_left = 22.0
	_arrival_button(teacher.buttons.leave, at + Vector2(0, buttons_height), func(): idris_leave_requested.emit())

func _story_text(panel: Panel, value: String, y: float, bold: bool = false) -> float:
	var body := RichTextLabel.new()
	body.position = Vector2(34, y)
	body.size.x = 1120
	body.fit_content = true
	body.scroll_active = false
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_theme_font_override("normal_font", bold_font if bold else font)
	body.add_theme_font_override("bold_font", bold_font)
	body.add_theme_font_size_override("normal_font_size", 23)
	body.add_theme_font_size_override("bold_font_size", 23)
	body.add_theme_color_override("default_color", PAPER)
	if screen in CHAPTER_SCREENS:
		body.add_theme_constant_override("line_separation", 5)
	panel.add_child(body)

	var offset := 0
	for marker: RegExMatch in _word_marker.search_all(value):
		var id := marker.get_string(1)
		if not language_words.has(id):
			continue
		body.add_text(value.substr(offset, marker.get_start() - offset))
		var word: Dictionary = language_words[id]
		if known_words.has(id):
			body.push_bold()
			body.add_text(word.en)
			body.pop()
			body.push_color(Color("e9bd70"))
			body.push_font_size(17)
			body.add_text(" (" + word.ar + ")")
			body.pop()
			body.pop()
		else:
			body.push_color(Color("a7d3ff"))
			body.push_italics()
			body.push_underline()
			body.add_text(word.ar)
			body.pop()
			body.pop()
			body.pop()
		offset = marker.get_end()
	body.add_text(value.substr(offset))
	return body.get_content_height()

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
	if screen in ["arrival", "idris", "purse_salma", "purse_page"] or screen in GRAB_SCREENS:
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
	if screen not in ["arrival", "idris", "prayer_record", "purse_salma", "purse_page"] and screen not in GRAB_SCREENS:
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

func _chapter_panel(kicker: String, title_value: String) -> Panel:
	var panel := _panel(Vector2.ZERO, Vector2(1188, 0), Color("1b130be8"))
	_heading(panel, kicker, title_value)
	return panel

func _chapter_finish(panel: Panel, button_y: float) -> void:
	panel.size.y = button_y + 82.0
	panel.position = Vector2(366, maxf(138.0, 583.0 - panel.size.y / 2.0))

func _chapter_note(panel: Panel, value: String, y: float) -> float:
	_label(panel, value.to_upper(), Vector2(34, y), Vector2(1120, 28), 16, Color("e9bd70"))
	return y + 36.0

func _chapter_button(panel: Panel, value: String, at: Vector2, callback: Callable, primary: bool = false, full_width: bool = false) -> float:
	var width := 1120.0 if full_width else _button_width(value, primary)
	var button := _button(value, at, Vector2(width, 56), callback, primary, panel)
	if full_width:
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		for state in ["normal", "hover", "pressed"]:
			button.get_theme_stylebox(state).content_margin_left = 22.0
	return width + 12.0

func _chapter_row_rule(panel: Panel, y: float) -> void:
	var rule := ColorRect.new()
	rule.position = Vector2(34, y)
	rule.size = Vector2(1120, 1)
	rule.color = Color("88612566")
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(rule)

func _build_purse() -> void:
	var purse: Dictionary = chapter.purse
	var panel := _chapter_panel(purse.kicker, purse.title)
	var y := 111.0
	y += _story_text(panel, purse.intro, y) + 16.0
	for person: Dictionary in open_purse.visible_people():
		y += _purse_person_row(panel, purse, person, y)
	if not open_purse.page_read:
		y = _chapter_note(panel, purse.only_public, y)
	y += 10.0
	var x := 34.0
	if not open_purse.salma_asked:
		x += _chapter_button(panel, purse.ask_baker, Vector2(x, y), func(): salma_requested.emit())
	elif not open_purse.page_read:
		x += _chapter_button(panel, str(purse.take_page).format({"teacher": chapter.teacher}), Vector2(x, y), func(): page_requested.emit())
	x += _chapter_button(panel, purse.end_day, Vector2(x, y), func(): end_purse_day_requested.emit(), true)
	_chapter_button(panel, purse.not_now, Vector2(x, y), func(): screen_requested.emit("market_map"))
	_chapter_finish(panel, y)

func _purse_person_row(panel: Panel, purse: Dictionary, person: Dictionary, y: float) -> float:
	_chapter_row_rule(panel, y)
	var id: String = person.id
	var gift: String = open_purse.gift_status(id)
	var cost := int(person.cost)
	var public_label: String = str(purse.give).format({"n": cost})
	var secret_label: String = purse.give_secret
	var status := ""
	if not gift.is_empty():
		status = purse.given_public if gift == "public" else purse.given_secret
	elif progress.coins < cost:
		status = purse.not_enough

	var action_width := _button_width(public_label, true)
	if not status.is_empty():
		action_width = font.get_string_size(status, HORIZONTAL_ALIGNMENT_LEFT, -1, 23).x
	elif open_purse.page_read:
		action_width += _button_width(secret_label) + 8.0
	var body_width := 1120.0 - action_width - 20.0
	var name_color := PAPER if gift.is_empty() else Color("b1a18b")
	var body_color := Color("ebdab7") if gift.is_empty() else Color("b1a18b")
	_label(panel, person.name, Vector2(34, y + 12), Vector2(body_width, 30), 23, name_color, true)
	var ask := _label(panel, "", Vector2(34, y + 43), Vector2(body_width, 0), 20, body_color)
	ask.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ask.text = person.ask
	ask.size.y = ask.get_minimum_size().y
	var row_height := maxf(84.0, 57.0 + ask.size.y)
	var action_at := Vector2(1154.0 - action_width, y + (row_height - 56.0) / 2.0)
	if not status.is_empty():
		var color := Color("ffd27e") if gift.is_empty() else Color("c4965b")
		var label := _label(panel, status, action_at, Vector2(action_width, 56), 23, color)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		_chapter_button(panel, public_label, action_at, func(): gift_requested.emit(id, false), true)
		if open_purse.page_read:
			action_at.x += _button_width(public_label, true) + 8.0
			_chapter_button(panel, secret_label, action_at, func(): gift_requested.emit(id, true))
	return row_height

func _build_salma() -> void:
	var baker: Dictionary = chapter.purse.baker
	var panel := _chapter_panel(chapter.purse.kicker, baker.title)
	var y := 111.0
	for line: String in baker.lines:
		y += _story_text(panel, line, y) + 15.0
	var take: String = str(chapter.purse.take_page).format({"teacher": chapter.teacher})
	_chapter_button(panel, take, Vector2(34, y), func(): page_requested.emit(), true, true)
	y += 69.0
	_chapter_button(panel, baker.back, Vector2(34, y), func(): page_closed.emit(), false, true)
	_chapter_finish(panel, y)

func _build_page_one() -> void:
	var page: Dictionary = chapter.page
	var panel := _chapter_panel(page.kicker, page.title)
	var y := 111.0
	y += _story_text(panel, str(page.story).format({"teacher": chapter.teacher}), y) + 15.0
	var hadith: String = str(page.hadith).format({"teacher": chapter.teacher, "word": "{sirr}"})
	y += _story_text(panel, hadith, y) + 15.0
	y = _chapter_note(panel, str(page.source) + " · " + str(page.learned).format(chapter.words.sirr), y)
	_chapter_button(panel, page.back, Vector2(34, y), func(): page_closed.emit(), true, true)
	_chapter_finish(panel, y)

func _build_purse_morning() -> void:
	var morning: Dictionary = chapter.purse.morning
	var panel := _chapter_panel(morning.kicker, morning.title)
	var y := 111.0
	for line: String in open_purse.morning_lines():
		y += _story_text(panel, line, y) + 15.0
	var x := 34.0 + _chapter_button(panel, morning.to_rep, Vector2(34, y), func(): screen_requested.emit("reputation"), true)
	_chapter_button(panel, morning.to_map, Vector2(x, y), func(): screen_requested.emit("market_map"))
	_chapter_finish(panel, y)

func _build_bread_grab() -> void:
	var grab: Dictionary = chapter.grab
	var beat: Dictionary = grab[screen.trim_prefix("grab_")]
	var panel := _chapter_panel(beat.kicker, beat.title)
	var y := 111.0
	match screen:
		"grab_see":
			y += _story_text(panel, beat.text, y) + 14.0
			_chapter_button(panel, beat.next, Vector2(34, y), func(): bread_grab_left.emit(), true, true)
		"grab_ask":
			y += _story_text(panel, beat.text, y) + 14.0
			var first := true
			for id: String in grab.answers:
				_chapter_button(panel, grab.answers[id].button, Vector2(34, y), func(): bread_grab_answered.emit(id), first, true)
				first = false
				y += 69.0
			y -= 69.0
		"grab_after":
			var id := bread_grab.answer_id
			y += _story_text(panel, grab.answers[id].out, y) + 14.0
			if id == "lie":
				y = _chapter_note(panel, beat.note, y)
			var x := 34.0 + _chapter_button(panel, beat.to_rep, Vector2(34, y), func(): screen_requested.emit("reputation"), true)
			_chapter_button(panel, beat.to_map, Vector2(x, y), func(): screen_requested.emit("market_map"))
	_chapter_finish(panel, y)

func reputation_lines() -> Array:
	var lines: Array = open_purse.reputation_lines()
	var answer: Variant = bread_grab.reputation_line()
	if answer != null:
		lines.append(answer)
	return lines

func _build_reputation() -> void:
	var rep: Dictionary = chapter.rep
	var panel := _chapter_panel(rep.kicker, str(rep.title).format({"n": progress.trust}))
	var lines := reputation_lines()
	var y := 111.0
	if lines.is_empty():
		y += _story_text(panel, rep.empty, y) + 15.0
	var row_height := 70.0 if lines.size() > 6 else 81.0
	for line: Array in lines:
		_chapter_row_rule(panel, y)
		_label(panel, "“%s”" % line[0], Vector2(34, y + 10), Vector2(1000, 32), 23, PAPER, true)
		_label(panel, str(line[1]).to_upper(), Vector2(34, y + 42), Vector2(1000, 24), 16, Color("e9bd70"))
		var tone: String = rep.tone[str(int(line[2]))]
		var tag := _label(panel, tone, Vector2(1034, y + 16), Vector2(120, 48), 23, Color("ffd27e"))
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		y += row_height
	if open_purse.has_secret_gift():
		y = _chapter_note(panel, rep.secret_note, y)
	y = _chapter_note(panel, rep.towns_note, y)
	var x := 34.0 + _chapter_button(panel, rep.to_map, Vector2(34, y), func(): screen_requested.emit("market_map"), true)
	_chapter_button(panel, rep.to_goal, Vector2(x, y), func(): goal_requested.emit())
	_chapter_finish(panel, y)

func _build_prayer_buttons(x: float, place_width: float, row_y: float = 973.0) -> float:
	var prayer := _prayer_label if place_id != "masjid" else ""
	var width := 0.0
	if not prayer.is_empty():
		width += _button_width(prayer, true) + 22.0
	if not _make_up_label.is_empty():
		width += _button_width(_make_up_label) + 22.0
	var separate_row := x + width + place_width > 1878.0
	var at := Vector2(x, 898.0 if separate_row else row_y)
	if not prayer.is_empty():
		at.x += _arrival_button(prayer, at, func(): pray_requested.emit(), true) + 22.0
	if not _make_up_label.is_empty():
		at.x += _arrival_button(_make_up_label, at, func(): make_up_requested.emit()) + 22.0
	return x if separate_row else at.x

func _build_place_bar(x: float) -> void:
	if place_id.is_empty() or not data.places.has(place_id):
		var idle: String = data.ui.place_bar.idle
		var idle_width: float = font.get_string_size(idle, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
		x = _build_prayer_buttons(x, idle_width + 36)
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
		var masjid_actions: Dictionary = identity.clock.masjid_actions
		action = masjid_actions.after_meeting if idris_met else masjid_actions.none_yet
		if not _prayer_label.is_empty():
			action = _prayer_label
	var name_width := bold_font.get_string_size(name_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	var line_width := font.get_string_size(line_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	var button_width := bold_font.get_string_size(action, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 46
	var extra_text := ""
	var extra_action: Callable
	var extra_primary := false
	if place_id == "inn" and not open_purse.done:
		extra_text = chapter.places.inn
		extra_action = func(): purse_requested.emit()
	elif _board_prompt == BreadGrab.Prompt.SEE:
		extra_text = chapter.places.board
		extra_action = func(): bread_grab_requested.emit()
	elif _board_prompt == BreadGrab.Prompt.ASK:
		extra_text = chapter.grab.ask_button
		extra_action = func(): bread_grab_ask_requested.emit()
		extra_primary = true
	var extra_width := _button_width(extra_text, extra_primary) + 18.0 if not extra_text.is_empty() else 0.0
	var total_width := name_width + line_width + button_width + extra_width + 55.0
	if _board_prompt == BreadGrab.Prompt.NONE:
		x = _build_prayer_buttons(x, total_width)
	var waiting := _board_prompt == BreadGrab.Prompt.WAIT
	var bar_y := 891.0 if waiting else 965.0
	var width := total_width
	if waiting:
		width = maxf(width, font.get_string_size(chapter.grab.wait_line, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 36.0)
	var panel := _panel(Vector2(x, bar_y), Vector2(width, 147.0 if waiting else 73.0), Color("191c19"))
	_label(panel, name_value, Vector2(18, 15), Vector2(name_width + 4, 42), 24, PAPER, true)
	_label(panel, line_value, Vector2(18 + name_width, 15), Vector2(line_width + 4, 42), 24, PAPER)
	var action_x := x + total_width - button_width - extra_width - 17.0
	_button(action, Vector2(action_x, bar_y + 8.0), Vector2(button_width, 56), func(): use_requested.emit(), true)
	if not extra_text.is_empty():
		_button(extra_text, Vector2(action_x + button_width + 18.0, bar_y + 8.0), Vector2(extra_width - 18.0, 56), extra_action, extra_primary)
	if waiting:
		_label(panel, chapter.grab.wait_line, Vector2(18, 87), Vector2(width - 36, 42), 24, PAPER)

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

func _button(value: String, at: Vector2, extent: Vector2, callback: Callable, primary: bool = false, parent: Node = null) -> Button:
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
	var task_panel := parent != null or screen in ["arrival", "idris", "board", "task", "result", "lesson", "goal", "prayer_record"]
	var background := Color("1b130bf2") if task_panel else Color("191c19")
	button.add_theme_stylebox_override("normal", _style(GOLD if primary else background))
	button.add_theme_stylebox_override("hover", _style(GOLD.lightened(0.12) if primary else (background.lightened(0.1) if task_panel else Color("312b20"))))
	button.add_theme_stylebox_override("pressed", _style(GOLD.darkened(0.12) if primary else (background.darkened(0.12) if task_panel else Color("0d100f"))))
	button.pressed.connect(callback)
	(parent if parent != null else content).add_child(button)
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
