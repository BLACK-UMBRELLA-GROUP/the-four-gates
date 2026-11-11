extends Node3D
## River Market arrival, prayer, movement, tasks and chapter progression.

const Foundations = preload("res://game/foundations.gd")
const MarketWorld = preload("res://game/market_world.gd")
const MarketPlayer = preload("res://game/market_player.gd")
const MarketUI = preload("res://game/market_ui.gd")
const TaskProgress = preload("res://game/task_progress.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")
const OpenPurse = preload("res://game/open_purse.gd")
const BreadGrab = preload("res://game/bread_grab.gd")

var data: Dictionary
var identity: Dictionary
var chapter: Dictionary
var open_purse := OpenPurse.new()
var bread_grab := BreadGrab.new()
var world: Node3D
var player: CharacterBody3D
var ui: CanvasLayer
var clock: PrayerClock
var night: bool:
	get: return clock.night
var current_place := ""
var destination := ""
var route: Array[Vector3] = []
var capture_runner: RefCounted
var progress := TaskProgress.new()
var arrival_beat := 0
var arrival_reply := ""
var arrival_fair = null
var idris_beat := 0
var known_words: Dictionary = {}
var idris_met := false
var paid_nights := 0
var day: int:
	get: return clock.day
var minute_of_day: int:
	get: return clock.minute_of_day
var _daily_job_day := 0
var _arrival_sunset := false
var _idris_reply := ""
var _idris_new_word := ""
var _record_return_screen := "game"
var _prayer_adhan: Variant = null

func _ready() -> void:
	data = Foundations.load_data()
	identity = Foundations.load_identity()
	chapter = Foundations.load_chapter1()
	clock = PrayerClock.new(identity.clock)
	Foundations.configure_input(data)
	progress.setup(data)
	open_purse.setup(chapter, progress, clock)
	bread_grab.setup(chapter, progress, clock)
	world = MarketWorld.new()
	add_child(world)
	world.setup(data)
	world.setup_chapter_people(chapter)
	player = MarketPlayer.new()
	add_child(player)
	player.setup(data)
	player.position = world.point(data.start_place)
	ui = MarketUI.new()
	add_child(ui)
	ui.setup(data, progress, identity, clock, chapter, open_purse, bread_grab)
	ui.known_words = known_words
	ui.begin_requested.connect(begin_game)
	ui.arrival_choice_requested.connect(choose_arrival)
	ui.arrival_continue_requested.connect(continue_arrival)
	ui.arrival_walk_requested.connect(walk_from_arrival)
	ui.arrival_meet_requested.connect(meet_idris_from_arrival)
	ui.idris_choice_requested.connect(choose_idris)
	ui.idris_continue_requested.connect(continue_idris)
	ui.idris_leave_requested.connect(leave_idris)
	ui.idris_replay_requested.connect(replay_idris)
	ui.screen_requested.connect(show_screen)
	ui.wait_requested.connect(wait_until_next_prayer)
	ui.pray_requested.connect(pray_here)
	ui.make_up_requested.connect(make_up_prayer)
	ui.record_requested.connect(show_prayer_record)
	ui.record_closed.connect(close_prayer_record)
	clock.adhan_started.connect(_show_adhan)
	ui.use_requested.connect(use_place)
	ui.goal_requested.connect(show_goal)
	ui.destination_requested.connect(walk_to_place)
	ui.task_requested.connect(open_task)
	ui.choice_requested.connect(choose_task)
	ui.amend_requested.connect(amend_task)
	ui.daily_job_requested.connect(do_daily_job)
	ui.weight_requested.connect(try_weight)
	ui.answer_requested.connect(answer_weight)
	ui.purse_requested.connect(show_open_purse)
	ui.salma_requested.connect(ask_salma)
	ui.page_requested.connect(read_page_one)
	ui.page_closed.connect(return_to_purse)
	ui.gift_requested.connect(give_from_purse)
	ui.end_purse_day_requested.connect(end_purse_day)
	ui.bread_grab_requested.connect(show_bread_grab)
	ui.bread_grab_left.connect(leave_bread_grab)
	ui.bread_grab_ask_requested.connect(ask_about_bread)
	ui.bread_grab_answered.connect(answer_bread_grab)
	show_screen("title")
	update_state()
	if "--capture-foundations" in OS.get_cmdline_user_args():
		capture_runner = preload("res://tests/capture_foundations.gd").new()
		capture_runner.run(self)
	elif "--capture-tasks" in OS.get_cmdline_user_args():
		capture_runner = preload("res://tests/capture_tasks.gd").new()
		capture_runner.run(self)
	elif "--capture-gate" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_gate.gd").new()
		capture_runner.run(self)
	elif "--capture-identity" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_identity.gd").new()
		capture_runner.run(self)
	elif "--capture-arrival" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_arrival.gd").new()
		capture_runner.run(self)
	elif "--capture-clock" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_clock.gd").new()
		capture_runner.run(self)
	elif "--capture-idris" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_idris.gd").new()
		capture_runner.run(self)
	elif "--capture-open-purse" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_open_purse.gd").new()
		capture_runner.run(self)
	elif "--capture-bread-grab" in OS.get_cmdline_user_args():
		capture_runner = load("res://tests/capture_bread_grab.gd").new()
		capture_runner.run(self)

