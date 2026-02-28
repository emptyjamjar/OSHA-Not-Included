## Pause menu for the game.
extends Control


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and InteractionManager.can_interact:
		get_tree().paused = not get_tree().paused
		visible = not visible
