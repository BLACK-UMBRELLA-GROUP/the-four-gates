extends Node3D
## Camera and lighting controls for the Founder-named, disposable look test.

const CaptureHelper = preload("res://look_test/capture_helper.gd")
const SHOTS: Array[String] = ["Street", "Gate", "River", "Market"]
@onready var camera: Camera3D = $Camera3D
@onready var environment: Environment = $Environment.environment
var time_of_day: String = "day"
var capturing: bool = false
var capture_helper: RefCounted

func _ready() -> void:
	set_shot("Street")
	set_time_of_day("day")
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if "--capture" in args or "--measure" in args or "--check-controls" in args:
		capturing = true
		capture_helper = CaptureHelper.new()
		capture_helper.run.call_deferred(self, args)

func set_shot(shot: String) -> void:
	var marker: Marker3D = get_node("Shots/" + shot)
	camera.global_transform = marker.global_transform
	camera.fov = 58.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func set_time_of_day(mode: String) -> void:
	time_of_day = mode
	var phase: float = 0.0 if mode == "day" else (1.0 if mode == "night" else 0.5)
	(environment.sky.sky_material as ShaderMaterial).set_shader_parameter("phase", phase)
	$Sun.visible = mode != "night"
	$Sun.light_energy = 1.15 if mode == "day" else 0.38
	$Sun.light_color = Color(1.0, 0.84, 0.66) if mode == "day" else Color(1.0, 0.51, 0.28)
	$Sun.rotation_degrees = Vector3(-38, -32, 0) if mode == "day" else Vector3(-8, -42, 0)
	$MoonLight.visible = mode != "day"
	$MoonLight.light_energy = 0.34 if mode == "night" else 0.12
	$MoonLight.light_color = Color(0.49, 0.62, 1.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.81, 0.87) if mode == "day" else Color(0.28, 0.36, 0.65)
	environment.ambient_light_energy = 0.42 if mode == "day" else (0.22 if mode == "night" else 0.30)
	environment.fog_enabled = true
	environment.fog_sky_affect = 0.0
	environment.fog_density = 0.003 if mode == "day" else 0.004
	environment.fog_light_color = Color(0.72, 0.64, 0.53) if mode == "day" else Color(0.12, 0.17, 0.30)
	environment.fog_light_energy = 0.55
	environment.glow_enabled = true
	environment.glow_intensity = 0.65
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.ssao_enabled = true
	environment.ssil_enabled = true
	for light: Node in $Lanterns.find_children("*", "OmniLight3D", true, false):
		(light as OmniLight3D).light_energy = 0.10 if mode == "day" else (3.2 if mode == "night" else 2.0)
		(light as OmniLight3D).light_size = 0.25

func _unhandled_input(event: InputEvent) -> void:
	if capturing:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera.rotation.y -= event.relative.x * 0.0025
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * 0.0025, -1.50, 1.50)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		for index: int in range(4):
			if event.keycode == KEY_F1 + index:
				set_shot(SHOTS[index])
		if event.keycode == KEY_F5:
			set_time_of_day("day")
		if event.keycode == KEY_F6:
			set_time_of_day("night")
		if event.keycode == KEY_F7:
			set_time_of_day("dusk")

func _process(delta: float) -> void:
	if capturing:
		return
	var direction: Vector3 = Vector3.ZERO
	direction.z = float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	direction.x = float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
	direction.y = float(Input.is_physical_key_pressed(KEY_E)) - float(Input.is_physical_key_pressed(KEY_Q))
	var speed: float = 10.0 if Input.is_physical_key_pressed(KEY_SHIFT) else 4.0
	camera.position += camera.basis * direction.normalized() * speed * minf(delta, 0.1)