func _process(delta: float) -> void:
	if ui.screen not in ["title", "arrival"]:
		clock.advance_seconds(delta)
	update_state()

func _physics_process(_delta: float) -> void:
	if ui.screen not in ["game", "market_map"]:
		player.test_move_axis = Vector2.ZERO
		return
	if route.is_empty():
		return
	var offset := route[0] - player.position
	offset.y = 0
	var arrival: float = data.player.use_radius if route.size() == 1 else data.player.capsule_radius
	if offset.length() < arrival:
		route.pop_front()
		if route.is_empty():
			player.test_move_axis = Vector2.ZERO
		return
	var local := offset.rotated(Vector3.UP, -player.yaw).normalized()
	player.test_move_axis = Vector2(local.x, local.z)

func update_state() -> void:
	if not is_instance_valid(player) or not is_instance_valid(ui):
		return
	current_place = ""
	var nearest: float = data.player.use_radius
	for id in data.places:
		var point: Vector3 = world.point(id)
		var distance := Vector2(player.position.x, player.position.z).distance_to(Vector2(point.x, point.z))
		if distance <= nearest:
			nearest = distance
			current_place = id
	if day != _daily_job_day:
		_daily_job_day = day
		progress.morning()
	var world_night: bool = night or (ui.screen == "arrival" and _arrival_sunset)
	if world.night != world_night:
		world.set_night(world_night)
	ui.refresh(player.position, current_place, night, world.salma.is_visible_in_tree())

func begin_game() -> void:
	progress.setup(data)
	open_purse.reset()
	bread_grab.reset()
	world.stop_faris_run()
	world.set_inn_people_waiting(true)
	world.reset_gate()
	arrival_beat = 0
	arrival_reply = ""
	arrival_fair = null
	idris_met = false
	ui.idris_met = false
	known_words.clear()
	paid_nights = 0
	clock.reset()
	_arrival_sunset = false
	player.position = world.point(data.start_place)
	player.velocity = Vector3.ZERO
	player.yaw = 0
	player.pitch = 0
	player.update_camera()
	route.clear()
	destination = ""
	player.test_move_axis = Vector2.ZERO
	_show_arrival()

func choose_arrival(index: int) -> void:
	var beats: Array = identity.arrival.beats
	if ui.screen != "arrival" or arrival_beat >= beats.size() or not arrival_reply.is_empty():
		return
	var choices: Array = beats[arrival_beat].choices
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	var effect: Dictionary = choice.effect
	var coin_change := int(effect.get("coins", 0))
	progress.coins += coin_change
	if coin_change < 0:
		paid_nights += 1
	if effect.has("fair"):
		arrival_fair = effect.fair
	if effect.has("time"):
		clock.advance_to(day, int(effect.time), false)
	arrival_reply = choice.reply
	_show_arrival()

func continue_arrival() -> void:
	if ui.screen != "arrival" or arrival_reply.is_empty():
		return
	arrival_beat += 1
	arrival_reply = ""
	var beats: Array = identity.arrival.beats
	if arrival_beat < beats.size():
		# The sunset backdrop begins with the prompt. Its choice applies the time jump.
		for choice: Dictionary in beats[arrival_beat].choices:
			if choice.effect.has("time"):
				_arrival_sunset = true
				break
	_show_arrival()

func walk_from_arrival() -> void:
	if ui.screen != "arrival" or arrival_beat != identity.arrival.beats.size():
		return
	player.position = world.point("inn")
	player.velocity = Vector3.ZERO
	show_screen("market_map")

func _show_arrival() -> void:
	ui.arrival_beat = arrival_beat
	ui.arrival_reply = arrival_reply
	ui.arrival_fair = arrival_fair is bool and arrival_fair
	show_screen("arrival")

