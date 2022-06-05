tool
extends Area
## This is just an Area that looks for a path child
## The patch switching system is pretty simple

onready var _path: Path = _find_path()

func _get_configuration_warning() -> String:
	var warning := ""
	if _find_path() == null:
		warning += "Path switch does not contain path."
	return warning


func get_path_node() -> Path:
	return _path
	

func _find_path() -> Path:
	for child in get_children():
		if child is Path:
			return child
	return null
