extends SceneTree
## Headless regressions for the legacy look-test controller, without game scenes.

const Controller = preload("res://look_test/camera.gd")
const SHOTS: Array[String] = ["Street", "Gate", "River", "Market"]
const SHOT_KEYS: Array[Key] = [KEY_F1, KEY_F2, KEY_F3, KEY_F4]
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", label)

func _key(controller: Node3D, code: Key, pressed: bool = true, echo: bool = false) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	event.echo = echo
	controller.call("_unhandled_input", event)

func _fixture() -> Node3D:
	var controller: Node3D = Controller.new()
	controller.position = Vector3(7, 2, -4)
	controller.rotation.y = 0.4
	var camera: Camera3D = Camera3D.new()
	camera.name = "Camera3D"
	controller.add_child(camera)
	var world: WorldEnvironment = WorldEnvironment.new()
	world.name = "Environment"
	world.environment = Environment.new()
	world.environment.sky = Sky.new()
	var shader: Shader = Shader.new()
	shader.code = "shader_type sky; uniform float phase = 0.0; void sky() { COLOR = vec3(phase); }"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	world.environment.sky.sky_material = material
	controller.add_child(world)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.name = "Sun"
	controller.add_child(sun)
	var moon: DirectionalLight3D = DirectionalLight3D.new()
	moon.name = "MoonLight"
	controller.add_child(moon)
	var lanterns: Node3D = Node3D.new()
	lanterns.name = "Lanterns"
	controller.add_child(lanterns)
	# Nested lanterns catch regressions in the controller's recursive light lookup.
	var bracket: Node3D = Node3D.new()
	lanterns.add_child(bracket)
	bracket.add_child(OmniLight3D.new())
	lanterns.add_child(OmniLight3D.new())
	var shots: Node3D = Node3D.new()
	shots.name = "Shots"
	controller.add_child(shots)
	for index: int in range(SHOTS.size()):
		var marker: Marker3D = Marker3D.new()
		marker.name = SHOTS[index]
		marker.position = Vector3(index * 3, index + 1, -index * 2)
		marker.rotation = Vector3(0.1 * index, 0.2 * index, 0)
		shots.add_child(marker)
	return controller

func _run() -> void:
	var controller: Node3D = _fixture()
	root.add_child(controller)
	# Test explicit keyboard dispatch without polling the host's physical keyboard.
	controller.set_process(false)
	controller.set_process_unhandled_input(false)
	var camera: Camera3D = controller.get_node("Camera3D") as Camera3D
	var sun: DirectionalLight3D = controller.get_node("Sun") as DirectionalLight3D
	var moon: DirectionalLight3D = controller.get_node("MoonLight") as DirectionalLight3D
	var world: WorldEnvironment = controller.get_node("Environment") as WorldEnvironment
	var sky: ShaderMaterial = world.environment.sky.sky_material as ShaderMaterial
	var lanterns: Array[Node] = controller.get_node("Lanterns").find_children("*", "OmniLight3D", true, false)
	_expect(camera.global_transform.is_equal_approx((controller.get_node("Shots/Street") as Marker3D).global_transform), "ready selects Street")
	_expect(controller.get("time_of_day") == "day", "ready selects day")
	var shot_fov: float = camera.fov
	for index: int in range(SHOTS.size()):
		camera.fov = 25.0
		_key(controller, SHOT_KEYS[index])
		var marker: Marker3D = controller.get_node("Shots/" + SHOTS[index]) as Marker3D
		_expect(camera.global_transform.is_equal_approx(marker.global_transform), SHOTS[index] + " shortcut uses full world transform")
		_expect(is_equal_approx(camera.fov, shot_fov), SHOTS[index] + " shortcut restores shot FOV")
	var selected: Transform3D = camera.global_transform
	_key(controller, KEY_F1, false)
	_key(controller, KEY_F2, true, true)
	_expect(camera.global_transform.is_equal_approx(selected), "released and echo shot keys are ignored")
	var daylight: float = (lanterns[0] as OmniLight3D).light_energy
	_key(controller, KEY_F6)
	_expect(controller.get("time_of_day") == "night", "F6 selects night")
	_expect(not sun.visible and moon.visible, "night hides sun and shows moon")
	_expect(is_equal_approx(float(sky.get_shader_parameter("phase")), 1.0), "night reaches sky endpoint")
	var night_light: float = (lanterns[0] as OmniLight3D).light_energy
	_expect(night_light > daylight, "night brightens lanterns")
	_key(controller, KEY_F7)
	_expect(controller.get("time_of_day") == "dusk", "F7 selects dusk")
	_expect(sun.visible and moon.visible, "dusk retains both celestial lights")
	var dusk_phase: float = float(sky.get_shader_parameter("phase"))
	_expect(dusk_phase > 0.0 and dusk_phase < 1.0, "dusk sky lies between day and night")
	for lantern: Node in lanterns:
		var energy: float = (lantern as OmniLight3D).light_energy
		_expect(energy > daylight and energy < night_light, "dusk updates direct and nested lanterns")
	_key(controller, KEY_F5, false)
	_key(controller, KEY_F6, true, true)
	_expect(controller.get("time_of_day") == "dusk", "released and echo lighting keys are ignored")
	controller.set("capturing", true)
	_key(controller, KEY_F1)
	_key(controller, KEY_F5)
	_expect(camera.global_transform.is_equal_approx(selected), "capture guard blocks shot shortcuts")
	_expect(controller.get("time_of_day") == "dusk", "capture guard blocks lighting shortcuts")
	controller.set("capturing", false)
	_key(controller, KEY_F5)
	_expect(controller.get("time_of_day") == "day", "F5 works again after capture guard clears")
	_expect(sun.visible and not moon.visible, "day restores celestial visibility")
	_expect(is_zero_approx(float(sky.get_shader_parameter("phase"))), "day restores sky endpoint")
	for lantern: Node in lanterns:
		_expect(is_equal_approx((lantern as OmniLight3D).light_energy, daylight), "day restores each lantern after mode roundtrip")
	controller.free()
	print("Look controls: ", checks - failures, "/", checks, " passed")
	quit(0 if failures == 0 else 1)
