## Resume button for pause menu.
extends TextureButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_button_up() -> void:
	Audio.play_close_menu()
	Audio.reset_music_volume()
	get_tree().paused = false
	$"..".visible = false
