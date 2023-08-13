@tool
@icon("grid2d.svg")
class_name Grid2D
extends Node2D
## Generic grid that goes along the X and Y axis.
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
## but allows setting values in any cells.
@export var infinite: bool = false :
	set(value):
		infinite = value
		reset()
@export var _regions: Array[Rect2i] = [Rect2i(0, 0, 16, 16)] :
	set(value):
		_regions = value
		reset()
## Cell size as (x, y).
@export var cell_size: Vector2i = Vector2i(16, 16) :
	set(value):
		cell_size = value
		queue_redraw()
@export_group("Debug", "debug_")
## Draws the grid with option value and position labels.
@export var debug_enabled := false :
	set(value):
		debug_enabled = value
		queue_redraw()
@export var debug_editor_only := false :
	set(value):
		debug_editor_only = value
		queue_redraw()
@export var debug_grid_color := Color("ffffffbf") :
	set(value):
		debug_grid_color = value
		queue_redraw()
## Shows labels for every cell that show the cell position and its value.
@export var debug_show_labels := true :
	set(value):
		debug_show_labels = value
		queue_redraw()
@export var debug_font: Font :
	set(value):
		if value == null:
			# Only way to get the default font.
			var label = Label.new()
			value = label.get_theme_font("")
			label.queue_free()
		debug_font = value
		queue_redraw()
@export_range(0, 1, 1, "or_greater") var debug_font_size: float = 12.0 :
	set(value):
		debug_font_size = value
		queue_redraw()

var _grid: Dictionary


func _ready() -> void:
	if debug_font == null:
		var label = Label.new()
		debug_font = label.get_theme_font("")
		label.queue_free()

	reset()


## Resets the grid to all cells in [param regions]
## or to empty if [param infinite] is [code]true[/code].
func reset() -> void:
	_grid.clear()

	if not infinite:
		for region in _regions:
			add_region(region)

	queue_redraw()


# --- Values ---


## Sets [param cell] to [param value].
func set_value(cell: Vector2i, value) -> void:
	if not has_cell(cell) and not infinite:
		push_error("Attempted to set %s to %s in %s, but the cell doesn't exist" % [cell, value, name])
		return

	_grid[cell] = value
	value_set.emit(cell, value)
	grid_changed.emit(_grid)


## Sets the ([param x], [param y]) cell to [param value].
func set_valuexy(x: int, y: int, value) -> void:
	set_value(Vector2i(x, y), value)


## Sets all cells in [param cells] to [param value].
func set_values(cells: Array[Vector2i], value) -> void:
	for cell in cells:
		set_value(cell, value)


## Returns the value in [param cell].
## Returns [code]null[/code] and pushes an error if the cell doesn't exist.
func get_value(cell: Vector2i):
	if not has_cell(cell):
		push_error("Attempted to get value at %s in %s, but the cell doesn't exist" % [cell, name])
		return null

	return _grid[cell]


## Returns the value in the ([param x], [param y]) cell.
## Returns [code]null[/code] and pushes an error if the cell doesn't exist.
func get_valuexy(x: int, y: int):
	return get_value(Vector2i(x, y))


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


## Adds a cell at ([param x], [param y]) with a value of null.
func add_cellxy(x: int, y: int) -> void:
	add_cell(Vector2i(x, y))


## Erases [param cell] from the grid.
func erase_cell(cell: Vector2i) -> void:
	if not has_cell(cell):
		return
	_grid.erase(cell)
	grid_changed.emit(_grid)
	cell_erased.emit(cell)


## Erases the ([param x], [param y]) cell from the grid.
func erase_cellxy(x: int, y: int) -> void:
	erase_cell(Vector2i(x, y))


# --- Regions ---


## Adds a [param region] (without resetting any values).
func add_region(region: Rect2i) -> void:
	var x_range = range(region.position.x, region.position.x + region.size.x)
	var y_range = range(region.position.y, region.position.y + region.size.y)
	for x in x_range:
		for y in y_range:
			if has_cellxy(x, y):
				continue

			add_cellxy(x, y)


## Erases all cells in [param region].
func erase_region(region: Rect2i) -> void:
	var x_range = range(region.position.x, region.position.x + region.size.x)
	var y_range = range(region.position.y, region.position.y + region.size.y)
	for x in x_range:
		for y in y_range:
			if not has_cellxy(x, y):
				continue

			erase_cellxy(x, y)


# --- Checks ---


## Returns [code]true[/code] if [param cell] exists in the grid.
func has_cell(cell: Vector2i) -> bool:
	return _grid.keys().has(cell)


## Returns [code]true[/code] if the ([param x], [param y]) cell exists in the grid.
func has_cellxy(x: int, y: int) -> bool:
	return has_cell(Vector2i(x, y))


## Returns [code]true[/code] if all [param cells] exist in the grid.
func has_cells(cells: Array[Vector2i]) -> bool:
	for cell in cells:
		if not has_cell(cell):
			return false

	return true


## Returns [code]true[/code] if the value in [param cell] is
## [code]null[/code] or if the cell doesn't exist.
func is_value_null(cell: Vector2i) -> bool:
	return get_value(cell) == null


## Returns [code]true[/code] if the value in the ([param x], [param y]) cell
## is [code]null[/code] or if the cell doesn't exist.
func is_value_nullxy(x: int, y: int) -> bool:
	return is_value_null(Vector2i(x, y))


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
func world_to_map(pos: Vector2) -> Vector2i:
	return Vector2i((pos - position) / Vector2(cell_size))


## Returns the position of the top left corner of the [param cell] in the world.
func map_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell * cell_size) + position


## Returns the position of the center of the [param cell] in the world.
func map_to_world_centered(cell: Vector2i) -> Vector2:
	return map_to_world(cell) + Vector2(cell_size) / 2


## Returns the position of the top left corner of the [param cell] relative to the [Grid2D]'s position.
func local_map_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell * cell_size)


## Returns the position of the center of the [param cell] relative to the [Grid2D]'s position.
func local_map_to_world_centered(cell: Vector2i) -> Vector2:
	return local_map_to_world(cell) + Vector2(cell_size) / 2


# --- Drawing ---


func _draw() -> void:
	if not Engine.is_editor_hint() and debug_editor_only:
		return

	if not debug_enabled:
		return

	for cell in _grid.keys():
		var cell_in_world = local_map_to_world(cell)
		var rect: Rect2 = Rect2(cell_in_world, cell_size)

		draw_rect(rect, debug_grid_color, false)

		if not debug_show_labels:
			continue

		var y_offset: float = cell_size.y * 0.5
		var string_pos: Vector2 = cell_in_world + Vector2(0, y_offset)
		var value_string_pos: Vector2 = string_pos + Vector2(0, debug_font_size)

		# Position string and value string below it.
		draw_string(debug_font, string_pos,
					str(cell), HORIZONTAL_ALIGNMENT_CENTER,
					cell_size.x, debug_font_size, debug_grid_color)
		draw_string(debug_font, value_string_pos,
					str(_grid[cell]), HORIZONTAL_ALIGNMENT_CENTER,
					cell_size.x, debug_font_size, debug_grid_color)
