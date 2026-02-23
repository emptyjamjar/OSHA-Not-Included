extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false # Replace with function body.
	process_mode = Node.PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == true:
			get_tree().paused = false
		else:
			get_tree().paused = true
		
		if visible == true:
			visible = false
		else:
			visible = true