func meet_idris_from_arrival() -> void:
	if ui.screen == "arrival" and arrival_beat == identity.arrival.beats.size():
		_start_idris()

func _start_idris() -> void:
	player.position = world.point("masjid")
	player.velocity = Vector3.ZERO
	player.test_move_axis = Vector2.ZERO
	route.clear()
	destination = ""
	idris_beat = 0
	_idris_reply = ""
	_idris_new_word = ""
	_show_idris()

func choose_idris(index: int) -> void:
	var beats: Array = identity.teacher.beats
	if ui.screen != "idris" or idris_beat >= beats.size() or not _idris_reply.is_empty():
		return
	var choices: Array = beats[idris_beat].choices
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	if choice.learns != null and identity.language.words.has(choice.learns) and not known_words.has(choice.learns):
		known_words[choice.learns] = true
		_idris_new_word = choice.learns
	_idris_reply = choice.reply
	_show_idris()

func continue_idris() -> void:
	if ui.screen != "idris" or _idris_reply.is_empty():
		return
	idris_beat += 1
	_idris_reply = ""
	_idris_new_word = ""
	if idris_beat == identity.teacher.beats.size():
		idris_met = true
		ui.idris_met = true
	_show_idris()

func leave_idris() -> void:
	if ui.screen == "idris":
		show_screen("market_map")

func replay_idris() -> void:
	if ui.screen == "idris" and idris_beat == identity.teacher.beats.size():
		_start_idris()

func _show_idris() -> void:
	ui.idris_beat = idris_beat
	ui.idris_reply = _idris_reply
	ui.idris_new_word = _idris_new_word
	ui.known_words = known_words
	show_screen("idris")

func _minutes(time: String) -> int:
	return int(time.get_slice(":", 0)) * 60 + int(time.get_slice(":", 1))

func show_screen(screen: String) -> void:
	if screen in MarketUI.GRAB_SCREENS:
		world.oven_camera.make_current()
	elif screen != "reputation" or ui.screen != "grab_after":
		player.camera.make_current()
	ui.show_screen(screen)
	player.enabled = screen == "game" or screen == "market_map"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if screen == "game" else Input.MOUSE_MODE_VISIBLE
	update_state()

func wait_until_next_prayer() -> void:
	clock.wait_until_next_prayer()
	update_state()

func _show_adhan(message: String) -> void:
	if _prayer_adhan == null:
		ui.show_toast(message, ui.screen == "market_map")
	else:
		_prayer_adhan = message

func pray_here() -> void:
	update_state()
	_do_prayer(clock.pray.bind(current_place == "masjid"))

func make_up_prayer() -> void:
	_do_prayer(clock.make_up)

func _do_prayer(action: Callable) -> void:
	# An adhan crossed during the ten-minute advance is shown first.
	_prayer_adhan = ""
	var receipt: String = action.call()
	var adhan: String = _prayer_adhan
	_prayer_adhan = null
	update_state()
	if not adhan.is_empty():
		ui.show_toast(adhan, ui.screen == "market_map", receipt)
	elif not receipt.is_empty():
		ui.show_toast(receipt, ui.screen == "market_map")

func show_prayer_record() -> void:
	if ui.screen not in ["title", "arrival", "prayer_record"]:
		_record_return_screen = ui.screen
		show_screen("prayer_record")

func close_prayer_record() -> void:
	show_screen(_record_return_screen)

func _rest_at_inn() -> void:
	var cost := int(identity.arrival.inn_night)
	var message: String = identity.inn.broom
	if paid_nights > 0:
		paid_nights -= 1
		message = str(identity.inn.paid).format({"n": paid_nights})
	elif progress.coins >= cost:
		progress.coins -= cost
		message = str(identity.inn.coins).format({"n": cost})
	clock.advance_to(day + 1, _minutes(str(identity.inn.wakes_at).get_slice(" ", 0)), false)
	update_state()
	ui.show_toast(message, ui.screen == "market_map")

func show_open_purse() -> void:
	if current_place == "inn" and ui.screen in ["game", "market_map"] and not open_purse.done:
		_stop_travel()
		show_screen("purse")

func ask_salma() -> void:
	if ui.screen == "purse" and not open_purse.salma_asked:
		open_purse.salma_asked = true
		show_screen("purse_salma")

