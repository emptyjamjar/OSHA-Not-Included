## Quit button for pause menu.
extends TextureButton


func _on_button_up() -> void:
	Audio.play_exit_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/menus/main_menu/main_menu.tscn")
