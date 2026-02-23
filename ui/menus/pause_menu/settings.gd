extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_button_up() -> void:
	# todo: wait for dev to make relevant settings
	#get_tree().paused = false
	pass
