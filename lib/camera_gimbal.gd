tool
extends Spatial

export var target: NodePath setget set_target
export var orientation: Vector3
export var pan: Vector2
export var zoom: float = 10
export var rotation_tween_duration: float = .15
export var pan_tween_duration: float = .15
export var zoom_tween_duration: float = .15
export var position_tween_duration: float = .15

var _target: Spatial
var _tween := Tween.new()

onready var _camera: Camera = _find_camera()
onready var _pitch_axis := Position3D.new()
onready var _yaw_axis := Position3D.new()
onready var _roll_axis := Position3D.new()
onready var _camera_position := Position3D.new()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	set_target(target)
	add_child(_tween)
	add_child(_pitch_axis)
	_pitch_axis.add_child(_yaw_axis)
	_yaw_axis.add_child(_roll_axis)
	_roll_axis.add_child(_camera_position)
	
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if _camera != null:
		_camera.set_as_toplevel(true)
		_camera.global_transform = _camera_position.global_transform
	
	if _target != null:
		var rotation_diff := _target.rotation - orientation
		var current_orient := _get_orientation()
		var final_orient := Vector3(
			lerp_angle(current_orient.x, rotation_diff.x, 1),
			lerp_angle(current_orient.y, rotation_diff.y, 1),
			lerp_angle(current_orient.z, rotation_diff.z, 1)
		)
		
		_tween.interpolate_method(
			self, 
			"_set_orientation", 
			current_orient, 
			final_orient, 
			rotation_tween_duration)
		
		_tween.interpolate_method(
			self,
			"_set_zoom",
			_get_zoom(),
			zoom,
			zoom_tween_duration
		)
		
		_tween.interpolate_method(
			self,
			"_set_pan",
			_get_pan(),
			pan,
			pan_tween_duration
		)
		
		_tween.interpolate_property(
			self, 
			"global_transform:origin",
			global_transform.origin,
			_target.global_transform.origin, 
			position_tween_duration)
		
		_tween.start()
		
		
func _get_configuration_warning() -> String:
	var warning := ""
	if _find_camera() == null:
		warning += "No camera added as child."

	return warning
	

func set_target(value: NodePath) -> void:
	var node := get_node_or_null(value)
	
	if not node is Spatial and is_instance_valid(node):
		push_error("Failed to set target. Target must be of type Spatial.")
		target = ""
		return
		
	target = value
	_target = node
	
	
func _get_orientation() -> Vector3:
	return Vector3(
		_yaw_axis.rotation.x, 
		_pitch_axis.rotation.y, 
		_roll_axis.rotation.z)
	

func _set_orientation(orient: Vector3) -> void:
	_yaw_axis.rotation.x = orient.x
	_pitch_axis.rotation.y = orient.y
	_roll_axis.rotation.z = orient.z


func _get_zoom() -> float:
	return _camera_position.translation.z


func _set_zoom(camera_zoom: float) -> void:
	_camera_position.translation.z = camera_zoom


func _get_pan() -> Vector2:
	var camera_pos := _camera_position.translation
	return Vector2(camera_pos.x, camera_pos.y)


func _set_pan(camera_pan: Vector2) -> void:
	_camera_position.translation.x = camera_pan.x
	_camera_position.translation.y = camera_pan.y
	
	
func _find_camera() -> Camera:
	for child in get_children():
		if child is Camera:
			return child
	return null
