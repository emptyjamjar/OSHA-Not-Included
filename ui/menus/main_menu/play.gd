extends TextureButton

## Play button for main menu.
	
func _on_button_up() -> void:
	get_tree().change_scene_to_file("res://game.tscn") # Replace with function body.