func read_page_one() -> void:
	if ui.screen in ["purse", "purse_salma"] and open_purse.salma_asked and not open_purse.page_read:
		open_purse.page_read = true
		known_words["sirr"] = true
		_set_purse_scene_place("masjid")
		show_screen("purse_page")

func return_to_purse() -> void:
	if ui.screen == "purse_page":
		_set_purse_scene_place("inn")
	if ui.screen in ["purse_salma", "purse_page"]:
		show_screen("purse")

func _set_purse_scene_place(place: String) -> void:
	player.position = world.point(place)
	_stop_travel()

func _stop_travel() -> void:
	player.velocity = Vector3.ZERO
	player.test_move_axis = Vector2.ZERO
	route.clear()
	destination = ""

func give_from_purse(id: String, secret: bool) -> void:
	if ui.screen == "purse" and open_purse.give(id, secret):
		show_screen("purse")

func end_purse_day() -> void:
	if ui.screen == "purse" and open_purse.end_day():
		world.set_inn_people_waiting(false)
		show_screen("purse_morning")

func show_bread_grab() -> void:
	if _bread_grab_prompt() != BreadGrab.Prompt.SEE:
		return
	_stop_travel()
	bread_grab.see()
	world.run_faris_from_oven()
	show_screen("grab_see")

func leave_bread_grab() -> void:
	if ui.screen == "grab_see":
		world.stop_faris_run()
		show_screen("market_map")

func ask_about_bread() -> void:
	if _bread_grab_prompt() != BreadGrab.Prompt.ASK:
		return
	_stop_travel()
	show_screen("grab_ask")

func answer_bread_grab(id: String) -> void:
	if ui.screen == "grab_ask" and bread_grab.answer(id):
		show_screen("grab_after")

func _bread_grab_prompt() -> BreadGrab.Prompt:
	if current_place == "board" and ui.screen in ["game", "market_map"]:
		return bread_grab.board_prompt(world.salma.is_visible_in_tree())
	return BreadGrab.Prompt.NONE

func use_place() -> void:
	update_state()
	match current_place:
		"board": show_board()
		"scales":
			if progress.lesson_done:
				ui.show_toast(data.other_text.scales_after_lesson)
			else:
				progress.tried_weight = -1
				show_screen("lesson")
		"gate":
			var message := progress.ask_gate()
			if progress.gate_open:
				world.open_gate()
			update_state()
			ui.show_toast(message)
		"centre": ui.show_toast(data.other_text.centre_exit)
		"inn": _rest_at_inn()
		"masjid":
			if not clock.prayer_label(true).is_empty():
				pray_here()
			elif not idris_met:
				_start_idris()
			else:
				ui.show_toast(data.ui.not_built, ui.screen == "market_map")
		_: pass

func show_goal() -> void:
	show_screen("goal")

func try_weight(index: int) -> void:
	if ui.screen == "lesson" and progress.try_weight(index):
		ui.show_screen("lesson")

func answer_weight() -> void:
	if ui.screen != "lesson" or progress.tried_weight < 0:
		return
	if progress.answer_weight():
		show_screen("game")
		var cheated: bool = arrival_fair is bool and not arrival_fair
		ui.show_toast(identity.arrival.cheat_found_after_lesson if cheated else data.lesson.win, cheated)
	else:
		ui.show_toast(data.lesson.wrong)

func show_board() -> void:
	show_screen("board")

func open_task(id: String) -> void:
	if progress.tasks.has(id):
		return
	for task: Dictionary in data.tasks:
		if task.id == id:
			ui.task_id = id
			show_screen("task")
			return

func choose_task(id: String, choice: String) -> void:
	var result := progress.choose_task(id, choice)
	if result.is_empty():
		return
	ui.result = result
	show_screen("result")

func amend_task(id: String) -> void:
	if not progress.amend_task(id):
		return
	show_board()
	for task: Dictionary in data.tasks:
		if task.id == id:
			ui.show_toast(task.amends.result)
			return

func do_daily_job() -> void:
	if progress.do_daily_job():
		show_board()
		ui.show_toast(data.daily_job.toast)

