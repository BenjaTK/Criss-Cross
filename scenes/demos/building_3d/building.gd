class_name Building
extends Node3D


enum Dir {DOWN, LEFT, UP, RIGHT}

@export var size: Vector2i = Vector2i.ONE

var occupied_cells: Array[Vector2i]


func get_cells(origin: Vector2i) -> Array[Vector2i]:
	_set_occupied_cells()
	var cells: Array[Vector2i]
	for occupied_cell in occupied_cells:
		cells.append(occupied_cell + origin)

	return cells


func _set_occupied_cells() -> void:
	for x in size.x:
		for z in size.y:
			occupied_cells.append(Vector2i(x, z))


func get_rotation_angle(dir: Dir) -> float:
	match dir:
		Dir.DOWN: return 0.0
		Dir.LEFT: return deg_to_rad(90)
		Dir.UP: return deg_to_rad(180)
		Dir.RIGHT, _: return deg_to_rad(270)


func get_dir_offset(dir: Dir) -> Vector2i:
	match dir:
		Dir.DOWN: return Vector2i.ZERO
		Dir.LEFT: return Vector2i(0, size.x)
		Dir.UP: return Vector2i(size.x, size.y)
		Dir.RIGHT, _: return Vector2i(size.y, 0)
