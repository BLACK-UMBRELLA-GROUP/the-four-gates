extends SceneTree
## Independent movement regressions against the real capsule controller.
## All fixture nodes and settings live in memory; no game scene or content is loaded.

const Player = preload("res://game/market_player.gd")
const ACTIONS = ["move_left", "move_right", "move_forward", "move_back", "run"]
const WALK_SPEED := 2.0
const RUN_SPEED := 5.0

var checks := 0
var failures := 0
var world: Node3D
var player


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)


func frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func release_actions() -> void:
	for action in ACTIONS:
		Input.action_release(action)


func horizontal_position() -> Vector2:
	return Vector2(player.position.x, player.position.z)


func horizontal_velocity() -> Vector2:
	return Vector2(player.velocity.x, player.velocity.z)


func build_fixture() -> void:
	world = Node3D.new()
	root.add_child(world)
	var floor_body := StaticBody3D.new()
	var floor_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(100.0, 1.0, 100.0)
	floor_shape.shape = box
	floor_body.add_child(floor_shape)
	floor_body.position.y = -0.5
	world.add_child(floor_body)
	player = Player.new()
	world.add_child(player)
	# Synthetic controller settings, unrelated to any pending content changes.
	player.setup({
		"player": {
			"capsule_height": 1.8, "capsule_radius": 0.25,
			"walk_speed": WALK_SPEED, "run_speed": RUN_SPEED, "max_step": 0.3,
		},
		"camera": {
			"height_above_feet": 1.5, "distance_behind": 3.0,
			"mouse_turns": false, "pull_in_at_walls": false,
			"pitch_min_deg": -30.0, "pitch_max_deg": 30.0,
		},
	})
	player.enabled = true


func check_motion(actions: Array, direction: Vector2, speed: float, label: String) -> void:
	release_actions()
	for action in actions:
		Input.action_press(action)
	var before := horizontal_position()
	await frames(8)
	var displacement := horizontal_position() - before
	check(absf(horizontal_velocity().length() - speed) < 0.001, label + " respects the configured speed")
	check(displacement.length() > 0.05, label + " moves the physical capsule")
	check(displacement.normalized().dot(direction.normalized()) > 0.999, label + " travels in the expected world direction")


func _run() -> void:
	build_fixture()
	await frames(6)
	check(player.is_on_floor(), "the in-memory capsule settles on the physical floor")
	# Every diagonal must move as fast as a cardinal input, including while running.
	for item in [
		["move_left", "move_forward", Vector2(-1.0, -1.0)],
		["move_right", "move_forward", Vector2(1.0, -1.0)],
		["move_left", "move_back", Vector2(-1.0, 1.0)],
		["move_right", "move_back", Vector2(1.0, 1.0)],
	]:
		await check_motion([item[0], item[1]], item[2], WALK_SPEED, str(item[0]) + "/" + str(item[1]) + " walk")
		await check_motion([item[0], item[1], "run"], item[2], RUN_SPEED, str(item[0]) + "/" + str(item[1]) + " run")
	# Turning the view changes movement direction, without changing speed.
	player.yaw = PI / 2.0
	await check_motion(["move_forward"], Vector2.LEFT, WALK_SPEED, "quarter-turn forward")
	player.yaw = PI
	await check_motion(["move_forward", "run"], Vector2.DOWN, RUN_SPEED, "half-turn forward run")
	player.yaw = 0.0
	release_actions()
	for action in ACTIONS:
		Input.action_press(action)
	var before := horizontal_position()
	await frames(3)
	check(horizontal_velocity().is_zero_approx(), "opposing held inputs cancel even with run held")
	check(horizontal_position().distance_to(before) < 0.001, "opposing inputs leave the capsule in place")
	release_actions()
	Input.action_press("move_forward")
	Input.action_press("run")
	await frames(3)
	check(horizontal_velocity().length() > WALK_SPEED, "held run input moves before input is disabled")
	player.enabled = false
	before = horizontal_position()
	await frames(4)
	check(horizontal_velocity().is_zero_approx(), "disabled input stops horizontal velocity with keys still held")
	check(horizontal_position().distance_to(before) < 0.001, "disabled input prevents physical movement with keys still held")
	player.enabled = true
	await frames(3)
	check(horizontal_velocity().is_equal_approx(Vector2(0.0, -RUN_SPEED)), "enabling input resumes the still-held run direction")
	release_actions()
	before = horizontal_position()
	await frames(3)
	check(horizontal_velocity().is_zero_approx(), "releasing input stops horizontal velocity")
	check(horizontal_position().distance_to(before) < 0.001, "releasing input leaves no horizontal drift")
	# Only in-memory nodes are freed. The runner never creates or removes disk fixtures.
	world.queue_free()
	await process_frame
	print("PLAYER MOVEMENT TESTS: ", checks - failures, "/", checks, " passed; failures=", failures)
	quit(0 if failures == 0 else 1)
