@tool
extends EditorPlugin


const UpdateButton := preload("res://addons/criss-cross/editor/update_button.tscn")

var update_button


func _enter_tree() -> void:
	update_button = UpdateButton.instantiate() as Button
	update_button.editor_plugin = self
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, update_button)


func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, update_button)
