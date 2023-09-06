extends Area2D


@export var grid: Grid2D
@export var size: Vector2i = Vector2i.ONE

var dragging := false
var _drag_start_pos: Vector2i
var occupied_cells: Array[Vector2i]
var tween: Tween

@onready var top_left_cell = Vector2i(0, 0) :
	set(value):
		var prev_cell = top_left_cell

		if grid.has_cells(_get_cells(value)):
			top_left_cell = value

		var world_pos := grid.map_to_world(top_left_cell)
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		tween.tween_property(self, "global_position", world_pos, 0.3)


func _ready() -> void:
	input_event.connect(_on_input_event)

	for x in size.x:
		for y in size.y:
			occupied_cells.append(Vector2i(x, y))

	_move_to(grid.world_to_map(global_position))


func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - _get_centered_offset()
		queue_redraw()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			_start_dragging()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if dragging:
				_stop_dragging()


func _start_dragging() -> void:
	tween.stop()
	z_index = 1
	dragging = true
	_drag_start_pos = top_left_cell

	grid.set_values(_get_cells(top_left_cell), null)
	grid.queue_redraw()


func _stop_dragging() -> void:
	z_index = 0
	dragging = false

	var target_cell := _get_mouse_top_left_cell()

	var target_cells := _get_cells(target_cell)
	if not grid.has_cells(target_cells) or not grid.are_values_null(target_cells):
		target_cell = _drag_start_pos

	_move_to(target_cell)
	queue_redraw()


func _move_to(cell: Vector2i) -> void:
	var target_cells := _get_cells(cell)
	if not grid.has_cells(target_cells) or not grid.are_values_null(target_cells):
		cell = _get_next_empty_cell_in_grid()

	top_left_cell = cell
	grid.set_values(_get_cells(top_left_cell), self)
	grid.queue_redraw()


func _get_centered_offset() -> Vector2:
	return (Vector2(size) * 0.5) * Vector2(grid.cell_size)

func _get_mouse_top_left_cell() -> Vector2i:
	return grid.world_to_map(get_global_mouse_position() + Vector2(grid.cell_size)/2.0 - _get_centered_offset())

# Get all cells the item will occupy based on its size.
func _get_cells(origin: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i]
	for occupied_cell in occupied_cells:
		cells.append(occupied_cell + origin)

	return cells


func _get_next_empty_cell_in_grid() -> Vector2i:
	for cell in grid.get_cells():
		if grid.is_value_null(cell):
			return cell

	return Vector2i(NAN, NAN)


func _draw() -> void:
	# Highlight cells the item will occupy.
	if dragging:
		var current_cell := _get_mouse_top_left_cell()
		if not grid.has_cells(_get_cells(current_cell)):
			return

		var rect_position := to_local(grid.map_to_world(current_cell))
		var rect_size := size * grid.cell_size
		draw_rect(Rect2(rect_position, rect_size), Color(1, 1, 1, 0.38823530077934))
