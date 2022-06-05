extends "res://src/path_traversal/kinematic_path_traveler.gd"

const PathSwitch = preload("res://src/path_traversal/path_switch.gd")

export var move_speed: float = 20
var gravity: float = -3

onready var mesh: CSGMesh = get_node("CSGMesh")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity
	
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = 50
	
	if path != null:
		var move_dir := Input.get_axis("ui_left", "ui_right")
		var path_dir := get_path_direction()
		var look_at_target := translation + path_dir.rotated(Vector3.UP, PI/2)
		
		if translation != look_at_target:
			look_at(look_at_target, Vector3.UP)
		
		if move_dir == 0:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
		else:
			mesh.scale.x = sign(move_dir)
			
		move_along_path(delta, move_speed * move_dir)


func _on_PathFinder_area_entered(area: Area):
	if area is PathSwitch:
		set_path(area.get_path_node())
