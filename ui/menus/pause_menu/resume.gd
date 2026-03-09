## Resume button for pause menu.
extends TextureButton


func _on_button_up() -> void:
	Audio.play_close_menu()
	get_tree().paused = false
	$"..".visible = false
