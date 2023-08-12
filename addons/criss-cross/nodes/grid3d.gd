@tool
extends Node3D


@export var size: Vector2i = Vector2i(16, 16) : set = set_size
@export var cell_size: Vector2i = Vector2i(16, 16)

var grid: Dictionary


func _ready() -> void:
	reset()


func set_size(value: Vector2i) -> void:
	size = value
	reset()


func reset() -> void:
	grid.clear()

	for x in size.x:
		for z in size.y:
			grid[Vector2i(x, z)] = null


# --- Values ---


## Sets [param cell] to [param value]
func set_value(cell: Vector2i, value) -> void:
	if not has_cell(cell):
		push_warning("%s is out of %s's bounds" % [cell, name])
		return

	grid[cell] = value


func set_valuexz(x: int, z: int, value) -> void:
	set_value(Vector2i(x, z), value)


## Sets all cells in [param cells] to [param value]
func set_values(cells: Array[Vector2i], value) -> void:
	for cell in cells:
		set_value(cell, value)


func get_value(cell: Vector2i):
	if not has_cell(cell):
		push_warning("%s is out of %s's bounds" % [cell, name])
		return null

	return grid[cell]


func get_valuexz(x: int, z: int):
	return get_value(Vector2i(x, z))


# --- Checks ---

func has_cell(cell: Vector2i) -> bool:
	return grid.keys.has(cell)


func has_cellxz(x: int, z: int) -> bool:
	return has_cell(Vector2i(x, z))


# --- Positions ---


func world_to_map(pos: Vector3) -> Vector2i:
	var pos_2d: Vector2 = Vector2(pos.x - position.x, pos.z - position.z)

	return Vector2i(pos_2d / Vector2(cell_size))


func map_to_world_centered(cell: Vector2i) -> Vector3:
	return map_to_world(cell) + Vector3(cell_size.x / 2, 0, cell_size.y / 2)


func map_to_world(cell: Vector2i) -> Vector3:
	return Vector3(cell.x * cell_size.x, position.y, cell.y * cell_size.y) + position


func local_map_to_world(cell: Vector2i) -> Vector3:
	return Vector3(cell.x * cell_size.x, position.y, cell.y * cell_size.y)
