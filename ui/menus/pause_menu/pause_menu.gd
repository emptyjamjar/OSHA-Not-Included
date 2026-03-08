## Pause menu for the game.
extends Control

var isSubMenuOpen := false


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if isSubMenuOpen:
		return
	if event.is_action_pressed("pause") and InteractionManager.can_interact:
		get_tree().paused = not get_tree().paused
		visible = not visible


func _on_sub_menu_opened() -> void:
	isSubMenuOpen = true


func _on_sub_menu_closed() -> void:
	isSubMenuOpen = false
