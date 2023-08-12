class_name Building
extends Node3D


enum Dir {DOWN, LEFT, UP, RIGHT}

@export var size: Vector2i = Vector2i.ONE


func get_cells(origin: Vector2i, dir: Dir) -> Array[Vector2i]:
	var cells: Array[Vector2i]

	match dir:
		Dir.DOWN, Dir.UP:
			for x in size.x:
				for z in size.y:
					cells.append(origin + Vector2i(x, z))
		Dir.LEFT, Dir.RIGHT:
			for x in size.y:
				for z in size.x:
					cells.append(origin + Vector2i(x, z))

	return cells


func get_rotation_angle(dir: Dir) -> float:
	match dir:
		Dir.DOWN: return 0.0
		Dir.LEFT: return deg_to_rad(90)
		Dir.UP: return deg_to_rad(180)
		Dir.RIGHT, _: return deg_to_rad(270)


# Has to offset by certain amount when rotating. In cell units.
func get_dir_offset(dir: Dir) -> Vector2i:
	match dir:
		Dir.DOWN: return Vector2i.ZERO
		Dir.LEFT: return Vector2i(0, size.x)
		Dir.UP: return Vector2i(size.x, size.y)
		Dir.RIGHT, _: return Vector2i(size.y, 0)
