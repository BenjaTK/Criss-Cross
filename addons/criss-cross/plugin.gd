@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("Grid2D", "Node2D", preload("nodes/grid2d.gd"), preload("nodes/grid2d.svg"))
	add_custom_type("Grid3D", "Node3D", preload("nodes/grid3d.gd"), preload("nodes/grid3d.svg"))


func _exit_tree() -> void:
	remove_custom_type("Grid2D")
	remove_custom_type("Grid3D")
