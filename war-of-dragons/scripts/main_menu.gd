extends Control

func _on_start_button_pressed() -> void:
	Global.load_from_save = false
	get_tree().change_scene_to_file("uid://b55p48oyoj4p8")

func _on_load_button_pressed() -> void:
	Global.load_from_save = true
	get_tree().change_scene_to_file("uid://b55p48oyoj4p8")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
