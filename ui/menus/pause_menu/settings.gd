extends TextureButton

## Settings button for pause menu.

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
func _on_button_up() -> void:
	# todo: wait for dev to make relevant settings
	#get_tree().paused = false
	pass
