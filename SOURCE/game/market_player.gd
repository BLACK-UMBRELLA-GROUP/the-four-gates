extends CharacterBody3D
## Feet-origin capsule controller. Gameplay dimensions come from the locked data.

var data: Dictionary
var camera: Camera3D
var arm: SpringArm3D
var camera_pivot: Node3D
var yaw := 0.0
var pitch := 0.0
var enabled := false
var walk_multiplier := 1.0
var test_move_axis := Vector2.ZERO
var test_running := false
var stepped_last_frame := false


func setup(source: Dictionary) -> void:
	data = source
	var capsule := CapsuleShape3D.new()
	capsule.height = data.player.capsule_height
	capsule.radius = data.player.capsule_radius
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = capsule.height / 2.0
	add_child(collision)
	var visual := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.height = capsule.height
	mesh.radius = capsule.radius
	visual.mesh = mesh
	visual.position.y = collision.position.y
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("e6c78e")
	visual.material_override = material
	add_child(visual)
	camera_pivot = Node3D.new()
	camera_pivot.position.y = data.camera.height_above_feet
	add_child(camera_pivot)
	arm = SpringArm3D.new()
	arm.spring_length = data.camera.distance_behind
	arm.margin = data.player.capsule_radius / 2.0
	arm.collision_mask = collision_mask
	arm.add_excluded_object(get_rid())
	var camera_shape := SphereShape3D.new()
	camera_shape.radius = data.player.capsule_radius / 2.0
	arm.shape = camera_shape
	camera_pivot.add_child(arm)
	camera = Camera3D.new()
	arm.add_child(camera)
	camera.current = true
	floor_snap_length = data.player.max_step
	update_camera()


func _unhandled_input(event: InputEvent) -> void:
	if not enabled or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion and data.camera.mouse_turns:
		apply_look(event.relative)


func apply_look(relative: Vector2) -> void:
	# The same relative-motion path is callable by the dummy-display test runner.
	var viewport := get_viewport().get_visible_rect().size
	yaw -= relative.x / viewport.x * TAU
	pitch -= relative.y / viewport.y * PI
	pitch = clampf(pitch, deg_to_rad(data.camera.pitch_min_deg), deg_to_rad(data.camera.pitch_max_deg))
	update_camera()


func update_camera() -> void:
	if camera_pivot == null:
		return
	camera_pivot.rotation = Vector3(pitch, yaw, 0.0)
	arm.collision_mask = collision_mask if data.camera.pull_in_at_walls else 0


func _physics_process(delta: float) -> void:
	if data.is_empty():
		return
	var axis := test_move_axis
	if enabled:
		axis += Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	axis = axis.limit_length()
	var speed: float = data.player.run_speed if test_running or (enabled and Input.is_action_pressed("run")) else float(data.player.walk_speed) * walk_multiplier
	var direction := Basis(Vector3.UP, yaw) * Vector3(axis.x, 0.0, axis.y)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	var supported := is_on_floor() or stepped_last_frame
	if not supported:
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0
	stepped_last_frame = false
	var motion := Vector3(velocity.x, 0.0, velocity.z) * delta
	if supported and not motion.is_zero_approx():
		_try_step(motion)
	move_and_slide()
	update_camera()


func _try_step(motion: Vector3) -> void:
	# A low obstacle is accepted only if the capsule fits above it and lands on top.
	var obstruction := KinematicCollision3D.new()
	if not test_move(global_transform, motion, obstruction):
		return
	# Physics clearance is added to the probe, then the actual landing height is
	# checked against the approved step limit before applying any movement.
	var rise := Vector3.UP * (float(data.player.max_step) + safe_margin * 2.0)
	if test_move(global_transform, rise):
		return
	var raised := global_transform
	raised.origin += rise
	if test_move(raised, motion):
		return
	raised.origin += motion
	var landing := KinematicCollision3D.new()
	if not test_move(raised, -rise, landing):
		return
	if landing.get_normal().y <= 0.0:
		return
	var step_height := landing.get_position().y - global_position.y
	if step_height > float(data.player.max_step) + safe_margin / 100.0:
		return
	var travelled_height := rise.y + landing.get_travel().y
	if travelled_height <= safe_margin:
		return
	global_position += rise + landing.get_travel()
	stepped_last_frame = true
