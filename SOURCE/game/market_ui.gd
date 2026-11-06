extends CanvasLayer
## Interface from LOCK 1 masters. Only placement, colour and drawing measurements
## live here; all displayed content is read from the approved data dictionary.

signal begin_requested
signal screen_requested(screen: String)
signal wait_requested
signal use_requested
signal goal_requested
signal destination_requested(place_id: String)
signal task_requested(task_id: String)
signal choice_requested(task_id: String, choice: String)
signal amend_requested(task_id: String)
signal daily_job_requested

const MapCanvas = preload("res://game/map_canvas.gd")
const PAPER := Color("f5e8cd")
const GOLD := Color("f8ae36")
const INK := Color("30200e")
var data: Dictionary = {}
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
var font := SystemFont.new()
var bold_font := SystemFont.new()
var title_font := SystemFont.new()
var progress: RefCounted
var task_id := ""
var result: Dictionary = {}
var _last_coins := -1
var _last_trust := -1
var _last_daily_count := -1

func setup(source: Dictionary, progress_value: RefCounted) -> void:
	data = source
	progress = progress_value
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
	map.configure(data)
	map.destination_requested.connect(func(id: String): destination_requested.emit(id))
	map.city_gate_requested.connect(func(index: int): show_toast(data.city_map.gate_messages[index]))
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
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	map.visible = screen == "market_map" or screen == "city_map"
	map.mode = screen
	map.night = night
	map.player_position = player_position
	map.selected_place = place_id
	map.queue_redraw()
	match screen:
		"title":
			_build_title()
		"game", "market_map":
			_build_hud()
			_build_place_bar()
			if screen == "market_map":
				_button(data.ui.buttons.city_map, Vector2(42, 974), Vector2(138, 55), func(): screen_requested.emit("city_map"))
				_button(data.ui.buttons.wait_day if night else data.ui.buttons.wait_night, Vector2(203, 974), Vector2(200, 55), func(): wait_requested.emit())
			else:
				_button(data.ui.buttons.map, Vector2(42, 974), Vector2(138, 55), func(): screen_requested.emit("market_map"))
		"city_map":
			_button(data.ui.buttons.title_back, Vector2(42, 983), Vector2(105, 55), func(): screen_requested.emit("title"))
			_button(data.ui.buttons.goal, Vector2(170, 983), Vector2(93, 55), func(): goal_requested.emit())
		"board":
			_build_hud()
			_build_board()
		"task":
			_build_hud()
			_build_task()
		"result":
			_build_hud()
			_build_result()
	_last_coins = progress.coins
	_last_trust = progress.trust
	_last_daily_count = progress.daily_count

func refresh(position_value: Vector3, place_value: String, night_value: bool) -> void:
	player_position = position_value
	var rebuild: bool = place_id != place_value or night != night_value or _last_coins != progress.coins or _last_trust != progress.trust or _last_daily_count != progress.daily_count
	place_id = place_value
	night = night_value
	if not is_instance_valid(root):
		return
	map.player_position = player_position
	map.selected_place = place_id
	map.night = night
	if map.visible:
		map.queue_redraw()
	if rebuild and screen != "title":
		show_screen(screen)

func show_toast(value: String) -> void:
	if not is_instance_valid(toast_label):
		return
	toast_label.text = value
	_toast_seconds = 3.5
	toast_panel.show()

func _process(delta: float) -> void:
	if _toast_seconds > 0:
		_toast_seconds -= delta
		if _toast_seconds <= 0:
			toast_panel.hide()

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
		var letter := _label(content, glyph, Vector2(title_x, 390), Vector2(glyph_width + 2, 150), 112, Color("ffda87"), true)
		letter.add_theme_font_override("font", title_font)
		title_x += glyph_width + 14
	var subtitle := _label(content, str(data.title_screen.line), Vector2(380, 564), Vector2(1160, 52), 28, PAPER)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(data.ui.buttons.begin, Vector2(830, 650), Vector2(107, 56), func(): begin_requested.emit(), true)
	_button(data.ui.buttons.settings, Vector2(960, 650), Vector2(130, 56), func(): show_toast(data.title_screen.settings_toast))

func _build_hud() -> void:
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
	var hit := Button.new()
	hit.flat = true
	hit.position = Vector2.ZERO
	hit.size = trust.size
	hit.modulate = Color(1, 1, 1, 0)
	hit.pressed.connect(func(): goal_requested.emit())
	trust.add_child(hit)

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

func _build_place_bar() -> void:
	var x := 425.0 if screen == "market_map" else 203.0
	if place_id.is_empty() or not data.places.has(place_id):
		var idle: String = data.ui.place_bar.idle
		var idle_width: float = font.get_string_size(idle, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
		var idle_panel := _panel(Vector2(x, 965), Vector2(idle_width + 36, 73), Color("191c19"))
		_label(idle_panel, idle, Vector2(18, 15), Vector2(idle_width + 4, 42), 24, PAPER)
		return
	var place: Dictionary = data.places[place_id]
	var name_value: String = place.name
	var line_value: String = str(data.ui.place_bar.format).format({"name": "", "line": place.line})
	var action: String = data.ui.place_actions[place_id]
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
	var task_panel := screen in ["board", "task", "result"]
	var background := Color("1b130bf2") if task_panel else Color("191c19")
	button.add_theme_stylebox_override("normal", _style(GOLD if primary else background))
	button.add_theme_stylebox_override("hover", _style(GOLD.lightened(0.12) if primary else (background.lightened(0.1) if task_panel else Color("312b20"))))
	button.add_theme_stylebox_override("pressed", _style(GOLD.darkened(0.12) if primary else (background.darkened(0.12) if task_panel else Color("0d100f"))))
	button.pressed.connect(callback)
	content.add_child(button)
	return button
