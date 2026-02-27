extends TextureButton

## Resume button for pause menu.

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
func _on_button_up() -> void:
	get_tree().paused = false
	$"..".visible = false
