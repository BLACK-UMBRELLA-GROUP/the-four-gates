extends Node3D
## LOCK 1: world, movement, market tasks, scales lesson and gate progression.

const Foundations = preload("res://game/foundations.gd")
const MarketWorld = preload("res://game/market_world.gd")
const MarketPlayer = preload("res://game/market_player.gd")
const MarketUI = preload("res://game/market_ui.gd")
const TaskProgress = preload("res://game/task_progress.gd")

var data: Dictionary
var world: Node3D
var player: CharacterBody3D
var ui: CanvasLayer
var night := false
var current_place := ""
var destination := ""
var route: Array[Vector3] = []
var capture_runner: RefCounted
var progress := TaskProgress.new()

func _ready() -> void:
	data = Foundations.load_data()
	Foundations.configure_input(data)
	progress.setup(data)
	world = MarketWorld.new()
	add_child(world)
	world.setup(data)
	player = MarketPlayer.new()
	add_child(player)
	player.setup(data)
	player.position = world.point(data.start_place)
	ui = MarketUI.new()
	add_child(ui)
	ui.setup(data, progress)
	ui.begin_requested.connect(begin_game)
	ui.screen_requested.connect(show_screen)
	ui.wait_requested.connect(toggle_night)
	ui.use_requested.connect(use_place)
	ui.goal_requested.connect(show_goal)
	ui.destination_requested.connect(walk_to_place)
	ui.task_requested.connect(open_task)
	ui.choice_requested.connect(choose_task)
	ui.amend_requested.connect(amend_task)
	ui.daily_job_requested.connect(do_daily_job)
	ui.weight_requested.connect(try_weight)
	ui.answer_requested.connect(answer_weight)
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

func _process(_delta: float) -> void:
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
	ui.refresh(player.position, current_place, night)

func begin_game() -> void:
	player.position = world.point(data.start_place)
	player.velocity = Vector3.ZERO
	player.yaw = 0
	player.update_camera()
	route.clear()
	player.test_move_axis = Vector2.ZERO
	show_screen("game")

func show_screen(screen: String) -> void:
	ui.show_screen(screen)
	player.enabled = screen == "game" or screen == "market_map"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if screen == "game" else Input.MOUSE_MODE_VISIBLE
	update_state()

func toggle_night() -> void:
	night = not night
	if not night:
		progress.morning()
	world.set_night(night)
	update_state()
	ui.show_toast(data.other_text.night if night else data.other_text.day)

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
		ui.show_toast(data.lesson.win)
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
	if event.is_action_pressed("close"):
		if ui.screen == "city_map": show_screen("market_map")
		elif ui.screen == "market_map": show_screen("game")
		elif ui.screen in ["board", "task", "result", "lesson", "goal"]: show_screen("game")
		else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("market_map") and ui.screen != "title":
		show_screen("game" if ui.screen == "market_map" else "market_map")
	elif event.is_action_pressed("goal") and ui.screen != "title": show_goal()
	elif event.is_action_pressed("wait_day_night") and ui.screen != "title": toggle_night()
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