func _unhandled_input(event: InputEvent) -> void:
	if ui.screen == "arrival":
		return
	if ui.screen == "idris":
		if event.is_action_pressed("close"):
			leave_idris()
		return
	if ui.screen in ["purse_salma", "purse_page"]:
		if event.is_action_pressed("close"):
			return_to_purse()
		return
	if ui.screen in MarketUI.GRAB_SCREENS:
		if event.is_action_pressed("close"):
			if ui.screen == "grab_see":
				leave_bread_grab()
			else:
				show_screen("market_map")
		return
	if event.is_action_pressed("close"):
		if ui.screen == "prayer_record": close_prayer_record()
		elif ui.screen == "city_map": show_screen("market_map")
		elif ui.screen == "world_map": show_screen("city_map")
		elif ui.screen == "market_map": show_screen("game")
		elif ui.screen in ["purse", "purse_morning", "reputation"]: show_screen("market_map")
		elif ui.screen in ["board", "task", "result", "lesson", "goal"]: show_screen("game")
		else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("market_map") and ui.screen != "title":
		show_screen("game" if ui.screen == "market_map" else "market_map")
	elif event.is_action_pressed("goal") and ui.screen != "title": show_goal()
	elif event.is_action_pressed("wait_prayer") and ui.screen != "title": wait_until_next_prayer()
	elif event.is_action_pressed("pray") and ui.screen in ["game", "market_map"]: pray_here()
	elif event.is_action_pressed("use") and ui.screen in ["game", "market_map"]: use_place()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and ui.screen == "game":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventKey and event.pressed and not event.echo and (event.is_action("move_left") or event.is_action("move_right") or event.is_action("move_forward") or event.is_action("move_back")):
		route.clear()
		player.test_move_axis = Vector2.ZERO

func walk_to_place(id: String) -> void:
	# Follow the approved street graph with physical movement, never teleport.
	if not data.places.has(id):
		return
	var attachment := _street_attachment()
	var costs: Dictionary = attachment.costs
	var previous: Dictionary = {}
	var pending: Array = costs.keys()
	var visited := {}
	while not pending.is_empty():
		pending.sort_custom(func(a, b): return costs[a] < costs[b])
		var point_id: String = pending.pop_front()
		if visited.has(point_id): continue
		visited[point_id] = true
		if point_id == id: break
		for edge in data.streets:
			var next: String = edge[1] if edge[0] == point_id else (edge[0] if edge[1] == point_id else "")
			if next.is_empty(): continue
			var cost: float = costs[point_id] + world.point(point_id).distance_to(world.point(next))
			if not costs.has(next) or cost < costs[next]:
				costs[next] = cost
				previous[next] = point_id
				pending.append(next)
	if not costs.has(id):
		return
	var path: Array[String] = [id]
	while previous.has(path[0]):
		path.push_front(previous[path[0]])
	route.clear()
	for waypoint: Vector3 in attachment.waypoints:
		route.append(waypoint)
	for point_id in path: route.append(world.point(point_id))
	destination = id


func _street_attachment() -> Dictionary:
	var here := Vector2(player.position.x, player.position.z)
	var square: Vector3 = world.point(data.square.centre)
	var square_point := Vector2(square.x, square.z)
	if here.distance_to(square_point) <= float(data.square.radius):
		# The square is convex: moving directly to its centre stays in the square.
		return {"waypoints": [], "costs": {data.square.centre: here.distance_to(square_point)}}
	var best_distance := INF
	var best_projection := Vector2.ZERO
	var best_edge: Array = []
	var waypoints: Array[Vector3] = []
	var on_quay: bool = here.y >= float(data.world.quay.z_from) and here.y <= float(data.world.quay.z_to)
	for edge: Array in data.streets:
		var from: Vector3 = world.point(edge[0])
		var to: Vector3 = world.point(edge[1])
		if on_quay:
			# Attach to the quay's horizontal street through a right-angle leg
			# inside the walkable strip, rather than cutting across house blocks.
			if not data.start_place in edge or not is_equal_approx(from.z, to.z):
				continue
		var projection := Geometry2D.get_closest_point_to_segment(here, Vector2(from.x, from.z), Vector2(to.x, to.z))
		var distance := here.distance_to(projection)
		if on_quay:
			distance = absf(here.x - projection.x) + absf(here.y - projection.y)
		if distance < best_distance:
			best_distance = distance
			best_projection = projection
			best_edge = edge
	# Every valid street point attaches to a segment's centreline. Both segment
	# endpoints are graph candidates, weighted by their distance from that foot.
	if on_quay:
		waypoints.append(Vector3(best_projection.x, 0.0, here.y))
	waypoints.append(Vector3(best_projection.x, 0.0, best_projection.y))
	var costs := {}
	for point_id: String in best_edge:
		var endpoint: Vector3 = world.point(point_id)
		costs[point_id] = best_distance + best_projection.distance_to(Vector2(endpoint.x, endpoint.z))
	return {"waypoints": waypoints, "costs": costs}
