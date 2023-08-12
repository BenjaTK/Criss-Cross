@tool
extends Node2D


@export var size: Vector2i = Vector2i(16, 16) : set = set_size
@export var cell_size: Vector2i = Vector2i(16, 16) :
	set(value):
		cell_size = value
		queue_redraw()
@export_group("Debug", "debug_")
## Draws the grid when in-game.
## Will draw the grid in-editor if the node is selected.
@export var debug_enabled := false :
	set(value):
		debug_enabled = value
		queue_redraw()
@export var debug_grid_color := Color("ffffffbf") :
	set(value):
		debug_grid_color = value
		queue_redraw()
@export var debug_show_labels := true :
	set(value):
		debug_show_labels = value
		queue_redraw()

var grid: Dictionary
var _debug_font: Font


func _ready() -> void:
	var label = Label.new()
	_debug_font = label.get_theme_font("")
	label.queue_free()

	reset()


func set_size(value: Vector2i) -> void:
	size = value
	reset()
	queue_redraw()


func reset() -> void:
	grid.clear()

	for x in size.x:
		for y in size.y:
			grid[Vector2i(x, y)] = null


# --- Values ---


## Sets [param cell] to [param value]
func set_value(cell: Vector2i, value) -> void:
	if not has_cell(cell):
		push_warning("%s is out of %s's bounds" % [cell, name])
		return

	grid[cell] = value


func set_valuexy(x: int, y: int, value) -> void:
	set_value(Vector2i(x, y), value)


## Sets all cells in [param cells] to [param value]
func set_values(cells: Array[Vector2i], value) -> void:
	for cell in cells:
		set_value(cell, value)


func get_value(cell: Vector2i):
	if not has_cell(cell):
		push_warning("%s is out of %s's bounds" % [cell, name])
		return null

	return grid[cell]


func get_valuexy(x: int, y: int):
	return get_value(Vector2i(x, y))


# --- Checks ---

func has_cell(cell: Vector2i) -> bool:
	return grid.keys.has(cell)


func has_cellxy(x: int, y: int) -> bool:
	return has_cell(Vector2i(x, y))


# --- Positions ---


func world_to_map(pos: Vector2) -> Vector2i:
	return Vector2i((pos - position) / Vector2(cell_size))


func map_to_world_centered(cell: Vector2i) -> Vector2:
	return map_to_world(cell) + Vector2(cell_size) / 2


func map_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell * cell_size) + position


func local_map_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell * cell_size)


# --- Drawing ---


func _draw() -> void:
	if not debug_enabled:
		return

	for cell in grid.keys():
		var cell_in_world = local_map_to_world(cell)
		var rect: Rect2 = Rect2(cell_in_world, cell_size)

		draw_rect(rect, debug_grid_color, false)

		if debug_show_labels:
			var string: String = "%s\n%s" % [cell, grid[cell]]
			var label_font_size := min(cell_size.x * 0.5, 12)
			var y_offset: float = cell_size.y * 0.5
			var string_pos: Vector2 = cell_in_world + Vector2(0, y_offset)
			var value_string_pos: Vector2 = string_pos + Vector2(0, label_font_size)

			# Position string and value string below it.
			draw_string(_debug_font, string_pos,
						str(cell), HORIZONTAL_ALIGNMENT_CENTER,
						cell_size.x, label_font_size, debug_grid_color)
			draw_string(_debug_font, value_string_pos,
						str(grid[cell]), HORIZONTAL_ALIGNMENT_CENTER,
						cell_size.x, label_font_size, debug_grid_color)
