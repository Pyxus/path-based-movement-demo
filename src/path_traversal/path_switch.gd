tool
extends Area
## This is just an Area that looks for a path child
## A path traveler can then use an area to detect this switch and grab the path.
## The patch switching system here is pretty simple and just meant as a demonstration.

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
