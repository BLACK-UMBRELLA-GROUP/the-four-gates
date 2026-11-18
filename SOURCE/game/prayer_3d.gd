extends Node3D
## LOCK 99: a timed sequence of placeholder poses, with no saved effects.

signal finished

# The prayer camera sees only its placeholders. Existing cameras never see the
# stage because it is hidden whenever its camera is inactive.
const STAGE_LAYER := 1 << 19
enum Pose { TAKBIR, STANDING, BOWING, STANDING_UP, PROSTRATION, SITTING, SECOND_PROSTRATION, CLOSING }

var slots: Array[Vector2i] = []
var positions: Array
var position_index := -1
var camera: Camera3D

var _rows: int
var _per_row: int
var _height: float
var _radius: float
var _participants: Array[Node3D] = []
var _imam: Node3D
var _player_material: StandardMaterial3D
var _regular_material: StandardMaterial3D
var _stage_mesh: CapsuleMesh
var _gesture_mesh: CapsuleMesh
var _elapsed := 0.0
var _remaining := 0.0


func setup(prayer: Dictionary, player: Dictionary) -> void:
	hide()
	positions = prayer.positions
	_rows = int(prayer.rows)
	_per_row = int(prayer.per_row)
	_height = float(player.capsule_height)
	_radius = float(player.capsule_radius)
	_player_material = _material(Color("e6c78e"))
	_regular_material = _material(Color("9c664a"))
	_stage_mesh = CapsuleMesh.new()
	_stage_mesh.height = _height
	_stage_mesh.radius = _radius
	_gesture_mesh = CapsuleMesh.new()
	_gesture_mesh.height = _radius
	_gesture_mesh.radius = _radius / 3.0
	_imam = _figure()
	_imam.position.z = -_row_spacing()
	var middle := slot_for(0).x
	for index in _rows * _per_row:
		var participant := _figure()
		var slot := slot_for(index)
		participant.position = Vector3((slot.x - middle) * _radius * 2.0, 0.0, slot.y * _row_spacing())
		_participants.append(participant)
	camera = Camera3D.new()
	camera.cull_mask = STAGE_LAYER
	add_child(camera)


func slot_for(index: int) -> Vector2i:
	var place := index % _per_row
	var middle := floori(_per_row / 2.0)
	var distance := floori((place + 1) / 2.0)
	var column := middle + distance if place % 2 == 1 else middle - distance
	return Vector2i(column, floori(float(index) / _per_row))


func start(regular_count: int) -> void:
	var player_index := clampi(regular_count, 0, _participants.size() - 1)
	slots.clear()
	for index in _participants.size():
		var participant := _participants[index]
		participant.visible = index <= player_index
		if participant.visible:
			slots.append(slot_for(index))
			_set_material(participant, _player_material if index == player_index else _regular_material)
	_elapsed = 0.0
	_remaining = 0.0
	_enter_position(0)
	_move_camera()
	show()
	camera.make_current()


func advance(delta: float) -> void:
	if position_index < 0:
		return
	_elapsed += delta
	_remaining -= delta
	while _remaining <= 0.0:
		var next := position_index + 1
		if next >= positions.size():
			skip()
			return
		_enter_position(next)
	_move_camera()


func skip() -> void:
	if position_index < 0:
		return
	hide()
	position_index = -1
	_remaining = 0.0
	slots.clear()
	finished.emit()


func _enter_position(index: int) -> void:
	position_index = index
	_remaining += float(positions[index][2])
	_pose(_imam, index)
	for slot in slots.size():
		_pose(_participants[slot], index)


func _pose(figure: Node3D, pose_index: int) -> void:
	var body := figure.get_child(0) as MeshInstance3D
	var pitch := 0.0
	var height_scale := 1.0
	match pose_index:
		Pose.BOWING:
			pitch = -PI / 3.0
		Pose.PROSTRATION, Pose.SECOND_PROSTRATION:
			pitch = -PI / 2.0
		Pose.SITTING, Pose.CLOSING:
			height_scale = 0.6
	body.rotation.x = pitch
	body.scale.y = height_scale
	body.position.y = (_radius + (_height / 2.0 - _radius) * cos(pitch)) * height_scale
	(figure.get_child(1) as MeshInstance3D).visible = pose_index == Pose.TAKBIR
	(figure.get_child(2) as MeshInstance3D).visible = pose_index == Pose.TAKBIR


func _move_camera() -> void:
	var rise := smoothstep(0.0, float(positions[0][2]), _elapsed)
	var back_row := (_rows - 1) * _row_spacing()
	camera.position = Vector3(0.0, lerpf(_height, _height * 4.0, rise), back_row + _per_row * _radius * 2.0)
	camera.look_at(Vector3(0.0, _height / 2.0, back_row / 2.0))


func _row_spacing() -> float:
	return _height + _radius * 2.0


func _figure() -> Node3D:
	var figure := Node3D.new()
	add_child(figure)
	var body := _capsule(_stage_mesh)
	figure.add_child(body)
	for side in [-1, 1]:
		var hand := _capsule(_gesture_mesh)
		hand.position = Vector3(side * _radius, _height - _radius, -_radius)
		figure.add_child(hand)
	_set_material(figure, _regular_material)
	return figure


func _capsule(mesh: CapsuleMesh) -> MeshInstance3D:
	var capsule := MeshInstance3D.new()
	capsule.mesh = mesh
	capsule.layers = STAGE_LAYER
	capsule.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return capsule


func _set_material(figure: Node3D, material: StandardMaterial3D) -> void:
	for capsule: MeshInstance3D in figure.get_children():
		capsule.material_override = material


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
