@tool
@icon("grid3d.svg")
class_name Grid3D
extends Node3D
## Generic grid that goes along the X and Z axis.
##
## Cells can contain values of any kind. If not [param infinite],
## it will generate cells based on [param regions] and will set them
## all to null.[br]Used for quickly making grid-based systems.


signal value_set(cell: Vector2i, value)
## Emitted when the grid is changed in any way, either by removing or adding
## cells or modifying a cell's value.
signal grid_changed(new_grid: Dictionary)
signal cell_added(cell: Vector2i)
signal cell_erased(cell: Vector2i)


## If true, ignores [param regions] and doesn't initialize with any cells,
## but allows setting values in any cell.
@export var infinite: bool = false :
	set(value):
		infinite = value
		reset()
@export var _regions: Array[Rect2i] = [Rect2i(0, 0, 16, 16)] :
	set(value):
		_regions = value
		reset()
## Cell size as (x, z).
@export var cell_size: Vector2i = Vector2i(2, 2)

var _grid: Dictionary


func _ready() -> void:
	reset()


## Resets the grid to all cells in [param regions]
## or to empty if [param infinite] is [code]true[/code].
func reset() -> void:
	_grid.clear()

	if infinite:
		return

	for region in _regions:
		add_region(region)


# --- Values ---


## Sets [param cell] to [param value]
func set_value(cell: Vector2i, value) -> void:
	if not has_cell(cell) and not infinite:
		push_warning("%s is out of %s's bounds" % [cell, name])
		return

	_grid[cell] = value
	value_set.emit(cell, value)
	grid_changed.emit(_grid)


## Sets the ([param x], [param z]) cell to [param value].
func set_valuexz(x: int, z: int, value) -> void:
	set_value(Vector2i(x, z), value)


## Sets all cells in [param cells] to [param value]
func set_values(cells: Array[Vector2i], value) -> void:
	for cell in cells:
		set_value(cell, value)


## Returns the value in [param cell].
## Returns [code]null[/code] and pushes an error if the cell doesn't exist.
func get_value(cell: Vector2i):
	if not has_cell(cell):
		if not infinite:
			push_warning("%s is out of %s's bounds" % [cell, name])
		return null

	return _grid[cell]


## Returns the value in the ([param x], [param z]) cell.
## Returns [code]null[/code] and pushes an error if the cell doesn't exist.
func get_valuexz(x: int, z: int):
	return get_value(Vector2i(x, z))


# --- Cells ---


## Returns a [code]Dictionary[/code] with the positions and values of the cells.
func get_cells() -> Dictionary:
	return _grid


## Adds [param cell] to the grid with a value of null.
func add_cell(cell: Vector2i) -> void:
	if has_cell(cell):
		return
	_grid[cell] = null
	grid_changed.emit(_grid)
	cell_added.emit(cell)


## Adds a cell at ([param x], [param z]) with a value of null.
func add_cellxz(x: int, z: int) -> void:
	add_cell(Vector2i(x, z))


## Erases [param cell] from the grid.
func erase_cell(cell: Vector2i) -> void:
	if not has_cell(cell):
		return
	_grid.erase(cell)
	grid_changed.emit(_grid)
	cell_erased.emit(cell)


## Erases the ([param x], [param z]) cell from the grid.
func erase_cellxz(x: int, z: int) -> void:
	erase_cell(Vector2i(x, z))


# --- Regions ---


## Adds a [param region] (without resetting any values).
func add_region(region: Rect2i) -> void:
	var x_range = range(region.position.x, region.position.x + region.size.x)
	var z_range = range(region.position.y, region.position.y + region.size.y)
	for x in x_range:
		for z in z_range:
			if has_cellxz(x, z):
				continue

			add_cellxz(x, z)


## Erases all cells in [param region].
func erase_region(region: Rect2i) -> void:
	var x_range = range(region.position.x, region.position.x + region.size.x)
	var z_range = range(region.position.y, region.position.y + region.size.y)
	for x in x_range:
		for z in z_range:
			if not has_cellxz(x, z):
				continue

			erase_cellxz(x, z)


# --- Checks ---


## Returns [code]true[/code] if [param cell] exists in the grid.
func has_cell(cell: Vector2i) -> bool:
	return _grid.keys().has(cell)


## Returns [code]true[/code] if the ([param x], [param z]) cell exists in the grid.
func has_cellxz(x: int, z: int) -> bool:
	return has_cell(Vector2i(x, z))


## Returns [code]true[/code] if all [param cells] exist in the grid.
func has_cells(cells: Array[Vector2i]) -> bool:
	for cell in cells:
		if not has_cell(cell):
			return false

	return true


## Returns [code]true[/code] if the value in [param cell]
## is [code]null[/code] or if the cell doesn't exist.
func is_value_null(cell: Vector2i) -> bool:
	return get_value(cell) == null


## Returns [code]true[/code] if the value in the ([param x], [param z]) cell
## is [code]null[/code] or if the cell doesn't exist.
func is_value_nullxz(x: int, z: int) -> bool:
	return is_value_null(Vector2i(x, z))


## Returns true if all values in the [param cells] are equal to null.
func are_values_null(cells: Array[Vector2i]) -> bool:
	for cell in cells:
		if not is_value_null(cell):
			return false

	return true


## Returns true if all values in the [param cells] are equal to [value].
func are_values_equal(cells: Array[Vector2i], value) -> bool:
	for cell in cells:
		if not get_value(cell) == value:
			return false

	return true


# --- Positions ---


## Returns the cell in [param pos].
func world_to_map(pos: Vector3) -> Vector2i:
	var pos_2d: Vector2 = Vector2(pos.x - position.x, pos.z - position.z)
	return Vector2i(pos_2d / Vector2(cell_size))


## Returns the position of the top left corner of the [param cell] in the world.
func map_to_world(cell: Vector2i) -> Vector3:
	return Vector3(cell.x * cell_size.x, 0, cell.y * cell_size.y) + position


## Returns the position of the center of the [param cell] in the world.
func map_to_world_centered(cell: Vector2i) -> Vector3:
	return map_to_world(cell) + Vector3(cell_size.x / 2, 0, cell_size.y / 2)


## Returns the position of the top left corner of the [param cell] relative to the [Grid2D]'s position.
func local_map_to_world(cell: Vector2i) -> Vector3:
	return Vector3(cell.x * cell_size.x, position.y, cell.y * cell_size.y)


## Returns the position of the center of the [param cell] relative to the [Grid2D]'s position.
func local_map_to_world_centered(cell: Vector2i) -> Vector3:
	return local_map_to_world(cell) + Vector3(cell_size.x / 2, 0, cell_size.y / 2)
