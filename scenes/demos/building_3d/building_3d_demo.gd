extends Node3D


@export var buildings: Array[PackedScene]

var current_building: PackedScene :
	set(value):
		current_building = value
		if not self.is_node_ready(): # Required to make preview work.
			await self.ready

		# Update preview.
		if preview_building != null:
			preview_building.queue_free()

		preview_building = current_building.instantiate()
		preview.add_child(preview_building)
var current_building_idx: int = 0
var moused_over_cell: Vector2i
var preview_building: Building
var rotating_camera: bool = false
var dir: Building.Dir = Building.Dir.DOWN :
	set(value):
		dir = value

@onready var grid: Grid3D = $Grid3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = %Camera3D
@onready var preview: Node3D = $Preview


func _ready() -> void:
	current_building = buildings[current_building_idx]


func _process(delta: float) -> void:
	moused_over_cell = grid.world_to_map(_get_mouse_pos_in_world())

	# Hide the preview if the position isn't valid.
	preview.visible = grid.are_values_null(preview_building.get_cells(moused_over_cell, dir))

	preview.rotation.y = preview_building.get_rotation_angle(dir)

	var preview_dir_offset := preview_building.get_dir_offset(dir) * grid.cell_size
	var preview_offset := Vector3.UP * 0.5 + (Vector3(preview_dir_offset.x, 0, preview_dir_offset.y))
	preview.global_position = grid.map_to_world(moused_over_cell) + preview_offset


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			_place_building()

		if event.button_index == MOUSE_BUTTON_MIDDLE:
			rotating_camera = event.is_pressed()
			if not rotating_camera:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	if event.is_action_pressed("next_building"):
		current_building_idx = wrapi(current_building_idx + 1, 0, buildings.size())
		current_building = buildings[current_building_idx]

	if event.is_action_pressed("rotate"):
		# Set next direction.
		dir = wrapi(dir + 1, 0, 4)

	if event is InputEventMouseMotion and rotating_camera:
		_rotate_camera(event)


func _place_building() -> void:
	var origin := moused_over_cell
	var building := current_building.instantiate()
	if not (building is Building):
		return

	# Get all cells the building will occupy, for buildings larger than 1x1.
	var cells: Array[Vector2i] = building.get_cells(origin, dir)
	# Check if all cells are free.
	if not grid.are_values_null(cells):
		print("Can't build here!")
		return

	grid.set_values(cells, building)
	add_child(building)

	building.rotation.y = building.get_rotation_angle(dir)
	building.global_position = grid.map_to_world(origin + building.get_dir_offset(dir))


func _get_mouse_pos_in_world() -> Vector3:
	var space_state = get_world_3d().direct_space_state

	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 2000
	var ray_array = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_end))

	if ray_array.has("position"):
		return ray_array.position

	return Vector3()


func _rotate_camera(event: InputEventMouseMotion) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	Input.set_default_cursor_shape(Input.CURSOR_MOVE)

	camera_pivot.rotation.y -= event.relative.x * 0.005
	camera_pivot.rotation.y = wrapf(camera_pivot.rotation.y, 0.0, TAU)

	camera_pivot.rotation.x -= event.relative.y * 0.005
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(-30))
