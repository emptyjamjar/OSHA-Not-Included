extends Control

## Pause menu for the game.

func _ready() -> void:
	visible = false # Replace with function body.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == true:
			get_tree().paused = false
		else:
			get_tree().paused = true
		
		if visible == true:
			visible = false
		else:
			visible = true
