extends KinematicBody

const SNAP_EPSILON = -0.01

enum LockAxis{
	NONE = 0,
	X = 1,
	Y = 1 << 1,
	Z = 1 << 2
}

export(int, FLAGS, "Lock X", "Lock Y", "Lock Z") var path_axis_lock: int = LockAxis.Y

var path: Path setget set_path
var velocity: Vector3

var _offset: float
var _loop: bool


func move_along_path(delta: float, speed: float) -> void:
	if not is_instance_valid(path):
		push_error("Failed to move along path. Path not set.")
		return
	
	if not is_zero_approx(speed):
		var position_in_path_local := path.to_local(global_transform.origin)
		var closest_offset := path.curve.get_closest_offset(position_in_path_local)
		var next_point := path.curve.interpolate_baked(closest_offset + sign(speed))
		var motion_dir := global_transform.origin.direction_to(next_point)
		
		# Snap to closest offset if collision occurs in direction of motion
		# Prevents offset point from moving too far away from body during collision.
		for i in get_slide_count():
			var collision := get_slide_collision(i)

			if _dot_product_axis_lock(collision.normal, motion_dir) < SNAP_EPSILON:
				_offset = closest_offset
				break
	
	for i in get_slide_count():
		_integrate(delta, get_slide_collision(i))
		
	_increment_offset(speed * delta)
	
	var displacement := path.curve.interpolate_baked(_offset, true) - global_transform.origin
	var velocity_along_path := displacement / delta
	
	# Update non-locked velocity components
	for axis in 3:
		if not _is_axis_locked(axis):
			velocity[axis] = velocity_along_path[axis]

	velocity = move_and_slide(velocity)


func get_path_direction() -> Vector3:
	if not is_instance_valid(path):
		push_error("Failed to get path direction. Path not set.")
		return Vector3.ZERO
	
	var p1 := path.curve.interpolate_baked(_offset)
	var p2 := path.curve.interpolate_baked(_offset + 0.001)
	return p1.direction_to(p2)


func set_path(new_path: Path) -> void:
	if new_path != null and path != new_path:
		var last_point_index := new_path.curve.get_point_count() - 1
		var first_point = new_path.curve.get_point_position(0)
		var last_point = new_path.curve.get_point_position(last_point_index)
		
		_offset = new_path.curve.get_closest_offset(global_transform.origin)
		_loop = first_point.is_equal_approx(last_point)
		
	path = new_path


func _increment_offset(increment: float) -> void:
	_offset += increment

	if _loop:
		_offset = wrapf(_offset, 0, path.curve.get_baked_length())
	else:
		_offset = clamp(_offset, 0, path.curve.get_baked_length())


func _is_axis_locked(axis: int) -> bool:
	return path_axis_lock & (1 << axis) != 0
	
	
func _dot_product_axis_lock(vec1: Vector3, vec2: Vector3) -> float:
	var dot_product := 0.0
	
	for axis in 3:
		if not _is_axis_locked(axis):
			dot_product += vec1[axis] * vec2[axis]
	
	return dot_product
	
	
func _vector_axis_lock(vector: Vector3) -> Vector3:
	for axis in 3:
		if _is_axis_locked(axis):
			vector[axis] = 0
	return vector
	

func _integrate(delta: float, collision: KinematicCollision) -> void:
	# No default integrate yet but the idea here is when collisions occur
	# You can translate changes in motion to changes in offset.
	pass
